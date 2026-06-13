# My_Golden_Kids
bigdata_CapstoneDesign
# 버릴래말래

YOLO11과 LLM 기반 생활폐기물 분리배출 안내 서비스

## 기술 스택
- Frontend: Flutter
- Backend: FastAPI + SQLite
- AI: YOLO11 (객체 탐지), Claude API (이물질 판단 / 채팅)

## 주요 기능
- 사진 촬영 → YOLO11 품목 탐지 → Claude Haiku 이물질 판단 → 배출방법 안내
- 텍스트 자유 질문 → Claude Sonnet → 배출방법 안내
- 회원가입 / 로그인
- 커뮤니티 게시판

## 프로젝트 구조
- frontend/ : Flutter 앱
- backend/ : FastAPI 서버
- preprocessing/ : 데이터 전처리 코드
- model/ : YOLO11 학습 코드 (Colab 노트북)

## 모델
- YOLO11m 파인튜닝
- Hugging Face: https://huggingface.co/huggingleg12/recycle-yolo11
- mAP@50: 0.893 (1차), 0.857 (2차)

## 시작하기
### 백엔드
cd My_Golden_Kids
venv\Scripts\activate
uvicorn main:app --reload

### 프론트엔드
flutter pub get
flutter run

## 팀원
| 이름 | 역할 |
|------|------|
| 정주영 | PM · AI 모델 담당 |
| 김가연 | 프론트엔드 · 카메라 |
| 김경남 | 프론트엔드 · UI/UX |
| 이승열 | 백엔드 · FastAPI |
| 이승준 | 백엔드 · Flutter 연동 |
