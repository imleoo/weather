# 钓鱼天气后端API

这是钓鱼天气应用的后端API服务，使用FastAPI框架开发，支持用户管理、钓点分享、鱼获分享等功能。

## 功能特性

- **用户认证**: 注册、登录、JWT令牌认证
- **钓点管理**: 创建、查看、分享钓点，按距离搜索附近钓点
- **鱼获分享**: 发布鱼获照片和信息，社区互动
- **社交功能**: 点赞、评论、用户间交流
- **文件上传**: 图片上传和压缩处理
- **位置服务**: 基于GPS的地理位置功能

## 技术栈

- **Python 3.8+**
- **FastAPI**: 现代化的Web API框架
- **SQLAlchemy**: ORM数据库操作
- **MySQL**: 关系型数据库
- **JWT**: 用户认证
- **Pillow**: 图片处理
- **Uvicorn**: ASGI服务器

## 快速开始

### 1. 环境准备

确保已安装Python 3.8+和MySQL数据库。

### 2. 安装依赖

```bash
cd backend
python -m pip install -r requirements.txt
```

### 3. 配置数据库

编辑 `.env` 文件，配置数据库连接信息：

```
DATABASE_HOST=192.168.28.37
DATABASE_PORT=3306
DATABASE_USER=root
DATABASE_PASSWORD=mysql_wjZTK5
DATABASE_NAME=FishingWeather
```

### 4. 启动服务

```bash
python start.py --install  # 首次运行，会自动安装依赖和初始化数据库
# 或者
python start.py  # 直接启动（假设已安装依赖）
```

服务将在 http://0.0.0.0:8000 启动

### 5. API文档

启动后访问：
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API端点

### 认证相关
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `GET /api/auth/me` - 获取当前用户信息
- `PUT /api/auth/profile` - 更新用户资料
- `PUT /api/auth/password` - 修改密码

### 钓点相关
- `POST /api/fishing-spots` - 创建钓点
- `GET /api/fishing-spots/nearby` - 获取附近钓点
- `GET /api/fishing-spots/{id}` - 获取钓点详情
- `DELETE /api/fishing-spots/{id}` - 删除钓点

### 鱼获相关
- `POST /api/fish-catches` - 分享鱼获
- `GET /api/fish-catches` - 获取鱼获列表
- `GET /api/fish-catches/{id}` - 获取鱼获详情
- `POST /api/fish-catches/{id}/like` - 点赞鱼获
- `DELETE /api/fish-catches/{id}/like` - 取消点赞
- `POST /api/fish-catches/{id}/comments` - 评论鱼获
- `GET /api/fish-catches/{id}/comments` - 获取评论
- `DELETE /api/fish-catches/{id}` - 删除鱼获

### 用户数据
- `GET /api/users/me/fish-catches` - 我的鱼获
- `GET /api/users/me/fishing-spots` - 我的钓点
- `GET /api/users/me/liked-catches` - 我点赞的鱼获
- `GET /api/users/{id}/fish-catches` - 指定用户的鱼获
- `GET /api/users/{id}/fishing-spots` - 指定用户的钓点

### 文件上传
- `POST /api/upload/image` - 上传图片

## 数据库设计

### 主要表结构

- **users**: 用户信息
- **fishing_spots**: 钓点信息
- **fish_catches**: 鱼获分享
- **likes**: 点赞记录
- **comments**: 评论信息

### 数据库初始化

运行以下命令初始化数据库：

```bash
python init_db.py
```

## 部署说明

### 生产环境配置

1. 修改 `.env` 文件中的配置：
   - 使用强密码作为 `SECRET_KEY`
   - 配置正确的数据库连接信息
   - 设置合适的文件上传限制

2. 使用HTTPS确保安全性

3. 配置反向代理（如Nginx）

### Docker部署

```bash
# 构建镜像
docker build -t fishing-weather-api .

# 运行容器
docker run -d -p 8000:8000 --name fishing-api fishing-weather-api
```

## 开发说明

### 项目结构

```
backend/
├── main.py              # 主应用文件
├── config.py            # 配置管理
├── database.py          # 数据库连接
├── models.py            # 数据模型
├── schemas.py           # Pydantic模型
├── crud.py              # 数据库操作
├── auth.py              # 认证相关
├── utils.py             # 工具函数
├── init_db.py           # 数据库初始化
├── start.py             # 启动脚本
├── requirements.txt     # 依赖列表
├── .env                 # 环境配置
└── routers/             # API路由
    ├── auth_router.py
    ├── fishing_spots_router.py
    ├── fish_catches_router.py
    ├── upload_router.py
    └── users_router.py
```

### 添加新功能

1. 在 `models.py` 中定义数据模型
2. 在 `schemas.py` 中定义Pydantic模型
3. 在 `crud.py` 中实现数据库操作
4. 在相应的router文件中实现API端点

## 注意事项

1. **安全性**: 确保在生产环境中使用强密钥和HTTPS
2. **性能**: 大量数据时考虑添加缓存和分页优化
3. **备份**: 定期备份数据库
4. **日志**: 配置适当的日志记录
5. **监控**: 添加健康检查和监控

## 许可证

本项目采用MIT许可证。