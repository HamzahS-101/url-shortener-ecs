FROM python:3.14.10-slim-trixie AS builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


FROM python:3.14.10-slim-trixie

WORKDIR /app
COPY --from=builder /install /usr/local
COPY src/ ./src/

# Removed because Trivy flagged high vulnerabilities in pip's bundled libraries, and the app doesn't need pip at runtime
RUN pip uninstall -y pip

USER 10001:10001
EXPOSE 8080

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
