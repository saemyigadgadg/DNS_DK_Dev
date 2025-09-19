/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-02-19
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-12-20   yeongdeok.seo@sbtglobal.com   Initial Version
**/
import { LightningElement, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import getStatusData from '@salesforce/apex/DN_CSPendingSatatusBoardController.getStatusData';
import myResource from "@salesforce/resourceUrl/brcArea";

export default class DNS_CSPendingStatusBoard extends LightningElement {
    channelName = '/event/StatusBoardEvent__e';
    subscription = null;
    @track currentWCName = '';
    @track currentWCData = {};
    @track workCenterList = [];
    @track workCenterDatas = {};
    timerId;
    isLoading = false;

    // Map Images
    @track brcArea = '';
    brcArea_01 = myResource + "/brcArea_01.png";
    brcArea_02 = myResource + "/brcArea_02.png";
    brcArea_03 = myResource + "/brcArea_03.png";
    brcArea_04 = myResource + "/brcArea_04.png";
    brcArea_05 = myResource + "/brcArea_05.png";
    brcArea_06 = myResource + "/brcArea_06.png";
    brcArea_07 = myResource + "/brcArea_07.png";
    brcArea_08 = myResource + "/brcArea_08.png";

    connectedCallback() {
        this.registerSubscribe();
        onError((error) => {
            console.error('CDC subscription error:', error);
        });
        this.refreshStatusData();
    }

    renderedCallback() {
        this.adjustSLDSStyles();
    }

    registerSubscribe() {
        try {
            subscribe(this.channelName, -1, this.handleCaseChangeEvent.bind(this))
                .then(response => {
                    console.log('Subscribed to channel:', response.channel);
                    this.subscription = response;
                })
                .catch(error => {
                    console.error('Subscription error:', error);
                });
        } catch (error) {
            console.error('Error in registerSubscribe:', error);
        }
    }

    handleCaseChangeEvent() {
        this.refreshStatusData();
    }

    refreshStatusData() {
        this.isLoading = true;
        getStatusData()
            .then((result) => {
                console.log('Updated Case counts:', result);
                this.updateStatusData(result);
            })
            .catch((error) => {
                console.error('Error fetching updated case counts:', error);
                this.error = error;
            });
    }

    //황준효 테스트용 플랫폼 이벤트
    // TicketEvent__e te = new TicketEvent__e();
    // te.ticketId__c = ticketList[0].Id;
    // System.debug('ticketLog ::: ' + te);
    // Database.SaveResult sr = EventBus.publish(te);
    // System.debug('sr ::: ' + sr);
    // if(sr.isSuccess()) {
    //     System.debug('Success');
    // }

    updateStatusData(data) {
        try {
            this.workCenterList = data.workCenterSet;
            this.workCenterDatas = data.workCenterData;
            // console.log('LIST ::: ', JSON.stringify(this.workCenterList));
            // console.log('DATAS ::: ', JSON.stringify(this.workCenterDatas));
            let i = 0;
            let isFirst = true;
            this.currentWCName = this.workCenterList[i];
            this.currentWCData = this.workCenterDatas[this.currentWCName];
            this.getImageUrl(this.currentWCName);

            // console.log('currentWCName ::: ', JSON.stringify(this.currentWCName));
            // console.log('currentWCData ::: ', JSON.stringify(this.currentWCData));

            this.timerId = setInterval(() => {
                if (isFirst) i = 1;
                this.currentWCName = this.workCenterList[i];
                this.currentWCData = this.workCenterDatas[this.currentWCName];
                this.getImageUrl(this.currentWCName);
                isFirst = false;
                i++;

                if (i == this.workCenterList.length) i = 0;
            }, 10000);
            this.isLoading = false;
        } catch (error) {
            console.log('에러 ::: ', error.message);
        }
    }

    disconnectedCallback() {
        clearInterval(this.timerId);
        if (this.subscription) {
            unsubscribe(this.subscription, () => {
                console.log('Unsubscribed from Case Change Event channel');
            });
        }
    }

    adjustSLDSStyles() {
        const style = document.createElement('style');
        style.innerText = `
            .title-wrap .icon-wrap .slds-icon-text-default,
            .call-wrap .card-title .slds-icon-text-default,
            .agent-wrap .card-container .slds-icon-text-default {
                fill: #adb5bd !important;
            }
         `;
        this.template.querySelector('.total-wrap').appendChild(style);
    }

    getImageUrl(name) {
        // /resource/1739855371000/brcArea/brcArea_02.png
        if (name == '수원지사') {
            this.brcArea = this.brcArea_01;
        } else if (name == '인천지사') {
            this.brcArea = this.brcArea_02;
        } else if (name == '대구지사') {
            this.brcArea = this.brcArea_03;
        } else if (name == '대전지사') {
            this.brcArea = this.brcArea_04;
        } else if (name == '천안POST') {
            this.brcArea = this.brcArea_05;
        } else if (name == '광주POST') {
            this.brcArea = this.brcArea_06;
        } else if (name == '부산지사') {
            this.brcArea = this.brcArea_07;
        } else if (name == '창원지사') {
            this.brcArea = this.brcArea_08;
        }
    }
}