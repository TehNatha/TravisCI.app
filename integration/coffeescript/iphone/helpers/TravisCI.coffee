#import "NavigationScreen.js"
#import "Pusher.js"
#import "RepositoriesScreen.js"
#import "BuildsScreen.js"
#import "JobsScreen.js"
#import "JobDetailScreen.js"
#import "JobLogScreen.js"

class TravisCIClass
  window: ->
    UIATarget.localTarget().frontMostApp().mainWindow()

  tableWithName: (name) ->
    @window().tableViews().firstWithName(name)

TravisCI = new TravisCIClass