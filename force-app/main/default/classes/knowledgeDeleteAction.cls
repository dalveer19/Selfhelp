public without sharing class knowledgeDeleteAction {

     @AuraEnabled
    public static String deleteKA(string recordId){
       try {   
       String kaDeleted; 
        
       Id  permissionSetId_AllowDeleteAll = [SELECT Id FROM PermissionSet WHERE Name =: 'Knowledge_Content_Manager_PS'].Id;
       list<PermissionSetAssignment> permissionList = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() and PermissionSetId =: permissionSetId_AllowDeleteAll];        
        knowledge__kav ka = [select id,ownerId,publishStatus,KnowledgeArticleId,IsMasterLanguage from knowledge__kav where id=: recordId limit 1];
        list<knowledge__kav> kaPub = [Select id from knowledge__kav where KnowledgeArticleId =: ka.KnowledgeArticleId and publishStatus = 'Online' ];
        if(permissionList.isempty()){
            if(ka.OwnerId ==  UserInfo.getUserId()  && ka.PublishStatus == 'Draft' && ka.IsMasterLanguage == true){
               KbManagement.PublishingService.deleteDraftArticle(ka.KnowledgeArticleId);
            } else if(ka.OwnerId ==  UserInfo.getUserId()  && ka.PublishStatus == 'Draft' && ka.IsMasterLanguage == false) {
                KbManagement.PublishingService.deleteDraftTranslation(recordId);
            } else {
                throw new AuraHandledException('error');
            } 
        } else {
               KbManagement.PublishingService.deleteDraftArticle(ka.KnowledgeArticleId);
        }
           if(kaPub.isEmpty()){
              kaDeleted =  [SELECT Id, Name FROM ListView WHERE SobjectType = 'Knowledge__kav' and DeveloperName ='draft_articles' limit 1].Id;
               return kaDeleted;
           } else {
              return ka.KnowledgeArticleId;
           }
        }catch ( Exception ex){
             throw new AuraHandledException('Darn it! Something went wrong: '+ ex.getMessage());
            }
}
}