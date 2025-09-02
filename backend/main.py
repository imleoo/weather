from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import timedelta
import uvicorn
import time

from database import engine, get_db
from models import Base
from auth import verify_token
from config import settings
from routers import auth_router, fishing_spots_router, fish_catches_router, upload_router, users_router
from logging_config import backend_logger, log_api_call
import os

# 创建数据库表
Base.metadata.create_all(bind=engine)
backend_logger.info("数据库表创建成功")

# 创建上传目录
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
backend_logger.info(f"上传目录创建成功: {settings.UPLOAD_DIR}")

# 创建FastAPI应用
app = FastAPI(
    title="钓鱼天气后端API",
    description="钓鱼天气应用的后端API服务",
    version="1.0.0",
)

# 应用启动事件
@app.on_event("startup")
async def startup_event():
    backend_logger.info("钓鱼天气后端服务启动")
    backend_logger.info(f"服务地址: {settings.HOST}:{settings.PORT}")
    backend_logger.info(f"数据库连接: {settings.DATABASE_URL}")
    backend_logger.info(f"上传目录: {settings.UPLOAD_DIR}")

# 应用关闭事件
@app.on_event("shutdown")
async def shutdown_event():
    backend_logger.info("钓鱼天气后端服务关闭")

# CORS配置 - 必须在其他中间件之前添加
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境应该限制为特定域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],  # 暴露所有响应头
)

# 请求日志中间件
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    
    # 获取客户端IP
    client_host = request.client.host if request.client else "unknown"
    
    # 记录请求详情
    backend_logger.info(f"收到请求: {request.method} {request.url.path}")
    backend_logger.info(f"来源IP: {client_host}")
    
    # 获取并记录认证信息
    user_id = None
    auth_header = request.headers.get("authorization")
    if auth_header:
        backend_logger.info(f"Authorization头: {auth_header[:50]}...")  # 只记录前50个字符
        if auth_header.startswith("Bearer "):
            try:
                token = auth_header.split(" ")[1]
                backend_logger.info(f"正在验证Token: {token[:20]}...")
                token_data = verify_token(token)
                user_id = token_data.get("user_id")
                backend_logger.info(f"Token验证成功，用户ID: {user_id}")
            except Exception as e:
                backend_logger.error(f"Token验证失败: {str(e)}")
    else:
        backend_logger.info("请求没有Authorization头")
    
    # 处理请求
    try:
        response = await call_next(request)
    except Exception as e:
        backend_logger.error(f"处理请求时出错: {str(e)}")
        raise
    
    # 计算响应时间
    process_time = time.time() - start_time
    
    # 记录响应状态
    backend_logger.info(f"响应状态: {response.status_code}")
    
    # 记录API调用日志
    log_api_call(
        logger=backend_logger,
        method=request.method,
        endpoint=str(request.url.path),
        status_code=response.status_code,
        response_time=process_time,
        user_id=user_id,
        ip_address=client_host
    )
    
    return response

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