/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-17-2024
 * @last modified by  : youjin.shim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-17-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({

    doInit: function (component, event, helper) {
        console.log(component.getName());
        helper.gfnDoInit(component,event);
    },

    //모든 체크박스 선택
    selectAll: function (component, event, helper) {
        let checkboxes = component.find("checkbox");
        let isChecked = component.find("headerCheckbox").get("v.checked");
        let allData = component.get('v.partsList');
        allData.forEach((data)=>{
            data.isSelected = isChecked;
        });
        component.set('v.partsList', allData);

        // let plist = [];
        // if(isChecked) {
        //     if (Array.isArray(checkboxes)) {
        //         checkboxes.forEach(function (checkbox, index) {
        //             checkbox.set("v.checked", isChecked);
        //         });
        //     } else {
        //         checkboxes.set("v.checked", isChecked);
        //     }
        //     plist = allData;
        // } else {
        //     if (Array.isArray(checkboxes)) {
        //         checkboxes.forEach(function (checkbox) {
        //             checkbox.set("v.checked", isChecked);
        //         });
        //     } else {
        //         checkboxes.set("v.checked", isChecked);
        //     }
        //     plist = [];
        // }
        // component.set('v.selectRow', plist);
        // var selectRow = component.get('v.selectRow');
        // console.log('selectedProd:', JSON.stringify(selectRow));
    },

    // 체크박스 선택
    handleCheckBox: function (component, event, helper) {
        let index = event.getSource().get('v.accesskey');
        let isCheck = event.getSource().get('v.checked');
        let allData = component.get('v.partsList');
        let selectRow = component.get('v.selectRow');
        if(isCheck) {
            selectRow.push(allData[index]);
        } else {
            selectRow = selectRow.filter(ele => ele.warrantyId !== allData[index].warrantyId);
        }
        component.set('v.selectRow', selectRow);
    },

    //스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        // x축 스크롤 값을 유지
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
    },
    handleDetail: function (component, event, helper) {
        //let warrantySeq = event.currentTarget.accessKey;
       
        let warrantySeq = event.currentTarget.name;
 
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
                                helper.gfnConvertParams(headerParams, headerParam);
                                // headerParams[headerParam.field] = headerParam.value;
                            });

                        }else {
                            helper.gfnConvertParams(headerParams, params.message);
                            // headerParams[params.message.field] = params.message.value;
                        }
                        component.set('v.headerParams', headerParams);

                    }
                    break;
                case 'DN_DealerPortalDisplay': 
                    break;
                case 'dN_DealerPortalButton':
                    console.log(JSON.stringify(params), ' test');
                    if(params.type === 'Seach') {
                        helper.gfnSearch(component, null);
                    }else if(params.type === 'Save') {
                        console.log('type : Save');
                        helper.gfnUpdateWarranty(component,helper);
                    }else if(params.type === 'ExcelDownload') {
                        helper.createExcel(component);
                    }else if(params.type ==='ButtonPickList') {
                        component.set('v.statusCode',params.message.value);
                    }
                    break;
                
                case 'dN_DealerPortalQueryPage':
                    // console.log('dN_DealerPortalQueryPage');
                    // console.log(JSON.stringify(params), ' msg');
                    // component.set('v.nextPage',    params.message.nextpage);
                    // component.set('v.currentPage', params.message.currentPage);
                    // helper.gfnSearchReturnRequestOrder(component, null, 'PageChange');
                    break;  
            }
        }
    },
})