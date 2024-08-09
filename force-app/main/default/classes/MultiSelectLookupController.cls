public with sharing class MultiSelectLookupController {
    @AuraEnabled(cacheable=true)
    public static List<SObjectQueryResult> retrieveRecords(String objectName, 
                                                           String fieldAPINames,
                                                           String filterFieldAPIName,
                                                           String strInput,
                                                           List<String> caseStatusValues) {
        
        List<SObjectQueryResult> lstReturnResult = new List<SObjectQueryResult>();
        if(strInput.equals('*')) {
            strInput = '';
        }
        String str = strInput + '%';
        String strQueryField = '';
        List<String> fieldList = fieldAPINames.split(',');

        if(!fieldList.contains('Id')) {
            fieldList.add('Id');
            strQueryField = String.join(fieldList, ',');
        } else {
            strQueryField = fieldAPINames;
        }

        String strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                        + ' FROM ' 
                        + String.escapeSingleQuotes(objectName) 
                        + ' WHERE ' + filterFieldAPIName + ' LIKE \'' + str + '%\'';

        if (caseStatusValues != null && !caseStatusValues.isEmpty()) {
            strQuery += ' AND Status IN :caseStatusValues';
        }

        strQuery += ' ORDER BY ' + filterFieldAPIName + ' LIMIT 50';
                        
        System.debug('strQuery=' + strQuery);

        List<SObject> lstResult = database.query(strQuery);
        for(String strField : fieldList) {
            for(SObject sobj : lstResult) {                
                if(strField != 'Id') {
                    SObjectQueryResult result = new SObjectQueryResult();
                    result.recordId = (String) sobj.get('Id');
                    result.recordName = (String) sobj.get(strField);
                    lstReturnResult.add(result);
                }                
            }
        }
        return lstReturnResult;
    }
    
    public class SObjectQueryResult {
        @AuraEnabled
        public String recordId;

        @AuraEnabled
        public String recordName;
    }
}