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
else
    USER=root
fi

exec gosu $USER "$@"
