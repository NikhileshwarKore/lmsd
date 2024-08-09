import { LightningElement, api, wire } from 'lwc';
import getGridList from '@salesforce/apex/CaseController.getGridList';

export default class SelectedItemsTable extends LightningElement {
    @api selectedItemsData;
    columns = [
        { label: 'Case Number', fieldName: 'CaseNumber', type: 'text' },
        { label: 'Case Origin', fieldName: 'Origin', type: 'text' }
    ];

    @wire(getGridList)
    wiredCases({ error, data }) {
        if (data) {
            this.selectedItemsData = data;
        } else if (error) {
            console.error('Error fetching data:', error);
            // Handle error
        }
    }
}