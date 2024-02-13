import { LightningElement, api, track, wire } from 'lwc';
import getKnowledgeRecord from '@salesforce/apex/shpArticleRecordPageController.getKnowledgeRecord';
import updateKnowledgeRecord from '@salesforce/apex/shpArticleRecordPageController.updateKnowledgeRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

export default class ShpArticleRecordCustomControl extends LightningElement {
    @api recordId;
    @track recordData = {};
    @track isLoading = true;
    @track isReadOnly = true;
    @track isEditHidden = true;
    @track isEditMode = false;
    @track isTranslationStatusVisible = false;
    @track sectionIcon = 'utility:chevrondown'


    @wire(getRecord, { recordId: '$recordId', fields: ['Approval_status__c', 'PublishStatus'] })
    wiredRecord(data, error) {
        this.isLoading = true
        if (data) {
            this.loadKnowledgeRecord()
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error));
        }
    }

    loadKnowledgeRecord() {
        getKnowledgeRecord({ recordId: this.recordId }).then(result => {
            this.recordData = result
            console.log(this.recordData)
            if (this.recordData.isMasterLanguage && this.recordData.publishStatus != 'Online') {
                this.isEditHidden = false
                this.isLoading = false
            }
            if (this.recordData.isMasterLanguage) {
                this.isTranslationStatusVisible = true;
            }
            if(this.recordData.publishStatus == 'Online'){
                this.isEditHidden = true
                this.isLoading = false
            }
            this.isLoading = false
        })
            .catch(error => {
                console.error('Error fetching knowledge record', error)
            })
    }

    handleEdit() {
        this.isReadOnly = !this.isReadOnly
        this.isEditMode = true
    }

    handleCheckboxChange(event) {
        const fieldName = event.target.name
        const value = event.target.checked
        this.recordData = { ...this.recordData, [fieldName]: value }
    }

    handleCancel() {
        this.isEditMode = false
        this.isReadOnly = true
        this.isLoading = true
        this.loadKnowledgeRecord();
    }

    handleSave() {
        // Call the Apex method to update the record
        updateKnowledgeRecord({
            applicableToAllClients: this.recordData.applicableToAllClients,
            articleVisibilityForCandidate: this.recordData.articleVisibilityForCandidate,
            featureArticle: this.recordData.featureArticle,
            recordId: this.recordId,
            translationComplete: this.recordData.translationComplete
        })
            .then(result => {
                if (result) {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                } else {
                    // Update successful, switch back to read-only mode
                    this.isReadOnly = true
                    this.isEditMode = false
                    this.isLoading = true
                    this.loadKnowledgeRecord();
                }
            })
    }

    toggleSection() {
        let currentSection = this.template.querySelector('[data-id="shpAVC"]')
        if (currentSection.className.search('slds-is-open') == -1) {
            currentSection.className = 'test-id__section slds-section slds-m-vertical_none has-header slds-is-open';
            this.sectionIcon = 'utility:chevrondown';
        } else {
            currentSection.className = 'test-id__section slds-section slds-m-vertical_none has-header';
            this.sectionIcon = 'utility:chevronright';
        }
    }
}