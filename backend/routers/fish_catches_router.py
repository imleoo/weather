from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from database import get_db
from schemas import FishCatchCreate, FishCatchResponse, SuccessResponse
import crud

router = APIRouter()

# TODO: 需要从main.py导入get_current_user
# from main import get_current_user

@router.get("/", response_model=dict)
async def get_fish_catches(
    page: int = Query(1, ge=1, description="页码"),
    limit: int = Query(20, ge=1, le=100, description="每页数量"),
    db: Session = Depends(get_db)
):
    """获取鱼获分享列表"""
    catches = crud.get_fish_catches(db, page=page, limit=limit)
    return {
        "catches": [catch.__dict__ for catch in catches]
    }

# @router.post("/", response_model=FishCatchResponse)
# async def create_fish_catch(
#     fish_catch: FishCatchCreate,
#     current_user = Depends(get_current_user),
#     db: Session = Depends(get_db)
# ):
#     """创建鱼获分享"""
#     db_catch = crud.create_fish_catch(db, fish_catch, current_user.id)
#     return db_catch