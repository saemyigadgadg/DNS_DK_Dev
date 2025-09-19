({
    // apexCall : function( component, helper, methodName, params ) {
    //     var self = this;
    //     return new Promise($A.getCallback(function(resolve, reject) {
    //         let action = component.get('c.' + methodName);

    //         if(typeof action !== 'undefined') {
    //             action.setParams(params);

    //             action.setCallback(helper, function(response) {
    //                 if (response.getState() === 'SUCCESS') {
    //                     resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
    //                 } else {
    //                     let errors = response.getError();
    //                     console.log(methodName, errors);
	// 					reject(errors);
    //                 }
    //             });
    //             $A.enqueueAction(action);
    //         }
    //     }));
    // },
    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },
    handleSave : function( component, toastMessage) {
        let self = this;
        let valCheck = false;
        let ship = document.querySelectorAll('.detail-info-input');
        ship.forEach(element => {
            console.log(element.value,' value;;;');
            if(element.value.length > 36) {
                valCheck = true;
                element.setCustomValidity("상세주소는 최대 36자까지만 작성가능합니다.");
                // 유효성 검사 및 메시지 표시
                element.reportValidity();
            }
        });
        if(valCheck) {
            self.toast('error', '주소 정보를 확인해주세요.');
            return;
        }

        
        self.apexCall(component, null,this, 'addressUpsert', {
            recordId : component.get('v.recordId'),
            addressList : component.get('v.shipToList'),
            deleted : component.get('v.deleted')
        })
        .then($A.getCallback(function(result) {
            console.log('ship to Save');
           
            self.toast('success', `${toastMessage}`);
            component.find('headerCheckbox').set('v.checked',false);
            self.init(component);
            // let action = component.get('c.doInit');
            // $A.enqueueAction(action);
            //$A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# error : ' + error.message);
        });
    },

    init : function( component) {
        let self = this;
        this.apexCall(component, null, this, 'getShipToList', {
            recordId : component.get('v.recordId'),
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            let shipList = [];
            console.log("result", JSON.stringify(r));
            console.log(r.length,' ::: r.length');
            if(r.length > 0) {
                shipList = r;
            } else {
                shipList.push({
                    id : '', 
                    street : '', 
                    postalCode : '', 
                    city : '',
                    detailInfo : '',
                    sggNm : '',
                    roadAddr : ''
                });
            }
            console.log(JSON.stringify(shipList),' :: shipList');
            setTimeout(() => {
                component.set('v.shipToList', shipList);    
            },0 );
            
            console.log(JSON.stringify(component.get('v.shipToList')), ' SHIP LIST ::');
        }))
        .catch(function(error) {
            console.log('# searchAddress error : ' + error.message);
        });
    }
        
})