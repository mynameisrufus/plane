SegmentCtrl = ($scope, $timeout, $location, $http, $element, $attrs, $compile, documentParser) ->

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

    doc = documentParser.parse data
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
  '$compile',
  'documentParser'
]

# angular.controller 'SegmentCtrl', SegmentCtrl
