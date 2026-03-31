#!/bin/bash
set -e

DATA_DIR="/AstrBot/data"
BACKUP_DIR="/AstrBot/backup"
REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"

echo ">>> Pulling config from GitHub..."

if [ -d "$BACKUP_DIR/.git" ]; then
  cd "$BACKUP_DIR"
  git pull
else
  if git clone "$REPO_URL" "$BACKUP_DIR" 2>/dev/null; then
    echo ">>> Cloned existing repo"
  else
    echo ">>> Repo is empty, initializing..."
    mkdir -p "$BACKUP_DIR"
    cd "$BACKUP_DIR"
    git init
    git remote add origin "$REPO_URL"
  fi
fi

# 从备份还原数据
echo ">>> Restoring data..."
mkdir -p "$DATA_DIR"
cp -r "$BACKUP_DIR"/. "$DATA_DIR/" 2>/dev/null || true
rm -rf "$DATA_DIR/.git"

cd "$BACKUP_DIR"
git config user.email "astrbot@render.com"
git config user.name "AstrBot"

# 后台定时备份（每10分钟）
(while true; do
  sleep 600
  echo ">>> Backing up..."
  mkdir -p "$BACKUP_DIR"

  # 复制所有文件（排除 .git）
  cp -r "$DATA_DIR"/. "$BACKUP_DIR/" 2>/dev/null || true
  rm -rf "$BACKUP_DIR/.git"

  # 用 SQLite 安全导出数据库
  if [ -f "$DATA_DIR/data_v4.db" ]; then
    sqlite3 "$DATA_DIR/data_v4.db" ".backup '$BACKUP_DIR/data_v4.db'"
  fi

  cd "$BACKUP_DIR"
  git init 2>/dev/null || true
  git remote set-url origin "$REPO_URL" 2>/dev/null || git remote add origin "$REPO_URL" 2>/dev/null || true
  git config user.email "astrbot@render.com"
  git config user.name "AstrBot"
  git add -A
  git commit -m "auto backup $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null || true
  git push origin HEAD 2>/dev/null || true
  echo ">>> Backup pushed at $(date)"
done) &

echo ">>> Starting AstrBot..."
cd /AstrBot
python main.py
