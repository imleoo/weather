#!/bin/bash

# 钓鱼天气应用启停脚本
# 用于启动和停止前后端服务

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 日志目录
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

# 日志文件
BACKEND_LOG="$LOG_DIR/backend.log"
FRONTEND_LOG="$LOG_DIR/frontend.log"
COMBINED_LOG="$LOG_DIR/combined.log"

# PID文件
BACKEND_PID_FILE="$LOG_DIR/backend.pid"
FRONTEND_PID_FILE="$LOG_DIR/frontend.pid"

# 函数：打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] $message${NC}" | tee -a "$COMBINED_LOG"
}

# 函数：检查后端是否运行
is_backend_running() {
    if [ -f "$BACKEND_PID_FILE" ]; then
        local pid=$(cat "$BACKEND_PID_FILE")
        if ps -p $pid > /dev/null 2>&1; then
            return 0
        else
            rm -f "$BACKEND_PID_FILE"
        fi
    fi
    return 1
}

# 函数：检查前端是否运行
is_frontend_running() {
    if [ -f "$FRONTEND_PID_FILE" ]; then
        local pid=$(cat "$FRONTEND_PID_FILE")
        if ps -p $pid > /dev/null 2>&1; then
            return 0
        else
            rm -f "$FRONTEND_PID_FILE"
        fi
    fi
    return 1
}

# 函数：启动后端服务
start_backend() {
    if is_backend_running; then
        print_message $YELLOW "后端服务已在运行中"
        return 0
    fi
    
    print_message $BLUE "正在启动后端服务..."
    
    # 检查Python环境
    if ! command -v python3 &> /dev/null; then
        print_message $RED "错误: 未找到Python3，请先安装Python3"
        return 1
    fi
    
    # 检查虚拟环境
    if [ ! -d "backend/venv" ]; then
        print_message $BLUE "创建Python虚拟环境..."
        cd backend
        python3 -m venv venv
        if [ $? -ne 0 ]; then
            print_message $RED "创建虚拟环境失败"
            cd ..
            return 1
        fi
        cd ..
    fi
    
    # 激活虚拟环境并安装依赖
    cd backend
    source venv/bin/activate
    pip install -r requirements.txt >> "$BACKEND_LOG" 2>&1
    
    # 初始化数据库
    print_message $BLUE "初始化数据库..."
    python init_db.py >> "$BACKEND_LOG" 2>&1
    
    # 启动后端服务
    nohup python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload >> "$BACKEND_LOG" 2>&1 &
    local pid=$!
    echo $pid > "$BACKEND_PID_FILE"
    cd ..
    
    # 等待服务启动
    sleep 3
    
    if is_backend_running; then
        print_message $GREEN "后端服务启动成功 (PID: $pid)"
        print_message $GREEN "API地址: http://localhost:8000"
        print_message $GREEN "API文档: http://localhost:8000/docs"
    else
        print_message $RED "后端服务启动失败，请查看日志: $BACKEND_LOG"
        return 1
    fi
}

# 函数：启动前端服务
start_frontend() {
    if is_frontend_running; then
        print_message $YELLOW "前端服务已在运行中"
        return 0
    fi
    
    print_message $BLUE "正在启动前端服务..."
    
    # 检查Flutter环境
    if ! command -v flutter &> /dev/null; then
        print_message $RED "错误: 未找到Flutter，请先安装Flutter并配置环境变量"
        return 1
    fi
    
    # 获取依赖
    print_message $BLUE "获取Flutter依赖..."
    flutter pub get >> "$FRONTEND_LOG" 2>&1
    
    # 启动前端服务（开发模式）
    nohup flutter run --debug >> "$FRONTEND_LOG" 2>&1 &
    local pid=$!
    echo $pid > "$FRONTEND_PID_FILE"
    
    # 等待服务启动
    sleep 5
    
    if is_frontend_running; then
        print_message $GREEN "前端服务启动成功 (PID: $pid)"
    else
        print_message $RED "前端服务启动失败，请查看日志: $FRONTEND_LOG"
        return 1
    fi
}

# 函数：停止后端服务
stop_backend() {
    if ! is_backend_running; then
        print_message $YELLOW "后端服务未运行"
        return 0
    fi
    
    local pid=$(cat "$BACKEND_PID_FILE")
    print_message $BLUE "正在停止后端服务 (PID: $pid)..."
    
    kill $pid
    sleep 2
    
    if ps -p $pid > /dev/null 2>&1; then
        print_message $YELLOW "强制停止后端服务..."
        kill -9 $pid
    fi
    
    rm -f "$BACKEND_PID_FILE"
    print_message $GREEN "后端服务已停止"
}

# 函数：停止前端服务
stop_frontend() {
    if ! is_frontend_running; then
        print_message $YELLOW "前端服务未运行"
        return 0
    fi
    
    local pid=$(cat "$FRONTEND_PID_FILE")
    print_message $BLUE "正在停止前端服务 (PID: $pid)..."
    
    kill $pid
    sleep 2
    
    if ps -p $pid > /dev/null 2>&1; then
        print_message $YELLOW "强制停止前端服务..."
        kill -9 $pid
    fi
    
    rm -f "$FRONTEND_PID_FILE"
    print_message $GREEN "前端服务已停止"
}

# 函数：显示状态
show_status() {
    print_message $BLUE "=== 服务状态 ==="
    
    if is_backend_running; then
        local pid=$(cat "$BACKEND_PID_FILE")
        print_message $GREEN "后端服务: 运行中 (PID: $pid)"
    else
        print_message $RED "后端服务: 未运行"
    fi
    
    if is_frontend_running; then
        local pid=$(cat "$FRONTEND_PID_FILE")
        print_message $GREEN "前端服务: 运行中 (PID: $pid)"
    else
        print_message $RED "前端服务: 未运行"
    fi
    
    echo
    print_message $BLUE "=== 日志文件 ==="
    print_message $NC "后端日志: $BACKEND_LOG"
    print_message $NC "前端日志: $FRONTEND_LOG"
    print_message $NC "综合日志: $COMBINED_LOG"
}

# 函数：查看日志
show_logs() {
    local service=$1
    
    case $service in
        "backend")
            if [ -f "$BACKEND_LOG" ]; then
                tail -f "$BACKEND_LOG"
            else
                print_message $RED "后端日志文件不存在"
            fi
            ;;
        "frontend")
            if [ -f "$FRONTEND_LOG" ]; then
                tail -f "$FRONTEND_LOG"
            else
                print_message $RED "前端日志文件不存在"
            fi
            ;;
        "combined")
            if [ -f "$COMBINED_LOG" ]; then
                tail -f "$COMBINED_LOG"
            else
                print_message $RED "综合日志文件不存在"
            fi
            ;;
        *)
            print_message $RED "用法: $0 logs [backend|frontend|combined]"
            ;;
    esac
}

# 函数：显示帮助信息
show_help() {
    echo "钓鱼天气应用启停脚本"
    echo
    echo "用法: $0 [命令] [选项]"
    echo
    echo "命令:"
    echo "  start [backend|frontend|all]  启动服务"
    echo "  stop [backend|frontend|all]   停止服务"
    echo "  restart [backend|frontend|all] 重启服务"
    echo "  status                         查看服务状态"
    echo "  logs [backend|frontend|combined] 查看日志"
    echo "  help                           显示帮助信息"
    echo
    echo "示例:"
    echo "  $0 start all                   启动所有服务"
    echo "  $0 stop backend                停止后端服务"
    echo "  $0 logs backend                查看后端日志"
}

# 主程序
main() {
    case "${1:-help}" in
        "start")
            case "${2:-all}" in
                "backend")
                    start_backend
                    ;;
                "frontend")
                    start_frontend
                    ;;
                "all")
                    start_backend
                    start_frontend
                    ;;
                *)
                    print_message $RED "用法: $0 start [backend|frontend|all]"
                    exit 1
                    ;;
            esac
            ;;
        "stop")
            case "${2:-all}" in
                "backend")
                    stop_backend
                    ;;
                "frontend")
                    stop_frontend
                    ;;
                "all")
                    stop_frontend
                    stop_backend
                    ;;
                *)
                    print_message $RED "用法: $0 stop [backend|frontend|all]"
                    exit 1
                    ;;
            esac
            ;;
        "restart")
            case "${2:-all}" in
                "backend")
                    stop_backend
                    sleep 2
                    start_backend
                    ;;
                "frontend")
                    stop_frontend
                    sleep 2
                    start_frontend
                    ;;
                "all")
                    stop_frontend
                    stop_backend
                    sleep 2
                    start_backend
                    start_frontend
                    ;;
                *)
                    print_message $RED "用法: $0 restart [backend|frontend|all]"
                    exit 1
                    ;;
            esac
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs "$2"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_message $RED "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 检查参数
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# 运行主程序
main "$@"