{CompositeDisposable} = require 'atom'
_ = require "lodash"
shell = require('shell');
HistoryView = require "./history-view"
StatusMessage = require './status-message'
Growl = require "./growl.js"

module.exports = AtomGrowl =

  activate: (state) ->
    @growl ?= new Growl();

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-growl:push-test-message': => @testForward()
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-growl:show-history', =>
        @historyView ?= new HistoryView()
        @historyView.history = atom.notifications.getNotifications().reverse()
        @historyView.show()

    # @TODO: Figure out why @ is empty when calling @onmessage this way.
    # as a workaround: pass @ as argument
    @subscriptions.add atom.notifications.onDidAddNotification (n) => @onMessage(n, @);

    # Observe config values
    atom.config.observe 'atom-growl.showInStatusbar', (newValue) =>
      @statusMessage?.remove() if newValue == false

  deactivate: ->
    @subscriptions.dispose()

  onMessage: (n, self) =>
    return false if atom.config.get('atom-growl.enabledTypes')
      .replace(/\s/g, '')
      .split(',')
      .indexOf(n.type) == -1

    opts = {};
    if n.options.buttons and n.options.buttons.length > 0
      opts = {
        'onClick': n.options.buttons[0].onDidClick
      }

    self.growl.forward(n, opts).then(
      (result) =>
        self.displayMessage({
            text: "✓ Growl (#{self.growl.count})"
            type: "info",
            tooltip: "Growl forward count: #{self.growl.count}"
          }, 60 * 1000) if atom.config.get('atom-growl.showInStatusbar')
      (err) =>
        self.displayMessage({
          text: "Growl error",
          type: "error",
          tooltip: err
        }, 60 * 1000)
    )

  testForward: ->
    atom.notifications.addInfo("Growl test title", {
      description: "Growl test @ #{new Date()}",
      buttons: [{
        text: 'More'
        className: 'btn-one'
        onDidClick: -> shell.openExternal("https://www.atom.io");
      }]
    })

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
