public with sharing class LookupController {
    @AuraEnabled(cacheable=true)
    public static List<SObjectResult> getResults(String ObjectName, String fieldName, String value, List<String> selectedRecId) {
        List<SObjectResult> sObjectResultList = new List<SObjectResult>();

        if(selectedRecId == null) {
            selectedRecId = new List<String>();
        }

        if(String.isNotEmpty(value)) {
            String query = 'SELECT Id, ' + fieldName + ' FROM ' + ObjectName + ' WHERE ' + fieldName + ' LIKE \'%' + value.trim() + '%\' AND ID NOT IN :selectedRecId';
            for(SObject so : Database.query(query)) {
                String fieldValue = (String) so.get(fieldName);
                sObjectResultList.add(new SObjectResult(fieldValue, so.Id));
            }
        }
        return sObjectResultList;
    }

    public class SObjectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObjectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
        
        public SObjectResult() {}
    }
}