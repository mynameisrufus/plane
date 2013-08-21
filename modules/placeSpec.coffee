describe 'Controller: ContentCtrl', ->

  docString = ->
    """
    <!DOCTYPE html>
    <html>
      <head>
        <title>Example</title>
      </head>
      <body>
        <div id="content"><p>goodbye</p></div>
      </body>
    </html>
    """

  element = ->
    angular.element '<div id="content"><p>hello</p></div>'

  ctrl = httpMock = element = null

  beforeEach module 'plane'

  beforeEach inject ($controller, $rootScope, $httpBackend, $http) ->

    httpMock = $httpBackend
    ctrl     = $controller

    $httpBackend.when('GET', 'http://example.dev/test.html').respond(docString())


    element = angular.element '<div id="content"><p>hello</p></div>'

    ctrl ContentCtrl,
      $element: element
      $scope: $rootScope.$new()
      $http: $http
      $attrs: { id: "content" }

  afterEach ->
    httpMock.verifyNoOutstandingExpectation()
    httpMock.verifyNoOutstandingRequest()

  it "should swap out the content from the response", inject ($rootScope) ->
    expect(element.find('p').text()).toEqual "hello"

    httpMock.expectGET 'http://example.dev/test.html'
    $rootScope.$broadcast '$locationChangeSuccess', 'http://example.dev/test'
    httpMock.flush()

    expect(element.find('p').text()).toEqual "goodbye"

describe 'Controller: SegmentCtrl', ->

  docString = ->
    """
    <!DOCTYPE html>
    <html>
      <head>
        <title>Example</title>
      </head>
      <body>
        <div id="content"><p>goodbye</p></div>
      </body>
    </html>
    """

  element = ->
    angular.element '<div id="content"><p>hello</p></div>'

  ctrl = scope = httpMock = element = timeout = null

  beforeEach module 'plane'

  beforeEach inject ($controller, $rootScope, $httpBackend, $http, $timeout) ->

    scope    = $rootScope.$new()
    httpMock = $httpBackend
    ctrl     = $controller
    timeout  = $timeout

    httpMock.when('GET', 'http://example.dev/test').respond(docString())
    
    element = angular.element '<div id="content"><p>hello</p></div>'

    ctrl SegmentCtrl,
      $element: element
      $scope: scope
      $http: $http
      $attrs: { id: "content" }
      $location: { $$absUrl: 'http://example.dev/test' }

  afterEach ->
    httpMock.verifyNoOutstandingExpectation()
    httpMock.verifyNoOutstandingRequest()

  it "should swap out the content from the response", ->
    expect(element.find('p').text()).toEqual "hello"

    httpMock.expectGET 'http://example.dev/test'
    scope.$broadcast '$locationChangeSuccess', 'http://example.dev/test'
    timeout.flush()
    httpMock.flush()

    expect(element.find('p').text()).toEqual "goodbye"
