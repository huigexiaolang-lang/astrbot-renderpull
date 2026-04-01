

# AstrBot-Renderpull

**EN** | [中文](#中文)

A simple solution to persist AstrBot (or any chatbot with a SQLite database) data when deployed on cloud platforms like Render, which reset the filesystem on every restart.

**How it works:** A background script automatically backs up the `data/` directory (personas, memory, plugins) to your private GitHub repo every 2 minutes. On each restart, the data is pulled back automatically.

> AstrBot repo: https://github.com/astrbotdevs/astrbot

---

## Setup

**Step 1: Create two GitHub repos**
One public repo for the Dockerfile and start.sh (or just fork this repo), and one private repo to store your bot's data.

**Step 2: Add the files**
If you forked this repo, skip this step. Otherwise, copy `Dockerfile` and `start.sh` into your public repo.

**Step 3: Create a GitHub Token**
Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic), generate a token with `repo` permission.

**Step 4: Add environment variables in Render**
Add these 3 variables to your web service:
- `GITHUB_TOKEN` — Your personal access token
- `GITHUB_USER` — Your GitHub username
- `GITHUB_REPO` — Your private repo name

**Step 5: Deploy from your repo**
In Render, set your service to build from the public repo instead of using the official Docker image.

**Step 6: First-time setup**
After the first deploy, configure your bot normally. Wait ~3 minutes for the first backup to push to your private repo. You can verify by checking if files appear there.

---

## 中文

一个简单的方案，解决 AstrBot（或其他使用 SQLite 数据库的聊天机器人）部署在 Render 等云平台时，每次重启数据丢失的问题。

**原理：** 后台脚本每2分钟自动将 `data/` 目录（人设、记忆、插件）备份到你的私有 GitHub repo，每次重启时自动拉取恢复。

---

## 使用步骤

**第一步：创建两个 GitHub repo**
一个公开 repo 用于存放 Dockerfile 和 start.sh（也可以直接 fork 本 repo），一个私有 repo 用于存储机器人数据。

**第二步：添加文件**
如果你 fork 了本 repo，跳过此步骤。否则将 `Dockerfile` 和 `start.sh` 复制到你的公开 repo。

**第三步：创建 GitHub Token**
GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)，生成一个勾选了 `repo` 权限的 token。

**第四步：在 Render 添加环境变量**
在你的 web service 中添加以下3个变量：
- `GITHUB_TOKEN` — 你的 personal access token
- `GITHUB_USER` — 你的 GitHub 用户名
- `GITHUB_REPO` — 你的私有 repo 名称

**第五步：从你的 repo 部署**
在 Render 中将服务改为从公开 repo 构建，而不是使用官方 Docker 镜像。

**第六步：首次使用**
第一次部署后，正常配置好你的机器人。等约3分钟让第一次备份推送到私有 repo，去私有 repo 检查是否有文件出现即可确认备份正常工作。
