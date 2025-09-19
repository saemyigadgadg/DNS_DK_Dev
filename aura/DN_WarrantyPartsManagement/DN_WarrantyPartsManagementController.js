/**
 * @author            : Jun-Yeong Choi
 * @description       : 
 * @last modified on  : 12-18-2024
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   2024-06-18   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        console.log(component.getName());
        helper.gfnDoInit(component,event);
    },


    openCustomerOrderDetail: function (component, event, helper) {
        let warrantySeq = event.currentTarget.accessKey;

        let payload = {
            uuid : component.get('v.uuid'),
            type : 'CustomModalOverlay',
            message : {
                param : `warrantySeq=${warrantySeq}`,
                modalName:'DN_WarrantyDetails',
                headerLabel:'Claim 정보'
            }
        };

        component.find("dealerPortalLMC").publish(payload);
    },

    selectAll: function (component, event, helper) {
        let isChecked = component.find("headerCheckbox").get("v.checked");
        
        let partsList = component.get('v.partsList');
        partsList.forEach(part=>{
            if(!part.isDisabled) 
                part.isSelected = isChecked;
        });

        component.set('v.partsList', partsList);
    },

    handleScroll: function (component, event, helper) {
        // var rightTable = event.target;
        // var rightScrollTop = rightTable.scrollTop;
        // setTimeout(() => {
        //     var leftTableEl = component.find("leftTableDiv").getElement();
        //     leftTableEl.scrollTop = rightScrollTop;
        // }, 300); // 300ms 정도 지연
        
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        // x축 스크롤 값을 유지
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
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
                case 'DN_DealerPortalDisplay': 
                    
                    break;
                case 'dN_DealerPortalButton':
                    if(params.type === 'Seach') {
                        helper.gfnSearch(component, null);
                    }else if(params.type === 'Save') {
                        // console.log('type : Save');
                        helper.gfnUpdateWarranty(component, null);
                    }else if(params.type === 'ExcelDownload') {
                        helper.gfnExcelDownload(component, null);
                    }else if(params.type === 'GoodIssue') {

                        let requestGoodsIssueList = component.get('v.partsList').filter(part=>part.isSelected && !part.isDisabled);
                        if(requestGoodsIssueList.length == 0) {
                            helper.toast('Warning', '출고할 서비스 오더를 입력하세요');
                            component.set('v.isLoading', false);
                            return ;
                        }

                        let isIncludeCancelStatus = false;
                        requestGoodsIssueList.forEach((requestGoodsIssue)=>{
                            console.log(requestGoodsIssue.status);
                            if(requestGoodsIssue.status === '3') {
                                isIncludeCancelStatus = true;
                            }
                        })

                        if(isIncludeCancelStatus) {
                            helper.openConfirm('진행상태가 취소인 항목이 포함되어 있습니다. 취소 항목을 제외하고 진행하시겠습니까?','default', 'headerless').then($A.getCallback(function(result){
                                if(result) {
                                    component.set('v.isDeliveryModal', true);        
                                }else {
                                    component.set('v.isLoading', false);
                                }
                            }));
                        }else {
                            component.set('v.isDeliveryModal', true);
                        }

                    }
                    break;
                
                case 'dN_DealerPortalQueryPage':
                    break;  
            }
        }
    },

    deliverySave : function(component, event, helper) {
        helper.gfnCompleteGoodsIssue(component, null);
    },

    deliveryCancel : function(component, event, helper) {
        helper.gfnDeliveryCancel(component);
    },

    
    handleChangeDealer : function(component, event, helper) {
        let dealerId = event.getSource().get('v.value');
        let accesskey = event.getSource().get('v.accesskey');
        helper.gfnGetStockByChangeDealer(component, dealerId, accesskey);
    }

})