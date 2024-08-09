// RecordViewDemo.js
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import CASE_OBJECT from '@salesforce/schema/Case';

export default class RecordViewDemo extends LightningElement {
    @api recordId;
    activeSections = ['A', 'B'];

    @wire(getRecord, { recordId: '$recordId', fields: [CASE_OBJECT.recordTypeId] })
    wiredCase({ error, data }) {
        if (data) {
            const recordTypeId = data.fields.RecordTypeId.value;
            this.isProductRecord = recordTypeId === 'product'; // Replace 'productRecordTypeId' with your actual record type ID
            this.isMarketRecord = recordTypeId === 'market'; // Replace 'marketRecordTypeId' with your actual record type ID
        } else if (error) {
            // Handle error
        }
    }
}