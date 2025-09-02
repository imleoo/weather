from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session

from database import get_db
from schemas import UploadResponse
from utils import save_uploaded_file

router = APIRouter()

# TODO: 需要从main.py导入get_current_user
# from main import get_current_user

# @router.post("/image", response_model=UploadResponse)
# async def upload_image(
#     image: UploadFile = File(...),
#     current_user = Depends(get_current_user),
#     db: Session = Depends(get_db)
# ):
#     """上传图片"""
#     try:
#         # 保存图片文件
#         image_url = save_uploaded_file(image)
        
#         return UploadResponse(
#             image_url=image_url,
#             message="图片上传成功"
#         )
    
#     except HTTPException:
#         raise
#     except Exception as e:
#         raise HTTPException(
#             status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
#             detail=f"图片上传失败: {str(e)}"
#         )