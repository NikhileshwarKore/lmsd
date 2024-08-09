public class CustomMetadataClient {
    
    static public Database.UpsertResult upsertMetadata(SObjectType objectType, Map<SObjectField,Object> record) {
        return upsertMetadata(objectType, new List<Map<SObjectField,Object>>{record})[0];
    }

    static public List<Database.UpsertResult> upsertMetadata(SObjectType type, List<Map<SObjectField,Object>> metadatas) {
        
        if (Test.isRunningTest()) Test.setMock(WebServiceMock.class, new UpsertMetadataMock());

        //turn maps of fields and values into web service DTOs
        List<CustomMetadata> customMetadatas = new List<CustomMetadata>();
        for (Map<SObjectField,Object> metadata : metadatas) customMetadatas.add(new CustomMetadata(type, metadata));

        //invoke metadata api
        MetadataClient client = new MetadataClient(UserInfo.getSessionId());
        List<UpsertResult> metadataResults = client.upsertMetadata(customMetadatas, true);

        //coerce to familiar database class
        List<Database.UpsertResult> databaseResults = new List<Database.UpsertResult>();
        for (UpsertResult metadataResult : metadataResults) databaseResults.add(metadataResult.toDatabaseUpsertResult());
        return databaseResults;

    }
    
    class UpsertMetadataMock implements WebServiceMock
    {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String,Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            upsertMetadataResponse_element element = new upsertMetadataResponse_element();
            element.result = new List<UpsertResult>();
            for (Metadata metadata : ((upsertMetadata_element)request).metadata) {
                UpsertResult result = new UpsertResult();
                result.success = true;
                element.result.add(result);
            }
            response.put('response_x', element);
        }
    }

    static public Database.DeleteResult deleteMetadata(SObjectType type, String developerName) {
        return deleteMetadata(type, new List<String>{developerName})[0];
    }

    static public List<Database.DeleteResult> deleteMetadata(SObjectType type, List<String> developerNames) {
        
        if (Test.isRunningTest()) Test.setMock(WebServiceMock.class, new DeleteMetadataMock());
        
        //turn names into qualified full names
        List<String> fullNames = new List<String>();
        for (String developerName : developerNames) fullNames.add(String.valueOf(type) + '.' + developerName);

        //invoke metadata api
        MetadataClient client = new MetadataClient(UserInfo.getSessionId());
        List<DeleteResult> metadataResults = client.deleteMetadata('Meta_Data_Testing__mdt', fullNames, true);

        //coerce to familiar database class
        List<Database.DeleteResult> databaseResults = new List<Database.DeleteResult>();
        for (DeleteResult metadataResult : metadataResults) databaseResults.add(metadataResult.toDatabaseDeleteResult());
        return databaseResults;

    }
    
    class DeleteMetadataMock implements WebServiceMock
    {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String,Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            deleteMetadataResponse_element element = new deleteMetadataResponse_element();
            element.result = new List<DeleteResult>();
            for (String fullName : ((deleteMetadata_element)request).fullNames) {
                DeleteResult result = new DeleteResult();
                result.success = true;
                result.fullName = fullName;
                element.result.add(result);
            }
            response.put('response_x', element);
        }
    }

    /**
     * This webservice class creates Custom Metadata
     * records synchronously using the Metadata API.
     */
    public class MetadataClient {

        String endpoint;
        Integer timeout_x; //special variable on the stub
        SessionHeader_element SessionHeader = new SessionHeader_element();
        AllOrNoneHeader_element AllOrNoneHeader = new AllOrNoneHeader_element();
        String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
        String AllOrNoneHeader_hns = 'AllOrNoneHeader=http://soap.sforce.com/2006/04/metadata';
        String[] ns_map_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata', 'CustomMetadataClient.MetadataClient'};

        /**
         * Example usage:
         *
         * String sessionId = UserInfo.getSessionId();
         * MetadataClient client = new MetadataClient(sessionId);
         */
        public MetadataClient(String sessionId) {
            //set timeout
            Integer timeout = 60 * 1000;
            this.timeout_x = timeout;

            //set session id
            String userId = UserInfo.getUserId();
            String orgId = UserInfo.getOrganizationId();
            this.SessionHeader.sessionId = sessionId;

            //set metadata endpoint
            this.endpoint = protocolAndHost + '/services/Soap/m/40.0';
        }

        /**
         * Example usage:
         *
         * CustomMetadata customMetadata = new CustomMetadata();
         * customMetadata.label = 'My Meta Record1';
         * customMetadata.fullName = 'MyMeta__mdt.Record1';
         * client.upsertMetadata(new List<CustomMetadata>{customMetadata}, true);
         */
        public List<UpsertResult> upsertMetadata(List<Metadata> metadatas, Boolean allOrNone) {
            if (metadatas.isEmpty()) return new List<UpsertResult>();
            this.AllOrNoneHeader.allOrNone = allOrNone;
            upsertMetadata_element request = new upsertMetadata_element();
            request.metadata = metadatas;
            upsertMetadataResponse_element response;
            Map<String,upsertMetadataResponse_element> response_map = new Map<String,upsertMetadataResponse_element>();
            response_map.put('response_x', response);
            WebServiceCallout.invoke(
              this,
              request,
              response_map,
              new String[]{endpoint,
              '',
              'http://soap.sforce.com/2006/04/metadata',
              'upsertMetadata',
              'http://soap.sforce.com/2006/04/metadata',
              'upsertMetadataResponse',
              'CustomMetadataClient.upsertMetadataResponse_element'}
            );
            response = response_map.get('response_x');
            return response.result;
        }

        /**
         * Example usage:
         *
         * String type = 'CustomMetadata';
         * String fullName = 'MyMeta__mdt.Record1';
         * client.deleteMetadata(type, new List<String>{fullName}, true);
         */
        public List<DeleteResult> deleteMetadata(String type, List<String> fullNames, Boolean allOrNone) {
            if (fullNames.isEmpty()) return new List<DeleteResult>();
            this.AllOrNoneHeader.allOrNone = allOrNone;
            deleteMetadata_element request = new deleteMetadata_element();
            request.type = type;
            request.fullNames = fullNames;
            deleteMetadataResponse_element response;
            Map<String,deleteMetadataResponse_element> response_map = new Map<String,deleteMetadataResponse_element>();
            response_map.put('response_x', response);
            WebServiceCallout.invoke(
              this,
              request,
              response_map,
              new String[]{endpoint,
              '',
              'http://soap.sforce.com/2006/04/metadata',
              'deleteMetadata',
              'http://soap.sforce.com/2006/04/metadata',
              'deleteMetadataResponse',
              'CustomMetadataClient.deleteMetadataResponse_element'}
            );
            response = response_map.get('response_x');
            return response.result;
        }
    }

    class CustomMetadataValue {

        String field;
        String value;

        /**
         * Example usage:
         *
         * CustomMetadataValue value = new CustomMetadataValue(
         *     Stage__mdt.Position__c,
         *     3
         *  );
         */
        CustomMetadataValue(SObjectField field, Object value) {
            this.field = String.valueOf(field);
            this.value = String.valueOf(value);
        }

        String[] field_type_info = new String[]{'field','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        String[] value_type_info = new String[]{'value','http://soap.sforce.com/2006/04/metadata',null,'1','1','true'};
        String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        String[] field_order_type_info = new String[]{'field','value'};
    }

    class SessionHeader_element {
        String sessionId;
        String[] sessionId_type_info = new String[]{'sessionId','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        String[] field_order_type_info = new String[]{'sessionId'};
    }

    class upsertMetadata_element {
        Metadata[] metadata;
        String[] metadata_type_info = new String[]{'metadata','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        String[] field_order_type_info = new String[]{'metadata'};
    }

    class upsertMetadataResponse_element {
        UpsertResult[] result;
        String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        String[] field_order_type_info = new String[]{'result'};
    }

    class deleteMetadata_element {
        String type;
        String[] fullNames;
        String[] type_type_info = new String[]{'type','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        String[] fullNames_type_info = new String[]{'fullNames','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        String[] field_order_type_info = new String[]{'type','fullNames'};
    }

    class deleteMetadataResponse_element {
        DeleteResult[] result;
        String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        String[] field_order_type_info = new String[]{'result'};
    }

    class AllOrNoneHeader_element {
        Boolean allOrNone;
        String[] allOrNone_type_info = new String[]{'allOrNone','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        String[] field_order_type_info = new String[]{'allOrNone'};
    }

    class Error {
        String message;
        String[] fields;
        String statusCode;
        transient String[] fields_type_info = new String[]{'fields','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        transient String[] message_type_info = new String[]{'message','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        transient String[] statusCode_type_info = new String[]{'statusCode','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        transient String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        transient String[] field_order_type_info = new String[]{'fields','message','statusCode'};
    }

    abstract class Metadata {
        //inheritance doesn't work
    }

    class CustomMetadata extends Metadata {

        String label;
        String fullName;
        String description;
        Boolean isProtected;
        CustomMetadataValue[] values;

        /**
         * Example usage:
         *
         * SObjectType type = SObjectType.MyMeta__mdt;
         * Map<SObjectField,Object> metadata = new Map<SObjectField,Object>();
         * metadata.put(MyMeta__mdt.DeveloperName, 'Record_1')
         * metadata.put(MyMeta__mdt.MasterLabel, 'Record One')
         * CustomMetadata customMetadata = new CustomMetadata(type, metadata);
         */
        CustomMetadata(SObjectType type, Map<SObjectField,Object> metadata) {

            this.values = new List<CustomMetadataValue>();
            for (SObjectField field : metadata.keySet()) {

                //populate special properties for developer name and master label
                if (String.valueOf(field) == 'MasterLabel') this.label = String.valueOf(metadata.get(field));
                if (String.valueOf(field) == 'DeveloperName') this.fullName = String.valueOf(type) + '.' + metadata.get(field);
                if (!String.valueOf(field).endsWith('__c')) continue; //ignore Id, Label, Language, NamespacePrefix, QualifiedApiName etc

                //coerce all other keys and values to value DTOs
                this.values.add(new CustomMetadataValue(field, metadata.get(field)));
            }

        }

        String type = 'CustomMetadata';
        String[] type_att_info = new String[]{'xsi:type'};

        String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        String[] description_type_info = new String[]{'description','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        String[] label_type_info = new String[]{'label','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        String[] isProtected_type_info = new String[]{'protected','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        String[] values_type_info = new String[]{'values','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        String[] field_order_type_info = new String[]{'fullName','description','label','isProtected','values'};
    }

    class DeleteResult {
        String id;
        Error[] errors;
        Boolean success;
        transient String fullName;
        transient String[] errors_type_info = new String[]{'errors','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        transient String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        transient String[] success_type_info = new String[]{'success','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        transient String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        transient String[] field_order_type_info = new String[]{'errors','fullName','success'};

        Database.DeleteResult toDatabaseDeleteResult() {
            this.id = this.fullName;
            return (Database.DeleteResult)Json.deserialize(Json.serialize(this), Database.DeleteResult.class);
        }
    }

    @TestVisible class UpsertResult {
        String id;
        Error[] errors;
        Boolean success;
        Boolean created;
        transient String fullName;
        transient String[] created_type_info = new String[]{'created','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        transient String[] errors_type_info = new String[]{'errors','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        transient String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        transient String[] success_type_info = new String[]{'success','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        transient String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        transient String[] field_order_type_info = new String[]{'created','errors','fullName','success'};

        Database.UpsertResult toDatabaseUpsertResult() {
            this.id = this.fullName;
            return (Database.UpsertResult)Json.deserialize(Json.serialize(this), Database.UpsertResult.class);
        }

    }
    
    /**
     * Determines the true API hostname for a Salesforce org using the Identity URL
     *
     * Why not just use Url.getSalesforceBaseUrl?
     * The return value can be any of the following:
     * - http://pod.salesforce.com (from a batch apex class)
     * - https://c.na1.visual.force.com (a local Visualforce Page)
     * - https://mysite.secure.force.com (from a Force.com Site)
     * - https://ns.pod.visual.force.com (some page in a managed package)
     */
    static public String protocolAndHost {
        public set; get {
            if (protocolAndHost == null) {
                //memoize
                String uid = UserInfo.getUserId();
                String sid = UserInfo.getSessionId();
                String oid = UserInfo.getOrganizationId();
                String base = Url.getOrgDomainURL().tostring();

                //use getSalesforceBaseUrl within batches and schedules (not Visualforce), and fix inconsistent protocol
                if (sid == null) return base.replaceFirst('http:', 'https:');

                //within test context use url class, else derive from identity response
                PageReference api = new PageReference('/id/' + oid + '/' + uid + '?access_token=' + sid);
                String content = Test.isRunningTest() ? '{"urls":{"profile":"' + base + '"}}' : api.getContent().toString();
                Url profile = new Url(content.substringBetween('"profile":"', '"'));
                protocolAndHost = profile.getProtocol() + '://' + profile.getHost();
            }
            return protocolAndHost;
        }
    }

}