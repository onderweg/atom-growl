# Public: Displays a message in the status bar.
module.exports =
class StatusMessage
  # Public: Displays `message` in the status bar.
  #
  # If the status bar does not exist for whatever reason, no message is displayed and no error
  # occurs.
  #
  # message - A {String} containing the message to display.
  constructor: (message) ->
    #@statusBar = atom.workspaceView?.statusBar
    @statusBar = document.querySelector('status-bar')
    if @statusBar
      @item = document.createElement('div')
      @item.classList.add('inline-block')      
      @set(message)
      @tile = @statusBar.addRightTile({@item})

  # Public: Removes the message from the status bar.
  remove: ->
    @tile?.destroy()

  # Public: Updates the text of the message.
  #
  # text - A {String} containing the new message to display.
  set: (message) ->
    if @statusBar
      @item.setAttribute('data-type', (message.type || 'info'))
      @item.innerHTML = message.text
      @item.title = message.tooltip || ""

  onClick: (event) ->
    @item.addEventListener('click', event)
