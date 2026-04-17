from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from pydantic import BaseModel
from typing import Optional
from database import get_db
from models.tables import Post, Comment, Like, Report

router = APIRouter(prefix="/community", tags=["커뮤니티"])


# ─────────────────────────
# 스키마
# ─────────────────────────
class PostCreate(BaseModel):
    user_id: Optional[int] = None
    session_id: Optional[str] = None
    author_nickname: str
    title: str
    content: str

class CommentCreate(BaseModel):
    user_id: Optional[int] = None
    session_id: Optional[str] = None
    author_nickname: str
    content: str


# ─────────────────────────
# 게시글 목록 조회
# ─────────────────────────
@router.get("/posts")
def get_posts(db: Session = Depends(get_db)):
    posts = (
        db.query(Post)
        .filter(Post.is_hidden == False)
        .options(joinedload(Post.comments))
        .order_by(Post.created_at.desc())
        .all()
    )
    result = []
    for p in posts:
        result.append({
            "id": p.id,
            "author": p.author_nickname,
            "session_id": p.session_id,
            "title": p.title,
            "content": p.content,
            "likes": p.likes,
            "report_count": p.report_count,
            "created_at": p.created_at.isoformat(),
            "comments": [
                {
                    "id": c.id,
                    "author": c.author_nickname,
                    "content": c.content,
                    "created_at": c.created_at.isoformat(),
                }
                for c in p.comments
            ],
        })
    return result


# ─────────────────────────
# 게시글 작성
# ─────────────────────────
@router.post("/posts")
def create_post(req: PostCreate, db: Session = Depends(get_db)):
    post = Post(
        user_id=req.user_id,
        session_id=req.session_id,
        author_nickname=req.author_nickname,
        title=req.title,
        content=req.content,
    )
    db.add(post)
    db.commit()
    db.refresh(post)
    return {"message": "게시글이 등록되었어요!", "post_id": post.id}


# ─────────────────────────
# 게시글 삭제
# ─────────────────────────
@router.delete("/posts/{post_id}")
def delete_post(post_id: int, session_id: Optional[str] = None, user_id: Optional[int] = None, db: Session = Depends(get_db)):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="게시글을 찾을 수 없어요.")

    # 본인 글만 삭제 가능
    is_owner = (user_id and post.user_id == user_id) or (session_id and post.session_id == session_id)
    if not is_owner:
        raise HTTPException(status_code=403, detail="본인 글만 삭제할 수 있어요.")

    db.delete(post)
    db.commit()
    return {"message": "게시글이 삭제되었어요."}


# ─────────────────────────
# 댓글 작성
# ─────────────────────────
@router.post("/posts/{post_id}/comments")
def create_comment(post_id: int, req: CommentCreate, db: Session = Depends(get_db)):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="게시글을 찾을 수 없어요.")

    comment = Comment(
        post_id=post_id,
        user_id=req.user_id,
        session_id=req.session_id,
        author_nickname=req.author_nickname,
        content=req.content,
    )
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return {"message": "댓글이 등록되었어요!", "comment_id": comment.id}


# ─────────────────────────
# 좋아요 토글
# ─────────────────────────
class LikeRequest(BaseModel):
    user_id: Optional[int] = None
    session_id: Optional[str] = None

@router.post("/posts/{post_id}/like")
def toggle_like(post_id: int, req: LikeRequest, db: Session = Depends(get_db)):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="게시글을 찾을 수 없어요.")

    query = db.query(Like).filter(Like.post_id == post_id)
    if req.user_id:
        query = query.filter(Like.user_id == req.user_id)
    else:
        query = query.filter(Like.session_id == req.session_id)

    existing = query.first()
    if existing:
        db.delete(existing)
        post.likes = max(0, post.likes - 1)
        db.commit()
        return {"liked": False, "likes": post.likes}
    else:
        db.add(Like(post_id=post_id, user_id=req.user_id, session_id=req.session_id))
        post.likes += 1
        db.commit()
        return {"liked": True, "likes": post.likes}


# ─────────────────────────
# 신고
# ─────────────────────────
class ReportRequest(BaseModel):
    reporter_email: str

@router.post("/posts/{post_id}/report")
def report_post(post_id: int, req: ReportRequest, db: Session = Depends(get_db)):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="게시글을 찾을 수 없어요.")

    already = db.query(Report).filter(
        Report.post_id == post_id,
        Report.reporter_email == req.reporter_email
    ).first()
    if already:
        raise HTTPException(status_code=400, detail="이미 신고한 게시글이에요.")

    db.add(Report(post_id=post_id, reporter_email=req.reporter_email))
    post.report_count += 1
    if post.report_count >= 3:
        post.is_hidden = True 
    db.commit()

    return {"message": "신고가 접수되었어요.", "report_count": post.report_count}


# ─────────────────────────
# 내가 쓴 글 목록 조회
# ─────────────────────────
@router.get("/posts/my")
def get_my_posts(user_id: Optional[int] = None, session_id: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Post).filter(Post.is_hidden == False)
    if user_id:
        query = query.filter(Post.user_id == user_id)
    elif session_id:
        query = query.filter(Post.session_id == session_id)
    posts = query.order_by(Post.created_at.desc()).all()
    return [
        {
            "id": p.id,
            "title": p.title,
            "content": p.content,
            "likes": p.likes,
            "created_at": p.created_at.isoformat(),
        }
        for p in posts
    ]


# ─────────────────────────
# 내가 쓴 댓글 목록 조회
# ─────────────────────────
@router.get("/comments/my")
def get_my_comments(user_id: Optional[int] = None, session_id: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Comment)
    if user_id:
        query = query.filter(Comment.user_id == user_id)
    elif session_id:
        query = query.filter(Comment.session_id == session_id)
    comments = query.order_by(Comment.created_at.desc()).all()
    return [
        {
            "id": c.id,
            "post_id": c.post_id,
            "content": c.content,
            "created_at": c.created_at.isoformat(),
        }
        for c in comments
    ]