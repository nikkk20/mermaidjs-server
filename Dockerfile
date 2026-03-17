FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    nodejs npm chromium \
    fonts-liberation libnss3 libatk-bridge2.0-0 libx11-xcb1 \
    libgtk-3-0 libxcomposite1 libxdamage1 libxrandr2 \
    libgbm1 libasound2 \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Puppeteer config
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Python config
ENV PYTHONUNBUFFERED=1

# Install Mermaid CLI
RUN npm install -g @mermaid-js/mermaid-cli

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy app
COPY . .

# Expose (optional for Render, but fine)
EXPOSE 8080

# IMPORTANT: use dynamic PORT
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port $PORT"]