from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from schemas import UserResponse
import crud

router = APIRouter()

# TODO: 需要从main.py导入get_current_user
# from main import get_current_user

# @router.get("/me/fish-catches", response_model=dict)
# async def get_user_fish_catches(
#     current_user = Depends(get_current_user),
#     db: Session = Depends(get_db)
# ):
#     """获取当前用户的鱼获列表"""
#     catches = crud.get_user_fish_catches(db, current_user.id)
#     return {"catches": catches}

# @router.get("/me/fishing-spots", response_model=dict)
# async def get_user_fishing_spots(
#     current_user = Depends(get_current_user),
#     db: Session = Depends(get_db)
# ):
#     """获取当前用户的钓点列表"""
#     spots = crud.get_user_fishing_spots(db, current_user.id)
#     return {"spots": spots}

# @router.get("/me/liked-catches", response_model=dict)
# async def get_liked_fish_catches(
#     current_user = Depends(get_current_user),
#     db: Session = Depends(get_db)
# ):
#     """获取当前用户点赞的鱼获列表"""
#     catches = crud.get_liked_fish_catches(db, current_user.id)
#     return {"catches": catches}

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    """获取用户信息"""
    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="用户未找到"
        )
    return user