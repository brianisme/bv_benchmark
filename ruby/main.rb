require 'active_support/core_ext/hash/conversions'
require 'ruby-prof'
require 'nokogiri'
require 'memory_profiler'
require 'json'
require 'oj'
require 'ox'

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
      id: o['id'],
      name: o['name'],
      price:
        o.dig('shortTermPrice', 'amount') || o.dig('longTermPrice', 'amount'),
      promotion: o['promotions'],
      highlight: o['highlights'],
      provider: o['provider']['name']
    }
  end
end

def transform_symbol(offers)
  offers.map do |o|
    {
      id: o[:id],
      name: o[:name],
      price: o.dig(:shortTermPrice, :amount) || o.dig(:longTermPrice, :amount),
      promotion: o[:promotions],
      highlight: o[:highlights],
      provider: o[:provider][:name]
    }
  end
end

puts '------------------------------------------------------------'
puts '[JSON]'
profile do
  offers = JSON.parse(json)['payload']['offers']
  transform(offers)
end

puts '------------------------------------------------------------'
puts '[JSON]'
MemoryProfiler.start
offers = JSON.parse(json)['payload']['offers']
transform(offers)
report = MemoryProfiler.stop
report.pretty_print

puts '------------------------------------------------------------'
puts '[Oj]'
profile do
  offers = Oj.load(json)
  transform(offers['payload']['offers'])
end

puts '------------------------------------------------------------'
puts '[Oj]'
MemoryProfiler.start
offers = Oj.load(json)
transform(offers['payload']['offers'])
report = MemoryProfiler.stop
report.pretty_print

puts '------------------------------------------------------------'
puts '[Nokogiri]'
profile do
  offers = Nokogiri::XML.parse(File.open('fixtures/offers.xml'))
  ok =
    offers.xpath('//offers').map do |offer|
      {
        id: offer.at_xpath('id').text,
        name: offer.at_xpath('name').text,
        price:
          offer.at_css('shortTermPrice amount')&.text ||
            offer.at_css('longTermPrice amount')&.text
      }
    end
  ok
end

puts '------------------------------------------------------------'
puts '[Nokogiri]'
MemoryProfiler.start
offers = Nokogiri::XML.parse(File.open('fixtures/offers.xml'))
ok =
  offers.xpath('//offers').map do |offer|
    {
      id: offer.at_xpath('id').text,
      name: offer.at_xpath('name').text,
      price:
        offer.at_css('shortTermPrice amount')&.text ||
          offer.at_css('longTermPrice amount')&.text
    }
  end
ok
report = MemoryProfiler.stop
report.pretty_print

puts '------------------------------------------------------------'
puts '[ox]'
profile do
  doc = Ox.load(xml, mode: :hash)
  transform_symbol(doc[:root][:payload][:offers])
end

puts '------------------------------------------------------------'
puts '[ox]'
MemoryProfiler.start
doc = Ox.load(xml, mode: :hash)
transform_symbol(doc[:root][:payload][:offers])
report = MemoryProfiler.stop
report.pretty_print
