const { expect } = require('chai');
const { canPerformActionSince } = require('../index')._test;

describe('createQueue cooldown helper', () => {
  it('allows when lastTimestamp is null', () => {
    const now = Date.now();
    const res = canPerformActionSince(null, now, 60);
    expect(res.allowed).to.be.true;
    expect(res.remainingMs).to.equal(0);
  });

  it('disallows when within cooldown', () => {
    const now = Date.now();
    const last = now - 30 * 1000; // 30s ago
    const res = canPerformActionSince(last, now, 60);
    expect(res.allowed).to.be.false;
    expect(res.remainingMs).to.be.above(0);
  });

  it('allows when past cooldown', () => {
    const now = Date.now();
    const last = now - 90 * 1000; // 90s ago
    const res = canPerformActionSince(last, now, 60);
    expect(res.allowed).to.be.true;
    expect(res.remainingMs).to.equal(0);
  });
});