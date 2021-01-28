# Docker image for QGIS server

## Usage

Expects a `project.qgs` project file and all the files it depends on in the `/etc/qgisserver/`
directory. Either you create another image to add those files or you inject them using
a volume. For example:

```bash
docker run --detach --publish=8380:80 --volume=$PWD/etc/qgisserver:/etc/qgisserver camptocamp/qgis-server
```

With the previous command, you'll get to your server with this URL:
http://localhost:8380/?SERVICE=WMS&REQUEST=GetCapabilities

## Tuning

You can use the following variables (`-e` option in `docker run`):

-   `QGIS_SERVER_LOG_LEVEL`: The debug level for the logs (`0`=max debug, `3`=no debug logs)
-   `PGSERVICEFILE`: If you want to change the default of `/etc/qgisserver/pg_service.conf`
-   `QGIS_PROJECT_FILE`: If you want to change the default of `/etc/qgisserver/project.qgs`
-   `QGIS_CATCH_SEGV`: Set to `1` if you want stacktraces in the logs in case of segmentation faults.
-   `FCGID_MAX_REQUESTS_PER_PROCESS`: The number of requests a QGIS server will serve before being restarted by apache
-   `FCGID_MIN_PROCESSES`: The minimum number of fcgi processes to keep (defaults to `1`)
-   `FCGID_MAX_PROCESSES`: The maximum number of fcgi processes to keep (defaults to `5`)
-   `FCGID_IO_TIMEOUT`: This is the maximum period of time the module will wait while trying to read from or
    write to a FastCGI application (default to `40`)
-   `FCGID_BUSY_TIMEOUT`: The maximum time limit for request handling (defaults to `300`)
-   `FCGID_IDLE_TIMEOUT`: Application processes which have not handled a request for
    this period of time will be terminated (defaults to `300`)

[See also QGIS server documentation](https://docs.qgis.org/3.16/en/docs/server_manual/config.html?highlight=environment#environment-variables)

Fonts present in the `/etc/qgisserver/fonts` directory will be installed and thus usable by QGIS.

## Running the client

If you want to edit a project file, you can run the client from a Linux machine with the following command:

```bash
docker run --rm -ti --env=DISPLAY=unix${DISPLAY} --volume=/tmp/.X11-unix:/tmp/.X11-unix --volume=${HOME}:${HOME} camptocamp/qgis-server:master-desktop
```
