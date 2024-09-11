/*
* Controller class for lwcLogTimeOnTask and LogTimeOnTask components.
*/
public with sharing class FPSA_LogTimeOnTaskController {
    @AuraEnabled(cacheable=true)
    public static list<Log_Table__c> getLog(String taskId) {
        return [SELECT Id, Name, Time_Spent__c, Work_Description__c, Date__c ,Resource__c,ResourceName__c
                    FROM Log_Table__c 
                    WHERE Task__c = :taskId 
                    ORDER BY Date__c DESC];
    }

    @AuraEnabled()
    Public static Date insertLog(Integer a_Time_Spent, String a_Work_Description, Date a_Date, String a_taskId){
        System.debug('An a_taskId: '+a_taskId);    
        try{
            Id loggedinUserId= userInfo.getUserId(); 
            Id a_resourceId = [Select Id, Name, MPM4_BASE__User__c FROM MPM4_BASE__Milestone1_Resource__c where MPM4_BASE__User__c =: loggedinUserId].Id;
            return insLOG( a_Time_Spent, a_Work_Description,a_Date,a_taskId,a_resourceId);
        }
        catch(Exception ex){
            System.debug('An Exception: '+ex);
            return null;
        }
    }
 
 
    public static Date insLOG(Integer a_Time_Spent, String a_Work_Description, Date a_Date, String a_taskId, Id a_resourceId){
        try{
            Log_Table__c a_Rec = new Log_Table__c();
            a_Rec.Time_Spent__c = a_Time_Spent;
            a_Rec.Work_Description__c = a_Work_Description;
            a_Rec.Date__c = a_Date;
            a_Rec.Task__c = a_taskId;
            a_Rec.Resource__c = a_resourceId;

            Insert a_Rec;
            return a_Rec.Date__c;
        }
        catch(Exception ex){
            System.debug('An Exception: '+ex);
            return null;
        }
    }
 
    @AuraEnabled(cacheable=true)
    public static list<Log_Table__c> findLogs(string searchKey){
        System.debug('findLogs searchKey: '+searchKey);
        List<Log_Table__c> lst = new List<Log_Table__c>([SELECT Id, Name, Time_Spent__c, Work_Description__c, Date__c,Resource__r.name,ResourceName__c FROM Log_Table__c WHERE Task__c = :searchKey  ORDER BY Date__c DESC]);
        return lst;
    }    
}