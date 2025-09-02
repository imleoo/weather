"""
依赖项模块
避免循环导入
"""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from database import get_db
import crud

security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    """获取当前用户"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # 解码JWT token
        payload = jwt.decode(
            credentials.credentials, 
            "your-secret-key",  # 应该使用环境变量
            algorithms=["HS256"]
        )
        user_id: int = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    # 从数据库获取用户
    user = crud.get_user_by_id(db, user_id=user_id)
    if user is None:
        raise credentials_exception
    
    return user