"""
日志配置模块
统一管理前后端日志记录
"""

import logging
import logging.handlers
import os
from datetime import datetime
from typing import Optional

class ColoredFormatter(logging.Formatter):
    """彩色日志格式化器"""
    
    # 颜色代码
    COLORS = {
        'DEBUG': '\033[36m',    # 青色
        'INFO': '\033[32m',     # 绿色
        'WARNING': '\033[33m',  # 黄色
        'ERROR': '\033[31m',    # 红色
        'CRITICAL': '\033[35m', # 紫色
        'RESET': '\033[0m'      # 重置
    }
    
    def format(self, record):
        # 添加颜色
        if record.levelname in self.COLORS:
            record.levelname = f"{self.COLORS[record.levelname]}{record.levelname}{self.COLORS['RESET']}"
        return super().format(record)

def setup_backend_logging(
    name: str = "fishing_weather_backend",
    log_dir: str = "../logs",
    level: int = logging.INFO
) -> logging.Logger:
    """
    设置后端日志记录
    
    Args:
        name: 日志器名称
        log_dir: 日志目录
        level: 日志级别
    
    Returns:
        配置好的日志器
    """
    # 确保日志目录存在
    log_dir = os.path.abspath(log_dir)
    os.makedirs(log_dir, exist_ok=True)
    
    # 创建日志器
    logger = logging.getLogger(name)
    logger.setLevel(level)
    
    # 避免重复添加处理器
    if logger.handlers:
        return logger
    
    # 日志格式
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(filename)s:%(lineno)d - %(message)s'
    )
    
    # 控制台处理器（带颜色）
    console_handler = logging.StreamHandler()
    console_handler.setLevel(level)
    console_handler.setFormatter(ColoredFormatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    ))
    
    # 文件处理器（按天轮转）
    log_file = os.path.join(log_dir, f"{name}.log")
    file_handler = logging.handlers.TimedRotatingFileHandler(
        log_file,
        when='midnight',
        interval=1,
        backupCount=30,
        encoding='utf-8'
    )
    file_handler.setLevel(level)
    file_handler.setFormatter(formatter)
    
    # 错误日志单独记录
    error_file = os.path.join(log_dir, f"{name}_error.log")
    error_handler = logging.handlers.TimedRotatingFileHandler(
        error_file,
        when='midnight',
        interval=1,
        backupCount=30,
        encoding='utf-8'
    )
    error_handler.setLevel(logging.ERROR)
    error_handler.setFormatter(formatter)
    
    # 添加处理器
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
    logger.addHandler(error_handler)
    
    return logger

def log_api_call(
    logger: logging.Logger,
    method: str,
    endpoint: str,
    status_code: int,
    response_time: float,
    user_id: Optional[int] = None,
    ip_address: Optional[str] = None,
    error: Optional[str] = None
):
    """
    记录API调用日志
    
    Args:
        logger: 日志器
        method: HTTP方法
        endpoint: API端点
        status_code: 状态码
        response_time: 响应时间（秒）
        user_id: 用户ID
        ip_address: IP地址
        error: 错误信息
    """
    log_data = {
        "type": "api_call",
        "method": method,
        "endpoint": endpoint,
        "status_code": status_code,
        "response_time": round(response_time * 1000, 2),  # 转换为毫秒
        "timestamp": datetime.now().isoformat()
    }
    
    if user_id:
        log_data["user_id"] = user_id
    if ip_address:
        log_data["ip_address"] = ip_address
    if error:
        log_data["error"] = error
    
    if status_code >= 400:
        logger.error(f"API调用失败: {log_data}")
    else:
        logger.info(f"API调用成功: {log_data}")

def log_database_operation(
    logger: logging.Logger,
    operation: str,
    table: str,
    duration: float,
    row_count: Optional[int] = None,
    error: Optional[str] = None
):
    """
    记录数据库操作日志
    
    Args:
        logger: 日志器
        operation: 操作类型（SELECT, INSERT, UPDATE, DELETE）
        table: 表名
        duration: 执行时间（秒）
        row_count: 影响行数
        error: 错误信息
    """
    log_data = {
        "type": "database_operation",
        "operation": operation,
        "table": table,
        "duration": round(duration * 1000, 2),  # 转换为毫秒
        "timestamp": datetime.now().isoformat()
    }
    
    if row_count is not None:
        log_data["row_count"] = row_count
    if error:
        log_data["error"] = error
    
    if error:
        logger.error(f"数据库操作失败: {log_data}")
    elif duration > 1.0:  # 超过1秒的慢查询
        logger.warning(f"慢查询: {log_data}")
    else:
        logger.debug(f"数据库操作: {log_data}")

def log_user_action(
    logger: logging.Logger,
    user_id: int,
    action: str,
    target_type: Optional[str] = None,
    target_id: Optional[int] = None,
    details: Optional[dict] = None
):
    """
    记录用户操作日志
    
    Args:
        logger: 日志器
        user_id: 用户ID
        action: 操作类型
        target_type: 目标类型
        target_id: 目标ID
        details: 详细信息
    """
    log_data = {
        "type": "user_action",
        "user_id": user_id,
        "action": action,
        "timestamp": datetime.now().isoformat()
    }
    
    if target_type:
        log_data["target_type"] = target_type
    if target_id:
        log_data["target_id"] = target_id
    if details:
        log_data["details"] = details
    
    logger.info(f"用户操作: {log_data}")

# 创建默认日志器
backend_logger = setup_backend_logging()