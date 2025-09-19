({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);

        helper.apexCall(component, event, helper, 'checkBusinessNumber', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r ::: ', r);
            
            if(r.flag == 'success') {
                component.set('v.resBody',  r.resBody.data);
                component.set('v.isFlag',   true);
                component.set('v.status',   r.resBody.data[0].b_stt);
                if(r.resBody.data[0].b_stt_cd != '' && r.resBody.data[0].b_stt_cd != '01') {
                    component.set('v.isFlag', false);
                    component.set('v.failResult', '조회하신 사업자는 ' + r.resBody.data[0].b_stt + ' 입니다.');
                } else if(r.resBody.data[0].b_stt_cd == '') {
                    component.set('v.isFlag', false);
                    component.set('v.failResult', '국세청에 등록되지 않은 사업자등록번호입니다.');
                }
            } else if(r.flag == 'null') {
                helper.closeModal(component, event);

                component.find('overlayLib').notifyClose();
                helper.toast('사업자 번호를 입력해주세요.', 'error');
            } else if(r.flag == 'already') {
                component.set('v.isAlready', true);
            } else if(r.flag == 'error') {
                helper.closeModal(component, event);
                component.find('overlayLib').notifyClose();
                helper.toast($A.get("$Label.c.DNS_ACC_T_ADMIN"), 'error');
            } else {
                helper.closeModal(component, event);
                component.find('overlayLib').notifyClose();
                helper.toast('API communication failed, please contact your administrator', 'error');
            }
            
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# doInit error : ' + error.message);
        });
    },

    handleConfirm : function(component, event, helper) {
        if(component.get('v.isFlag')) {
            helper.apexCall(component, event, helper, 'updateIsBusinessLicense', {
                recordId : component.get('v.recordId')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);
                helper.closeModal(component, event);
                component.find('overlayLib').notifyClose();
                $A.get('e.force:refreshView').fire();

                if(r.flag == 'success') {
                    helper.toast('사업자 번호 진위 확인이 완료되었습니다.', 'success');
                } else if(r.flag == 'fail') {
                    helper.toast($A.get("$Label.c.DNS_ACC_T_ADMIN"), 'error');
                } else {
                    helper.toast('중복된 사업자 번호가 있습니다. 확인 후 다시 시도하세요.', 'error');
                }
            }))
            .catch(function(error) {
                console.log('# doInit error : ' + error.message);
            });
        } else {
            helper.closeModal(component, event);
            component.find('overlayLib').notifyClose();
        }
    },

    handleClose : function(component, event, helper) {
        helper.closeModal(component, event);
        component.find('overlayLib').notifyClose();
    }
})