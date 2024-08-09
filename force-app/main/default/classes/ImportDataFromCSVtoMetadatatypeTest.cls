@isTest
private class ImportDataFromCSVtoMetadatatypeTest {
    public static String[] csvFileLines;
    public static Blob csvFileBody;
    testmethod static void loadTestData(){
        String metaDataobjectName = 'Test_data__mdt';      
         String str = 'masterlabel,developername,Number_Testing__c, Text_Testing__c,Check_Box_Testing__c,Date_Testing__c\n test1,test1,10,welcome,true,2023-12-22\n test2,test2,11,welcome,true,2023-12-23';       
		 csvFileBody = Blob.valueOf(str);
        ImportDataFromCSVtoMetadatatype imporDataObj = new ImportDataFromCSVtoMetadatatype();
        imporDataObj.csvFileBody = csvFileBody;
        imporDataObj.selectedObject =metaDataobjectName;
        imporDataObj.readFromFile();
        imporDataObj.saveData();
        imporDataObj.ExportToExcel();
        imporDataObj.rerenderBlock();
    }
}