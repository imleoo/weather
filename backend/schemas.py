from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# 用户相关的Pydantic模型
class UserBase(BaseModel):
    email: EmailStr
    nickname: str
    bio: Optional[str] = ""

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    nickname: Optional[str] = None
    bio: Optional[str] = None

class UserResponse(UserBase):
    id: int
    avatar_url: Optional[str] = None
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class PasswordChange(BaseModel):
    old_password: str
    new_password: str

# 钓点相关的Pydantic模型
class FishingSpotBase(BaseModel):
    name: str
    description: Optional[str] = ""
    latitude: float
    longitude: float

class FishingSpotCreate(FishingSpotBase):
    pass

class FishingSpotResponse(FishingSpotBase):
    id: int
    user_id: int
    user_name: str
    is_public: bool
    distance: Optional[float] = None  # 距离当前位置的距离
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# 鱼获相关的Pydantic模型
class FishCatchBase(BaseModel):
    fish_type: str
    weight: float
    description: Optional[str] = ""
    latitude: float
    longitude: float
    location_name: str

class FishCatchCreate(FishCatchBase):
    image_url: Optional[str] = None

class FishCatchResponse(FishCatchBase):
    id: int
    image_url: Optional[str] = None
    user_id: int
    user_name: str
    is_public: bool
    likes: int = 0
    comments: int = 0
    is_liked: bool = False
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# 点赞相关的Pydantic模型
class LikeResponse(BaseModel):
    id: int
    user_id: int
    fish_catch_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# 评论相关的Pydantic模型
class CommentBase(BaseModel):
    content: str

class CommentCreate(CommentBase):
    fish_catch_id: int
    parent_id: Optional[int] = None

class CommentResponse(CommentBase):
    id: int
    user_id: int
    author_name: str
    fish_catch_id: int
    parent_id: Optional[int] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# Token相关的Pydantic模型
class Token(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse

class TokenData(BaseModel):
    email: Optional[str] = None

# 通用响应模型
class SuccessResponse(BaseModel):
    message: str
    data: Optional[dict] = None

class ErrorResponse(BaseModel):
    message: str
    detail: Optional[str] = None

# 分页响应模型
class PaginatedResponse(BaseModel):
    items: List[dict]
    total: int
    page: int
    limit: int
    has_next: bool
    has_prev: bool

# 文件上传响应
class UploadResponse(BaseModel):
    image_url: str
    message: str