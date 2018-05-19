FROM ubuntu:16.04 as build

RUN mkdir -p /usr/local/app/build /usr/local/app/contrib
WORKDIR /usr/local/app
COPY ./contrib/cuda-repo-ubuntu1604_9.2.88-1_amd64.deb ./contrib
RUN dpkg -i ./contrib/cuda-repo-ubuntu1604_9.2.88-1_amd64.deb \
  && apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub \
  && apt-get update \
  && apt-get install -y cuda \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y \
    build-essential \
    cmake \
    wget \
    libboost-dev \
    libboost-all-dev \
  && rm -rf /var/lib/apt/lists/*

RUN export CUDA_CUDART_LIBRARY="/usr/local/cuda/lib64/libcudart.so"

COPY . /usr/local/app
RUN cd build/ \
  && cmake -DCUDA_CUDART_LIBRARY=CUDA_CUDART_LIBRARY ../  \
  && make -j $(nproc)
