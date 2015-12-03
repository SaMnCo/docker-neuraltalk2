FROM armv7/armhf-ubuntu:14.04

MAINTAINER Samuel Cozannet <samuel.cozannet@madeden.com>

RUN apt-get update && \
    apt-get upgrade -yqq && \
    apt-get install -yqq nano curl git wget mercurial gcc-4.8 g++-4.8 jq && \
    mkdir -p /opt/deep-belief

# Install deep-belief
RUN cd /opt/deep-belief && \
    hg clone https://bitbucket.org/eigen/eigen && \
    git clone https://github.com/jetpacapp/DeepBeliefSDK && \
    ln -sf /opt/deep-belief/eigen /opt/deep-belief/DeepBeliefSDK/eigen && \
    cd /opt/deep-belief/DeepBeliefSDK/source && \
    make clean && \
    rm -rf /usr/bin/gcc && \
    rm -rf /usr/bin/g++ && \
    ln -s /usr/bin/gcc-4.8 /usr/bin/gcc && \
    ln -s /usr/bin/g++-4.8 /usr/bin/g++  && \
    make GEMM=eigen TARGET=pi2 && \
    cp libjpcnn.so /usr/lib/ && \
    cp src/include/libjpcnn.h /usr/include/

# Adding folders a local stuff 
RUN mkdir -p /data/images /data/www /data/output

VOLUME /data/images

# Expose default port
expose 8000

ADD run.sh run.sh
ADD web.sh web.sh
ADD www /data/

RUN chmod +x run.sh && \
    chown root:root run.sh && \
    chmod +x web.sh && \
    chown root:root web.sh


CMD [ "web.sh" ]
