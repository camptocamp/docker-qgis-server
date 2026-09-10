from c2cwsgiutils.acceptance.connection import CacheExpected


def _hrefs(answer):
    return [link["href"] for link in answer["links"]]


def test_ogcapi_landing(connection):
    answer = connection.get_json("ogcapi/?f=json", cache_expected=CacheExpected.DONT_CARE)
    hrefs = _hrefs(answer)
    assert hrefs, answer
    for href in hrefs:
        assert href.startswith("http://qgis:8080/"), href


def test_ogcapi_landing_forwarded_headers(connection):
    # QGIS Server builds the request URL (used in the OGC API links) from the Host header
    # and the HTTPS environment variable, the front server sets HTTPS from X-Forwarded-Proto.
    answer = connection.get_json(
        "ogcapi/?f=json",
        headers={"X-Forwarded-Proto": "https", "Host": "www.example.com"},
        cache_expected=CacheExpected.DONT_CARE,
    )
    hrefs = _hrefs(answer)
    assert hrefs, answer
    for href in hrefs:
        assert href.startswith("https://www.example.com"), href


def test_ogcapi_landing_forwarded_headers_lighttpd(connection_lighttpd):
    answer = connection_lighttpd.get_json(
        "ogcapi/?f=json",
        headers={"X-Forwarded-Proto": "https", "Host": "www.example.com"},
        cors=False,
        cache_expected=CacheExpected.DONT_CARE,
    )
    hrefs = _hrefs(answer)
    assert hrefs, answer
    for href in hrefs:
        assert href.startswith("https://www.example.com"), href
