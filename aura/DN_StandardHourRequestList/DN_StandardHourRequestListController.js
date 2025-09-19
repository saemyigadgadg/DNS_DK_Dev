({
    doInit : function(component, event, helper) {
        console.log('doInit');
        var today = new Date();
        var yyyy = today.getFullYear();
        var mm = (today.getMonth() + 1).toString().padStart(2, '0');
        var dd = today.getDate().toString().padStart(2, '0');
        var todayStr = yyyy + '-' + mm + '-' + dd;
        var startDateStr = yyyy + '-01-01';
        component.set('v.startDate', startDateStr);
        component.set('v.endDate', todayStr);
        component.set('v.isLoading', true);
        var statusList = [
            { label: '전체', value: '전체' },
            { label: '승인', value: '승인' },
            { label: '반려', value: '반려' },
            { label: '승인대기', value: '승인대기' }
        ];
        component.set('v.statusList', statusList);
        $A.getCallback(function() {
            component.get("c.handleSearch").run();
        })();
    },

    handleSearch: function(component, event, helper) {
        component.set('v.isLoading', true);
        var orderNumber    = component.get('v.orderNumber');
        var startDate      = component.get('v.startDate');
        var endDate        = component.get('v.endDate');
        var modelManager   = component.get('v.modelManager');
        var selectedStatus = component.get('v.selectedStatus');
        if (Array.isArray(modelManager)) {
            modelManager = undefined;
        }
        console.log('orderNumber =>', orderNumber);
        console.log('modelManager => ', modelManager);

        if(startDate == null || endDate == null) {
            component.set('v.isLoading', false);
            helper.showMyToast('Error', '요청기간 입력은 필수입니다.');
            return;
        }

        var action = component.get('c.getRequestList');
        action.setParams({
            orderNumber    : orderNumber,
            startDate      : startDate,
            endDate        : endDate,
            modelManager   : modelManager,
            selectedStatus : selectedStatus
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.requestList', result);
            } else {
                helper.showMyToast('Error', '정보를 검색하는데 문제가 발생하였습니다. 관리자에게 문의하십시오.');
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    clickApproval: function(component, event, helper) {
        component.set('v.openApproval', true);
        var rowIndex = event.getSource().get('v.accesskey');
        console.log('rowIndex =>', rowIndex);
        component.set('v.selectedIndex', rowIndex);
    },

    cancelApprove: function(component, event, helper) {
        component.set('v.openApproval', false);
    },

    clickReject: function(component, event, helper) {
        component.set('v.openReject', true);
        var rowIndex = event.getSource().get('v.accesskey');
        console.log('rowIndex =>', rowIndex);
        component.set('v.selectedIndex', rowIndex);
    },

    cancelReject: function(component, event, helper) {
        component.set('v.openReject', false);
    },

    approveRequest: function(component, event, helper) {
        component.set('v.isLoading', true);
        var requesterList = component.get('v.requestList');
        console.log('requesterList =>', requesterList);
        var rowIndex = component.get('v.selectedIndex');
        console.log(requesterList[rowIndex]);
        var JSONRequester = JSON.stringify(requesterList[rowIndex]);
        var action = component.get('c.confirmApproval');
        action.setParams({
            requesterData : JSONRequester
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                helper.showMyToast('SUCCESS', '성공적으로 승인이 완료되었습니다.');
                component.set('v.openApproval', false);
            } else {
                helper.showMyToast('ERROR', '승인에 실패하였습니다. 관리자에게 문의하십시오.');
            }
            $A.get('e.force:refreshView').fire();
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    rejectRequest: function(component, event, helper) {
        component.set('v.isLoading', true);
        var requesterList = component.get('v.requestList');
        console.log('requesterList =>', requesterList);
        var rowIndex = component.get('v.selectedIndex');
        console.log(requesterList[rowIndex]);
        var rejectReason = component.get('v.rejectReason');

        var JSONRequester = JSON.stringify(requesterList[rowIndex]);
        var action = component.get('c.confirmReject');
        action.setParams({
            requesterData : JSONRequester,
            rejectReason : rejectReason
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                helper.showMyToast('SUCCESS', '표준공수 신규/변경 요청이 반려되었습니다.');
                component.set('v.openReject', false);
            } else {
                helper.showMyToast('ERROR', '반려에 실패하였습니다. 관리자에게 문의하십시오.');
            }
            $A.get('e.force:refreshView').fire();
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    }
})