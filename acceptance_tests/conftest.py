"""
Common fixtures for every tests.
"""
import pytest
from c2cwsgiutils.acceptance.connection import Connection

from acceptance_tests import wait_db, wait_qgisserver


@pytest.fixture(scope="session")
def wait():
    """
    Fixture that start/stop the Docker composition used for all the tests.
    """
    wait_db()
    wait_qgisserver()
    return


@pytest.fixture
def connection(wait):
    """
    Fixture that returns a connection to a running batch container.
    """
    return Connection("http://qgis:8080/", "http://www.example.com/")
