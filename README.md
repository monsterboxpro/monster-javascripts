In your application.coffee

//=require 'monster'

### ApiBase (api.coffee)

Allows you to define routes similar to rails.

$service 'Api', class extends ApiBase
  namespace: 'api'
  projects; {}
  users:
    member:
      entry: 'get'
    collection:
      activity: 'get'

Makes it easy to call these routes:

@Api.projects.index()
@Api.users.show(@model)
@Api.users.entry(@model)
@Api.users.activity()

### AngularJs Helpers (scaffold.coffee)

$controller
$service
$directive
$filter

### Javascript Classes

Javascript classes that make common life easier.

List  - Handle lists eg. indexes
Show  - Handles show eg. indiviual members
Popup - Handles popups
Form  - Handles forms
