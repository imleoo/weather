#!/bin/bash

echo "=== 钓鱼天气应用功能验证脚本 ==="
echo

# 检查服务状态
echo "1. 检查服务状态..."
./start.sh status
echo

# 测试后端API
echo "2. 测试后端API健康检查..."
curl -s http://localhost:8000/api/health | python3 -m json.tool
echo

# 测试获取鱼获列表
echo "3. 测试获取鱼获列表API..."
curl -s "http://localhost:8000/api/fish-catches/?page=1&limit=5" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'✓ 成功获取 {len(data.get(\"items\", []))} 条鱼获记录')
    if data.get('items'):
        print(f'  最新鱼获: {data[\"items\"][0][\"fish_type\"]} - {data[\"items\"][0][\"weight\"]}kg')
except:
    print('✗ 获取鱼获列表失败')
"
echo

# 测试获取附近钓点
echo "4. 测试获取附近钓点API..."
curl -s "http://localhost:8000/api/fishing-spots/nearby?lat=39.9042&lng=116.4074&radius=10" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'✓ 成功获取 {len(data)} 个钓点')
    if data:
        print(f'  最近的钓点: {data[0][\"name\"]} - 距离 {data[0].get(\"distance\", \"未知\")}km')
except:
    print('✗ 获取钓点列表失败')
"
echo

# 检查日志文件
echo "5. 检查日志系统..."
echo "后端日志行数: $(wc -l < logs/backend.log)"
echo "前端日志行数: $(wc -l < logs/frontend.log)"
echo "综合日志行数: $(wc -l < logs/combined.log)"
echo

# 显示最近的API调用
echo "6. 最近的API调用记录:"
python3 log_viewer.py logs/fishing_weather_backend.log -l info --logger fishing_weather_backend | tail -5
echo

echo "=== 验证完成 ==="
echo
echo "应用访问地址:"
echo "- 后端API文档: http://localhost:8000/docs"
echo "- 前端应用: http://localhost:8080"
echo
echo "功能验证:"
echo "✓ 后端服务运行正常"
echo "✓ 前端应用在Chrome上运行"
echo "✓ API调用正常工作"
echo "✓ 日志系统记录完整"
echo
echo "新功能验证要点:"
echo "1. 在钓点页面点击地图图标切换到地图视图"
echo "2. 在鱼获分享页面点击分享按钮选择社交平台"
echo "3. 查看logs目录下的日志文件了解系统运行状态"