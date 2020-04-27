import json
import time

from lxml import etree
from memory_profiler import profile

def recursive_dict(element):
   return element.tag, \
          dict(map(recursive_dict, element)) or element.text

def load_json(file):
  return json.load(file)

def transform(offers):
  return map(lambda o: {
    'id': o['id'],
    'name': o['name'],
    'price': o['shortTermPrice']['amount'] if o.get('shortTermPrice') else o['longTermPrice']['amount'],
    'promotion': o.get('promotions'),
    'highlight': o['highlights'],
    'provider': o['provider'].get('value')
  }, offers)

def transform_xml(offers):
  return map(lambda o: {
    'id': o.xpath('id')[0].text,
    'name': o.xpath('name')[0].text,
    'price': o.xpath('shortTermPrice/amount')[0].text if len(o.xpath('shortTermPrice')) else o.xpath('longTermPrice/amount')[0].text,
    'promotion': recursive_dict(o.xpath('promotions')[0]) if len(o.xpath('promotions')) else None,
    'highlight': recursive_dict(o.xpath('highlights')[0]),
    'provider': o.xpath('provider/value')[0].text
  }, offers)

@profile
def parse_json(file):
  offers = load_json(file)['payload']['offers']
  return transform(offers)

@profile
def parse_xml(str):
  root = etree.XML(str)
  offers = root.xpath('payload/offers')
  return transform_xml(offers)


def json_profile():
  with open('fixtures/offers.json') as json_file:
    start_time = time.time()

    transformedOffers = parse_json(json_file)
    print("--- %s seconds ---" % (time.time() - start_time))

def xml_profile():
  with open('fixtures/offers.xml') as xml_file:
    start_time = time.time()

    transformedOffers = parse_xml(xml_file.read())
    print(transformedOffers[0])
    print("--- %s seconds ---" % (time.time() - start_time))




if __name__ == '__main__':
    json_profile()
    xml_profile()