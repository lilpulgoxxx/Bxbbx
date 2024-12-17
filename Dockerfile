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
    vim

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -u -p /opt/miniconda3 \
    && rm miniconda.sh \
    && /opt/miniconda3/bin/conda init

# Set conda environment variables
ENV PATH="/opt/miniconda3/bin:$PATH"
ENV CONDA_DEFAULT_ENV=nerfstream

# Create conda environment and activate it
RUN conda create -n nerfstream python=3.10 -y \
    && conda activate nerfstream

# Set the pip index URL to Aliyun mirror
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# Install dependencies from requirements.txt
COPY requirements.txt ./
RUN pip install -r requirements.txt

# Install additional libraries
RUN pip install "git+https://github.com/facebookresearch/pytorch3d.git"
RUN pip install tensorflow-gpu==2.8.0

# Install and downgrade protobuf version
RUN pip uninstall -y protobuf \
    && pip install protobuf==3.20.1

# Install ffmpeg using conda
RUN conda install -y ffmpeg

# Copy and install your Python packages
COPY ../python_rtmpstream /python_rtmpstream
WORKDIR /python_rtmpstream/python
RUN pip install .

# Copy the nerfstream application
COPY nerfstream /nerfstream
WORKDIR /nerfstream

# Command to run the application
CMD ["python3", "app.py"]
