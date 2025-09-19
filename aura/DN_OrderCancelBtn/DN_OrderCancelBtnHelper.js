({
    toast: function (type, title, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title      : title
            , type     : type
            , message  : message
            , duration : 3000
            , mode     : 'dismissible'
        });
        toastEvent.fire();
    }

    , closeModal : function() {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }

    , handleError : function(methodName, errorMsg) {
        var msg = errorMsg;
        if(typeof msg != 'string' && msg.length > 0) { msg = msg[0]; }
        if(msg.message) { msg = msg.message; }

        console.error(methodName + " Error : " + JSON.stringify(msg, null, 2));
        this.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), msg);
    }
})