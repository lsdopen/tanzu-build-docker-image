FROM ubuntu:22.10
RUN apt update
RUN apt install docker.io -y
USER 1000
