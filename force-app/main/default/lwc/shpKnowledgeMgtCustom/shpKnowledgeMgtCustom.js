import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getObjectInfo } from 'lightning/uiRecordApi';

export default class ShpKnowledgeMgtCustom extends LightningElement {
    @api recordId
    @track account;
    lastModifiedDate;


// @wire(getObjectInfo, { objectApiName: 'knowledege__kav' })
// yourOBJ({data, error}) {
//     if (data) {
//         console.log('Data: ', data);
//     } else if (error) {
//         console.error('Error: ', error);
//     }
// }

    @wire(getRecord, { recordId: '$recordId', fields: ['Approval_status__c', 'PublishStatus'] })
    wiredRecord(data, error) {
        console.log('accountRecord => ', data, error);
        if (data) {
            this.account = data;
            this.lastModifiedDate = data.lastModifiedDate;
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error));
        }
    }

}