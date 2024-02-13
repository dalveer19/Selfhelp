public with sharing class SHP_KnowledgeSearchResultsController {

    public class searchSuggestionsKnowledgeWrapper{
        @AuraEnabled public List<resultsWrapper> searchResultsList;
        @AuraEnabled public String errorMsg;
    }
    public class resultsWrapper{
        @AuraEnabled public Knowledge__kav searchResult;
        // @AuraEnabled public List<dcWrapper> dataCategoriesList; 
        @AuraEnabled public String clientName;
    }
    public class dcWrapper{
        @AuraEnabled public String dcLabel;
        @AuraEnabled public String dcName;
    }
    public class emptySOSLResultException extends Exception {}

    @AuraEnabled
    public static searchSuggestionsKnowledgeWrapper getKnowledgeSearchSuggestionResults(String searchKey,String language, String clientCode, String categoryName, Boolean additionalInfoRequired){
        
        searchSuggestionsKnowledgeWrapper sskw = new searchSuggestionsKnowledgeWrapper();
        String searchQuery = 'FIND';
        String escaped_SearchKey = String.escapeSingleQuotes(searchKey);
        String escaped_Language = String.escapeSingleQuotes(language);
        searchQuery +=  ' \'' + escaped_SearchKey + '\'' +
                        ' IN ALL FIELDS' + 
                        ' RETURNING Knowledge__kav(' + 
                        ' Id, Title, Summary, knowledgeArticleId' +
                        ' WHERE PublishStatus = \'Online\' AND Language =' +
                        ' \'' + escaped_Language + '\'' +
                        ' AND Article_visiblity_for_candidate__c = true  AND RecordType.Name = ' +
                        ' \'' + SHP_ConstantUtil.KnowledgeRecordTypeName + '\'';
        String allArticlesSQ = searchQuery + ' AND Applicable_to_all_clients__c=false)';
        String allClientsArticlesSQ = searchQuery + ' AND Applicable_to_all_clients__c=true)';
        if(categoryName!='' && categoryName!=null){
            String categoriesString = ' WITH DATA CATEGORY Candidate__c BELOW (' + categoryName + '__c)';
            allArticlesSQ += categoriesString;
            allClientsArticlesSQ += categoriesString;
            System.debug(allArticlesSQ);
            System.debug(allClientsArticlesSQ);
            try{
                List<Knowledge__kav> allClientsArticles = search.query(allClientsArticlesSQ)[0];
                System.debug('allClientsArticles : '  + allClientsArticles);
                Set<Id> articleMasterVersionIdSet = new Set<Id>();
                for(Knowledge__kav article : allClientsArticles){
                    articleMasterVersionIdSet.add(article.knowledgeArticleId);
                }
                if(clientCode!=null && clientCode!=''){
                    sskw = getClientSpecificSSKW(articleMasterVersionIdSet, allArticlesSQ, allClientsArticles, clientCode, additionalInfoRequired);
                }else{
                    if(allClientsArticles.size()<=0){
                        throw new emptySOSLResultException(SHP_ConstantUtil.emptySOSLResultExceptionMsg);
                    }
                    else{
                        sskw = getClientNonSpecificSSKW(articleMasterVersionIdSet, allArticlesSQ, allClientsArticles, additionalInfoRequired);
                    }
                }
            }catch(Exception e){
                String errorMsg = 'Exception :'+ e.getLineNumber() + ' --> ' + e.getMessage();
                System.debug(errorMsg);
                sskw.errorMsg = errorMsg;
            }
        }else{
            try{
                List<Knowledge__kav> allClientsArticles = search.query(allClientsArticlesSQ)[0];
                Set<Id> articleMasterVersionIdSet = new Set<Id>();
                for(Knowledge__kav article : allClientsArticles){
                    articleMasterVersionIdSet.add(article.knowledgeArticleId);
                }
                if(clientCode!=null && clientCode!=''){
                    sskw = getClientSpecificSSKW(articleMasterVersionIdSet, allArticlesSQ, allClientsArticles, clientCode, additionalInfoRequired);
                }
                else{
                    if(allClientsArticles.size()<=0){
                        throw new emptySOSLResultException(SHP_ConstantUtil.emptySOSLResultExceptionMsg);
                    }
                    else{
                        sskw = getClientNonSpecificSSKW(articleMasterVersionIdSet, allArticlesSQ, allClientsArticles, additionalInfoRequired);
                    }
                }
            }catch(Exception e){
                String errorMsg = 'Exception :'+ e.getLineNumber() + ' --> ' + e.getMessage();
                sskw.errorMsg = errorMsg;
            }
        }
        return sskw;
    }
    public static searchSuggestionsKnowledgeWrapper getClientSpecificSSKW(Set<Id> articleMasterVersionIdSet, String allArticlesSQ, List<Knowledge__kav> allClientsArticles, String clientCode, Boolean additionalInfoRequired){
        searchSuggestionsKnowledgeWrapper sskw = new searchSuggestionsKnowledgeWrapper();
        sskw.searchResultsList = new List<resultsWrapper>();
        try{
            List<Knowledge__kav> allArticles = search.query(allArticlesSQ)[0];
            Set<Id> tempIdSet_allArticles = new Set<Id>();
            for(Knowledge__kav article : allArticles){
                tempIdSet_allArticles.add(article.knowledgeArticleId);
            }
            Id clientId = shp_accountUtility.getAccountId(clientCode);
            List<Linked_Client__c> linkedClientList = [SELECT Client__r.Name, Knowledge_Article__r.knowledgeArticleId FROM Linked_Client__c WHERE Client__c =:clientId AND  Knowledge_Article__r.knowledgeArticleId IN :tempIdSet_allArticles AND Knowledge_Article__r.RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName ];
            for(Linked_Client__c clientArticle : linkedClientList){
                articleMasterVersionIdSet.add(clientArticle.Knowledge_Article__r.knowledgeArticleId);
            }
            if(articleMasterVersionIdSet.size()<=0){
                throw new emptySOSLResultException(SHP_ConstantUtil.emptySOSLResultExceptionMsg);
            }
            // Additional Information Required - For Search Results
            if(additionalInfoRequired){
                // Data Categories Map Creation
                // List<Knowledge__DataCategorySelection> dataCategories = [SELECT Id, Parent.KnowledgeArticleId, ParentId, DataCategoryName FROM Knowledge__DataCategorySelection WHERE Parent.KnowledgeArticleId IN : articleMasterVersionIdSet];
                // List<Knowledge__DataCategorySelection> dataCategoriesLabels = [SELECT Id, Parent.KnowledgeArticleId, ParentId, toLabel(DataCategoryName) FROM Knowledge__DataCategorySelection WHERE Parent.KnowledgeArticleId IN : articleMasterVersionIdSet];
                // Map<String,String> dataCategoriesMap = new Map<String,String>();
                // for(Knowledge__DataCategorySelection dc1 : dataCategories){
                //     for(Knowledge__DataCategorySelection dc2 : dataCategoriesLabels){
                //         if(dc1.Id == dc2.Id){
                //             dataCategoriesMap.put(dc1.DataCategoryName,dc2.DataCategoryName);
                //         }
                //     }
                // }
                List<Linked_Client__c> allLinkedClientsList = [SELECT Client__r.Name, Knowledge_Article__r.knowledgeArticleId FROM Linked_Client__c WHERE  Knowledge_Article__r.knowledgeArticleId IN :tempIdSet_allArticles  AND Knowledge_Article__r.PublishStatus='Online' AND Knowledge_Article__r.RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName];
                List<resultsWrapper> searchResultsList_clientSpecific = new List<resultsWrapper>();
                List<resultsWrapper> searchResultsList_allClients = new List<resultsWrapper>();
                // Applicable to all clients = false
                for(Knowledge__kav article : allArticles){
                    if(articleMasterVersionIdSet.contains(article.knowledgeArticleId)){
                        resultsWrapper rw = new resultsWrapper();
                        rw.searchResult = article;
                        String clientName = '';
                        List<String> clientNameList = new List<String>();
                        for(Linked_Client__c linkedClient : allLinkedClientsList){
                            if(linkedClient.Knowledge_Article__r.knowledgeArticleId == article.knowledgeArticleId){
                                
                                System.debug('linkedClient.Knowledge_Article__r.knowledgeArticleId ' + linkedClient.Knowledge_Article__r.knowledgeArticleId);
                                System.debug('article.knowledgeArticleId ' + article.knowledgeArticleId);
                                System.debug('linkedClient.Client__r.Name ' + linkedClient.Client__r.Name);

                                if(clientNameList.size()==0){
                                    clientNameList.add(linkedClient.Client__r.Name);
                                }
                                else if(clientNameList.size()==1){
                                    clientNameList.add(linkedClient.Client__r.Name);
                                }
                                else{
                                    clientNameList = new List<String>();
                                    clientNameList.add(System.Label.Multiple_Programs);
                                    break;
                                }
                            }
                        }
                        if(clientNameList.size()==1){
                            rw.clientName = clientNameList[0];
                        }
                        if(clientNameList.size()==2){
                            rw.clientName = clientNameList[0] + '; ' + clientNameList[1];
                        }
                        // rw.dataCategoriesList = new List<dcWrapper>();
                        // for(Knowledge__DataCategorySelection kdcs : dataCategories){
                        //     if(kdcs.Parent.KnowledgeArticleId == article.knowledgeArticleId){
                        //         dcWrapper dcw = new dcWrapper();
                        //         dcw.dcName = kdcs.DataCategoryName;
                        //         dcw.dcLabel = dataCategoriesMap.get(kdcs.DataCategoryName);
                        //         rw.dataCategoriesList.add(dcw);
                        //     }
                        // }
                        searchResultsList_clientSpecific.add(rw);
                    }
                }
                // Applicable to all clients =  true
                for(Knowledge__kav article : allClientsArticles){
                    resultsWrapper rw = new resultsWrapper();
                    rw.searchResult = article;
                    rw.clientName = System.Label.All_Programs;
                    // rw.dataCategoriesList = new List<dcWrapper>();
                    // for(Knowledge__DataCategorySelection kdcs : dataCategories){
                    //     if(kdcs.Parent.KnowledgeArticleId == article.knowledgeArticleId){
                    //         dcWrapper dcw = new dcWrapper();
                    //         dcw.dcName = kdcs.DataCategoryName;
                    //         dcw.dcLabel = dataCategoriesMap.get(kdcs.DataCategoryName);
                    //         rw.dataCategoriesList.add(dcw);
                    //     }
                    // }
                    searchResultsList_allClients.add(rw);
                }
                sskw.searchResultsList.addAll(searchResultsList_clientSpecific);
                sskw.searchResultsList.addAll(searchResultsList_allClients);
            }
            // No Additional Information - For Suggestions
            else{
                for(Knowledge__kav article : allArticles){
                    if(articleMasterVersionIdSet.contains(article.knowledgeArticleId)){
                        resultsWrapper rw = new resultsWrapper();
                        rw.searchResult = article;
                        sskw.searchResultsList.add(rw);
                    }
                }
                for(Knowledge__kav article : allClientsArticles){
                    resultsWrapper rw = new resultsWrapper();
                    rw.searchResult = article;
                    sskw.searchResultsList.add(rw);
                }
            }
        }catch(Exception e){
            String errorMsg = 'Exception :'+ e.getLineNumber() + ' --> ' + e.getMessage();
            System.debug(errorMsg);
            sskw.errorMsg = errorMsg;
        }
        return sskw;
    }
    public static searchSuggestionsKnowledgeWrapper getClientNonSpecificSSKW(Set<Id> articleMasterVersionIdSet, String allArticlesSQ, List<Knowledge__kav> allClientsArticles, Boolean additionalInfoRequired){
        searchSuggestionsKnowledgeWrapper sskw = new searchSuggestionsKnowledgeWrapper();
        sskw.searchResultsList = new List<resultsWrapper>();
        try{
            // Additional Information Required - For Search Results
            if(additionalInfoRequired){
                // Data Categories Map Creation
                // List<Knowledge__DataCategorySelection> dataCategories = [SELECT Id, Parent.KnowledgeArticleId, ParentId, DataCategoryName FROM Knowledge__DataCategorySelection WHERE Parent.KnowledgeArticleId IN : articleMasterVersionIdSet];
                // List<Knowledge__DataCategorySelection> dataCategoriesLabels = [SELECT Id, Parent.KnowledgeArticleId, ParentId, toLabel(DataCategoryName) FROM Knowledge__DataCategorySelection WHERE Parent.KnowledgeArticleId IN : articleMasterVersionIdSet];
                // Map<String,String> dataCategoriesMap = new Map<String,String>();
                // for(Knowledge__DataCategorySelection dc1 : dataCategories){
                //     for(Knowledge__DataCategorySelection dc2 : dataCategoriesLabels){
                //         if(dc1.Id == dc2.Id){
                //             dataCategoriesMap.put(dc1.DataCategoryName,dc2.DataCategoryName);
                //         }
                //     }
                // }
                // Applicable to all clients = true
                for(Knowledge__kav article : allClientsArticles){
                    resultsWrapper rw = new resultsWrapper();
                    rw.searchResult = article;
                    rw.clientName = System.Label.All_Programs;
                    // rw.dataCategoriesList = new List<dcWrapper>();
                    // for(Knowledge__DataCategorySelection kdcs : dataCategories){
                    //     if(kdcs.Parent.KnowledgeArticleId == article.knowledgeArticleId){
                    //         dcWrapper dcw = new dcWrapper();
                    //         dcw.dcName = kdcs.DataCategoryName;
                    //         dcw.dcLabel = dataCategoriesMap.get(kdcs.DataCategoryName);
                    //         rw.dataCategoriesList.add(dcw);
                    //     }
                    // }
                    sskw.searchResultsList.add(rw);
                }
            }
            // No Additional Information - For Suggestions
            else{
                System.debug('No Additional Information - For Suggestions ');

                for(Knowledge__kav article : allClientsArticles){
                    System.debug(article.Title);
                    resultsWrapper rw = new resultsWrapper();
                    rw.searchResult = article;
                    sskw.searchResultsList.add(rw);
                }
            }
        }catch(Exception e){
            String errorMsg = 'Exception :'+ e.getLineNumber() + ' --> ' + e.getMessage();
            System.debug(errorMsg);
            sskw.errorMsg = errorMsg;
        }
        return sskw;
    }
    @AuraEnabled
    public static searchSuggestionsKnowledgeWrapper getCategorySpecificArticles(String language, String clientCode, String categoryName){
        searchSuggestionsKnowledgeWrapper sskw = new searchSuggestionsKnowledgeWrapper();
        sskw.searchResultsList = new List<resultsWrapper>();
        String escaped_Language = String.escapeSingleQuotes(language);

        String qs = 'SELECT Id, Title, Summary, KnowledgeArticleId' +
                    ' FROM Knowledge__kav' +
                    ' WHERE PublishStatus = \'Online\' AND Language =' +
                    ' \'' + escaped_Language + '\'' +
                    ' AND Article_visiblity_for_candidate__c = true AND RecordType.Name =' +
                    ' \'' + SHP_ConstantUtil.KnowledgeRecordTypeName + '\'' ;
                        
        String qsAllClients =   qs + 
                                ' AND Applicable_to_all_clients__c=true' +
                                ' WITH DATA CATEGORY Candidate__c BELOW (' + String.escapeSingleQuotes(categoryName) + '__c)' +
                                ' ORDER BY LastPublishedDate DESC';

        String qsClientSpecific =   qs + 
                                    ' AND Applicable_to_all_clients__c=false' +
                                    ' WITH DATA CATEGORY Candidate__c BELOW (' + String.escapeSingleQuotes(categoryName) + '__c)' + 
                                    ' ORDER BY LastPublishedDate DESC';

        try{
            List<Knowledge__kav> allClientArticles = Database.query(qsAllClients);

            if(clientCode!='' && clientCode!=null){

                List<Knowledge__kav> clientSpecificArticles = Database.query(qsClientSpecific);
                Set<Id> kaIdSet = new Set<Id>();
                for(Knowledge__kav ka : clientSpecificArticles){
                    kaIdSet.add(ka.KnowledgeArticleId);
                }

                Set<Id> clientSelectedKAIds = new Set<Id>();
                Id clientId = shp_accountUtility.getAccountId(clientCode);
                List<Linked_Client__c> linkedClientList = [SELECT Client__r.Name, Knowledge_Article__r.KnowledgeArticleId FROM Linked_Client__c WHERE Client__c =:clientId AND  Knowledge_Article__r.KnowledgeArticleId IN :kaIdSet AND Knowledge_Article__r.RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName];
                for(Linked_Client__c lc : linkedClientList){
                        clientSelectedKAIds.add(lc.Knowledge_Article__r.KnowledgeArticleId);
                }

                List<Linked_Client__c> allLinkedClientsList = [SELECT Client__r.Name, Knowledge_Article__r.KnowledgeArticleId FROM Linked_Client__c WHERE  Knowledge_Article__r.KnowledgeArticleId IN :kaIdSet  AND Knowledge_Article__r.PublishStatus='Online' AND Knowledge_Article__r.RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName];

                List<resultsWrapper> searchResultsList_clientSpecific = new List<resultsWrapper>();
                List<resultsWrapper> searchResultsList_allClients = new List<resultsWrapper>();

                for(Knowledge__kav article : clientSpecificArticles){
                    if(clientSelectedKAIds.contains(article.knowledgeArticleId)){
                        resultsWrapper rw = new resultsWrapper();
                        rw.searchResult = article;
                        String clientName = '';
                        List<String> clientNameList = new List<String>();
                        for(Linked_Client__c linkedClient : allLinkedClientsList){
                            if(linkedClient.Knowledge_Article__r.knowledgeArticleId == article.knowledgeArticleId){
                                if(clientNameList.size()==0){
                                    clientNameList.add(linkedClient.Client__r.Name);
                                }
                                else if(clientNameList.size()==1){
                                    clientNameList.add(linkedClient.Client__r.Name);
                                }
                                else{
                                    clientNameList = new List<String>();
                                    clientNameList.add(System.Label.Multiple_Programs);
                                    break;
                                }
                            }
                        }
                        if(clientNameList.size()==1){
                            rw.clientName = clientNameList[0];
                        }
                        if(clientNameList.size()==2){
                            rw.clientName = clientNameList[0] + '; ' + clientNameList[1];
                        }
                        searchResultsList_clientSpecific.add(rw);
                    }
                }
                for(Knowledge__kav article : allClientArticles){
                    resultsWrapper rw = new resultsWrapper();
                    rw.searchResult = article;
                    rw.clientName = System.Label.All_Programs;
                    searchResultsList_allClients.add(rw);
                }
                sskw.searchResultsList.addAll(searchResultsList_clientSpecific);
                sskw.searchResultsList.addAll(searchResultsList_allClients);
            }
            else{
                for(Knowledge__kav article : allClientArticles){
                    resultsWrapper rw = new resultsWrapper();
                    rw.searchResult = article;
                    rw.clientName = System.Label.All_Programs;
                    sskw.searchResultsList.add(rw);
                }            
            }
        }
        catch(Exception e){
            String errorMsg = 'Exception :'+ e.getLineNumber() + ' --> ' + e.getMessage();
            System.debug(errorMsg);
            sskw.errorMsg = errorMsg;
        }
        return sskw;
    }

    public class dataCategoriesFilterWrapper{
        @AuraEnabled public String categoryName;
        @AuraEnabled public String categoryLabel;
        @AuraEnabled public list<subcatNameLabel> subcategoryList;
        @AuraEnabled public String errorMsg;
    }
    public class subcatNameLabel{
        @AuraEnabled public String subcatName;
        @AuraEnabled public String subcatLabel;
    }    
    
    @AuraEnabled(cacheable=true)
    public static list<dataCategoriesFilterWrapper> getDataCategoriesFilter(){
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<Schema.DescribeDataCategoryGroupStructureResult> results;
        List <DataCategoryGroupSobjectTypePair> pairs = new List <DataCategoryGroupSobjectTypePair>();
        list<dataCategoriesFilterWrapper> dcfwList = new list<dataCategoriesFilterWrapper>();
        try {
            List<String> objType = new List<String>();
            objType.add(SHP_ConstantUtil.KnowledgeArticleVersion);
            describeCategoryResult = Schema.describeDataCategoryGroups(objType);
            for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
                if(singleResult.getName()==SHP_ConstantUtil.Candidate){
                    DataCategoryGroupSobjectTypePair pair = new DataCategoryGroupSobjectTypePair();
                    pair.setSobject(SHP_ConstantUtil.KnowledgeArticleVersion);
                    pair.setDataCategoryGroupName(singleResult.getName());
                    pairs.add(pair);
                }
            }
            results = Schema.describeDataCategoryGroupStructures(pairs, false);
            for(DescribeDataCategoryGroupStructureResult result: results){
                DataCategory[] topCategories = result.getTopCategories();
                DataCategory[] allCategories = getAllCategories(topCategories);
                for(DataCategory category : allCategories){
                    if(!category.getName().equalsIgnoreCase(SHP_ConstantUtil.All) && !category.getChildCategories().isEmpty()){
                        dataCategoriesFilterWrapper dcfw = new dataCategoriesFilterWrapper();
                        dcfw.subcategoryList = new list<subcatNameLabel>();
                        dcfw.categoryName = category.getName();
                        dcfw.categoryLabel = category.getLabel();
                        DataCategory [] childCategories = category.getChildCategories();
                        for(DataCategory subcat : childCategories){
                            subcatNameLabel snl = new subcatNameLabel();
                            snl.subcatName = subcat.getName();
                            snl.subcatLabel = subcat.getLabel();
                            dcfw.subcategoryList.add(snl);
                        }
                        dcfwList.add(dcfw);
                    }
                }
            }
            return dcfwList;
        }catch(Exception e){
            dataCategoriesFilterWrapper dcfw = new dataCategoriesFilterWrapper();
            dcfw.errorMsg = e.getLineNumber() + e.getMessage();
            dcfwList.add(dcfw);
            return dcfwList;
        }
    }
    public static DataCategory[] getAllCategories(DataCategory [] categories){
        if(categories.isEmpty()){
            return new DataCategory[]{};
        } else {
            DataCategory [] categoriesClone = categories.clone();
            DataCategory category = categoriesClone[0];
            DataCategory[] allCategories = new DataCategory[]{category};
            categoriesClone.remove(0);
            categoriesClone.addAll(category.getChildCategories());
            allCategories.addAll(getAllCategories(categoriesClone));
            return allCategories;
        }
    }
}