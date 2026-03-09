# syntax=docker/dockerfile:1
# Streamlit Quantitative Analysis PoC — production container image

FROM python:3.11-slim

# Create a non-root user/group for security
RUN groupadd --system appgroup \
 && useradd  --system --gid appgroup --no-create-home appuser

WORKDIR /app

# Install Python dependencies in a separate layer (better cache reuse on redeploy)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY app.py utils.py ./

# Transfer ownership to the non-root user
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8501

# Lightweight health check that uses the stdlib (no extra packages needed)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD python -c \
        "import urllib.request; urllib.request.urlopen('http://localhost:8501/_stcore/health')"

ENTRYPOINT ["streamlit", "run", "app.py", \
            "--server.port=8501", \
            "--server.address=0.0.0.0", \
            "--server.headless=true", \
            "--browser.gatherUsageStats=false"]
