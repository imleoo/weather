from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from database import get_db
from schemas import FishingSpotCreate, FishingSpotResponse, SuccessResponse
import crud
from dependencies import get_current_user

router = APIRouter()

@router.post("/", response_model=FishingSpotResponse)
async def create_fishing_spot(
    spot: FishingSpotCreate,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """创建钓点"""
    db_spot = crud.create_fishing_spot(db, spot, current_user.id)
    return db_spot

@router.get("/nearby", response_model=dict)
async def get_nearby_fishing_spots(
    lat: float = Query(..., description="纬度"),
    lng: float = Query(..., description="经度"),
    radius: float = Query(10.0, description="搜索半径（公里）"),
    db: Session = Depends(get_db)
):
    """获取附近的钓点"""
    spots = crud.get_nearby_fishing_spots(db, lat, lng, radius)
    return {
        "spots": [spot.__dict__ for spot in spots]
    }