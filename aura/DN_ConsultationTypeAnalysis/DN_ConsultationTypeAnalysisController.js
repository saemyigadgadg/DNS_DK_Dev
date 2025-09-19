({
    init: function (component, event, helper) {
        const today = new Date();
        const year = today.getFullYear(); // 2023
        const month = (today.getMonth() + 1).toString().padStart(2, '0'); // 06
        const day = today.getDate().toString().padStart(2, '0'); // 18

        const dateString = year + '-' + month + '-' + day;
        component.set('v.startDate', dateString);
        component.set('v.endDate', dateString);
    },

    switchListView: function (component, event) {
        var value = event.getParam("value");
        if (value === 'date') {
            component.set("v.isByDate", true);
        } else {
            component.set("v.isByDate", false);
        }
    },
    handleSearch: function (component, event, helper) {
        var reportType = component.get('v.reportType');
        console.log('reportType', reportType);

        if($A.util.isEmpty(component.get('v.startDate')) || $A.util.isEmpty(component.get('v.endDate'))){
            helper.toast(component, 'ERROR', '조회일자를 정확히 입력해주세요.', 'Error');
            return;
        }

        var params = {
            startDate: component.get('v.startDate'),
            endDate: component.get('v.endDate')
        };
        if (reportType == 'date') {//일자
            helper.apex(component, 'getDailyData', params)
                .then(function (result) {
                    console.log('getDailyData', result);
                    if (result.isSuccess) {
                        component.set('v.byDate', result.dateList);
                        if (result.dateList.length > 0) {
                            helper.getData(component);
                        } else {
                            component.set("v.dateSum", []);
                        }
                    } else {
                        helper.toast(component, result.errMessage(), 'ERROR', 'Error');
                    }
                });
        } else {//상담원
            helper.apex(component, 'getPersonData', params)
                .then(function (result) {
                    console.log('getPersonData', result);
                    if (result.isSuccess) {
                        component.set('v.byAgent', result.dateList);
                        if (result.dateList.length > 0) {
                            helper.getData(component);
                        } else {
                            component.set("v.agentSum", []);
                        }
                    } else {
                        helper.toast(component, result.errMessage(), 'ERROR', 'Error');
                    }
                });
        }
    },
})