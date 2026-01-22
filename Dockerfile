# Use official Python slim image
FROM python:3.12-slim

# Set work directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app
COPY main.py .

# Expose port
EXPOSE 9000

# Command to run the app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "9000"]
