$ ->
  reverser = null
  $('#start').click (e) ->
    e.preventDefault()
    return if reverser?
    reverser = new Reverser()
    return false

  $('#reverse-control').click (e) ->
    e.preventDefault()
    el = $(this)
    reversified = el.hasClass('on')

    el.toggleClass('on', !reversified)

    if reversified
      reverser.normalize()
    else
      reverser.reversify()


    return false