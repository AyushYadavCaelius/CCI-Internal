public without sharing class ContactTriggerHelper {

    public static final List<String> TRIGGER_FIELDS = new List<String>{
        'Caelius_Alignment__c',
        'Salesforce_Market__c',
        'Salesforce_Segment__c',
        'Cadence_Meetings__c',
        'Salesforce_Technology__c',
        'Salesforce_Industry__c'
    };
    public void updateChildRecords(List<Contact> newContacts, Map<Id, Contact> oldMap){
        List<Contact> consToUpdate = new List<Contact>();
        Set<Id> parentConIds = new Set<Id>();
    	Map<Id, Contact> parentConsMap = new Map<Id, Contact>();
    	Set<Id> processedIds = new Set<Id>();
    	for(Contact con : newContacts){
            Boolean isChanged = false;
        	
            for(String fieldName : TRIGGER_FIELDS){
                if ((con.get(fieldName) != NULL) && (oldMap.get(con.Id).get(fieldName) != con.get(fieldName))) {
                    isChanged = true;
                    break;
                }
            }
        	if(isChanged){
            	parentConsMap.put(con.Id, con);
                parentConIds.add(con.Id);
        	}            
    	}
    	if(!(parentConsMap.keySet().isEmpty())){
            //Set<Id> parentConIds = new Set<Id>();
            //parentConIds.addAll(parentConsMap.keySet());

        	getChildRecordsRecursively(parentConIds, processedIds, consToUpdate, parentConsMap);
    	}
    
    	if(!consToUpdate.isEmpty()){
            try{
                update consToUpdate;
            } catch(Exception e){
                String errorMessage = 'Error in ContactStatusUpdateBatch: ' + e.getMessage() + '\n' + e.getStackTraceString();
            	SendErrorEmail.sendEmail(errorMessage);
            }
    	}
    }
    public void getChildRecordsRecursively(Set<Id> parentconIds, Set<Id> processedIds, List<Contact> consToUpdate, Map<Id, Contact> parentConsMap){
        Boolean isProcessed = false;
        Set<Id> newParentIds = new Set<Id>();
        Map<Id, Contact> newParentMap = new Map<Id, Contact>();
        //using map of fields and their values instead of object 
        //Map<Id, Map<String, String

        List<Contact> conList = [SELECT Id,Name, Caelius_Alignment__c,Salesforce_Market__c,Salesforce_Segment__c,Cadence_Meetings__c, Salesforce_Technology__c, Salesforce_Industry__c, ReportsToId FROM Contact WHERE ReportsToId IN: parentconIds];
        if(conList.isEmpty()){
            return;
        }
        for(Contact con : conList){
            //test changes start
            Contact con2 = new Contact();
            con2.Id = con.Id;

            if(processedIds.contains(con.Id)){
            
                //return;
                isProcessed = true;
            }
            if(!isProcessed){
              
                Boolean isAnyFieldUpdated = false;
                for (String fieldName : TRIGGER_FIELDS) {
                    if (con.get(fieldName) == NULL) {
                        
                        System.debug('Inside child con: ' + con.Id);
                        processedIds.add(con.Id);
                        if (con.ReportsToId != NULL && parentConsMap.get(con.ReportsToId) != NULL) {
                            con.put(fieldName, parentConsMap.get(con.ReportsToId).get(fieldName));
                            //101 starts
                            con2.put(fieldName, parentConsMap.get(con.ReportsToId).get(fieldName));
                            //101 ends
                            isAnyFieldUpdated = true;
                            //test changes start 101
                            //newParentMap.put(con.Id, con);
                            //test changes end
                        }
                    } else {
                       
                        //101 con.put(fieldName, parentConsMap.get(con.ReportsToId).get(fieldName));
                        //test changes start 101
                        
                        con2.put(fieldName, parentConsMap.get(con.ReportsToId).get(fieldName));
                     
                        isAnyFieldUpdated = true;
                        //101 newParentMap.put(con.Id, con2);
                        //test changes end
                    }
                }
                if (isAnyFieldUpdated) {
                    consToUpdate.add(con);
                    newParentIds.add(con.Id);
                    newParentMap.put(con.Id, con2);
                }

            }
        }
        if (isProcessed) {
            return;
        }
        getChildRecordsRecursively(newParentIds, processedIds, consToUpdate, newParentMap);
    }
}