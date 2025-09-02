from sqlalchemy.orm import Session
from sqlalchemy import and_, func, desc, asc
from typing import List, Optional
from models import User, FishingSpot, FishCatch, Like, Comment
from schemas import UserCreate, UserUpdate, FishingSpotCreate, FishCatchCreate, CommentCreate
from auth import get_password_hash, verify_password
from utils import calculate_distance

# 用户相关CRUD操作
def get_user(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def create_user(db: Session, user: UserCreate):
    hashed_password = get_password_hash(user.password)
    db_user = User(
        email=user.email,
        nickname=user.nickname,
        bio=user.bio,
        hashed_password=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def update_user(db: Session, user_id: int, user_update: UserUpdate):
    db_user = db.query(User).filter(User.id == user_id).first()
    if db_user:
        update_data = user_update.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_user, key, value)
        db.commit()
        db.refresh(db_user)
    return db_user

def authenticate_user(db: Session, email: str, password: str):
    user = get_user_by_email(db, email)
    if not user or not verify_password(password, user.hashed_password):
        return False
    return user

def change_password(db: Session, user_id: int, old_password: str, new_password: str):
    user = db.query(User).filter(User.id == user_id).first()
    if not user or not verify_password(old_password, user.hashed_password):
        return False
    
    user.hashed_password = get_password_hash(new_password)
    db.commit()
    return True

# 钓点相关CRUD操作
def create_fishing_spot(db: Session, spot: FishingSpotCreate, user_id: int):
    db_spot = FishingSpot(**spot.dict(), user_id=user_id)
    db.add(db_spot)
    db.commit()
    db.refresh(db_spot)
    return db_spot

def get_fishing_spot(db: Session, spot_id: int):
    return db.query(FishingSpot).filter(FishingSpot.id == spot_id).first()

def get_nearby_fishing_spots(db: Session, latitude: float, longitude: float, radius: float = 10.0, limit: int = 50):
    """获取附近的钓点"""
    spots = db.query(FishingSpot, User.nickname).join(
        User, FishingSpot.user_id == User.id
    ).filter(
        FishingSpot.is_public == True
    ).order_by(desc(FishingSpot.created_at)).limit(limit).all()
    
    # 计算距离并过滤
    nearby_spots = []
    for spot, nickname in spots:
        distance = calculate_distance(latitude, longitude, spot.latitude, spot.longitude)
        if distance <= radius:
            spot_dict = {
                "id": spot.id,
                "name": spot.name,
                "description": spot.description,
                "latitude": spot.latitude,
                "longitude": spot.longitude,
                "user_id": spot.user_id,
                "user_name": nickname,
                "is_public": spot.is_public,
                "distance": distance,
                "created_at": spot.created_at,
                "updated_at": spot.updated_at,
            }
            nearby_spots.append(spot_dict)
    
    # 按距离排序
    nearby_spots.sort(key=lambda x: x["distance"])
    return nearby_spots

def get_user_fishing_spots(db: Session, user_id: int, page: int = 1, limit: int = 20):
    """获取用户的钓点列表"""
    offset = (page - 1) * limit
    spots = db.query(FishingSpot, User.nickname).join(
        User, FishingSpot.user_id == User.id
    ).filter(
        FishingSpot.user_id == user_id
    ).offset(offset).limit(limit).all()
    
    return [
        {
            "id": spot.id,
            "name": spot.name,
            "description": spot.description,
            "latitude": spot.latitude,
            "longitude": spot.longitude,
            "user_id": spot.user_id,
            "user_name": nickname,
            "is_public": spot.is_public,
            "created_at": spot.created_at,
            "updated_at": spot.updated_at,
        }
        for spot, nickname in spots
    ]

def delete_fishing_spot(db: Session, spot_id: int, user_id: int):
    """删除钓点"""
    spot = db.query(FishingSpot).filter(
        and_(FishingSpot.id == spot_id, FishingSpot.user_id == user_id)
    ).first()
    if spot:
        db.delete(spot)
        db.commit()
        return True
    return False

# 鱼获相关CRUD操作
def create_fish_catch(db: Session, catch: FishCatchCreate, user_id: int):
    db_catch = FishCatch(**catch.dict(), user_id=user_id)
    db.add(db_catch)
    db.commit()
    db.refresh(db_catch)
    return db_catch

def get_fish_catch(db: Session, catch_id: int):
    return db.query(FishCatch).filter(FishCatch.id == catch_id).first()

def get_fish_catches(db: Session, page: int = 1, limit: int = 20, current_user_id: Optional[int] = None):
    """获取鱼获列表"""
    offset = (page - 1) * limit
    
    # 基础查询
    query = db.query(
        FishCatch,
        User.nickname.label("user_name"),
        func.count(Like.id).label("likes_count"),
        func.count(Comment.id).label("comments_count")
    ).join(
        User, FishCatch.user_id == User.id
    ).outerjoin(
        Like, FishCatch.id == Like.fish_catch_id
    ).outerjoin(
        Comment, FishCatch.id == Comment.fish_catch_id
    ).filter(
        FishCatch.is_public == True
    ).group_by(FishCatch.id).order_by(desc(FishCatch.created_at))
    
    # 分页
    catches = query.offset(offset).limit(limit).all()
    
    result = []
    for catch, user_name, likes_count, comments_count in catches:
        # 检查当前用户是否点赞了这条记录
        is_liked = False
        if current_user_id:
            like_exists = db.query(Like).filter(
                and_(Like.fish_catch_id == catch.id, Like.user_id == current_user_id)
            ).first()
            is_liked = like_exists is not None
        
        result.append({
            "id": catch.id,
            "fish_type": catch.fish_type,
            "weight": catch.weight,
            "description": catch.description,
            "latitude": catch.latitude,
            "longitude": catch.longitude,
            "location_name": catch.location_name,
            "image_url": catch.image_url,
            "user_id": catch.user_id,
            "user_name": user_name,
            "is_public": catch.is_public,
            "likes": likes_count or 0,
            "comments": comments_count or 0,
            "is_liked": is_liked,
            "created_at": catch.created_at,
            "updated_at": catch.updated_at,
        })
    
    return result

def get_user_fish_catches(db: Session, user_id: int, page: int = 1, limit: int = 20):
    """获取用户的鱼获列表"""
    offset = (page - 1) * limit
    
    query = db.query(
        FishCatch,
        User.nickname.label("user_name"),
        func.count(Like.id).label("likes_count"),
        func.count(Comment.id).label("comments_count")
    ).join(
        User, FishCatch.user_id == User.id
    ).outerjoin(
        Like, FishCatch.id == Like.fish_catch_id
    ).outerjoin(
        Comment, FishCatch.id == Comment.fish_catch_id
    ).filter(
        FishCatch.user_id == user_id
    ).group_by(FishCatch.id).order_by(desc(FishCatch.created_at))
    
    catches = query.offset(offset).limit(limit).all()
    
    return [
        {
            "id": catch.id,
            "fish_type": catch.fish_type,
            "weight": catch.weight,
            "description": catch.description,
            "latitude": catch.latitude,
            "longitude": catch.longitude,
            "location_name": catch.location_name,
            "image_url": catch.image_url,
            "user_id": catch.user_id,
            "user_name": user_name,
            "is_public": catch.is_public,
            "likes": likes_count or 0,
            "comments": comments_count or 0,
            "is_liked": False,
            "created_at": catch.created_at,
            "updated_at": catch.updated_at,
        }
        for catch, user_name, likes_count, comments_count in catches
    ]

def delete_fish_catch(db: Session, catch_id: int, user_id: int):
    """删除鱼获"""
    catch = db.query(FishCatch).filter(
        and_(FishCatch.id == catch_id, FishCatch.user_id == user_id)
    ).first()
    if catch:
        db.delete(catch)
        db.commit()
        return True
    return False

# 点赞相关CRUD操作
def like_fish_catch(db: Session, catch_id: int, user_id: int):
    """点赞鱼获"""
    # 检查是否已经点赞
    existing_like = db.query(Like).filter(
        and_(Like.fish_catch_id == catch_id, Like.user_id == user_id)
    ).first()
    
    if existing_like:
        return False  # 已经点赞了
    
    # 添加点赞
    like = Like(fish_catch_id=catch_id, user_id=user_id)
    db.add(like)
    db.commit()
    return True

def unlike_fish_catch(db: Session, catch_id: int, user_id: int):
    """取消点赞"""
    like = db.query(Like).filter(
        and_(Like.fish_catch_id == catch_id, Like.user_id == user_id)
    ).first()
    
    if like:
        db.delete(like)
        db.commit()
        return True
    return False

def get_user_liked_catches(db: Session, user_id: int, page: int = 1, limit: int = 20):
    """获取用户点赞的鱼获"""
    offset = (page - 1) * limit
    
    query = db.query(
        FishCatch,
        User.nickname.label("user_name"),
        func.count(Like.id).label("likes_count"),
        func.count(Comment.id).label("comments_count")
    ).join(
        Like, FishCatch.id == Like.fish_catch_id
    ).join(
        User, FishCatch.user_id == User.id
    ).outerjoin(
        Comment, FishCatch.id == Comment.fish_catch_id
    ).filter(
        Like.user_id == user_id
    ).group_by(FishCatch.id).order_by(desc(Like.created_at))
    
    catches = query.offset(offset).limit(limit).all()
    
    return [
        {
            "id": catch.id,
            "fish_type": catch.fish_type,
            "weight": catch.weight,
            "description": catch.description,
            "latitude": catch.latitude,
            "longitude": catch.longitude,
            "location_name": catch.location_name,
            "image_url": catch.image_url,
            "user_id": catch.user_id,
            "user_name": user_name,
            "is_public": catch.is_public,
            "likes": likes_count or 0,
            "comments": comments_count or 0,
            "is_liked": True,
            "created_at": catch.created_at,
            "updated_at": catch.updated_at,
        }
        for catch, user_name, likes_count, comments_count in catches
    ]

# 评论相关CRUD操作
def create_comment(db: Session, comment: CommentCreate, user_id: int):
    """创建评论"""
    db_comment = Comment(
        content=comment.content,
        fish_catch_id=comment.fish_catch_id,
        user_id=user_id,
        parent_id=comment.parent_id
    )
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)
    return db_comment

def get_fish_catch_comments(db: Session, catch_id: int):
    """获取鱼获的评论"""
    comments = db.query(Comment, User.nickname).join(
        User, Comment.user_id == User.id
    ).filter(
        Comment.fish_catch_id == catch_id
    ).order_by(asc(Comment.created_at)).all()
    
    return [
        {
            "id": comment.id,
            "content": comment.content,
            "user_id": comment.user_id,
            "author_name": nickname,
            "fish_catch_id": comment.fish_catch_id,
            "parent_id": comment.parent_id,
            "created_at": comment.created_at,
            "updated_at": comment.updated_at,
        }
        for comment, nickname in comments
    ]