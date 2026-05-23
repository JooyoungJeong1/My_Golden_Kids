from fastapi import APIRouter
from pydantic import BaseModel
from typing import List
import httpx
import os
import csv
from dotenv import load_dotenv

load_dotenv()

router = APIRouter(prefix="/chat", tags=["채팅"])

API_KEY = os.getenv("ANTHROPIC_API_KEY")

# 서버 시작 시 CSV 1회 로드
DISPOSAL_DATA = []

def load_csv():
    csv_path = os.path.join(os.path.dirname(__file__), "rules.csv")
    if not os.path.exists(csv_path):
        print("[경고] 분리배출기준.csv 파일을 찾을 수 없어요.")
        return
    with open(csv_path, encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            DISPOSAL_DATA.append(row)
    print(f"[INFO] 분리배출기준 {len(DISPOSAL_DATA)}개 항목 로드 완료")

load_csv()


# 질문과 관련된 CSV 항목 검색
def search_disposal(query: str) -> str:
    if not DISPOSAL_DATA:
        return ""

    keywords = query.replace(" ", "").lower()
    matched = []

    for row in DISPOSAL_DATA:
        searchable = (
            row.get("클래스명", "") +
            row.get("품목예시", "") +
            row.get("배출방법", "") +
            row.get("주의사항", "") +
            row.get("배출불가항목", "")
        ).replace(" ", "").lower()

        if any(kw in searchable for kw in keywords):
            matched.append(row)

    if not matched:
        return ""

    result = []
    for row in matched[:3]:  # 최대 3개 항목만
        result.append(
            f"[{row['클래스명']}]\n"
            f"품목예시: {row['품목예시']}\n"
            f"배출방법: {row['배출방법']}\n"
            f"주의사항: {row['주의사항']}\n"
            f"배출불가: {row['배출불가항목']}"
        )
    return "\n\n".join(result)


# 요청 스키마
class ChatMessage(BaseModel):
    role: str       # "user" 또는 "assistant"
    content: str

class ChatRequest(BaseModel):
    messages: List[ChatMessage]  # 전체 대화 히스토리


# 채팅 API
@router.post("")
async def chat(req: ChatRequest):
    # 마지막 유저 메시지로 CSV 검색
    last_user_msg = next(
        (m.content for m in reversed(req.messages) if m.role == "user"), ""
    )
    context = search_disposal(last_user_msg)

    # 시스템 프롬프트에 CSV 컨텍스트 추가
    system_prompt = "당신은 분리배출 전문 도우미입니다. 친절하고 간결하게 한국어로 답변하세요."
    if context:
        system_prompt += f"\n\n아래는 관련 분리배출 기준입니다. 이 내용을 우선적으로 참고하여 답변하세요:\n\n{context}"

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
                "system": system_prompt,
                "messages": [{"role": m.role, "content": m.content} for m in req.messages],
            },
            timeout=30.0,
        )
        data = response.json()
        return {"reply": data["content"][0]["text"]}