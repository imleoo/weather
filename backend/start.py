#!/usr/bin/env python3
"""
启动脚本
用于启动钓鱼天气后端服务
"""

import os
import sys
import subprocess

# 添加当前目录到Python路径
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from config import settings

def install_requirements():
    """安装依赖包"""
    print("正在安装依赖包...")
    try:
        subprocess.run([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"], check=True)
        print("依赖包安装完成")
        return True
    except subprocess.CalledProcessError as e:
        print(f"依赖包安装失败: {e}")
        return False

def init_database():
    """初始化数据库"""
    print("正在初始化数据库...")
    try:
        from init_db import init_database
        return init_database()
    except Exception as e:
        print(f"数据库初始化失败: {e}")
        return False

def start_server():
    """启动服务器"""
    print(f"正在启动服务器... {settings.HOST}:{settings.PORT}")
    try:
        import uvicorn
        uvicorn.run(
            "main:app",
            host=settings.HOST,
            port=settings.PORT,
            reload=True,
            log_level="info"
        )
    except Exception as e:
        print(f"服务器启动失败: {e}")
        return False

def main():
    """主函数"""
    print("=" * 50)
    print("钓鱼天气后端服务启动程序")
    print("=" * 50)
    
    # 检查是否需要安装依赖
    if len(sys.argv) > 1 and sys.argv[1] == "--install":
        if not install_requirements():
            return False
    
    # 初始化数据库
    if not init_database():
        return False
    
    # 启动服务器
    print("准备启动服务器...")
    start_server()

if __name__ == "__main__":
    main()