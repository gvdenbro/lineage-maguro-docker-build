FROM ubuntu:15.04

MAINTAINER Gregory Vandenbroucke (gregory.vandenbroucke@gmail.com)

ENV USER_NAME 'LineageOS GregFoobar'
ENV USER_MAIL 'LineageOS-GregFoobar@docker.host'

ENV SRC_DIR /srv/src
ENV CCACHE_DIR /srv/ccache
ENV ZIP_DIR /srv/zips
#ENV LMANIFEST_DIR /srv/local_manifests

ENV USE_CCACHE 1
ENV DEBUG true
ENV CLEAN_OUTDIR true
ENV CLEAN_AFTER_BUILD true

ENV CRONTAB_TIME '0 10 * * *'

VOLUME $SRC_DIR
VOLUME $CCACHE_DIR
VOLUME $ZIP_DIR
#VOLUME $LMANIFEST_DIR

RUN apt-get update && apt-get install -y \
    bc bison build-essential curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev \
    lib32readline-gplv2-dev lib32z1-dev libesd0-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev \
    libxml2 libxml2-utils lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev maven openjdk-7-jdk \
    cron

RUN mkdir -p $SRC_DIR
RUN mkdir -p $CCACHE_DIR
RUN mkdir -p $ZIP_DIR
#RUN mkdir -p $LMANIFEST_DIR

COPY src/* /root/

WORKDIR $SRC_DIR

RUN chmod 0755 /root/*


ENTRYPOINT /root/init.sh
