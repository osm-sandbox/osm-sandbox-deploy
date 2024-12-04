FROM developmentseed/osmseed-web:1.0.0-dev.h686c7c0
ENV workdir /var/www
COPY login.js $workdir/app/assets/javascripts/login.js
RUN rails i18n:js:export assets:precompile
ADD config/settings.yml $workdir/config/
COPY pre_start.sh $workdir/
CMD $workdir/pre_start.sh && $workdir/start.sh
