({
    doInit : function(component, event, helper) {
        component.set('v.isLoaded', false);
        var recordId = component.get("v.recordId");
        var action = component.get('c.getSignature')
		action.setParams({
            'recordId': recordId,
            'signatureType' : component.get('v.signatureType')
		})
        console.log('viewer : ',component.get('v.signatureType'));
        
        action.setCallback(this, function(res){   
            var result = res.getReturnValue();
              component.set('v.isLoaded', true); 
            if(result != '') {
                component.set('v.signatureData', result);
                console.log('result : ',result);
                component.set('v.hasSign', true);
            } else {
                 
            }
            
        });
        $A.enqueueAction(action);
    },

    deleteSign: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.deleteSignFile");

        if (!window.confirm("Would you like to delete recent Signature?")) {
            return;
        }
        var signatureType = component.get('v.signatureType');
        var returnMessage = '';
        if(signatureType == 'engineer'){
            returnMessage = 'engineer_delete';
        }else{
            returnMessage = 'customer_delete';
        }
        action.setParams({ 
            'recordId': recordId,
            'signatureType' :component.get('v.signatureType')
        })

        action.setCallback(this, function(res) {
            var state = res.getState();
            console.log("State :: ", state);

            if (state == "SUCCESS") {
                component.set("v.signatureData", "");
                var completeEvt = component.getEvent("complete");
                    completeEvt.setParams({
                        "signatureType": returnMessage,
                        "recordId": recordId
                    });
                    console.log('completeEvt :: ', JSON.stringify(completeEvt, null, 2));
                    
                    completeEvt.fire();
                // $A.get('e.force:refreshView').fire();
                console.log("SUCCESS Zone");
            } else if (state == "ERROR") {
                $A.log("callback error", res.getError());
            }

            // $A.get('e.force:refreshView').fire();

        });
        $A.enqueueAction(action);
    }





        
})