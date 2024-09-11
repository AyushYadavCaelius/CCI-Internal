public class OpportunityTypeUpdateBatch implements Database.Batchable<sobject>, schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'Select Id,account.Closed_Won_Opportunities__c,account.Account_Age__c, StageName, type  from opportunity where IsClosed = false and ( (Account.Closed_Won_Opportunities__c  = 1 and type in (\'New Business\',\'\') ) OR (Account.Closed_Won_Opportunities__c >1 and type in (\'New Business\', \'Existing Business (2nd Engagement)\', \'\') ) OR (Account.Account_Age__c >=12 and type in (\'New Business\', \'Existing Business (2nd Engagement)\', \'\', \'Existing Business (2+ Engagements)\')) )';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<opportunity> scope){
        try{
        List<Opportunity> oppUpdateList = new List<opportunity>();
        for(opportunity oppRecord : scope){
            if(oppRecord.account.Account_Age__c != null && oppRecord.account.Account_Age__c >= 12){
                oppRecord.type = 'Existing Business (1+ Year Engagement)';
                oppUpdateList.add(oppRecord);
            }
            else if(oppRecord.account.Closed_Won_Opportunities__c == 1){
                oppRecord.type = 'Existing Business (2nd Engagement)';
                oppUpdateList.add(oppRecord);
            }
            else if(oppRecord.account.Closed_Won_Opportunities__c > 1){
                oppRecord.type = 'Existing Business (2+ Engagements)';
                oppUpdateList.add(oppRecord);
            }
            
        }
        update oppUpdateList;
        } catch(Exception e){
            String errorMessage = 'Error in ContactStatusUpdateBatch: ' + e.getMessage() + '\n' + e.getStackTraceString();
            SendErrorEmail.sendEmail(errorMessage);
        }
    }
    
    public void finish(Database.BatchableContext bc){
    }
    
     public void execute(SchedulableContext SC){
        database.executeBatch(new OpportunityTypeUpdateBatch());
    }
}