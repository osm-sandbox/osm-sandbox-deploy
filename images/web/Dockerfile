FROM developmentseed/osmseed-web:1.0.0-dev.he1070f2
ENV workdir /var/www
COPY restore.sh $workdir/
CMD $workdir/restore.sh && $workdir/start.sh
