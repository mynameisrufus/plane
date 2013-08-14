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
