({
    getData: function(component) {
        var reportType = component.get('v.reportType');
        console.log('reportType : ', reportType);
        if(reportType == 'date'){
            var byDate = component.get('v.byDate');
            console.log('byDate',byDate);
        
            let dateSum = [];
            let fields = Object.keys(byDate[0]); 
            let excludeFields = ["ownerId", "ownerName", "activityDate"];
            fields.forEach(field => {
                if (!excludeFields.includes(field)) { 
                    if (typeof byDate[0][field] === 'number') {
                        dateSum[field] = byDate.reduce((acc, curr) => acc + curr[field], 0);
                    } else {
                        dateSum[field] = "";
                    }
                }
            });
            component.set("v.dateSum", [dateSum]);
        }else{

            var byAgent = component.get('v.byAgent');
            console.log('byAgent',byAgent);
        
            let agentSum = [];
            let fields = Object.keys(byAgent[0]); 
            let excludeFields = ["ownerId", "ownerName", "activityDate"];
            fields.forEach(field => {
                if (!excludeFields.includes(field)) { 
                    if (typeof byAgent[0][field] === 'number') {
                        agentSum[field] = byAgent.reduce((acc, curr) => acc + curr[field], 0);
                    } else {
                        agentSum[field] = "";
                    }
                }
            });
            component.set("v.agentSum", [agentSum]);
            
            console.log('agentSum', agentSum);
        }
        
    },
    toast : function(component, title, message, variant){
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "variant": variant
        });
    },
    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() );
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },

})