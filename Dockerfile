FROM python:3.11-slim

WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir requests==2.31.0

# Copy application
COPY main.py .
RUN chmod +x main.py

# Run the STF
CMD ["python", "main.py"]
