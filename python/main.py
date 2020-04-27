import json
import time

import xmltodict
from memory_profiler import profile

def load_json(file):
  return json.load(file)

def transform(offers):
  return map(lambda o: {
    'id': o['id'],
    'name': o['name'],
    'price': o['shortTermPrice']['amount'] if o.get('shortTermPrice') else o['longTermPrice']['amount'],
    'promotion': o.get('promotions'),
    'highlight': o['highlights'],
    'provider': o['provider'].get('name')
  }, offers)

@profile
def parse_json(file):
  offers = load_json(file)['payload']['offers']
  return transform(offers)

@profile
def parse_xml(file):
  offers = xmltodict.parse(file)['root']['payload']['offers']
  return transform(offers)


def json_profile():
  with open('fixtures/offers.json') as json_file:
    start_time = time.time()

    transformedOffers = parse_json(json_file)
    print("--- %s seconds ---" % (time.time() - start_time))

def xml_profile():
  with open('fixtures/offers.xml') as xml_file:
    start_time = time.time()

    transformedOffers = parse_xml(xml_file)
    print(transformedOffers[0])
    print("--- %s seconds ---" % (time.time() - start_time))




if __name__ == '__main__':
    json_profile()
    xml_profile()