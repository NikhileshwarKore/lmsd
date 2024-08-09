import { LightningElement, wire} from 'lwc';
import getMetaDataObjects from '@salesforce/apex/CustomMetadataLoaderController.getMetaDataObjects';
import uploadCSVDataFile from '@salesforce/apex/CustomMetadataLoaderController.uploadCSVDataFile';
import exportMetaData from '@salesforce/apex/CustomMetadataLoaderController.exportMetaData';
import saveRecords from '@salesforce/apex/CustomMetadataLoaderController.saveRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomMetadataLoader extends LightningElement {

    metaDataOptions = [];
    selectedMetadata;
    file;
    fileName;
    successMessage = '';
    uploadedData = [];
    showSpinner = false; 
    showSaveButton = false; 
    showUploadButton = true; 
    showExportButton = false;
 
    // Call the Apex method to get metadata objects  
    @wire(getMetaDataObjects)
    wiredMetaData({ error, data }) {
        if (data) {
            this.metaDataOptions = data;
        } else if (error) {
            this.showToast('Error', 'Error loading metadata objects', 'error');
        }
    }

    handleMetadataChange(event) {
        this.selectedMetadata = event.detail.value;
        this.showExportButton = this.selectedMetadata !== null;
    }

    handleFileChange(event) {
        this.files = event.target.files;
        if (this.files.length > 0) {
            const selectedFile = this.files[0];
            this.fileName = selectedFile.name.toLowerCase(); // Convert to lowercase
            if (this.fileName.endsWith('.csv')) {
                this.file = selectedFile;
            } else {
                this.file = null;
            }
        }
    }
   
    handleFileUpload() {
        
        if (this.file && this.selectedMetadata) {
            this.showSpinner = true;
            const reader = new FileReader();
            reader.onload = (event) => {
                const csvData = event.target.result;
                uploadCSVDataFile({ csvData: csvData, metadataType: this.selectedMetadata })
                    .then(records => {
                        if (records && records.length > 0) {
                            this.uploadedData = records;
                            this.successMessage = `${records.length} records uploaded successfully`;
                            this.showToast('Success', this.successMessage, 'success');
                            this.showSaveButton = true;
                            this.showUploadButton = false;
                            this.showExportButton = false;
    
                        } else {
                            this.uploadedData = [];
                            this.successMessage = '';
                            this.showToast('Error', 'CSV record does not match the number of fields.', 'error');
                            this.showSaveButton = false;
                            this.showExportButton = false;
                        }
                    })
                    .catch(error => {
                        this.uploadedData = [];
                        this.successMessage = '';
                        this.showToast('Error', error.body.message, 'error');
                       // this.showToast('Error', 'There was an error uploading the CSV data', 'error');
                    })
                    .finally(() => {
                        this.showSpinner = false;
                    });
            };
            reader.readAsText(this.file);
        } else {
            this.uploadedData = [];
            this.successMessage = '';
            this.showToast('Error', 'Please choose both a CSV file and a metadata type', 'error');
            this.showSpinner = false;
        }
    }
    
    handleSave() {
        if (this.selectedMetadata && this.uploadedData.length > 0) {
            this.showSpinner = true;
            console.log('csv data>>>>', this.uploadedData);
            saveRecords({ metadataType: this.selectedMetadata, records: this.uploadedData })
                .then(savedRecordCount => {
                    const successMessage = `${savedRecordCount} Records for ${this.selectedMetadata} saved successfully.`;
                    this.showToast('Success', successMessage, 'success');
                    this.showSaveButton = false;
                })
                .catch(error => {
                    this.showToast('Error','There was an error saving the records'+ error.body.message, 'error');
                   // this.showToast('Error', 'There was an error saving the records', 'error');     
                })
                .finally(() => {
                    this.showSpinner = false; // Reset spinner to false after the Apex call
                });
        }
    }

    exportToExcel() {
        this.showSpinner = true;
        // Fetch all fields and records based on the selected custom metadata type
        exportMetaData({ selectedMetadata: this.selectedMetadata })
            .then(result => {
                if (result && result.length > 0) {
                    let doc = '<table>';
                    // Add all the Table Headers with dynamic field labels
                    doc += '<tr>';
                    Object.keys(result[0]).forEach(field => {
                        doc += '<th>' + field + '</th>';
                    });
                    doc += '</tr>';
                    // Add the data rows
                    result.forEach(record => {
                        doc += '<tr>';
                        Object.keys(result[0]).forEach(field => {
                            doc += '<td>' + (record[field] !== undefined ? record[field] : '') + '</td>';
                        });
                        doc += '</tr>';
                    });
                    doc += '</table>';
                    var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
                    let downloadElement = document.createElement('a');
                    downloadElement.href = element;
                    downloadElement.target = '_self';
                    downloadElement.download = this.selectedMetadata  + '.xls';
                    document.body.appendChild(downloadElement);
                    downloadElement.click();
                }
                this.showToast('Success', 'Your file was downloaded successfully.', 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching records' +error.body.message, 'error');
            }) 
            .finally(() => {
                this.showSpinner = false; 
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}