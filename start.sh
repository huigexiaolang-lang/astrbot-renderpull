#!/bin/bash
set -e

DATA_DIR="/AstrBot/data"
REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"

echo ">>> Pulling config from GitHub..."

if [ -d "$DATA_DIR/.git" ]; then
  cd "$DATA_DIR"
  git pull
else
  if git clone "$REPO_URL" "$DATA_DIR" 2>/dev/null; then
    echo ">>> Cloned existing repo"
  else
    echo ">>> Repo is empty, initializing..."
    mkdir -p "$DATA_DIR"
    cd "$DATA_DIR"
    git init
    git remote add origin "$REPO_URL"
  fi
fi

cd "$DATA_DIR"
git config user.email "astrbot@render.com"
git config user.name "AstrBot"

(while true; do
  sleep 600
  cd "$DATA_DIR"
  git add -A
  git commit -m "auto backup $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null || true
  git push origin HEAD 2>/dev/null || true
  echo ">>> Backup pushed at $(date)"
done) &

echo ">>> Starting AstrBot..."
cd /AstrBot
python main.py
