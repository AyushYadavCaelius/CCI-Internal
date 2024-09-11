import { LightningElement, api, wire } from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/MPM4_BASE__Milestone1_Project__c.MPM4_BASE__Status__c'

const FIELDS = [
    STATUS_FIELD
];

export default class CustomRichText extends LightningElement {
    @api recordId;
    richText;
    bannerText;

    @wire(getRecord, { recordId:'$recordId', fields: FIELDS})
    loadFields({error, data}){
        if(error){
            console.log('error');
            
        }else if(data){
            
            const projectHealth = getFieldValue(data, STATUS_FIELD);
            this.richText = projectHealth == null ? 'Red' : projectHealth;
            this.bannerText = 'Project Health: ' + this.richText;
        }
    }

    get richTextBackground(){
        return this.richText == 'Green' ? 'custom-rich-text-bg-green' : this.richText == 'Yellow' ? 'custom-rich-text-bg-yellow' : 'custom-rich-text-bg-red'
    }
}