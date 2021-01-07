'use strict';

var app = angular.module('exampleApp', ['JSONedit']);

function MainViewCtrl($scope, $filter) {

    $scope.jsonData = {"字段名":"字段值"};
    var name = decodeURIComponent(window.name);
    if (name[0] == '{' || name[0] == '[') {
        $scope.jsonData = JSON.parse(name);
    }

    $scope.$watch('jsonData', function(json) {
        $scope.jsonString = $filter('json')(json);
    }, true);
    $scope.$watch('jsonString', function(json) {
        try {
            $scope.jsonData = JSON.parse(json);
            $scope.wellFormed = true;
        } catch(e) {
            $scope.wellFormed = false;
        }
    }, true);
}
