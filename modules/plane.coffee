plane = angular.module('plane', [])

# https://github.com/rails/turbolinks/blob/master/lib/assets/javascripts/turbolinks.js.coffee
browserCompatibleDocumentParser = ->
  createDocumentUsingParser = (html) ->
    (new DOMParser).parseFromString html, 'text/html'

  createDocumentUsingDOM = (html) ->
    doc = document.implementation.createHTMLDocument ''
    doc.documentElement.innerHTML = html
    doc

  createDocumentUsingWrite = (html) ->
    doc = document.implementation.createHTMLDocument ''
    doc.open 'replace'
    doc.write html
    doc.close()
    doc

  # Use createDocumentUsingParser if DOMParser is defined and natively
  # supports 'text/html' parsing (Firefox 12+, IE 10)
  #
  # Use createDocumentUsingDOM if createDocumentUsingParser throws an exception
  # due to unsupported type 'text/html' (Firefox < 12, Opera)
  #
  # Use createDocumentUsingWrite if:
  #  - DOMParser isn't defined
  #  - createDocumentUsingParser returns null due to unsupported type
  #  'text/html' (Chrome, Safari)
  #  - createDocumentUsingDOM doesn't create a valid HTML document (safeguarding
  #  against potential edge cases)
  try
    if window.DOMParser
      testDoc = createDocumentUsingParser '<html><body><p>test'
      createDocumentUsingParser
  catch e
    testDoc = createDocumentUsingDOM '<html><body><p>test'
    createDocumentUsingDOM
  finally
    unless testDoc?.body?.childNodes.length is 1
      return createDocumentUsingWrite

documentParser = browserCompatibleDocumentParser()

ContentCtrl = ($rootScope, $scope, $window, $location, $http, $element, $attrs, $compile, $document) ->

  parentScope = $scope.$parent

  scope = $scope

  id = $attrs.id

  url = $location.$$absUrl

  options = cache: false

  extractTitleAndContent = (doc) ->
    title   = doc.querySelector 'title'
    content = doc.querySelector "##{id}"
    content = doc.body unless content
    [title, content.children]

  changeContent = (title, content) ->
    $document.prop 'title', title?.textContent
    $element.html ""
    $element.append content
    $compile($element.contents())(scope)

  onSuccess = (data, status, headers) ->
    doc = documentParser data
    $document.find("header")?[0]?.scrollIntoView(true)
    changeContent extractTitleAndContent(doc)...

  transition = (skip) ->
    unless skip
      $element.html ""
      onSuccess
    else
      (data, status, headers) ->
        onSuccess data, status, headers

  get = (transitionContent) ->

    scope.$destroy()
    scope = parentScope.$new()

    callback = transition !transitionContent

    $http.get("#{url}.html", options).success(callback).error(callback)

  listners = []

  # Anything can `$broadcast` reload content on the root scope and the page will
  # get refreshed.
  listners.push $rootScope.$on '$reloadContent',  ->
    get false

  # When ever the route changes we we swap out the content with the new url. If
  # the new url and current url and are the same we skip because we are probably
  # on the first page load.
  listners.push $rootScope.$on '$locationChangeSuccess', (event, newUrl, oldUrl) ->
    if newUrl != oldUrl
      url = newUrl
      get true

  parentScope.$on '$destroy', ->
    listner() for listner in listners()

ContentCtrl.$inject = [
  '$rootScope',
  '$scope',
  '$window',
  '$location',
  '$http',
  '$element',
  '$attrs',
  '$compile',
  '$document'
]

plane.controller('ContentCtrl', ContentCtrl)

SegmentCtrl = ($scope, $timeout, $location, $http, $element, $attrs, $compile) ->

  parentScope = $scope.$parent

  scope = $scope

  id = $attrs.id

  url = $location.$$absUrl

  options = cache: false, headers: { "Accept": "text/html" }

  duration = Number($attrs.timeout || 30000)

  promise = false

  get = ->
    $http.get(url, options).success(onSuccess).then(poll, onError)

  poll = ->
    unless parentScope.$$destroyed
      promise = $timeout get, duration, true

  onError = ->
    promise = $timeout poll, 60000, true

  onSuccess = (data) ->
    scope.$destroy()
    scope = parentScope.$new()

    doc = documentParser data
    content = doc.querySelector "##{id}"
    $element.html ""
    $element.append content.children

    $compile($element.contents())(scope)

  parentScope.$on "$destroy", ->
    $timeout.cancel promise

  poll()

SegmentCtrl.$inject = [
  '$scope',
  '$timeout',
  '$location',
  '$http',
  '$element',
  '$attrs',
  '$compile'
]

plane.controller 'SegmentCtrl', SegmentCtrl
