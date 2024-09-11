public class AccountHelper {

    public static void updateOpportunityAccountPlanning(List<Account> updatedAccounts) {
        Set<Id> accountIds = new Set<Id>();
        
        // Collect Account Ids with non-empty Account Planning
        for (Account acc : updatedAccounts) {
            if (!String.isBlank(acc.Account_Planning__c)) {
                accountIds.add(acc.Id);
            }
        }
        
        if (!accountIds.isEmpty()) {
            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
            
            // Fetch Opportunities related to the updated Accounts
            for (Opportunity opp : [SELECT Id, AccountId, Account.Account_Planning__c, Account_Planning__c FROM Opportunity WHERE AccountId IN :accountIds]) {
                // Update Opportunity Account Planning if different from Account's Account Planning
                if (String.isBlank(opp.Account_Planning__c) || opp.Account_Planning__c != opp.Account.Account_Planning__c) {
                    opp.Account_Planning__c = opp.Account.Account_Planning__c;
                    opportunitiesToUpdate.add(opp);
                }
            }
            
            // Update Opportunities with modified Account Planning
            if (!opportunitiesToUpdate.isEmpty()) {
                update opportunitiesToUpdate;
            }
        }
    }
}