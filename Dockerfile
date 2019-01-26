FROM ubuntu:bionic

RUN apt-get update
RUN apt install -y bison build-essential clang++-6.0 clang-6.0 cmake coreutils diffutils flex \
                   git libboost-test-dev libffi-dev libgmp-dev libjemalloc-dev libmpfr-dev    \
                   libstdc++6 libxml2 libyaml-cpp-dev llvm-6.0 m4 maven opam openjdk-8-jdk    \
                   pkg-config python3 python-jinja2 python-pygments unifdef zlib1g-dev
RUN curl -sSL https://get.haskellstack.org/ | sh
RUN cpan install App::FatPacker Getopt::Declare String::Escape String::ShellQuote UUID::Tiny

ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g $GROUP_ID user && \
    useradd -m -u $USER_ID -s /bin/sh -g user user

USER $USER_ID:$GROUP_ID
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain 1.28.0
