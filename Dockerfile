FROM alpine:latest
RUN apk update && apk add iproute2 iputils-ping curl iptables kmod python3

WORKDIR /project/script
COPY ./script /project/script 
RUN chmod -R +x /project/script
