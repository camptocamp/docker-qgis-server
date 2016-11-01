#!/bin/bash
set -e

if [ "$GID" != "0" ]
then
    groupadd -r -g $GID builders
    GROUP=builders
else
    GROUP=root
fi

if [ "$UID" != "0" ]
then
    useradd -m builder -u $UID -g $GROUP
    USER=builder
    chown builder: /home/builder/.ccache
else
    USER=root
fi

export PATH=/usr/lib/ccache:$PATH
export QT_SELECT=5

exec gosu $USER "$@"
