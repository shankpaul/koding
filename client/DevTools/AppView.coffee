class DevToolsMainView extends KDView

  COFFEE = "//cdnjs.cloudflare.com/ajax/libs/coffee-script/1.6.3/coffee-script.min.js"

  constructor:->
    super

    @storage = KD.singletons.localStorageController.storage "DevTools"
    @liveMode = @storage.getAt 'liveMode'

  getToggleLiveReloadMenuView: (item, menu)->

    itemLabel = "#{if @liveMode then 'Disable' else 'Enable'} live compile"

    toggleLiveReload = new KDView
      partial : "<span>#{itemLabel}</span>"
      click   : =>
        @toggleLiveReload()
        menu.contextMenu.destroy()

    toggleLiveReload.on "viewAppended", ->
      toggleLiveReload.parent.setClass "default"

  getToggleFullscreenMenuView: (item, menu)->
    labels = [
      "Enter Fullscreen"
      "Exit Fullscreen"
    ]
    mainView = KD.getSingleton "mainView"
    state    = mainView.isFullscreen() or 0
    toggleFullscreen = new KDView
      partial : "<span>#{labels[Number state]}</span>"
      click   : =>
        mainView.toggleFullscreen()
        menu.contextMenu.destroy()

    toggleFullscreen.on "viewAppended", ->
      toggleFullscreen.parent.setClass "default"


  viewAppended:->

    @addSubView @workspace      = new CollaborativeWorkspace
      name                      : "Koding DevTools"
      delegate                  : this
      firebaseInstance          : "tw-local"
      panels                    : [
        title                   : "Koding DevTools"
        layout                  :
          direction             : "vertical"
          sizes                 : [ "264px", null ]
          splitName             : "BaseSplit"
          views                 : [
            {
              type              : "finder"
              name              : "finder"
              editor            : "JSEditor"
              handleFileOpen    : (file, content) =>

                {CSSEditor, JSEditor} = @workspace.activePanel.panesByName

                switch FSItem.getFileExtension file.path
                  when 'css', 'styl'
                  then editor = CSSEditor
                  else editor = JSEditor

                editor.openFile file, content
            }
            {
              type              : "split"
              options           :
                direction       : "vertical"
                sizes           : [ "50%", "50%" ]
                splitName       : "InnerSplit"
                cssClass        : "inner-split"
              views             : [
                {
                  type          : "split"
                  options       :
                    direction   : "horizontal"
                    sizes       : [ "50%", "50%" ]
                    splitName   : "EditorSplit"
                    cssClass    : "editor-split"
                  views         : [
                    {
                      type      : "custom"
                      name      : "JSEditor"
                      paneClass : DevToolsEditorPane
                      title     : "JavaScript"
                      # buttons : [
                      #   {
                      #     itemClass: KDOnOffSwitch
                      #     callback: ->
                      #       log arguments
                      #   }
                      # ]
                    }
                    {
                      type      : "custom"
                      name      : "CSSEditor"
                      title     : "Style"
                      paneClass : DevToolsCssEditorPane
                    }
                  ]
                }
                {
                  type          : "custom"
                  name          : "PreviewPane"
                  title         : "Preview"
                  paneClass     : CollaborativePane
                }
              ]
            }
          ]
      ]

    @workspace.ready =>


      {JSEditor, CSSEditor} = panes = @workspace.activePanel.panesByName

      KD.singletons.vmController.ready =>

        JSEditor.ready =>

          JSEditor.loadLastOpenFile()
          JSEditor.codeMirrorEditor.on "change", \
            _.debounce (@lazyBound 'previewApp', no), 500

          JSEditor.on "RunRequested", @lazyBound 'previewApp', yes
          JSEditor.on "AutoRunRequested", @bound 'toggleLiveReload'

          @on 'closeAllMenuItemClicked', =>
            CSSEditor.closeFile(); JSEditor.closeFile()

        CSSEditor.ready =>

          CSSEditor.loadLastOpenFile()
          CSSEditor.codeMirrorEditor.on "change", \
            _.debounce (@lazyBound 'previewCss', no), 500

          CSSEditor.on "RunRequested", @lazyBound 'previewCss', yes
          CSSEditor.on "AutoRunRequested", @bound 'toggleLiveReload'
          CSSEditor.on "FocusedOnMe", => @_lastActiveEditor = CSSEditor

        @on 'createMenuItemClicked',  @bound 'createNewApp'
        @on 'publishMenuItemClicked', @bound 'publishCurrentApp'
        @on 'compileMenuItemClicked', @bound 'compileApp'

  previewApp:(force = no)->

    return  if not force and not @liveMode
    return  if @_inprogress
    @_inprogress = yes

    {JSEditor, PreviewPane} = @workspace.activePanel.panesByName
    editorData = JSEditor.getData()
    extension = if editorData then editorData.getExtension() else 'coffee'

    if extension not in ['js', 'coffee']
      @_inprogress = no
      pc = PreviewPane.container
      pc.destroySubViews()
      pc.addSubView new ErrorPaneWidget {},
        error     :
          name    : "Preview not supported"
          message : "You can only preview .coffee and .js files."
      return

    @compiler (coffee)=>

      code = JSEditor.getValue()

      PreviewPane.container.destroySubViews()
      window.appView = new KDView

      try

        switch extension
          when 'js' then eval code
          when 'coffee' then coffee.run code

        PreviewPane.container.addSubView window.appView

      catch error

        try window.appView.destroy?()
        warn "Failed to run:", error

        PreviewPane.container.addSubView new ErrorPaneWidget {}, {code, error}

      finally

        delete window.appView
        @_inprogress = no


  previewCss:(force = no)->

    return  if not force and not @liveMode

    {CSSEditor, PreviewPane} = @workspace.activePanel.panesByName

    @_css?.remove()

    @_css = $ "<style scoped></style>"
    @_css.html CSSEditor.getValue()

    PreviewPane.container.domElement.prepend @_css

  compiler:(callback)->

    return callback @coffee  if @coffee
    require [COFFEE], (@coffee)=> callback @coffee

  compileApp:->

    {JSEditor} = @workspace.activePanel.panesByName

    KodingAppsController.compileAppOnServer JSEditor.getData()?.path, ->
      log "COMPILE", arguments

  createNewApp:->

    KD.singletons.kodingAppsController.makeNewApp (err, data)=>

      return warn err  if err

      {appPath} = data
      {CSSEditor, JSEditor, finder} = @workspace.activePanel.panesByName

      vmName = KD.singletons.vmController.defaultVmName
      finder.finderController.expandFolders \
        FSHelper.getPathHierarchy "[#{vmName}]#{appPath}/resources"

      JSEditor.loadFile  "[#{vmName}]#{appPath}/index.coffee"
      CSSEditor.loadFile "[#{vmName}]#{appPath}/resources/style.css"

  publishCurrentApp:->

    {JSEditor} = @workspace.activePanel.panesByName
    KodingAppsController.createJApp JSEditor.getData()?.path, ->
      new KDNotificationView
        title: "Published successfully!"

  toggleLiveReload:(state)->

    if state?
    then @liveMode = state
    else @liveMode = !@liveMode

    new KDNotificationView
      title: if @liveMode then 'Live compile enabled' \
                          else 'Live compile disabled'

    @storage.setValue 'liveMode', @liveMode
    return  unless @liveMode

    KD.utils.defer =>
      @previewApp yes; @previewCss yes

class DevToolsEditorPane extends CollaborativeEditorPane

  constructor:(options = {}, data)->

    options.defaultTitle or= 'JavaScript'
    options.editorMode   or= 'coffeescript'
    options.cssClass       = 'devtools-editor'
    super options, data

    @_mode = @getOption 'editorMode'
    @_defaultTitle = @getOption 'defaultTitle'

    @_lastFileKey = "lastFileOn#{@_mode}"
    @storage = KD.singletons.localStorageController.storage "DevTools"

  closeFile:->
    @openFile FSHelper.createFileFromPath 'localfile:/empty.coffee'

  loadFile:(path, callback = noop)->

    file = FSHelper.createFileFromPath path
    file.fetchContents (err, content)=>
      return callback err  if err

      file.path = path
      @openFile file, content

      KD.utils.defer -> callback null, {file, content}

  loadLastOpenFile:->

    path = @storage.getAt @_lastFileKey
    return  unless path

    @loadFile path, (err)=>
      @storage.unsetKey @_lastFileKey  if err?

  createEditor: (callback)->

    {cdnRoot} = CollaborativeEditorPane

    KodingAppsController.appendScriptElement 'script',
      url        : "#{cdnRoot}/addon/selection/active-line.js"
      identifier : "codemirror-activeline-addon"
      callback   : =>

        @codeMirrorEditor = CodeMirror @container.getDomElement()[0],
          lineNumbers     : yes
          lineWrapping    : yes
          styleActiveLine : yes
          scrollPastEnd   : yes
          cursorHeight    : 1
          tabSize         : 2
          mode            : @_mode
          extraKeys       :
            "Cmd-S"       : @bound "handleSave"
            "Ctrl-S"      : @bound "handleSave"
            "Alt-R"       : => @emit "RunRequested"
            "Shift-Ctrl-R": => @emit "AutoRunRequested"
            "Tab"         : (cm)->
              spaces = Array(cm.getOption("indentUnit") + 1).join " "
              cm.replaceSelection spaces, "end", "+input"

        @setEditorMode @_mode ? "coffee"

        callback?()

        @emit 'ready'

  openFile: (file, content)->

    validPath = file instanceof FSFile and not /^localfile\:/.test file.path

    if validPath
    then @storage.setValue @_lastFileKey, file.path
    else @storage.unsetKey @_lastFileKey

    super

    path = (FSHelper.plainPath file.path).replace \
      "/home/#{KD.nick()}/Applications/", ""

    @header.title.updatePartial if not validPath then @_defaultTitle else path

class DevToolsCssEditorPane extends DevToolsEditorPane

  constructor: (options = {}, data)->

    options.editorMode   = 'css'
    options.defaultTitle = 'Style'

    super options, data

class ErrorPaneWidget extends JView

  constructor:(options = {}, data)->

    options.cssClass = KD.utils.curry 'error-pane', options.cssClass
    super options, data

  pistachio:->
    {error} = @getData()
    line    = if error.location then "at line: #{error.location.last_line+1}" else ""
    stack   = if error.stack? then """
      <div class='stack'>
        <h2>Full Stack</h2>
        <pre>#{error.stack}</pre>
      </div>
    """ else ""

    """
      {h1{#(error.name)}}
      <pre>#{error.message} #{line}</pre>
      #{stack}
    """

  click:-> @setClass 'in'