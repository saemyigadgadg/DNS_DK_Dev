/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-11-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-12-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit: function(component, event, helper) {
        var body = component.get("v.body");
        body.forEach(function(childComponent) {
            var auraId = childComponent.getLocalId();
            if (auraId) {
            }
        });
        
        window.setTimeout(
            $A.getCallback(function() {
                var inputCmp = component.find("addressInput");
                if (inputCmp) {
                    inputCmp.focus();
                }
            }), 400
        );
        // 2024-12-05 iltae.seo 딜러포탈/대리점재고관리에서 사용하기 위해 별도로 설정
        helper.getSiteUrlList(component, event, helper);
    },

    searchAddress : function(component, event, helper) {
        component.set("v.pagingNumber", 1);
        helper.searchAddress(component, event, helper);
    },

    handleEnterSearch : function(component, event, helper) {
        if(event.keyCode === 13) {
            component.set("v.pagingNumber", 1);
            helper.searchAddress(component, event, helper);
        }
    },

    handleClickAddress : function(component, event, helper) {
        component.set('v.isLoading', true);
        var index           = event.currentTarget.getAttribute('data-index');
        var searchResults   = component.get("v.searchResults");
        var selectedResult  = searchResults[index];
        component.set('v.selectedResult', selectedResult);
        component.set('v.saveSearchText', component.get("v.searchText"));

        var vfHost = window.location.protocol + '//' + window.location.hostname + '/apex/DN_MOISAddressMap?admCd=' + selectedResult.admCd + '&rnMgtSn=' + selectedResult.rnMgtSn + '&udrtYn=' + selectedResult.udrtYn + '&buldMnnm=' + selectedResult.buldMnnm + '&buldSlno=' + selectedResult.buldSlno;
        // 커뮤니티용 사용가능하게 변경 24.12.10 진현욱
        if(vfHost.indexOf('my.site') != -1) {
            let pathNames = window.location.pathname.split('/');
            vfHost = '/'+pathNames[1]+'/apex/DN_MOISAddressMap?admCd=' + selectedResult.admCd + '&rnMgtSn=' + selectedResult.rnMgtSn + '&udrtYn=' + selectedResult.udrtYn + '&buldMnnm=' + selectedResult.buldMnnm + '&buldSlno=' + selectedResult.buldSlno;
        }        
     
        component.set("v.vfHost", vfHost);
        component.set('v.isSelected', true);
        component.set('v.isLoading', false);
    },

    handleTrueSearchAddress : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.isSelected', false);
        if(component.get("v.searchText") != component.get("v.saveSearchText")) {
            component.set("v.pagingNumber", 1);
            helper.searchAddress(component, event, helper);
        }
        component.set('v.isLoading', false);
    },

    handleTrueEnterSearch : function(component, event, helper) {
        if(event.keyCode === 13) {
            component.set('v.isLoading', true);
            component.set('v.isSelected', false);
            
            if(component.get("v.searchText") != component.get("v.saveSearchText")) {
                component.set("v.pagingNumber", 1);
                helper.searchAddress(component, event, helper);
            }
            component.set('v.isLoading', false);
        }
    },

    handleChangePage: function (component, event, helper) {
        try {
            var pageCountListIndex  = component.get('v.pageCountListIndex');
            var pageAllCountList    = component.get('v.pageAllCountList');
            var changePage          = Number(event.currentTarget.value);
            var name                = event.currentTarget.name;

            if (name == 'first') {
                changePage          = 1;
                pageCountListIndex  = 0;
            } else if (name == 'previous') {
                pageCountListIndex--;
                if (pageCountListIndex < 0) {
                    pageCountListIndex  = 0;
                    changePage          = pageAllCountList[pageCountListIndex][0] + 1;
                } else {
                    changePage = pageAllCountList[pageCountListIndex][pageAllCountList[pageCountListIndex].length - 1] + 1;
                }
            } else if (name == 'next') {
                pageCountListIndex++;
                if (pageCountListIndex >= pageAllCountList.length) {
                    pageCountListIndex  = pageAllCountList.length - 1;
                    changePage          = pageAllCountList[pageCountListIndex][pageAllCountList[pageCountListIndex].length - 1] + 1;
                } else {
                    changePage = pageAllCountList[pageCountListIndex][0] + 1;
                }
            }

            component.set('v.pagingNumber',         changePage);
            component.set('v.pageCountListIndex',   pageCountListIndex);
            component.set('v.pageCountList',        pageAllCountList[pageCountListIndex]);

            helper.searchAddress(component, event, helper);

        } catch (error) {
            console.log('handleChangePage Error : ' + JSON.stringify(error));
        }
    },

    handleChangeAddressRadio : function(component, event, helper) {
        var selectedValue = event.getSource().get("v.value");
        component.set('v.radioSelectedValue', selectedValue);
    },

    handleClose : function(component, event, helper) {     
        if(component.get('v.isCommunity')) {
            let addressType = component.get('v.addressType');
            //2024.12.12 디테일 화면에서 배송처 설정 기능으로 인해 분기처리
            if(addressType == 'quickAction') {
                component.set('v.isCommunity', false);
            } else {
                var modalEvent = component.getEvent('modalEvent');
                modalEvent.setParams({
                    "modalName"     : 'DN_AccountAddressPopUp',
                    "actionName"    : 'Close',
                    "message"       : 'Close'
                });
                modalEvent.fire();
                component.set('v.isCommunity', false);
                component.find('overlayLib').notifyClose();
            }
        } else {
            var modalEvent = component.getEvent('modalEvent');
            modalEvent.setParams({
                "modalName"     : 'DN_AccountAddressPopUp',
                "actionName"    : 'Close',
                "message"       : 'Close'
            });
            modalEvent.fire();
            component.set('v.isCommunity', false);
            component.find('overlayLib').notifyClose();
        }
    },

    handleSaveBtn : function(component, event, helper) {
        var selectedResult  = component.get("v.selectedResult");
        if(!component.get('v.isCommunity')) {
            let method = 'setShippingAddress';
            if('DealerCustomer__c' === component.get('v.sObjectName')) method = 'setDealerCustomerAddress';
            helper.apexCall(component, event, helper, method, {
                recordId    : component.get('v.recordId'),
                address     : selectedResult,
                detailInfo  : component.get('v.detailedAddress'),
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                
                if(r.flag == 'success') {
                    helper.toast('SUCCESS', '주소가 업데이트 되었습니다.');
                } else if(r.flag == 'fail') {
                    helper.toast('ERROR', '에러가 발생했습니다. 관리자에게 문의해 주세요.');
                } else {
                    helper.toast('ERROR', '주소 필드가 존재하지 않습니다.');
                }
                var modalEvent = component.getEvent('modalEvent');
                modalEvent.setParams({
                    "modalName"     : 'DN_AccountAddressPopUp',
                    "actionName"    : 'Close',
                    "message"       : 'Close'
                });
                modalEvent.fire();

                component.set('v.isCommunity', false);
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
                $A.get('e.force:refreshView').fire();
            }))
            .catch(function(error) {
                console.log('# setShippingAddress error : ' + error.message);
            });
        } else {
            // 2024-12-05 iltae.seo 딜러포탈/대리점재고관리에서 퀵액션 버튼으로도 사용하기 위해 분기처리  잠재고객이 
            let pathname = window.location.pathname;
            // 딜러포탈 고객 퀵액션에서 국내주소 검색 한경우
            if(pathname.includes('dealercustomer')) { 
                let addressType = component.get('v.addressType');
                if(addressType == 'shipToAddress') {
                    
                    let uuid = component.get('v.uuid');
                    if(uuid ==undefined) {
                        component.set("v.uuid", self.crypto.randomUUID());
                    }
                    var modalEvent = component.getEvent('modalEvent');
                    modalEvent.setParams({
                        "modalName"     : 'DN_AccountAddressPopUpController',
                        "actionName"    : 'addressInfo',
                        "message"       : {
                            selectedResult: selectedResult,
                            detailedAddress: component.get('v.detailedAddress'),
                            uuid : component.get('v.uuid')
                        }
                    });
                    modalEvent.fire();
                    component.set('v.isLoading', false);
                    component.set('v.isCommunity', false);
                    
                } else {
                    helper.apexCall(component, event, helper, 'setDealerCustomerAddress', {
                        recordId    : component.get('v.recordId'),
                        address     : selectedResult,
                        detailInfo  : component.get('v.detailedAddress'),
                    })
                    .then($A.getCallback(function(result) {
                        let r = result.r;
                        var modalEvent = component.getEvent('modalEvent');
                        modalEvent.setParams({
                            "modalName"     : 'DN_AccountAddressPopUp',
                            "actionName"    : 'Close',
                            "message"       : 'Close'
                        });
                        modalEvent.fire();
                        // component.set('v.isCommunity', false);
                        component.set('v.isLoading', false);
                        helper.toast('SUCCESS', '주소가 변경되었습니다.');
                        component.find('overlayLib').notifyClose();
                        $A.get('e.force:refreshView').fire();
                    }))
                    .catch(function(error) {
                        helper.toast('ERROR', '에러가 발생했습니다. 관리자에게 문의해주세요.');
                        console.log('# setDealerCustomerAddress : ' + error.message);
                    });
                }
                
            } else if(pathname.includes('account')) { // 2024 12 16 딜러포탈에서 Account를 사용하므로 추가 분기처리
                helper.apexCall(component, event, helper, 'setShippingAddress', {
                    recordId    : component.get('v.recordId'),
                    address     : selectedResult,
                    detailInfo  : component.get('v.detailedAddress'),
                })
                .then($A.getCallback(function(result) {
                    let r = result.r;
                    
                    if(r.flag == 'success') {
                        helper.toast('SUCCESS', '주소가 변경되었습니다.');
                    } else if(r.flag == 'fail') {
                        helper.toast('ERROR', '에러가 발생했습니다. 관리자에게 문의해주세요.');
                    } else {
                        helper.toast('ERROR', '주소 필드가 존재하지 않습니다.');
                    }
                    var modalEvent = component.getEvent('modalEvent');
                    modalEvent.setParams({
                        "modalName"     : 'DN_AccountAddressPopUp',
                        "actionName"    : 'Close',
                        "message"       : 'Close'
                    });
                    modalEvent.fire();
    
                    component.set('v.isCommunity', false);
                    component.set('v.isLoading', false);
                    component.find('overlayLib').notifyClose();
                    $A.get('e.force:refreshView').fire();
                }))
                .catch(function(error) {
                    console.log('# setShippingAddress error : ' + error.message);
                });
            } else {
                var modalEvent = component.getEvent('modalEvent');
                    modalEvent.setParams({
                        "modalName"     : 'DN_AccountAddressPopUpController',
                        "actionName"    : 'addressInfo',
                        "message"       : {
                            selectedResult: selectedResult,
                            detailedAddress: component.get('v.detailedAddress'),
                            uuid: component.get('v.uuid')
                        }
                    });
                modalEvent.fire();
                component.set('v.isLoading', false);
                component.set('v.isCommunity', false);
                component.find('overlayLib').notifyClose();
            }
        }
    }
})