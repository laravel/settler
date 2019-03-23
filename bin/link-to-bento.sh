#!/usr/bin/env bash

SED=sed

uname -a | grep Darwin > /dev/null
if [ $? -eq 0 ]
then
  if [ -x "$(which gsed)" ]
  then
    SED=gsed
  else
    echo "On macOS this script requires GNU sed. Install it with 'brew install gnu-sed'."
    exit 1
  fi
fi

/bin/ln -f scripts/provision.sh ../bento/ubuntu/scripts/homestead.sh
/bin/ln -f http/preseed.cfg ../bento/ubuntu/http
/bin/ln -f http/preseed-hyperv.cfg ../bento/ubuntu/http

$SED -i 's/scripts\/cleanup.sh/scripts\/homestead.sh/' ../bento/ubuntu/ubuntu-18.04-amd64.json
