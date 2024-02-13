public with sharing class shpArticleRecordPageController {
    public class KnowledgeRecordWrapper {
        @AuraEnabled
        public String approvalStatus { get; set; }
        @AuraEnabled
        public Boolean applicableToAllClients { get; set; }
        @AuraEnabled
        public Boolean articleVisibilityForCandidate { get; set; }
        @AuraEnabled
        public Boolean featureArticle { get; set; }
        @AuraEnabled
        public Id MasterVersionId { get; set; }
        @AuraEnabled
        public String publishStatus { get; set; }
        @AuraEnabled
        public Boolean isMasterLanguage { get; set; }
        @AuraEnabled
        public Boolean translationComplete { get; set; }
    }
    @AuraEnabled
    public static KnowledgeRecordWrapper getKnowledgeRecord(String recordId) {
        Knowledge__kav knowledgeRecord =    [SELECT Id, Approval_status__c, Applicable_to_all_clients__c, PublishStatus, 
                                                    Article_visiblity_for_candidate__c, feature_article__c, MasterVersionId, 
                                                    IsMasterLanguage, Translation_complete__c
                                            FROM Knowledge__kav WHERE Id = :recordId LIMIT 1];
        
        KnowledgeRecordWrapper wrapper = new KnowledgeRecordWrapper();
        wrapper.approvalStatus = knowledgeRecord.Approval_status__c;
        wrapper.applicableToAllClients = knowledgeRecord.Applicable_to_all_clients__c;
        wrapper.articleVisibilityForCandidate = knowledgeRecord.Article_visiblity_for_candidate__c;
        wrapper.featureArticle = knowledgeRecord.feature_article__c;
        wrapper.MasterVersionId = knowledgeRecord.MasterVersionId;
        wrapper.publishStatus = knowledgeRecord.PublishStatus;
        wrapper.isMasterLanguage = knowledgeRecord.isMasterLanguage;
        wrapper.translationComplete = knowledgeRecord.Translation_complete__c;

        return wrapper;
    }

    @AuraEnabled
    public static String updateKnowledgeRecord(Boolean applicableToAllClients, Boolean articleVisibilityForCandidate, Boolean featureArticle, String recordId, Boolean translationComplete) {
        // Retrieve the existing record
        try{
            Knowledge__kav existingRecord = [SELECT Applicable_to_all_clients__c, Article_visiblity_for_candidate__c, feature_article__c, Translation_complete__c
                                        FROM Knowledge__kav WHERE Id = :recordId LIMIT 1];
            // Update the fields
            existingRecord.Applicable_to_all_clients__c = applicableToAllClients;
            existingRecord.Article_visiblity_for_candidate__c = articleVisibilityForCandidate;
            existingRecord.feature_article__c = featureArticle;
            existingRecord.Translation_complete__c = translationComplete;
            // Perform the update
            update existingRecord;
            return null;
        }catch(Exception e){
            String errorMsg = e.getMessage();
            if(errorMsg.contains('Mark Article visibility for candidate to true to make this featured article')){
                errorMsg = 'Mark Article visibility for candidate to true to make this featured article';
            }
            return errorMsg;
        }
       
    }
}