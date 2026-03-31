FROM soulter/astrbot:latest

RUN apt-get update && apt-get install -y git sqlite3 && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
