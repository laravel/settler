#!/usr/bin/env bash -x
/bin/ln -f scripts/provision.sh ../bento/ubuntu/scripts/homestead.sh
/bin/ln -f http/preseed.cfg ../bento/ubuntu/http
/bin/ln -f http/preseed-hyperv.cfg ../bento/ubuntu/http

[ -x $(which gsed) ] && SED=gsed || SED=sed
$SED -i 's/scripts\/cleanup.sh/scripts\/homestead.sh/' ../bento/ubuntu/ubuntu-18.04-amd64.json
