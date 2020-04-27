require 'active_support/core_ext/hash/conversions'
require 'ruby-prof'
require 'nokogiri'
require 'json'

json = File.read('fixtures/offers.json')
xml = File.read('fixtures/offers.xml')

def profile(mode = RubyProf::WALL_TIME)
  RubyProf.measure_mode = mode
  RubyProf.start

  yield

  result = RubyProf.stop
  pretty = RubyProf::FlatPrinter.new(result)
  pretty.print(STDOUT)
end

def transform(offers)
  offers.map do |o|
    {
      id: o["id"],
      name: o["name"],
      price: o.dig("shortTermPrice", "amount") || o.dig("longTermPrice", "amount"),
      promotion: o["promotions"],
      highlight: o["highlights"],
      provider: o["provider"]["name"]
    }
  end
end

puts '------------------------------------------------------------'
puts '[JSON]'
profile do
  offers = JSON.parse(json)["payload"]["offers"]
  transform(offers)
end

puts '------------------------------------------------------------'
puts '[JSON]'
profile(RubyProf::MEMORY) do
  offers = JSON.parse(json)["payload"]["offers"]
  transform(offers)
end

puts '------------------------------------------------------------'
puts '[XML]'
profile do
  offers = Hash.from_xml(xml)["root"]["payload"]["offers"]
  transform(offers)
end

puts '------------------------------------------------------------'
puts '[XML]'
profile(RubyProf::MEMORY) do
  offers = Hash.from_xml(xml)["root"]["payload"]["offers"]
  transform(offers)
end

