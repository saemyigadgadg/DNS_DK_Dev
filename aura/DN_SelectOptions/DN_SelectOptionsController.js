({
    doInit : function(component, event, helper) {
        var recordIds = component.get("v.recordIds");
        var tselData = component.get('v.tselData');
        var action = component.get("c.getSelectOptions");
        var lineItemList = component.get('v.lineItemList');
        // console.log('selectId : ' + JSON.stringify(lineItemList));
        action.setParams({
            quoteLineId : lineItemList[0].Id,
            reset : ''
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            try {
                if(state === "SUCCESS") {
                    var returnVal = response.getReturnValue();
                    // console.log("🚀 ~ action.setCallback ~ returnVal:", returnVal);
                    console.log('returnVal.NOPLANT: ' + returnVal.NOPLANT);
                    console.log('returnVal.NOPLANT: ' + JSON.stringify(returnVal));

                    if(returnVal.isDNSA != undefined && returnVal.isDNSA.length > 0) {
                        if(returnVal.empty != undefined) {
                            if(returnVal.empty[0].Id == 'empty') {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": $A.get("$Label.c.DNS_M_Error"),
                                    "message":'Please enter the Requested Ship Date for the Quote Line Item.',
                                    "type": "error"
                                });
                                toastEvent.fire();
                                        
                                var modalEvent = component.getEvent('modalEvent');
                                modalEvent.setParams({
                                    "modalName": 'DN_SelectOptions',
                                    "actionName": 'Close',
                                    "message": 'CloseCV'
                                });
                                modalEvent.fire();
            
                                $A.get('e.force:refreshView').fire();
                                return;
                            }
                        }
                    }
                    console.log('returnVal.O_RETURN.length : ' + JSON.stringify(returnVal.O_RETURN));
                    console.log('returnVal.O_RETURN.length : ' + JSON.stringify(returnVal));

                    if(returnVal.O_RETURN != undefined && returnVal.O_RETURN.length > 0){
                        var resultsToast = $A.get("e.force:showToast");
                        if(returnVal.O_RETURN[0].CODE == 'NOCV'){
                            resultsToast.setParams({
                            "type" : "Error",
                            "title": $A.get("$Label.c.DNS_M_Error"),
                            "message": returnVal.O_RETURN[0].MSG

                            });
                            resultsToast.fire();
                        }
                        if(returnVal.O_RETURN[0].CODE == 'INCOMPLETE'){
                            resultsToast.setParams({
                            "type" : "Error",
                            "title": $A.get("$Label.c.DNS_M_Error"),
                            "message": returnVal.O_RETURN[0].MSG

                            });
                            resultsToast.fire();
                        }
                        component.set("v.status", returnVal.O_RETURN[0].CODE);
                        component.set("v.errormessage", returnVal.O_RETURN[0].MSG);
                    }
                    // component.set("v.status", returnVal.O_RETURN[0].CODE);
                    // component.set("v.errormessage", returnVal.O_RETURN[0].MSG);

                    if(returnVal.NOPLANT != undefined && returnVal.NOPLANT[0].TYPE == 'NOPLANT'){
                        var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": $A.get("$Label.c.DNS_M_Error"),
                                    "message":$A.get("$Label.c.DNS_M_NOCVPLANT"),
                                    "type": "error"
                                });
                                toastEvent.fire();
                                
                                var modalEvent = component.getEvent('modalEvent');
                                // console.log('modalEvent', modalEvent);
                                modalEvent.setParams({
                                    "modalName": 'DN_SelectOptions',
                                    "actionName": 'Close',
                                    "message": 'CloseCV'
                                });
                                modalEvent.fire();
    
                            $A.get('e.force:refreshView').fire();
                    }

                    if(returnVal.O_RETURN != undefined && returnVal.O_RETURN[0].TYPE == 'E'){
                        var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": $A.get("$Label.c.DNS_M_Error"),
                                    "message":returnVal.O_RETURN[0].MSG,
                                    "type": "error"
                                });
                                toastEvent.fire();
                                
                                var modalEvent = component.getEvent('modalEvent');
                                // console.log('modalEvent', modalEvent);
                                modalEvent.setParams({
                                    "modalName": 'DN_SelectOptions',
                                    "actionName": 'Close',
                                    "message": 'CloseCV'
                                });
                                modalEvent.fire();
    
                            $A.get('e.force:refreshView').fire();
                    }

                    // console.log(returnVal.T_VALUE);
                    // console.log(returnVal.DEFAULT);
                    var selectData = returnVal.T_VALUE;
                    var cvData = [];
                    var j = 0;
                    for(var i = 0; i < selectData.length; i++) {
                        if(i == 0){
                            cvData.push({
                                        Id : selectData[i].Id, 
                                        c : selectData[i].ATNAM, 
                                        c_value : selectData[i].ATBEZ, 
                                        v_code : [{[j] : selectData[i].ATWRT}], 
                                        v:[selectData[i].ATWTB], 
                                        selectedValue:[{[j] : selectData[i].ATWTB}], 
                                        color: selectData[i].Color, 
                                        price: [selectData[i].KBETR],
                                        mCheck : selectData[i].mCheck
                                    });
                        }else{
                            if(selectData[i-1].ATNAM != selectData[i].ATNAM){
                                j = 0;
                                cvData.push({Id : selectData[i].Id, 
                                             c : selectData[i].ATNAM, 
                                             c_value : selectData[i].ATBEZ, 
                                             v_code : [{[j] : selectData[i].ATWRT}], 
                                             v:[selectData[i].ATWTB], 
                                             selectedValue:[{[j] : selectData[i].ATWTB}], 
                                             color: selectData[i].Color, 
                                             price: [selectData[i].KBETR],
                                             mCheck : selectData[i].mCheck
                                            });
                            }else{
                                j++;
                                cvData[cvData.length-1].v.push(selectData[i].ATWTB);
                                cvData[cvData.length-1].v_code.push({[j] : selectData[i].ATWRT});
                                cvData[cvData.length-1].price.push(selectData[i].KBETR);
                            }
                        }
                    }
                    for(var i = 0; i < cvData.length; i++){
                        // cvData[i].color = false;
                        cvData[i].index = i;
                        // console.log('cvData' + i + ' : ' + JSON.stringify(cvData[i]));
                    }
                    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    var defaultData = returnVal.DEFAULT;
                    var defcvData = [];
                    var k = 0;
                    for(var i = 0; i < defaultData.length; i++) {
                        if(i == 0){
                            defcvData.push({c : defaultData[i].ATNAM, 
                                            c_value : defaultData[i].ATBEZ, 
                                            v_code : [{[k] : defaultData[i].ATWRT}], 
                                            v:[defaultData[i].ATWTB], 
                                            selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                            color: defaultData[i].Color, 
                                            price: [selectData[i].KBETR],
                                            mCheck : selectData[i].mCheck
                                        });
                        }else{
                            if(defaultData[i-1].ATNAM != defaultData[i].ATNAM){
                                k = 0;
                                defcvData.push({c : defaultData[i].ATNAM, 
                                                c_value : defaultData[i].ATBEZ, 
                                                v_code : [{[k] : defaultData[i].ATWRT}], 
                                                v:[defaultData[i].ATWTB], 
                                                selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                                color: defaultData[i].Color, 
                                                price: [defaultData[i].KBETR],
                                                mCheck : selectData[i].mCheck
                                            });
                            }else{
                                k++;
                                defcvData[defcvData.length-1].v.push(defaultData[i].ATWTB);
                                defcvData[defcvData.length-1].v_code.push({[k] : defaultData[i].ATWRT});
                                defcvData[defcvData.length-1].price.push(defaultData[i].KBETR);
                            }
                        }
                    }
                    // console.log('여기1');
                    // console.log('returnVal.SELCV : ' + returnVal.SELCV);
                    if(returnVal.SELCV.length > 0){
                        for(var i = 0; i < returnVal.SELCV.length; i++){
                            tselData.push({ATNAM : returnVal.SELCV[i].ATNAM,
                                ATWRT : returnVal.SELCV[i].ATWRT,
                                ZSEQNO : returnVal.SELCV[i].ZSEQNO
                            });
                        }
                    }
                    //DNSA인 경우
                    if(returnVal.isDNSA != undefined && returnVal.isDNSA.length > 0){
                        if(returnVal.FACTORY != undefined && returnVal.FACTORY.length > 0){
                            component.set('v.factoryData', returnVal.FACTORY);
                            component.set('v.isDNSA', true);
                        }
                        if(returnVal.previeousCVList != undefined && returnVal.previeousCVList.length > 0){
                            component.set('v.previeousCVList', returnVal.previeousCVList);
                            component.set('v.isDNSA', true);
                        }
                    }else{ //DNSA가 아닌경우
                        if(returnVal.previeousCVList != undefined && returnVal.previeousCVList.length > 0){
                            component.set('v.previeousCVList', returnVal.previeousCVList);
                            component.set('v.isPrevious', true);
                        }
                    }
                    
                    
                    // console.log('여기2');
                    cvData.forEach(item => {
                        const lastIndex = item.v_code.length; // 현재 마지막 index
                        // v_code에 새로운 object 추가
                        const newVCode = {};
                        newVCode[lastIndex] = ""; // 예: { "2": "" }
                        item.v_code.push(newVCode);
                      
                        // v에 "No Entry" 추가
                        item.v.push("No Entry");
                      });
                    component.set("v.tselData", tselData);
                    component.set("v.defcvData", defcvData);
                    component.set("v.initData", cvData);
                    component.set("v.options", cvData);
                    component.set("v.dataLoad", true);
    
                    component.set("v.status", returnVal.O_RETURN[0].CODE);
                    component.set("v.errormessage", returnVal.O_RETURN[0].MSG);
                    //   console.log('returnVal.O_RETURNCOMPLEX : ' + returnVal.O_RETURNCOMPLEX[0].TYPE);
                    if(returnVal.O_RETURNCOMPLEX != undefined && returnVal.O_RETURNCOMPLEX[0].TYPE == 'COMPLEXEDCV'){
                        component.set('v.essentialReset', true);
                    }
                }else{
                    component.set("v.dataLoad", true);  // 데이터 로드 실패 표시
                    component.set("v.isCVvalue", false);
                    console.error("옵션을 로드하는 중에 오류가 발생했습니다.");
    
                    var modalEvent = component.getEvent('modalEvent');
                    // console.log('modalEvent', modalEvent);
                    modalEvent.setParams({
                        "modalName": 'DN_SelectOptions',
                        "actionName": 'Close',
                        "message": 'CloseCV'
                    });
                    modalEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    component.set('v.lineItemList', []);
    
                }
            } catch (error) {
                console.log('Error ::: ' + error);
                console.log('Error ::: ' + error.message);
            }
            
        });
        $A.enqueueAction(action);
        
    },

    handleResetConfirm : function(component, event, helper) {
        component.set("v.dataLoad", false);

        var recordIds = component.get("v.recordIds");
        component.set('v.tselData ', []);
        var tselData = component.get('v.tselData');
        component.set("v.defcvData", []);
        component.set("v.initData", []);
        component.set("v.options", []);
        component.set("v.upRecord", []);
        component.set('v.essentialReset', false);
        
        var action = component.get("c.getSelectOptions");
        var lineItemList = component.get('v.lineItemList');
        // console.log('selectId : ' + JSON.stringify(lineItemList));
        action.setParams({
            quoteLineId : lineItemList[0].Id,
            reset : 'reset'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                if(returnVal.O_RETURN[0].TYPE == 'E'){
                    var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get("$Label.c.DNS_M_Error"),
                                "message":returnVal.O_RETURN[0].MSG,
                                "type": "error"
                            });
                            toastEvent.fire();
                            
                            var modalEvent = component.getEvent('modalEvent');
                            // console.log('modalEvent', modalEvent);
                            modalEvent.setParams({
                                "modalName": 'DN_SelectOptions',
                                "actionName": 'Close',
                                "message": 'CloseCV'
                            });
                            modalEvent.fire();

                        $A.get('e.force:refreshView').fire();
                }
                // console.log(returnVal.T_VALUE);
                // console.log(returnVal.DEFAULT);
                var selectData = returnVal.T_VALUE;
                var cvData = [];
                var j = 0;
                for(var i = 0; i < selectData.length; i++) {
                    if(i == 0){
                        cvData.push({
                                    Id : selectData[i].Id, 
                                    c : selectData[i].ATNAM, 
                                    c_value : selectData[i].ATBEZ, 
                                    v_code : [{[j] : selectData[i].ATWRT}], 
                                    v:[selectData[i].ATWTB], 
                                    selectedValue:[{[j] : selectData[i].ATWTB}], 
                                    color: selectData[i].Color, 
                                    price: [selectData[i].KBETR],
                                    mCheck : selectData[i].mCheck
                                });
                    }else{
                        if(selectData[i-1].ATNAM != selectData[i].ATNAM){
                            j = 0;
                            cvData.push({Id : selectData[i].Id, 
                                         c : selectData[i].ATNAM, 
                                         c_value : selectData[i].ATBEZ, 
                                         v_code : [{[j] : selectData[i].ATWRT}], 
                                         v:[selectData[i].ATWTB], 
                                         selectedValue:[{[j] : selectData[i].ATWTB}], 
                                         color: selectData[i].Color, 
                                         price: [selectData[i].KBETR],
                                         mCheck : selectData[i].mCheck
                                        });
                        }else{
                            j++;
                            cvData[cvData.length-1].v.push(selectData[i].ATWTB);
                            cvData[cvData.length-1].v_code.push({[j] : selectData[i].ATWRT});
                            cvData[cvData.length-1].price.push(selectData[i].KBETR);
                        }
                    }
                }
                for(var i = 0; i < cvData.length; i++){
                    // cvData[i].color = false;
                    cvData[i].index = i;
                    // console.log('cvData' + i + ' : ' + JSON.stringify(cvData[i]));
                }
                /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                var defaultData = returnVal.DEFAULT;
                var defcvData = [];
                var k = 0;
                for(var i = 0; i < defaultData.length; i++) {
                    if(i == 0){
                        defcvData.push({c : defaultData[i].ATNAM, 
                                        c_value : defaultData[i].ATBEZ, 
                                        v_code : [{[k] : defaultData[i].ATWRT}], 
                                        v:[defaultData[i].ATWTB], 
                                        selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                        color: defaultData[i].Color, 
                                        price: [selectData[i].KBETR],
                                        mCheck : selectData[i].mCheck
                                    });
                    }else{
                        if(defaultData[i-1].ATNAM != defaultData[i].ATNAM){
                            k = 0;
                            defcvData.push({c : defaultData[i].ATNAM, 
                                            c_value : defaultData[i].ATBEZ, 
                                            v_code : [{[k] : defaultData[i].ATWRT}], 
                                            v:[defaultData[i].ATWTB], 
                                            selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                            color: defaultData[i].Color, 
                                            price: [defaultData[i].KBETR],
                                            mCheck : selectData[i].mCheck
                                        });
                        }else{
                            k++;
                            defcvData[defcvData.length-1].v.push(defaultData[i].ATWTB);
                            defcvData[defcvData.length-1].v_code.push({[k] : defaultData[i].ATWRT});
                            defcvData[defcvData.length-1].price.push(defaultData[i].KBETR);
                        }
                    }
                }
                // console.log('여기1');
                // console.log('returnVal.SELCV : ' + returnVal.SELCV);
                if(returnVal.SELCV.length > 0){
                    for(var i = 0; i < returnVal.SELCV.length; i++){
                        tselData.push({ATNAM : returnVal.SELCV[i].ATNAM,
                            ATWRT : returnVal.SELCV[i].ATWRT,
                            ZSEQNO : returnVal.SELCV[i].ZSEQNO
                        });
                    }
                }
                //DNSA인 경우
                if(returnVal.isDNSA != undefined && returnVal.isDNSA.length > 0){
                    if(returnVal.FACTORY != undefined && returnVal.FACTORY.length > 0){
                        component.set('v.factoryData', returnVal.FACTORY);
                        component.set('v.isDNSA', true);
                    }
                    if(returnVal.previeousCVList != undefined && returnVal.previeousCVList.length > 0){
                        component.set('v.previeousCVList', returnVal.previeousCVList);
                        component.set('v.isDNSA', true);
                    }
                }else{ //DNSA가 아닌경우
                    if(returnVal.previeousCVList != undefined && returnVal.previeousCVList.length > 0){
                        component.set('v.previeousCVList', returnVal.previeousCVList);
                        component.set('v.isPrevious', true);
                    }
                }
                
                
                // console.log('여기2');
                cvData.forEach(item => {
                    const lastIndex = item.v_code.length; // 현재 마지막 index
                    // v_code에 새로운 object 추가
                    const newVCode = {};
                    newVCode[lastIndex] = ""; // 예: { "2": "" }
                    item.v_code.push(newVCode);
                  
                    // v에 "No Entry" 추가
                    item.v.push("No Entry");
                  });
                component.set("v.tselData", tselData);
                component.set("v.defcvData", defcvData);
                component.set("v.initData", cvData);
                component.set("v.options", cvData);
                component.set("v.dataLoad", true);

                component.set("v.status", returnVal.O_RETURN[0].CODE);
                component.set("v.errormessage", returnVal.O_RETURN[0].MSG);
                component.set('v.isConfirmReset', false);        

            }else{
                component.set("v.dataLoad", true);  // 데이터 로드 실패 표시
                component.set("v.isCVvalue", false);
                console.error("옵션을 로드하는 중에 오류가 발생했습니다.");

                var modalEvent = component.getEvent('modalEvent');
                // console.log('modalEvent', modalEvent);
                modalEvent.setParams({
                    "modalName": 'DN_SelectOptions',
                    "actionName": 'Close',
                    "message": 'CloseCV'
                });
                modalEvent.fire();
                $A.get('e.force:refreshView').fire();
                component.set('v.lineItemList', []);

            }
        });
        $A.enqueueAction(action);
        
    },

    handleChange : function(component, event, helper) {
        component.set("v.dataLoad", false);

        var tselData = component.get('v.tselData');
        var index = event.getSource().get("v.name");
        // console.log('parent Index : ' +  index);

        var selectedIndex = event.getSource().get("v.value");
        // console.log('child Index : ' + selectedIndex);
        // console.log('event.getSource() : ' + event.getSource());
        var options = component.get("v.options");

        var defcvData = component.get("v.defcvData");

        // if(selectedIndex == 0){
        //     options[index].color = false;
        // }else{
        //     options[index].color = true;
        // }

        // component.set("v.options", options);

        var upRecord = component.get("v.upRecord");

        var initData = component.get("v.initData");

        var selectedValue = initData[index].selectedValue;
        // console.log(selectedValue);
        for(var i = 0; i < initData.length; i++){
            if (!upRecord[i]) {
                upRecord[i] = {
                    c_code: '',
                    c_value: '',
                    v_code: '',
                    v_value: '',
                    Color : false,
                    price: 0,
                };
            }
            if(index == i){
                upRecord[i].Id     = initData[index].Id;
                upRecord[i].c_code = initData[index].c;
                upRecord[i].c_value = initData[index].c_value;
                upRecord[i].v_code = initData[index].v_code[selectedIndex][selectedValue];
                upRecord[i].v_value = initData[index].v[selectedIndex];
                upRecord[i].price = initData[index].price[selectedIndex];
                tselData.push({ATNAM : initData[index].c,
                    ATWRT : initData[index].v_code[selectedIndex][selectedValue],
                    ZSEQNO : tselData.length + 1
                });
            }

        }
        // console.log('tselData : ' + JSON.stringify(tselData));
        // console.log(JSON.stringify(upRecord));
        // console.log(defcvData[index].v_code[0][0]);
        // console.log(upRecord[index].v_code);
        // if(defcvData[index].v_code[0][0] == upRecord[index].v_code){
        //     options[index].color = false;
        // }else{
        //     options[index].color = true;
        // }
        component.set("v.tselData", tselData);
        component.set("v.options", options);
        component.set('v.upRecord', upRecord);

        var lineItemList = component.get('v.lineItemList');
        var action = component.get("c.changeOption");
        var cvData = [];
        var defcvData = [];

        action.setParams({
            quoteLineId : lineItemList[0].Id,
            selectedValue : tselData,
            isODLogic : component.get('v.isOn')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                // console.log(returnVal.T_VALUE);
                // console.log(returnVal.DEFAULT);
                var selectData = returnVal.T_VALUE;
                
                var j = 0;
                for(var i = 0; i < selectData.length; i++) {
                    if(i == 0){
                        cvData.push({Id : selectData[i].Id, 
                                    c : selectData[i].ATNAM, 
                                    c_value : selectData[i].ATBEZ, 
                                    v_code : [{[j] : selectData[i].ATWRT}], 
                                    v:[selectData[i].ATWTB], 
                                    selectedValue:[{[j] : selectData[i].ATWTB}], 
                                    color: selectData[i].Color, 
                                    price: [selectData[i].KBETR],
                                    mCheck : selectData[i].mCheck
                                });
                    }else{
                        if(selectData[i-1].ATNAM != selectData[i].ATNAM){
                            j = 0;
                            cvData.push({Id : selectData[i].Id, 
                                         c : selectData[i].ATNAM, 
                                         c_value : selectData[i].ATBEZ, 
                                         v_code : [{[j] : selectData[i].ATWRT}], 
                                         v:[selectData[i].ATWTB], 
                                         selectedValue:[{[j] : selectData[i].ATWTB}], 
                                         color: selectData[i].Color, 
                                         price: [selectData[i].KBETR],
                                         mCheck : selectData[i].mCheck
                                        });
                        }else{
                            j++;
                            cvData[cvData.length-1].v.push(selectData[i].ATWTB);
                            cvData[cvData.length-1].v_code.push({[j] : selectData[i].ATWRT});
                            cvData[cvData.length-1].price.push(selectData[i].KBETR);
                        }
                    }
                }
                
                for(var i = 0; i < cvData.length; i++){
                    // cvData[i].color = false;
                    cvData[i].index = i;
                    // console.log('cvData' + i + ' : ' + JSON.stringify(cvData[i]));
                }
                
                /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                var defaultData = returnVal.DEFAULT;
                var k = 0;
                for(var i = 0; i < defaultData.length; i++) {
                    if(i == 0){
                        defcvData.push({c : defaultData[i].ATNAM, 
                                        c_value : defaultData[i].ATBEZ, 
                                        v_code : [{[k] : defaultData[i].ATWRT}], 
                                        v:[defaultData[i].ATWTB], 
                                        selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                        color: defaultData[i].Color, 
                                        price: [selectData[i].KBETR],
                                        mCheck : selectData[i].mCheck
                                    });
                    }else{
                        if(defaultData[i-1].ATNAM != defaultData[i].ATNAM){
                            k = 0;
                            defcvData.push({c : defaultData[i].ATNAM, 
                                            c_value : defaultData[i].ATBEZ, 
                                            v_code : [{[k] : defaultData[i].ATWRT}], 
                                            v:[defaultData[i].ATWTB], 
                                            selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                            color: defaultData[i].Color, 
                                            price: [defaultData[i].KBETR],
                                            mCheck : selectData[i].mCheck
                                        });
                        }else{
                            k++;
                            defcvData[defcvData.length-1].v.push(defaultData[i].ATWTB);
                            defcvData[defcvData.length-1].v_code.push({[k] : defaultData[i].ATWRT});
                            defcvData[defcvData.length-1].price.push(defaultData[i].KBETR);
                        }
                    }
                }
                // for(var i = 0; i < defcvData.length; i++){
                //     // cvData[i].color = false;
                //     defcvData[i].index = i;
                //     console.log('defcvData' + i + ' : ' + JSON.stringify(defcvData[i]));

                // }
                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //T_INCON_VALUE
                var inconData = returnVal.T_INCON_VALUE;
                var tInconValue = [];
                var v = 0;
                if(inconData.length > 0){
                    for(var i = 0; i < inconData.length; i++) {
                        if(i == 0){
                            tInconValue.push({Id : inconData[i].Id, 
                                        c : inconData[i].ATNAM, 
                                        c_value : inconData[i].ATBEZ, 
                                        v_code : [{[v] : inconData[i].ATWRT}], 
                                        v:[inconData[i].ATWTB], 
                                        selectedValue:[{[v] : inconData[i].ATWTB}], 
                                        color: inconData[i].Color, 
                                        price: [inconData[i].KBETR]});
                        }else{
                            if(inconData[i-1].ATNAM != inconData[i].ATNAM){
                                v = 0;
                                tInconValue.push({Id : inconData[i].Id, 
                                             c : inconData[i].ATNAM, 
                                             c_value : inconData[i].ATBEZ, 
                                             v_code : [{[v] : inconData[i].ATWRT}], 
                                             v:[inconData[i].ATWTB], 
                                             selectedValue:[{[v] : inconData[i].ATWTB}], 
                                             color: inconData[i].Color, 
                                             price: [inconData[i].KBETR]});
                            }else{
                                v++;
                                tInconValue[tInconValue.length-1].v.push(inconData[i].ATWTB);
                                tInconValue[tInconValue.length-1].v_code.push({[v] : inconData[i].ATWRT});
                                tInconValue[tInconValue.length-1].price.push(inconData[i].KBETR);
                            }
                        }
                    }
                    
                    component.set("v.isInconvalue", true);
                    component.set("v.isCVvalue", false);
                    component.set("v.tInconValue", tInconValue);
                }

                component.set("v.defcvData", defcvData);
                cvData.forEach(item => {
                    const lastIndex = item.v_code.length; // 현재 마지막 index
                    // v_code에 새로운 object 추가
                    const newVCode = {};
                    newVCode[lastIndex] = ""; // 예: { "2": "" }
                    item.v_code.push(newVCode);
                  
                    // v에 "No Entry" 추가
                    item.v.push("No Entry");
                });
                
                component.set("v.initData", cvData);
                component.set("v.options", cvData);
                component.set("v.dataLoad", true);
                // for(var i = 0; i < component.get("v.initData").length; i++){
                //     console.log('initData' + i + ' : ' + JSON.stringify(component.get("v.initData")[i]));
                // }
                // console.log('returnVal.O_RETURN : ' + returnVal.O_RETURN);
                // console.log('returnVal.O_RETURN : ' + JSON.stringify(returnVal.O_RETURN));
                if(returnVal.O_RETURN.length > 0){
                    var resultsToast = $A.get("e.force:showToast");
                    if(returnVal.O_RETURN[0].CODE == 'NOCV'){
                        resultsToast.setParams({
                        "type" : "Error",
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": returnVal.O_RETURN[0].MSG

                        });
                        resultsToast.fire();
                    }
                    if(returnVal.O_RETURN[0].CODE == 'INCOMPLETE'){
                        resultsToast.setParams({
                        "type" : "Error",
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": returnVal.O_RETURN[0].MSG

                        });
                        resultsToast.fire();
                    }
                }
                component.set("v.status", returnVal.O_RETURN[0].CODE);
                component.set("v.errormessage", returnVal.O_RETURN[0].MSG);
                
                
            }else{
                component.set("v.dataLoad", true);  // 데이터 로드 실패 표시
                component.set("v.isCVvalue", false);
                console.error("옵션을 로드하는 중에 오류가 발생했습니다.");
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);

    },

    handleChangeIncon : function(component, event, helper) {

        var tselData = component.get('v.tselData');
        var index = event.getSource().get("v.name");
        // console.log('parent Index : ' +  index);

        var selectedIndex = event.getSource().get("v.value");
        // console.log('child Index : ' + selectedIndex);
        var options = component.get("v.options");

        var defcvData = component.get("v.defcvData");

        var upRecord = component.get("v.upRecord");

        var initData = component.get("v.initData");
        // console.log('initData:', JSON.stringify(initData));
        // console.log('length:', initData.length);
        var tInconValue = component.get("v.tInconValue");
        // console.log('tInconValue:', JSON.stringify(tInconValue));

        var selectedValue = tInconValue[index].selectedValue;
        // console.log(JSON.stringify(selectedValue));
        // console.log('오냐1');
        for(var i = 0; i < tInconValue.length; i++){
            if (!upRecord[i]) {
                upRecord[i] = {
                    c_code: '',
                    c_value: '',
                    v_code: '',
                    v_value: '',
                    Color : false,
                    price: 0,
                };
            }
            if(index == i){
                // upRecord[i].Id     = initData[index].Id;
                upRecord[i].c_code = tInconValue[index].c;
                upRecord[i].c_value = tInconValue[index].c_value;
                upRecord[i].v_code = tInconValue[index].v_code[selectedIndex][selectedValue];
                upRecord[i].v_value = tInconValue[index].v[selectedIndex];
                upRecord[i].price = tInconValue[index].price[selectedIndex];
                tselData.push({ATNAM : tInconValue[index].c,
                    ATWRT : tInconValue[index].v_code[selectedIndex][selectedValue],
                    ZSEQNO : tselData.length + 1
                });
            }

        }
        // console.log('오냐2');

        // console.log('tselData : ' + JSON.stringify(tselData));
        // console.log(JSON.stringify(upRecord));
        // console.log(defcvData[index].v_code[0][0]);
        // console.log(upRecord[index].v_code);
        component.set("v.tselData", tselData);
        component.set('v.upRecord', upRecord);

    },

    handleSubminIncon:function(component, event, helper){
        
        component.set("v.dataLoad", false); 
        var initData = component.get("v.initData");
        // console.log('initData:', JSON.stringify(initData));
        var tselData = component.get('v.tselData');
        var lineItemList = component.get('v.lineItemList');
        var action = component.get("c.changeOption");
        var cvData = [];
        var defcvData = [];

        action.setParams({
            quoteLineId : lineItemList[0].Id,
            selectedValue : tselData
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                // console.log(returnVal.T_VALUE);
                // console.log(returnVal.DEFAULT);
                var selectData = returnVal.T_VALUE;
                
                var j = 0;
                for(var i = 0; i < selectData.length; i++) {
                    if(i == 0){
                        cvData.push({Id : selectData[i].Id, 
                                    c : selectData[i].ATNAM, 
                                    c_value : selectData[i].ATBEZ, 
                                    v_code : [{[j] : selectData[i].ATWRT}], 
                                    v:[selectData[i].ATWTB], 
                                    selectedValue:[{[j] : selectData[i].ATWTB}], 
                                    color: selectData[i].Color, 
                                    price: [selectData[i].KBETR],
                                    mCheck : selectData[i].mCheck
                                });
                    }else{
                        if(selectData[i-1].ATNAM != selectData[i].ATNAM){
                            j = 0;
                            cvData.push({Id : selectData[i].Id, 
                                         c : selectData[i].ATNAM, 
                                         c_value : selectData[i].ATBEZ, 
                                         v_code : [{[j] : selectData[i].ATWRT}], 
                                         v:[selectData[i].ATWTB], 
                                         selectedValue:[{[j] : selectData[i].ATWTB}], 
                                         color: selectData[i].Color, 
                                         price: [selectData[i].KBETR],
                                         mCheck : selectData[i].mCheck
                                        });
                        }else{
                            j++;
                            cvData[cvData.length-1].v.push(selectData[i].ATWTB);
                            cvData[cvData.length-1].v_code.push({[j] : selectData[i].ATWRT});
                            cvData[cvData.length-1].price.push(selectData[i].KBETR);
                        }
                    }
                }
                for(var i = 0; i < cvData.length; i++){
                    // cvData[i].color = false;
                    cvData[i].index = i;
                    // console.log('cvData' + i + ' : ' + JSON.stringify(cvData[i]));
                }
                /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                var defaultData = returnVal.DEFAULT;
                var k = 0;
                for(var i = 0; i < defaultData.length; i++) {
                    if(i == 0){
                        defcvData.push({c : defaultData[i].ATNAM, 
                                        c_value : defaultData[i].ATBEZ, 
                                        v_code : [{[k] : defaultData[i].ATWRT}], 
                                        v:[defaultData[i].ATWTB], 
                                        selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                        color: defaultData[i].Color, 
                                        price: [selectData[i].KBETR],
                                        mCheck : selectData[i].mCheck
                                    });
                    }else{
                        if(defaultData[i-1].ATNAM != defaultData[i].ATNAM){
                            k = 0;
                            defcvData.push({c : defaultData[i].ATNAM, 
                                            c_value : defaultData[i].ATBEZ, 
                                            v_code : [{[k] : defaultData[i].ATWRT}], 
                                            v:[defaultData[i].ATWTB], 
                                            selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                            color: defaultData[i].Color, 
                                            price: [defaultData[i].KBETR],
                                            mCheck : selectData[i].mCheck
                                        });
                        }else{
                            k++;
                            defcvData[defcvData.length-1].v.push(defaultData[i].ATWTB);
                            defcvData[defcvData.length-1].v_code.push({[k] : defaultData[i].ATWRT});
                            defcvData[defcvData.length-1].price.push(defaultData[i].KBETR);
                        }
                    }
                }
                // for(var i = 0; i < defcvData.length; i++){
                //     // cvData[i].color = false;
                //     defcvData[i].index = i;
                //     console.log('defcvData' + i + ' : ' + JSON.stringify(defcvData[i]));

                // }
                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //T_INCON_VALUE
                var inconData = returnVal.T_INCON_VALUE;
                var tInconValue = [];
                var v = 0;
                if(inconData.length > 0){
                    for(var i = 0; i < inconData.length; i++) {
                        if(i == 0){
                            tInconValue.push({Id : inconData[i].Id, 
                                        c : inconData[i].ATNAM, 
                                        c_value : inconData[i].ATBEZ, 
                                        v_code : [{[v] : inconData[i].ATWRT}], 
                                        v:[inconData[i].ATWTB], 
                                        selectedValue:[{[v] : inconData[i].ATWTB}], 
                                        color: inconData[i].Color, 
                                        price: [inconData[i].KBETR]});
                        }else{
                            if(inconData[i-1].ATNAM != inconData[i].ATNAM){
                                v = 0;
                                tInconValue.push({Id : inconData[i].Id, 
                                             c : inconData[i].ATNAM, 
                                             c_value : inconData[i].ATBEZ, 
                                             v_code : [{[v] : inconData[i].ATWRT}], 
                                             v:[inconData[i].ATWTB], 
                                             selectedValue:[{[v] : inconData[i].ATWTB}], 
                                             color: inconData[i].Color, 
                                             price: [inconData[i].KBETR]});
                            }else{
                                v++;
                                tInconValue[tInconValue.length-1].v.push(inconData[i].ATWTB);
                                tInconValue[tInconValue.length-1].v_code.push({[v] : inconData[i].ATWRT});
                                tInconValue[tInconValue.length-1].price.push(inconData[i].KBETR);
                            }
                        }
                    }
                    
                    component.set("v.isInconvalue", true);
                    component.set("v.isCVvalue", false);
                    component.set("v.tInconValue", tInconValue);
                }

                component.set("v.defcvData", defcvData);
                cvData.forEach(item => {
                    const lastIndex = item.v_code.length; // 현재 마지막 index
                    // v_code에 새로운 object 추가
                    const newVCode = {};
                    newVCode[lastIndex] = ""; // 예: { "2": "" }
                    item.v_code.push(newVCode);
                  
                    // v에 "No Entry" 추가
                    item.v.push("No Entry");
                });
                component.set("v.initData", cvData);
                component.set("v.options", cvData);
                // for(var i = 0; i < component.get("v.initData").length; i++){
                //     console.log('initData' + i + ' : ' + JSON.stringify(component.get("v.initData")[i]));
                // }
                if(returnVal.O_RETURN.length > 0){
                    var resultsToast = $A.get("e.force:showToast");
                    if(returnVal.O_RETURN[0].CODE == 'NOCV'){
                        resultsToast.setParams({
                        "type" : "Error",
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": returnVal.O_RETURN[0].MSG

                        });
                        resultsToast.fire();
                    }
                    if(returnVal.O_RETURN[0].CODE == 'INCOMPLETE'){
                        resultsToast.setParams({
                        "type" : "Error",
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": returnVal.O_RETURN[0].MSG

                        });
                        resultsToast.fire();
                    }
                }
                component.set("v.status", returnVal.O_RETURN[0].CODE);
                component.set("v.errormessage", returnVal.O_RETURN[0].MSG);
                component.set("v.dataLoad", true);
                component.set("v.isCVvalue", true);
                component.set("v.isInconvalue", false);
            }
            else{
                component.set("v.dataLoad", true);  // 데이터 로드 실패 표시
                component.set("v.isCVvalue", false);
                console.error("옵션을 로드하는 중에 오류가 발생했습니다.");
                $A.get('e.force:refreshView').fire();
                

            }
        });
        $A.enqueueAction(action);
    },
    
    handleCloseIncon : function(component, event, helper){
        component.set("v.isCVvalue", true);
        component.set("v.isInconvalue", false);

    },
    handleClose : function(component, event, helper) {
        var modalEvent = component.getEvent('modalEvent');
        // console.log('modalEvent', modalEvent);
        modalEvent.setParams({
            "modalName": 'DN_SelectOptions',
            "actionName": 'Close',
            "message": 'CloseCV'
        });
        modalEvent.fire();
        $A.get('e.force:refreshView').fire();
        component.set('v.lineItemList', []);
    },

    handleSave : function(component, event, helper) {
        component.set("v.dataLoad", false); 
        var status = component.get("v.status");
        var odLogic = component.get('v.isOn');
        // console.log('status : ' + status);
        if(status != 'SUCCESS'){
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type" : "Error",
                "title": $A.get("$Label.c.DNS_M_Error"),
                "message": $A.get("$Label.c.DNS_M_CVSaveError")
                // "message": '현재상태에서저장불가', Saving is not possible in the current state.
                
                });
                resultsToast.fire();
            component.set("v.dataLoad", true); 
            return;
        }
        // if(odLogic == false){
        //     var resultsToast = $A.get("e.force:showToast");
        //     resultsToast.setParams({
        //         "type" : "Error",
        //         "title": $A.get("$Label.c.DNS_M_Error"),
        //         "message": $A.get("$Label.c.DN_M_ODLOGICCHECK")
        //         // "message": 'OD Logic 적용 후 저장 바랍니다.', Please save after applying the OD logic.

                
        //         });
        //         resultsToast.fire();
        //     component.set("v.dataLoad", true); 
        //     return;
        // }
        var initData = component.get("v.initData");
        var options = component.get("v.options");
        var lineItemList = component.get('v.lineItemList');
        var upRecord = component.get("v.upRecord");

        let hasEmptyV = options.some(item => {
            return item.c_value !== 'Variant condition for MM' &&
                   item.c_value !== 'MFPRO' &&
                   (!item.v || item.v.length === 0 || item.v[0] === '' || item.v[0] == null);
        });
        if(hasEmptyV){
            // var resultsToast = $A.get("e.force:showToast");
            //     resultsToast.setParams({
            //         "type" : "Error",
            //         "title": $A.get("$Label.c.DNS_M_Error"),
            //         "message": $A.get("$Label.c.DNS_M_ImpposibleCV")
            //         // "message": '현재상태에서저장불가', Saving is not possible in the current state.
                    
            //         });
            //         resultsToast.fire();
            //     component.set("v.dataLoad", true); 
            //     return;
        }
        
            try {
                for(var i = 0; i < options.length; i++){
                    if (!upRecord[i]) {
                        upRecord[i] = {}; // upRecord[i] 초기화
                    }

                    upRecord[i].v_value = options[i].v[0];
                    if(options[i].color){
                        upRecord[i].Color = options[i].color;
                    }else{
                        upRecord[i].Color = false;
                    }
                    upRecord[i].c_code = initData[i].c;
                    upRecord[i].c_value = initData[i].c_value;
                    upRecord[i].v_code = initData[i].v_code[0][0];
                    upRecord[i].v_value = initData[i].v[0];
                }
            } catch (error) {
                console.log('error : ' + error);
            }
            
            // console.log(JSON.stringify(upRecord));
            // console.log('1');
            var action = component.get("c.saveRecord");
            action.setParams({
                lineItemList: lineItemList,
                upRecord : upRecord
            });
            // console.log('2');
            action.setCallback(this, function(response) {
                // console.log('3');
                // console.log(response);
                var state = response.getState();
                // console.log('state : ' + state);
                if(state === "SUCCESS") {
                    // console.log('SUCCESS');
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type" : "Success",
                            "title": $A.get("$Label.c.DNS_M_Success"),
                            "message": $A.get('$Label.c.DNS_M_Success')

                        });
                        resultsToast.fire();
                        $A.get('e.force:refreshView').fire();

                        var modalEvent = component.getEvent('modalEvent');
                        modalEvent.setParams({
                            "modalName"     : 'DN_SelectOptions',
                            "actionName"    : 'Close',
                            "message"       : 'updateGroupId'
                        });
                        modalEvent.fire();
                        
                        component.set("v.dataLoad", true); 

                }else{
                    console.error(state.message);
                    }
            });
            $A.enqueueAction(action);
        
        
    },

    handlePanelLeftTabs : function(component, event, helper) {
        component.set('v.isTabSwitch', true);
    },

    handlePanelRightTabs : function(component, event, helper) {
        component.set('v.isTabSwitch', false);
    },

    openResetModal: function(component, event, helper) {
        component.set('v.isConfirmReset', true);
    },
    
    closeConfirmModal : function(component, event, helper) {
        component.set('v.isConfirmReset', false);        
    },

    toggleOn: function(component, event, helper) {
        try {
            component.set("v.isOn", true);
        component.set("v.dataLoad", false);

        var tselData = component.get('v.tselData');
        // var index = event.getSource().get("v.name");
        // console.log('parent Index : ' +  index);

        // var selectedIndex = event.getSource().get("v.value");
        // console.log('child Index : ' + selectedIndex);
        // console.log('event.getSource() : ' + event.getSource());
        var options = component.get("v.options");

        var defcvData = component.get("v.defcvData");

        // if(selectedIndex == 0){
        //     options[index].color = false;
        // }else{
        //     options[index].color = true;
        // }

        // component.set("v.options", options);

        var upRecord = component.get("v.upRecord");

        var initData = component.get("v.initData");

        // var selectedValue = initData[index].selectedValue;
        // console.log(selectedValue);
        // for(var i = 0; i < initData.length; i++){
        //     if (!upRecord[i]) {
        //         upRecord[i] = {
        //             c_code: '',
        //             c_value: '',
        //             v_code: '',
        //             v_value: '',
        //             Color : false,
        //             price: 0,
        //         };
        //     }
        //     if(index == i){
        //         upRecord[i].Id     = initData[index].Id;
        //         upRecord[i].c_code = initData[index].c;
        //         upRecord[i].c_value = initData[index].c_value;
        //         upRecord[i].v_code = initData[index].v_code[selectedIndex][selectedValue];
        //         upRecord[i].v_value = initData[index].v[selectedIndex];
        //         upRecord[i].price = initData[index].price[selectedIndex];
        //         tselData.push({ATNAM : initData[index].c,
        //             ATWRT : initData[index].v_code[selectedIndex][selectedValue],
        //             ZSEQNO : tselData.length + 1
        //         });
        //     }

        // }
        // console.log('tselData : ' + JSON.stringify(tselData));
        // console.log(JSON.stringify(upRecord));
        // console.log(defcvData[index].v_code[0][0]);
        // console.log(upRecord[index].v_code);
        // if(defcvData[index].v_code[0][0] == upRecord[index].v_code){
        //     options[index].color = false;
        // }else{
        //     options[index].color = true;
        // }
        // component.set("v.tselData", tselData);
        // component.set("v.options", options);
        // component.set('v.upRecord', upRecord);

        var lineItemList = component.get('v.lineItemList');
        var action = component.get("c.changeOption");
        var cvData = [];
        var defcvData = [];

        action.setParams({
            quoteLineId : lineItemList[0].Id,
            selectedValue : tselData,
            isODLogic : component.get('v.isOn')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                // console.log(returnVal.T_VALUE);
                // console.log(returnVal.DEFAULT);
                var selectData = returnVal.T_VALUE;
                
                var j = 0;
                for(var i = 0; i < selectData.length; i++) {
                    if(i == 0){
                        cvData.push({Id : selectData[i].Id, 
                                    c : selectData[i].ATNAM, 
                                    c_value : selectData[i].ATBEZ, 
                                    v_code : [{[j] : selectData[i].ATWRT}], 
                                    v:[selectData[i].ATWTB], 
                                    selectedValue:[{[j] : selectData[i].ATWTB}], 
                                    color: selectData[i].Color, 
                                    price: [selectData[i].KBETR],
                                    mCheck : selectData[i].mCheck
                                });
                    }else{
                        if(selectData[i-1].ATNAM != selectData[i].ATNAM){
                            j = 0;
                            cvData.push({Id : selectData[i].Id, 
                                         c : selectData[i].ATNAM, 
                                         c_value : selectData[i].ATBEZ, 
                                         v_code : [{[j] : selectData[i].ATWRT}], 
                                         v:[selectData[i].ATWTB], 
                                         selectedValue:[{[j] : selectData[i].ATWTB}], 
                                         color: selectData[i].Color, 
                                         price: [selectData[i].KBETR],
                                         mCheck : selectData[i].mCheck
                                        });
                        }else{
                            j++;
                            cvData[cvData.length-1].v.push(selectData[i].ATWTB);
                            cvData[cvData.length-1].v_code.push({[j] : selectData[i].ATWRT});
                            cvData[cvData.length-1].price.push(selectData[i].KBETR);
                        }
                    }
                }
                
                for(var i = 0; i < cvData.length; i++){
                    // cvData[i].color = false;
                    cvData[i].index = i;
                    // console.log('cvData' + i + ' : ' + JSON.stringify(cvData[i]));
                }
                
                /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                var defaultData = returnVal.DEFAULT;
                var k = 0;
                for(var i = 0; i < defaultData.length; i++) {
                    if(i == 0){
                        defcvData.push({c : defaultData[i].ATNAM, 
                                        c_value : defaultData[i].ATBEZ, 
                                        v_code : [{[k] : defaultData[i].ATWRT}], 
                                        v:[defaultData[i].ATWTB], 
                                        selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                        color: defaultData[i].Color, 
                                        price: [selectData[i].KBETR],
                                        mCheck : selectData[i].mCheck
                                    });
                    }else{
                        if(defaultData[i-1].ATNAM != defaultData[i].ATNAM){
                            k = 0;
                            defcvData.push({c : defaultData[i].ATNAM, 
                                            c_value : defaultData[i].ATBEZ, 
                                            v_code : [{[k] : defaultData[i].ATWRT}], 
                                            v:[defaultData[i].ATWTB], 
                                            selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                            color: defaultData[i].Color, 
                                            price: [defaultData[i].KBETR],
                                            mCheck : selectData[i].mCheck
                                        });
                        }else{
                            k++;
                            defcvData[defcvData.length-1].v.push(defaultData[i].ATWTB);
                            defcvData[defcvData.length-1].v_code.push({[k] : defaultData[i].ATWRT});
                            defcvData[defcvData.length-1].price.push(defaultData[i].KBETR);
                        }
                    }
                }
                // for(var i = 0; i < defcvData.length; i++){
                //     // cvData[i].color = false;
                //     defcvData[i].index = i;
                //     console.log('defcvData' + i + ' : ' + JSON.stringify(defcvData[i]));

                // }
                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //T_INCON_VALUE
                var inconData = returnVal.T_INCON_VALUE;
                var tInconValue = [];
                var v = 0;
                if(inconData.length > 0){
                    for(var i = 0; i < inconData.length; i++) {
                        if(i == 0){
                            tInconValue.push({Id : inconData[i].Id, 
                                        c : inconData[i].ATNAM, 
                                        c_value : inconData[i].ATBEZ, 
                                        v_code : [{[v] : inconData[i].ATWRT}], 
                                        v:[inconData[i].ATWTB], 
                                        selectedValue:[{[v] : inconData[i].ATWTB}], 
                                        color: inconData[i].Color, 
                                        price: [inconData[i].KBETR]});
                        }else{
                            if(inconData[i-1].ATNAM != inconData[i].ATNAM){
                                v = 0;
                                tInconValue.push({Id : inconData[i].Id, 
                                             c : inconData[i].ATNAM, 
                                             c_value : inconData[i].ATBEZ, 
                                             v_code : [{[v] : inconData[i].ATWRT}], 
                                             v:[inconData[i].ATWTB], 
                                             selectedValue:[{[v] : inconData[i].ATWTB}], 
                                             color: inconData[i].Color, 
                                             price: [inconData[i].KBETR]});
                            }else{
                                v++;
                                tInconValue[tInconValue.length-1].v.push(inconData[i].ATWTB);
                                tInconValue[tInconValue.length-1].v_code.push({[v] : inconData[i].ATWRT});
                                tInconValue[tInconValue.length-1].price.push(inconData[i].KBETR);
                            }
                        }
                    }
                    
                    component.set("v.isInconvalue", true);
                    component.set("v.isCVvalue", false);
                    component.set("v.tInconValue", tInconValue);
                }

                component.set("v.defcvData", defcvData);
                cvData.forEach(item => {
                    const lastIndex = item.v_code.length; // 현재 마지막 index
                    // v_code에 새로운 object 추가
                    const newVCode = {};
                    newVCode[lastIndex] = ""; // 예: { "2": "" }
                    item.v_code.push(newVCode);
                  
                    // v에 "No Entry" 추가
                    item.v.push("No Entry");
                });
                component.set("v.initData", cvData);
                component.set("v.options", cvData);
                component.set("v.dataLoad", true);
                // for(var i = 0; i < component.get("v.initData").length; i++){
                //     console.log('initData' + i + ' : ' + JSON.stringify(component.get("v.initData")[i]));
                // }
                // console.log('returnVal.O_RETURN : ' + returnVal.O_RETURN);
                // console.log('returnVal.O_RETURN : ' + JSON.stringify(returnVal.O_RETURN));
                if(returnVal.O_RETURN.length > 0){
                    var resultsToast = $A.get("e.force:showToast");
                    if(returnVal.O_RETURN[0].CODE == 'NOCV'){
                        resultsToast.setParams({
                        "type" : "Error",
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": returnVal.O_RETURN[0].MSG

                        });
                        resultsToast.fire();
                    }
                    if(returnVal.O_RETURN[0].CODE == 'INCOMPLETE'){
                        resultsToast.setParams({
                        "type" : "Error",
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": returnVal.O_RETURN[0].MSG

                        });
                        resultsToast.fire();
                    }
                }
                component.set("v.status", returnVal.O_RETURN[0].CODE);
                component.set("v.errormessage", returnVal.O_RETURN[0].MSG);
                
            }else{
                component.set("v.dataLoad", true);  // 데이터 로드 실패 표시
                component.set("v.isCVvalue", false);
                console.error("옵션을 로드하는 중에 오류가 발생했습니다.");
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
        } catch (error) {
            console.log('error : ' + error.message);
        }
        
    },

    toggleOff: function(component, event, helper) {
        try
        {
        component.set("v.isOn", false);
        component.set("v.dataLoad", false);

        var tselData = component.get('v.tselData');
        // var index = event.getSource().get("v.name");

        // var selectedIndex = event.getSource().get("v.value");
        var options = component.get("v.options");

        var defcvData = component.get("v.defcvData");

        var upRecord = component.get("v.upRecord");

        var initData = component.get("v.initData");

        // var selectedValue = initData[index].selectedValue;
        // console.log(selectedValue);
        // for(var i = 0; i < initData.length; i++){
        //     if (!upRecord[i]) {
        //         upRecord[i] = {
        //             c_code: '',
        //             c_value: '',
        //             v_code: '',
        //             v_value: '',
        //             Color : false,
        //             price: 0,
        //         };
        //     }
        //     if(index == i){
        //         upRecord[i].Id     = initData[index].Id;
        //         upRecord[i].c_code = initData[index].c;
        //         upRecord[i].c_value = initData[index].c_value;
        //         upRecord[i].v_code = initData[index].v_code[selectedIndex][selectedValue];
        //         upRecord[i].v_value = initData[index].v[selectedIndex];
        //         upRecord[i].price = initData[index].price[selectedIndex];
        //         tselData.push({ATNAM : initData[index].c,
        //             ATWRT : initData[index].v_code[selectedIndex][selectedValue],
        //             ZSEQNO : tselData.length + 1
        //         });
        //     }

        // }
        
        // component.set("v.tselData", tselData);
        // component.set("v.options", options);
        // component.set('v.upRecord', upRecord);

        var lineItemList = component.get('v.lineItemList');
        var action = component.get("c.changeOption");
        var cvData = [];
        var defcvData = [];

        action.setParams({
            quoteLineId : lineItemList[0].Id,
            selectedValue : component.get('v.tselData'),
            isODLogic : component.get('v.isOn')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                // console.log(returnVal.T_VALUE);
                // console.log(returnVal.DEFAULT);
                var selectData = returnVal.T_VALUE;
                
                var j = 0;
                for(var i = 0; i < selectData.length; i++) {
                    if(i == 0){
                        cvData.push({Id : selectData[i].Id, 
                                    c : selectData[i].ATNAM, 
                                    c_value : selectData[i].ATBEZ, 
                                    v_code : [{[j] : selectData[i].ATWRT}], 
                                    v:[selectData[i].ATWTB], 
                                    selectedValue:[{[j] : selectData[i].ATWTB}], 
                                    color: selectData[i].Color, 
                                    price: [selectData[i].KBETR],
                                    mCheck : selectData[i].mCheck
                                });
                    }else{
                        if(selectData[i-1].ATNAM != selectData[i].ATNAM){
                            j = 0;
                            cvData.push({Id : selectData[i].Id, 
                                         c : selectData[i].ATNAM, 
                                         c_value : selectData[i].ATBEZ, 
                                         v_code : [{[j] : selectData[i].ATWRT}], 
                                         v:[selectData[i].ATWTB], 
                                         selectedValue:[{[j] : selectData[i].ATWTB}], 
                                         color: selectData[i].Color, 
                                         price: [selectData[i].KBETR],
                                         mCheck : selectData[i].mCheck
                                        });
                        }else{
                            j++;
                            cvData[cvData.length-1].v.push(selectData[i].ATWTB);
                            cvData[cvData.length-1].v_code.push({[j] : selectData[i].ATWRT});
                            cvData[cvData.length-1].price.push(selectData[i].KBETR);
                        }
                    }
                }
                
                for(var i = 0; i < cvData.length; i++){
                    // cvData[i].color = false;
                    cvData[i].index = i;
                    // console.log('cvData' + i + ' : ' + JSON.stringify(cvData[i]));
                }
                
                /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                var defaultData = returnVal.DEFAULT;
                var k = 0;
                for(var i = 0; i < defaultData.length; i++) {
                    if(i == 0){
                        defcvData.push({c : defaultData[i].ATNAM, 
                                        c_value : defaultData[i].ATBEZ, 
                                        v_code : [{[k] : defaultData[i].ATWRT}], 
                                        v:[defaultData[i].ATWTB], 
                                        selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                        color: defaultData[i].Color, 
                                        price: [selectData[i].KBETR],
                                        mCheck : selectData[i].mCheck
                                    });
                    }else{
                        if(defaultData[i-1].ATNAM != defaultData[i].ATNAM){
                            k = 0;
                            defcvData.push({c : defaultData[i].ATNAM, 
                                            c_value : defaultData[i].ATBEZ, 
                                            v_code : [{[k] : defaultData[i].ATWRT}], 
                                            v:[defaultData[i].ATWTB], 
                                            selectedValue:[{[k] : defaultData[i].ATWTB}], 
                                            color: defaultData[i].Color, 
                                            price: [defaultData[i].KBETR],
                                            mCheck : selectData[i].mCheck
                                        });
                        }else{
                            k++;
                            defcvData[defcvData.length-1].v.push(defaultData[i].ATWTB);
                            defcvData[defcvData.length-1].v_code.push({[k] : defaultData[i].ATWRT});
                            defcvData[defcvData.length-1].price.push(defaultData[i].KBETR);
                        }
                    }
                }
                // for(var i = 0; i < defcvData.length; i++){
                //     // cvData[i].color = false;
                //     defcvData[i].index = i;
                //     console.log('defcvData' + i + ' : ' + JSON.stringify(defcvData[i]));

                // }
                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //T_INCON_VALUE
                var inconData = returnVal.T_INCON_VALUE;
                var tInconValue = [];
                var v = 0;
                if(inconData.length > 0){
                    for(var i = 0; i < inconData.length; i++) {
                        if(i == 0){
                            tInconValue.push({Id : inconData[i].Id, 
                                        c : inconData[i].ATNAM, 
                                        c_value : inconData[i].ATBEZ, 
                                        v_code : [{[v] : inconData[i].ATWRT}], 
                                        v:[inconData[i].ATWTB], 
                                        selectedValue:[{[v] : inconData[i].ATWTB}], 
                                        color: inconData[i].Color, 
                                        price: [inconData[i].KBETR]});
                        }else{
                            if(inconData[i-1].ATNAM != inconData[i].ATNAM){
                                v = 0;
                                tInconValue.push({Id : inconData[i].Id, 
                                             c : inconData[i].ATNAM, 
                                             c_value : inconData[i].ATBEZ, 
                                             v_code : [{[v] : inconData[i].ATWRT}], 
                                             v:[inconData[i].ATWTB], 
                                             selectedValue:[{[v] : inconData[i].ATWTB}], 
                                             color: inconData[i].Color, 
                                             price: [inconData[i].KBETR]});
                            }else{
                                v++;
                                tInconValue[tInconValue.length-1].v.push(inconData[i].ATWTB);
                                tInconValue[tInconValue.length-1].v_code.push({[v] : inconData[i].ATWRT});
                                tInconValue[tInconValue.length-1].price.push(inconData[i].KBETR);
                            }
                        }
                    }
                    
                    component.set("v.isInconvalue", true);
                    component.set("v.isCVvalue", false);
                    component.set("v.tInconValue", tInconValue);
                }

                component.set("v.defcvData", defcvData);
                cvData.forEach(item => {
                    const lastIndex = item.v_code.length; // 현재 마지막 index
                    // v_code에 새로운 object 추가
                    const newVCode = {};
                    newVCode[lastIndex] = ""; // 예: { "2": "" }
                    item.v_code.push(newVCode);
                  
                    // v에 "No Entry" 추가
                    item.v.push("No Entry");
                });
                component.set("v.initData", cvData);
                component.set("v.options", cvData);
                component.set("v.dataLoad", true);
                // for(var i = 0; i < component.get("v.initData").length; i++){
                //     console.log('initData' + i + ' : ' + JSON.stringify(component.get("v.initData")[i]));
                // }
                // console.log('returnVal.O_RETURN : ' + returnVal.O_RETURN);
                // console.log('returnVal.O_RETURN : ' + JSON.stringify(returnVal.O_RETURN));
                if(returnVal.O_RETURN.length > 0){
                    var resultsToast = $A.get("e.force:showToast");
                    if(returnVal.O_RETURN[0].CODE == 'NOCV'){
                        resultsToast.setParams({
                        "type" : "Error",
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": returnVal.O_RETURN[0].MSG

                        });
                        resultsToast.fire();
                    }
                    if(returnVal.O_RETURN[0].CODE == 'INCOMPLETE'){
                        resultsToast.setParams({
                        "type" : "Error",
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": returnVal.O_RETURN[0].MSG

                        });
                        resultsToast.fire();
                    }
                }
                component.set("v.status", returnVal.O_RETURN[0].CODE);
                component.set("v.errormessage", returnVal.O_RETURN[0].MSG);
                
            }else{
                component.set("v.dataLoad", true);  // 데이터 로드 실패 표시
                component.set("v.isCVvalue", false);
                console.error("옵션을 로드하는 중에 오류가 발생했습니다.");
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
        } catch (error) {
            console.log('error : ' + error.message);
        }
    }
    
    // handleReset:function(component, event, helper) {
    //     component.set("v.dataLoad", false);

    //     var tselData = component.get("v.tselData");
    //     if(tselData.length > 0){
    //         component.set("v.tresetselData", tselData); //reset후 save없이 cancel할 경우 다시 tselData에 값을 넣어주기위함
    //         component.set("v.tselData", []); //tselData는 초기화
    //     }
    //     try {
    //         this.doInit(component, event, helper);
    //     } catch (error) {
    //         console.log('error : ' + error);            
    //     }
    // }
})