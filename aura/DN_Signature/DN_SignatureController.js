({
    onScriptReady: function(cmp, evt, h) {
      console.log('id : ', cmp.get('v.id'));
      
      h.init(cmp);
    },
  
    onCapture: function(cmp, evt, h) {
      h.capture(cmp);
    },
  
    handleTouchMove: function(cmp, evt, h) {
      evt.stopPropagation();
    },
  
    onTouch: function(cmp, evt, h) {
      h.touch(cmp);
    },
  
    onClear: function(cmp, evt, h) {
      h.clear(cmp);
    }
  })