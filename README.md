[![Build Status](https://ci.lb.infra.caas-camptocamp.net/buildStatus/icon?job=docker-images/docker-qgis-server/master)](https://ci.lb.infra.caas-camptocamp.net/job/docker-images/job/docker-qgis-server/job/master/)

# Docker image for QGIS server

## Usage

Expects a `project.qgs` project file and all the files it depends on in the `/project/`
directory. Either you create another image to add those files or you inject them using
a volume. For example:

```bash
docker run -d -p 8380:80 --volume=$PWD/project:/project camptocamp/qgis-server
```
With the previous command, you'll get to your server with this URL:
http://localhost:8380/?SERVICE=WMS&REQUEST=GetCapabilities

## Tunning

You can use the following variables (`-e` option in `docker run`):

* QGIS_SERVER_LOG_LEVEL: The debug level for the logs (0=max debug, 3=no debug logs)
* QGIS_SERVER_LOG_FILE: To output the logs to a file (default to stdout)
* PGSERVICEFILE: If you want to change the default of `/project/pg_service.conf`
* QGIS_PROJECT_FILE: If you want to change the default of `/project/project.qgs`

## Running the client

If you want to edit a project file, you can run the client with the following command:
```bash
make run-client
```
