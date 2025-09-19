({
    doInit : function(component, event, helper) {

    },

    handleCheckBusinessNumber : function(component, event, helper) {
        component.set('v.isLoading', true);
        let businessNumber = component.get("v.businessNumber");

        helper.apexCall(component, event, helper, 'checkBusinessNumber_ListView', {
            inputValue : businessNumber
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r ::: ', r);
            
            if(r.flag == 'success') {
                component.set('v.resBody',  r.resBody.data);
                component.set('v.isFlag',   true);
                if(r.resBody.data[0].b_stt_cd != '' && r.resBody.data[0].b_stt_cd != '01') {
                    component.set('v.isFlag', false);
                    component.set('v.failResult', '조회하신 사업자는 ' + r.resBody.data[0].b_stt + ' 입니다. \n폐업한 사업자번호로는 추후 주문 생성 불가 하오니, 고객의 유효한 사업자번호 확인 후 진행해주세요.');
                } else if(r.resBody.data[0].b_stt_cd == '') {
                    component.set('v.isFlag', false);
                    component.set('v.failResult', '국세청에 등록되지 않은 사업자등록번호입니다.');
                }
            } else if(r.flag == 'null') {
                component.set('v.isFlag', false);
                component.set('v.failResult', '사업자번호를 입력해주세요.');
            } else if(r.flag == 'error') {
                helper.toast($A.get("$Label.c.DNS_ACC_T_ADMIN"), 'error');
            } else {
                helper.toast('API communication failed, please contact your administrator', 'error');
            }
            
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# checkBusinessNumber_ListView error : ' + error.message);
        });
    },

    handleClose : function(component, event, helper) {
        window.history.back();
    }
})