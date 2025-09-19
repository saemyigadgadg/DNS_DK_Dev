({
    init : function(component, event, helper) {
        // var signaturType = component.get('v.signatureType');
        // var signature;
        // if(signaturType == 'engineer'){
        //     signature = component.find('signature_engineer');
        // }else{
        //     signature = component.find('signature_customer');
        // }
        // console.log('signatureType :: ', signaturType);
        // console.log('signature :: ', signature);
        // signature.set('v.readOnly',false);
        
    },
    onClear: function(component, event, helper) {
        if(component.get('v.signatureType') == 'engineer'){
            component.find('signature_engineer').clear();
        }else{
            component.find('signature_customer').clear();
        }
    },    
    acceptSignature: function(component, event, helper) {
        var signatureType = component.get('v.signatureType');
        var signature;
        if(signatureType == 'engineer'){
            signature = component.find('signature_engineer');
        }else{
            signature = component.find('signature_customer');
        }
        
        signature.capture();
        console.log('signaturType :: ', signatureType);
        
        var strDataURI = signature.get('v.signatureData');
        strDataURI = strDataURI.replace(/^data:image\/(png|jpg);base64,/, "");
        
        try{
            //이미지 데이터 사이즈가 4096 이상이면 정상 서명으로 간주. 그 이하는 비정상 서명으로 간주
            if(strDataURI.length < 4096){
                helper.fnShowToast('warning' , 'Warning' , 'Please check if the signature is normal.');
                signature.init();
            } else {
                var parentId = component.get('v.recordId');
                signature.set('v.readOnly', true);
                component.set('v.showModalSpinner', true);
        
                
                //Controller 
                var action = component.get("c.saveSignatureNew");
                
                action.setParams({
                    'signatureBody' : strDataURI,
                    'parentId' : parentId,
                    'signatureType' : signatureType
                });
                helper.getPromise(action).then(
                    $A.getCallback(function(result){
                        if(result) {
                            helper.fnShowToast('success' , 'Success' , 'Confirmed.');
                            component.set('v.showModalSpinner', false);
                            component.set('v.bDisplay',false);
                            // signature.set('v.readOnly', false);
                            // signature.init();
                            // $A.get('e.force:refreshView').fire();
                            var completeEvt = component.getEvent("complete");
                                completeEvt.setParams({
                                    "signatureType": signatureType,
                                    "recordId": parentId
                                });
                                console.log('completeEvt :: ', completeEvt);
                                
                                completeEvt.fire();
                        } else {
                            helper.fnShowToast('error' , 'error' , 'error.');
                            component.set('v.showModalSpinner', false);
                            component.set('v.bDisplay',false);
                            signature.clear();
                        }

                       
                    })
                ).catch(function(error){
                    console.log(error)
                })
              
            }
        } catch(e){
            console.log(e);
        }
        // $A.get('e.force:refreshView').fire();
    },
 })