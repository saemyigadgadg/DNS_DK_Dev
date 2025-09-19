/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-12-2024
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-12-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
	// 초기값 설정
	doInit : function(component, event, helper) {
		component.set('v.isLoading', true);
        component.set("v.isInit", false);
        //console.log('do init');
		helper.apexCall(component, event, helper, 'getDisplayMdt', {
			displayKey : component.get("v.DisplayKey")
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
			// 공통 MDT 설정
			component.set("v.displayMdt", r);
            //console.log(JSON.stringify(r), ' <>===');
			component.set("v.displayButtonMdt", r.buttonList);
            component.set("v.displayFilterMdt", r.filterList);
            component.set("v.uuid", self.crypto.randomUUID());
            component.set("v.userInfo", r.userInfo);
            let itemPerPage = component.get("v.designItemsPerPage");
            let pagePerGroup = component.get("v.designPagesPerGroup");
            if(parseInt(itemPerPage) > 0) {
                component.set("v.itemsPerPage", parseInt(itemPerPage));
            }
            if(parseInt(pagePerGroup) > 0) {
                component.set("v.pagesPerGroup", parseInt(pagePerGroup));
            }

            let requiredParams = r.filterList.filter((filter) => filter.isRequired)
                                             .map((filter)=> {
                                                let requireParam = {'fieldApiName':filter.fieldApiName};
                                                return requireParam;
                                             });
            // // 한Row당 필터 수 설정
            // let cardElement = component.find("filterCssSetting").getElement();
            // cardElement.style.gridTemplateColumns = "repeat(2, 1fr)"; 
             //데이터테이블 생성
            let dataTableCmp = component.get("v.DataTableComponent");
            // return new Promise((resolve, reject) => {
                $A.createComponent(`c:${dataTableCmp}`,
                    {
                        uuid : component.get("v.uuid"),
                        itemsPerPage : component.get('v.itemsPerPage'),
                        currentPage : component.get('v.currentPage'),
                        pagesPerGroup : component.get('v.pagesPerGroup'),
                        orderByField : component.get('v.orderByField'),
                        orderBy : component.get('v.orderBy'),
                        requiredParams : requiredParams,
                        currentUserInfo : component.get("v.userInfo")
                    },
                    function (content, status, errorMessage) {
                        
                    if (status === "SUCCESS") {
                        let container = component.find("dataTable");
                        container.set("v.body", content);
                        component.set("v.isInit", true);
                        //필터의 Default Value => DataTable로 보내기 위해 실행순서 변경
                        $A.createComponent(`c:dN_DealerPortalFilter`,
                            {
                                uuid : component.get("v.uuid"),
                                displayFilterMdtList : component.get("v.displayFilterMdt"),
                                filterSection : component.get('v.displayMdt').filterSection
                            },
                            function (content, status, errorMessage) {
                                
                            if (status === "SUCCESS") {
                                let container = component.find("Filter");
                                container.set("v.body", content);
                            } else if (status === "INCOMPLETE") {
                                //console.log("No response from server or client is offline.")
                            } else if (status === "ERROR") {
                                //console.log("Error: " + errorMessage);
                            }
                        });
                        //resolve();
                    } else if (status === "INCOMPLETE") {
                        //console.log("No response from server or client is offline.")
                        //reject("INCOMPLETE");
                    } else if (status === "ERROR") {
                        //console.log("Error: " + errorMessage);
                        //reject(errorMessage);
                    }
                });	
            // })		
        }))
        .catch(function(error) {
            //console.log('# addError error : ' + error.message);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
        
	},

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        //console.log("새로고침 이벤트를 받는 지 확인 :::: ", JSON.stringify(params));
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            // 커스텀으로 생성한 모달화면 
            if(params.type == 'CustomModal') { 
                
                let obj ={};
                ////console.log(params.message.param.length,' < ===params.message');
                if(params.message.param.length > 0) {
                    let objSet;
                    if(params.message.param.indexOf(',')) {
                        objSet = params.message.param.split(',');
                    } else {
                        objSet = params.message.param;
                    }
                    //console.log(JSON.stringify(objSet),' < ==objSet')
                    for(let i=0; i<objSet.length; i++) {
                        let objs = objSet[i].split('=');
                        let key = objs[0].trim();
                        let value = objs[1].trim();
                        //배열 형식일경우 형변환
                        if(value.indexOf('[') > -1 && value.lastIndexOf(']') > -1) 
                            value = JSON.parse(value);
                         
                        obj[key] = value;
                    }  
                }
                
                    $A.createComponent(`c:${params.message.modalName}`,obj ,
                        function (content, status, errorMessage) {
                            if (status === "SUCCESS") {
                                $A.getCallback(function () {
                                    var container = component.find(`modalContainer`);//component.find(`${params.cmpName}`);
                                    container.set("v.body", content);       
                                })();
                            } else if (status === "INCOMPLETE") {
                                console.log("No response from server or client is offline.")
                            } else if (status === "ERROR") {
                                console.log("Error: " + errorMessage);
                            }
                        });
                        // function(content, status, errorMessage) {
                            
                        //     // if (status === "SUCCESS") {
                        //     //     new Promise($A.getCallback(function(resolve, reject) {
                        //     //         var container = component.find(`modalContainer`);//component.find(`${params.cmpName}`);
                        //     //         container.set("v.body", content);       
                        //     //     }));
                        //     //     console.log(status,' :::status');
                        //     //     console.log(content,' :::content');
                        //     //     console.log("Modal rendered successfully");
                        //     //     // // 렌더링 완료 후 작업
                        //     //     $A.getCallback(function () {
                                    
                                    
                        //     //     })();
                                
                        //     // } else if (status === "INCOMPLETE") {
                        //     //     console.log("No response from server or client is offline.")
                        //     // } else if (status === "ERROR") {
                        //     //     console.log("Error: " + errorMessage);
                        //     // }
                        // });    
                
                
                
            }else if(params.type == 'CustomModalOverlay') { 
                console.log('CustomModalFromLWC ! ');
                let obj ={};
                //console.log(params.message.param.length,' < ===params.message');
                if(params.message.param.length > 0) {
                    let objSet;
                    if(params.message.param.indexOf(',')) {
                        objSet = params.message.param.split(',');
                    } else {
                        objSet = params.message.param;
                    }
                    for(let i=0; i<objSet.length; i++) {
                        let objs = objSet[i].split('=');
                        let key = objs[0].trim();
                        let value = objs[1].trim();
                        //배열 형식일경우 형변환
                        if(value.indexOf('[') > -1 && value.lastIndexOf(']') > -1) 
                            value = JSON.parse(value);
                         
                        obj[key] = value;
                    }  
                }
                console.log(JSON.stringify(obj),' ::::obj');
                let { headerLabel, isShowCloseButton } = params.message;
                if(typeof isShowCloseButton =='undefined' ) isShowCloseButton = true;
                let modalBody;
                $A.createComponent(`c:${params.message.modalName}`, obj,
                function(content, status, errorMessage) {
                    if (status === "SUCCESS") {
                        modalBody = content;
                        component.find('overlayLib').showCustomModal({
                            header: headerLabel,
                            body: modalBody,
                            showCloseButton: isShowCloseButton,
                            cssClass: "",
                        })
                    }else {
                        console.erorr('Error ??');
                        console.log(errorMessage);
                    }
                });

                console.log('이거 타나요?');
                // $A.createComponent(`c:${params.message.modalName}`,obj ,
                // function (content, status, errorMessage) {
                //     if (status === "SUCCESS") {
                //         var container = component.find(`modalContainer`);//component.find(`${params.cmpName}`);
                //         container.set("v.body", content);
                //     } else if (status === "INCOMPLETE") {
                //         console.log("No response from server or client is offline.")
                //     } else if (status === "ERROR") {
                //         console.log("Error: " + errorMessage);
                //     }
                // });
            } 
            // 뒤로가기
            if(params.type == 'Back') {
                window.history.back();
            }
            // 커스텀으로 생성한 페이지 이동
            if (params.type == 'CustomPage') { //modalName -> 페이지 이동인 경우 페이지명 넣기
                let hostname = window.location.hostname;
                let pathName = window.location.pathname;
                let navService = component.find('navService');
                pathName = pathName.substring(0, pathName.lastIndexOf('/') + 1);
                ////console.log(window.location,' < ==window.location');
                //console.log(hostname,' < ==hostname');
                
                let pageReference = {
                    type: "standard__webPage",
                    attributes: {
                        url: hostname + pathName +params.message.modalName ,
                    }
                };
                navService.navigate(pageReference)
            }
            //console.log(JSON.stringify(params), ' < ==ExcelDownload');
            // LWC테이블에서 액셀 다운로드 요청
            if(params.type =='ExcelDownload') {
                component.set('v.excelGRData',params.message.excelData);
                component.set('v.headerData',params.message.headerData);
                component.set('v.excelName', `${params.message.headerData[0]['참고문서번호']}_입고취소증`)
                helper.handleGIGRDocumentExcel(component);
            }
            
        }
    },
    
    // 스탠다드화면이 아닌 아우라 모달을 호출하는 경우 모달별 Param정보 수신
    handleCompEvent: function (component, event, helper) {
        var modalName = event.getParam("modalName");
        var action = event.getParam("actionName");
        var message = event.getParam("message");
        // //console.log(JSON.stringify(message) ,  ' 디스플레이 CMP : message');
        if(message.parentCmp=='DN_DealerPortalDisplay') {
            switch (modalName) {
                case 'MachineModal':
                    component.find("dealerPortalLMC").publish(
                        {
                            'uuid' : component.get("v.uuid"),
                            'type': 'filterModal',
                            'message' :  { 'field' : 'Type', 'label': message.label, 'value' :message.label, 'dependencyField':'machineNo' , 'isLabel': true},
                            'cmpName' : 'DN_DealerPortalDisplay'
                        });
                    break;
                case 'SerialModal':
                    component.find("dealerPortalLMC").publish(
                        {
                            'uuid' : component.get("v.uuid"),
                            'type': 'filterModal',
                            'message' :  { 'field' : 'SerialNumber', 'label':message.label , 'value' : message.label, 'dependencyValue': message.machineName},
                            'cmpName' : 'DN_DealerPortalDisplay'
                        });
                    break;
                case 'DN_AgencyCustomerListModal':
                    //24-12-23 Hyunwook Jin 추가
                    //console.log('DN_AgencyCustomerListModal');
                    //console.log(JSON.stringify(message));
                    component.find("dealerPortalLMC").publish(
                        {
                            'uuid' : component.get("v.uuid"),
                            'type': 'filterModal',
                            'message' :  Object.assign({}, message,{ 'field' : 'CustomerName__c', 'label':message.customerName, 'value' : message.id}),
                            'cmpName' : 'DN_DealerPortalDisplay'
                    });
                    break;
                case 'DN_AgencyCustomerShipToModal':
                    //25-01-04 Hyunwook Jin 추가
                    //{"city":"경기도 남양주시 화도읍 경춘로 2028","customerAddress":"12181 경기도 남양주시 화도읍 경춘로 2028, 232","customerCode":"1244220","customerId":"a2XF7000000Myk4MAC","customerName":"명성기계 부품대리점","customerPhone":"01031797674","id":"a2YF7000001B9KdMAK","manager":"서비스요원","postalCode":"12181","street":"232","parentCmp":"DN_DealerPortalDisplay"}
                    //console.log('DN_AgencyCustomerShipToModal');
                    //console.log(JSON.stringify(message));
                    component.find("dealerPortalLMC").publish(
                        {
                            'uuid' : component.get("v.uuid"),
                            'type': 'filterModal',
                            'message' :  { 'field' : 'shipTo', 'label':message.customerAddress, 'value' : message.id, 'city': message.city, 'street':message.street, 'postalCode':message.postalCode, 'representative':message.manager, 'phone':message.customerPhone , 'customerName':message.customerName },
                            'cmpName' : 'DN_DealerPortalDisplay'
                    });
                    break;
                case 'DN_inputModalOpen':
                    //25-01-04 Hyunwook Jin 추가
                    //console.log('DN_inputModalOpen');
                    //console.log(JSON.stringify(message));
                    //{"inputZipCode":"06241","inputCountry":"서울특별시","inputAddress":"서울특별시 강남구 강남대로 362 (역삼동), 상세입니다","inputManager":"","inputPhone":"","inputCustomerName":"고객사명 ","detailAddress":"상세입니다","parentCmp":"DN_DealerPortalDisplay"}
                    let label = `${message.inputZipCode} ${message.inputAddress}`;
                    let {inputZipCode, inputManager, inputPhone, inputCustomerName, detailAddress, inputAddress} = message;
                    if(detailAddress && inputAddress.lastIndexOf(detailAddress) != -1) {
                        let lastIdx = inputAddress.lastIndexOf(detailAddress);
                        inputAddress = inputAddress.substring(5, lastIdx).trimStart();
                        
                        if(inputAddress.lastIndexOf(', ') == inputAddress.length - 2)
                            inputAddress = inputAddress.substring(0, inputAddress.length - 2);
                    }
                    component.find("dealerPortalLMC").publish(
                        {
                            'uuid' : component.get("v.uuid"),
                            'type': 'filterModal',
                            'message' :  { 'field' : 'shipTo', 'label':label, 'value' : '9999999999', 'postalCode':inputZipCode, 'representative':inputManager, 'phone':inputPhone, 'customerName':inputCustomerName, 'street':detailAddress, 'city':inputAddress }, //
                            'cmpName' : 'DN_DealerPortalDisplay'
                    });
                    break;
                case 'DN_AgencyCustomerOrderDetail':
                    
                    break;
                case 'DN_AgencyCustomerOrderStatus':
                    
                    break;
                case 'DN_SearchProductNumber':
                    //'{"Id":"01tF7000008ice9IAA","Name":"STA-2LT-DNS","ProductCode":"STA-2LT-DNS","RecordTypeId":"012F7000000KXqkIAG","IsStrategicMaterial__c":false}'
                    //console.log('DN_SearchProductNumber');
                    //console.log(JSON.stringify(message));
                    component.find("dealerPortalLMC").publish(
                        {
                            'uuid' : component.get("v.uuid"),
                            'type': 'filterModal',
                            'message' :  { 'field' : 'productCode', 'label':message.ProductCode, 'value' : message.Id},
                            'cmpName' : 'DN_DealerPortalDisplay'
                    }); 
                    
                    break;  
                case 'DN_DemandAdjPerAgencyPopupResMultiPart': // 멀티 부품 검색 label => List, value => List
                    //console.log(JSON.stringify(message) + ' ::: DN_DemandAdjPerAgencyPopupResMultiPart	');
                    component.find("dealerPortalLMC").publish(
                        {
                            'uuid' : component.get("v.uuid"),
                            'type': 'filterModal',
                            'message' :  { 'field' : 'productCode', 'label':message.label, 'value' : message.value},
                            'cmpName' : 'DN_DealerPortalDisplay'
                    });   
                    break;    
                case 'DN_searchStorageBinModal':
                    //console.log(JSON.stringify(message));
                    component.find("dealerPortalLMC").publish(
                        {
                            'uuid' : component.get("v.uuid"),
                            'type': 'filterModal',
                            'message' :  { 'field' : 'location', 'label':message.FM_Loc__c, 'value' : message.Id},
                            'cmpName' : 'DN_DealerPortalDisplay'
                    }); 
                    break;
                case 'DN_DemandAdjPerAgencyPopupResMultiBin':
                    component.find("dealerPortalLMC").publish(
                        {
                            'uuid' : component.get("v.uuid"),
                            'type': 'filterModal',
                            'message' :  { 'field' : 'location', 'label':message.label, 'value' : message.value},
                            'cmpName' : 'DN_DealerPortalDisplay'
                    }); 
                    break;
                case 'DN_SettingStorageModal':
                    component.find("dealerPortalLMC").publish(
                        {
                            'uuid' : component.get("v.uuid"),
                            'type': 'Create',
                            'message' :  'Create',
                            'cmpName' : 'DN_DealerPortalDisplay'
                    }); 
                    break;        
                
            }
        }
        
        
        
    },  
    onEvent: function(component, event, helper) {
        var elem = component.getElement();
        //console.log(elem,' < ==elem');
        //console.log(elem.offsetParent, ' < ==elem.offsetParent');
        if (elem && elem.offsetParent !== null) {
            // event handling logic here
        }
    } 
})