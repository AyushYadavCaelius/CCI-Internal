@isTest
public class SendErrorEmailTest {
 
    @isTest
    static void sendEmailTest() {
    	String errorMessage = 'Test error email body';
        Test.startTest();
        SendErrorEmail.sendEmail(errorMessage);
        Test.stopTest();
        List<EmailMessage> results = [SELECT Id FROM EmailMessage];
        System.assert(results.size() > 0, 'Email was sent');
    }
}