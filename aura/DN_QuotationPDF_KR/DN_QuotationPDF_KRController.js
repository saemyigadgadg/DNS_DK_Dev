({
    init : function(component, event, helper) {
        component.get("v.recordId");
        // console.log(component.get('v.url'));

        var keyCheck = component.get("c.getKeyfield");
        keyCheck.setParams({
            recordId : component.get("v.recordId")
        });
        keyCheck.setCallback(this, function(response){
            component.set('v.subtitle', $A.get("$Label.c.PartnerPortal"));

            var msg = response.getReturnValue();
            // console.log('msg : ' + msg);
            this.currentUrl = window.location.href;
            // console.log('현재 페이지 URL: ' + this.currentUrl);
            if(msg == 'SUCCESS'){
                // component.set('v.url', '/partners/apex/DN_QuotationExport_KRPage?Id=' + component.get('v.recordId'));
                if(this.currentUrl.includes('site')){
                    //Portal이면
                    component.set('v.url', $A.get("$Label.c.PartnerPortal") + '/apex/DN_QuotationExport_KRPage?Id=' + component.get('v.recordId'));
                }else{
                    component.set('v.url', '/apex/DN_QuotationExport_KRPage?Id=' + component.get('v.recordId'));
                }


                var action = component.get("c.getVersion");
                action.setParams({
                    quoteId: component.get("v.recordId")
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === "SUCCESS") {
                        var version = response.getReturnValue();
                        component.set('v.verSion', version);
                    }
                });
                $A.enqueueAction(action);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": msg,
                        "type": "error"
                    });
                    toastEvent.fire();
            $A.get('e.force:closeQuickAction').fire();

            }
        });
        $A.enqueueAction(keyCheck);



        
    },
    createPDF: function(component, event, helper) {
        component.set('v.isLoading', true);

        var action = component.get("c.generatePDF");
        action.setParams({
            quoteId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type" : "Success",
                        "title": $A.get("$Label.c.DNS_M_Success"),
                        "message": $A.get("$Label.c.DNS_M_Success")

                    });
                    resultsToast.fire();
                    $A.get('e.force:refreshView').fire();

                
                //PDF Local에 저장 부분 시작
                var base64PDF = response.getReturnValue();
                // console.log('base64 : ' + base64PDF);
                // Create a Blob from the Base64 string
                var byteCharacters = atob(base64PDF.base64PDF);
                var byteNumbers = new Array(byteCharacters.length);
                for (var i = 0; i < byteCharacters.length; i++) {
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }
                var byteArray = new Uint8Array(byteNumbers);
                var blob = new Blob([byteArray], { type: 'application/pdf' });
                
                // Create a link element
                var link = document.createElement('a');
                link.href = window.URL.createObjectURL(blob);
                link.download = base64PDF.QuoteName + '.pdf';
                link.style.display = 'none';
                
                // Append to the DOM
                document.body.appendChild(link);
                
                // Trigger the download
                link.click();
                
                // Clean up and remove the link
                document.body.removeChild(link);
                //PDF Local에 저장 부분 끝
            }else {
                console.error(state.message);
            }
        });
        $A.enqueueAction(action);
    },
    closeClick: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
    }
})