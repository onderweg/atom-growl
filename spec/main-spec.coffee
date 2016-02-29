{EditorView, WorkspaceView} = require 'atom'
AtomGrowl = require '../lib/main'

describe "Atom Growl", ->

  mainModule  = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('atom-growl').then (pkg) =>
        mainModule = pkg.mainModule

  describe "@activate()", ->
    
    it "observes config values and takes action", ->
      mainModule.statusMessage = {
        remove: () ->
      }
      spy = spyOn(mainModule.statusMessage, 'remove')
      atom.config.set "atom-growl.showInStatusbar", false
      expect(spy).toHaveBeenCalled()
