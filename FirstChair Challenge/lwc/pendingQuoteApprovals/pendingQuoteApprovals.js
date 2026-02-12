import { LightningElement, wire } from 'lwc';
import getPendingQuotes from '@salesforce/apex/QuoteApprovalLwcController.getPendingQuotes';
import approveQuotes from '@salesforce/apex/QuoteApprovalLwcController.approveQuotes';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    {
        label: 'Quote Name',
        fieldName: 'recordUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        }
    },
    { label: 'Opportunity', fieldName: 'OpportunityName' },
    { label: 'Discount', fieldName: 'Discount__c', type: 'number' },
    { label: 'Total Amount', fieldName: 'Total_Amount__c', type: 'currency' },
    { label: 'Approval Status', fieldName: 'Approval_Status__c', type: 'text' }
];

export default class PendingQuoteApprovals extends LightningElement {

    columns = COLUMNS;
    quotes = [];
    error;
    wiredResult;
    selectedRowIds = [];
    isLoading = false;

    // 🔹 Wire
    @wire(getPendingQuotes)
    wiredQuotes(result) {
        this.wiredResult = result;

        if (result.data) {
            this.quotes = result.data.map(q => ({
                ...q,
                OpportunityName: q.Opportunity?.Name || '',
                recordUrl: '/' + q.Id
            }));
            this.error = undefined;
        } 
        else if (result.error) {
            this.error = result.error;
            this.quotes = [];
        }
    }

    // 🔹 Capturar selección
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRowIds = selectedRows.map(row => row.Id);
    }

    // 🔹 Aprobar seleccionados
    handleApproveSelected() {

        if (this.selectedRowIds.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No Selection',
                    message: 'Please select at least one quote.',
                    variant: 'warning'
                })
            );
            return;
        }

        this.isLoading = true;

        approveQuotes({ quoteIds: this.selectedRowIds })
            .then(() => {
                return refreshApex(this.wiredResult);
            })
            .then(() => {
                this.selectedRowIds = [];
                this.isLoading = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Selected quotes approved successfully.',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.isLoading = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error approving selected quotes.',
                        variant: 'error'
                    })
                );
            });
    }
}