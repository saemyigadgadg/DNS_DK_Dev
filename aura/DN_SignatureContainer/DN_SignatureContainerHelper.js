({
    fnShowToast : function(type, title, message) {
       var toastEvent = $A.get("e.force:showToast");
       toastEvent.setParams({
           "title": title,
           "message": message,
           "type" : type
       });
       toastEvent.fire();
   },

   getPromise : function(action){
       return new Promise($A.getCallback(function(resolve, reject){
           action.setCallback(this, function(response){
               let state = response.getState()

               if(state === 'SUCCESS'){
                   resolve(response.getReturnValue())
               }else{
                   reject(response.getError())
               }
           })

           $A.enqueueAction(action);
       }))
   },


})