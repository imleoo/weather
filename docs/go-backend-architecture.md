# Go后端技术架构文档

## 1. 架构概述

### 1.1 架构设计理念
- **微服务架构**: 采用微服务设计模式，支持服务独立部署和扩展
- **领域驱动设计(DDD)**: 按业务领域划分服务边界
- **整洁架构**: 分离业务逻辑与技术实现细节
- **依赖注入**: 使用接口解耦，便于测试和维护
- **响应式编程**: 支持高并发和异步处理

### 1.2 技术栈选择
```
├── Web框架: Gin (高性能HTTP框架)
├── 数据库ORM: GORM (对象关系映射)
├── 缓存: Redis + go-redis
├── 认证: JWT-go
├── 配置: Viper
├── 日志: Zap
├── 依赖注入: Wire
├── 测试: Testify + Mock
├── 文档: Swagger
└── 监控: Prometheus客户端
```

## 2. 系统架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        Load Balancer                        │
│                        (Nginx/HAProxy)                      │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────┴───────────────────────────────┐
│                    API Gateway                              │
│                  (Kong/Traefik)                             │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────┴───────────────────────────────┐
│                   Application Layer                         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────┐ │
│  │Auth Service │ │Spot Service │ │Catch Service│ │File Svc │ │
│  │             │ │             │ │             │ │         │ │
│  │• User Auth  │ │• Spot Mgmt  │ │• Catch Share│ │• Upload │ │
│  │• JWT Token  │ │• Geo Search │ │• Comments   │ │• Storage│ │
│  │• Profile    │ │• Location   │ │• Likes      │ │• CDN    │ │
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └────┬────┘ │
└─────────┼───────────────┼───────────────┼───────────┼───────┘
          │               │               │           │
┌─────────┴───────┬───────┴───────┬───────┴───────────┴───────┐
│                 │               │                            │
│ ┌───────────────┴───────────────┴───────────────┐ ┌─────────┴────┐
│ │            Domain Layer                        │ │Infrastructure│
│ │  ┌──────────┐ ┌──────────┐ ┌──────────┐       │ │   Layer      │
│ │  │User Model│ │Spot Model│ │Catch Model│      │ │              │
│ │  │          │ │          │ │          │       │ │ • MySQL      │
│ │  • Entity   │ • Entity   │ • Entity   │       │ │ • Redis      │
│ │  • Business │ • Business │ • Business │       │ │ • MinIO/S3   │
│ │  • Rules     │ • Rules    │ • Rules    │       │ │ • Message Q  │
│ │  └──────────┘ └──────────┘ └──────────┘       │ │ • External   │
│ │                                               │ │   APIs       │
│ └───────────────────────────────────────────────┘ └──────────────┘
└───────────────────────────────────────────────────────────────┘
```

## 3. 项目结构

```
fishing-backend-go/
├── cmd/
│   ├── api/                    # API服务入口
│   │   └── main.go
│   ├── worker/                 # 后台任务服务
│   │   └── main.go
│   └── migrate/                # 数据库迁移工具
│       └── main.go
├── internal/
│   ├── domain/                 # 领域层
│   │   ├── user/              # 用户领域
│   │   │   ├── entity.go
│   │   │   ├── repository.go
│   │   │   ├── service.go
│   │   │   └── value_object.go
│   │   ├── fishing_spot/      # 钓点领域
│   │   │   ├── entity.go
│   │   │   ├── repository.go
│   │   │   ├── service.go
│   │   │   └── value_object.go
│   │   └── fish_catch/        # 鱼获领域
│   │       ├── entity.go
│   │       ├── repository.go
│   │       ├── service.go
│   │       └── value_object.go
│   ├── application/            # 应用层
│   │   ├── commands/          # 命令处理
│   │   ├── queries/           # 查询处理
│   │   ├── dto/               # 数据传输对象
│   │   └── services/          # 应用服务
│   ├── infrastructure/         # 基础设施层
│   │   ├── config/            # 配置管理
│   │   ├── database/          # 数据库连接
│   │   ├── cache/             # 缓存配置
│   │   ├── storage/           # 文件存储
│   │   ├── messaging/         # 消息队列
│   │   └── external/          # 外部服务
│   ├── interfaces/             # 接口层
│   │   ├── http/              # HTTP接口
│   │   │   ├── handlers/      # 请求处理器
│   │   │   ├── middleware/    # 中间件
│   │   │   └── routes/        # 路由定义
│   │   └── rpc/               # RPC接口
│   └── shared/                 # 共享组件
│       ├── errors/             # 错误处理
│       ├── logger/             # 日志管理
│       ├── utils/              # 工具函数
│       └── constants/          # 常量定义
├── pkg/                        # 可复用包
│   ├── auth/                   # 认证相关
│   ├── geo/                    # 地理计算
│   ├── validator/              # 数据验证
│   └── response/               # 响应封装
├── migrations/                 # 数据库迁移文件
├── scripts/                    # 脚本文件
├── configs/                    # 配置文件
├── tests/                      # 测试文件
├── docs/                       # 文档
├── deployments/                # 部署配置
│   ├── docker/
│   └── kubernetes/
├── Makefile                    # 构建脚本
├── go.mod                      # Go模块定义
├── go.sum                      # Go依赖锁定
└── README.md                   # 项目文档
```

## 4. 领域层设计

### 4.1 用户领域 (User Domain)

```go
// internal/domain/user/entity.go
package user

import (
    "time"
    "github.com/google/uuid"
)

type User struct {
    ID          uuid.UUID  `json:"id"`
    Email       string     `json:"email"`
    Password    string     `json:"-"`
    Nickname    string     `json:"nickname"`
    Avatar      string     `json:"avatar"`
    Bio         string     `json:"bio"`
    IsActive    bool       `json:"is_active"`
    CreatedAt   time.Time  `json:"created_at"`
    UpdatedAt   time.Time  `json:"updated_at"`
    LastLoginAt *time.Time `json:"last_login_at"`
}

type UserProfile struct {
    User
    FollowersCount int `json:"followers_count"`
    FollowingCount int `json:"following_count"`
    CatchCount     int `json:"catch_count"`
    SpotCount      int `json:"spot_count"`
}

// 领域服务接口
type UserService interface {
    Register(cmd *RegisterCommand) (*User, error)
    Login(cmd *LoginCommand) (*AuthToken, error)
    UpdateProfile(userID uuid.UUID, cmd *UpdateProfileCommand) error
    ChangePassword(userID uuid.UUID, cmd *ChangePasswordCommand) error
    GetProfile(userID uuid.UUID) (*UserProfile, error)
    ResetPassword(email string) error
}

// 仓储接口
type UserRepository interface {
    Create(user *User) error
    Update(user *User) error
    FindByID(id uuid.UUID) (*User, error)
    FindByEmail(email string) (*User, error)
    ExistsByEmail(email string) (bool, error)
    UpdateLastLogin(userID uuid.UUID) error
}
```

### 4.2 钓点领域 (Fishing Spot Domain)

```go
// internal/domain/fishing_spot/entity.go
package fishing_spot

import (
    "time"
    "github.com/google/uuid"
)

type FishingSpot struct {
    ID          uuid.UUID  `json:"id"`
    Name        string     `json:"name"`
    Latitude    float64    `json:"latitude"`
    Longitude   float64    `json:"longitude"`
    Description string     `json:"description"`
    Images      []string   `json:"images"`
    IsPublic    bool       `json:"is_public"`
    OwnerID     uuid.UUID  `json:"owner_id"`
    CreatedAt   time.Time  `json:"created_at"`
    UpdatedAt   time.Time  `json:"updated_at"`
}

type SpotWithDistance struct {
    FishingSpot
    Distance float64 `json:"distance"` // 单位：米
}

type SpotService interface {
    CreateSpot(ownerID uuid.UUID, cmd *CreateSpotCommand) (*FishingSpot, error)
    GetNearbySpots(lat, lng, radius float64, page, limit int) ([]*SpotWithDistance, int64, error)
    GetSpotByID(spotID uuid.UUID) (*FishingSpot, error)
    UpdateSpot(ownerID, spotID uuid.UUID, cmd *UpdateSpotCommand) error
    DeleteSpot(ownerID, spotID uuid.UUID) error
    SearchSpots(keyword string, lat, lng, radius float64, page, limit int) ([]*SpotWithDistance, int64, error)
}

type SpotRepository interface {
    Create(spot *FishingSpot) error
    Update(spot *FishingSpot) error
    FindByID(id uuid.UUID) (*FishingSpot, error)
    FindNearby(lat, lng, radius float64, page, limit int) ([]*SpotWithDistance, int64, error)
    Search(keyword string, lat, lng, radius float64, page, limit int) ([]*SpotWithDistance, int64, error)
    FindByOwner(ownerID uuid.UUID, page, limit int) ([]*FishingSpot, int64, error)
    Delete(id uuid.UUID) error
    ExistsNearby(ownerID uuid.UUID, lat, lng, threshold float64) (bool, error)
}
```

### 4.3 鱼获领域 (Fish Catch Domain)

```go
// internal/domain/fish_catch/entity.go
package fish_catch

import (
    "time"
    "github.com/google/uuid"
)

type FishCatch struct {
    ID          uuid.UUID  `json:"id"`
    FishName    string     `json:"fish_name"`
    Weight      *float64   `json:"weight"`
    Length      *float64   `json:"length"`
    Description string     `json:"description"`
    Images      []string   `json:"images"`
    Latitude    *float64   `json:"latitude"`
    Longitude   *float64   `json:"longitude"`
    Location    *string    `json:"location"`
    IsPublic    bool       `json:"is_public"`
    OwnerID     uuid.UUID  `json:"owner_id"`
    SpotID      *uuid.UUID `json:"spot_id"`
    CreatedAt   time.Time  `json:"created_at"`
    UpdatedAt   time.Time  `json:"updated_at"`
}

type CatchWithStats struct {
    FishCatch
    LikeCount    int `json:"like_count"`
    CommentCount int `json:"comment_count"`
    IsLiked      bool `json:"is_liked"` // 当前用户是否点赞
}

type Like struct {
    ID        uuid.UUID `json:"id"`
    UserID    uuid.UUID `json:"user_id"`
    CatchID   uuid.UUID `json:"catch_id"`
    CreatedAt time.Time `json:"created_at"`
}

type Comment struct {
    ID        uuid.UUID  `json:"id"`
    Content   string     `json:"content"`
    UserID    uuid.UUID  `json:"user_id"`
    CatchID   uuid.UUID  `json:"catch_id"`
    ParentID  *uuid.UUID `json:"parent_id"`
    CreatedAt time.Time  `json:"created_at"`
    UpdatedAt time.Time  `json:"updated_at"`
}

type CatchService interface {
    CreateCatch(ownerID uuid.UUID, cmd *CreateCatchCommand) (*FishCatch, error)
    GetCatches(query *CatchQuery) ([]*CatchWithStats, int64, error)
    GetCatchByID(catchID uuid.UUID, userID *uuid.UUID) (*CatchWithStats, error)
    UpdateCatch(ownerID, catchID uuid.UUID, cmd *UpdateCatchCommand) error
    DeleteCatch(ownerID, catchID uuid.UUID) error
    LikeCatch(userID, catchID uuid.UUID) error
    UnlikeCatch(userID, catchID uuid.UUID) error
    AddComment(userID, catchID uuid.UUID, cmd *AddCommentCommand) (*Comment, error)
    GetComments(catchID uuid.UUID, page, limit int) ([]*Comment, int64, error)
    DeleteComment(userID, commentID uuid.UUID) error
}
```

## 5. 应用层设计

### 5.1 命令模式 (CQRS)

```go
// internal/application/commands/create_user.go
package commands

import (
    "github.com/google/uuid"
    "github.com/leoobai/fishing-backend/internal/domain/user"
)

type CreateUserCommand struct {
    Email       string `json:"email" validate:"required,email"`
    Password    string `json:"password" validate:"required,min=8"`
    Nickname    string `json:"nickname" validate:"required,min=2,max=20"`
    Avatar      string `json:"avatar" validate:"omitempty,url"`
    Bio         string `json:"bio" validate:"omitempty,max=500"`
}

type CreateUserHandler struct {
    userRepo user.UserRepository
    userService user.UserService
}

func NewCreateUserHandler(userRepo user.UserRepository, userService user.UserService) *CreateUserHandler {
    return &CreateUserHandler{
        userRepo: userRepo,
        userService: userService,
    }
}

func (h *CreateUserHandler) Handle(cmd *CreateUserCommand) (*user.User, error) {
    // 检查邮箱是否已存在
    exists, err := h.userRepo.ExistsByEmail(cmd.Email)
    if err != nil {
        return nil, err
    }
    if exists {
        return nil, user.ErrEmailAlreadyExists
    }

    // 创建用户
    user, err := h.userService.Register(cmd)
    if err != nil {
        return nil, err
    }

    return user, nil
}
```

### 5.2 查询模式

```go
// internal/application/queries/get_catches.go
package queries

import (
    "github.com/google/uuid"
    "github.com/leoobai/fishing-backend/internal/domain/fish_catch"
)

type GetCatchesQuery struct {
    SortBy     string     `json:"sort_by"` // latest, popular, nearby
    Page       int        `json:"page"`
    Limit      int        `json:"limit"`
    UserID     *uuid.UUID `json:"user_id"`
    Lat        *float64   `json:"lat"`
    Lng        *float64   `json:"lng"`
    Radius     *float64   `json:"radius"`
    CurrentUserID *uuid.UUID `json:"current_user_id"`
}

type GetCatchesResult struct {
    Catches    []*fish_catch.CatchWithStats `json:"catches"`
    TotalCount int64                        `json:"total_count"`
    Page       int                          `json:"page"`
    Limit      int                          `json:"limit"`
}

type GetCatchesHandler struct {
    catchService fish_catch.CatchService
}

func NewGetCatchesHandler(catchService fish_catch.CatchService) *GetCatchesHandler {
    return &GetCatchesHandler{
        catchService: catchService,
    }
}

func (h *GetCatchesHandler) Handle(query *GetCatchesQuery) (*GetCatchesResult, error) {
    catches, total, err := h.catchService.GetCatches(&fish_catch.CatchQuery{
        SortBy:     query.SortBy,
        Page:       query.Page,
        Limit:      query.Limit,
        UserID:     query.UserID,
        Lat:        query.Lat,
        Lng:        query.Lng,
        Radius:     query.Radius,
        CurrentUserID: query.CurrentUserID,
    })
    
    if err != nil {
        return nil, err
    }

    return &GetCatchesResult{
        Catches:    catches,
        TotalCount: total,
        Page:       query.Page,
        Limit:      query.Limit,
    }, nil
}
```

## 6. 基础设施层设计

### 6.1 数据库设计

```sql
-- 用户表
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    avatar VARCHAR(500),
    bio TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL,
    INDEX idx_email (email),
    INDEX idx_nickname (nickname)
);

-- 钓点表
CREATE TABLE fishing_spots (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    description TEXT,
    images JSON,
    is_public BOOLEAN DEFAULT true,
    owner_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_owner (owner_id),
    INDEX idx_location (latitude, longitude),
    INDEX idx_public (is_public),
    SPATIAL INDEX idx_spatial (POINT(latitude, longitude)),
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 鱼获表
CREATE TABLE fish_catches (
    id VARCHAR(36) PRIMARY KEY,
    fish_name VARCHAR(100) NOT NULL,
    weight DECIMAL(10, 3),
    length DECIMAL(10, 2),
    description TEXT,
    images JSON NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(10, 8),
    location VARCHAR(255),
    is_public BOOLEAN DEFAULT true,
    owner_id VARCHAR(36) NOT NULL,
    spot_id VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_owner (owner_id),
    INDEX idx_spot (spot_id),
    INDEX idx_public (is_public),
    INDEX idx_created (created_at),
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (spot_id) REFERENCES fishing_spots(id) ON DELETE SET NULL
);

-- 点赞表
CREATE TABLE likes (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    catch_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_catch (user_id, catch_id),
    INDEX idx_catch (catch_id),
    INDEX idx_user (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (catch_id) REFERENCES fish_catches(id) ON DELETE CASCADE
);

-- 评论表
CREATE TABLE comments (
    id VARCHAR(36) PRIMARY KEY,
    content TEXT NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    catch_id VARCHAR(36) NOT NULL,
    parent_id VARCHAR(36) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_catch (catch_id),
    INDEX idx_user (user_id),
    INDEX idx_parent (parent_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (catch_id) REFERENCES fish_catches(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE
);
```

### 6.2 Redis缓存设计

```go
// internal/infrastructure/cache/redis_cache.go
package cache

import (
    "context"
    "encoding/json"
    "time"
    
    "github.com/go-redis/redis/v8"
    "github.com/google/uuid"
)

type RedisCache struct {
    client *redis.Client
}

func NewRedisCache(addr string, password string, db int) *RedisCache {
    client := redis.NewClient(&redis.Options{
        Addr:     addr,
        Password: password,
        DB:       db,
    })
    
    return &RedisCache{client: client}
}

// 用户会话缓存
func (c *RedisCache) SetUserSession(ctx context.Context, userID uuid.UUID, token string, duration time.Duration) error {
    key := "user:session:" + userID.String()
    return c.client.Set(ctx, key, token, duration).Err()
}

func (c *RedisCache) GetUserSession(ctx context.Context, userID uuid.UUID) (string, error) {
    key := "user:session:" + userID.String()
    return c.client.Get(ctx, key).Result()
}

// 钓点缓存
func (c *RedisCache) SetNearbySpots(ctx context.Context, lat, lng, radius float64, spots []byte, duration time.Duration) error {
    key := c.generateGeoKey("spots:nearby", lat, lng, radius)
    return c.client.Set(ctx, key, spots, duration).Err()
}

func (c *RedisCache) GetNearbySpots(ctx context.Context, lat, lng, radius float64) ([]byte, error) {
    key := c.generateGeoKey("spots:nearby", lat, lng, radius)
    return c.client.Get(ctx, key).Bytes()
}

// 鱼获缓存
func (c *RedisCache) SetCatchList(ctx context.Context, query string, catches []byte, duration time.Duration) error {
    key := "catches:list:" + query
    return c.client.Set(ctx, key, catches, duration).Err()
}

func (c *RedisCache) GetCatchList(ctx context.Context, query string) ([]byte, error) {
    key := "catches:list:" + query
    return c.client.Get(ctx, key).Bytes()
}

func (c *RedisCache) generateGeoKey(prefix string, lat, lng, radius float64) string {
    // 将坐标和半径转换为网格键，实现近似地理位置缓存
    gridLat := int(lat * 100)    // 精度约为1km
    gridLng := int(lng * 100)
    gridRadius := int(radius / 1000) // 转换为km
    return fmt.Sprintf("%s:%d:%d:%d", prefix, gridLat, gridLng, gridRadius)
}
```

## 7. 接口层设计

### 7.1 RESTful API设计

```go
// internal/interfaces/http/routes/user_routes.go
package routes

import (
    "github.com/gin-gonic/gin"
    "github.com/leoobai/fishing-backend/internal/application/commands"
    "github.com/leoobai/fishing-backend/internal/application/queries"
    "github.com/leoobai/fishing-backend/internal/interfaces/http/handlers"
    "github.com/leoobai/fishing-backend/internal/interfaces/http/middleware"
)

type UserRoutes struct {
    userHandler *handlers.UserHandler
    jwtMiddleware *middleware.JWTMiddleware
}

func NewUserRoutes(userHandler *handlers.UserHandler, jwtMiddleware *middleware.JWTMiddleware) *UserRoutes {
    return &UserRoutes{
        userHandler: userHandler,
        jwtMiddleware: jwtMiddleware,
    }
}

func (r *UserRoutes) Register(router *gin.Engine) {
    // 公开路由
    public := router.Group("/api/v1/auth")
    {
        public.POST("/register", r.userHandler.Register)
        public.POST("/login", r.userHandler.Login)
        public.POST("/refresh", r.userHandler.RefreshToken)
        public.POST("/forgot-password", r.userHandler.ForgotPassword)
        public.POST("/reset-password", r.userHandler.ResetPassword)
    }
    
    // 需要认证的路由
    protected := router.Group("/api/v1/users")
    protected.Use(r.jwtMiddleware.AuthRequired())
    {
        protected.GET("/me", r.userHandler.GetProfile)
        protected.PUT("/me", r.userHandler.UpdateProfile)
        protected.PUT("/me/password", r.userHandler.ChangePassword)
        protected.DELETE("/me", r.userHandler.DeleteAccount)
        
        // 用户内容管理
        protected.GET("/me/catches", r.userHandler.GetMyCatches)
        protected.GET("/me/spots", r.userHandler.GetMySpots)
        protected.GET("/me/likes", r.userHandler.GetMyLikedCatches)
        
        // 其他用户信息
        protected.GET("/:id", r.userHandler.GetUserByID)
        protected.GET("/:id/catches", r.userHandler.GetUserCatches)
        protected.GET("/:id/spots", r.userHandler.GetUserSpots)
    }
}
```

### 7.2 中间件设计

```go
// internal/interfaces/http/middleware/auth_middleware.go
package middleware

import (
    "net/http"
    "strings"
    
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
    "github.com/leoobai/fishing-backend/internal/infrastructure/config"
    "github.com/leoobai/fishing-backend/pkg/auth"
)

type JWTMiddleware struct {
    jwtService auth.JWTService
    config     *config.Config
}

func NewJWTMiddleware(jwtService auth.JWTService, config *config.Config) *JWTMiddleware {
    return &JWTMiddleware{
        jwtService: jwtService,
        config:     config,
    }
}

func (m *JWTMiddleware) AuthRequired() gin.HandlerFunc {
    return func(c *gin.Context) {
        // 获取token
        tokenString := m.extractToken(c)
        if tokenString == "" {
            c.JSON(http.StatusUnauthorized, gin.H{
                "code": 401,
                "message": "Authorization token required",
            })
            c.Abort()
            return
        }
        
        // 验证token
        claims, err := m.jwtService.ValidateToken(tokenString)
        if err != nil {
            c.JSON(http.StatusUnauthorized, gin.H{
                "code": 401,
                "message": "Invalid or expired token",
            })
            c.Abort()
            return
        }
        
        // 设置用户信息到上下文
        userID, err := uuid.Parse(claims.UserID)
        if err != nil {
            c.JSON(http.StatusUnauthorized, gin.H{
                "code": 401,
                "message": "Invalid token claims",
            })
            c.Abort()
            return
        }
        
        c.Set("userID", userID)
        c.Set("userEmail", claims.Email)
        c.Next()
    }
}

func (m *JWTMiddleware) extractToken(c *gin.Context) string {
    bearerToken := c.GetHeader("Authorization")
    if len(strings.Split(bearerToken, " ")) == 2 {
        return strings.Split(bearerToken, " ")[1]
    }
    return ""
}

// CORS中间件
func CORS() gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
        c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
        c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
        c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")
        
        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(204)
            return
        }
        
        c.Next()
    }
}

// 错误处理中间件
func ErrorHandler() gin.HandlerFunc {
    return gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
        if err, ok := recovered.(string); ok {
            c.JSON(http.StatusInternalServerError, gin.H{
                "code": 500,
                "message": "Internal server error",
                "error": err,
            })
        }
        c.AbortWithStatus(http.StatusInternalServerError)
    })
}
```

## 8. 配置管理

```go
// internal/infrastructure/config/config.go
package config

import (
    "log"
    "os"
    "strconv"
    "time"
    
    "github.com/spf13/viper"
)

type Config struct {
    // 服务器配置
    Server struct {
        Host         string
        Port         string
        Mode         string // development, staging, production
        ReadTimeout  time.Duration
        WriteTimeout time.Duration
    }
    
    // 数据库配置
    Database struct {
        Host         string
        Port         string
        Username     string
        Password     string
        DBName       string
        MaxOpenConns int
        MaxIdleConns int
        MaxLifetime  time.Duration
    }
    
    // Redis配置
    Redis struct {
        Host         string
        Port         string
        Password     string
        DB           int
        PoolSize     int
        MinIdleConns int
    }
    
    // JWT配置
    JWT struct {
        Secret           string
        AccessTokenTTL   time.Duration
        RefreshTokenTTL  time.Duration
    }
    
    // 存储配置
    Storage struct {
        Type     string // local, s3, oss
        Endpoint string
        Bucket   string
        Region   string
        AccessKey string
        SecretKey string
    }
    
    // 日志配置
    Logger struct {
        Level      string
        Output     string // stdout, file
        FilePath   string
        MaxSize    int    // MB
        MaxBackups int
        MaxAge     int    // days
    }
    
    // 监控配置
    Monitoring struct {
        Enabled bool
        MetricsPort string
    }
}

func LoadConfig() (*Config, error) {
    viper.SetConfigName("config")
    viper.SetConfigType("yaml")
    viper.AddConfigPath("./configs")
    viper.AddConfigPath(".")
    
    // 设置默认值
    setDefaults()
    
    // 读取配置文件
    if err := viper.ReadInConfig(); err != nil {
        if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
            return nil, err
        }
    }
    
    // 绑定环境变量
    bindEnvVars()
    
    var config Config
    if err := viper.Unmarshal(&config); err != nil {
        return nil, err
    }
    
    return &config, nil
}

func setDefaults() {
    // 服务器默认配置
    viper.SetDefault("server.host", "0.0.0.0")
    viper.SetDefault("server.port", "8080")
    viper.SetDefault("server.mode", "development")
    viper.SetDefault("server.read_timeout", "15s")
    viper.SetDefault("server.write_timeout", "15s")
    
    // 数据库默认配置
    viper.SetDefault("database.host", "localhost")
    viper.SetDefault("database.port", "3306")
    viper.SetDefault("database.max_open_conns", 25)
    viper.SetDefault("database.max_idle_conns", 5)
    viper.SetDefault("database.max_lifetime", "5m")
    
    // JWT默认配置
    viper.SetDefault("jwt.access_token_ttl", "24h")
    viper.SetDefault("jwt.refresh_token_ttl", "168h") // 7天
}

func bindEnvVars() {
    // 服务器环境变量
    viper.BindEnv("server.host", "SERVER_HOST")
    viper.BindEnv("server.port", "SERVER_PORT")
    viper.BindEnv("server.mode", "SERVER_MODE")
    
    // 数据库环境变量
    viper.BindEnv("database.host", "DB_HOST")
    viper.BindEnv("database.port", "DB_PORT")
    viper.BindEnv("database.username", "DB_USERNAME")
    viper.BindEnv("database.password", "DB_PASSWORD")
    viper.BindEnv("database.db_name", "DB_NAME")
    
    // Redis环境变量
    viper.BindEnv("redis.host", "REDIS_HOST")
    viper.BindEnv("redis.port", "REDIS_PORT")
    viper.BindEnv("redis.password", "REDIS_PASSWORD")
    
    // JWT环境变量
    viper.BindEnv("jwt.secret", "JWT_SECRET")
}
```

## 9. 部署架构

### 9.1 Docker容器化

```dockerfile
# Dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main cmd/api/main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /root/

COPY --from=builder /app/main .
COPY --from=builder /app/configs ./configs

EXPOSE 8080
CMD ["./main"]
```

### 9.2 Kubernetes部署

```yaml
# deployments/kubernetes/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fishing-backend
  labels:
    app: fishing-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fishing-backend
  template:
    metadata:
      labels:
        app: fishing-backend
    spec:
      containers:
      - name: fishing-backend
        image: fishing-backend:latest
        ports:
        - containerPort: 8080
        env:
        - name: SERVER_MODE
          value: "production"
        - name: DB_HOST
          value: "mysql-service"
        - name: REDIS_HOST
          value: "redis-service"
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: jwt-secret
              key: secret
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: fishing-backend-service
spec:
  selector:
    app: fishing-backend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

## 10. 监控和运维

### 10.1 性能监控

```go
// internal/infrastructure/monitoring/metrics.go
package monitoring

import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promauto"
)

var (
    // HTTP请求指标
    httpRequestsTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "fishing_http_requests_total",
            Help: "Total number of HTTP requests",
        },
        []string{"method", "endpoint", "status"},
    )
    
    httpRequestDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "fishing_http_request_duration_seconds",
            Help: "HTTP request duration in seconds",
        },
        []string{"method", "endpoint"},
    )
    
    // 业务指标
    userRegistrations = promauto.NewCounter(
        prometheus.CounterOpts{
            Name: "fishing_user_registrations_total",
            Help: "Total number of user registrations",
        },
    )
    
    spotCreations = promauto.NewCounter(
        prometheus.CounterOpts{
            Name: "fishing_spot_creations_total",
            Help: "Total number of fishing spot creations",
        },
    )
    
    catchShares = promauto.NewCounter(
        prometheus.CounterOpts{
            Name: "fishing_catch_shares_total",
            Help: "Total number of fish catch shares",
        },
    )
    
    // 数据库指标
    dbQueriesTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "fishing_db_queries_total",
            Help: "Total number of database queries",
        },
        []string{"table", "operation"},
    )
    
    dbQueryDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "fishing_db_query_duration_seconds",
            Help: "Database query duration in seconds",
        },
        []string{"table", "operation"},
    )
)

// 指标记录函数
func RecordHTTPRequest(method, endpoint, status string) {
    httpRequestsTotal.WithLabelValues(method, endpoint, status).Inc()
}

func RecordHTTPRequestDuration(method, endpoint string, duration float64) {
    httpRequestDuration.WithLabelValues(method, endpoint).Observe(duration)
}

func RecordUserRegistration() {
    userRegistrations.Inc()
}

func RecordSpotCreation() {
    spotCreations.Inc()
}

func RecordCatchShare() {
    catchShares.Inc()
}

func RecordDBQuery(table, operation string) {
    dbQueriesTotal.WithLabelValues(table, operation).Inc()
}

func RecordDBQueryDuration(table, operation string, duration float64) {
    dbQueryDuration.WithLabelValues(table, operation).Observe(duration)
}
```

### 10.2 健康检查

```go
// internal/interfaces/http/handlers/health_handler.go
package handlers

import (
    "net/http"
    
    "github.com/gin-gonic/gin"
    "github.com/leoobai/fishing-backend/internal/infrastructure/database"
    "github.com/leoobai/fishing-backend/internal/infrastructure/cache"
)

type HealthHandler struct {
    db    *database.DB
    cache *cache.RedisCache
}

func NewHealthHandler(db *database.DB, cache *cache.RedisCache) *HealthHandler {
    return &HealthHandler{
        db:    db,
        cache: cache,
    }
}

type HealthStatus struct {
    Status   string                 `json:"status"`
    Version  string                 `json:"version"`
    Uptime   string                 `json:"uptime"`
    Services map[string]ServiceHealth `json:"services"`
}

type ServiceHealth struct {
    Status  string `json:"status"`
    Message string `json:"message,omitempty"`
}

func (h *HealthHandler) Health(c *gin.Context) {
    status := HealthStatus{
        Status:  "healthy",
        Version: "1.0.0",
        Uptime:  getUptime(),
        Services: make(map[string]ServiceHealth),
    }
    
    // 检查数据库连接
    if err := h.db.Ping(); err != nil {
        status.Services["database"] = ServiceHealth{
            Status:  "unhealthy",
            Message: err.Error(),
        }
        status.Status = "unhealthy"
    } else {
        status.Services["database"] = ServiceHealth{
            Status: "healthy",
        }
    }
    
    // 检查缓存连接
    if err := h.cache.Ping(c.Request.Context()); err != nil {
        status.Services["cache"] = ServiceHealth{
            Status:  "unhealthy",
            Message: err.Error(),
        }
        status.Status = "unhealthy"
    } else {
        status.Services["cache"] = ServiceHealth{
            Status: "healthy",
        }
    }
    
    if status.Status == "healthy" {
        c.JSON(http.StatusOK, status)
    } else {
        c.JSON(http.StatusServiceUnavailable, status)
    }
}

func (h *HealthHandler) Ready(c *gin.Context) {
    // 就绪检查，检查应用是否可以接收流量
    if err := h.db.Ping(); err != nil {
        c.JSON(http.StatusServiceUnavailable, gin.H{
            "status": "not_ready",
            "error":  err.Error(),
        })
        return
    }
    
    c.JSON(http.StatusOK, gin.H{
        "status": "ready",
    })
}
```

这个Go后端架构文档提供了完整的技术实现方案，包括：

1. **微服务架构设计**：采用领域驱动设计和整洁架构原则
2. **完整的技术栈**：使用Gin、GORM、Redis、JWT等主流Go技术
3. **详细的项目结构**：按业务领域分层组织代码
4. **数据库设计**：包含完整的表结构和索引设计
5. **缓存策略**：Redis缓存层优化性能
6. **API设计**：RESTful接口规范和中间件设计
7. **配置管理**：支持多环境的配置管理
8. **容器化部署**：Docker和Kubernetes部署方案
9. **监控运维**：Prometheus指标和健康检查

这个架构具有良好的可扩展性、可维护性和高性能，能够支撑钓鱼社交应用的后端需求。,