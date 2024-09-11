public class ContactStatusUpdateBatch implements Database.Batchable<sobject>, Database.Stateful, Schedulable {
    
    public Map<Id,Integer> contactUpdateMap;
    public Map<Id,String> contactStatusMap;
    public ContactStatusUpdateBatch(){
        contactUpdateMap = new Map<Id,Integer>();
        contactStatusMap = new Map<Id,String>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id,Salesforce_Contact__r.name,Opportunity__r.StageName,Salesforce_Contact__r.Salesforce_Relationship_Level__c,Salesforce_Contact__c  from Opportunity_Salesforce_Contact__c where Opportunity__r.StageName != \'Closed Lost\' and Salesforce_Contact__r.Salesforce_Relationship_Level__c != \'Actively Referring\'   ' ;
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity_Salesforce_Contact__c> scope){
        try{
        for(Opportunity_Salesforce_Contact__c salesforceContact : scope ){
            Integer closedOppCount = contactUpdateMap.containsKey(salesforceContact.Salesforce_Contact__c) ? contactUpdateMap.get(salesforceContact.Salesforce_Contact__c) : 0;
            String contactCurrentStatus = contactStatusMap.containsKey(salesforceContact.Salesforce_Contact__c) ? contactStatusMap.get(salesforceContact.Salesforce_Contact__c) : salesforceContact.Salesforce_Contact__r.Salesforce_Relationship_Level__c;  
            if(salesforceContact.Opportunity__r.StageName == 'Closed Won'){
                  closedOppCount +=1;
            } 
            contactUpdateMap.put(salesforceContact.Salesforce_Contact__c,closedOppCount);
            contactStatusMap.put(salesforceContact.Salesforce_Contact__c,contactCurrentStatus);
        }
        } catch(Exception e){
            String errorMessage = 'Error in ContactStatusUpdateBatch: ' + e.getMessage() + '\n' + e.getStackTraceString();
            SendErrorEmail.sendEmail(errorMessage);
        }
      
    }
    
    public void finish(Database.BatchableContext bc){
        try{
        List<Contact> contactUpdateList = new List<Contact>();
        
        for(Id contactId : contactUpdateMap.keySet()){
            Integer closedOppCount = contactUpdateMap.get(contactId);
            String currentContactStatus = contactStatusMap.get(contactId);
            Contact newContact = new Contact();
            newContact.Id = contactId;
            
            if(closedOppCount == 0){
                if(currentContactStatus == '' || currentContactStatus == null ){
                    newContact.Salesforce_Relationship_Level__c = 'First Active Pursuit';
                    contactUpdateList.add(newContact);
                }
            }
            else if(closedOppCount == 1){
                if(currentContactStatus != 'Closed Business'){
                    newContact.Salesforce_Relationship_Level__c = 'Closed Business';
                    contactUpdateList.add(newContact);
                }
            }
            else if(closedOppCount > 1){
                
                newContact.Salesforce_Relationship_Level__c = 'Actively Referring';
                contactUpdateList.add(newContact);
                
            }
        }
        
        if(contactUpdateList.Size() > 0){
            update contactUpdateList;
        }
        } catch(Exception e){
            String errorMessage = 'Error in ContactStatusUpdateBatch: ' + e.getMessage() + '\n' + e.getStackTraceString();
            SendErrorEmail.sendEmail(errorMessage);
        }
            
    }
    
    public void execute(SchedulableContext SC){
        database.executeBatch(new ContactStatusUpdateBatch());
    }
}