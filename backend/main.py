from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import timedelta
import uvicorn

from database import engine, get_db
from models import Base
from auth import verify_token
from config import settings
from routers import auth_router, fishing_spots_router, fish_catches_router, upload_router, users_router
import os

# 创建数据库表
Base.metadata.create_all(bind=engine)

# 创建上传目录
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)

# 创建FastAPI应用
app = FastAPI(
    title="钓鱼天气后端API",
    description="钓鱼天气应用的后端API服务",
    version="1.0.0",
)

# CORS配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境应该限制为特定域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 静态文件服务（用于图片访问）
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")

# 安全配置
security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    """获取当前用户（依赖注入）"""
    token = credentials.credentials
    token_data = verify_token(token)
    
    from crud import get_user_by_email
    user = get_user_by_email(db, email=token_data["email"])
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user

# 注册路由
app.include_router(auth_router.router, prefix="/api/auth", tags=["认证"])
app.include_router(fishing_spots_router.router, prefix="/api/fishing-spots", tags=["钓点"])
app.include_router(fish_catches_router.router, prefix="/api/fish-catches", tags=["鱼获"])
app.include_router(upload_router.router, prefix="/api/upload", tags=["文件上传"])
app.include_router(users_router.router, prefix="/api/users", tags=["用户"])

@app.get("/")
async def root():
    """根路径"""
    return {"message": "钓鱼天气后端API服务正在运行", "version": "1.0.0"}

@app.get("/api/health")
async def health_check():
    """健康检查"""
    return {"status": "healthy", "message": "服务运行正常"}

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=True,  # 开发环境自动重载
    )