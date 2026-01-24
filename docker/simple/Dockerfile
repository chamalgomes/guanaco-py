FROM python:3.12-bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        cmake \
        ninja-build \
        clang \
        libclang-dev \
        libomp-dev \
        libopenblas-dev \
        g++ \
        && apt-get clean && \
        rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN pip install --upgrade pip
RUN pip install pytest scikit-build setuptools fastapi uvicorn sse-starlette pydantic-settings starlette-context

ENV CMAKE_GENERATOR="Ninja"
ENV CMAKE_ARGS="-DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS -DGGML_NO_ACCELERATE=ON"

RUN pip install .[server] --verbose --no-cache-dir

ENV HOST=0.0.0.0
ENV PORT=8000

EXPOSE 8000

CMD ["/bin/sh", "/app/docker/simple/run.sh"]
