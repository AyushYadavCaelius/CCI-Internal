public class OpportunityHelper {
    
    public static void populateAccountPlanning(List<Opportunity> opps) {
        Set<Id> accountIds = new Set<Id>();
        
        // Collect Account Ids
        for(Opportunity opp : opps) {
            if(opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
        
        // Fetch Account Planning values for the collected Account Ids
        if(!accountIds.isEmpty()) {
            Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, Account_Planning__c FROM Account WHERE Id IN :accountIds]);
            
            // Update Opportunity Account Planning if corresponding Account has a value
            for(Opportunity opp : opps) {
                if(String.isBlank(opp.Account_Planning__c)) {
                    Account acc = accountsMap.get(opp.AccountId);
                    if(acc != null && acc.Account_Planning__c != null) {
                        opp.Account_Planning__c = acc.Account_Planning__c;
                    }
                }
            }
        }
    }
    
    public static void updateAccountPlanning(List<Opportunity> newOpps , Map<Id,Opportunity> oldMap) {
        Map<Id, String> accountPlanningMap = new Map<Id, String>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
        
        for(Opportunity opp : newOpps){
            accountIds.add(opp.AccountId);
        }
        Map<Id,Account> accMap =new Map<Id,Account>([Select Id,Account_Planning__c,Initial_Opp_Won__c FROM Account WHERE Id IN :accountIds ]);
        
        
        // Collect Account Planning updates and corresponding Account Ids
       /* for(Opportunity opp : newOpps) {
            if(opp.AccountId != null && !String.isBlank(opp.Account_Planning__c)) {
                //accountIds.add(opp.AccountId);
                accountPlanningMap.put(opp.AccountId, opp.Account_Planning__c);
            }
        }*/
        
        Map<Id, Account> accountsMap = new Map<Id, Account>();
        Set<Id> accPlanningSet = new Set<Id>();
        for(Opportunity opp : newOpps) {
            if(opp.AccountId != null && !String.isBlank(opp.Account_Planning__c)) {
                accPlanningSet.add(opp.AccountId);
                accountPlanningMap.put(opp.AccountId, opp.Account_Planning__c);
                accountsMap.put(opp.AccountId,accMap.get(opp.AccountId));
            }
        }
        
        if(!accPlanningSet.isEmpty()) {

            //Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, Account_Planning__c FROM Account WHERE Id IN :accountIds]);
            
            // Update Accounts with new Account Planning values
            
            for(Id accountId : accPlanningSet) {
                Account acc = accountsMap.get(accountId);
                if(acc != null && accountPlanningMap.containsKey(accountId) && acc.Account_Planning__c == null ) {
                    acc.Account_Planning__c = accountPlanningMap.get(accountId);
                    accountsToUpdate.put(acc.Id,acc);
                }
            }
           
        }
        
        //Opp Closed won Update
        for(opportunity opp : newOpps){
            if(oldMap != null){
            if(opp.StageName == 'Closed Won' && 
               ((oldMap != null && oldMap.get(opp.Id).StageName != 'Closed Won' && accMap.get(opp.AccountId).Initial_Opp_Won__c == null) || oldMap == null && accMap.get(opp.AccountId).Initial_Opp_Won__c == null )
               ){
                Account acc = new Account();
                acc.Id = opp.AccountId;
                if(accountsToUpdate.containsKey(opp.AccountId)){
                    acc = accountsToUpdate.get(opp.AccountId);
                }
                acc.Initial_Opp_Won__c = system.today();
                accountsToUpdate.put(acc.id,acc);
            }
        }
        }
        
        // Perform DML operation
        if(!accountsToUpdate.isEmpty()) {
            update accountsToUpdate.values();
        }
    }
}