ARG BASEVERSION

FROM jacobneiltaylor/docker-base:${BASEVERSION}

# Install system dependencies
RUN apt_pre.sh && \
    apt-get install -y \
    git \
    zsh \
    clang \
    protobuf-compiler \
    build-essential \
    libprotobuf-dev \
    libffi-dev \
    libz-dev \
    libncursesw5-dev \
    libssl-dev \
    libgdbm-dev \
    libsqlite3-dev \
    libbz2-dev \
    liblzma-dev \
    tk-dev \
    libdb-dev \
    python3-dev \
    libreadline-dev \
    nodejs\ 
    npm && \
    apt_post.sh

# Install standard toolchains and dev tools
RUN npm install -g @bazel/bazelisk && USE_BAZEL_VERSION=7.0.0 bazelisk
RUN $(install_go.sh 1.22.3 /opt/go) && CGO_ENABLED=0 go install github.com/envoyproxy/protoc-gen-validate@latest
RUN $(install_rust.sh 1.75.0 /opt/rust) && cargo install just fnm && fnm install --fnm-dir /opt/fnm --corepack-enabled v20.11.0 && fnm alias --fnm-dir /opt/fnm v20.11.0 default
RUN $(install_pyenv.sh 2.3.35 /opt/pyenv) && pyenv install pypy3.10 && pyenv install 3.10 && pyenv install 3.11 && pyenv install 3.12 && pyenv global 3.12 && pyenv rehash && update_pip.sh /opt/pyenv/shims/pip3
RUN $(install_tfenv.sh 3.0.0 /opt/tfenv) && tfenv install 1.3.9 && tfenv install 1.4.6 && tfenv install 1.5.7 && tfenv use 1.5.7
RUN /opt/pyenv/shims/pip3 install jinja2-cli aws-sam-cli

# Set environment variables
ENV PATH "/opt/fnm/aliases/default/bin:/opt/pyenv/shims:/opt/pyenv/bin:/opt/rust/bin:/opt/go/local/bin:/opt/go/bin:$PATH"
ENV RUSTUP_HOME "/opt/rust"
ENV CARGO_HOME "/opt/rust"
ENV GOPATH "/opt/go/local"
ENV GOBIN "/opt/go/local/bin"
ENV PYENV_ROOT "/opt/pyenv"
ENV FNM_DIR "/opt/fnm"
ENV FNM_COREPACK_ENABLED "true"

ENTRYPOINT [ "/usr/bin/zsh" ]
