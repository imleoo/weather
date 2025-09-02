#!/usr/bin/env python3
"""
日志查看工具
用于查看和分析前后端日志
"""

import os
import sys
import argparse
from datetime import datetime, timedelta
import re
import json
from typing import Dict, List, Optional

def color_text(text: str, color: str) -> str:
    """给文本添加颜色"""
    colors = {
        'red': '\033[91m',
        'green': '\033[92m',
        'yellow': '\033[93m',
        'blue': '\033[94m',
        'magenta': '\033[95m',
        'cyan': '\033[96m',
        'white': '\033[97m',
        'reset': '\033[0m'
    }
    return f"{colors.get(color, '')}{text}{colors['reset']}"

def parse_log_line(line: str) -> Optional[Dict]:
    """解析日志行"""
    # FastAPI/Uvicorn日志格式
    uvicorn_pattern = r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}) - (\w+) - ([^:]+): (.+)'
    match = re.match(uvicorn_pattern, line)
    if match:
        timestamp, level, logger, message = match.groups()
        return {
            'timestamp': timestamp,
            'level': level.lower(),
            'logger': logger,
            'message': message,
            'raw': line
        }
    
    # 自定义日志格式
    custom_pattern = r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}) - ([^:]+) - (\w+) - (.+)'
    match = re.match(custom_pattern, line)
    if match:
        timestamp, logger, level, message = match.groups()
        return {
            'timestamp': timestamp,
            'level': level.lower(),
            'logger': logger,
            'message': message,
            'raw': line
        }
    
    return None

def filter_logs(logs: List[Dict], level: str = None, logger: str = None, 
                keyword: str = None, start_time: str = None, end_time: str = None) -> List[Dict]:
    """过滤日志"""
    filtered = logs
    
    if level:
        filtered = [log for log in filtered if log['level'] == level.lower()]
    
    if logger:
        filtered = [log for log in filtered if logger.lower() in log['logger'].lower()]
    
    if keyword:
        filtered = [log for log in filtered if keyword.lower() in log['message'].lower()]
    
    if start_time:
        start_dt = datetime.fromisoformat(start_time)
        filtered = [log for log in filtered if datetime.fromisoformat(log['timestamp']) >= start_dt]
    
    if end_time:
        end_dt = datetime.fromisoformat(end_time)
        filtered = [log for log in filtered if datetime.fromisoformat(log['timestamp']) <= end_dt]
    
    return filtered

def display_logs(logs: List[Dict], tail: int = None, colorize: bool = True):
    """显示日志"""
    if tail:
        logs = logs[-tail:]
    
    for log in logs:
        level_color = {
            'debug': 'cyan',
            'info': 'green',
            'warning': 'yellow',
            'error': 'red',
            'critical': 'magenta'
        }.get(log['level'], 'white')
        
        timestamp = color_text(log['timestamp'], 'blue') if colorize else log['timestamp']
        level = color_text(log['level'].upper(), level_color) if colorize else log['level'].upper()
        logger = color_text(log['logger'], 'magenta') if colorize else log['logger']
        message = log['message']
        
        # 高亮JSON格式的消息
        if message.strip().startswith('{') and message.strip().endswith('}'):
            try:
                data = json.loads(message)
                if isinstance(data, dict) and 'type' in data:
                    if data['type'] == 'api_call':
                        status_color = 'green' if data.get('status_code', 0) < 400 else 'red'
                        status = color_text(str(data.get('status_code', '')), status_color) if colorize else str(data.get('status_code', ''))
                        message = f"API {data.get('method', '')} {data.get('endpoint', '')} - {status} ({data.get('response_time', 0)}ms)"
                    elif data['type'] == 'user_action':
                        message = f"User {data.get('user_id', '')} {data.get('action', '')}"
            except:
                pass
        
        print(f"{timestamp} {level} [{logger}] {message}")

def analyze_logs(logs: List[Dict]):
    """分析日志统计"""
    if not logs:
        print("没有日志可分析")
        return
    
    # 统计各级别日志数量
    level_counts = {}
    for log in logs:
        level = log['level']
        level_counts[level] = level_counts.get(level, 0) + 1
    
    print("\n" + "="*50)
    print("日志统计")
    print("="*50)
    
    for level, count in sorted(level_counts.items()):
        color = {
            'error': 'red',
            'warning': 'yellow',
            'info': 'green',
            'debug': 'cyan'
        }.get(level, 'white')
        print(f"{color_text(level.upper(), color)}: {count}")
    
    # 统计各日志器数量
    logger_counts = {}
    for log in logs:
        logger = log['logger']
        logger_counts[logger] = logger_counts.get(logger, 0) + 1
    
    print("\n日志器统计:")
    for logger, count in sorted(logger_counts.items(), key=lambda x: x[1], reverse=True)[:5]:
        print(f"  {logger}: {count}")
    
    # 错误日志分析
    error_logs = [log for log in logs if log['level'] == 'error']
    if error_logs:
        print(f"\n错误日志 ({len(error_logs)} 条):")
        for log in error_logs[-5:]:  # 显示最近5条错误
            print(f"  {log['timestamp']} - {log['message']}")
    
    # API调用分析
    api_logs = []
    for log in logs:
        if log['message'].strip().startswith('{'):
            try:
                data = json.loads(log['message'])
                if isinstance(data, dict) and data.get('type') == 'api_call':
                    api_logs.append(data)
            except:
                pass
    
    if api_logs:
        print(f"\nAPI调用统计 ({len(api_logs)} 次):")
        
        # 响应时间统计
        response_times = [log.get('response_time', 0) for log in api_logs]
        if response_times:
            avg_time = sum(response_times) / len(response_times)
            max_time = max(response_times)
            print(f"  平均响应时间: {avg_time:.2f}ms")
            print(f"  最大响应时间: {max_time:.2f}ms")
        
        # 状态码统计
        status_codes = {}
        for log in api_logs:
            code = log.get('status_code', 0)
            status_codes[code] = status_codes.get(code, 0) + 1
        
        print("  状态码分布:")
        for code, count in sorted(status_codes.items()):
            color = 'green' if code < 400 else 'red'
            print(f"    {color_text(str(code), color)}: {count}")

def main():
    parser = argparse.ArgumentParser(description='钓鱼天气应用日志查看工具')
    parser.add_argument('log_file', help='日志文件路径')
    parser.add_argument('-f', '--follow', action='store_true', help='实时跟踪日志')
    parser.add_argument('-n', '--tail', type=int, default=50, help='显示最后N行日志')
    parser.add_argument('-l', '--level', choices=['debug', 'info', 'warning', 'error', 'critical'], help='过滤日志级别')
    parser.add_argument('--logger', help='过滤日志器名称')
    parser.add_argument('-k', '--keyword', help='搜索关键词')
    parser.add_argument('--start', help='开始时间 (YYYY-MM-DD HH:MM:SS)')
    parser.add_argument('--end', help='结束时间 (YYYY-MM-DD HH:MM:SS)')
    parser.add_argument('--no-color', action='store_true', help='禁用彩色输出')
    parser.add_argument('-a', '--analyze', action='store_true', help='分析日志统计')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.log_file):
        print(f"错误: 日志文件不存在: {args.log_file}")
        sys.exit(1)
    
    if args.follow:
        # 实时跟踪模式
        print(f"实时跟踪日志文件: {args.log_file}")
        print("按 Ctrl+C 退出\n")
        
        with open(args.log_file, 'r', encoding='utf-8') as f:
            # 移动到文件末尾
            f.seek(0, 2)
            
            try:
                while True:
                    line = f.readline()
                    if line:
                        log = parse_log_line(line.strip())
                        if log:
                            display_logs([log], colorize=not args.no_color)
                    else:
                        import time
                        time.sleep(0.1)
            except KeyboardInterrupt:
                print("\n停止跟踪")
    else:
        # 读取日志文件
        try:
            with open(args.log_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except Exception as e:
            print(f"读取日志文件失败: {e}")
            sys.exit(1)
        
        # 解析日志
        logs = []
        for line in lines:
            log = parse_log_line(line.strip())
            if log:
                logs.append(log)
        
        # 过滤日志
        logs = filter_logs(
            logs,
            level=args.level,
            logger=args.logger,
            keyword=args.keyword,
            start_time=args.start,
            end_time=args.end
        )
        
        if args.analyze:
            analyze_logs(logs)
        else:
            display_logs(logs, tail=args.tail, colorize=not args.no_color)

if __name__ == "__main__":
    main()