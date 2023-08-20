FROM ubuntu:23.04 as base
ENV UBUNTU_CODE_NAME=lunar

FROM base as devcontainer
ARG DEBIAN_FRONTEND=noninteractive

# --- Install Dev Tools from default apt repo ---
RUN apt-get update
RUN apt-get -y --fix-missing install git
# general build tooling:
RUN apt-get -y --fix-missing install ninja-build gdb curl zip pkg-config
# java runtime (e.g. for Sonar):
RUN apt-get -y --fix-missing install default-jre
# for Nuget access of vcpkg binary caching:
RUN apt-get -y --fix-missing install mono-complete
# for gcov style coverage:
RUN apt-get -y --fix-missing install gcovr
# for installing from other apt repos:
RUN apt-get -y --fix-missing install gpg wget software-properties-common

# --- Install *latest* version of CMake from https://apt.kitware.com/ ---
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg > /dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | tee /etc/apt/sources.list.d/kitware.list > /dev/null
RUN apt-get update
RUN rm /usr/share/keyrings/kitware-archive-keyring.gpg
RUN apt-get -y --fix-missing install kitware-archive-keyring
RUN apt-get -y --fix-missing install cmake

RUN cmake --version

# --- Install *specified* version of gcc from https://packages.ubuntu.com  ---
ARG GCC_VERSION=13
RUN apt-get -y --fix-missing install "g++-$GCC_VERSION" "gcc-$GCC_VERSION"

RUN update-alternatives --install /usr/bin/gcc gcc "/usr/bin/gcc-$GCC_VERSION" 20
RUN update-alternatives --install /usr/bin/g++ g++ "/usr/bin/g++-$GCC_VERSION" 20

RUN g++ --version

# --- Install *specified* version of llvm, clang, etc. from https://apt.llvm.org/ ---
ARG CLANG_VERSION=16
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN add-apt-repository "deb http://apt.llvm.org/$UBUNTU_CODE_NAME/ llvm-toolchain-$UBUNTU_CODE_NAME-$CLANG_VERSION main"
RUN apt-get update
RUN apt-get -y --fix-missing install llvm-$CLANG_VERSION clang-$CLANG_VERSION clang-tidy-$CLANG_VERSION clang-format-$CLANG_VERSION lldb-$CLANG_VERSION lld-$CLANG_VERSION libclang-$CLANG_VERSION-dev

RUN update-alternatives --install /usr/bin/clang clang "/usr/bin/clang-$CLANG_VERSION" 20
RUN update-alternatives --install /usr/bin/clang++ clang++ "/usr/bin/clang++-$CLANG_VERSION" 20
RUN update-alternatives --install /usr/bin/clang-tidy clang-tidy "/usr/bin/clang-tidy-$CLANG_VERSION" 20
RUN update-alternatives --install /usr/bin/clang-format clang-format "/usr/bin/clang-format-$CLANG_VERSION" 20

LABEL clang-version=$CLANG_VERSION gcc-version=$GCC_VERSION

RUN clang --version

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
