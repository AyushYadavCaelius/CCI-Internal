import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { refreshApex } from "@salesforce/apex";
import getLog from '@salesforce/apex/FPSA_LogTimeOnTaskController.getLog';
import insertLog from '@salesforce/apex/FPSA_LogTimeOnTaskController.insertLog';
import findLogs from '@salesforce/apex/FPSA_LogTimeOnTaskController.findLogs';

import { updateRecord } from 'lightning/uiRecordApi';

//import RESOURCE_FIELD from '@salesforce/schema/MPM4_BASE__Milestone1_Resource__c.Name';
import RESOURCE_FIELD from '@salesforce/schema/MPM4_BASE__Milestone1_Task__c.Name';
const COLS = [
    { label: 'Date', fieldName: 'Date__c'},
    { label: 'Time Spent', fieldName: 'Time_Spent__c', editable: true },
    { label: 'Work Description', fieldName: 'Work_Description__c', editable: true },
    { label: 'Resource', fieldName: 'ResourceName__c'}
];



export default class LwcLogTimeOnTask extends LightningElement {


    
    @track firstRecord = true;
    @api a_Time_Spent_Ref;
    @api a_Work_Description_Ref;
    @api a_Date_Ref;
    @api a_Resource_Ref;
    ResourceName = RESOURCE_FIELD;

    handle_Time_Spent_Change(event) {
       // if(event.target.name==='Time_Spent'){
        this.a_Time_Spent_Ref = event.detail.value;
      //  }
    }
  
    handle_Work_Description_Change(event) {
      //  if(event.target.name==='Work_Description'){
        this.a_Work_Description_Ref = event.detail.value;
      //  }
    }
  
    handle_Date_Change(event) {
     //  if(event.target.name==='log_Date'){
        this.a_Date_Ref = event.detail.value;
      //  }
    }

    handle_Resource_Change(event) {
        //  if(event.target.name==='log_Date'){
           this.a_Resource_Ref = event.detail.value;
         //  }
       }


    @api recordId;
	refreshcmp;

    fieldSetObjName;
    @track isNoAllocations = false;
    @track resourceAllocations = [];
	@track resourceAllocationsDummy = [];
    //isLoading = true;// spinner

    @wire(getLog, { taskId: '$recordId' })
    wiredGetLogs(result) { 
        const { data, error } = result;
        this.refreshcmp = result;
        if (data) {
			//console.log(' fetchResourceAllocations seelcted Record data ==> '+JSON.stringify(data));
			this.resourceAllocations = [];
			this.resourceAllocationsDummy = [];
			
			for (const row of data) {
				//console.log(' rowww str '+JSON.stringify(row));
			 
				this.resourceAllocations.push({
					Id : row.Id,
                    logName : row.RESOURCE_FIELD,
                    timeSpent : row.Time_Spent__c,
                    workDescription : row.Work_Description__c,
                    logDate : row.Date__c
				});
			}
			this.isNoAllocations = this.resourceAllocations.length === 0;
			this.error = undefined;
			this.fieldSetObjName = 'Log_Table__c';
			
			let tempRecordInput = {
				apiName: 'Log_Table__c',
				fields: {
					Id: 'DummyId'
				}
			 }
			this.resourceAllocationsDummy.push(tempRecordInput);
        } else if (error) {
            this.error = error;
			this.resourceAllocations = undefined;
			console.log('Error on loading resourceAllocations (fetchResourceAllocations) ==> '+error);
        }
    }

  

    @track logs;
    @track errorMsg;

    createRow(event){
        this.firstRecord = true; 
    }
    hideRow(event){
        this.firstRecord = true; 
    }

    addResource(event){
        insertLog({a_Time_Spent : this.a_Time_Spent_Ref,  
            a_Work_Description : this.a_Work_Description_Ref, 
            a_Date : this.a_Date_Ref,
             a_taskId : this.recordId})
             .then(result => {
                const event = new ShowToastEvent({
                    title: 'Log created',
                    message: 'New Log created for Date : '+ result ,
                    variant: 'success'
                });
                this.dispatchEvent(event);
                //eval("$A.get('e.force:refreshView').fire();");
                
                return refreshApex(this.logs);    
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title : 'Error',
                    message : 'Error creating Log. Please Contact System Admin',
                    variant : 'error'
                });
                this.dispatchEvent(event);
            });
          
            
            this.isNoAllocations = false;
            this.firstRecord = true; 
            this.log_Date = null; 
            this.Time_Spent = null; 
            this.Work_Description = null; 
            //window.reload();
            
           
            
            return refreshApex(this.logs);
             

	}

    columns = COLS;
    @wire(findLogs, { searchKey: '$searchKey' })
    logs;
	
    
    

    handleSave(event) {

        isNoAllocations = true;
        const recordInputs =  event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
    
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(loggs => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Logs updated',
                    variant: 'success'
                })
            );
            return refreshApex(this.logs).then(() => {

                // Clear all draft values in the datatable
                this.draftValues = [];

            });
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or reloading record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
        
    }
    

    connectedCallback(){
       this.searchKey = this.recordId;
       return refreshApex(this.wiredGetLogs); 
    }

}