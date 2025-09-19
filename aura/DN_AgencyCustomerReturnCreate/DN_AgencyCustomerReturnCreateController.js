/**
 * @author            : Jun-Yeong Choi
 * @Description       : 
 * @last modified on  : 2024-06-10
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-03   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        helper.gfnDoinit(component,event);
    },

    handleRowToggle: function (component, event, helper) {
        // var index = event.currentTarget.dataset.index;
        // returnList[index].complaintRow = !returnList[index].complaintRow;
        var checkbox = component.find('checkbox');
        var returnList = component.get('v.returnRequestList');
        console.log('returnList::', JSON.stringify(returnList[0].complaintRow));
        var selectedOrder = [];
        for (var i = 0; i < checkbox.length; i++) {
            if (checkbox[i].get("v.checked")) {
                selectedOrder.push(returnList[i]);
            }
        }
        console.log('selectedOrder::', JSON.stringify(selectedOrder));
        component.set('v.selectedOrder', selectedOrder);
        const onClick = (event) => {
            if(event.target.name == 'fileUpload') {
                console.log(event.target.id);
                component.set("v.selectOrderNumber", event.target.id);
            }
        }
        window.addEventListener('click', onClick);
    },

    // 이벤트 Catch : 고객사명 모달
    // handleCompEvent: function (component, event, helper) {
    //     var modalName = event.getParam("modalName");
    //     var action = event.getParam("actionName");
    //     var message = event.getParam("message");
    //     console.log('message::', message);

    //     // if (modalName == 'DN_AgencyCustomerListModal' && message != '일반고객') {
    //     //     component.set('v.customerName', message.customerName);

    //     // } else if (message == '일반고객') {
    //     //     component.set('v.customerName', message);
    //     // } 
        
    //     if (modalName == 'DN_AgencyCustomerListModal' ) {
    //         helper.gfnSetCustomerInfo(component, message.id, message.id, message.customerName);
    //         // if(message.id == '9999999999') {
    //         //     //일반 고객
    //         //     component.set('v.customerCode', message.id);
    //         //     component.set('v.customer', undefined);
    //         // }else {
    //         //     //대리점 고객
    //         //     component.set('v.customerCode', undefined);
    //         //     component.set('v.customer', message.id);
    //         // }

    //         // component.set('v.customerName', message.customerName);
            

    //     }else if (modalName == 'DN_SearchProductNumber') {
    //         var partsNumber = component.get('v.partsNumber');
    //         partsNumber = message.ProductCode;
    //         component.set('v.partsNumber', partsNumber);
    //     }
    // },

    createReturn: function (component, event, helper) {
        helper.gfnCreateReturn(component,event);
    },
    
    handleReasonChange: function (component, event, helper) {
        let value = event.getSource().get("v.value");
        let accesskey = event.getSource().get("v.accesskey");
        console.log('accesskey : ', accesskey);
        let returnRequestList = component.get('v.returnRequestList');
        let targetReturn = returnRequestList.find(returnRequest=> `${returnRequest.orderSeq}_${returnRequest.itemSeq}`==accesskey);
        let dependecyInfo = component.get('v.reason2DependecyAllOptions');
        if(Array.isArray(dependecyInfo[value])) {
            targetReturn.reason2Options = dependecyInfo[value];
            component.set('v.reason2Options', dependecyInfo[value]);
        }else {
            targetReturn.reason2Options = component.get('v.defaultOptions');
        }
        targetReturn.reason2 = undefined;
        component.set('v.returnRequestList', returnRequestList);
    },

    // 파일첨부 후 후처리
    // 화면에 파일목록
    onuploadfinished: function (component, event, helper) {
        // component.set("v.isSpinner", true);
        helper.gfnFileUploadFinished(component, event);
        

        // helper.apexCall(component, event, helper, 'uploadfinished', {
        //     fileIds: component.get("v.uploadFileIds")
        // })
        // .then($A.getCallback(function(result) {
        //     let r = result.r;
        //     console.log(JSON.stringify(r), ' < ===result'); //component.get("v.fileList");
        //     let linkList = [];
        //     r.forEach(element => {
        //         linkList.push({
        //             id : element.Id,
        //             title : element.Title,
        //             contentDocumentId :element.ContentDocumentId,
        //             versionDataUrl : element.VersionDataUrl
        //         });
        //     });
        //     // let listSet = component.get("v.fileList");
        //     // let fielMaps = { orderNumber : component.get("v.selectOrderNumber"),
        //     //                  list : linkList};
        //     // listSet.push(fielMaps);

        //     let returnListSet = component.get('v.returnList');
        //     returnListSet.forEach(element => {
        //         if(element.orderNo == component.get("v.selectOrderNumber")) {
        //             element.fileList = linkList;
        //         }
        //     });
        //     console.log(returnListSet, ' < ===returnListSet');
        //     console.log(JSON.stringify(returnListSet), ' < ===returnListSet');
        //     component.set("v.returnList", returnListSet);
        //     //console.log(JSON.stringify(component.get("v.fileList")), '22222222');
        //     //$A.get('e.force:refreshView').fire();
        // }))
        // .catch(function(error) {
        //     console.log(' error : ' + error.message);
        // });
        // component.set("v.isSpinner", false);
    },

    removeFile: function (component, event, helper) {
        // component.set("v.isSpinner", true);
        let removeId = event.currentTarget.getAttribute("data-id");
        console.log('removeId : ', removeId);
        helper.gfnRemoveFile(component, removeId);
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            console.log(`${component.getName()}.setSubscriptionLMC`);
            console.log(JSON.stringify(message));
           
            switch (params.cmpName) {
                case 'dN_DealerPortalFilter':
                    if(params.type ==='filterChange' || params.type === 'defaultFilter') {
                        let headerParams = component.get('v.headerParams');
                        if(!!!headerParams) headerParams = {};

                        console.log('type : filterChange');
                        let isArray = Array.isArray(params.message);
                        
                        if(isArray) {
                            [...params.message].forEach((headerParam)=>{
                                headerParams[headerParam.field] = headerParam.value;
                            });

                        }else {
                            headerParams[params.message.field] = params.message.value;
                        }
                        component.set('v.headerParams', headerParams);
                    }
                    break;
                    
                case 'dN_DealerPortalButton':
                    if(params.type === 'Seach') {
                        helper.gfnSearchReturnRequestOrder(component, null, 'Search');
                    }else if(params.type === 'Save') {
                        console.log('type : Save');
                        helper.gfnCreateReturn(component, null);
                    }
                    break;
                
                case 'dN_DealerPortalQueryPage':
                    console.log('dN_DealerPortalQueryPage');
                    console.log(JSON.stringify(params), ' msg');
                    component.set('v.nextPage',    params.message.nextpage);
                    component.set('v.currentPage', params.message.currentPage);
                    helper.gfnSearchReturnRequestOrder(component, null, 'PageChange');
                    break;  
            }
        }
    },
    handleQTYChange : function(component, event, helper) {
        console.log(' ::: handleQTYChange');
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let returnRequest = component.get(`v.returnRequestList`);
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        console.log(value,' :: value');
        returnRequest[index].returnQuantity = value;
        
        component.set(`v.returnRequestList.`, returnRequest);
    },

})