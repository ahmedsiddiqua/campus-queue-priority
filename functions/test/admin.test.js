const { expect } = require('chai');
const sinon = require('sinon');
const admin = require('firebase-admin');

const { isAdminUid } = require('../index')._test;

describe('admin helpers', () => {
  let sandbox;
  beforeEach(() => {
    sandbox = sinon.createSandbox();
  });
  afterEach(() => {
    sandbox.restore();
  });

  it('isAdminUid returns true when users doc has role admin', async () => {
    const fakeDoc = { exists: true, data: () => ({ role: 'admin' }) };
    sandbox.stub(admin.firestore.Firestore.prototype, 'collection').returns({ doc: () => ({ get: () => Promise.resolve(fakeDoc) }) });

    const res = await isAdminUid('someuid');
    expect(res).to.be.true;
  });

  it('isAdminUid returns false when no user doc', async () => {
    const fakeDoc = { exists: false };
    sandbox.stub(admin.firestore.Firestore.prototype, 'collection').returns({ doc: () => ({ get: () => Promise.resolve(fakeDoc) }) });
    const res = await isAdminUid('nouid');
    expect(res).to.be.false;
  });
});