# Builds the BinSE runtime image from artifacts/BinSE.zip.
ARG PYTHON_BASE=python:3.8.20-slim-bookworm
FROM ${PYTHON_BASE}

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TRANSFORMERS_OFFLINE=1 \
    PIP_DEFAULT_TIMEOUT=120 \
    PIP_RETRIES=10

# libgomp1/libgfortran5: runtime libs required by the torch/scipy wheels
RUN apt-get update \
 && apt-get install -y --no-install-recommends libgomp1 libgfortran5 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r /app/requirements.txt

COPY artifacts/BinSE.zip /tmp/release.zip
RUN python -m zipfile -e /tmp/release.zip /app/ \
 && mv /app/BinSE/* /app/ && rmdir /app/BinSE \
 && rm /tmp/release.zip \
 && chmod -R a-w /app/BlockEmbedding /app/CG_store /app/FunctionEmbedding /app/propagation_store /app/Tokenizer

# optional in-container feature extraction (needs a mounted Linux IDA); off by default
ARG WITH_EXTRACTOR=0
COPY artifacts/extractor/BinSE_extractor.zip /tmp/extractor.zip
RUN if [ "$WITH_EXTRACTOR" = "1" ]; then \
      python -m zipfile -e /tmp/extractor.zip /tmp/x \
   && mkdir -p /app/ida_extract \
   && cp /tmp/x/BinSE_extractor/linux/* /app/ida_extract/ \
   && rm -rf /tmp/x; \
    fi \
 && rm /tmp/extractor.zip

ENTRYPOINT ["python", "main.py"]
