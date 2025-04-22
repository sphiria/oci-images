#!/bin/sh

if [ "${RUNNER_TYPE:-job}" = "Chron" ]; then
   php83 /var/www/html/mediawiki-services-jobrunner/redisJobChronService --config-file=/var/www/html/mediawiki-services-jobrunner/jobrunner-conf.json
else
   php83 /var/www/html/mediawiki-services-jobrunner/redisJobRunnerService --config-file=/var/www/html/mediawiki-services-jobrunner/jobrunner-conf.json
fi