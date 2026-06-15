const { calcEndOfService } = require('./calculator.js');

let passed = 0, failed = 0;
function assert(label, got, expected) {
  const ok = Math.abs(got - expected) < 0.01;
  if (ok) { console.log(`  ✅ ${label}`); passed++; }
  else     { console.error(`  ❌ ${label} — got ${got.toFixed(2)}, expected ${expected}`); failed++; }
}
function calc(s, y, m, r) { return calcEndOfService(s, y, m, r).result; }

console.log('calculator.js — 8 test cases (verified vs lib/main.dart:175-203)');

assert('<2y resignation → 0',           calc(5000,  1, 0, 'resignation'), 0);
assert('4y resignation → 3333.33',      calc(5000,  4, 0, 'resignation'), 10000 / 3);
assert('7y resignation → 24000',        calc(8000,  7, 0, 'resignation'), 24000);
assert('7y termination → 36000',        calc(8000,  7, 0, 'termination'), 36000);
assert('2y exact resignation → 2000',   calc(6000,  2, 0, 'resignation'), 2000);
assert('5y exact resignation → 10000',  calc(6000,  5, 0, 'resignation'), 10000);
assert('10y exact resignation → 45000', calc(6000, 10, 0, 'resignation'), 45000);
assert('6mo resignation → 0',           calc(6000,  0, 6, 'resignation'), 0);

console.log(`\n${passed}/${passed + failed} passed`);
if (failed > 0) process.exit(1);
