StatusMessage = require '../lib/status-message.coffee'

describe 'Status message', ->
  [statusMessage, statusBarService, workspaceElement] = []

  beforeEach ->
    jasmine.attachToDOM atom.views.getView atom.workspace
    workspaceElement = atom.views.getView(atom.workspace)

    atom.packages.activatePackage('status-bar').then (pack) ->
      statusBarService = pack.mainModule.provideStatusBar()

    waitsForPromise ->
      atom.packages.activatePackage 'status-bar'
      atom.packages.activatePackage 'atom-growl'

    runs ->
      statusMessage = new StatusMessage({
          type: 'info'
      })

  afterEach ->
    statusMessage.remove()

  it 'should render status message', ->
    messageText = "test message"
    statusMessage.set({
        text: messageText
    })
    # Check if tiled is rendered
    expect(statusBarService.getRightTiles()).toContain(statusMessage.tile)
    expect(statusBarService.getLeftTiles()).not.toContain(statusMessage.tile)
    # Check tile content
    statusBarService.getRightTiles().forEach (tile) ->
      expect(tile.item.innerHTML).toEqual(messageText) if tile == statusMessage.tile

  it 'should remove status message', ->
    expect(statusBarService.getRightTiles()).toContain(statusMessage.tile)
    statusMessage.remove();
    expect(statusBarService.getRightTiles()).not.toContain(statusMessage.tile)

  it 'should handle click',  ->
    clickSpy = jasmine.createSpy()
    statusMessage.onClick clickSpy
    statusMessage.item.click()
    waitsFor ->
       clickSpy.callCount > 0
    runs ->
      expect(clickSpy).toHaveBeenCalled()
