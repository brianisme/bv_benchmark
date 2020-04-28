const fs = require('fs');
const x2j = require('rapidx2j');
const { performance } = require('perf_hooks');

const json = fs.readFileSync('fixtures/offers.json');
const xml = fs.readFileSync('fixtures/offers.xml', 'utf8');

function profile(fn) {
  const t0 = performance.now()
  const heap0 = process.memoryUsage().heapUsed
  fn()
  const heap1 = process.memoryUsage().heapUsed
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
  const offers = x2j.parse(xml, { preserve_case: true })['payload']['offers']
  transform(offers)
})


console.log('----------------------------------')
console.log('[JSON]')

profile(function() {
  let { payload: { offers } } = JSON.parse(json)
  transform(offers)
})