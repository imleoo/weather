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
from config import settings
from logging_config import backend_logger

security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    """获取当前用户"""
    backend_logger.info(f"===== 开始用户认证 =====")
    backend_logger.info(f"收到的Token: {credentials.credentials[:30]}...")
    
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # 解码JWT token
        backend_logger.info(f"正在解码JWT Token...")
        payload = jwt.decode(
            credentials.credentials, 
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        
        # 打印payload内容以调试
        backend_logger.info(f"JWT Payload: {payload}")
        
        # 尝试从不同字段获取email
        email: str = payload.get("email") or payload.get("sub")
        backend_logger.info(f"解析出的email: {email}")
        
        if email is None:
            backend_logger.error("Token中没有找到email或sub字段")
            backend_logger.error(f"Payload内容: {payload}")
            raise credentials_exception
            
    except jwt.ExpiredSignatureError:
        backend_logger.error("Token已过期")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except JWTError as e:
        backend_logger.error(f"JWT解码失败: {str(e)}")
        raise credentials_exception
    except Exception as e:
        backend_logger.error(f"认证过程中发生未知错误: {str(e)}")
        raise credentials_exception
    
    # 从数据库获取用户
    backend_logger.info(f"正在从数据库查询用户: {email}")
    user = crud.get_user_by_email(db, email=email)
    if user is None:
        backend_logger.error(f"数据库中未找到用户: {email}")
        raise credentials_exception
    
    backend_logger.info(f"用户认证成功: {email} (ID: {user.id})")
    backend_logger.info(f"===== 认证完成 =====")
    return user