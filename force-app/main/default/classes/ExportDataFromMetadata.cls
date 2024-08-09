public class ExportDataFromMetadata {
    public transient List<String> fieldList{get;set;}
    public String objectName{get;set;}
    public String pageName{get;set;}
    public transient List<List<sObject>> sObjectList{get;set;}
    public transient List<sObject> sobjectsTempList{get;set;}
    public boolean displayExport {get;set;}
 	public Integer recordLimit { get; set; }
    public ExportDataFromMetadata() {
        sobjectsTempList = new List<sObject>();
        fieldList = new List<String> ();
        if(Test.isRunningTest())
        {
           objectName = 'vamritech__Sample_Configuration__mdt';
        }else{
        	objectName = ApexPages.currentPage().getParameters().get('objectName');
            pageName = 'ExportFieldsFromMetadataToCSV?objectName='+objectName;
        }
        sObjectList = new List<List<sobject>> ();
        for(String fieldName : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet()){
            fieldList.add(fieldName);
         
        }
       	List<sObject> sobjectTempList = new List<sObject>();
        recordLimit = Integer.valueOf(Label.Query_Limit);
		String query = ' select '+ String.join(fieldList,' , ')+' from '+objectName+ ' LIMIT ' + recordLimit;
        sobjectsTempList = Database.query(query);
    }
   
}