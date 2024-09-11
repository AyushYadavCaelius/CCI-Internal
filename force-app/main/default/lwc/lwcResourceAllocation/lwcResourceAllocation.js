import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchResourceAllocations from '@salesforce/apex/FPSA_ResourceAllocation.fetchResourceAllocations';
import getFieldSetMetadata from '@salesforce/apex/FPSA_ResourceAllocation.getFieldSetMetadata';
import fetchAllocationWrapper from '@salesforce/apex/FPSA_ResourceAllocation.fetchAllocationWrapper';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from "@salesforce/apex";

const SECTION_OPEN_ICON  = "utility:switch";
const SECTION_CLOSE_ICON = "utility:chevronright";
const Label_Mappings = {
	"Description" : "Responsibility",
	"Allocation Percent" : "Percentage",
	"Total Planned Hours" : "Total",
	"Projected Revenue" : "Revenue",
	"Cost Rate Amount" : "Cost Rate"
}

export default class LwcResourceAllocation extends LightningElement {
	fixedWidth = "width:5rem;";
	fixedWidthWithMax = "width:15rem;";

	@api recordId;
	refreshcmp;

	@track resourceAllocations = [];
	@track resourceAllocationsDummy = [];

	fieldSetObjName;
	@track isEditMode = true;
	isLoading = true;// spinner
	@track isNoAllocations = false;
	@track unAssignedResourceId;
	@track plannedHours;
	@track projectedRevenue;
	@track sectionIcons = {
        projectDetailSection: SECTION_OPEN_ICON
	}	

	connectedCallback(){
		
	}
	
	sectionClick(event){
        //console.log('Clicked Id ',event.target.getAttribute("data-id"));
		let sectionName = event.target.getAttribute("data-id");
        let contempList = this.template.querySelector('.' + sectionName);;
		if(contempList){
            let isHidden = contempList.getAttribute("class").search('slds-is-open');
            if(isHidden == -1){
                this.sectionIcons[sectionName] = SECTION_OPEN_ICON;
                contempList.setAttribute("class", sectionName + ' slds-section slds-is-open');
            } else {
                this.sectionIcons[sectionName] = SECTION_CLOSE_ICON;
                contempList.setAttribute("class", sectionName + ' slds-section slds-is-close');
            }
        }
    }


	@track mapData= [];
	@track projectDetail;
	@track durationinweeks;
	@wire(fetchAllocationWrapper, { projectId: '$recordId' })
    wiredfetchAllocationWrapper(result) {
		//console.log(' in calling fetchAllocationWrapper ',JSON.stringify(result));
		const { data, error } = result;
		if (data) {
			var conts = data.weekStarting;
			this.projectDetail = data.projectRec;
			this.durationinweeks = data.durationInWeeks;
			this.unAssignedResourceId = data.unAssignedResourceId;
			var sNo = 1;
            for(var key in conts){
                this.mapData.push({
					seqNo: sNo,
					wDate: conts[key],
					wFieldName: key
				}); //Here we are creating the array to show on UI.
				sNo = sNo + 1;
            }
        } else if (error) {
            this.error = error;
			this.mapData = undefined;
			this.projectDetail = undefined;
			console.log('Error on fetchAllocationWrapper (fetchAllocationWrapper) ==> '+error);
        }
    }

	@wire(fetchResourceAllocations, { projectId: '$recordId', unAssignId: '$unAssignedResourceId' })
    wiredResourceAllocs(result) {
		//console.log(' in calling fetchResourceAllocations ');
		const { data, error } = result;
		this.refreshcmp = result;
        if (data) {
			//console.log(' fetchResourceAllocations seelcted Record data ==> '+JSON.stringify(data));
			this.resourceAllocations = [];
			this.resourceAllocationsDummy = [];
			this.plannedHours = 0;
			this.projectedRevenue = 0;
			for (const row of data) {
				//console.log(' rowww str '+JSON.stringify(row));
				if(row.FPSA_Total_Planned_Hours__c){
					this.plannedHours = +this.plannedHours + +row.FPSA_Total_Planned_Hours__c;
				}
				if(row.FPSA_Projected_Revenue__c){
					this.projectedRevenue = +this.projectedRevenue + +row.FPSA_Projected_Revenue__c;
				}
				this.resourceAllocations.push({
					Id : row.Id,
					projectId : row.FPSA_Project__c,
					selectedAllocationId : row.Id,
					isUnassigned : row.Resource_Name__c && row.Resource_Name__c === this.unAssignedResourceId
				});
			}
			this.isNoAllocations = this.resourceAllocations.length === 0;
			this.error = undefined;
			this.fieldSetObjName = 'FPSA_Project_Allocation__c';
			
			let tempRecordInput = {
				apiName: 'FPSA_Project_Allocation__c',
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

	fieldSets = [];
	@wire(getFieldSetMetadata, { objName: '$fieldSetObjName', fieldSetName: 'Allocation_Fields' })
	opptyFieldSetsdata(result) {
        const { data, error } = result;
		//console.log('Opportunity FieldSet results : ', JSON.stringify(data));
        if(data){
            let sections = [];
            data.forEach((mt) => {
                //console.log(' mt ## ', mt);
                //this.recordTypeId = mt.recordTypeId;
                //this.sObjectName = mt.sObjectName;
                let fieldSetFields = [];
                mt.fieldsMetadata.forEach((fd) => {
                    // Get valid JSON
                    const fieldProperties = JSON.parse(fd);
                    const {
                        fieldSetProperties,
                        fieldDescribeProperties
                    } = fieldProperties;
					let customCssClasses = '';
					if(fieldDescribeProperties && (fieldDescribeProperties.name === 'FPSA_Role__c' 
						|| fieldDescribeProperties.name === 'FPSA_Description__c'
						|| fieldDescribeProperties.name === 'Resource_Name__c')){
						customCssClasses += 'nonFixedColumnCls';
					}else{
						customCssClasses += 'fixedColumnCls';
					}
                    fieldSetFields.push({
						name: fieldDescribeProperties.name,
						classnamecustom: customCssClasses,
						classFixedColumns: fieldDescribeProperties.name === 'FPSA_Role__c' || fieldDescribeProperties.name === 'FPSA_Description__c' ? 'classFixedColumns':'classNonFixedColumns',
						label: Label_Mappings[fieldDescribeProperties.label] !== undefined ? Label_Mappings[fieldDescribeProperties.label] : fieldDescribeProperties.label ,
                        isRequired: fieldSetProperties.isRequired || fieldSetProperties.dbRequired,
                        isUpdateable: !!fieldDescribeProperties.updateable,
                        editable: this.isEditMode && !!fieldDescribeProperties.updateable,
						isDisabled: fieldDescribeProperties.name === 'FPSA_Total_Planned_Hours__c' || fieldDescribeProperties.name === 'FPSA_Projected_Revenue__c',
						isResourceField: fieldDescribeProperties.name === 'Resource_Name__c',
						isPlannedHours: fieldDescribeProperties.name === 'FPSA_Total_Planned_Hours__c',
						isProjectedRevenue: fieldDescribeProperties.name === 'FPSA_Projected_Revenue__c'
                    });
                });
                //this.activeSections.push(mt.fieldSetLabel);
                this.fieldSets.push({
                    fieldSetTitle: mt.fieldSetLabel,
                    fieldSetAPIName: mt.fieldSetAPIName,
                    recordTypeId: mt.recordTypeId,
                    sobjName: mt.sObjectName,
                    recordFields: fieldSetFields
                })
            });
            this.handleFieldSetsData();
        }else if(error){
            console.log('error in calling getFieldSetMetadata (Opportunity field sets) apex method -> ',error);
        }
	}
	
	@track AllocationFieldSets;
	handleFieldSetsData(){
        //console.log(' fieldSets in handleFieldSetsData ** ',this.fieldSets );
        if(this.fieldSets){
            this.fieldSets.forEach(fieldSet=>{
				 fieldSet.recordFields.forEach((field) => {
                    field.editable = this.isEditMode && field.isUpdateable;
                    // console.log(' fieldset field : '+field.name);
					//console.log(' field.name ==> ',field.name);
				});
                //console.log(' fieldSet ## ', JSON.stringify(fieldSet));
                // use the api name to check fiel set name 
                if(fieldSet.recordFields && fieldSet.recordFields.length > 0){
                    if(fieldSet.fieldSetAPIName === 'Allocation_Fields'){
                        this.AllocationFieldSets = {title:fieldSet.fieldSetTitle,fields:fieldSet.recordFields};
                    }
                }
            });
		}

		this.isLoading = false;
	}

	handleFormSubmit(event){
		event.preventDefault();
		const fields = event.detail.fields;
		// console.log( "Fields: ", fields );
		if (fields) {
			fields.forEach(field => {
				// console.log('Field is==> ' + field.fieldName);
				// console.log('Field is==> ' + field.value);
			});
		}
	}

	hadleProductLineSave(){

		this.hasError = false;
        this.errorMessages = undefined;
		this.isLoading = true;
		this.template
		.querySelectorAll(".lwcRecEditFrom")
		.forEach(element => {
			element.submit();
		});
	  	this.savedRecordsCount = 0;
	}
	savedRecordsCount;
	handleSuccessAllocation(event){
		//console.log('Saved Record Id -> ' + event.detail.id);
		//alert('handleSuccess()--->');
		if(event.detail.id){
			this.savedRecordsCount = this.savedRecordsCount + 1;
		}
		if(this.savedRecordsCount === this.resourceAllocations.length){
			// console.log('called sucessfully on all records');
			refreshApex(this.refreshcmp);
			this.isLoading = false;
		}
	}

	handleErrorAllocation(event){
		//console.log('error ', JSON.stringify(event));
		let objErrors = [];
        if(event.detail && event.detail.output){
            let errorList = event.detail.output;
            let errorFieldName;
            //console.log(' error in before fieldErrors ::::  ', JSON.stringify(errorList.fieldErrors));
            if(errorList.fieldErrors){

                Object.keys(errorList.fieldErrors).forEach(
                function(field) { 
                    errorList.fieldErrors[field].forEach(
                        function(msg) { 
                            //console.log(' error in fieldErrors ::::  ', msg.message);
                            // console.log(msg.fieldLabel); console.log(msg.field);
                            // console.log(msg.errorCode); console.log(msg.message); 
                            errorFieldName = msg.field;
                            objErrors.push(msg.message);
                        }
                    )
                });

            }
            if(errorList.errors){
                errorList.errors.forEach(error=>{
                    //console.log(' error in Top ::::  ', error.message);
                    objErrors.push(error.message);
                 });
            }
        }
		// console.log(' Final error messages ==> ',objErrors);
        if(objErrors){
            this.errorMessages = objErrors;
        }
        this.isLoading = false;
        this.hasError = true;
        this.minimizeError = false;
	}

	@track hasError = false;
	@track minimizeError = true;
	@track errorMessages;
    handleCloseError(){
        this.minimizeError = !this.minimizeError;
    }

	generateUniqueId(){
		return '_' + Math.random().toString(36).substr(2, 9);
	}

	addResource(){
		this.resourceAllocations.push({
			projectId : this.recordId,
			selectedAllocationId: this.generateUniqueId(),
			isUnassigned: true
		});
		this.isNoAllocations = this.resourceAllocations.length === 0;
	}

	copyRow(event){
		this.isLoading = true;
		let copyRowObj = this.resourceAllocations[event.target.value];
		// console.log(' copyRowObj ',copyRowObj);
		// console.log(' copyRowObj rec id ',copyRowObj.Id);
		// console.log(' copyRowObj rec uni id ',copyRowObj.selectedAllocationId);

		let uniqueIdCopy = this.generateUniqueId();
		this.resourceAllocations.push({
			projectId : this.recordId,
			selectedAllocationId: uniqueIdCopy,
			isUnassigned: true
		});
		// console.log('1 uniqueIdCopy ',uniqueIdCopy);
		let recordValues = new Map();
		this.template.querySelectorAll('lightning-input-field[data-myid="'+copyRowObj.selectedAllocationId+'"]').forEach(element => {
			if(element.value){
				recordValues.set(element.dataset.myfieldname, element.value);
				console.log(' element.value ==> ',element.value, ' field Name ',element.dataset.myfieldname);
			}
		});
		// console.log(" recordValues ==> ",JSON.stringify(recordValues));
		setTimeout(()=> {
			this.template.querySelectorAll('lightning-input-field[data-myid="'+uniqueIdCopy+'"]').forEach(element => {
				element.value = recordValues.get(element.dataset.myfieldname);
			});
			//this.calculateFooterTotals();
			this.isLoading = false;
		}, 1000);
	}

	deleteRow(event){
		this.isLoading = true;
		let deleteRowObj = this.resourceAllocations[event.target.value];
		let deleteId = deleteRowObj.Id;
		//console.log(' deleteId ==> ',deleteId);
		if(deleteId){
			deleteRecord(deleteId)
			.then(() => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Success',
						message: 'Allocation deleted successfully',
						variant: 'success'
					})
				);

				// To delete the record from UI
				this.resourceAllocations.splice(event.target.value, 1);
				refreshApex(this.refreshcmp);
				this.isLoading = false;
			})
			.catch(error => {
				console.log('error while deleting Allocation ', error);
			});
		}else{
			this.resourceAllocations.splice(event.target.value, 1);
			setTimeout(()=> {
				this.calculateFooterTotals();
				this.isLoading = false;
			}, 500);
		}

		this.isNoAllocations = this.resourceAllocations.length === 0;
	}

	setHasChanged(event){
		// console.log(' unique Id '+event.target.name);
		// console.log(' value on change '+event.target.value);
		// console.log(' value on change field '+event.target.dataset.myfieldname);
		// console.log(' Selected opp Line '+JSON.stringify(this.getSelectedProductRec(event.target.name)));
		let fieldChange = event.target.dataset.myfieldname;
		let fieldChangedValue = event.target.value;
		let recordValues = [];
		this.template.querySelectorAll('lightning-input-field[data-myid="'+event.target.name+'"]').forEach(element => {
			if(element.value){
				recordValues.push({field:element.dataset.myfieldname, value:element.value});
			}
			if(fieldChange === 'Allocation_Percent__c'){
				if(element.dataset.myfieldname.startsWith("FPSA_Week_") && element.dataset.myfieldname.endsWith("_hrs__c")){
					if(fieldChangedValue){
						element.value = (40 / 100 ) * fieldChangedValue;
					}else{
						element.value = 0;
					}
					
				}
			}
		});
		//console.log(' changed record Values ',JSON.stringify(recordValues));
		let totalPlannedHours = 0;
		let billRate = 0;
		//console.log('1 ==> totalPlannedHours ',totalPlannedHours);
		this.template.querySelectorAll('lightning-input-field[data-myid="'+event.target.name+'"]').forEach(element => {
			//console.log('element ===>>> ',element.dataset.myfieldname,' : ',element.value);
			if(element.value && element.dataset.myfieldname.startsWith("FPSA_Week_") && element.dataset.myfieldname.endsWith("_hrs__c")){
				totalPlannedHours = +totalPlannedHours + +element.value;
			}
			if(element.value && element.dataset.myfieldname === "FPSA_Bill_Rate__c"){
				billRate = element.value;
			}
		});
		//set values
		this.template.querySelectorAll('lightning-input-field[data-myid="'+event.target.name+'"]').forEach(element => {
			if(element.dataset.myfieldname === "FPSA_Total_Planned_Hours__c"){
				element.value = totalPlannedHours;
			}
			if(element.dataset.myfieldname === "FPSA_Projected_Revenue__c"){
				element.value = totalPlannedHours * billRate;
			}

		});
		
		this.calculateFooterTotals();
	}

	calculateFooterTotals(){
		console.log(' in calculateFooterTotals : ',this.plannedHours);
		this.plannedHours = 0;
		this.template.querySelectorAll('.FPSA_Total_Planned_Hours__c').forEach(element => {
			if(element.value){
				this.plannedHours = +this.plannedHours + +element.value;
			}
		});
		console.log('after in calculateFooterTotals : ',this.plannedHours);
		this.projectedRevenue = 0;
		this.template.querySelectorAll('.FPSA_Projected_Revenue__c').forEach(element => {
			if(element.value){
				this.projectedRevenue = +this.projectedRevenue + +element.value;
			}
		});
	}

	showInfoToast() {
        const evt = new ShowToastEvent({
            title: 'No Allocations',
            message: 'Please create Project Allocations',
            variant: 'info',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }


	closeMenu(){
		console.log(' calling close menu ==>  ');
	}
}