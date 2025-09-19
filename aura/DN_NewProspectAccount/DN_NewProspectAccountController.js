/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 05-21-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-01-17   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function(component, event, helper) {
        var baseUrl = window.location.origin;
        component.set("v.baseUrl", baseUrl);

        console.log('baseUrl :: ' + baseUrl);
        
        helper.apexCall(component, event, helper, 'getLoginUserInfo', {})
        .then($A.getCallback(function(result) {
            let r = result.r;

            console.log('TEST User ::: ', JSON.stringify(r, null, 2));

            component.set('v.isDomesticUser', r.isDomesticUser);
            // component.set('v.loginUserCountry' , r.loginUserCountry);
            // component.set('v.loginUserRegion' , r.loginUserRegion);
            component.set("v.loginUserInfo", r.loginUser);
            if (r.isDomesticUser) {
                component.set('v.isReadOnly',  true);
            }

        }))
        .catch(function(error) {
            helper.toast('ERROR', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            console.log('# search isDomesticUser check error : ' + error.message);
        });
    },

    handleSearchAddress : function(component, event, helper) {
        component.set('v.isAddress', true);
    },

    handleNewCustomer : function(component, event, helper) {
        component.set('v.newCustomerOpen', true);
        component.set('v.isCustomer', false);
        component.set('v.isSearched', false);
        // 2025-04-12 이청우 추가
        component.set("v.newPhone","");
    },

    cancelNewCustomer : function(component, event, helper) {
        component.set('v.newCustomerOpen', false);
    },

    handleModalEvent: function(component, event, helper) { 
        try {
            let message = event.getParam('message');
            let addressComponents = component.find('shippingAddress');
            let addressComponent = addressComponents[0];
            component.set("v.detailedAddress", message.detailedAddress);
            
            // addressComponent.set('v.street', message.selectedResult.roadAddr + '\n' + message.detailedAddress);
            addressComponent.set('v.street', message.detailedAddress);
            addressComponent.set('v.city', message.selectedResult.roadAddr);
            // addressComponent.set('v.city', message.selectedResult.siNm);
            addressComponent.set('v.country', 'Korea, Republic of');
            addressComponent.set('v.province', ' ');
            addressComponent.set('v.postalCode', message.selectedResult.zipNo);

            let sggNmField = component.find('recordField_sggNm');
        
            sggNmField.set('v.value', message.selectedResult.siNm + ' ' + message.selectedResult.sggNm);
            console.log('시군구명 ::: ', JSON.stringify(sggNmField));
        } catch (error) {
            console.log('handleModalEvent error: ' + JSON.stringify(error));
        }
    },

    // 고객사 선택 시 isCompanySelected 값 true / false를 통해 추가 컴포넌트 표시 여부 설정 
    handleAccountSelect: function(component, event) {
        const rowIndex = event.getSource().get('v.value');
        const rowData = component.get('v.resultCustomerList')[rowIndex];

        if (!rowData) {
            console.error('Row data is undefined for index:', rowIndex);
            return;
        }

        const allCheckboxes = component.find("checkbox");
        if (!allCheckboxes) {
            console.error('No checkboxes found.');
            return;
        }

        const checkboxesArray = Array.isArray(allCheckboxes) ? allCheckboxes : [allCheckboxes];
        if (event.getSource().get('v.checked')) {
            checkboxesArray.forEach(checkbox => {
                if (checkbox.get("v.value") !== rowIndex) {
                    checkbox.set("v.disabled", true);
                }
            });
        } else {
            checkboxesArray.forEach(checkbox => {
                checkbox.set("v.disabled", false);
            });
        }

        let isSelected = event.getSource().get("v.checked");
        component.set("v.isAccountSelected", isSelected);

        component.set("v.resultCustomer", rowData);
    },

    // 고객사 검색과 검색 후 컴포넌트 동작 처리
    handleSearchAccount : function(component, event, helper) {
        component.set('v.isLoading', true);

        let searchCustomerName = component.get("v.searchCustomerName").trim();
        let searchRepresentative = component.get("v.searchRepresentative").trim();
        let searchBusiness = component.get("v.searchBusiness").trim().replace(/[^0-9]/g, '');

        if (!searchCustomerName && !searchRepresentative && !searchBusiness) {
            helper.toast('WARNING', $A.get("$Label.c.DNS_ACC_T_ACCOUNT_ANY"));
            component.set('v.isLoading', false);
            return;
        } 
        
        // 2025-03-24 추가 이청우
        if(searchCustomerName.length < 2) {
            helper.toast('WARNING', $A.get("$Label.c.DNS_ACC_NAMELENGTH"));
            component.set('v.isLoading', false);
            return;
        }
        if(searchCustomerName == '삭제') {
            helper.toast('WARNING', '해당 이름은 검색할 수 없습니다.');
            component.set('v.isLoading', false);
            return;
        }
        helper.apexCall(component, event, helper, 'searchProspectAccount', {
            searchCustomerName :   searchCustomerName,
            searchRepresentative : searchRepresentative,
            searchBusiness : searchBusiness
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r ::: ', r);
            
            if(r.flag == 'success' && r.resultData.length > 0) {
                component.set("v.isCustomer", true);
                component.set("v.newCustomerOpen", false);
                component.set("v.isAccountSelected", false);
                component.set("v.resultCustomerList", r.resultData);
                
                var resultSize = r.resultData.length;
                var formattedSize = resultSize.toLocaleString();
                
                component.set("v.resultSize", formattedSize);

                if (r.resultData.isRequest == '승인') {
                    component.set("v.isRequest", true);
                    helper.toast('SUCCESS', $A.get("$Label.c.DNS_ACC_T_ALREADY_MYACCOUNT"));

                } else if (r.resultData.isRequest == '이미 요청됨') { 
                    component.set("v.isRequest", true);
                    helper.toast('SUCCESS', $A.get("$Label.c.DNS_ACC_T_ALREADY_REQUEST"));

                } else if (r.resultData.isRequest == '보호 고객') {
                    component.set("v.isRequest", true);
                    helper.toast('WARNING', $A.get("$Label.c.DNS_ACC_T_CANNOT_REQUEST"));
                }
            } 
            // else if (r.flag == 'Already') {
            //     component.set("v.isCustomer", false);
            //     component.set("v.newCustomerOpen", false);

            //     helper.toast('WARNING','Not Prospect Customer or Trade Customer.');
            // } 
            else {
                var formattedSize = 0;
                component.set("v.resultSize", formattedSize);

                component.set("v.isCustomer", false);
                component.set("v.newCustomerOpen", false);
                component.set("v.resultCustomer", '');
                
                // component.set("v.newCustomerName",searchCustomerName);
                // component.set("v.newRepresentative",searchRepresentative);
                // component.set("v.isSearched", true);
            }
            component.set("v.newCustomerName",searchCustomerName);
            component.set("v.newRepresentative",searchRepresentative);
            component.set("v.isSearched", true);

            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            helper.toast('ERROR', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            console.log('# searchcustomerId error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },
    
    // 고객사 사용 요청 
    handleRequestUse : function(component, event, helper) {
        let prospect = component.get("v.resultCustomer");
        prospect.requestReason = component.get("v.requestReason").trim();

        if (!prospect.accountId) {
            helper.toast('WARNING', $A.get("$Label.c.DNS_M_CustomerNotMatch"));
            component.set('v.isLoading', false); 
            return;
        }

        if (prospect.requestReason == null || prospect.requestReason === '') {
            helper.toast('WARNING', $A.get("$Label.c.DNS_M_EnterRequestReason"));
            component.set('v.isLoading', false); 
            return;
        }
        console.log(JSON.stringify(prospect, null, 4));

        component.set('v.isLoading', true);

        helper.apexCall(component, event, helper, 'requestToUse', { prospect })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            console.log('result test ::: ', JSON.stringify(result.r, null, 2));

            if (r.flag == 'success' && r.resultString != null) {
                let recordId = r.resultString;
                helper.toast('SUCCESS', $A.get("$Label.c.DNS_ACC_T_RequestCreation"));

                var externalLink = component.get("v.baseUrl");

                if (externalLink.includes("--dev.sandbox")) {
                    externalLink += '/partners/s/dns-requesttousecustomer/' + recordId;
                } else {
                    externalLink += '/s/dns-requesttousecustomer/' + recordId;
                }

                window.open(externalLink, '_top');
            } else if (r.flag === 'warning') {
                helper.toast('ERROR', r.message || $A.get("$Label.c.DNS_ACC_T_FOUNDFAIL"));
                component.set("v.isLoading", false);
            } else if (r.flag === 'already') {
                helper.toast('ERROR', r.message);
                component.set("v.isLoading", false);
            } else if (r.flag === 'auth') {
                helper.toast('ERROR', r.message);
                component.set("v.isLoading", false);
            }

            else {
                helper.toast('ERROR', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
                component.set("v.isLoading", false);
            }
        }))
        .catch(function(error) {
            helper.toast('ERROR', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            console.log('# requestcustomerId error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    // submit 대신 사용할 고객사 저장 
    handleSave : function(component, event, helper) {

        component.set('v.isLoading', true);

        try {
            var fieldMap = {};
            var inputs  = component.find('recordField');
            
            var sggNm  = component.find('recordField_sggNm');
            let isDomesticUser = component.get("v.isDomesticUser");
            let detailedAddress   = component.get("v.detailedAddress");

            if (!Array.isArray(inputs)) {
                inputs = [inputs];
            }
            
            for (let i = 0; i < inputs.length; i++) {
                let input = inputs[i];
                let fieldName = input.get("v.fieldName");
                
                if (fieldName === 'Competitor__c' && !component.get("v.isDomesticUser")) {
                    continue; 
                }

                // 25/01/03 이주현 추가 RegionLookup__c Null 일 때
                // if (fieldName === 'RegionLookup__c' && typeof(input.get("v.value")) === 'object' && input.get("v.value").length === 0 ){
                //     input.set("v.value", null);
                // }

                if (fieldName === 'RegionLookup__c') {
                    let regionValue = input.get("v.value");
                    if (regionValue == null || (typeof regionValue === 'object' && regionValue.length === 0)) {
                        input.set("v.value", null);
                    }
                }


                let loginUser = component.get('v.loginUserInfo');
                // Business Number Check
                // Coutry KR이 아닌 경우 10자리 제한 제외
                // if (fieldName === 'BusinessNumber__c' && loginUser.Account.CountryLookup__r.CountryCode__c == 'KR') {
                //     let businessNumber = input.get("v.value");
                //     if (businessNumber && businessNumber.length != 10) {
                //         helper.toast('WARNING', 'Please enter VAT Code(Busniess Number) of 10 characters.');
                //         component.set('v.isLoading', false);
                //         input.getElement().focus();
                //         return;
                //     }
                // }

                        
                if (input.get("v.required") && (input.get("v.value") == null || input.get("v.value") === '')) {
                    // helper.toast('WARNING', 'Please fill out all required fields : ' + fieldName);
                    helper.toast('WARNING', $A.get("$Label.c.DNS_M_FillOutRequireField"));
                    component.set('v.isLoading', false);
                    input.getElement().focus();
                    return;
                } 

                fieldMap[fieldName] = input.get("v.value");
            }

            if (isDomesticUser) {
                if (sggNm && typeof sggNm.get === 'function') {
                    let sggNmValue = sggNm.get("v.value"); 
                    if (!sggNmValue || sggNmValue == '') {
                        // helper.toast('WARNING', 'Please enter an address.');
                        helper.toast('WARNING', $A.get("$Label.c.DNS_M_EnterAddress"));
                        console.log('sggNm is null check.');
                        component.set('v.isLoading', false);
                        return;
                    }
                    fieldMap['sggNm__c'] = sggNmValue; 
                } else {
                    console.warn('sggNm component not found or invalid.');
                }
            }
            
            if (detailedAddress) {
                fieldMap['DetailAddress__c'] = detailedAddress; 
            }

            var shippingAddress = component.find('shippingAddress');
            if (Array.isArray(shippingAddress)) {
                shippingAddress = shippingAddress[0];
                console.log('shippingAddress', shippingAddress);
                
            }
    
            if (shippingAddress && typeof shippingAddress.get === 'function') {
                fieldMap['ShippingStreet'] = shippingAddress.get("v.street");
                fieldMap['ShippingCity'] = shippingAddress.get("v.city");
                fieldMap['ShippingState'] = shippingAddress.get("v.province");
                fieldMap['ShippingCountry'] = shippingAddress.get("v.country");
                fieldMap['ShippingPostalCode'] = shippingAddress.get("v.postalCode");
            } else {
                console.warn('Shipping Address component not found or invalid.');
            }

            if (
                !fieldMap['ShippingCity'] || 
                !fieldMap['ShippingPostalCode'] || 
                !fieldMap['ShippingCountry']
            ) {
                // helper.toast('WARNING', 'Please enter an address.');
                helper.toast('WARNING', $A.get("$Label.c.DNS_M_EnterAddress"));
                component.set('v.isLoading', false);
                return;
            }
            
            // 국내 : Postal Code 5자리로 제한. 글로벌은 자릿수 제한x
            if(isDomesticUser){
                if(fieldMap['ShippingPostalCode'] && fieldMap['ShippingPostalCode'].length !== 5){
                    // helper.toast('WARNING', 'Postal code should be 5 characters.');
                    helper.toast('WARNING', $A.get("$Label.c.DNS_M_PostalCodeChar"));
                    component.set('v.isLoading', false);
                    return;
                }
            }
            
            console.log(JSON.stringify(fieldMap, null, 2));


            helper.apexCall(component, event, helper, 'saveProspectAccount', {
                objectName: component.get('v.objectName'),
                fieldMap: fieldMap,
            })
            .then($A.getCallback(function(result) {
                let r = result.r;

                console.log('result :: '  + JSON.stringify(result));

                if (r.flag == 'virtual') {
                    helper.toast('WARNING', 'Parent Account creation was successful.');
                    component.set('v.isLoading', false);
                    return;
                } else if(r.flag == 'dupl') {
                    // helper.toast('WARNING', 'A duplicate business number exists.');
                    helper.toast('WARNING', $A.get("$Label.c.DNS_M_DuplBusinessNum"));
                    component.set('v.isLoading', false);
                    return;
                } else if(r.flag == 'already') {
                    // helper.toast('WARNING', 'This is a duplicate account and representative.');
                    helper.toast('WARNING', $A.get("$Label.c.DNS_M_DuplAccRep"));
                    component.set('v.isLoading', false);
                    return;                
                } else if(r.flag == 'ERPDUPLICATE') {
                    // helper.toast('ERROR', 'This is a customer that already exists in ERP.');
                    helper.toast('WARNING', $A.get("$Label.c.DNS_M_DuplERPAcc"));
                    console.log(r.errorString);
                    component.set('v.isLoading', false);
                    return;
                } else if(r.flag == 'fail') {
                    // helper.toast('WARNING', 'Check whether the account can be created.');
                    helper.toast('ERROR', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
                    component.set('v.isLoading', false);
                    return;                
                } else if(r.flag == 'success' && r.newRecordId != null ) {
                    let recordId = r.newRecordId;
                    helper.toast('SUCCESS', $A.get("$Label.c.DNS_M_PostalSaveSuccess"));
        
                    var externalLink = component.get("v.baseUrl");

                    if (externalLink.includes("--dev.sandbox")) {
                        externalLink += '/partners/dns-requesttousecustomer/' + recordId;
                    } else {
                        externalLink += '/s/requesttousecustomer/' + recordId;
                    }

                    // window.open(externalLink, '_top');
                    window.open('https://dportal.dn-solutions.com/s/account/' + recordId, '_top');
                }else if(r.flag =='Postal Code'){
                    helper.toast('ERROR', $A.get("$Label.c.DNS_M_PostalCodeError"));
                    console.log('Postal Code Error');
                    component.set('v.isLoading', false);
                    return;
                }  else {
                    helper.toast('ERROR', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
                    console.log(r.errorString);
                    console.log(r.stackTrace);
                    component.set('v.isLoading', false);
                }
            }));
        } catch (error) {
            console.log('handleSave Error : ' + error);
        }
    },
    
    // 고객사 검색 및 요청 버튼 엔터키 사용
    handleKeyPress: function (component, event, helper) {
        if(event.keyCode === 13) {
            $A.enqueueAction(component.get('c.handleSearchAccount'));
        }   
    } ,
})