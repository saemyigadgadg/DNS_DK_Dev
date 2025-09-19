/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-18
 * @last modified by  : jiyoung.p@dncompany.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-13-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var baseUrl = window.location.origin;
        component.set("v.baseUrl", baseUrl);

        let urlParams;
        let orderNumber;

        // 1. CRM
        let pageRef = component.get("v.pageReference");
        if (pageRef && pageRef.state) {
            orderNumber = pageRef.state.c__orderNumber; 
        }

        // 2. 포털
        if (!orderNumber) {
            urlParams = new URLSearchParams(window.location.search);
            orderNumber = urlParams.get("orderNumber");
        }

        console.log('Extracted orderNumber:', orderNumber);

        if (orderNumber) {
            component.set("v.orderNumber", orderNumber);
        
            setTimeout(() => {
                let inputCmp = component.find("inputOrderNumber");
                if (inputCmp) {
                    inputCmp.set("v.value", orderNumber);
                }
            }, 100);

            $A.enqueueAction(component.get('c.handleSearch'));
        }

        let actionDetail = component.get("v.serviceData.actionDetail");
        console.log("actionDetail 초기 값:", actionDetail);

        let action = component.get("c.getLoginUserInfo");
        
        action.setParams({ });

        action.setCallback(this, function(response) {
            let state = response.getState();
            let r = response.getReturnValue();
            
            if (state === "SUCCESS") {
                if (r.flag == "success") {
                    
                    console.log('init Info ::: ', JSON.stringify( r.loginUserInfo, null, 2));
                    component.set("v.loginUserInfo", r.loginUserInfo);
                    
                    if(r.loginUserInfo.Service_Territory__r.classify__c == 'W/C') {
                        component.set("v.isReportBranch", true);
                    }

                    if(r.loginUserInfo.Service_Territory__r.classify__c == '지사' || r.loginUserInfo.Service_Territory__r.classify__c == 'POST') {
                        component.set("v.isBranch", true);
                    }

                    if(r.loginUserInfo.RelatedRecord.Profile.Name == 'DNSA CS Agency') {
                        component.set("v.isDNSA", true);
                    }
                    
                } else if (r.flag == "warning") {
                    helper.toast("WARNING", r.message);
                } else {
                    helper.toast("Error", r.message);
                }
            } else {
                helper.toast("Error", r.message);
            } 
        });
        $A.enqueueAction(action);
    },

    // 오더번호로 조회
    handleSearch: function(component, event, helper) {
        component.set("v.serviceData", []);
        component.set("v.workList", []);

        var orderNumber = component.get("v.orderNumber").trim();

        if (!orderNumber) {
            helper.toast('WARNING', '오더번호를 입력해주세요.');
            component.set('v.isSearched', false);
            component.set('v.isLoading', false);
            return;
        }

        if (!helper.numberOnlyCheck(orderNumber)) {
            helper.toast('WARNING', '오더번호는 숫자로만 입력해주세요.');
            component.set('v.isLoading', false);
            return;
        } else {
            component.set('v.isLoading', true);
            component.set('v.isSearched', false);
            
            helper.resetComponent(component);

            helper.apexCall(component, event, helper, 'searchPartCallOut', { orderNumber: orderNumber })
            .then($A.getCallback(function (result) {
                console.log('searchPartCallOut : '+ result);
                helper.apexCall(component, event, helper, 'searchBeforeCallOut', { orderNumber: orderNumber })
                .then($A.getCallback(function (result) {
                    console.log('serviceData callOut Success flag ::: ', result.r.flag);
                    // console.log('@@ result.r.responseData; : ' + JSON.stringify(result.r.responseData));
                    
                    if (result.r.responseData) {
                        let reponseData = result.r.responseData;
                        
                        console.log('O_AUFNR ::: ', reponseData.O_AUFNR);
                        console.log('O_STATUS ::: ', reponseData.O_STATUS);
                        console.log('O_ILART ::: ', reponseData.O_ILART);
                    }
                    
                    if (!result.r.isPortalEnabled) {
                        console.log('내부 사용자 확인 ::: ', result.r.isPortalEnabled);
                        component.set("v.isPortalEnabled", false);
                    }

                    helper.apexCall(component, event, helper, 'orderNumberSearch', { orderNumber: orderNumber })
                    .then($A.getCallback(function (result) {

                        const responseData = result.r;
                        console.log('serviceData Update Search ::: ', JSON.stringify(result.r, null, 2));

                        if (responseData.flag === 'noWorkOrder') {
                            helper.toast('WARNING', '해당 오더번호의 서비스오더가 존재하지 않습니다.');
                            component.set('v.isSearched', false);
                            component.set('v.isLoading', false);
                            return;
                        }

                        if (responseData.flag === 'No permission') {
                            helper.toast('WARNING', '해당 서비스오더에 권한이 없습니다.');
                            component.set('v.isSearched', false);
                            component.set('v.isLoading', false);
                            return;
                        }

                        if (responseData.flag === 'not Service Resource') {
                            helper.toast('WARNING', '로그인된 계정은 서비스요원 계정이 아닙니다.');
                            component.set('v.isSearched', false);
                            component.set('v.isLoading', false);
                            return;
                        }

                        if (responseData.flag === 'none Template') {
                            helper.toast('WARNING', '해당 오더 유형의 템플릿이 없습니다.');
                            component.set('v.isSearched', false);
                            component.set('v.isLoading', false);
                            return;
                        }
                        
                        const templateNumber = responseData.searchService.templateNumber;
                        const isTypeCheck = responseData.isTypeCheck;
                        const searchService = responseData.searchService;
                        const searchProductRequestList = responseData.searchProductRequestList; // 부품 사용 내역 리스트 (서비스 리포트)
                        const searchCommonPartsList = responseData.searchCommonPartsList; // 부품 사용 내역 리스트 (기획/순회 서비스)

                        if (responseData.failureAreaList) {
                            component.set('v.failureAreaList', responseData.failureAreaList);
                        }

                        if (!templateNumber || responseData.flag === 'error') {
                            component.set("v.templateNumber", "");
                            helper.toast('WARNING', 'This order number does not exist.');
                            component.set('v.isSearched', false);
                            component.set('v.isLoading', false);
                            return;
                        }

                        component.set("v.recordId", searchService.workOrderId);
                        component.set("v.templateNumber", templateNumber);
                        component.set("v.isTypeCheck", isTypeCheck);
                        component.set('v.isSearched', true);
                        component.set("v.serviceData", searchService);
                        console.log('isTypeCheck');
                        console.log(isTypeCheck);
                        console.log(templateNumber);
                        console.log(component.get("v.isConfirmed"));
                        console.log(searchService.isConfirmed);
                        if (searchService.isConfirmed) {
                            component.set("v.isConfirmed", searchService.isConfirmed);
                            component.set("v.confirmedDate", searchService.serviceReportInfo.confirmedDate);
                            if (templateNumber == 'RT08' || templateNumber == 'RT04' || templateNumber == 'RT05') {
                                component.set("v.isDisabled", searchService.isConfirmed);
                            }
                        }
                        let code = searchService.serviceReportInfo.workOrderTypeCode;
                        // 설치 시운전 단일 필드 값 셋팅
                        if ('104'=== code || templateNumber =='RT06') {
                            if (Object.keys(searchService.installTestInfo).length > 0) {
                                let installTestInfo = searchService.installTestInfo;
                                installTestInfo.workOrderResultId = searchService.workOrderResultId;

                                if(installTestInfo.totalInstallTime == 0) {
                                    installTestInfo.totalInstallTime = installTestInfo.mainInstallTime;
                                }
                                component.set("v.workOrderResultData", installTestInfo);
                                
                                // 설치 시운전 다중 체크 박스 값 셋팅
                                if (installTestInfo.preparationOptions) {
                                    let preparationOptions = installTestInfo.preparationOptions || ''; 
                                    
                                    let selectedOptions = preparationOptions ? preparationOptions.split(';').filter(option => option.trim() !== '') : [];
                                    component.set("v.multiPicklistValues", selectedOptions);
                                    
                                    component.set("v.installationFinish", searchService.installTestInfo.installationFinish);
                                    component.set("v.isHECareByAsset", searchService.installTestInfo.isHECareByAsset);
                                } else {
                                    component.set("v.multiPicklistValues", []); 
                                }

                                console.log('isHECare ::: ', JSON.stringify(installTestInfo.isHECare, null, 2));
                                console.log('isHEModel ::: ', JSON.stringify(installTestInfo.isHEModel, null, 2));
                                console.log('isSavePortal ::: ', JSON.stringify(searchService.isSavePortal, null, 2));
                                console.log('isHECareByAsset ::: ', JSON.stringify(searchService.installTestInfo.isHECareByAsset, null, 2));

                                if (installTestInfo.isHECare && installTestInfo.isHEModel) {
                                    component.set('v.isHECare', false);
                                    
                                    if (!searchService.isSavePortal) {
                                        searchService.installTestInfo.isHECareByAsset = true;
                                        component.set('v.workOrderResultData', searchService.installTestInfo);
                                    } 
                                    
                                    console.log('workOrderResultData ::: ', JSON.stringify(component.get('v.workOrderResultData'), null, 2));
                                    helper.toast("info", "자동화 옵션(AWC, LPS, RPS)가 부착된 장비일 경우 HE Care 1612 대상 장비 체크 바랍니다.");
                                } else if (!installTestInfo.isHECare && installTestInfo.isHEModel) {
                                    component.set('v.isHECare', true);
                                    searchService.installTestInfo.isHECareByAsset = true;
                                    component.set('v.workOrderResultData', searchService.installTestInfo);
                                } else {
                                    component.set('v.isHECare', true);
                                }
                            } 
                        } else {
                            if (Object.keys(searchService.repairHistoryInfo).length > 0) {
                                let repairHistoryInfo =  searchService.repairHistoryInfo
                                repairHistoryInfo.workOrderResultId = searchService.workOrderResultId;
                                if (repairHistoryInfo.selectedCauseArea.causeAreaCode) {
                                    component.set("v.repairActionGroupCode", '90000001');
                                }
                                if (repairHistoryInfo.reasonForOrverWork == '표준공수 없음을 선택하였습니다.') {
                                    component.set("v.isNoStandardWork", true);
                                }
                                component.set('v.workOrderResultData', repairHistoryInfo);
                            }
                        }
                        
                        // console.log('셋팅 테스트 ::: ',JSON.stringify(component.get('v.loginUserInfo'), null, 2));
                        // 공통 작업내역 리스트
                        if (searchService.workList) {
                            let isBranch = component.get("v.isBranch");
                            let workOrderResultList = searchService.workList;
                            let initWorkList = helper.initResultWorkList(workOrderResultList, templateNumber, isBranch);
                            component.set("v.workList", initWorkList);
                        }
                        // 설치 시운전 초기하자 리스트
                        if (searchService.defectList) {
                            let workOrderResultList = searchService.defectList;
                            let initDefectList = helper.initResultDefectList(workOrderResultList);
                            component.set("v.defectList", initDefectList);
                        }
                        // 조치결과 입력 표준 공수 리스트
                        if (searchService.standardWorkList) {
                            let workOrderResultList = searchService.standardWorkList;
                            let initStandardWorkList = helper.initResultStandardWorkList(workOrderResultList);
                            component.set("v.standardWorkList", initStandardWorkList);
                        }
                        // 유상 클레임 부품사용내역 (참조용) 리스트
                        if (searchService.productRequestList) {
                            let workOrderResultList = searchService.productRequestList;
                            let initUsageList = helper.initResultUsagePartsList(workOrderResultList);
                            component.set("v.usageList", initUsageList);
                        }
                        // 부품 사용 내역(기획/순회서비스)
                        if (searchCommonPartsList && !searchService.serviceReportInfo.warrantyService) {
                            component.set("v.commonParts", searchCommonPartsList);
                        }
                        // 조치결과 입력 부품 사용 내역 다중 픽리스트 셋팅
                        if (searchProductRequestList) {
                            let productRequests = helper.productPicklistSet(component, searchProductRequestList);
                            component.set("v.productRequests", productRequests);
                            console.log('test productRequest ::: ', JSON.stringify(searchProductRequestList, null, 2));
                        }
                        
                        let siteManager = searchService.serviceReportInfo.siteManager || '';
                        component.set("v.siteManager", siteManager);
                        let siteManagerPhone = searchService.serviceReportInfo.siteManagerPhone || '';
                        component.set("v.siteManagerPhone", siteManagerPhone);
                        let mainWorker  = searchService.serviceReportInfo.mainWorker || '';
                        component.set("v.mainWorker", mainWorker);
                        let mainWorkerPhone = searchService.serviceReportInfo.mainWorkerPhone || '';
                        component.set("v.mainWorkerPhone", mainWorkerPhone);

                        let representative = searchService.serviceReportInfo.representative || '';
                        let contactPhone = searchService.serviceReportInfo.contactPhone || '';

                        let isCustomerChecked = component.get("v.isCustomerChecked");
                        if ((siteManager || siteManagerPhone) && (representative == siteManager) && (contactPhone == siteManagerPhone)) {
                            isCustomerChecked = true;
                        } 
                        component.set("v.isCustomerChecked", isCustomerChecked);
                        
                        let isSiteManagerChecked = component.get("v.isSiteManagerChecked");
                        if ((siteManager || siteManagerPhone) && (mainWorker == siteManager) && (mainWorkerPhone == siteManagerPhone)) {
                            isSiteManagerChecked = true;
                        }
                        component.set("v.isSiteManagerChecked", isSiteManagerChecked);

                        // 모든 조건 체크 후 내부 CRM 서비스 오더 상세 페이지에서 액션버튼으로 조회 시 무조건 조회만 가능 25.03.14 추가
                        console.log('마지막 수정 가능 여부 체크 Flag ::: ', component.get("v.isCRMSearch"));
                        if(component.get("v.isCRMSearch") == true) {
                            component.set("v.isConfirmed", true);
                            console.log('isConfirmed ::: ', component.get("v.isConfirmed"));
                            component.set("v.isDisabled", true);
                            console.log('isDisabled ::: ', component.get("v.isDisabled"));
                        }
                        
                        component.set('v.isLoading', false);
                    }))
                    .catch(function (error) {
                        helper.toast('ERROR', 'An error occurred, please contact your administrator.!!');
                        console.log('# orderNumber error : ' + error.message);
                        component.set('v.isSearched', false);
                        component.set('v.isLoading', false);
                    });
                }))
                .catch(function (error) {
                    helper.toast('ERROR', 'An error occurred, please contact your administrator.!');
                    console.log('# IF Search error : ' + error.message);
                    component.set('v.isSearched', false);
                    component.set('v.isLoading', false);
                });
			
            }))
            .catch(function (error) {
                helper.toast('ERROR', 'An error occurred, please contact your administrator.');
                console.log('# IF Search error : ' + error.message);
                component.set('v.isSearched', false);
                component.set('v.isLoading', false);
            });
        }
        console.log(component.get("v.isTypeCheck"));
        console.log("search");        
    },   
    
    handleCompEvent : function(component, event, helper) {
        let modalName = event.getParam("modalName");
        let actionName = event.getParam("actionName");
        let message = event.getParam("message"); 

        console.log('handleCompEvent ServiceWrapper');
        console.log('modalName:', modalName);
        console.log('actionName:', actionName);
        console.log('message:', message);
        
        if (actionName == 'isConfirmed') {
            component.set("v.confirmedDate", message);
        }
    },
    
    handleKeyPress: function (component, event, helper) {
        if(event.keyCode === 13) {
            $A.enqueueAction(component.get('c.handleSearch'));
        }
    },

    // 출하지시서 열기
    openEquipment: function (component, event, helper) {
        var machineName = component.get("v.serviceData").serviceReportInfo.machineName;
        var assetName = component.get("v.serviceData").serviceReportInfo.assetName;

        var currentUrl = component.get("v.baseUrl");

        if (currentUrl.includes("--dev.sandbox")) {
            currentUrl += '/partners/s/equipment-specification-info' + '?machineName=' + encodeURIComponent(machineName) + '&assetName=' + encodeURIComponent(assetName);
        } else {
            currentUrl += '/s/equipment-specification-info' + '?machineName=' + encodeURIComponent(machineName) + '&assetName=' + encodeURIComponent(assetName);
        }
        
        window.open(currentUrl, '_blank');
    },
    
})