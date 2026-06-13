# 버릴지말지 백엔드

## 시작하기

### 1. 가상환경 만들기
```bash
python -m venv venv

# Windows
venv\Scripts\activate

# Mac/Linux
source venv/bin/activate
```

### 2. 패키지 설치
```bash
pip install -r requirements.txt
```

### 3. 환경변수 설정
```bash
cp .env.example .env
# .env 파일 열어서 DB 비밀번호 등 채우기
```

### 4. MySQL DB 만들기
MySQL에서 아래 명령어 실행:
```sql
CREATE DATABASE buriljimalji CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 5. 서버 실행
```bash
uvicorn main:app --reload
```

서버가 켜지면:
- API 서버: http://127.0.0.1:8000
- 자동 API 문서: http://127.0.0.1:8000/docs  ← 여기서 바로 테스트 가능!

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
| GET | /community/posts | 게시글 목록 |
| POST | /community/posts | 게시글 작성 |
| DELETE | /community/posts/{id} | 게시글 삭제 |
| POST | /community/posts/{id}/comments | 댓글 작성 |
| POST | /community/posts/{id}/like | 좋아요 토글 |
| POST | /community/posts/{id}/report | 신고 |

### 사진 분석
| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | /photo/analyze | 사진 업로드 → YOLO 분석 |

### 로그
| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | /logs | 사용자 행동 로그 저장 |
