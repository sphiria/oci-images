FROM ghcr.io/sphiria/oci-images/mediawiki-fpm:v1.0.0

USER root

WORKDIR /var/www/

RUN git clone https://github.com/miraheze/jobrunner-service.git mediawiki-services-jobrunner

COPY --chown=nobody:nobody --chmod=770 ./entrypoint.sh /var/www/html/mediawiki-services-jobrunner/entrypoint.sh

USER nobody

ENTRYPOINT ["/var/www/html/mediawiki-services-jobrunner/entrypoint.sh"]