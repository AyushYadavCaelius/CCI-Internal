public class SendErrorEmail {
    public static void sendEmail(String errorMessage){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
		String[] toAddresses = new String[] {'Bharat.arora@caeliusconsulting.com'};
        email.setToAddresses(toAddresses);
        email.setSubject('Apex Error Notification');
        email.setPlainTextBody(errorMessage);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}