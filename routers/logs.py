from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from database import get_db
from models.tables import Log

router = APIRouter(prefix="/logs", tags=["로그"])


class LogRequest(BaseModel):
    user_id: Optional[int] = None
    user_email: Optional[str] = None
    action: str    # login, logout, nickname_change, profile_change ...
    detail: Optional[str] = None


@router.post("")
def save_log(req: LogRequest, db: Session = Depends(get_db)):
    log = Log(
        user_id=req.user_id,
        user_email=req.user_email,
        action=req.action,
        detail=req.detail,
    )
    db.add(log)
    db.commit()
    return {"message": "로그 저장 완료"}
