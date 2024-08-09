public class PostInstallCallback implements Metadata.DeployCallback{
	public void handleResult(Metadata.DeployResult result,
        Metadata.DeployCallbackContext context) {
        
        if (result.status == Metadata.DeployStatus.Succeeded) {
            // Deployment was successful, take appropriate action.
           // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Meta Data inserted successfully'));
           Messaging.SingleEmailMessage  msgObj = new Messaging.SingleEmailMessage ();
            msgObj.setSubject(Label.Success_Callback);           
            List<String> emailAddresses = new List<String>{UserInfo.getUserEmail()}; 
            Metadata.DeployDetails deployDetailsList = result.details;
            List<Metadata.DeployMessage> deploymentMessagesList = deployDetailsList.componentSuccesses;    
            String errorMessageBody = '';
            for(Metadata.DeployMessage messageObj:deploymentMessagesList){
                if(messageObj.success==true && !String.valueOf(messageObj.fullName).split('\\.')[1].containsIgnoreCase('xml')){
                    errorMessageBody+=String.valueOf(messageObj.fullName).split('\\.')[1]+'\n';
                }
            }
            errorMessageBody += System.Label.Callback_Body;
            msgObj.setPlainTextBody(errorMessageBody);
            msgObj.setToAddresses(emailAddresses);
            Messaging.sendEmail(new List<Messaging.Email>{msgObj});          
        } else {
            // Deployment wasn’t successful, take appropriate action.
            Messaging.SingleEmailMessage  msgObj = new Messaging.SingleEmailMessage ();
            msgObj.setSubject(Label.Error_Callback);
            msgObj.setPlainTextBody(result.details+'='+result.errorMessage);
            List<String> emailAddresses = new List<String>{UserInfo.getUserEmail()};      
            Metadata.DeployDetails deployDetailsList = result.details;
            List<Metadata.DeployMessage> deploymentMessagesList = deployDetailsList.componentFailures;    
            String errorMessageBody = '';
            for(Metadata.DeployMessage messageObj:deploymentMessagesList){
                if(messageObj.success==false){
                    errorMessageBody+=messageObj.problem+'\n';
                }
            }
            msgObj.setPlainTextBody(errorMessageBody);
            msgObj.setToAddresses(emailAddresses);
            Messaging.sendEmail(new List<Messaging.Email>{msgObj});
        }
    }
}