# ---- build stage: only used if you have dependencies ----
FROM cgr.dev/chainguard/python:latest-dev AS build
WORKDIR /app

# If you have a requirements.txt, uncomment these two lines:
# COPY requirements.txt .
# RUN pip install --prefix=/install -r requirements.txt --no-cache-dir

# ---- final runtime: minimal image without pip ----
FROM cgr.dev/chainguard/python:latest AS runtime
WORKDIR /app

# If you had dependencies, uncomment this line to copy them in:
# COPY --from=build /install /usr/local

# Copy your app code into the container
COPY . .

EXPOSE 8080
CMD ["python", "-m", "http.server", "8080"]
