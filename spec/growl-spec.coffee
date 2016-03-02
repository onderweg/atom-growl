GrowlyStub = require './fixtures/growly-stub.js'
GrowlForwarder = require "../lib/growl-forwarder.js"

describe 'The Growl API interface', ->

  growly = new GrowlyStub()
  forwarder = new GrowlForwarder(growly)

  disposables = []

  beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('atom-growl')

  afterEach ->
    for disposable in disposables
      disposable.dispose()

  it 'should forward to Growl',  ->
      growlResult = null

      spyOn(growly, 'register').andCallThrough();
      spyOn(growly, 'notify').andCallThrough();

      notification = {
          message: 'This is a test message',
          type: 'info',
          options: {}
      };
      waitsForPromise ->
          forwarder.forward(notification).then(
            (result) =>
              growlResult = result
            (err) =>
              throw err
          )

      runs ->
        # Promises resolves?
        expect(growlResult).toBe true
        # Count incremented?
        expect(forwarder.count).toBe 1
        # Growly calls
        expect(growly.register).toHaveBeenCalled();
        expect(growly.notify.mostRecentCall.args[1]).toEqual({
          title: notification.message,
          label: notification.type
        });
