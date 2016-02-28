{CompositeDisposable} = require 'atom'
_ = require "lodash"
HistoryView = require "./history-view"
StatusMessage = require './status-message'
Growl = require "./growl.js"

module.exports = AtomGrowl =

  activate: (state) ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-growl:push-test-message': => @testForward()
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-growl:show-history', =>
        @historyView ?= new HistoryView()
        @historyView.history = atom.notifications.getNotifications().reverse()
        @historyView.show()

    # Observe config values
    atom.config.observe 'atom-growl.showInStatusbar', (newValue) =>
      @statusMessage?.remove() if newValue == false

    @growl ?= new Growl();

    onMessage = (n) =>
      return unless atom.config.get('atom-growl.forwardToGrowl')
      @growl.forward(n).then(
        (result) =>
          @displayMessage({
              text: "✓ Growl (#{@growl.count})"
              type: "info",
              tooltip: "Growl forward count: #{@growl.count}"
            }, 60 * 1000) if atom.config.get('atom-growl.showInStatusbar')
        (err) =>
          @displayMessage({
            text: "Growl error",
            type: "error",
            tooltip: err
          }, 60 * 1000)
        )
    throttled = _.throttle onMessage, 400

    atom.notifications.onDidAddNotification throttled;

  deactivate: ->
    @subscriptions.dispose()

  testForward: ->
    atom.notifications.addInfo("Growl test title", {
      detail: "Growl test @ " + new Date(),
    });

  displayMessage: (message, timeout) ->
    clearTimeout(@timeout) if @timeout?
    if @statusMessage?
      @statusMessage.set(message)
    else
      @statusMessage = new StatusMessage(message)
      @statusMessage.onClick( (e) =>
        # Replay last
        @growl.forward atom.notifications.getNotifications().pop()
      )
    @setMessageTimeout(timeout) if timeout?

  # Internal: Sets a timeout to remove the status bar message.
  #
  # timeout - The {Number} of milliseconds until the message should be removed.
  setMessageTimeout: (timeout) ->
    clearTimeout(@timeout) if @timeout?
    @timeout = setTimeout(=>
      @statusMessage.remove()
      @statusMessage = null
    , timeout)
