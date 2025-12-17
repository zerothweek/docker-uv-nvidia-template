# --------------------------------------------------------
# 1. BASE IMAGE
# --------------------------------------------------------
    FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

    LABEL maintainer="youngjoo"
    LABEL version = "0.0.1"
    LABEL description = "a docker image template(uv + nvidia)"
    
    # --------------------------------------------------------
    # 2. SYSTEM DEPENDENCIES
    # --------------------------------------------------------
    ENV DEBIAN_FRONTEND=noninteractive
    ENV LC_ALL=C.UTF-8
    ENV LANG=C.UTF-8
    
    # Consolidate apt-get to keep layers small
    # Added 'curl' and 'ca-certificates' as they are often needed for uv/git networking
    RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        git \
        curl \
        ca-certificates \
        && rm -rf /var/lib/apt/lists/*
    
    # --------------------------------------------------------
    # 3. INJECT UV
    # --------------------------------------------------------
    COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
    
    # --------------------------------------------------------
    # 4. ENVIRONMENT CONFIGURATION
    # --------------------------------------------------------
    ENV VIRTUAL_ENV=/opt/venv
    ENV PATH="$VIRTUAL_ENV/bin:$PATH"
    # Compiles Python files to .pyc bytecode during the build.
    # Speeds up container startup time because Python doesn't have to compile on the fly.
    ENV UV_COMPILE_BYTECODE=1
    # Tells uv to install packages into our specific /opt/venv directory
    # instead of trying to create a new .venv folder next to pyproject.toml.
    ENV UV_PROJECT_ENVIRONMENT=$VIRTUAL_ENV
    # Forces uv to COPY files from cache instead of Hard Linking them.
    # Prevents permission errors when running as root or changing users later.
    ENV UV_LINK_MODE=copy
    
    
    # --------------------------------------------------------
    # 5. DEPENDENCY INSTALLATION
    # --------------------------------------------------------
    WORKDIR /app
    
    # Define Install Groups (default to empty/all)
    ARG INSTALL_GROUPS="--group eda --group ml"
    
    # COPY Lockfiles first! 
    # allows Docker to detect if they changed. If uv.lock hasn't changed,
    # Docker skips the 'RUN uv sync' step entirely (Instant build).
    COPY pyproject.toml uv.lock ./
    
    # Install dependencies
    RUN --mount=type=cache,target=/root/.cache/uv \
        uv sync --frozen --no-install-project $INSTALL_GROUPS
    
    # --------------------------------------------------------
    # 6. RUNTIME
    # --------------------------------------------------------
    # Note: No CMD here. We define the command in docker-compose.
    # This makes the image reusable for workers, web servers, or dev shells.