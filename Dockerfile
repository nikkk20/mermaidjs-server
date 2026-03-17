FROM python:3.11-slim

# Install system dependencies: Node.js, npm, and Chromium
RUN apt-get update && apt-get install -y \
    nodejs npm chromium \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Force Puppeteer to use the installed system Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Install the Mermaid CLI globally
RUN npm install -g @mermaid-js/mermaid-cli

WORKDIR /app

# Install Python requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code and configurations
COPY . .

# Expose port required by Cloud Run
EXPOSE 8080

# Run the FastAPI server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]