"""
Common fixtures for every tests.
"""
import pytest
from c2cwsgiutils.acceptance.composition import Composition
from c2cwsgiutils.acceptance.connection import Connection

from acceptance_tests import BASE_URL, PROJECT_NAME, wait_db, wait_qgisserver


@pytest.fixture(scope="session")
def composition(request):
    """
    Fixture that start/stop the Docker composition used for all the tests.
    """
    result = Composition(request, PROJECT_NAME, "docker-compose.yaml")
    wait_db()
    wait_qgisserver()
    return result


@pytest.fixture
def connection(composition):
    """
    Fixture that returns a connection to a running batch container.
    """
    return Connection(BASE_URL, "http://www.example.com/")
