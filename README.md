# Dockerfiles for image recognition

The idea of these containers comes from some issues from the [original work repo](https://github.com/karpathy/neuraltalk2). 

I thought I would create a simple Dockerfile to make it easy for people to start playing with the Neural Talk, which is a very very cool tech. These are the 2 main folder amd64 and armhf. 

There are 2 folders here, as my intention is primarily to make this work on a raspberry pi 2, even if there is still some work to be done. The armhf branch cannot be processed on Docker Hub, but you can build it at home on your own ARM machine, or use an ARM public cloud. The image also has been uploaded to the hub. 

Then as I struggled with Torch on Raspberry Pi 2, I searched for more solutions to recognize images, and I found some [Deep Belief work](https://github.com/jetpacapp/DeepBeliefSDK) that works nicely on Raspberry Pi and decided to add it as a container in the armhf-deepbelief folder.  

The intention of the containers is only to use a pre-trained model. I may change this in the future or if people request it. 

# Neural Talk Containers

* Stored in folders amd64 and armhf

## What this container does

This image has everything preinstalled to create caption on images from a pre-trained model. 

The pre-trained model is stored in the env variable DATASET_SRC and defaults to "http://cs.stanford.edu/people/karpathy/neuraltalk2/checkpoint_v1_cpu.zip"

Then it will need a volume with images to perform the captioning. If you don't specify anything, the container will download 10 images from the official website, so "something" happens. 

You can then connect on http://localhost:8000/vis to access visualization. 

## How to run

You can do the most simple docker run ever: 

    docker run -it -b samnco/neuraltalk2:latest

Or you can specify a volume with images: 

    docker run -it -b -v /path/to/images:/data/images -p 8000:8000 samnco/neuraltalk2:latest

Finally, you can provide a pre-trained model, provided you share it in a volume mounted at /data/model. The model has to be a .t7 file to be recognized (simple check on extension)

    docker run -it -b -v /path/to/images:/data/images -v /path/to/model:/data/model samnco/neuraltalk2:latest

Then connect on the website

    http://localhost:8000/vis

## Adding images

Once you have more images added to your image folder, if you want to run the captioning again, just to

	docker exec -it <containerid> run.sh

Other implementations offer an upload REST API, which is neat. I may introduce similar features in the future. 

# Deep Belief Container

* Stored in armhf-deepbelief and on the hub samnco/armhf-deepbelief:latest

## What this container does

This images is meant to run on a ARMv7 device such as a Raspberry Pi
It provides a deep belief network to analyze the content of images. It is an implementation  of the work shared by https://github.com/jetpacapp

When started, it will expose a web server on port 8000 that shares visualization of the images and their caption. Adding images is done by running the "run.sh" script with a path to an image.
The intended behavior is to store images in a shared volume (/data/images), then run a cron job or an incron job on all and/or new images to process them. They are then moved to a subfolder, while a thumbnail is generated for display in the website (you will need to refresh the page)

## How to run

	docker run -it -v <path/to/images>:/data/images -p 8000:8000 --name deepbelief samnco/armhf-deepbelief:latest

Then

	docker exec -it deepbelief run.sh /data/images/<image_name>

to process an image. 

Access the visualization via http://localhost:8000

