@isTest
private class PostInstallCallbackTest {
@IsTest
    static void succeedCallback() {
       
        Metadata.DeployCallback callback = new PostInstallCallback();     
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.status = Metadata.DeployStatus.Succeeded;
        Metadata.DeployMessage messageObj = new Metadata.DeployMessage();
        messageObj.changed = true;
        messageObj.success = true;
        messageObj.fullName='';
        messageObj.componentType ='CustomMetadata';
        messageObj.fullName = 'Sample_Configuration.Test1';
        Metadata.DeployDetails deployDetailsObj = new Metadata.DeployDetails();
        deployDetailsObj.componentSuccesses.add(messageObj);
        result.details = deployDetailsObj;     
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
         callback.handleResult(result, context);
    }
    @IsTest
    static void errorCallback() {
       
        Metadata.DeployCallback callback = new PostInstallCallback();     
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.status = Metadata.DeployStatus.Failed;
        Metadata.DeployMessage messageObj = new Metadata.DeployMessage();
        messageObj.changed = false;
        messageObj.success = false;   
        messageObj.componentType ='CustomMetadata';
        messageObj.fullName = 'Sample_Configuration.Test1';
        messageObj.problem = 'Default: value not of required type: 1';
        messageObj.problemType = Metadata.DeployProblemType.Error;
        Metadata.DeployDetails deployDetailsObj = new Metadata.DeployDetails();
        deployDetailsObj.componentFailures.add(messageObj);
        result.details = deployDetailsObj;     
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();       
        callback.handleResult(result, context);
    }
}