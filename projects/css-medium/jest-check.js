// jest-check.js <jest-json> <list> ...: every line of the lists ("<test file> :: <full test name>") must be a passed test in the
// Jest JSON report of the run.
const fs = require('fs');
const path = require('path');
const [, , report, ...lists] = process.argv;
const status = new Map();
for (const file of JSON.parse(fs.readFileSync(report, 'utf8')).testResults) {
  for (const a of file.assertionResults) status.set(path.relative(process.cwd(), file.name) + ' :: ' + a.fullName, a.status);
}
const bad = [];
for (const l of lists) {
  for (const line of fs.readFileSync(l, 'utf8').split('\n').filter(Boolean)) {
    if (status.get(line) !== 'passed') bad.push(line + ' [' + (status.get(line) || 'did not run') + ']');
  }
}
if (bad.length) { console.log('grade: not passing:\n' + bad.join('\n')); process.exit(1); }
console.log('grade: ok');
