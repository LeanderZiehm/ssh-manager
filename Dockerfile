# Base image
FROM python:3.14-slim AS base

# Set working directory
WORKDIR /app

# Install UV
# RUN pip install --upgrade pip && pip install uv
RUN pip install uv
RUN uv venv

COPY pyproject.toml .

RUN uv pip install -r pyproject.toml

COPY src src

CMD ["uv", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "9000"]
