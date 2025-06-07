FROM ubuntu:24.04 as base

FROM base as devcontainer
ARG DEBIAN_FRONTEND=noninteractive

# --- Install Dev Tools from default apt repo ---
RUN apt-get update && apt-get -y --fix-missing install \
    git \
    # general build tooling:
    ninja-build gdb curl zip pkg-config \ 
    # java runtime (e.g. for Sonar):
    default-jre \
    # for Nuget access of vcpkg binary caching:
    mono-complete \
    # for gcov style coverage:
    gcovr


# --- Install cmake version of gcc from https://packages.ubuntu.com  ---
RUN apt-get update && apt-get -y --fix-missing install cmake
RUN cmake --version

# --- Install *specified* version of gcc from https://packages.ubuntu.com  ---
RUN apt -y remove gcc g++

ARG GCC_VERSION=14
RUN apt-get update && apt-get -y --fix-missing install "g++-$GCC_VERSION" "gcc-$GCC_VERSION"

RUN update-alternatives --install /usr/bin/gcc gcc "/usr/bin/gcc-$GCC_VERSION" 20
RUN update-alternatives --install /usr/bin/g++ g++ "/usr/bin/g++-$GCC_VERSION" 20
RUN update-alternatives --install /usr/bin/gcov gcov "/usr/bin/gcov-$GCC_VERSION" 20

RUN g++ --version

# --- Install *specified* version of llvm, clang, etc. from https://packages.ubuntu.com  ---

ARG CLANG_VERSION=19
RUN apt-get update && apt-get -y --fix-missing install llvm-$CLANG_VERSION clang-$CLANG_VERSION clang-tidy-$CLANG_VERSION clang-format-$CLANG_VERSION lldb-$CLANG_VERSION lld-$CLANG_VERSION libclang-$CLANG_VERSION-dev

RUN update-alternatives --install /usr/bin/clang clang "/usr/bin/clang-$CLANG_VERSION" 20
RUN update-alternatives --install /usr/bin/clang++ clang++ "/usr/bin/clang++-$CLANG_VERSION" 20
RUN update-alternatives --install /usr/bin/clang-tidy clang-tidy "/usr/bin/clang-tidy-$CLANG_VERSION" 20
RUN update-alternatives --install /usr/bin/clang-format clang-format "/usr/bin/clang-format-$CLANG_VERSION" 20
RUN update-alternatives --install /usr/bin/llvm-profdata llvm-profdata "/usr/bin/llvm-profdata-$CLANG_VERSION" 20
RUN update-alternatives --install /usr/bin/llvm-cov llvm-cov "/usr/bin/llvm-cov-$CLANG_VERSION" 20

RUN clang --version

LABEL clang-version=$CLANG_VERSION gcc-version=$GCC_VERSION

FROM devcontainer as test

COPY ./test /test
WORKDIR /test

RUN cmake --preset clang
RUN cmake --build ./build/clang
RUN ./build/clang/test

RUN cmake --preset gcc
RUN cmake --build ./build/gcc
RUN ./build/gcc/test

FROM devcontainer as final
