import logging
import time

import psycopg2
from c2cwsgiutils.acceptance import utils

LOG = logging.getLogger(__name__)


def wait_db():
    timeout = time.time() + 60.0

    conn_string = "host='db' port='5432' dbname='test' user='www-data' password='www-data'"
    while True:
        try:
            LOG.info("Trying to connect to the DB... ")
            conn = psycopg2.connect(conn_string)
            conn.close()
            break
        except:
            assert time.time() <= timeout
            time.sleep(0.5)


def wait_qgisserver():
    utils.wait_url("http://qgis:8080?SERVICE=WFS&VERSION=2.0.0&REQUEST=describeFeaturetype&TYPENAME=polygons")
