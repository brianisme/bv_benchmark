const memwatch = require('@airbnb/node-memwatch');
const fs = require('fs');
const { parseString } = require('xml2js');
const { performance } = require('perf_hooks');

const json = fs.readFileSync('fixtures/offers.json');
const xml = fs.readFileSync('fixtures/offers.xml', 'utf8');

function profile(fn) {
  const t0 = performance.now()
  const heap0 = process.memoryUsage().heapTotal
  fn()
  const heap1 = process.memoryUsage().heapTotal
  const t1 = performance.now()
  console.log('Time used:', t1 - t0);
  console.log('Memory used:', (((heap1 - heap0)  / 1024) / 1024));
}

function transform(offers) {
  return offers.map(function(o){
    return {
      id: o.id,
      name: o.name,
      price: o.shortTermPrice ? o.shortTermPrice.amount : o.longTermPrice.amount,
      promotion: o.promotions,
      highlight: o.highlights,
      provider: o.provider.name
    }
  })
}


console.log('----------------------------------')
console.log('[XML]')

profile(function() {
  parseString(xml, function(_err, { root: { payload }}){
    transform(payload[0].offers)
    console.log('transformed')
  })
})


console.log('----------------------------------')
console.log('[JSON]')

profile(function() {
  let { payload: { offers } } = JSON.parse(json)
  transform(offers)
})