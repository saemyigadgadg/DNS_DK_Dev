import { LightningElement, api, wire } from 'lwc';
import getRelatedRecords from '@salesforce/apex/dealerTicketRelatedListController.getRelatedRecords';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';

export default class CustomRelatedList extends NavigationMixin(LightningElement) {
    recordId;
    records;
    error;

    columns = [
        {
            label: 'Ticket Number',
            fieldName: 'caseUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'CaseNumber' },
                target: '_blank'
            }
        },
        { label: 'Subject', fieldName: 'Subject', type: 'text' },
        { label: 'Status', fieldName: 'Status', type: 'text' }
    ];

    connectedCallback() {
        const url = new URL(window.location.href);
        const pathParts = url.pathname.split('/');

        // 예: /partners/s/account/001F700001lLkqKIAS/testaccount
        const accountIndex = pathParts.indexOf('account');
        if (accountIndex !== -1 && pathParts.length > accountIndex + 1) {
            this.recordId = pathParts[accountIndex + 1];
        }

        console.log('recordId:', this.recordId);
        console.log('USER_ID:', USER_ID);

        getRelatedRecords({
                    accountId: this.recordId,
                    userId :  USER_ID
                }).then(result => {
                    console.log('result::: ', result);
                    this.records = result.map(row => ({
                        ...row,
                        caseUrl: `/partners/s/case/${row.Id}/view`
                    }));
                }).catch(error => {
                    console.log(JSON.stringify(error));
                }).finally(() => this.isLoading = false );
    }

    // @wire(getRelatedRecords, { accountId: '$recordId', userId: USER_ID })
    // wiredRecords({ error, data }) {
    //     console.log('------------');
    //     console.log(data);
    //     console.log(USER_ID);
    //     console.log(recordId);
    //     console.log('------------');
    //     if (data) {
    //         console.log('JSON.stringify(data)');
    //         console.log(JSON.stringify(data));
    //         this.records = data.map(row => ({
    //             ...row,
    //             caseUrl: `/lightning/r/Case/${row.Id}/view`
    //         }));
    //         this.error = undefined;
    //     } else if (error) {
    //         console.log('JSON.stringify(error)');
    //         console.log(JSON.stringify(error));
    //         this.error = error.body.message;
    //         this.records = undefined;
    //     }
    // }
}