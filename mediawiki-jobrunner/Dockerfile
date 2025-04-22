FROM ghcr.io/sphiria/oci-images/mediawiki-fpm:v1.0.0

USER root

WORKDIR /var/www

COPY --chown=nobody:nobody --chmod=770 ./entrypoint.sh /var/www/jobrunner/entrypoint.sh

USER nobody

ENTRYPOINT ["/var/www/jobrunner/entrypoint.sh"]