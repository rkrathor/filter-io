var TabletWallEvents = {
  like:function (s) {
    var e = $('.buttonAnimate.icon-thumbs-up');
    e.show();
    setTimeout(function () {
      e.addClass('active');
      setTimeout(function () {
        e.removeClass('active');
        e.hide();
        Wall.events.like(s);
      }, 500);
    }, 100);

  },

  unlike:function (s) {
    var e = $('.buttonAnimate.icon-thumbs-down');
    e.show();
    setTimeout(function () {
      e.addClass('active');
      setTimeout(function () {
        e.removeClass('active');
        e.hide();
        Wall.events.unlike(s);
      }, 500);
    }, 100);
  }

};