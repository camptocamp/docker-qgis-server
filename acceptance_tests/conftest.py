"""
Common fixtures for every tests.
"""

import logging
import time

import psycopg2
import pytest
from c2cwsgiutils.acceptance import utils
from c2cwsgiutils.acceptance.connection import Connection

LOG = logging.getLogger(__name__)


@pytest.fixture(scope="session", autouse=True)
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


@pytest.fixture(scope="session", autouse=True)
def wait_qgisserver():
    utils.wait_url("http://qgis:8080")


@pytest.fixture(scope="session", autouse=True)
def wait_qgisserver_landing():
    utils.wait_url("http://qgis-landingpage:8080/mapserv_proxy/qgis")


@pytest.fixture
def connection():
    """
    Fixture that returns a connection to a running batch container.
    """
    return Connection("http://qgis:8080/", "http://www.example.com/")


@pytest.fixture
def connection_landingpage():
    """
    Fixture that returns a connection to a running batch container.
    """
    return Connection("http://qgis-landingpage:8080/", "http://www.example.com/")


@pytest.fixture
def connection_lighttpd():
    """
    Fixture that returns a connection to a running batch container.
    """
    return Connection("http://qgis-lighttpd:8080/", "http://www.example.com/")
