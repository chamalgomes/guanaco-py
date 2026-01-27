FROM python:3.12-bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        git \
        python3 \
        python3-pip \
        build-essential \
        cmake \
        ninja-build \
        libopenblas-dev \
        g++ \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/*

WORKDIR /app

COPY . /app

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install pytest scikit-build setuptools fastapi uvicorn sse-starlette pydantic-settings starlette-context

ENV CMAKE_GENERATOR="Ninja"
ENV CMAKE_ARGS="-DGGML_AVX=on -DGGML_AVX2=on -DGGML_FMA=on -DGGML_F16C=on -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS"

RUN pip install .[server] --verbose;

ENV HOST=0.0.0.0
ENV PORT=8000

EXPOSE 8000

CMD ["/bin/sh", "/app/docker/simple/run.sh"]
