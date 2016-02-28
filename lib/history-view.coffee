{SelectListView, $} = require 'atom-space-pen-views'

atom.themes.requireStylesheet(require.resolve('../styles/history.less'))

module.exports =
class HistoryView extends SelectListView

  getFilterKey: -> 'message'

  initialize: () ->
    super
    @history = []
    @panel = atom.workspace.addModalPanel(item: this, visible: false)
    @addClass('pusher-history-view')

  viewForItem: (item) ->
    "<li class='growl-history'>" +
      "<strong>#{item.message}</strong>" +
      "<div class='secondary-line'>" +
        "<span class='level #{item.type}'>#{item.type}</span>" +
      "</div>" +
    "</li>"

  confirmed: (item) ->
    atom.clipboard.write(item.message)

    typeName = item.type.charAt(0).toUpperCase() + item.type.slice(1)
    atom.notifications['add'+typeName](item.message, item.options);
    @cancel()

  populate: ->
    @setItems(@history)

  show: ->
    @populate()
    @panel.show()
    @focusFilterEditor()

  cancel: ->
    @panel.hide()
