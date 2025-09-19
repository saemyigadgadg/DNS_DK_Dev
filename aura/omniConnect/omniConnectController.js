({

    handleDisconnect: function(component, message, helper) { 
        // Read the message argument to get the values in the message payload
        var omniAPI = component.find("omniToolkit");
        var utilityBarAPI = component.find("utilitybar");
        // omniAPI.getServicePresenceStatusId().then(function(result) {
        //     console.log('current status  ' , JSON.stringify(result,undefined,2));
        // }).catch(function(error) {
        //     console.log(error);
        // });
        utilityBarAPI.getAllUtilityInfo().then(function(response) {
            var myUtilityInfo = response.find(ele => ele.panelHeaderLabel === 'Phone');
            var myUtilityInfo1 = response.find(ele => ele.panelHeaderLabel === 'Omni-Channel');            
            if(message.getParam("state") == 'disconnected'){
                if(myUtilityInfo){
                    utilityBarAPI.setUtilityLabel({
                        utilityId : myUtilityInfo.id,
                        label: `Phone WS Disconnect`
                    });
                    utilityBarAPI.setUtilityHighlighted({
                        utilityId : myUtilityInfo.id,
                        highlighted: true
                    });
                }
            } else{
                if(myUtilityInfo){
                    utilityBarAPI.setUtilityLabel({
                        utilityId : myUtilityInfo.id,
                        label: `Phone`
                    });
                }
            }  

       }) 
        .catch(function(error) {
            console.log(error);
        });
    },
})