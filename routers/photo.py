from fastapi import APIRouter, UploadFile, File, HTTPException
from PIL import Image
import io
import base64
import httpx
import os
from dotenv import load_dotenv

router = APIRouter(prefix="/photo", tags=["사진 분석"])

# YOLO 모델 로딩 (서버 시작 시 1회만)
try:
    from ultralytics import YOLO
    from huggingface_hub import hf_hub_download
    model = YOLO(hf_hub_download("huggingleg12/recycle-yolo11", "weights/best.pt"))
    YOLO_AVAILABLE = True
except Exception:
    YOLO_AVAILABLE = False
    print("[경고] YOLO 모델 로딩 실패. pip install ultralytics 확인하세요.")


# 감지 라벨 → 분리배출 정보 매핑
LABEL_MAP = {
    "paper": {
        "name": "종이",
        "category": "종이류",
        "steps": "① 테이프·스티커 제거\n② 납작하게 펼치기\n③ 종이류 수거함에 배출",
        "badges": [{"label": "종이류 ♻️", "bgColor": "BBDEFB", "textColor": "0D47A1"}],
    },
    "paper_pack": {
        "name": "종이팩",
        "category": "종이류",
        "steps": "① 내용물 비우고 헹구기\n② 펼쳐서 말리기\n③ 종이팩 전용 수거함에 배출",
        "badges": [{"label": "종이팩 ♻️", "bgColor": "BBDEFB", "textColor": "0D47A1"}],
    },
    "paper_cup": {
        "name": "종이컵",
        "category": "종이류",
        "steps": "① 내용물 비우고 헹구기\n② 종이컵 전용 수거함에 배출",
        "badges": [{"label": "종이컵 ♻️", "bgColor": "BBDEFB", "textColor": "0D47A1"}],
    },
    "can": {
        "name": "캔류",
        "category": "캔류",
        "steps": "① 내용물 비우고 헹구기\n② 찌그러트리기\n③ 캔 수거함에 배출",
        "badges": [{"label": "캔류 ♻️", "bgColor": "FFF9C4", "textColor": "7A6000"}],
    },
    "reusable_glass": {
        "name": "재사용유리",
        "category": "유리류",
        "steps": "① 내용물 비우고 헹구기\n② 뚜껑 분리\n③ 유리 수거함에 배출",
        "badges": [{"label": "유리류 ♻️", "bgColor": "E8EAF6", "textColor": "1A237E"}],
    },
    "colored_glass": {
        "name": "색깔유리",
        "category": "유리류",
        "steps": "① 내용물 비우고 헹구기\n② 뚜껑 분리\n③ 유리 수거함에 배출",
        "badges": [{"label": "유리류 ♻️", "bgColor": "E8EAF6", "textColor": "1A237E"}],
    },
    "pet": {
        "name": "페트병",
        "category": "플라스틱류",
        "steps": "① 라벨 제거\n② 내용물 비우고 헹구기\n③ 찌그러트려 뚜껑 닫기\n④ 플라스틱 수거함에 배출",
        "badges": [{"label": "플라스틱 ♻️", "bgColor": "C8E6C9", "textColor": "1B5E20"}],
    },
    "plastic": {
        "name": "플라스틱",
        "category": "플라스틱류",
        "steps": "① 내용물 비우고 헹구기\n② 라벨 제거\n③ 플라스틱 수거함에 배출",
        "badges": [{"label": "플라스틱 ♻️", "bgColor": "C8E6C9", "textColor": "1B5E20"}],
    },
    "vinyl": {
        "name": "비닐",
        "category": "비닐류",
        "steps": "① 내용물 완전히 비우기\n② 이물질 제거\n③ 비닐 전용 수거함에 배출",
        "badges": [{"label": "비닐류 ♻️", "bgColor": "F8BBD0", "textColor": "880E4F"}],
    },
    "styrofoam": {
        "name": "스티로폼",
        "category": "스티로폼류",
        "steps": "① 이물질 제거\n② 테이프·스티커 제거\n③ 스티로폼 전용 수거함에 배출",
        "badges": [{"label": "스티로폼 ♻️", "bgColor": "F3E5F5", "textColor": "4A148C"}],
    },
    "battery": {
        "name": "건전지",
        "category": "건전지",
        "steps": "① 방전 확인\n② 건전지 전용 수거함에 배출\n③ 편의점, 마트 등에 비치된 수거함 이용",
        "badges": [{"label": "유해폐기물", "bgColor": "FFCCBC", "textColor": "BF360C"}],
    },
}

async def analyze_ai(base64_image: str, media_type: str = "image/jpeg") -> dict:
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://api.anthropic.com/v1/messages",
                headers={
                    "x-api-key": os.getenv("ANTHROPIC_API_KEY"),
                    "anthropic-version": "2023-06-01",
                    "content-type": "application/json",
                },
                json={
                    "model": "claude-haiku-4-5-20251001",
                    "max_tokens": 256,
                    "messages": [{
                        "role": "user",
                        "content": [
                            {
                                "type": "image",
                                "source": {
                                    "type": "base64",
                                    "media_type": media_type,
                                    "data": base64_image
                                }
                            },
                            {
                                "type": "text",
                                "text": "이 이미지를 분석해서 JSON으로만 답해줘. 다른 말은 하지마.\n{\"contamination\": true or false, \"multi_packaging\": true or false}\ncontamination: 음식물, 기름, 오염물질 등 이물질이 있으면 true\nmulti_packaging: 플라스틱+금속, 종이+비닐처럼 서로 다른 재질이 결합되어 분리가 어려운 경우만 true. 단순히 라벨이나 스티커가 붙어있는 것은 false"
                            }
                        ]
                    }]
                },
                timeout=30.0,
            )
            data = response.json()
            text = data["content"][0]["text"]
            print(f"원본응답: {text}")

            # 코드블록 제거
            text = text.replace("```json", "").replace("```", "").strip()

            import json
            result = json.loads(text)
            print(f"분석결과: {result}")     

            return result
    except Exception as e:
        print(f"사진분석 오류: {e}")
        return {"contamination": False, "multi_packaging": False}

@router.post("/analyze")
async def analyze_photo(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="이미지 파일만 업로드 가능해요.")

    if not YOLO_AVAILABLE:
        raise HTTPException(status_code=503, detail="YOLO 모델이 준비되지 않았어요.")

    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")

    results = model(image)

    detected = []
    seen_labels = set()

    for box in results[0].boxes:
        label = model.names[int(box.cls)]
        confidence = float(box.conf)

        if confidence >= 0.4 and label in LABEL_MAP and label not in seen_labels:
            seen_labels.add(label)
            info = LABEL_MAP[label]
            detected.append({
                "label": label,
                "confidence": round(confidence * 100),
                **info,
            })

    if not detected:
        return {
            "result": "unknown",
            "message": "물체를 인식하기 어려워요. 더 가까이서 찍거나 채팅으로 물어보세요!",
            "items": [],
        }
    
    # AI로 이물질/다중포장재 분석
    base64_image = base64.b64encode(image_bytes).decode('utf-8')
    ai_result = await analyze_ai(base64_image, file.content_type)

    return {
        "result": "success",
        "items": detected,
        "contamination": ai_result.get("contamination", False),
        "multi_packaging": ai_result.get("multi_packaging", False),
    }
