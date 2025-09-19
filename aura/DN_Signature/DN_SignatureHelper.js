({
    init: function(cmp) {
      var wrapper = document.getElementById(this._getWrapperElement(cmp)),
        canvas = wrapper.querySelector('canvas'),
        minWidth = parseFloat(cmp.get('v.minWidth')),
        maxWidth = parseFloat(cmp.get('v.maxWidth')),
        penColor = cmp.get('v.penColor');
  
      function resizeCanvas() {
        var ratio = Math.max(window.devicePixelRatio || 1, 1);
        canvas.width = canvas.offsetWidth * ratio;
        canvas.height = canvas.offsetHeight * ratio;
        canvas.getContext("2d").scale(ratio, ratio);
      }
  
      cmp.set('v.signaturePad', new SignaturePad(canvas, {
        minWidth: minWidth,
        maxWidth: maxWidth,
        penColor: penColor
      }));
      resizeCanvas();
    },
  
    _getWrapperElement: function(cmp){
      return 'signatureWrapper' + cmp.get('v.id');
    },
  
    capture: function(cmp) {
      var dataUrl, pad = cmp.get('v.signaturePad');
      pad.trimCanvas();
      dataUrl = pad.toDataURL();
      //console.log("capture: dataUrl>>"+dataUrl);
  
      cmp.set('v.signatureData', dataUrl);
      console.log(cmp.get('v.signatureData'));
      //console.log("capture: signatureData>>"+cmp.get('v.signatureData'));
  
      
    },
  
    clear: function(cmp) {
      cmp.get('v.signaturePad').clear();
    },
  
    touch: function(cmp) {
      var e = document.querySelector('input.esignature-hide');
      e.focus();
    }
  })