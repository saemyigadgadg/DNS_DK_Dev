({
    init : function(component, event, helper) {
        const today = new Date();
        const year = today.getFullYear(); 
        const month = String(today.getMonth() + 1).padStart(2, '0');;
        const day = String(today.getDate()).padStart(2, '0');
        const formatedDate = year+'-'+month+'-'+day;
        console.log('formatedDate', formatedDate);
        component.set('v.startDate', formatedDate);
        component.set('v.endDate', formatedDate);      
    },
    handleSearch : function(component, event, helper) {
        component.set('v.isLoading', false);
        helper.getSearchList(component);
    },
    handleSMSList : function(component, event, helper){
        helper.getSMSList(component);
    },
    handleSearchTarget : function(component, event, helper){
        helper.getSMSList(component);
    },
    handleManageTab : function(component, event, helper){
        console.log('handleManageTab');
        // var utilityAPI = component.find('utilitybar');
        // utilityAPI.getAllUtilityInfo().then(function (response) {
        //     console.log('response',response);
        //     if (typeof response !== 'undefined') {
        //         utilityAPI.toggleModalMode({
        //             enableModalMode: true
        //         });
        //        utilityAPI.setPanelWidth({
        //            widthPX: 1200,
        //        });
        //        utilityAPI.setPanelHeight({
        //            heightPX:900
        //        });
        //         component.set('v.hasUtilityBar', true);
        //         utilityAPI.onUtilityClick({
        //             eventHandler: function() {
        //                 console.log('refreshContent');
        //                 helper.refreshContent(component);
        //             }
        //         });
        //     } else {
        //         component.set('v.hasUtilityBar', false);
        //     }
        // });
    },
})