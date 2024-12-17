# Copyright (c) 2020-2022, NVIDIA CORPORATION.  All rights reserved.
#
# NVIDIA CORPORATION and its licensors retain all intellectual property
# and proprietary rights in and to this software, related documentation
# and any modifications thereto. Any use, reproduction, disclosure or
# distribution of this software and related documentation without an express
# license agreement from NVIDIA CORPORATION is strictly prohibited.

ARG BASE_IMAGE=nvcr.io/nvidia/cuda:11.6.1-cudnn8-devel-ubuntu20.04
FROM $BASE_IMAGE

# Install necessary packages
RUN apt-get update -yq --fix-missing \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    pkg-config \
    wget \
    cmake \
    curl \
    git \
    vim \
    python3-pip \
    python3-dev \
    ffmpeg

# Set the pip index URL to Aliyun mirror
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# Copy requirements.txt and install dependencies
COPY requirements.txt ./
RUN pip3 install -r requirements.txt

# Install additional libraries
RUN pip3 install "git+https://github.com/facebookresearch/pytorch3d.git"
RUN pip3 install tensorflow-gpu==2.8.0

# Install and downgrade protobuf version
RUN pip3 uninstall -y protobuf \
    && pip3 install protobuf==3.20.1

# Copy and install your Python packages
COPY . .
WORKDIR /python_rtmpstream/python
RUN pip3 install .

# Copy the nerfstream application
COPY . .
WORKDIR /nerfstream

# Command to run the application
CMD ["python3", "app.py"]
