from c2cwsgiutils.acceptance.connection import CacheExpected


def test_langingpage(connection_landingpage):
    connection_landingpage.get_raw(
        "mapserv_proxy/qgis", cache_expected=CacheExpected.DONT_CARE
    )
    connection_landingpage.get_raw(
        "mapserv_proxy/qgis/", cache_expected=CacheExpected.DONT_CARE
    )
    connection_landingpage.get_raw(
        "mapserv_proxy/qgis/index.html", cache_expected=CacheExpected.DONT_CARE
    )
    connection_landingpage.get_raw(
        "mapserv_proxy/qgis/index.json", cache_expected=CacheExpected.DONT_CARE
    )
