ContentCtrl = ($rootScope, $scope, $window, $location, $http, $element, $attrs, $compile, $document, documentParser) ->

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
    doc = documentParser.parse data
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
  '$document',
  'documentParser'
]

# angular.controller 'ContentCtrl', ContentCtrl
