public class lookUpController {
 @AuraEnabled
 public static List < MPM4_BASE__Milestone1_Resource__c > fetchAccount(String searchKeyWord) {
  String searchKey = searchKeyWord + '%';
  List < MPM4_BASE__Milestone1_Resource__c > returnList = new List < MPM4_BASE__Milestone1_Resource__c > ();
  List < MPM4_BASE__Milestone1_Resource__c > lstOfAccount = [select id, Name from MPM4_BASE__Milestone1_Resource__c where Name LIKE: searchKey];
 
  for (MPM4_BASE__Milestone1_Resource__c acc: lstOfAccount) {
     returnList.add(acc);
     }
  return returnList;
 }
    
 
   
}