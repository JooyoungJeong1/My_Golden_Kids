from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from passlib.context import CryptContext
from database import get_db
from models.tables import User, Log
from datetime import datetime

router = APIRouter(prefix="/auth", tags=["인증"])
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# ─────────────────────────
# 요청/응답 스키마
# ─────────────────────────
class SignupRequest(BaseModel):
    email: str
    nickname: str
    password: str

class LoginRequest(BaseModel):
    email: str
    password: str

class UserResponse(BaseModel):
    id: int
    email: str
    nickname: str
    profile_emoji: str


# ─────────────────────────
# 회원가입
# ─────────────────────────
@router.post("/signup", response_model=UserResponse)
def signup(req: SignupRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == req.email).first():
        raise HTTPException(status_code=400, detail="이미 사용 중인 이메일이에요.")

    hashed_pw = pwd_context.hash(req.password)
    user = User(email=req.email, nickname=req.nickname, password=hashed_pw)
    db.add(user)
    db.commit()
    db.refresh(user)

    db.add(Log(user_id=user.id, user_email=user.email, action="signup", detail=f"회원가입: {user.email}"))
    db.commit()

    return user


# ─────────────────────────
# 로그인
# ─────────────────────────
@router.post("/login", response_model=UserResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()

    if not user or not pwd_context.verify(req.password, user.password):
        raise HTTPException(status_code=401, detail="이메일 또는 비밀번호가 올바르지 않아요.")

    db.add(Log(user_id=user.id, user_email=user.email, action="login", detail=f"로그인: {user.email}"))
    db.commit()

    return user


# ─────────────────────────
# 닉네임 변경
# ─────────────────────────
class NicknameChangeRequest(BaseModel):
    user_id: int
    new_nickname: str

@router.patch("/nickname")
def change_nickname(req: NicknameChangeRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == req.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="유저를 찾을 수 없어요.")

    # 7일 제한 체크
    if user.nickname_changed_at:
        diff = datetime.utcnow() - user.nickname_changed_at
        if diff.days < 7:
            remaining = 7 - diff.days
            raise HTTPException(status_code=400, detail=f"{remaining}일 후에 변경 가능해요.")

    user.nickname = req.new_nickname
    user.nickname_changed_at = datetime.utcnow()
    db.add(Log(user_id=user.id, user_email=user.email, action="nickname_change", detail=f"닉네임 변경: {req.new_nickname}"))
    db.commit()
    db.refresh(user)

    return {"message": "닉네임이 변경되었어요!", "nickname": user.nickname}


# ─────────────────────────
# 비밀번호 변경
# ─────────────────────────
class PasswordChangeRequest(BaseModel):
    user_id: int
    current_password: str
    new_password: str

@router.patch("/password")
def change_password(req: PasswordChangeRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == req.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="유저를 찾을 수 없어요.")
    if not pwd_context.verify(req.current_password, user.password):
        raise HTTPException(status_code=401, detail="현재 비밀번호가 올바르지 않아요.")

    user.password = pwd_context.hash(req.new_password)
    db.add(Log(user_id=user.id, user_email=user.email, action="password_change", detail="비밀번호 변경"))
    db.commit()

    return {"message": "비밀번호가 변경되었어요!"}


# ─────────────────────────
# 프로필 이모지 변경
# ─────────────────────────
class ProfileEmojiRequest(BaseModel):
    user_id: int
    emoji: str

@router.patch("/profile-emoji")
def change_profile_emoji(req: ProfileEmojiRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == req.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="유저를 찾을 수 없어요.")

    user.profile_emoji = req.emoji
    db.add(Log(user_id=user.id, user_email=user.email, action="profile_change", detail=f"프로필 변경: {req.emoji}"))
    db.commit()

    return {"message": "프로필이 변경되었어요!", "emoji": user.profile_emoji}
