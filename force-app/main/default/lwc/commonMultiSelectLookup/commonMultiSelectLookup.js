import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import retrieveRecords from '@salesforce/apex/LookupController.searchRecords';
import getExistingRecords from '@salesforce/apex/LookupController.getRecordsByIds';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class commonMultiSelectLookup extends NavigationMixin(LightningElement) {
  @api labelName;
  @api objectApiName;
  @api lookupCondition = '';
  @api titleFieldName = 'Name';
  @api subTitleFieldName = '';
  @api subTitle2FieldName = '';
  @api iconName;
  @api placeHolder = 'Search.....';
  @api selectedRecordIds=[];
  @api addedRecordIds=[];
  @api removedRecordIds=[];
  setRemovedElements = new Set();
  setAddedElements = new Set();
  loading = false;
  showFooter=false;
  @track items = []; //holds all records retrieving from database
  @track selectedItems = []; //holds only selected checkbox items that is being displayed based on search
  @track selectedItemsTempValues = []; //holds only selected checkbox items that is being displayed based on search
  //since values on checkbox deselection is difficult to track, so workaround to store previous values.
  //clicking on Done button, first previousSelectedItems items to be deleted and then selectedItems to be added into globalSelectedItems
  @track previousSelectedItems = [];
  @track value = []; //this holds checkbox values (Ids) which will be shown as selected
  @track globalSelectedItems = []; 
  
  searchInput = ''; //captures the text to be searched from user input
  showPicklist = false; //based on this flag dialog box will be displayed with checkbox items
  hasNoRecord = false; //to show 'No records found' message
  showFieldSet = false;

  
  
  connectedCallback()
  {
    var searchRequest={
      objectName: this.objectApiName,
      titleFieldName:this.titleFieldName,
      subTitleFieldName:this.subTitleFieldName,
      subTitle2FieldName:this.subTitle2FieldName,
      queryCondition: this.lookupCondition,
      selectedRecIds: this.selectedRecordIds
    };
    getExistingRecords({request:searchRequest})
    .then((data) => {
      if (data) {
        this.items = []; //initialize the array before assigning values coming from apex
        console.log('data---'+ JSON.stringify(this.data));
        if (data.length > 0) {
          this.setOptions(data);
          //now add newly selected items to the globalSelectedItems
          this.globalSelectedItems.push(...this.items);
          this.selectedItems = this.globalSelectedItems;
          //store current selection as previousSelectionItems
          this.previousSelectedItems = this.selectedItems;
        }
      }}).catch((error)=>
      {
        console.log('Error in loading existing record');
      });
  }

  // Create Options with main title, sub title and sub title 2
  setOptions(result)
  {
    try{
    result.map((resElement) => {
      // if Second field is required
       var title = resElement.recordName;
       var subTitleValue='';
       if (this.subTitleFieldName) {
         if (this.subTitleFieldName.indexOf('.') > 0) {
           var subTs = this.subTitleFieldName.split('.');
           if(resElement.record[subTs[0]])
           {
            subTitleValue=resElement.record[subTs[0]][subTs[1]];
            if(subTitleValue!==undefined)
            {
              if (this.subTitle2FieldName) {
                title = title + ' (' + subTitleValue+ '';
              }
              else{
                title = title + ' (' + subTitleValue+ ')';
              }
            }
          }
         }
         else {
           subTitleValue=resElement.record[this.subTitleFieldName];
           if(subTitleValue!==undefined)
           {
              if (this.subTitle2FieldName) {
                title = title + ' (' + subTitleValue+ '';
              }
              else{
              title = title + ' (' + subTitleValue+ ')';
              }
           }
         }
       }
       if (subTitleValue && this.subTitle2FieldName) {
        if (this.subTitle2FieldName.indexOf('.') > 0) {
          var subTs = this.subTitle2FieldName.split('.');
          if(resElement.record[subTs[0]])
           {
            var subTitleValue=resElement.record[subTs[0]][subTs[1]];
            if(subTitleValue!==undefined)
            {
              title = title + '-' + subTitleValue+ ')';
            }
            else{
              title = title+')';
            }
          }
        }
        else {
          var subTitleValue=resElement.record[this.subTitle2FieldName];
          if(subTitleValue!==undefined)
          {
            title = title + ' -' + subTitleValue+ ')';
          }
          else{
            title = title+')';
          }
        }
      }
        //prepare items array using spread operator which will be used as checkbox options
       this.items = [
         ...this.items,
         { value: resElement.recordId, label: title }
       ];
     });
    }
    catch(err)
    {
      console.error(JSON.stringify(err.message));
    }
  }

  searchText(event) {
    this.loading = true;
    this.showFooter=true;
    this.showPicklist = true;
    this.searchInput = event.target.value;
    if (this.searchInput.trim().length > 2) {
      
      //List of selected Ids
      var selItems=[];
      if(this.globalSelectedItems)
      {
       for (var i = 0; i < this.globalSelectedItems.length; i++) {
          selItems.push(this.globalSelectedItems[i].value);
        }
      }
      var searchRequest={
        searchKey: this.searchInput,
        objectName: this.objectApiName,
        titleFieldName:this.titleFieldName,
        subTitleFieldName:this.subTitleFieldName,
        subTitle2FieldName:this.subTitle2FieldName,
        queryCondition: this.lookupCondition,
        selectedRecIds: selItems
      };

      //retrieve records based on search input
      retrieveRecords({request: searchRequest})
        .then((result) => {
          this.loading = false;
          this.items = []; //initialize the array before assigning values coming from apex
          this.value = [];
          
          console.log('retrieveRecords-' + JSON.stringify(result));
          if (result.length > 0) {
            this.setOptions(result);
            this.showPicklist = true; //display dialog
            this.hasNoRecord = false;
            this.showFieldSet = true;
          } else {
            //display No records found message
            this.showPicklist = false;
            this.showFieldSet = false;
            this.hasNoRecord = true;
            this.loading = false;
          }
        })
        .catch((error) => {
          this.error = error;
          this.items = undefined;
          this.showPicklist = false;
          this.loading = false;
        });
    } else {
      this.showPicklist = true; //display dialog
      this.hasNoRecord = false;
      this.showFieldSet = false;
      this.loading = false;
    }
  }

  //This method is called during checkbox value change
  handleCheckboxChange(event) {
    let selectItemTemp = event.detail.value;

    //all the chosen checkbox items will come as follows: selectItemTemp=0032v00002x7UE9AAM,0032v00002x7UEHAA2
    this.selectedItems = []; //it will hold only newly selected checkbox items.

    this.selectedItemsTempValues = [];

    selectItemTemp.map((p) => {
      let arr = this.items.find((element) => element.value == p);
      if (arr != undefined) {
        this.value.push(arr.value);
        this.selectedItemsTempValues.push(arr);
      }
    });
    this.handleAddElementInSelectedList();
    if(this.items && this.items.length==0)
    {
      this.handleCancelClick(null);
    }
  }

  //This method is called during checkbox value change
  handleAddElementInSelectedList(event) {
    this.selectedItems = []; //it will hold only newly selected checkbox items.
    //Add to global selected records
    this.globalSelectedItems.push(...this.selectedItemsTempValues);
  
    var selItem = this.selectedItems;
    var globalSelItems = this.globalSelectedItems;
    
    //Raise Event for caller component
    this.raiseEvent();

    if (selItem.length > 0) {
      for (var i = 0; i < selItem.length; i++) {
        this.setAddedElements.add(selItem[i].value);
      }

      if (this.setRemovedElements.size > 0) {
        for (var j = 0; j < this.setRemovedElements; j++) {
          if (this.setRemovedElements[j] == selItem[i].value) {
            this.setRemovedElements[j].delete(selItem[i].value);
          }
        }
      }

      console.log('setRemovedElements=', this.setRemovedElements);
      console.log('setAddedElements=', this.setAddedElements);

      selItem.map((resElement) => {
        this.selectedItems = [
          ...this.selectedItems,
          { value: resElement.value, label: resElement.label }
        ];

        var abc = false;
        for (var i = 0; i < globalSelItems.length; i++) {
          if (resElement.value == globalSelItems[i].value) {
            abc = true;
            break;
          }
        }

        if (!abc) {
          this.globalSelectedItems = [
            ...this.globalSelectedItems,
            { value: resElement.value, label: resElement.label }
          ];
        }
      });
    }

    //Block to remove selected items from List
    var globalSelItemsAfterUpdate = this.globalSelectedItems;
    var allItems = this.items;
    var updateAllItems = [];

    if (allItems.length > 0) {
      allItems.map((resElement) => {
        //prepare items array using spread operator which will be used as checkbox options
        var abc = false;
        for (var i = 0; i < globalSelItemsAfterUpdate.length; i++) {
          if (resElement.value == globalSelItemsAfterUpdate[i].value) {
            abc = true;
            break;
          }
        }

        // this.items = [...this.items,{value:resElement.recordId,
        //label:resElement.recordName}];
        if (!abc) {
          updateAllItems = [
            ...updateAllItems,
            { value: resElement.value, label: resElement.label }
          ];
        }
      });
    }

    console.log('===updateAllItems==' + updateAllItems);
    this.items = [];
    if (updateAllItems.length > 0) {
      updateAllItems.map((resElement) => {
        this.items = [
          ...this.items,
          { value: resElement.value, label: resElement.label }
        ];
      });
    }
    //Block to remove selected items from List
  }

  //this method removes the pill item
  handleRemoveRecord(event) {
    this.showFooter=false;
    this.showPicklist=false;
    const removeItem = event.target.dataset.item;
    console.log('===removeItem===' + removeItem);
    this.removedElements += removeItem;
    this.removedElements += ',';

    console.log(
      '===this.setAddedElements.length===' + this.setAddedElements.size
    );
    //const abc = this.setAddedElements;
    var set1 = new Set();
    for (const item of this.setAddedElements) {
      console.log('=-=-item=-=', item);
      if (item != removeItem) {
        set1.add(item);
      }
    }
    console.log('===set1=' + set1);
    this.setAddedElements = new Set();
    for (const item of set1) {
      console.log('=-=-item=-12334=', item);
      this.setAddedElements.add(item);
    }

    this.setRemovedElements.add(removeItem);

    //this will prepare globalSelectedItems array excluding the item to be removed.
    this.globalSelectedItems = this.globalSelectedItems.filter(
      (item) => item.value != removeItem
    );
    console.log('---globalSelectedItems---' + this.globalSelectedItems);
    this.globalSelectedItems.map((p) => {
      this.previousSelectedItems = this.previousSelectedItems.filter(
        (item) => item.value != p.value
      );
    });

    const arrItems = this.globalSelectedItems;

    this.selectedItems = arrItems;
    console.log('---this.selectedItems--' + this.selectedItems);
    // eval("$A.get('e.force:refreshView').fire();");
    //initialize values again
    this.initializeValues();
    this.value = [];
  }

  
  //Raise Event to caller with selected Ids
  raiseEvent()
  {
    var selItems=[];
    if(this.globalSelectedItems)
    {
     for (var i = 0; i < this.globalSelectedItems.length; i++) {
        selItems.push(this.globalSelectedItems[i].value);
      }
    }
    this.selectedRecords=selItems;
    this.selectedRecordIds=selItems;
    var selectedRecords=selItems;
    this.addedRecordIds=[...this.setAddedElements];
    this.removedRecordIds=[...this.setRemovedElements];
    //Start Raise Event
    const selectedEvent = new CustomEvent('selection', { detail: this.globalSelectedItems });
    // Dispatches the event
    this.dispatchEvent(selectedEvent);

    const attributeChangeEvent = new FlowAttributeChangeEvent(
      'selectedRecords',
      this.globalSelectedItems
    );
    console.log('selectedRecords:'+JSON.stringify(selectedRecords));
    this.dispatchEvent(attributeChangeEvent);
    //End Raise Event
  }

  //this method initializes values after performing operations
  initializeValues() {
    this.searchInput = '';
    this.showFieldSet = false;
  }

  navigateToRecordPage(event) {
    var recId = event.currentTarget.dataset.id;
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recId,
        objectApiName: this.objectApiName,
        actionName: 'view'
      }
    });
  }

  handleCancelClick(event) {
    this.showPicklist = false;
    this.showFooter=false;
    this.initializeValues();
  }
}