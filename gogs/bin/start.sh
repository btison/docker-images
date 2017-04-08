#!/bin/sh -

export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/etc/passwd
export NSS_WRAPPER_GROUP=/etc/group

PATH=/bin:/usr/bin:/usr/local/bin
HOME=${HOME:?"need \$HOME variable"}
USER=$(whoami)
export USER HOME PATH

if [ ! -d "${HOME}/git" ]; then
  mkdir ${HOME}/git
fi

cd "$(dirname $0)"

(
  mkdir -p ${HOME}/ssh/ || true
  cd ${HOME}/ssh/
  /opt/gogs/ssh-hostkeygen
)

export GOGS_RUN_USER=${USER:-git}

exec ./start-gogs