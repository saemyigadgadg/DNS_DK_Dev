({
    gfnDoinit : function(component, event) {
        console.log('gfnDoinit ::');
        let recordId = this.getUrlParameter('c_record');
        if(recordId) {
            component.set('v.recordId', recordId);
        }

        let type = this.getUrlParameter('c_type');
        if(type) {
            component.set('v.type', type);
            component._intervalFail = 0; 
            component._intervalId = setInterval(function() {
                this.checkElement(component); // checkElement() 메소드를 반복 호출
            }.bind(this), 100);
            console.log('component._intervalId : ', component._intervalId);
            
        }
        // const parsedUrl = new URL(window.location.href);
        // const queryParams = parsedUrl.searchParams;
        // if(queryParams.get("c_record")) {
        //     component.set('v.recordId', queryParams.get("c_record"));
        // }

        this.apexCall(component, event, this, 'detailInit', {
            recordId: component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {

            let { r, state } = result;
            console.log('detailInit.r : ',  r);
            console.log('detailInit.state : ',  state);
            if(r.status.code === 200 ) {
                component.set('v.orderHeaderInfo', r.order);
                r.order.itemList.forEach((orderItem) => orderItem.isSelected = false);
                component.set("v.orderDetailList", r.order.itemList);
            }
            // component.set('v.isSpinner', false);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            // component.set('v.isSpinner', false);
        });
    },

    checkElement : function(component) {
        let element = window.document.querySelector('div.forceCommunityRecordHeadline');
        
        if (element) {
            // 수정 버튼 찾기
            const editButtons = element.querySelectorAll('button.slds-button[name="DealerOrder__c.Edit"]');
            editButtons.forEach((btn) => {
                console.log('수정 버튼 찾음:', btn);
                btn.style.display = 'none'; // 삭제 버튼 숨기기
            });

            // 삭제 버튼 찾기
            const deleteButtons = element.querySelectorAll('button.slds-button[name="DealerOrder__c.Delete"]');
            deleteButtons.forEach((btn) => {
                console.log('삭제 버튼 찾음:', btn);
                btn.style.display = 'none'; // 삭제 버튼 숨기기

                console.log('component._intervalId : ', component._intervalId);
                clearInterval(component._intervalId);
            });

            
        } else {
            component._intervalFail += 1;
            if(component._intervalFail > 10)  clearInterval(component._intervalId);

            console.log("Element not found.");
        }
    },

    gfnSelectedOrderItem : function(component) {
        return component.get('v.orderDetailList').filter((orderItem)=> orderItem.isSelected);
    },

    
    gfnMoveDetail : function(component, id, obejctApi) {
        let pageRef = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": id,
                "objectApiName": obejctApi,
                "actionName": "view"
            }
        };

        this.navigationTo(component, pageRef);
    },

    gfnMoveCustomPage : function(component, pageName, state) {
        let pageRef = {
            type: 'comm__namedPage',
            attributes: {
                name: pageName
            },
            state
        };

        this.navigationTo(component, pageRef);
    },
    
    closeModal : function(component) {
        var modal = component.find("orderDetailModal");
        var modalBackGround = component.find("orderDetailModalBackGround");

        //modal close
        $A.util.removeClass(modal, "slds-fade-in-open");
        //modalbackground close
        $A.util.removeClass(modalBackGround, "slds-backdrop_open");
        //modal hide
        $A.util.addClass(modal, "slds-hide");
        
        modalBackGround.getElement().removeEventListener("click", function(e) {
            e.stopPropagation();
        });
    },

    showMyToast: function (type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    }
})