#!/bin/bash
set -e

DATA_DIR="/AstrBot/data"
BACKUP_DIR="/AstrBot/backup"
REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"

# --- 1. 初始化环境 ---
echo ">>> Preparing backup directory..."
mkdir -p "$BACKUP_DIR"
cd "$BACKUP_DIR"

# 如果备份目录还没初始化过 Git，就拉取远程仓库
if [ ! -d ".git" ]; then
    echo ">>> Initializing repository from GitHub..."
    git clone "$REPO_URL" . || (git init && git remote add origin "$REPO_URL")
fi

# 配置 Git 用户信息
git config user.email "astrbot@render.com"
git config user.name "AstrBot"

# --- 2. 还原数据到运行目录 ---
echo ">>> Restoring data from backup to AstrBot..."
mkdir -p "$DATA_DIR"
# 仅复制非隐藏文件，避免把 .git 拷过去干扰运行环境
cp -rn "$BACKUP_DIR"/* "$DATA_DIR/" 2>/dev/null || true

# --- 3. 后台定时备份任务 ---
(
  while true; do
    # 每 10 分钟运行一次 (600秒)
    sleep 600
    echo ">>> Starting scheduled backup..."

    # 进入备份目录
    cd "$BACKUP_DIR"

    # 同步运行中的数据到备份目录（排除 .git 文件夹）
    # 使用 rsync 是最好的，如果没有 rsync 则使用 cp
    cp -r "$DATA_DIR"/* . 2>/dev/null || true

    # 安全备份 SQLite 数据库 (防止直接复制导致文件损坏)
    if [ -f "$DATA_DIR/data_v4.db" ]; then
      sqlite3 "$DATA_DIR/data_v4.db" ".backup 'data_v4.db'"
    fi

    # 检查是否有文件变动
    git add -A
    if ! git diff-index --quiet HEAD --; then
      echo ">>> Changes detected. Committing..."
      git commit -m "auto backup $(date '+%Y-%m-%d %H:%M:%S')"
      
      # 强制推送当前 HEAD 到远程 main 分支
      # 使用 --force 是为了防止因为 Render 实例重置导致的历史冲突
      if git push origin HEAD:main --force; then
        echo ">>> Backup successfully pushed to GitHub at $(date)"
      else
        echo ">>> [ERROR] Push failed. Check your GITHUB_TOKEN permissions."
      fi
    else
      echo ">>> No changes detected. Skip pushing."
    fi
  done
) &

# --- 4. 启动程序 ---
echo ">>> Starting AstrBot main process..."
cd /AstrBot
python main.py
