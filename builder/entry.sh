#!/bin/bash
set -e

groupadd -r -g $GID builders
useradd -m builder -u $UID -g builders

exec gosu builder "$@"
