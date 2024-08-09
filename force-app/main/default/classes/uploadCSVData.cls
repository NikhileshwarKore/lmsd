public with sharing class uploadCSVData {

    @AuraEnabled(cacheable=true)
    public static List<MetaDataOption> getMetaDataObjects() {
        List<MetaDataOption> metaDataOptions = new List<MetaDataOption>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        for (String customMetaDataName : globalDescribe.keySet()) {
            if (customMetaDataName.endsWithIgnoreCase('__mdt')) {
                metaDataOptions.add(new MetaDataOption(customMetaDataName, globalDescribe.get(customMetaDataName).getDescribe().getLabel()));
            }
        }
        return metaDataOptions;
    }

    public class MetaDataOption {
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public String label { get; set; }
        public MetaDataOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    @AuraEnabled
    public static List<Map<String, Object>> uploadCSVDataFile(String csvData, String metadataType) {
        try {
            List<SObject> sobjectList = readCSVFile(csvData, metadataType);
            List<Map<String, Object>> records = new List<Map<String, Object>>();
            // Check if the sobjectList is not null before processing it
            if (sobjectList != null) {
                System.debug('Records in CSV: ' + sobjectList.size());
                // Convert SObjects to a format suitable for serialization
                for (SObject record : sobjectList) {
                    Map<String, Object> recordMap = new Map<String, Object>();
                    for (SObjectField field : record.getSObjectType().getDescribe().fields.getMap().values()) {
                        recordMap.put(String.valueOf(field), record.get(field));
                    }
                    records.add(recordMap);
                }
                return records;
            } else {
                System.debug('Error: No records found in the CSV.');
                return new List<Map<String, Object>>();
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return new List<Map<String, Object>>();
        }
    }
    public static List<SObject> readCSVFile(String csvData, String metadataType) {
        List<SObject> sobjectList = new List<SObject>();
        // Get describe information for the custom metadata type
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType metadataObjectType = globalDescribe.get(metadataType);
        System.debug('metadataObjectType1111---->>' +metadataObjectType);
        if (metadataObjectType != null) {
            String[] csvLines = csvData.split('\n');
            String[] csvFieldNames = csvLines[0].split(',');
            Map<String, Integer> csvHeaderMap = new Map<String, Integer>();
            for (Integer i = 0; i < csvFieldNames.size(); i++) {
                String fieldName = csvFieldNames[i].trim().toLowerCase();
                csvHeaderMap.put(fieldName, i);
            }
            // Process the CSV lines
            for (Integer i = 1; i < csvLines.size(); i++) {
                SObject newRecord = metadataObjectType.newSObject();
                String[] csvRecordData = csvLines[i].split(',');
                // Ensure the CSV record has the correct number of fields
                if (csvRecordData.size() == csvFieldNames.size()) {
                    for (String fieldName : csvHeaderMap.keySet()) {
                        Integer fieldNumber = csvHeaderMap.get(fieldName);
                System.debug('Processing field: ' + fieldName + ' with field number: ' + fieldNumber);
                        String fieldValue = csvRecordData[fieldNumber].replaceAll('\"', ''); // Remove extra quotes
                        newRecord.put(fieldName, fieldValue);
                    }
                    sobjectList.add(newRecord);
                } else {
                    System.debug('CSV record at line ' + (i + 1) + ' does not match the number of fields.');
                }
            }
        } else {
            // Log or handle the case where the metadataObjectType is null
            System.debug('Error: metadataObjectType is null for ' + metadataType);
        }
        return sobjectList;
    }

    @AuraEnabled
    public static Integer saveRecords(String metadataType, List<Map<String, Object>> records) {
        Integer batchSize = 200; // Define an appropriate batch size
        Metadata.DeployContainer container = new Metadata.DeployContainer();
        Integer totalSavedRecords = 0;

        try {
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            Schema.SObjectType metadataObjectType = globalDescribe.get(metadataType);
    
            String objectName = metadataObjectType.getDescribe().getName();
    
            for (Integer i = 0; i < records.size(); i += batchSize) {
                List<Map<String, Object>> batch = new List<Map<String, Object>>();
                for (Integer j = i; j < Math.min(i + batchSize, records.size()); j++) {
                    batch.add(records[j]);
                }
    
                for (Map<String, Object> recordMap : batch) {
                    Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
                    customMetadata.fullName = objectName.removeEndIgnoreCase('__mdt') + '.' + recordMap.get('DeveloperName').toString();
                    System.debug(' customMetadata.fullName>>>>>' + customMetadata.fullName);
                    customMetadata.label = recordMap.get('MasterLabel').toString();
                    System.debug(' customMetadata.label>>>>>' + customMetadata.label);
    
                    for (String fieldName : recordMap.keySet()) {
                        if (!fieldName.equals('DeveloperName') && !fieldName.equals('MasterLabel') && recordMap.get(fieldName) != null) {
                            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                            customField.field = fieldName;
    
                            Schema.DisplayType valueType = metadataObjectType.getDescribe().fields.getMap().get(fieldName).getDescribe().getType();

                            if (valueType == Schema.DisplayType.Boolean) {
                                String booleanValue = (String)recordMap.get(fieldName);
                                customField.value = Boolean.valueOf(booleanValue.trim());
                            } else if (valueType == Schema.DisplayType.Date) {
                                String dateString = (String)recordMap.get(fieldName);
                                customField.value = Date.valueOf(dateString.trim());
                            } else if (valueType == Schema.DisplayType.DateTime) {
                                String dateTimeString = (String)recordMap.get(fieldName);
                                customField.value = Datetime.valueOf(dateTimeString.trim());
                            } else if (valueType == Schema.DisplayType.Reference) {
                                customField.value = String.valueOf(recordMap.get(fieldName));
                            } else if (valueType == Schema.DisplayType.Integer) {
                                customField.value = recordMap.get(fieldName);
                            } else {
                                customField.value = String.valueOf(recordMap.get(fieldName));
                            }

    
                            customMetadata.values.add(customField);
                        }
                    }
    
                    // Add metadata to the container outside of the loop
                    container.addMetadata(customMetadata);
                }

                totalSavedRecords += batch.size();
            }
    
            // Deploy the metadata
            Id asyncResultId = Metadata.Operations.enqueueDeployment(container, new PostInstallCallback());
    
            // Provide a success message if needed
            System.debug('Metadata deployment initiated successfully.');
    
        } catch (Exception e) {
            // Handle errors and log messages
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('Error saving records: ' + e.getMessage());
        }
        return totalSavedRecords;
    }

    @AuraEnabled
    public static List<Map<String, Object>> exportMetaData(String selectedMetadata) {
        List<Map<String, Object>> recordsList = new List<Map<String, Object>>();
 
        if (String.isNotBlank(selectedMetadata)) {
            // Dynamically query the fields based on the selected custom metadata type
            String query = 'SELECT ';
            Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(selectedMetadata).getDescribe().fields.getMap();
           
            for (String fieldName : fieldsMap.keySet()) {
                query += fieldName + ', ';
            }
            query = query.removeEnd(', ') + ' FROM ' + selectedMetadata;
           
            // Execute the query and fetch records
            List<SObject> records = Database.query(query);
 
            // Convert records to Map for serialization
            for (SObject record : records) {
                Map<String, Object> recordMap = new Map<String, Object>();
                for (String fieldName : fieldsMap.keySet()) {
                    recordMap.put(fieldName, record.get(fieldName));
                }
                recordsList.add(recordMap);
            }
        }
 
        return recordsList;
    }


}