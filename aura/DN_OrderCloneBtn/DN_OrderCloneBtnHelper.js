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
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
    }

    , handleError : function(methodName, errorMsg) {
        var msg = errorMsg;
        if(typeof msg != 'string' && errorMsg.length > 0) { msg = errorMsg[0]; }
        if(msg.message) { msg = msg.message; }

        if(msg.includes('first error:')) msg = msg.split('first error:')[1];

        console.error(methodName + " Error : " + JSON.stringify(msg, null, 2));
        this.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), msg);
    }

    , reverseSpinner : function(component) {
        component.set('v.isLoading', !component.get('v.isLoading'));
    }

    , sortData: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }

    // , sortData: function (data, fieldName, sortDirection) {
    //     // console.log('sortData : ', fieldName, sortDirection);
    //     // console.log('test01', sortedBy, sortDirection, component.get('v.sortDirection'));
        
    //     let sortedData = data.slice().sort((a, b) => {
    //         let fieldA = a[fieldName];
    //         let fieldB = b[fieldName];
            
    //         if (fieldName === 'quoteItemLink') {
    //             fieldA = a['productName'];
    //             fieldB = b['productName'];
    //         }

    //         let result = 0;
    //         if (fieldA < fieldB) { result = -1; } 
    //         else if (fieldA > fieldB) { result = 1; }

    //         return sortDirection === 'asc' ? result : -result;
    //     });

    //     return sortedData;
    // }
})