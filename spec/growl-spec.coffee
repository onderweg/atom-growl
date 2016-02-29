GrowlStub = require './fixtures/growl-stub.js'

growl = new GrowlStub

describe 'The Growl API interface', ->

  disposables = []

  beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('atom-growl')

      growl = new GrowlStub

  afterEach ->
    for disposable in disposables
      disposable.dispose()

  it 'should forward to Growl', (done) ->

    growl.forward({
        message: 'This is a test message',
        type: 'info'
    }).then(
      (result) =>
        # Promises resolves?
        expect(result).toBe true
        # Count incremented?
        expect(growl.count).toBe 1
        done()
      (err) =>
        throw err
    )
