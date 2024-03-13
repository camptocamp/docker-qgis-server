# Docker image for QGIS server

## Usage

The Docker container needs to have access to all files of the QGIS project to be published.
Either you create another image to add the files or you inject them using a volume.
For example, if your QGIS project is stored in `./qgis/project.qgz`:

```bash
docker run --detach --publish=8380:80 --volume=${PWD}/qgis:/etc/qgisserver camptocamp/qgis-server
```

With the previous command, you'll get to your server with this URL:
http://localhost:8380/?MAP=/etc/qgisserver/project.qgz&SERVICE=WMS&REQUEST=GetCapabilities

## Tuning

You can use the following variables (`-e` option in `docker run`):

- `QGIS_CATCH_SEGV`: Set to `1` if you want stacktraces in the logs in case of segmentation faults by running `tail -f /var/log/qgis.log` in the container
- `FCGID_MAX_REQUESTS_PER_PROCESS`: The number of requests a QGIS server will serve before being restarted by apache
- `FCGID_MIN_PROCESSES`: The minimum number of fcgi processes to keep (defaults to `1`)
- `FCGID_MAX_PROCESSES`: The maximum number of fcgi processes to keep (defaults to `5`)
- `FCGID_IO_TIMEOUT`: This is the maximum period of time the module will wait while trying to read from or
  write to a FastCGI application (default is `40`)
- `FCGID_BUSY_TIMEOUT`: The maximum time limit for request handling (defaults to `300`)
- `FCGID_IDLE_TIMEOUT`: Application processes which have not handled a request for
  this period of time will be terminated (defaults to `300`)
- `FILTER_ENV`: Filter the environment variables with e.g.:
  `| grep -vi _SERVICE_ | grep -vi _TCP | grep -vi _UDP | grep -vi _PORT` to remove the default
  Kubernetes environment variables (default in an empty string)
- `GET_ENV`: alternative to `FILTER_ENV`, a command that return the environment variables (defaults to `env`)

[See also QGIS server documentation](https://docs.qgis.org/latest/en/docs/server_manual/config.html?highlight=environment#environment-variables)

Fonts present in the `/etc/qgisserver/fonts` directory will be installed and thus usable by QGIS.

## Get a stack trace in case of segfault

Open a bash as root on the container with something like: `docker-compose exec --user=root qgisserver bash`, then:

```bash
apt-get update
apt-get install --assume-yes gdb
CORE_FILENAME=$(ls -tr1 /tmp/|grep core|tail -n 1)
gdb /usr/local/bin/qgis_mapserv.fcgi /tmp/${CORE_FILENAME}
```

Then press `<enter>`, the `bt` command will give you the stack trace.

If you can't be root in the container:

```bash
CONTAINER=<container>
CORE_FILENAME=$(docker exec ${CONTAINER} ls -tr1 /tmp/|grep core|tail -n 1)
docker cp ${CONTAINER}:/tmp/${CORE_FILENAME} ./core

docker run --rm -ti --volume=$(pwd):/core --entrypoint= camptocamp/qgis-server:<tag> bash
```

In the new shell:

```bash
apt-get update
apt-get install --assume-yes gdb
gdb /usr/local/bin/qgis_mapserv.fcgi /core/core
```

Then press `<enter>`, the `bt` command will give you the stack trace.

## Running the client

If you want to edit a project file, you can run the client from a Linux machine with the following command:

```bash
docker run --rm -ti --env=DISPLAY=unix${DISPLAY} --volume=/tmp/.X11-unix:/tmp/.X11-unix --volume=${HOME}:${HOME} camptocamp/qgis-server:master-desktop
```

## Changelog

### QGIS 3.22

We removed the default values for the following environment variables to better fit with the QGIS documentation:

- `QGIS_SERVER_LOG_LEVEL`, was `0`
- `QGIS_PROJECT_FILE`, was `/etc/qgisserver/project.qgs`
- `MAX_CACHE_LAYERS`, was `""`
- `QGIS_AUTH_DB_DIR_PATH`, was `/etc/qgisserver/`
- `PGSERVICEFILE`, was `/etc/qgisserver/pg_service.conf`

## Contributing

Install the pre-commit hooks:

```bash
pip install pre-commit
pre-commit install --allow-missing-config
```
