{CompositeDisposable} = require 'atom'

module.exports = ShowFirstLineOnTab =
  subscriptions: null
  isEnable: true

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'show-first-line-on-tab:saveuntitled': => @saveuntitled()
    @subscriptions.add atom.commands.add 'atom-workspace', 'show-first-line-on-tab:toggle': => @toggle()

    that = @
    @subscriptions.add atom.workspace.observeTextEditors (monitor) ->
      that.subscriptions.add monitor.onDidStopChanging =>
        if that.isEnable
          try
            atom.workspace.getActiveTextEditor().getBuffer().setPath(that.createPath()) unless that.checkExistPath()
          catch
            

  deactivate: ->
    @subscriptions.dispose()

  toggle: ->
    @isEnable = not @isEnable
    atom.notifications.addSuccess("Show First Line on Tab Package is #{@isEnable}")

  saveuntitled: ->
    items = atom.workspace.getActivePane()
    file = item?.buffer.file.mini = itms.
    firstLine = item?.buffer.lines[0]

    unless @checkExistPath()
      atom.workspace.getActiveTextEditor().getBuffer().setPath(@createPath())
      atom.workspace.getActivePane().saveActiveItemAs()
    else
      atom.workspace.getActivePane().saveActiveItem()
    return

  createPath: ->
    item = atom.workspace.getActivePaneItem()
    file = item?.buffer.file
    firstLine = item?.buffer.lines[0]

    if @checkExistPath()
      return file?.path
    else
      atom.project.addPath(atom.config.get('core.projectHome')) unless atom.project.getPaths()[0]?
      projectRootDir = atom.project.getDirectories()[0]
      firstLine = "untitled" if firstLine == ""
      charPosition = projectRootDir.getPath().length - projectRootDir.getBaseName().length - 1
      filePath = projectRootDir.getPath()[0..charPosition] + firstLine
      return filePath


  checkExistPath: ->
    try
      item = atom.workspace.getActivePaneItem()
      file = item?.buffer.file
      setPathFlag = file.existsSync()
    catch error
      setPathFlag = false

    return setPathFlag
