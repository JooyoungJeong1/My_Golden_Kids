from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine
from models.tables import Base
from routers import auth, community, photo, logs

# ─────────────────────────
# DB 테이블 자동 생성
# (서버 시작 시 테이블 없으면 자동으로 만들어줌)
# ─────────────────────────
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="버릴지말지 API",
    description="분리배출 도우미 앱 백엔드",
    version="1.0.0",
)

# CORS 설정 (Flutter 앱에서 접근 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 배포 시 앱 도메인으로 교체
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 등록
app.include_router(auth.router)
app.include_router(community.router)
app.include_router(photo.router)
app.include_router(logs.router)


@app.get("/")
def root():
    return {"status": "ok", "service": "버릴지말지 API 🌿"}
