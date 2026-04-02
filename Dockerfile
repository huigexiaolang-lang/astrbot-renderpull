FROM soulter/astrbot:latest

# 安装必要的工具：git, sqlite3, 以及 ca-certificates (确保 https 访问 github 不报错)
RUN apt-get update && apt-get install -y \
    git \
    sqlite3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 预设工作目录（这能确保你的脚本在正确的路径下查找文件）
WORKDIR /AstrBot

# 复制脚本并赋予权限
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 暴露端口（如果你需要外部访问 AstrBot 的面板，通常是 6161）
EXPOSE 6161

ENTRYPOINT ["/start.sh"]