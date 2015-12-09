# This version is meant to run on a GPU enabled machine, such as G2 instances on Amazon. 
FROM ubuntu:trusty

MAINTAINER Samuel Cozannet <samuel.cozannet@madeden.com>

ENV DATASET_SRC "http://cs.stanford.edu/people/karpathy/neuraltalk2/checkpoint_v1.zip"

RUN apt-get update && \ 
    apt-get upgrade -yqq && \
    apt-get install -yqq nano curl git wget libprotobuf-dev protobuf-compiler libhdf5-serial-dev hdf5-tools python-pip build-essential python-dev linux-image-extra-virtual && \
    mkdir -p /opt/neural-networks

# Install torch
RUN cd /opt/neural-networks && \
    wget https://raw.githubusercontent.com/torch/ezinstall/master/install-deps && \
    chmod +x ./install-deps && \
    ./install-deps && \
    git clone https://github.com/torch/distro.git /opt/neural-networks/torch --recursive && \
    cd /opt/neural-networks/torch && \
    ./install.sh -b 

# Install CUDA
RUN wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_7.5-18_amd64.deb && \
    dpkg -i cuda-repo-ubuntu1404_7.5-18_amd64.deb && \
    apt-get update && \
    apt-get install -yqq cuda && \
    export PATH=/usr/local/cuda-7.5/bin/:$PATH && \
    export LD_LIBRARY_PATH=/usr/local/cuda-7.5/lib64:$LD_LIBRARY_PATH
    echo PATH=\"/usr/local/cuda-7.5/bin:$PATH\" >/etc/environment && \
    echo "LD_LIBRARY_PATH=\"/usr/local/cuda-7.5/lib64:$LD_LIBRARY_PATH\"" >> /etc/environment

# Install additional dependencies
RUN cd /opt/neural-networks/torch && \
    . /opt/neural-networks/torch/install/bin/torch-activate && \
    luarocks install cutorch && \
    luarocks install cunn && \
    luarocks install nn && \
    luarocks install nngraph && \
    luarocks install image && \
    luarocks install loadcaffe

# Install HDF5 tools
RUN cd /opt/neural-networks && \
    . /opt/neural-networks/torch/install/bin/torch-activate && \
    git clone https://github.com/deepmind/torch-hdf5.git && \
    cd torch-hdf5 && \
    luarocks make hdf5-0-0.rockspec LIBHDF5_LIBDIR="/usr/lib/x86_64-linux-gnu/"

# Install h5py
RUN pip install --upgrade cython && \
    pip install --upgrade numpy && \
    pip install --upgrade h5py 

# Install cjson
RUN cd /opt/neural-networks/ && \
    . /opt/neural-networks/torch/install/bin/torch-activate && \
    wget -c http://www.kyne.com.au/%7Emark/software/download/lua-cjson-2.1.0.tar.gz && \
    tar xfz lua-cjson-2.1.0.tar.gz && \
    cd lua-cjson-2.1.0 && \
    luarocks make

# Install CUDNN
#ADD libcudnn.so.* /opt/neural-networks/torch/install/lib/
#RUN cd /opt/neural-networks/torch && \
#    . /opt/neural-networks/torch/install/bin/torch-activate && \
#    git clone https://github.com/soumith/cudnn.torch.git cudnn && \
#    luarocks make cudnn-scm-1.rockspec 

# Downloading NeuralTalk
RUN cd /opt/neural-networks/ && \
    git clone https://github.com/SaMnCo/neuraltalk2

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Adding folders a local stuff 
RUN mkdir -p /data/model /data/images 

VOLUME /data

# Expose default port
expose 8000

ADD install.sh /opt/neural-networks/install.sh
ADD run.sh run.sh

RUN chmod +x /opt/neural-networks/install.sh && \
    chown root:root /opt/neural-networks/install.sh && \
    chmod +x run.sh && \
    chown root:root run.sh


CMD [ "/opt/neural-networks/install.sh", "/data/model", "/data/images" ]

