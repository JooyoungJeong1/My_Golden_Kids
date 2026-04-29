from fastapi import APIRouter
import httpx
import os
from dotenv import load_dotenv

load_dotenv()

router = APIRouter(prefix="/chat", tags=["채팅"])

API_KEY = os.getenv("ANTHROPIC_API_KEY")

@router.post("")
async def chat(message: str):
    async with httpx.AsyncClient() as client:
        response = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": API_KEY,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json={
                "model": "claude-haiku-4-5-20251001",
                "max_tokens": 1024,
                "system": "당신은 분리배출 전문 도우미입니다. 친절하고 간결하게 한국어로 답변하세요.",
                "messages": [{"role": "user", "content": message}],
            },
            timeout=30.0,
        )
        data = response.json()
        return {"reply": data["content"][0]["text"]}