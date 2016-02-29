GrowlStub = require './fixtures/growl-stub.js'

describe 'The Growl API interface', ->

  growl = {}
  disposables = []

  beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('atom-growl')

      growl = new GrowlStub

  afterEach ->
    for disposable in disposables
      disposable.dispose()

  it 'should forward to Growl',  ->
      growlResult = null
      waitsForPromise ->
          growl.forward({
              message: 'This is a test message',
              type: 'info'
          }).then(
            (result) =>
              growlResult = result
            (err) =>
              throw err
          )

      runs ->
        # Promises resolves?
        expect(growlResult).toBe true
        # Count incremented?
        expect(growl.count).toBe 1
