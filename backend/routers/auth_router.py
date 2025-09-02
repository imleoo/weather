from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import timedelta

from database import get_db
from schemas import UserCreate, UserLogin, UserResponse, Token, SuccessResponse
from auth import create_access_token, get_password_hash, verify_password
from config import settings
import crud

router = APIRouter()

@router.post("/register", response_model=dict)
async def register(user: UserCreate, db: Session = Depends(get_db)):
    """用户注册"""
    # 检查邮箱是否已存在
    if crud.get_user_by_email(db, user.email):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="邮箱已被注册"
        )
    
    # 创建用户
    db_user = crud.create_user(db, user)
    
    # 生成访问令牌
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"email": db_user.email}, 
        expires_delta=access_token_expires
    )
    
    user_response = UserResponse(
        id=db_user.id,
        email=db_user.email,
        nickname=db_user.nickname,
        bio=db_user.bio,
        avatar_url=db_user.avatar_url,
        is_active=db_user.is_active,
        created_at=db_user.created_at,
        updated_at=db_user.updated_at
    )
    
    return {
        "message": "注册成功",
        "token": access_token,
        "user": user_response
    }

@router.post("/login", response_model=Token)
async def login(user: UserLogin, db: Session = Depends(get_db)):
    """用户登录"""
    # 查找用户
    db_user = crud.get_user_by_email(db, user.email)
    if not db_user or not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="邮箱或密码错误",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # 生成访问令牌
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"email": db_user.email}, 
        expires_delta=access_token_expires
    )
    
    user_response = UserResponse(
        id=db_user.id,
        email=db_user.email,
        nickname=db_user.nickname,
        bio=db_user.bio,
        avatar_url=db_user.avatar_url,
        is_active=db_user.is_active,
        created_at=db_user.created_at,
        updated_at=db_user.updated_at
    )
    
    return Token(
        access_token=access_token,
        token_type="bearer",
        user=user_response
    )