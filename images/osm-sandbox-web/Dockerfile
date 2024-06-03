FROM developmentseed/osmseed-web:1.0.0-dev.he1070f2
ENV workdir /var/www
COPY login.js $workdir/app/assets/javascripts/login.js
RUN rails i18n:js:export assets:precompile
COPY pre_start.sh $workdir/
CMD $workdir/pre_start.sh && $workdir/start.sh
