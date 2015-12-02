# Dockerfile for Neural Talk 2

The idea of this container comes from some issues from the [original work repo](https://github.com/karpathy/neuraltalk2). 

I thought I would create a simple Dockerfile to make it easy for people to start playing with the Neural Talk, which is a very very cool tech. 

There are 2 branches here, as my intention is primarily to make this work on a raspberry pi 2, even if there is still some work to be done. The armhf branch cannot be processed on Docker Hub, but you can build it at home on your own ARM machine, or use an ARM public cloud. 

The intention of this container is only to use a pre-trained model. I may change this in the future or if people request it. 

# What this container does

This image has everything preinstalled to create caption on images from a pre-trained model. 

The pre-trained model is stored in the env variable DATASET_SRC and defaults to "http://cs.stanford.edu/people/karpathy/neuraltalk2/checkpoint_v1_cpu.zip"

Then it will need a volume with images to perform the captioning. If you don't specify anything, the container will download 10 images from the official website, so "something" happens. 

You can then connect on http://<container IP>:8000/vis to access visualization. 

# How to run

You can do the most simple docker run ever: 

    docker run -it -b samnco/neuraltalk2:latest

Or you can specify a volume with images: 

    docker run -it -b -v /path/to/images:/data/images samnco/neuraltalk2:latest

Finally, you can provide a pre-trained model, provided you share it in a volume mounted at /data/model. The model has to be a .t7 file to be recognized (simple check on extension)

    docker run -it -b -v /path/to/images:/data/images -v /path/to/model:/data/model samnco/neuraltalk2:latest

Then access the IP address 

    docker exec -it <containerid> ip addr show eth0

# Adding images

Once you have more images added to your image folder, if you want to run the captioning again, just to

	docker exec -it <containerid> run.sh

