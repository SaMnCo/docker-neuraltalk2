# This images is meant to run on a x86_64 device. 
# It provides a deep belief network to analyze the content of images. 
# It is an implementation of the work shared by https://github.com/jetpacapp

# When started, it will expose a web server on port 8000 that shares visualization of the images and their caption. Adding images is done by running the "run.sh" script with a path to an image.
# The intended behavior is to store images in a shared volume (/data/images), then run a cron job or an incron job on all and/or new images to process them. They are then moved to a subfolder, while a thumbnail is generated for display in the website (you will need to refresh the page)

# Usage :
#   docker run -it -v <path/to/images>:/data/images -p 8000:8000 --name deepbelief samnco/amd64-deepbelief:latest
# Then
#   docker exec -it deepbelief run.sh /data/images/<image_name>
# Access the visualization via http://localhost:8000

FROM ubuntu:14.04

MAINTAINER Samuel Cozannet <samuel.cozannet@madeden.com>

ENV NETWORK ccv2012.ntwk
# Possible values: jetpac.ntwk, ccv2012.ntwk, ccv2010.ntwk
ENV ARCH=x86_64

RUN apt-get update && \
    apt-get upgrade -yqq && \
    apt-get install -yqq nano curl git wget mercurial gcc-4.8 g++-4.8 jq build-essential imagemagick && \
    mkdir -p /opt/deep-belief

# Install deep-belief
RUN cd /opt/deep-belief && \
    git clone https://github.com/jetpacapp/DeepBeliefSDK && \
    cd /opt/deep-belief/DeepBeliefSDK/LinuxLibrary && \
    ./install.sh

COPY networks/${NETWORK} /opt/deep-belief/DeepBeliefSDK/examples/SimpleLinux/jetpac.ntwk

RUN cd /opt/deep-belief/DeepBeliefSDK/examples/SimpleLinux && \
    make

# Adding folders a local stuff 
RUN mkdir -p /data/images/processed /data/www

VOLUME /data/images

# Expose default port
expose 8000

ADD bin/${ARCH}-run.sh /usr/bin/run.sh
ADD bin/web.sh /usr/bin/web.sh
ADD www/* /data/www/

RUN chmod +x /usr/bin/run.sh && \
    chown root:root /usr/bin/run.sh && \
    chmod +x /usr/bin/web.sh && \
    chown root:root /usr/bin/web.sh

CMD [ "web.sh" ]
