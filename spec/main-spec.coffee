{EditorView, WorkspaceView} = require 'atom'
AtomGrowl = require '../lib/main'

describe "Atom Growl", ->

  mainModule  = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('atom-growl').then (pkg) =>
        mainModule = pkg.mainModule

  describe "@activate()", ->

    it "observes showInStatusbar config value and takes action", ->
      mainModule.statusMessage = {
        remove: () ->
      }
      spy = spyOn(mainModule.statusMessage, 'remove')
      atom.config.set "atom-growl.showInStatusbar", false
      expect(spy).toHaveBeenCalled()

    it "observes enabledTypes config value and takes action", ->
      atom.config.set "atom-growl.enabledTypes", "error, warning"
      result = mainModule.onMessage({
          type: 'info'
        }, mainModule)
      expect(result).toBe false
      atom.config.set "atom-growl.enabledTypes", "error, info"
      result = mainModule.onMessage({
          type: 'info',
          options: {}
        }, mainModule)
      expect(result).not.toBe false
