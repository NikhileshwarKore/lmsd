public class ImportDataFromCSVtoMetadata {
    public String documentName {get;set;}
    public transient Blob csvFileBody {get;set;}
    public String[] contactDataLines {get;set;}    
    public List<sObject> sobjectList {get;set;}
    public boolean readSuccess {get;set;}
    public String OutPutString {get;set;}
    public List<String> lstFieldNames {get;set;} 
    public Map<String, Schema.SObjectField> sobjectFieldMap {get;set;} 
    String contactDataAsString;
    public String selectedObject {get;set;}
    public List<SelectOption> customMetaDataList {get;set;}
    //Add Schema data
    public Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

    public ImportDataFromCSVtoMetadata() {
        sobjectList = new List<SObject>();
        sobjectFieldMap = new Map<String, Schema.SObjectField>();
        customMetaDataList = new List<SelectOption>();
        customMetaDataList.add(new SelectOption('', '--None--'));
        for (String customMetaDataName : globalDescribe.keySet()) {
            if (customMetaDataName.endsWithIgnoreCase('_mdt')) {
                customMetaDataList.add(new SelectOption(customMetaDataName, globalDescribe.get(customMetaDataName).getDescribe().getLabel()));
            }
        }
        documentName = '';
        readSuccess = false;
        contactDataLines = new String[] {};
        lstFieldNames = new List<String>();
    }

    public void readFromFile(){
        try{
            contactDataAsString = csvFileBody.toString();
            readCSVFile();
        } catch(Exception e){
            readSuccess = false;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Missing_file_message);
            ApexPages.addMessage(errorMessage);
        }
    }    

    public void readCSVFile() {
        sobjectList.clear();
        sobjectFieldMap = globalDescribe.get(selectedObject).getDescribe().fields.getMap();

        Set<String> fieldSet = new Set<String>();
        for (String fieldName : sobjectFieldMap.keySet()) {
            fieldSet.add(fieldName.toLowerCase().trim());
        }
        contactDataLines = contactDataAsString.split('\n');
        String[] csvFieldNames = contactDataLines[0].split(',');

        Map<String, Integer> csvHeaderMap = new Map<String, Integer>();
        for (Integer i = 0; i < csvFieldNames.size(); i++) {
            String fieldName = csvFieldNames[i].trim().toLowerCase();
            csvHeaderMap.put(fieldName, i);
            lstFieldNames.add(csvFieldNames[i].trim());
            if (!fieldSet.contains(fieldName)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, fieldName + ' ' + System.Label.Invalid_field_name_message));
                return;
            }
        }
        // Process the CSV lines in batches
        Integer batchSize = 200;
        for (Integer i = 1; i < contactDataLines.size(); i += batchSize) {
            List<SObject> batch = new List<SObject>();

            for (Integer j = i; j < Math.min(i + batchSize, contactDataLines.size()); j++) {
                SObject sobj = globalDescribe.get(selectedObject).newSObject();
                String[] csvRecordData = contactDataLines[j].split(',');
                if (csvRecordData.size() != csvFieldNames.size()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CSV record at line ' + (j + 1) + ' does not match the number of fields.'));
                    return;
                }
                for (String fieldName : csvHeaderMap.keySet()) {
                    Integer fieldNumber = csvHeaderMap.get(fieldName);
                    String fieldValue = csvRecordData[fieldNumber].replaceAll('\"', ''); // Remove extra quotes
                    sobj.put(fieldName, fieldValue);
                }
                batch.add(sobj);
            }
            sobjectList.addAll(batch);
        }
        if (sobjectList.size() > 0) {
            readSuccess = true;
            OutPutString = System.Label.Number_of_Records + ' Of ' + sobjectList.size() + ' records.';
        }
    }

    public void saveData() {
        Integer batchSize = 200; // Define an appropriate batch size
        Metadata.DeployContainer container = new Metadata.DeployContainer();
        try {
            for (Integer i = 0; i < sobjectList.size(); i += batchSize) {
                List<sObject> batch = new List<sObject>();
                for (Integer j = i; j < Math.min(i + batchSize, sobjectList.size()); j++) {
                    batch.add(sobjectList[j]);
                }
                for (sObject sobjInstance : batch) {
                    String objectName = globalDescribe.get(selectedObject).getDescribe().getName();
                    Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
                    customMetadata.fullName = objectName.removeEndIgnoreCase('__mdt') + '.' + sobjInstance.get('developername').toString();
                    customMetadata.label = sobjInstance.get('masterLabel').toString();
                    for (String fieldName : lstFieldNames) {
                        fieldName= fieldName.trim();
                        if (fieldName != 'developername' && fieldName != 'masterLabel' && sobjInstance.get(fieldName) != null) {
                            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                            customField.field = fieldName;
                            System.debug('fieldName======='+fieldName);
                            
                            Schema.DisplayType valueType = sobjectFieldMap.get(fieldName).getDescribe().getType();
                            
                            if(valueType == Schema.DisplayType.Boolean){
                                //customField.value = Boolean.valueOf(sobjInstance.get(fieldName));
                                //System.debug('customField.value if else 1==='+sobjInstance.get(fieldName));
                                //customField.value = Boolean.valueOf('true');
                                System.debug('string value==='+sobjInstance.get(fieldName));
                                string bvalue= (String)sobjInstance.get(fieldName);
                               // customField.value = Boolean.valueOf(sobjInstance.get(fieldName));
                                customField.value = Boolean.valueOf(bvalue.trim());
                                System.debug('Boolean value==='+customField.value);
                            }
                            else if(valueType == Schema.DisplayType.Date){
                                customField.value = Date.valueOf(sobjInstance.get(fieldName));
                            }
                            else if(valueType == Schema.DisplayType.DateTime){
                                customField.value = DateTime.valueOf(sobjInstance.get(fieldName));
                            }
                            else if(valueType == Schema.DisplayType.Reference){
                                customField.value = string.valueOf(sobjInstance.get(fieldName));
                            }
                            else if(valueType == Schema.DisplayType.Integer){
                                customField.value = sobjInstance.get(fieldName);
                            }
                            else{
                                customField.value = String.valueOf(sobjInstance.get(fieldName));
                            }
                            customMetadata.values.add(customField);
                            System.debug('customMetadata 1==='+customMetadata);
                        }
                    }
                    // Added metadata to the container outside of the loop
                    container.addMetadata(customMetadata);
                }
            }
            // Moved the deployment operation outside of the loop
            Id asyncResultId = Metadata.Operations.enqueueDeployment(container, new PostInstallCallback());
            ApexPages.Message successMessage = new ApexPages.Message(ApexPages.severity.CONFIRM, globalDescribe.get(selectedObject).getDescribe().getLabel() + ' of ' + sobjectList.size() + ' ' + System.Label.Success_message);
            ApexPages.addMessage(successMessage);
        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Error_Message + e.getMessage() + '---' + e.getLineNumber());
            ApexPages.addMessage(errorMessage);
        }
    }
    
    public pagereference ExportToExcel(){
    PageReference pageRef = new PageReference('/apex/ExportFieldsFromMetaDataToCSVContainer');
    pageRef.setRedirect(true);
    pageRef.getParameters().put('objectName',selectedObject);
    return pageRef;
    }

    public pagereference rerenderBlock(){
        return null;
    }
}