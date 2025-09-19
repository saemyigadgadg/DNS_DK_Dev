/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-15
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-05   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);

        // recordId로 Message_Group_Junction__c Object에 등록된 User의 정보 가져오기
        helper.apexCall(component, event, helper, 'checkManagerInfo', {
            recordId: component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            
            var r = result.r;
            var status = r.status;
            // console.log('r :: ' + JSON.stringify(r));
            // console.log('status :: ' + status);

            if (status == 'Success') {
                // console.log('Success');

                var manager = r.manager;
                var groupInfo = r.groupInfo;

                component.set('v.managerInfo', manager);
                component.set('v.groupInfo', groupInfo);

            } else if (status == 'NoRecord') {
                component.find('overlayLib').notifyClose();
                helper.toast('error', 'Record not found.');
                // console.log('status :: ' + status);
                
            } else if (status == 'NotOneUser') {
                component.find('overlayLib').notifyClose();
                helper.toast('error', 'Only one manager can be registered.');
                // console.log('status :: ' + status);
                
            } else if (status == 'NoUser') {
                component.find('overlayLib').notifyClose();
                helper.toast('error', 'Manager not found.');
                // console.log('status :: ' + status);
                
            } else if (status == 'Fail') {
                component.find('overlayLib').notifyClose();
                helper.toast('error', 'An error occurred, please contact your administrator.');
                // console.log('status :: ' + status);
            } 

            component.set('v.isLoading', false);
        }))
        .catch(function (error) {
            console.log('# doInit error : ' + error.message);
        });
    },


    handleConfirm: function (component, evnet, helper) {
        component.set('v.isLoading', true);

        helper.apexCall(component, event, helper, 'assignManagertoUser', {
            groupInfo: component.get('v.groupInfo'),
            managerInfo: component.get('v.managerInfo')
        })
        .then($A.getCallback(function(result) {
            
            let r = result.r;

            if (r == 'Success') {
                component.find('overlayLib').notifyClose();
                helper.toast('success', 'The manager assigned successfully.');
                // console.log('Success');

            } else {
                component.find('overlayLib').notifyClose();
                helper.toast('error', 'An error occurred, please contact your administrator.');
                // console.log('Fail');
          
            }

            component.set('v.isLoading', false);
        }))
        .catch(function (error) {
            console.log('# handleConfirm error : ' + error.message);
        });
    },


    handleCloseModal: function (component, event, helper) {
        component.find('overlayLib').notifyClose();
    },


})