({
    doInit: function(component, event, helper) {
        var body = component.get("v.body");
        console.log(body);
        body.forEach(function(childComponent) {
            var auraId = childComponent.getLocalId();
            if (auraId) {
                console.log("Aura ID: " + auraId);
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
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_AccountAddressPopUp',
            "actionName"    : 'Close',
            "message"       : 'Close'
        });
        modalEvent.fire();
        component.find('overlayLib').notifyClose();
    },

    handleSaveBtn : function(component, event, helper) {
        var selectedResult  = component.get("v.selectedResult");
        let method = 'setAddress';
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
                "modalName"     : 'DN_WCAddressPopUp',
                "actionName"    : 'Close',
                "message"       : 'Close'
            });
            modalEvent.fire();

            component.set('v.isLoading', false);
            component.find('overlayLib').notifyClose();
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# setShippingAddress error : ' + error.message);
        });
    }
})