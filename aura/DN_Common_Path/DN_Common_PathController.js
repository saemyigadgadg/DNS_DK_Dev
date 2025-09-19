/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-04-13
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-13-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
  doinit : function(component, event, helper) {

    console.log(' do Init !');

    var recordId = component.get('v.recordId');
    console.log('recordId:', recordId);
  
    var action = component.get('c.getValidated');
    action.setParams({
      recordId : recordId
    });
    action.setCallback(this, function(response){
      
        // console.log('callback:', callback);
        var result = response.getReturnValue();
        console.log('result:', result);
        component.set('v.isValidated', result);
    });
    $A.enqueueAction(action);
},

handleRecordUpdated: function(component, event, helper) {
  var changeType = event.getParams().changeType;

  if (changeType === "CHANGED") {
      window.location.reload();


  }
}
})