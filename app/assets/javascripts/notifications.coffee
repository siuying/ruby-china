window.Notifications =
  unread: (counter) ->
    $("#userbar .notifications").
      addClass("unread").
      find('.count').
      text(counter).
      effect('bounce', {}, 500)
