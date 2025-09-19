/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-06-04
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-05-29   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.apexCall(component, event, helper, 'getTeamMemberList', {
            recordId: component.get('v.recordId')
        })
        .then($A.getCallback(function(res) {
            var list = res.r || [];

            console.log('List ::' + list);

            if (list.length < 1 ) {
                component.find('overlayLib').notifyClose();
                component.set('v.accTeamList', []);
                helper.toast('warning', '삭제할 팀 구성원이 없습니다.');
            } else {
                component.set('v.accTeamList', list);
            }

        }))
        .catch(function(err) {
            helper.toast('error', 'Failed to load team members.');
            console.error(err);

        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });



    },

    handleDelete: function(component, event, helper) {
        // 1) 선택된 체크박스 모으기
        // var selected = [];
        // var boxes = component.find("rowCheckbox");

        // if (!$A.util.isArray(boxes)) boxes = [boxes];

        // boxes.forEach(function(cb) {
        //     if (cb.get("v.checked")) {
        //         selected.push(cb.get("v.value"));
        //     }
        // });

        // if (selected.length === 0) {
        //     helper.toast("warning", "삭제할 멤버를 선택해 주세요.");
        //     return;
        // }

        component.set("v.isLoading", true);

        // 2) Apex로 삭제 요청
        helper.apexCall(component, event, helper, "deleteTeamMembers", {
            recordId: component.get('v.recordId')
        })
        .then($A.getCallback(function(res) {
            // component.find('overlayLib').notifyClose();

            var accId = res.r;

            console.log('accId :: ' + accId);

            if(accId != '' ){
                window.location.href = "/" + accId;
                helper.toast("success", "팀 구성원이 성공적으로 삭제되었습니다.");
                $A.get('e.force:refreshView').fire();
            }else{
                helper.toast(component, 'Error', res.r, 'error');
            }
        }))
        .catch(function(err) {
            component.set("v.isLoading", false);
            helper.toast("error", "삭제 중 오류가 발생했습니다.");
            console.error(err);
        });
    },

    handleCloseModal: function (component, event, helper) {
        // component.find('overlayLib').notifyClose();
        window.history.back();
    },


})