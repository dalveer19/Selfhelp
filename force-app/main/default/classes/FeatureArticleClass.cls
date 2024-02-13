public class FeatureArticleClass {
@AuraEnabled(cacheable=true)
    public static list<articleWrapper> getFeaturedArticles(string client,String language){
        system.debug('client value is :: '+client);
        system.debug('language value is :: '+language);
        
        try{
            List<articleWrapper> wrapperListToReturn = New List<articleWrapper>();

            if(language == 'en_US'){

                if(client == 'All'){
                    List<Knowledge__kav> knowledgeList = [SELECT id,Language,title,summary,masterVersionId,knowledgeArticleId 
                                                          FROM Knowledge__kav 
                                                          WHERE feature_article__c = true 
                                                          AND PublishStatus = 'Online' 
                                                          AND Article_visiblity_for_candidate__c = true 
                                                          AND Applicable_to_all_clients__c = true
                                                          AND Language = 'en_US' AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
                                                          ORDER BY LastPublishedDate DESC LIMIT 6];
                    for(Knowledge__kav ka : knowledgeList){
                        articleWrapper aw =  New articleWrapper();
                        aw.title = ka.title;
                        aw.summary = ka.summary;
                        aw.recordId = ka.id;
                        aw.masterVersionId = ka.masterVersionId;
                        aw.knowledgeArticleId = ka.knowledgeArticleId;
                        wrapperListToReturn.add(aw);
                        System.debug(wrapperListToReturn);
                    }                                                                                        
                }
                else{
                    Id clientId =  shp_accountUtility.getAccountId(client);
                    Set<Id> articleIdSet = New Set<Id>();
                    List<Linked_Client__c> linkedClientList = [SELECT id,Knowledge_Article__r.id,Knowledge_Article__r.knowledgeArticleId,Knowledge_Article__r.title,Knowledge_Article__r.summary,Knowledge_Article__r.masterVersionId 
                                                               FROM Linked_Client__c 
                                                               WHERE Client__c =: id.valueOf(clientId) 
                                                               AND Knowledge_Article__r.PublishStatus = 'Online'
                                                               AND Knowledge_Article__r.Language = 'en_US'
                                                               AND Knowledge_Article__r.feature_article__c = true
                                                               AND Knowledge_Article__r.Article_visiblity_for_candidate__c = true 
                                              				   AND Knowledge_Article__r.RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
                                                               ORDER BY Last_Published_Date__c DESC LIMIT 6];

                    for(Linked_Client__c lc : linkedClientList){
                        articleWrapper aw =  New articleWrapper();
                        aw.title = lc.Knowledge_Article__r.title;
                        aw.summary = lc.Knowledge_Article__r.summary;
                        aw.recordId = lc.Knowledge_Article__r.id;
                        aw.masterVersionId = lc.Knowledge_Article__r.masterVersionId;
                        aw.knowledgeArticleId = lc.Knowledge_Article__r.knowledgeArticleId;
                        wrapperListToReturn.add(aw);
                        articleIdSet.add(lc.Knowledge_Article__r.id);
                        System.debug(wrapperListToReturn);
                    }    

                    // Need to add logic of getting remanining from applicable to all clients 
                    if(wrapperListToReturn.size() < 6){
                        integer noOfRecordsToAdd = 6-wrapperListToReturn.size();
                        List<Knowledge__kav> knowledgeList = [SELECT id,Language,title,summary,masterVersionId,knowledgeArticleId 
                                                              FROM Knowledge__kav 
                                                              WHERE feature_article__c = true 
                                                              AND PublishStatus = 'Online' 
                                                              AND Article_visiblity_for_candidate__c = true 
                                                              AND Applicable_to_all_clients__c = true
                                                              AND Language = 'en_US' 
                                                              AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
                                                              AND ID NOT IN:articleIdSet
                                                              ORDER BY LastPublishedDate DESC LIMIT: noOfRecordsToAdd];

                        for(Knowledge__kav ka : knowledgeList){
                            articleWrapper aw =  New articleWrapper();
                            aw.title = ka.title;
                            aw.summary = ka.summary;
                            aw.recordId = ka.id;
                            aw.masterVersionId = ka.masterVersionId;
                            aw.knowledgeArticleId = ka.knowledgeArticleId;
                            wrapperListToReturn.add(aw);
                            System.debug(wrapperListToReturn);
                        }
                    }                                      
                    

                }
            }
            else{
                if(client == 'All'){
                    List<Knowledge__kav> knowledgeList = [SELECT id,Language,title,summary,masterVersionId,knowledgeArticleId 
                                                          FROM Knowledge__kav
                                                          WHERE feature_article__c = true 
                                                          AND PublishStatus = 'Online' 
                                                          AND Article_visiblity_for_candidate__c = true 
                                                          AND Applicable_to_all_clients__c = true
                                                          AND Language =: language 
                                                          AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
                                                          ORDER BY LastPublishedDate DESC LIMIT 6];
                    for(Knowledge__kav ka : knowledgeList){
                        articleWrapper aw =  New articleWrapper();
                        aw.title = ka.title;
                        aw.summary = ka.summary;
                        aw.recordId = ka.id;
                        aw.masterVersionId = ka.masterVersionId;
                        aw.knowledgeArticleId = ka.knowledgeArticleId;
                        wrapperListToReturn.add(aw);
                        System.debug(wrapperListToReturn);
                    } 
                }
                else{
                    Id clientId =  shp_accountUtility.getAccountId(client);
                    Set<Id> articleIdSet = New Set<Id>();
                    Set<Id> parentIdSet = New Set<Id>();
                    List<Linked_Client__c> linkedClientList = [SELECT id,Knowledge_Article__r.id,Knowledge_Article__r.knowledgeArticleId,Knowledge_Article__r.title,Knowledge_Article__r.summary,Knowledge_Article__r.masterVersionId 
                                                               FROM Linked_Client__c 
                                                               WHERE Client__c =: id.valueOf(clientId) 
                                                               AND Knowledge_Article__r.PublishStatus = 'Online'
                                                               AND Knowledge_Article__r.feature_article__c = true
                                                               AND Knowledge_Article__r.Article_visiblity_for_candidate__c = true 
                                              				   AND Knowledge_Article__r.RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
                                                               ORDER BY Last_Published_Date__c DESC ];

                    for(Linked_Client__c lc : linkedClientList ){
                        parentIdSet.add(lc.Knowledge_Article__r.knowledgeArticleId);
                    }  

                    List<Knowledge__kav> knowledgeList = [SELECT id,Language,title,summary,masterVersionId,knowledgeArticleId 
                                                          FROM Knowledge__kav 
                                                          WHERE feature_article__c = true 
                                                          AND PublishStatus = 'Online' 
                                                          AND Article_visiblity_for_candidate__c = true 
                                                         // AND Applicable_to_all_clients__c = true
                                                          AND Language =: language 
                                                          AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
                                                          AND knowledgeArticleId IN: parentIdSet
                                                          ORDER BY LastPublishedDate];

                    for(Knowledge__kav ka : knowledgeList){
                        if(wrapperListToReturn.size() < 6 ){
                            articleWrapper aw =  New articleWrapper();
                            aw.title = ka.title;
                            aw.summary = ka.summary;
                            aw.recordId = ka.id;
                            aw.masterVersionId = ka.masterVersionId;
                            aw.knowledgeArticleId = ka.knowledgeArticleId;
                            wrapperListToReturn.add(aw);
                            articleIdSet.add(ka.id);
                            System.debug(wrapperListToReturn);
                        }
                    }

                    if(wrapperListToReturn.size() < 6){
                        integer noOfRecordsToAdd = 6-wrapperListToReturn.size();
                        List<Knowledge__kav> knowledgeAllList = [SELECT id,Language,title,summary,masterVersionId,knowledgeArticleId 
                                                                 FROM Knowledge__kav 
                                                                 WHERE feature_article__c = true 
                                                                 AND PublishStatus = 'Online' 
                                                                 AND Article_visiblity_for_candidate__c = true 
                                                                 AND Applicable_to_all_clients__c = true
                                                                 AND Language =: language 
                                                                 AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
                                                                 AND ID NOT IN:articleIdSet
                                                                 ORDER BY LastPublishedDate DESC limit: noOfRecordsToAdd];

                        for(Knowledge__kav ka : knowledgeAllList){
                            articleWrapper aw =  new articleWrapper();
                            aw.title = ka.title;
                            aw.summary = ka.summary;
                            aw.recordId = ka.id;
                            aw.masterVersionId = ka.masterVersionId;
                            aw.knowledgeArticleId = ka.knowledgeArticleId;
                            wrapperListToReturn.add(aw);
                            System.debug(wrapperListToReturn);
                        }

                    }    

                }
            }
           

            
        
            return wrapperListToReturn;
        }catch(exception ex){
            throw new AuraHandledException(ex.getMessage() + '*****'+ex.getLineNumber() );
        }
    }
    
    public class articleWrapper{
    
        @AuraEnabled public string title{get;set;}
        @AuraEnabled public string summary{get;set;}
        @AuraEnabled public id recordId{get;set;}
        @AuraEnabled public id masterVersionId{get;set;}
        @AuraEnabled public id knowledgeArticleId{get;set;}
    }

}