"""
Common fixtures for every tests.
"""
from c2cwsgiutils.acceptance.composition import Composition
from c2cwsgiutils.acceptance.connection import Connection
import pytest

from acceptance_tests import BASE_URL, PROJECT_NAME, wait_db, wait_mapserver


@pytest.fixture(scope="session")
def composition(request):
    """
    Fixture that start/stop the Docker composition used for all the tests.
    """
    result = Composition(request, PROJECT_NAME, "docker-compose.yml")
    wait_db()
    wait_mapserver()
    return result


@pytest.fixture
def connection(composition):
    """
    Fixture that returns a connection to a running batch container.
    """
    return Connection(BASE_URL, 'http://www.example.com/')
