public with sharing class FetchArticles{

    @AuraEnabled(cacheable=true)
    public static list<articleWrapper> getFeaturedArticles(string client,String language){
        system.debug('client value is :: '+client);
        system.debug('language value is :: '+language);
        
        try{
            list<articleWrapper> wrapperListToReturn = new list<articleWrapper>();
            set<id> knowIDSet = new set<id>();
            set<id> knowVerIDSet = new set<id>();
            set<id> KnowEngVersionSet = new set<id>();
            list<Knowledge__kav> knowledgeList = new list<Knowledge__kav>();

            if(client == 'All' ){ // if user select all content articles
                system.debug('Entered in all ');
                
                knowledgeList = [select id,Language,title,summary,masterVersionId,knowledgeArticleId from Knowledge__kav where feature_article__c = true and PublishStatus = 'Online' 
                                                                                                            and Article_visiblity_for_candidate__c = true 
                                                                                                            and Applicable_to_all_clients__c = true
                                                                                                            and Language = 'en_US' AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
                                                                                                            order by LastPublishedDate DESC limit 6];
                
                // user selects all content and language is english
                for(Knowledge__kav ka : knowledgeList){
                    articleWrapper aw =  new articleWrapper();
                    aw.title = ka.title;
                    aw.summary = ka.summary;
                    aw.recordId = ka.id;
                    aw.masterVersionId = ka.masterVersionId;
                    aw.knowledgeArticleId = ka.knowledgeArticleId;
                    wrapperListToReturn.add(aw);
                    KnowEngVersionSet.add(ka.knowledgeArticleId);
                    System.debug(wrapperListToReturn);
                }   
                
                if(language <> 'en_US'){ // user selects all content and language is not english
                    wrapperListToReturn.clear(); //Clearing this as it will have Engligh version articles
					if(!KnowEngVersionSet.isEmpty()){
						for(Knowledge__kav ka : [select id,Language,title,summary,masterVersionId,knowledgeArticleId from Knowledge__kav where knowledgeArticleId IN: KnowEngVersionSet
																													and Language =:  language
																													and PublishStatus = 'Online' AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
																													order by LastPublishedDate DESC limit 6]){
							articleWrapper aw =  new articleWrapper();
							aw.title = ka.title;
							aw.summary = ka.summary;
							aw.recordId = ka.id;
							aw.masterVersionId = ka.masterVersionId;
							aw.knowledgeArticleId = ka.knowledgeArticleId;
							wrapperListToReturn.add(aw);
						}
					}
                }                                                                           
            }
            else{ // user selects particular client
                system.debug('Entered in specific ');
                Id clientId =  shp_accountUtility.getAccountId(client);
                	
                
                System.debug(clientId);
                    //user selects particular client and language is english
                    for(Linked_Client__c ca: [select id,Knowledge_Article__r.knowledgeArticleId from Linked_Client__c where Client__c =: id.valueOf(clientId) 
                                                                                                and Knowledge_Article__r.PublishStatus = 'Online'
                                                                                                and Knowledge_Article__r.feature_article__c = true
                                                                                                and Knowledge_Article__r.Article_visiblity_for_candidate__c = true 
                                              													AND Knowledge_Article__r.RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
                                                                                            // order by Related_article__r.LastPublishedDate DESC
                                                                                                Order by Last_Published_Date__c DESC
                                                                                                limit 6]){
                            knowIDSet.add(ca.Knowledge_Article__r.knowledgeArticleId);
                    }
                    system.debug('knowIDSet Value is :: '+knowIDSet);

                    if(!knowIDSet.isEmpty()){
                        System.debug('**************1*****************');
                            for(Knowledge__kav ka : [select id,title,summary,masterVersionId,knowledgeArticleId from Knowledge__kav where knowledgeArticleId IN: knowIDSet
                                                                                        and language = 'en_US' AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
                                                                                        order by LastPublishedDate DESC limit 6]){
                                articleWrapper aw =  new articleWrapper();
                                aw.title = ka.title;
                                aw.summary = ka.summary;
                                aw.recordId = ka.id;
                                aw.masterVersionId = ka.masterVersionId;
                                aw.knowledgeArticleId = ka.knowledgeArticleId;
                                wrapperListToReturn.add(aw);
                                KnowEngVersionSet.add(ka.knowledgeArticleId);
                                knowVerIDSet.add(ka.id);            
                            }
                            system.debug('wrapperListToReturn 1 Value is :: '+wrapperListToReturn);
                            system.debug('KnowEngVersionSet 1 Value is :: '+KnowEngVersionSet);
                            system.debug('knowVerIDSet 1 Value is :: '+knowVerIDSet);
                    }

                    //checking size of return list
                    integer returnListSizeEnUS = wrapperListToReturn.size();
                    system.debug('returnListSizeEnUS value is :: '+returnListSizeEnUS);
                    if(returnListSizeEnUS < 6){
                        System.debug('**************2*****************');
                        if(language == 'en_US'){
                            System.debug('**************3*****************');
                        integer noOfRecordsToAddEnUS = 6 - returnListSizeEnUS;

						//For dupicate bug fix CSH-540
						if(!knowVerIDSet.isEmpty()){
                            System.debug('**************4*****************');
							//Now even though user selected particular cliet as count is less than 6 we can all generic 
							for(Knowledge__kav ka : [select id,Language,title,summary,masterVersionId,knowledgeArticleId from Knowledge__kav where feature_article__c = true and PublishStatus = 'Online' 
																													and Article_visiblity_for_candidate__c = true 
																													and Applicable_to_all_clients__c = true
																													and Language = 'en_US' AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
																													and id NOT IN: knowVerIDSet 
																													order by LastPublishedDate DESC limit: noOfRecordsToAddEnUS]){
								articleWrapper aw =  new articleWrapper();
								aw.title = ka.title;
								aw.summary = ka.summary;
								aw.recordId = ka.id;
								aw.masterVersionId = ka.masterVersionId;
								aw.knowledgeArticleId = ka.knowledgeArticleId;
								KnowEngVersionSet.add(ka.knowledgeArticleId);
								wrapperListToReturn.add(aw);
                                System.debug('**************wrapperListToReturn 1*****************'+wrapperListToReturn);
							}
						}else{
                            System.debug('**************5*****************');
                            //Now even though user selected particular cliet as count is less than 6 we can all generic 
							for(Knowledge__kav ka : [select id,Language,title,summary,masterVersionId,knowledgeArticleId from Knowledge__kav where feature_article__c = true and PublishStatus = 'Online' 
																													and Article_visiblity_for_candidate__c = true 
																													and Applicable_to_all_clients__c = true
																													and Language = 'en_US' AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
																													//and id NOT IN: knowVerIDSet 
																													order by LastPublishedDate DESC limit: noOfRecordsToAddEnUS]){
								articleWrapper aw =  new articleWrapper();
								aw.title = ka.title;
								aw.summary = ka.summary;
								aw.recordId = ka.id;
								aw.masterVersionId = ka.masterVersionId;
								aw.knowledgeArticleId = ka.knowledgeArticleId;
								KnowEngVersionSet.add(ka.knowledgeArticleId);
								wrapperListToReturn.add(aw);
                                System.debug('**************wrapperListToReturn 2*****************'+wrapperListToReturn);
							}
                        }
                    }
                    }
                    System.debug('**************wrapperListToReturn 3*****************'+wrapperListToReturn);
                if(language != 'en_US'){
                    System.debug('**************LANG*****************');
                     //user selects particular client and language is not english
                    wrapperListToReturn.clear(); // Clearing this as it will have Engligh version articles 
                    knowVerIDSet.clear();            
                    System.debug('**************wrapperListToReturn 4*****************'+wrapperListToReturn);
                    for(Knowledge__kav ka : [select id,Language,title,summary,masterVersionId,knowledgeArticleId from Knowledge__kav where knowledgeArticleId IN: KnowEngVersionSet
                                                                                                                and Language =:  language
                                                                                                                and PublishStatus = 'Online' AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
                                                                                                                order by LastPublishedDate DESC limit 6]){
                        articleWrapper aw =  new articleWrapper();
                        aw.title = ka.title;
                        aw.summary = ka.summary;
                        aw.recordId = ka.id;
                        aw.masterVersionId = ka.masterVersionId;
                        aw.knowledgeArticleId = ka.knowledgeArticleId;
                        wrapperListToReturn.add(aw);
                        knowVerIDSet.add(ka.id);            
                    }

//CODE FIX FOR TRANSLATION **********************************************

                    integer returnListSizeLang = wrapperListToReturn.size();
                    system.debug('returnListSizeLang value is :: '+returnListSizeLang);
                    if(returnListSizeLang < 6){

                        integer noOfRecordsToAddLang = 6 - returnListSizeLang;

						//For dupicate bug fix CSH-540
						if(!knowVerIDSet.isEmpty()){
							//Now even though user selected particular cliet as count is less than 6 we can add all generic KAVs
							for(Knowledge__kav ka : [select id,Language,title,summary,masterVersionId,knowledgeArticleId from Knowledge__kav where feature_article__c = true and PublishStatus = 'Online' 
																													and Article_visiblity_for_candidate__c = true 
																													and Applicable_to_all_clients__c = true
																													and Language =:language AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
																													and id NOT IN: knowVerIDSet 
																													order by LastPublishedDate DESC limit: noOfRecordsToAddLang]){
								articleWrapper aw =  new articleWrapper();
								aw.title = ka.title;
								aw.summary = ka.summary;
								aw.recordId = ka.id;
								aw.masterVersionId = ka.masterVersionId;
								aw.knowledgeArticleId = ka.knowledgeArticleId;
								//KnowEngVersionSet.add(ka.knowledgeArticleId);
								wrapperListToReturn.add(aw);
                                System.debug('**************wrapperListToReturn 1*****************'+wrapperListToReturn);
							}
						}else{
                            //Now even though user selected particular cliet as count is less than 6 we can all generic 
							for(Knowledge__kav ka : [select id,Language,title,summary,masterVersionId,knowledgeArticleId from Knowledge__kav where feature_article__c = true and PublishStatus = 'Online' 
																													and Article_visiblity_for_candidate__c = true 
																													and Applicable_to_all_clients__c = true
																													and Language =:language AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName
																													//and id NOT IN: knowVerIDSet 
																													order by LastPublishedDate DESC limit: noOfRecordsToAddLang]){
								articleWrapper aw =  new articleWrapper();
								aw.title = ka.title;
								aw.summary = ka.summary;
								aw.recordId = ka.id;
								aw.masterVersionId = ka.masterVersionId;
								aw.knowledgeArticleId = ka.knowledgeArticleId;
								//KnowEngVersionSet.add(ka.knowledgeArticleId);
								wrapperListToReturn.add(aw);
                                System.debug('**************wrapperListToReturn 2*****************'+wrapperListToReturn);
							}
                        }
                    
                    }
//CODE FIX FOR TRANSLATION **********************************************
                }
                System.debug('**************wrapperListToReturn Final Language *****************'+wrapperListToReturn);
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