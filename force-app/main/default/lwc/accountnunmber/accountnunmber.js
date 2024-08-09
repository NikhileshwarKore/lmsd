import { LightningElement, track } from 'lwc';

export default class SearchAccountNumber extends LightningElement {
    @track accountOptions = [
        // Sample account options, replace with actual account data
        { label: 'Account 1', value: '001' },
        { label: 'Account 2', value: '002' },
        { label: 'Account 3', value: '003' }
    ];

    @track selectedAccounts = [];

    columns = [
        { label: 'Account Name', fieldName: 'Name', type: 'text' },
        { label: 'Account Number', fieldName: 'AccountNumber', type: 'text' }
    ];

    handleAccountSelection(event) {
        let newSelections = event.detail.value;
        let uniqueSelections = [];

        // Remove duplicates from the selections
        newSelections.forEach(selection => {
            if (!this.selectedAccounts.find(account => account.value === selection)) {
                uniqueSelections.push(selection);
            }
        });

        this.selectedAccounts = this.accountOptions.filter(option => {
            return uniqueSelections.includes(option.value);
        });
    }
}