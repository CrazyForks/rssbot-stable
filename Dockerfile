# 构建阶段
FROM rust:1.71-slim as builder

# 安装必要的构建依赖
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 创建新的构建目录
WORKDIR /usr/src/rssbot

# 复制项目文件
COPY . .

# 构建项目
RUN cargo build --release

# 运行阶段
FROM debian:bullseye-slim

# 安装运行时依赖
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 创建工作目录
WORKDIR /app

# 从构建阶段复制编译好的二进制文件
COPY --from=builder /usr/src/rssbot/target/release/rssbot /app/rssbot

# 创建数据目录
RUN mkdir -p /app/data

# 设置数据库文件的默认位置
ENV DATABASE_PATH=/app/data/rssbot.json

# 设置入口点
ENTRYPOINT ["/app/rssbot"]