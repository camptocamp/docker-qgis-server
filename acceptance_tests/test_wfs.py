from c2cwsgiutils.acceptance.connection import CacheExpected
from xml.etree import ElementTree


def test_get_feature(connection):
    answer = connection.get_xml('?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&TYPENAME=polygons',
                                cache_expected=CacheExpected.DONT_CARE)
    ns = '{http://www.qgis.org/gml}'
    features = answer.findall(".//%spolygons" % ns)
    assert len(features) == 1, ElementTree.dump(answer)
    assert [e.text for e in answer.findall(".//%spolygons/%sname" % (ns, ns))] == ['foo']
