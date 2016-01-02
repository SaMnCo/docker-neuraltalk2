# Dockerfiles for image recognition

The idea of these containers comes from some issues from the [original work repo](https://github.com/karpathy/neuraltalk2). 

I thought I would create a simple Dockerfile to make it easy for people to start playing with the Neural Talk, which is a very very cool tech with tons of applications. 

There are 2 folders: 

* Neuraltalk contains containers for the Neural Talk 2 networks
* DeepBelief is an implementation of the [JetPac Deep Belief SDK](https://github.com/jetpacapp/DeepBeliefSDK)

Then in each folders, various Dockerfiles are present, sorted by extensions: 

* amd64 is a CPU only image analysis, to run on your laptop or a non-nVidia enabled computer. This one is also automatically pushed to the Docker Hub. 
* amd64-gpu is built using the nvidia images. For some reasons, nVidia doesn't publish an image with cuDNN v3 so I can't have it published automagically, but provide instructions at the end of this document
* armhf: Supposedly compiled and working on 32b ARMv7 processors (powering Raspberry Pi 2 for example). Unfortunately, for now, and despite great support from the team writing the original work, it seems the neuraltalk2 doesn't like 32b processors like ARMv7, at least for now. Deepbelief however is OK. 

Note that the ARM images cannot be built on the Docker Hub, but you can build it at home on your own ARM machine, or use an ARM public cloud. I am doing my best to publish the images to the registry as well. 

The intention of the containers is only to use a pre-trained model. I may change this in the future or if people request it (or for nerdy fun at some point :)

# Neural Talk Containers

## What this container does

This image has everything preinstalled to create caption on images from a pre-trained model. 

The pre-trained model is stored in the env variable DATASET_SRC and defaults to "http://cs.stanford.edu/people/karpathy/neuraltalk2/checkpoint_v1_cpu.zip"

Then it will need a volume with images to perform the captioning. If you don't specify anything, the container will download 10 images from the official website, so "something" happens. 

You can then connect on http://localhost:8000/vis to access visualization. 

## How to run

You can do the most simple docker run ever: 

    docker run -it -d samnco/neuraltalk2:latest

Or you can specify a volume with images: 

    docker run -it -d -v /path/to/images:/data/images -p 8000:8000 samnco/neuraltalk2:latest

Finally, you can provide a pre-trained model, provided you share it in a volume mounted at /data/model. The model has to be a .t7 file to be recognized (simple check on extension)

    docker run -it -d -v /path/to/images:/data/images -v /path/to/model:/data/model samnco/neuraltalk2:latest

Then connect on the website

    http://localhost:8000/vis

## Adding images

Once you have more images added to your image folder, if you want to run the captioning again, just to

	docker exec -it <containerid> run.sh

Other implementations offer an upload REST API, which is neat. I may introduce similar features in the future. 

## Building & running the GPU image
### Building

nVidia publishes a set of Docker images for Cuda. For a reason I don't understand, and while the Dockerfile is available in their [repo](https://github.com/NVIDIA/nvidia-docker)... So anyway, you'll have to build it yourself. Here is how. 

First you'll need to clone their repo: 

	cd ~
	git clone https://github.com/NVIDIA/nvidia-docker.git

Now build the image for the cuDNN v3. 

	cd ~/nvidia-docker/ubuntu-14.04/cuda/7.5/devel/cudnn3
	sed -i s,cuda,nvidia/cuda, Dockerfile # For some reason nVidia also believes you create all images locally. Weird. 
	docker build -t nvidia/cuda:cudnn3-devel .

OK so now you have a proper image ready for more! 

Let's now clone this repo 

	cd ~
	git clone https://github.com/SaMnCo/docker-neuraltalk2.git

And let's build the image. You don't need an nvidia board for this, but you will need one to run it. 

	docker build -t samnco/neurotalk2-gpu:homemade docker-neuraltalk2/amd64-gpu

This will take a (very long) while. 

### Running

I have add a few issues running this in the cloud, so I guess I should share how to install the nVidia stack on a GPU enabled cloud instance such as a g2.2xlarge, running Ubuntu 14.04. It assumes you are root (otherwise copy to file and exec with sudo)

	#!/bin/bash
	USERNAME=ubuntu
	USERGROUP=ubuntu
	ARCH=amd64
	export NVIDIA_GPGKEY_SUM="bd841d59a27a406e513db7d405550894188a4c1cd96bf8aa4f82f1b39e0b5c1c"
	export NVIDIA_GPGKEY_FPR="889bee522da690103c4b085ed88c3d385c37d3be"
	export CUDA_VERSION="7.5"
	export CUDA_PKG_VERSION="7-5=7.5-18"

	apt-get update && apt-get upgrade -yqq

	apt-get update && sudo apt-get install -yqq build-essential linux-image-extra-virtual

	apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/GPGKEY && \
	    apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +2 > cudasign.pub && \
	    echo "$NVIDIA_GPGKEY_SUM cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
	    echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64 /" > /etc/apt/sources.list.d/cuda.list

	apt-get update && apt-get install -y --no-install-recommends --force-yes \
	    cuda-nvrtc-$CUDA_PKG_VERSION \
	    cuda-cusolver-$CUDA_PKG_VERSION \
	    cuda-cublas-$CUDA_PKG_VERSION \
	    cuda-cufft-$CUDA_PKG_VERSION \
	    cuda-curand-$CUDA_PKG_VERSION \
	    cuda-cusparse-$CUDA_PKG_VERSION \
	    cuda-npp-$CUDA_PKG_VERSION \
	    cuda-cudart-$CUDA_PKG_VERSION \
	    cuda && \
	    ln -s cuda-$CUDA_VERSION /usr/local/cuda

	echo "/usr/local/cuda/lib" >> /etc/ld.so.conf.d/cuda.conf && \
	    echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
	    ldconfig

	echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
	    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf && \
	    ldconfig

	export PATH="/usr/local/cuda/bin:${PATH}"
	export LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}"

OK so after this, we have an instance that should work. I strongly advise you reboot it now. 

Now you'll need to also have the nvidia-docker repo here so 

	cd /home/ubuntu
	git clone https://github.com/NVIDIA/nvidia-docker.git

and now, to run your new image,

	GPU=0 /home/ubuntu/nvidia-docker/nvidia-docker run -it -v /path/to/images:/data/images -v /path/to/model:/data/model -p 8000:8000 --name neurotalk2-gpu samnco/neuraltalk2-gpu:latest

If you do not provide images or a model, the container will download at first run. 

Further runs use the same run.sh script as above. 

## Post run

By default the container exposes port 8000. You'll need to consider opening this on TCP in the cloud configuration panel. 

# Deep Belief Container

## What this container does

It provides a deep belief network to analyze the content of images. It is an implementation  of the work shared by https://github.com/jetpacapp

When started, it will expose a web server on port 8000 that shares visualization of the images and their caption. Adding images is done by running the "run.sh" script with a path to an image.
The intended behavior is to store images in a shared volume (/data/images), then run a cron job or an incron job on all and/or new images to process them. They are then moved to a subfolder, while a thumbnail is generated for display in the website (you will need to refresh the page)

## How to run

	docker run -it -v <path/to/images>:/data/images -p 8000:8000 --name deepbelief samnco/armhf-deepbelief:latest

Then

	docker exec -it deepbelief run.sh /data/images/<image_name>

to process an image. 

Access the visualization via http://localhost:8000

