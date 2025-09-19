({
    doInit : function(component, event, helper) {
        helper.reverseSpinner(component);

        const recordId = component.get('v.recordId');
        // const isPortal = component.get('v.isPortal');

        try {
            var action = component.get('c.dnsaFactoryOptionMaster');
            action.setParams({
                recordId : recordId
            });
            action.setCallback(this, function(response){
                var returnVal = response.getReturnValue();
                // console.log('msg : ' + returnVal.isPortal);
                // console.log('returnVal.MasterData : ' + JSON.stringify(returnVal.MasterData));
                if(returnVal.msg == 'SUCCESS'){
                    component.set('v.isPortal', returnVal.isPortal);
                    // console.log('returnVal.crmuserDatas : ' + returnVal.crmuserDatas);
                    // console.log('returnVal.dealerDatas : ' + JSON.stringify(returnVal.dealerDatas));
                    if(returnVal.isPortal){
                        component.set('v.MasterData', returnVal.MasterData.filter(item => !returnVal.dealerDatas.some(delItem => delItem.key === item.key)));
                    }else{
                        component.set('v.MasterData', returnVal.MasterData.filter(item => !returnVal.crmuserDatas.some(delItem => delItem.key === item.key)));
                    }
                    component.set('v.dealerDatas', returnVal.dealerDatas);
                    component.set('v.crmuserDatas', returnVal.crmuserDatas);
                    component.set('v.isPortal', returnVal.isPortal);
                    component.set('v.modelInfo', returnVal.modelInfo);
                    component.set('v.productInfo', returnVal.productInfo);
                    helper.setColumns(component, returnVal.isPortal);

                    helper.reverseSpinner(component);

                }else{
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title"      : 'error'
                        , "type"     : 'ERROR'
                        , "message"  : returnVal.msg
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();

                }
            });
            $A.enqueueAction(action);
        } catch (error) {
            console.log('error : ' + error);
        }
    },

    handleRowAction: function(component, event, helper){
        try {
            const actionName = event.getParam('action').name;
            const row = event.getParam('row');
            // console.log('row : ' + JSON.stringify(row));
            // console.log('row : ' + row.key);
            var isPortal = component.get('v.isPortal');
            let crmuserDatas = component.get('v.crmuserDatas') || [];
            let dealerDatas = component.get('v.dealerDatas') || [];
            let delTableData = component.get('v.delTableData') || [];
            let MasterData = component.get('v.MasterData') || [];
            if(isPortal){ //딜러일 경우
                if (actionName === 'add') {
                    const addItem = MasterData.find(item => item.key === row.key);
                    MasterData = MasterData.filter(item => item.key !== row.key);
                    component.set('v.MasterData', MasterData);
                    addItem.del = '';
                    dealerDatas.push(addItem);
                    component.set('v.dealerDatas', dealerDatas);

                    delTableData = delTableData.filter(item => item.key !== row.key);
                    component.set("v.delTableData", delTableData);
                }
            }else{//CRM User일 경우
                if (actionName === 'add') {
                    const addItem = MasterData.find(item => item.key === row.key);
                    MasterData = MasterData.filter(item => item.key !== row.key);
                    component.set('v.MasterData', MasterData);
                    addItem.del = '';
                    crmuserDatas.push(addItem);
                    component.set('v.crmuserDatas', crmuserDatas);

                    delTableData = delTableData.filter(item => item.key !== row.key);
                    component.set("v.delTableData", delTableData);
                }
            }
        } catch (error) {
            console.error('Error in handleRowAction:', error);
            console.error('Error Name:', error.name);
            console.error('Error Message:', error.message);
            console.error('Error Stack:', error.stack);
        }
    },

    handleRemoveClick: function(component, event, helper) {
        const rowKey = event.getSource().get("v.name");

        var isPortal = component.get('v.isPortal');
        let crmuserDatas = component.get('v.crmuserDatas') || [];
        let dealerDatas = component.get('v.dealerDatas') || [];
        let delTableData = component.get('v.delTableData') || [];
        let MasterData = component.get('v.MasterData') || [];

        const dealerremoveItem = dealerDatas.find(item => item.key === rowKey);
        const crmuserremoveItem = crmuserDatas.find(item => item.key === rowKey);

        if(isPortal){ //딜러일 경우
            if(dealerremoveItem){
                dealerremoveItem.del = 'D';
                delTableData.push(dealerremoveItem);
                component.set("v.delTableData", delTableData);

                dealerDatas = dealerDatas.filter(item => item.key !== rowKey);
                component.set("v.dealerDatas", dealerDatas);

                MasterData.push(dealerremoveItem);
                component.set("v.MasterData", MasterData);
            }
        }else{
            if(crmuserremoveItem){
                crmuserremoveItem.del = 'D';
                delTableData.push(crmuserremoveItem);
                component.set("v.delTableData", delTableData);

                crmuserDatas = crmuserDatas.filter(item => item.key !== rowKey);
                component.set("v.crmuserDatas", crmuserDatas);

                MasterData.push(crmuserremoveItem);
                component.set("v.MasterData", MasterData);
            }
        }

    },

    handleClose : function(component, event, helper) {
        helper.close(component);
    },

    handleSave : function(component, event, helper) {
        try {
            helper.reverseSpinner(component);
    
            const isPortal = component.get('v.isPortal');
            const recordId = component.get('v.recordId');
            const crmuserDatas = component.get('v.crmuserDatas');
            const dealerDatas = component.get('v.dealerDatas');
            const delTableData = component.get('v.delTableData');

            var action = component.get("c.dnsaFactoryOptionSave");
            if(isPortal){
                action.setParams({ 
                    recordId : recordId,
                    selTableData : dealerDatas,
                    isPortal : isPortal
                });
            }else{
                action.setParams({ 
                    recordId : recordId,
                    selTableData : crmuserDatas.concat(delTableData),
                    isPortal : isPortal
                });
            }
            action.setCallback(this, function(response) {
                var state = response.getState();
                // console.log('state : ' + state);
                if(state === "SUCCESS"){
                    helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_MSG_AccessoryCreated"));
                    helper.close(component);
                } else {
                    helper.handleError('selectedItems', response.getError());
                    helper.reverseSpinner(component);
                }
            });
            $A.enqueueAction(action);
            
        } catch (error) {
            helper.reverseSpinner(component);
        }
    }
})