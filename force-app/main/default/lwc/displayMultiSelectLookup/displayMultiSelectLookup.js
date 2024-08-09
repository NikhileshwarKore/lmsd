import { LightningElement, track } from 'lwc';

export default class DisplayMultiSelectLookup extends LightningElement {
    @track selectedItemsToDisplay = ''; // To display items in comma-delimited way
    @track values = []; // Stores the labels in this array
    @track isItemExists = false; // Flag to check if message can be displayed


     handleSearch() {
        getGridList({ searchTerm: this.searchTerm })
            .then(result => {
                this.selectedItemsData = result;
            })
            .catch(error => {
                console.error('Error fetching data:', error);
                // Handle error
            });
    }

    handleClear() {
        this.searchTerm = '';
        this.selectedItemsData = null; // or empty array based on your requirement
    }

    
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    // Captures the retrieve event propagated from lookup component
    selectItemEventHandler(event) {
        const args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);
    }

    // Captures the remove event propagated from lookup component
    deleteItemEventHandler(event) {
        const args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);
    }

    // Displays the items in comma-delimited way
    displayItem(args) {
        this.values = []; // Initialize first
        args.forEach(element => {
            this.values.push(element.label);
        });

        this.isItemExists = args.length > 0;
        this.selectedItemsToDisplay = this.values.join(', ');
    }

    
}