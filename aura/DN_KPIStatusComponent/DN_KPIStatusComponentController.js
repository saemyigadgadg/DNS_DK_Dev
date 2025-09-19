/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-26
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-01-10   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var today = new Date();
        var year = today.getFullYear();
        var month = today.getMonth() + 1;

        var date = String(year) + '-' + String(month).padStart(2, '0');

        component.set('v.monthlyStartDate', date);
        component.set('v.monthlyEndDate', date);

        component.set('v.weeklyStartDate', date);
        component.set('v.weeklyEndDate', date);

        helper.apex(component, 'getPicklistLabelValue', {})
        .then(result => {
            if (result.result.isSuccess) {
                console.log('topWorkcenterOptions ::: ', JSON.stringify(result.topWorkcenterList));
                console.log('WorkcenterOptions ::: ', JSON.stringify(result.workcenterList));
                component.set('v.monthlyTopWorkcenterOptions', result.topWorkcenterList);
                component.set('v.monthlyWorkcenterOptions', result.workcenterList);
                component.set('v.weeklyTopWorkcenterOptions', result.topWorkcenterList);
                component.set('v.weeklyWorkcenterOptions', result.workcenterList);
            }
        }).catch(error => {
            console.log('Error ::: ' + error.message);
        });
    },

    monthlyHandleChangeTopWorkcenter : function(component, event, helper) {
        var value = component.get('v.monthlyTopWorkcenter');
        var options = component.get('v.monthlyTopWorkcenterOptions');
        var label = options.find(option => option.value === value).label;
        console.log('value ::: ', value);
        console.log('label ::: ', label);
    },

    monthlyHandleChangeWorkcenter : function(component, event, helper) {
        var value = component.get('v.monthlyWorkcenter');
        var options = component.get('v.monthlyWorkcenterOptions');
        var label = options.find(option => option.value === value).label;
        console.log('value ::: ', value);
        console.log('label ::: ', label);
    },

    monthlyHandleSearchButton : function(component, event, helper) {
        console.log('startDate ::: ', component.get('v.monthlyStartDate'));
        console.log('endDate ::: ', component.get('v.monthlyEndDate'));
        console.log('topWorkcenter ::: ', component.get('v.monthlyTopWorkcenter'));
        console.log('workcenter ::: ', component.get('v.monthlyWorkcenter'));
        console.log('월간조회~!');

        component.set('v.isLoading', true);

        var startDate = component.get('v.monthlyStartDate');
        var endDate = component.get('v.monthlyEndDate');
        var topWorkcenter = component.get('v.monthlyTopWorkcenter');
        var workcenter = component.get(    'v.monthlyWorkcenter');
        var workcenterId = '';
        var workcenterType = 'all';

        if (topWorkcenter == 'all' && workcenter != 'all') {
            workcenterId = workcenter;
            workcenterType = 'WC';
        } else if (topWorkcenter != 'all') {
            workcenterId = topWorkcenter;
            workcenterType = 'TopWC';
        }

        helper.apex(component, 'getTicketList', {
            startDate : startDate,
            endDate : endDate
        }).then(result1 => {
            helper.apex(component, 'getData', {
                fullTicketList : result1,
                startDate : startDate,
                endDate : endDate,
                workcenterId : workcenterId,
                type : workcenterType,
                keyType : 'monthly'
            }).then(result => {
                console.log('getMonthlyData result ::: ', result);
                component.set('v.monthlyData', result);
            }).catch(error => {
                console.log('getMonthlyData error ::: ', error.message);
            }).finally(() => {
                component.set('v.isLoading', false);
            });
        }).catch(error => {
            console.log('getMonthlyData error ::: ', error.message);
        });

    },

    weeklyHandleChangeTopWorkcenter : function(component, event, helper) {
        console.log('value ::: ', component.get('v.weeklyTopWorkcenter'));
        var value = component.get('v.weeklyTopWorkcenter');
        var options = component.get('v.weeklyTopWorkcenterOptions');
        var label = options.find(option => option.value === value).label;
        console.log('value ::: ', value);
        console.log('label ::: ', label);
    },

    weeklyHandleChangeWorkcenter : function(component, event, helper) {
        console.log('value ::: ', component.get('v.weeklyWorkcenter'));
        var value = component.get('v.weeklyWorkcenter');
        var options = component.get('v.weeklyWorkcenterOptions');
        var label = options.find(option => option.value === value).label;
        console.log('value ::: ', value);
        console.log('label ::: ', label);
    },

    weeklyHandleSearchButton : function(component, event, helper) {
        console.log('startDate ::: ', component.get('v.weeklyStartDate'));
        console.log('endDate ::: ', component.get('v.weeklyEndDate'));
        console.log('topWorkcenter ::: ', component.get('v.weeklyTopWorkcenter'));
        console.log('workcenter ::: ', component.get('v.weeklyWorkcenter'));
        console.log('주간조회~!');

        component.set('v.isLoading', true);

        var startDate = component.get('v.weeklyStartDate');
        var endDate = component.get('v.weeklyEndDate');
        var topWorkcenter = component.get('v.weeklyTopWorkcenter');
        var workcenter = component.get(    'v.weeklyWorkcenter');
        var workcenterId = '';
        var workcenterType = 'all';

        if (topWorkcenter == 'all' && workcenter != 'all') {
            workcenterId = workcenter;
            workcenterType = 'WC';
        } else if (topWorkcenter != 'all') {
            workcenterId = topWorkcenter;
            workcenterType = 'TopWC';
        }

        helper.apex(component, 'getTicketList', {
            startDate : startDate,
            endDate : endDate
        }).then(result1 => {
            helper.apex(component, 'getData', {
                fullTicketList : result1,
                startDate : startDate,
                endDate : endDate,
                workcenterId : workcenterId,
                type : workcenterType,
                keyType : 'weekly'
            }).then(result => {
                console.log('getWeeklyData result ::: ', result);
                component.set('v.weenklyData', result);
            }).catch(error => {
                console.log('getWeeklyData error ::: ', error.message);
            }).finally(() => {
                component.set('v.isLoading', false);
            });
        }).catch(error => {
            console.log('getMonthlyData error ::: ', error.message);
        });

        // helper.apex(component, 'getData', {
        //     startDate : startDate,
        //     endDate : endDate,
        //     workcenterId : workcenterId,
        //     type : workcenterType,
        //     keyType : 'weekly'
        // }).then(result => {
        //     console.log('getWeeklyData result ::: ', result);
        //     component.set('v.weenklyData', result);
        // }).catch(error => {
        //     console.log('getWeeklyData error ::: ', error.message);
        // }).finally(() => {
        //     component.set('v.isLoading', false);
        // });
    }
})