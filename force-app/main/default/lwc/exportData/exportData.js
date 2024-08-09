/*import { LightningElement, wire } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import getRecords from '@salesforce/apex/ExportDataFromMetadata.getLoadData';
import workbook from '@salesforce/resourceUrl/writeexcelfile';
export default class ExportData extends LightningElement {
    isLibraryLoaded = false;
    //columnHeader = [];
    records=[];
    dynamicColumns;
    ..connectedCallback(){
        alert('Hii-->')
       this.handleMeta();
    }
    handleMeta() {
        getRecords()
            .then(result => {
                this.records=result;
            alert('Method')
            })
            .catch(error => {
                this.error = error;
            });
    }..
    @wire(getRecords)
    wiredData({ error, data }) {
        if (data) {
            this.records=data;
            this.dynamicColumns=this.generateColumns(data[0]);
            
            alert ('Data-->' +JSON.stringify(this.records));
            alert ('Column Data-->' +JSON.stringify(this. dynamicColumns));

        } else if (error) {
            console.error('Error:', error);
        }
    }
    renderedCallback() {
        if (this.isLibraryLoaded) return;
        this.isLibraryLoaded = true;
        loadScript(this, workbook )
            .then(async (data) => {
                alert('success------>>>', JSON.stringify(data))
                console.log("success------>>>", JSON.stringify(data));
            })
            .catch(error => {
                console.log("failure-------->>>>", error);
            });
    }
    // calling the download function from xlsxMain.js
    async exportToXLSX() {
        let _self = this;
        var columns = [
            {
                column: '',
                type: String,
                value: d => d.this.dynamicColumns
            },

        ]; 
        await writeXlsxFile(_self.records, {
            schema: columns,
            fileName: 'file.xlsx',
            headerStyle: {
                backgroundColor: '#1E2F97',
                fontWeight: 'bold',
                align: 'center',
                color:'#FFFFFF'
            }
        })
    }
    generateColumns(record) {
        if (!record) {
            return [];
        }
        return Object.keys(record).map(fieldName => ({
            label: fieldName,
            fieldName: fieldName,
            type: 'text'
        }));
    }
}*/