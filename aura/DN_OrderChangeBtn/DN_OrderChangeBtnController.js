({
    doInit : function(component, event, helper) {

        const userLang = $A.get("$Locale.language");

        const WON_TEXT = userLang === 'ko' ? '원' : '';
        const WON_CODE = userLang === 'ko' ? '' : '₩';

        const HELP_CV = $A.get("$Label.c.DNS_T_eg") + ' ) MAIN/LEFT CHUCK SIZE- 210 MM (8 INCH) // 1EA // '+ $A.get("$Label.c.DNS_C_DealerPrice") + ': ' + WON_CODE + '150,000' + WON_TEXT;
        const HELP_SQPS = $A.get("$Label.c.DNS_T_eg") + ' ) HYD. FIXTURE UNIT 2.2KW 2AB // 1EA // ' + $A.get("$Label.c.DNS_C_DealerPrice") + ': ' + WON_CODE + '3,500,000' + WON_TEXT;
        const HELP_SQ = $A.get("$Label.c.DNS_T_eg") + ' ) R78481B COLLET;MILLING COLLET KIT // 3EA // ' + $A.get("$Label.c.DNS_C_DealerPrice") + ': ' + WON_CODE + '900,000' + WON_TEXT;
        const HELP_DETAIL = $A.get("$Label.c.DNS_T_eg") + ' ) ' + $A.get("$Label.c.DNS_F_DeliveryDate") + ' 2024.09.30 // ' + $A.get("$Label.c.DNS_F_PaymentTerms") 
                          + $A.get("$Label.c.DNS_F_AdvancePaymentBeforeShipment") + ' // ' + $A.get("$Label.c.DNS_F_Incoterms") + ' ' + $A.get("$Label.c.DNS_F_InstallationTestOperationDiagram");

        component.set('v.helpTextMap', {
            'CVChange' : HELP_CV
            , 'SQPSChange' : HELP_SQPS
            , 'ChangeOfSQ' : HELP_SQ
            , 'ChangeOrderDetail' : HELP_DETAIL
            , 'OrderReturn' : ''
            , 'OrderCancellation' : ''
            , 'ETC' : ''
        });
        // helper.reverseSpinner(component);
    }

    , closeClick: function(component, event, helper) {
        helper.closeModal();
    }

    , handleLoad: function(component, event, helper) {
        // helper.reverseSpinner(component);
        component.set('v.isLoading', false);
    }

    , handleSubmit: function(component, event, helper) {
        event.preventDefault();
        
        helper.reverseSpinner(component);

        const fields = event.getParam('fields');
        fields.Order__c = component.get('v.recordId');
        component.find('orderChangeForm').submit(fields);
    }

    , handleSuccess : function(component,event,helper) {
        var record = event.getParam("response");

        var action = component.get("c.sendNotiToManager");
        action.setParams({ 
            recordId : component.get('v.recordId')
            , changeId : record.id
        });
        action.setCallback(this, function(response) {
            console.log('handleSuccess', '3');

            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('handleSuccess', '4');
                helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_M_OrderChangeRequestSubmitted"));
                helper.closeModal();
            } else {
                console.log('handleSuccess', '5');
                helper.handleError('handleSuccess', response.getError());
                helper.reverseSpinner(component);
            }
        });
        $A.enqueueAction(action);
    }

    , handleError: function(component, event, helper) {
        helper.handleError('handleError', event.getParam("message"));
        console.log("Error error : " + JSON.stringify(event.getParam("error"), null, 1));
    }

    , handleReason : function(component, event, helper) {
        const tempText = event.getSource().get('v.value');
        const helpTextMap = component.get('v.helpTextMap');

        if(helpTextMap[tempText] && helpTextMap[tempText] != '') {
            component.set('v.helpText', helpTextMap[tempText]);
        } else {
            component.set('v.helpText', '');
        }
    }
})