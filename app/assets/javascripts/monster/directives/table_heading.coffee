$directive 'tableHeading', '$timeout','$window',
  ($timeout,$window)->
    (scope,element,attrs)->
      scroll = ->
        fun = ->
          parent      = element.parent('.data-table')
          left        = parent.find('.model:first').offset().left
          scroll_left = angular.element($window).scrollLeft()
          parent.find('.item.heading').css left: left-scroll_left
        $timeout fun, 0
      resize = ->
        fun = ->
          parent  = element.parent('.data-table')
          w = parent.find('.model:first').outerWidth()
          parent.find('.item.heading').width w
          columns = parent.find('.model:first .cell')
          _.each columns, (e,i)=>
            width = angular.element(e).outerWidth()
            element.find(".cell:nth-child(#{i+1})").css width: "#{width}px"
        $timeout fun, 0
      angular.element($window).bind 'resize', resize
      #angular.element($window).bind 'scroll', scroll
      scope.$watch attrs.tableHeading       , resize
      scope.$on 'data_heading'              , resize
