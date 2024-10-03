FROM debian:bookworm-slim
ENV workdir /mnt/data
WORKDIR $workdir

VOLUME /mnt/data
COPY ./start.sh /
CMD /start.sh
