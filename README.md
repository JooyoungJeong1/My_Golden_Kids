# 버릴래말래 (Flutter App)

분리배출 AI 도우미 앱 - 사진 또는 채팅으로 쓰레기 분리배출 방법을 알려주는 서비스

---

## 기술 스택

- **Frontend**: Flutter
- **Backend**: FastAPI + MySQL
- **AI**: YOLO (분리배출 이미지 분석), Claude API (채팅)

---

## 주요 기능

### 🤖 AI 분석
- 사진 촬영 또는 갤러리에서 이미지 업로드
- YOLO 모델로 쓰레기 종류 자동 감지
- 분리배출 방법 및 신뢰도 표시
- 여러 품목 동시 감지 지원

### 💬 AI 채팅
- 품목명 입력 시 분리배출 방법 안내
- 키워드 기반 빠른 답변
- 모르는 품목은 Claude API로 자동 연결
- 꼬리질문 버튼으로 추가 정보 제공

### 👤 회원 기능
- 아이디/비밀번호 회원가입 및 로그인
- 닉네임 변경 (7일 제한, 백엔드에서 관리)
- 비밀번호 변경
- 프로필 이모지 선택
- 문의하기 (MySQL logs 테이블에 저장)

### 🌿 커뮤니티
- 게시글 작성 / 삭제
- 댓글 작성
- 좋아요 토글
- 신고 기능 (3회 누적 시 자동 숨김)
- 내가 쓴 글 / 내가 쓴 댓글 조회
- 인기 게시글 하이라이트

### 📋 카테고리별 배출법
- 종이류, 캔류, 유리, 플라스틱, 비닐 등
- 4단계 분리배출 가이드

---

## 서버 연결 방식

자동 서버 탐색 (캐싱 방식) 적용:
- 앱 실행 후 첫 API 호출 시 자동으로 서버 탐색
- 안드로이드 에뮬레이터 → 배포 서버 순서로 탐색
- 찾은 서버 주소를 캐싱하여 이후 API 호출에 재사용
- 탐색 우선순위 
    1. http://10.0.2.2:8000        // 안드로이드 에뮬레이터
    2. http://211.104.25.94:8000   // 배포 서버

    ---

## 시작하기

### 1. 패키지 설치
```bash
flutter pub get
```

### 2. 앱 실행
```bash
flutter run
```

### 3. 백엔드 서버 실행
```bash
cd ../My_Golden_Kids
venv\Scripts\activate
uvicorn main:app --reload
```

서버가 켜지면:
- API 서버: http://127.0.0.1:8000
- API 문서: http://127.0.0.1:8000/docs

---

## 프로젝트 구조

```
lib/
├── models/
│   ├── category.dart       # 카테고리 모델
│   └── user_session.dart   # 로그인 세션 관리
├── screens/
│   ├── home_screen.dart    # 홈 화면
│   ├── chat_page.dart      # AI 채팅
│   ├── photo_page.dart     # 사진 분석
│   ├── community_page.dart # 커뮤니티
│   ├── my_page.dart        # 마이페이지
│   ├── login_page.dart     # 로그인
│   └── signup_page.dart    # 회원가입
├── services/
│   ├── api_service.dart    # 백엔드 API 연결
│   └── log_service.dart    # 로그 서비스
└── widgets/
    ├── category_card.dart      # 카테고리 카드
    └── typing_indicator.dart   # 채팅 타이핑 애니메이션
```

---

## API 목록

### 인증
| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | /auth/signup | 회원가입 |
| POST | /auth/login | 로그인 |
| PATCH | /auth/nickname | 닉네임 변경 (7일 제한) |
| PATCH | /auth/password | 비밀번호 변경 |
| PATCH | /auth/profile-emoji | 프로필 이모지 변경 |

### 커뮤니티
| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | /community/posts | 게시글 목록 조회 |
| POST | /community/posts | 게시글 작성 |
| DELETE | /community/posts/{id} | 게시글 삭제 |
| POST | /community/posts/{id}/comments | 댓글 작성 |
| POST | /community/posts/{id}/like | 좋아요 토글 |
| POST | /community/posts/{id}/report | 신고 |
| GET | /community/posts/my | 내가 쓴 글 조회 |
| GET | /community/comments/my | 내가 쓴 댓글 조회 |

### 사진 분석
| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | /photo/analyze | 사진 업로드 → YOLO 분석 |

### 채팅
| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | /chat | AI 채팅 (Claude API 연동) |

### 로그 & 문의
| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | /logs | 사용자 행동 로그 저장 |
| POST | /logs | 문의하기 저장 (action: inquiry) |