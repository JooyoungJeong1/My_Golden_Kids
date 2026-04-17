from fastapi import APIRouter, UploadFile, File, HTTPException
from PIL import Image
import io

router = APIRouter(prefix="/photo", tags=["사진 분석"])

# YOLO 모델 로딩 (서버 시작 시 1회만)
try:
    from ultralytics import YOLO
    model = YOLO("yolov8n.pt")
    YOLO_AVAILABLE = True
except Exception:
    YOLO_AVAILABLE = False
    print("[경고] YOLO 모델 로딩 실패. pip install ultralytics 확인하세요.")


# 감지 라벨 → 분리배출 정보 매핑
LABEL_MAP = {
    "bottle": {
        "name": "페트병 / 유리병",
        "category": "플라스틱 또는 유리",
        "steps": "① 라벨 제거\n② 내용물 비우고 헹구기\n③ 찌그러트려 뚜껑 닫기\n④ 플라스틱 또는 유리 수거함에 배출",
        "badges": [
            {"label": "재활용 가능", "bgColor": "C8E6C9", "textColor": "1B5E20"},
        ],
    },
    "cup": {
        "name": "컵 / 용기",
        "category": "플라스틱",
        "steps": "① 내용물 완전히 비우기\n② 물로 헹구기\n③ 플라스틱 수거함에 배출",
        "badges": [
            {"label": "플라스틱 ♻️", "bgColor": "C8E6C9", "textColor": "1B5E20"},
        ],
    },
    "can": {
        "name": "캔",
        "category": "캔류",
        "steps": "① 내용물 비우고 헹구기\n② 찌그러트리기\n③ 캔 수거함에 배출",
        "badges": [
            {"label": "캔류 ♻️", "bgColor": "FFF9C4", "textColor": "7A6000"},
        ],
    },
    "book": {
        "name": "책 / 종이류",
        "category": "종이류",
        "steps": "① 코팅 표지, 스프링 분리\n② 끈으로 묶기\n③ 종이류 수거함에 배출",
        "badges": [
            {"label": "종이류 ♻️", "bgColor": "BBDEFB", "textColor": "0D47A1"},
        ],
    },
    "cardboard": {
        "name": "박스",
        "category": "종이류",
        "steps": "① 테이프·스티커 제거\n② 납작하게 펼치기\n③ 종이류 수거함에 배출",
        "badges": [
            {"label": "종이류 ♻️", "bgColor": "BBDEFB", "textColor": "0D47A1"},
        ],
    },
    "plastic bag": {
        "name": "비닐봉투",
        "category": "비닐류",
        "steps": "① 내용물 완전히 비우기\n② 이물질 제거\n③ 비닐 전용 수거함에 배출",
        "badges": [
            {"label": "비닐류 ♻️", "bgColor": "F8BBD0", "textColor": "880E4F"},
        ],
    },
}


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

    return {
        "result": "success",
        "items": detected,
    }
