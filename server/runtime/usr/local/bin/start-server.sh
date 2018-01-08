#!/bin/bash
set -e

# save the environment to be able to restore it in the FCGI daemon (used
# in /usr/local/bin/qgis_mapsev_wrapper)
env | sed -e 's/^/export /' > /tmp/init_env.sh

trap 'echo "caught a SIGTERM"; kill -TERM $PID2; wait $PID2; kill -TERM $PID1; wait $PID1' TERM
trap '' WINCH

rm -f $APACHE_RUN_DIR/apache2.pid

(while true
do
    echo "Listening"
    cat /var/log/docker
done) &
PID1=$!

apache2 -DFOREGROUND &
PID2=$!
wait $PID2
