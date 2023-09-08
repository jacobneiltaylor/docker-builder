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
    libreadline-dev && \
    apt_post.sh

# Install standard toolchains and dev tools
RUN $(install_go.sh 1.21.1 /opt/go) && CGO_ENABLED=0 go install github.com/envoyproxy/protoc-gen-validate@latest
RUN $(install_rust.sh 1.72.0 /opt/rust) && cargo install just && pip3 install jinja2-cli aws-sam-cli
RUN $(install_pyenv.sh 2.3.26 /opt/pyenv) && pyenv install 3.11 && pyenv global 3.11 && pyenv rehash && update_pip.sh /opt/pyenv/shims/pip3
RUN $(install_tfenv.sh 3.0.0 /opt/tfenv) && tfenv install 1.3.9 && tfenv install 1.4.6 && tfenv install 1.5.7 && tfenv use 1.5.7

# Set environment variables
ENV PATH "/opt/pyenv/shims:/opt/pyenv/bin:/opt/rust/bin:/opt/go/local/bin:/opt/go/bin:$PATH"
ENV RUSTUP_HOME "/opt/rust"
ENV CARGO_HOME "/opt/rust"
ENV GOPATH "/opt/go/local"
ENV GOBIN "/opt/go/local/bin"
ENV PYENV_ROOT "/opt/pyenv"
ENV CGO_ENABLED "0"

ENTRYPOINT [ "/usr/bin/zsh" ]
