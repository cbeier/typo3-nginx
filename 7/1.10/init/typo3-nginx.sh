#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

chown www-data:www-data "${WODBY_DIR_FILES}"

gotpl /etc/gotpl/typo3.conf.tpl > /etc/nginx/conf.d/typo3.conf
