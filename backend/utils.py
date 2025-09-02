import os
import uuid
from typing import Optional
from fastapi import UploadFile, HTTPException
from PIL import Image
from config import settings

def save_uploaded_file(file: UploadFile, upload_dir: str = None) -> str:
    """保存上传的文件并返回文件URL"""
    if upload_dir is None:
        upload_dir = settings.UPLOAD_DIR
    
    # 确保上传目录存在
    os.makedirs(upload_dir, exist_ok=True)
    
    # 验证文件类型
    allowed_types = {"image/jpeg", "image/png", "image/jpg", "image/gif"}
    if file.content_type not in allowed_types:
        raise HTTPException(status_code=400, detail="不支持的文件类型")
    
    # 验证文件大小
    if file.size and file.size > settings.MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="文件太大")
    
    # 生成唯一文件名
    file_extension = file.filename.split(".")[-1] if file.filename else "jpg"
    file_name = f"{uuid.uuid4()}.{file_extension}"
    file_path = os.path.join(upload_dir, file_name)
    
    # 保存文件
    try:
        with open(file_path, "wb") as buffer:
            content = file.file.read()
            buffer.write(content)
        
        # 压缩图片
        compress_image(file_path)
        
        # 返回相对URL路径
        return f"/uploads/{file_name}"
    
    except Exception as e:
        # 如果保存失败，删除可能存在的文件
        if os.path.exists(file_path):
            os.remove(file_path)
        raise HTTPException(status_code=500, detail=f"文件保存失败: {str(e)}")

def compress_image(file_path: str, quality: int = 85, max_width: int = 1200):
    """压缩图片"""
    try:
        with Image.open(file_path) as img:
            # 转换为RGB（如果是RGBA）
            if img.mode in ("RGBA", "P"):
                img = img.convert("RGB")
            
            # 计算新尺寸
            width, height = img.size
            if width > max_width:
                ratio = max_width / width
                new_width = max_width
                new_height = int(height * ratio)
                img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
            
            # 保存压缩后的图片
            img.save(file_path, "JPEG", quality=quality, optimize=True)
    
    except Exception as e:
        print(f"图片压缩失败: {str(e)}")

def delete_file(file_path: str) -> bool:
    """删除文件"""
    try:
        if os.path.exists(file_path):
            os.remove(file_path)
            return True
        return False
    except Exception:
        return False

def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """计算两点之间的距离（km）"""
    from math import radians, sin, cos, sqrt, atan2
    
    # 地球半径（km）
    R = 6371.0
    
    # 转换为弧度
    lat1_rad = radians(lat1)
    lon1_rad = radians(lon1)
    lat2_rad = radians(lat2)
    lon2_rad = radians(lon2)
    
    # 计算差值
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad
    
    # Haversine公式
    a = sin(dlat / 2)**2 + cos(lat1_rad) * cos(lat2_rad) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    distance = R * c
    
    return round(distance, 2)