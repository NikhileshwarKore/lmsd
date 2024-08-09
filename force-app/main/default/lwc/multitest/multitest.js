import { LightningElement, api, track } from 'lwc';
import getResults from '@salesforce/apex/lwcMultiLookupController.getResults';

export default class LwcMultiLookup extends LightningElement {
    // Properties for comboboxes
    @track territoryValue;
    @track caseIdValue;
    @track patientValue;
    @track territoryOptions = [];
    @track caseIdOptions = [];
    @track patientOptions = [];

    // Existing properties
    @api objectName = 'Account';
    @api fieldName = 'Name';
    @api Label;
    @track searchRecords = [];
    @track selectedRecords = [];
    @api required = false;
    @api LoadingText = false;
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track messageFlag = false;

    // Search field method
    searchField(event) {
        const currentText = event.target.value;
        const selectRecId = this.selectedRecords.map(record => record.recId);
        this.LoadingText = true;
        getResults({ ObjectName: this.objectName, fieldName: this.fieldName, value: currentText, selectedRecId: selectRecId })
            .then(result => {
                this.searchRecords = result;
                this.LoadingText = false;
                this.txtclassname = result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
                this.messageFlag = currentText.length > 0 && result.length === 0;
            })
            .catch(error => {
                console.error(error);
            });
    }

    // Set selected record method
    setSelectedRecord(event) {
        const recId = event.currentTarget.dataset.id;
        const selectName = event.currentTarget.dataset.name;
        this.selectedRecords.push({ recId, recName: selectName });
        this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
        this.dispatchEvent(new CustomEvent('selected', { detail: { selRecords: this.selectedRecords } }));
    }

    // Remove selected record method
    removeRecord(event) {
        const removedRecId = event.detail.name;
        this.selectedRecords = this.selectedRecords.filter(record => record.recId !== removedRecId);
        this.dispatchEvent(new CustomEvent('selected', { detail: { selRecords: this.selectedRecords } }));
    }

    // Handle onchange event for Territory combobox
    handleTerritoryChange(event) {
        this.territoryValue = event.detail.value;
        // Call a method to fetch options based on the selected value
        // and update territoryOptions accordingly
    }

    // Handle onchange event for CaseId combobox
    handleCaseIdChange(event) {
        this.caseIdValue = event.detail.value;
        // Call a method to fetch options based on the selected value
        // and update caseIdOptions accordingly
    }

    // Handle onchange event for Patient combobox
    handlePatientChange(event) {
        this.patientValue = event.detail.value;
        // Call a method to fetch options based on the selected value
        // and update patientOptions accordingly
    }
}