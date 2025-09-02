#!/usr/bin/env python3
"""
数据库初始化脚本
用于创建数据库和表结构
"""

import os
import sys

# 添加当前目录到Python路径
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from config import settings
from models import Base
from database import engine

def create_database_if_not_exists():
    """创建数据库（如果不存在）"""
    # 创建不包含数据库名的连接URL
    base_url = f"mysql+mysqlconnector://{settings.DATABASE_USER}:{settings.DATABASE_PASSWORD}@{settings.DATABASE_HOST}:{settings.DATABASE_PORT}"
    
    try:
        # 连接到MySQL服务器（不指定数据库）
        temp_engine = create_engine(base_url)
        
        with temp_engine.connect() as connection:
            # 创建数据库
            connection.execute(text(f"CREATE DATABASE IF NOT EXISTS {settings.DATABASE_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"))
            print(f"数据库 {settings.DATABASE_NAME} 创建成功（或已存在）")
        
        temp_engine.dispose()
        
    except Exception as e:
        print(f"创建数据库失败: {e}")
        return False
    
    return True

def create_tables():
    """创建所有表"""
    try:
        # 创建所有表
        Base.metadata.create_all(bind=engine)
        print("所有表创建成功")
        return True
    except Exception as e:
        print(f"创建表失败: {e}")
        return False

def init_database():
    """初始化数据库"""
    print("开始初始化数据库...")
    print(f"数据库配置: {settings.DATABASE_HOST}:{settings.DATABASE_PORT}/{settings.DATABASE_NAME}")
    
    # 步骤1: 创建数据库
    if not create_database_if_not_exists():
        print("数据库初始化失败")
        return False
    
    # 步骤2: 创建表
    if not create_tables():
        print("数据库初始化失败")
        return False
    
    print("数据库初始化完成！")
    return True

if __name__ == "__main__":
    init_database()