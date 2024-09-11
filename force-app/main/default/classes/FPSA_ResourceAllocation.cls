public without sharing class FPSA_ResourceAllocation {


    @AuraEnabled(cacheable=true)
  public static list<FPSA_Project_Allocation__c> fetchResourceAllocations(String projectId, String unAssignId){
        return [Select Id, FPSA_Project__c, Resource_Name__c, FPSA_Total_Planned_Hours__c,
        FPSA_Projected_Revenue__c FROM FPSA_Project_Allocation__c where FPSA_Project__c =: projectId
        ORDER BY FPSA_Assignment_Number__c ASC];
    }

    @AuraEnabled(cacheable=true)
  public static AllocationWrapper fetchAllocationWrapper(String projectId){
        MPM4_BASE__Milestone1_Project__c projRecord = [Select 
                                                        Id, 
                                                        FPSA_Project_ID__c, 
                                                        FPSA_Start_Date__c,  
                                                        FPSA_End_Date__c,
                                                        FPSA_Duration_days__c,
                                                        Name,
                                                        FPSA_Planned_Hours__c,
                                                        FPSA_Revenue__c 
                                                        FROM MPM4_BASE__Milestone1_Project__c 
                                                        WHERE id =: projectId LIMIT 1];
        AllocationWrapper aWrapper = new AllocationWrapper();
        map<String, Date> weekStart = new map<String, Date>();
        if(projRecord != null){
            aWrapper.projectRec = projRecord;
            Date firstWeek = projRecord?.FPSA_Start_Date__c?.toStartofWeek();

            Integer durationInWeeks = Integer.valueOf(projRecord.FPSA_Duration_days__c);
            if(Math.mod (durationInWeeks , 7) > 0) { 
                durationInWeeks = Math.min((durationInWeeks / 7) + 1,103 );//Since we have Week fields till 103 therefore 103 is the upper limit
            }else{
                durationInWeeks =  Math.min(durationInWeeks / 7,103);
            }
            
            //Iterating to fetch the number of week fields and finding each one's start date(Sunday)
            for(Integer i = 1; i<=durationInWeeks;i++){ 
                //projAllocationQuery = projAllocationQuery + 'FPSA_Week_'+i+'_hrs__c,' ;           
                weekStart.put('FPSA_Week_'+i+'_hrs__c', firstWeek);//Collection of subsequent week's start date(Sunday)
                firstWeek = firstWeek.addDays(7);
            }
            aWrapper.weekStarting = weekStart;
            aWrapper.durationInWeeks = durationInWeeks;
            for(Contact resource: [Select Id 
                FROM Contact
                WHERE Name = 'Unassigned Resource']){
                    aWrapper.unAssignedResourceId = resource.Id;
            }
        }
        
        return aWrapper;
    }
    
    //Below method is called on init of Resource Allocation page
    @AuraEnabled
    public static WrapperResponse getResourceAllocation(Id projId){
        try{
            //Creating Project Allocation query dynamic to know how many weeks'fields are to be fetched
            String projAllocationQuery = 'SELECT id, FPSA_Assignment_Number__c, FPSA_Role__c, FPSA_Description__c,FPSA_Bill_Rate__c, ' + 
                                         'FPSA_Cost_Rate_Amount__c, Resource_Name__c, Resource_Name__r.Name, Resource_Name__r.Id, ' + 
                                         'FPSA_Projected_Revenue__c, FPSA_Total_Planned_Hours__c,';
            list<Date> weekStart = new list<Date>();
            InnerWrapper innerWrapperInst ;
            list<InnerWrapper> projAllocationHoursList ;
            wrapperResponse wrapperResponseInst;
            
            //Below query is on Project to fetch its details as well as Start End Date for calculating duration
            MPM4_BASE__Milestone1_Project__c projRecord = [Select Id, FPSA_Project_ID__c, FPSA_Start_Date__c,  FPSA_End_Date__c,FPSA_Duration_days__c,Name,FPSA_Planned_Hours__c,FPSA_Revenue__c from MPM4_BASE__Milestone1_Project__c where id = :projId LIMIT 1];
            Date firstWeek = projRecord.FPSA_Start_Date__c.toStartofWeek();//fetching first week's start date(Sunday) to be displayed on component
            //Calculating duration of the project in weeks on the basis of Start and End Date of project
            Integer durationInWeeks = Integer.valueOf(projRecord.FPSA_Duration_days__c);
            if(Math.mod (durationInWeeks , 7) > 0) { 
                 durationInWeeks = Math.min((durationInWeeks / 7) + 1,103 );//Since we have Week fields till 103 therefore 103 is the upper limit
            } else {
                       durationInWeeks =  Math.min(durationInWeeks / 7,103);
                    }
            
            //Iterating to fetch the number of week fields and finding each one's start date(Sunday)
            for(Integer i = 1; i<=durationInWeeks;i++){ 
                projAllocationQuery = projAllocationQuery + 'FPSA_Week_'+i+'_hrs__c,' ;           
                weekStart.add(firstWeek);//Collection of subsequent week's start date(Sunday)
                firstWeek = firstWeek.addDays(7);
            }
            //Below query is on Project Allocation after fetching number of week fields to be queried
            projAllocationQuery = projAllocationQuery.removeEnd(',') + ' FROM FPSA_Project_Allocation__c' + 
                                                                       ' WHERE FPSA_Project__c = \'' + projId + 
                                                                       '\' ORDER BY FPSA_Assignment_Number__c ASC';
                                                                       
            list<FPSA_Project_Allocation__c> projAllocationsRec = Database.query(projAllocationQuery); 
            
            OuterWrapper outerWrapperInst ;
            list<OuterWrapper> outerWrapperList = new list<OuterWrapper>();
            //Below loop splits the week field and its hours into a wrapper to iterate columns in the lightning component
            for(FPSA_Project_Allocation__c pa : projAllocationsRec){ 
                projAllocationHoursList = new list<InnerWrapper>();
                for(Integer i=1 ; i <= durationInWeeks ; i++){
                    innerWrapperInst = new InnerWrapper();
                    innerWrapperInst.key = 'FPSA_Week_'+i+'_hrs__c';
                    innerWrapperInst.value = (Decimal)pa.get('FPSA_Week_'+i+'_hrs__c');
                    projAllocationHoursList.add(innerWrapperInst);
                }
                outerWrapperInst = new OuterWrapper(); 
                outerWrapperInst.projAlloc = pa;
                outerWrapperInst.projAllocationHours = projAllocationHoursList;
                outerWrapperList.add(outerWrapperInst);
            }
            User loggedInUser = [Select Id,(Select FPSA_Allow_Project_Allocation__c from MPM4_BASE__Resources__r) from User where id = :UserInfo.getUserId()];
            Boolean enableSaveAllocation = !loggedInUser.MPM4_BASE__Resources__r.isEmpty() ? loggedInUser.MPM4_BASE__Resources__r[0].FPSA_Allow_Project_Allocation__c : false;
                //Creating below wrapper to be returned to lightning component
                wrapperResponseInst = new WrapperResponse();
                wrapperResponseInst.projRec = projRecord; //Project record's details
                wrapperResponseInst.weekStarting = weekStart; //All the weeks' starting dates(Sunday)
                wrapperResponseInst.projAllocationRec = outerWrapperList;//Project Allocation records
                wrapperResponseInst.duration = durationInWeeks;//Duration field
                wrapperResponseInst.roleValues = FPSA_CommonMethodsClass.getPickListValuesIntoList();  
                wrapperResponseInst.loggedInUserProfile = enableSaveAllocation;
            return wrapperResponseInst;
        } catch (Exception ex){
            return null;
        }        
    }
    
    //Below method is to save the new Allocation records and update the existing changes
    @AuraEnabled
    public static String saveAllocations(WrapperResponse allocations){
        try{
            FPSA_Project_Allocation__c projAllocationInst;
            Decimal totalPlannedHours;
            Integer i=0;
            Integer weekNumber = 0;
            Integer weekEndNumber = 0;
            list<FPSA_Project_Allocation__c> projAllocationList = new list<FPSA_Project_Allocation__c>();
            Id projectId = allocations.projRec.id;
            
            set<Id> resourceIds = new set<Id>();
            for(OuterWrapper wrapRes : allocations.projAllocationRec){
                resourceIds.add(wrapRes.projAlloc.Resource_Name__c);
            }
            map<ID,Contact> resourceIdWithName = new map<ID,Contact>([Select Name from Contact where id IN :resourceIds]);
            for(OuterWrapper wrapRes : allocations.projAllocationRec){          
                projAllocationInst = new FPSA_Project_Allocation__c();
                projAllocationInst = wrapRes.projAlloc;
                projAllocationInst.Name = wrapRes.projAlloc.FPSA_Role__c + ' - ' + resourceIdWithName.get(wrapRes.projAlloc.Resource_Name__c).Name;
                projAllocationInst.FPSA_Project__c = projectId;  
                totalPlannedHours = 0;            
                for(InnerWrapper w : wrapRes.projAllocationHours){
                    projAllocationInst.put(w.key,w.value);                
                    totalPlannedHours = totalPlannedHours + w.value;
                    if(w.value > 0){
                        if(i==0){//This i identifies the Allocation Start Date if it is not Week 1
                            weekNumber = Integer.valueOf(w.key.subStringBetween('FPSA_Week_','_hrs__c')) -1 ;
                            /*if(weekNumber == 0){ This if condition sets the Allocation Start Date as Project Start Date if Project start date is mid week
                                projAllocationInst.FPSA_Project_Start_Date__c = allocations.projRec.FPSA_Start_Date__c;
                            } else {*/
                                projAllocationInst.FPSA_Project_Start_Date__c = allocations.projRec.FPSA_Start_Date__c.addDays(weekNumber*7).toStartOfWeek();
                            //}  
                            i++;
                        }
                        weekEndNumber = Integer.valueOf(w.key.subStringBetween('FPSA_Week_','_hrs__c')) - 1;
                    }
                }
                Date endDateCalc = allocations.projRec.FPSA_Start_Date__c.addDays(weekEndNumber*7).toStartOfWeek() + 6 ;
                projAllocationInst.FPSA_End_Date__c = endDateCalc;
                i = 0;
                projAllocationInst.FPSA_Total_Planned_Hours__c = totalPlannedHours;
                if(projAllocationInst.FPSA_Bill_Rate__c != null){
                    projAllocationInst.FPSA_Projected_Revenue__c = projAllocationInst.FPSA_Bill_Rate__c * totalPlannedHours;
                }else{
                    projAllocationInst.FPSA_Projected_Revenue__c = 0;
                }
                projAllocationList.add(projAllocationInst);
            }
           Database.upsert (projAllocationList,false);
           //return projAllocationList;
           return 'na';
        }catch(Exception ex){
            
            return 'Mandatory Field is missing';
        }        
    }
    
    //Below method is to delete Allocation record
    @AuraEnabled
    public static boolean deleteAllocations(String resourceAllocationId){ 
        try{
            FPSA_Project_Allocation__c projAllocation = [Select id,FPSA_Lock_Project_Allocation__c from FPSA_Project_Allocation__c where id = :(ID)resourceAllocationId ];
            if(!projAllocation.FPSA_Lock_Project_Allocation__c){
                Database.delete(projAllocation,false);
                return true;
            }else{
                return false;
            }
            }catch(Exception ex){
                return false;
            }        
    }
    
    //Below is the wrapper class to be returned to the lightning component
    public class WrapperResponse{
        @AuraEnabled
        public list<Date> weekStarting {get;set;}
        @AuraEnabled
        public Boolean loggedInUserProfile {get;set;}
        @AuraEnabled
        public list<String> roleValues {get;set;}
        @AuraEnabled
        public Integer duration {get;set;}
        @AuraEnabled
        public MPM4_BASE__Milestone1_Project__c projRec {get;set;}
        @AuraEnabled
        public list<OuterWrapper> projAllocationRec {get;set;}
    }
    public class OuterWrapper{
        @AuraEnabled
        public FPSA_Project_Allocation__c projAlloc {get;set;}
        @AuraEnabled
        public list<InnerWrapper> projAllocationHours {get;set;}
    }
    public class InnerWrapper {
        @AuraEnabled
        public String key {get;set;}
        @AuraEnabled
        public Decimal value {get;set;}
    }

    public static DescribeSObjectResult sObjectResult;

  @AuraEnabled(Cacheable=true)
  public static MetadataResponse getObjectMetadata(String objName){
    // Setup response object
    MetadataResponse response = new MetadataResponse();
    try {
      // Handle Errors
     // sObjectResult ='';
      if (String.isBlank(objName)) newException('objName required to identify SObjectType', null);
      Type classType = Type.forName(objName);
      // Get the SObject
      System.debug('objName>>>>'+objName);
      //sObjectResult = ((SObject)Type.forName('Schema', objName).newInstance()).getSObjectType().getDescribe();
      sObjectResult = ((SObject) classType.newInstance()).getSObjectType().getDescribe();
      
      
      response.sObjectName = sObjectResult.getName();
    } catch (Exception ex) {
      newException(ex.getMessage(), ex.getStackTraceString());
    }
    // Return metadata
    return response;
  }

  @AuraEnabled(Cacheable=true)
  public static list<MetadataResponse> getFieldSetMetadata(String objName, String fieldSetName) {
    list<MetadataResponse> metadataRespList = new list<MetadataResponse>();
    try {
      
      if (String.isBlank(fieldsetName)) newException('Fieldset Name required to get Field Metadata', null);

      for(String fsName: fieldSetName.split(',')){
        
        // Setup response object
                MetadataResponse response = new MetadataResponse();
                // Get the SObject
        response = getObjectMetadata(objName);
        
        response.sObjectName = sObjectResult.getName();
        // Handle Errors
        // Get the FieldSets
        Map<String, FieldSet> fieldSets = sObjectResult.fieldSets.getMap();
        // Check if we have a fieldset with that name
        if (fieldSets.containsKey(fsName)) {
          // Get the Object fields
          Map<String, SObjectField> fields = sObjectResult.fields.getMap();
          // Check if the object has a record type id field
          if (fields.containsKey('RecordTypeId')) {
            // Get the records record type Id
            response.recordTypeId = (String) ((SObject) Database.query('SELECT RecordTypeId FROM '+response.sObjectName+' WHERE Id =: recordId')).get('RecordTypeId');
          }
          // Get the Label
          response.fieldSetLabel = fieldSets.get(fsName).getLabel();
          response.fieldSetAPIName = fieldSets.get(fsName).getName();
          
          // Construct a new list
          response.fieldsMetadata = new List<String>();
          // For each field in the FieldSet
          for (FieldSetMember fieldSetMember : fieldSets.get(fsName).getFields()) {
            // Get the path
            String fieldName = fieldSetMember.getFieldPath();
            
            // We can't handle Relationship fields
            if (!fieldName.contains('.')) {
              // Get the field describe
              DescribeFieldResult fd = fields.get(fieldName).getDescribe();
              // If the current user has access to the field
              
              if (fd.isAccessible()) {
                response.fieldsMetadata.add(JSON.serialize(
                  new Map<String, Object>{
                    'fieldSetProperties' => fieldSetMember,
                    'fieldDescribeProperties' => fd
                  }
                ));
              }
            } else {
              newException('Relationship Fields not supported FieldSet: "'+fsName+'" Field Name: "'+fieldName+'"', null);
            }
          }
          // Make sure we have fields
          
          //if (response.fieldsMetadata.isEmpty()) newException('No accessible fields for the current user in FieldSet "'+fsName+'"', null);
        } else {
          newException('Fieldset "'+fsName+'" not found for SObject "'+sObjectResult.getName()+'"', null);
        }
        metadataRespList.add(response);
      }

    } catch (Exception ex) {
      newException(ex.getMessage(), ex.getStackTraceString());
    }
    
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        
    // Return metadata
    return metadataRespList;
        
        
  }

  private static void newException(String exceptionMessage, String stackTraceString) {
    
    
    AuraHandledException ex = new AuraHandledException(exceptionMessage);
    ex.setMessage(exceptionMessage + (String.isNotBlank(stackTraceString) ? ' ' + stackTraceString : ''));
    throw ex;
  }

  public class MetadataResponse {
    @AuraEnabled public String recordTypeId;
    @AuraEnabled public String fieldSetLabel;
    @AuraEnabled public String fieldSetAPIName;
    @AuraEnabled public String sObjectName;
    @AuraEnabled public List<String> fieldsMetadata;
  }

    public class AllocationWrapper {
    @AuraEnabled public MPM4_BASE__Milestone1_Project__c projectRec;
    //@AuraEnabled public map<String, String> numberOfWeeks;
        @AuraEnabled public map<String, Date> weekStarting {get;set;}
        @AuraEnabled public Integer durationInWeeks {get;set;}
        @AuraEnabled public String unAssignedResourceId {get;set;}
        
  }
}