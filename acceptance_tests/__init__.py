from c2cwsgiutils.acceptance import utils
import logging
import psycopg2
import sys
import time


BASE_URL = 'http://' + utils.DOCKER_GATEWAY + ':8380/'
DB_ADDR = utils.DOCKER_GATEWAY
LOG = logging.getLogger(__name__)
PROJECT_NAME='qgis'


def wait_db():
    timeout = time.time() + 60.0

    conn_string = "host='%s' port='15432' dbname='test' user='www-data' password='www-data'" % DB_ADDR
    while True:
        try:
            LOG.info("Trying to connect to the DB... ")
            conn = psycopg2.connect(conn_string)
            conn.close()
            break
        except:
            assert time.time() <= timeout
            time.sleep(0.5)


def wait_mapserver():
    utils.wait_url(BASE_URL + '?SERVICE=WFS&VERSION=2.0.0&REQUEST=describeFeaturetype&TYPENAME=polygons')
