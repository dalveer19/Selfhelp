public without sharing class ArticleController {

    public class ArticleDetailsWrapper {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String Title { get; set; }
        @AuraEnabled public String Summary { get; set; }
        @AuraEnabled public String Candidatesection { get; set; }
        @AuraEnabled public Datetime LastPublishedDate { get; set; }
        @AuraEnabled public Boolean isVisibleToPublic { get; set; }
        @AuraEnabled public String articleText { get; set; }
        @AuraEnabled public List<String> clients{ get; set; }
        @AuraEnabled public Boolean invalidLangError { get; set; }
        @AuraEnabled public List<String> validLanguages{ get; set; }

        public ArticleDetailsWrapper(Knowledge__kav article, Boolean isVisibleToPublic, String articleText, List<String> clients){
            this.Id = article.Id;
            this.Title = article.Title;
            this.Summary = article.Summary;
            this.Candidatesection = article.Candidate_s_Section__c;
            this.LastPublishedDate = article.LastPublishedDate;
            this.isVisibleToPublic = isVisibleToPublic;
            this.articleText = articleText;
            this.clients = clients;
        }

        public ArticleDetailsWrapper(Boolean invalidLangError, List<String> validLanguages){
            this.invalidLangError = invalidLangError;
            this.validLanguages = validLanguages;
        }
    }

    @AuraEnabled(cacheable=true)
    public static ArticleDetailsWrapper getKnowledgeArticleDetails(String recordId, String language){

        List<String> clients = new List<String>();
        Knowledge__kav langArticle = new Knowledge__kav();
        List<String> validLanguages = new List<String>();
        Boolean invalidLangError = false;

        Knowledge__kav article = 
                [   SELECT KnowledgeArticleId
                    FROM Knowledge__kav 
                    WHERE Id =: recordId 
                    AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName 
                    LIMIT 1
                ];
        try{
            langArticle = 
                [   SELECT  Id, KnowledgeArticleId, Title, Summary, Candidate_s_Section__c, LastPublishedDate, Public_content__c, Applicable_to_all_clients__c 
                    FROM Knowledge__kav 
                    WHERE KnowledgeArticleId =: article.KnowledgeArticleId 
                    AND Language =: language 
                    AND PublishStatus = 'Online'  
                    LIMIT 1
                ];
        }
        catch(Exception e){
            String errorMsg = e.getMessage();
            if(errorMsg.contains('List has no rows for assignment to SObject')){
                invalidLangError = true;
                List<Knowledge__kav> validLangArticles = 
                    [
                        SELECT Language
                        FROM Knowledge__kav 
                        WHERE KnowledgeArticleId =: article.KnowledgeArticleId 
                        AND PublishStatus = 'Online'
                        ORDER BY Language
                    ];
                for(Knowledge__kav kav : validLangArticles){
                    validLanguages.add(kav.Language);
                }
            }
            ArticleDetailsWrapper result = new ArticleDetailsWrapper(true, validLanguages);
            return result;
        }
        // Query to retrieve linked clients for the knowledge article
        List<Linked_Client__c> clientsList = 
            [   
                SELECT Id, Client__r.Name, Client__c, Knowledge_Article__c, Knowledge_Article__r.knowledgeArticleId 
                FROM Linked_Client__c  
                WHERE Knowledge_Article__r.knowledgeArticleId=: langArticle.KnowledgeArticleId 
                AND Knowledge_Article__r.PublishStatus='Online' 
                AND Knowledge_Article__r.RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName 
            ];

        // Iterate through linked clients and add them to the clients list
        for(Linked_Client__c singleLC : clientsList){
            if(singleLC.Knowledge_Article__r.knowledgeArticleId == langArticle.knowledgeArticleId){
                if(clientsList.size() <= 2){
                    clients.add((String)singleLC.Client__r.Name);
                } else if(clientsList.size() > 2){
                    clients.add(System.Label.Multiple_Testing_program);
                    break;
                }
            }
        }
        // If the article is tagged to all clients
        if(langArticle.Applicable_to_all_clients__c == true && clients.size() == 0) {
            clients.add(System.Label.All_Testing_Programs);
        }
        
        // Create a wrapper and add to the result list
        Boolean isVisibleToPublic = langArticle.Public_content__c;
        String articleText = isVisibleToPublic ? truncateText(langArticle.Summary, 2) : langArticle.Summary;
        ArticleDetailsWrapper result = new ArticleDetailsWrapper(langArticle, isVisibleToPublic, articleText, clients);
        return result;
    }


    // Apex method to retrieve knowledge article details
    @AuraEnabled(cacheable=true)
    public static List<KnowledgeArticleWrapper> getKnowledgeDetails(String recordId,String language) {
        List<KnowledgeArticleWrapper> result = new List<KnowledgeArticleWrapper>();
        List<String> clients = new List<String>();

        try{

            // Query to retrieve knowledge article details
            Knowledge__kav article = 
                [   SELECT  Id, KnowledgeArticleId, Title, Summary, FAQ_Question__c, FAQ_Answer__c, Candidate_s_Section__c, LastPublishedDate, 
                            Public_content__c, Applicable_to_all_clients__c
                    FROM Knowledge__kav 
                    WHERE Id =: recordId 
                    AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName 
                    LIMIT 1
                ];

            KnowledgeArticleVersion langArticle = 
                [   SELECT Id, KnowledgeArticleId,  Title, Language 
                    FROM KnowledgeArticleVersion 
                    WHERE KnowledgeArticleId =: article.KnowledgeArticleId 
                    AND Language =: language 
                    AND PublishStatus =: 'Online'  
                    LIMIT 1
                ];

            Knowledge__kav articleToDisplay = 
                [
                    SELECT  Id, KnowledgeArticleId, Title, Summary, FAQ_Question__c, FAQ_Answer__c, Candidate_s_Section__c, LastPublishedDate, 
                            Public_content__c, Applicable_to_all_clients__c
                    FROM Knowledge__kav 
                    WHERE Id =: langArticle.Id 
                    AND RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName 
                    LIMIT 1
                ];

            // Query to retrieve linked clients for the knowledge article
            List<Linked_Client__c> clientsList = 
                [   
                    SELECT Id, Client__r.Name, Client__c, Knowledge_Article__c, Knowledge_Article__r.knowledgeArticleId 
                    FROM Linked_Client__c  
                    WHERE Knowledge_Article__r.knowledgeArticleId=: article.KnowledgeArticleId 
                    AND Knowledge_Article__r.PublishStatus='Online' 
                    AND Knowledge_Article__r.RecordType.Name =: SHP_ConstantUtil.KnowledgeRecordTypeName 
                ];

            // Iterate through linked clients and add them to the clients list
            for(Linked_Client__c singleLC : clientsList){
                if(singleLC.Knowledge_Article__r.knowledgeArticleId == article.knowledgeArticleId){
                    if(clientsList.size() <= 2){
                        clients.add((String)singleLC.Client__r.Name);
                    } else if(clientsList.size() > 2){
                        clients.add(System.Label.Multiple_Testing_program);
                        break;
                    }
                }
            }

            // If the article is tagged to all clients
            if(article.Applicable_to_all_clients__c == true && clients.size() == 0) {
                clients.add(System.Label.All_Testing_Programs);
            }

            // Create a wrapper and add to the result list
            Boolean isVisibleToPublic = article.Public_content__c;
            String articleText = isVisibleToPublic ? truncateText(article.Summary, 2) : article.Summary;
            result.add(new KnowledgeArticleWrapper(articleToDisplay, isVisibleToPublic, articleText, clients, false, null));
        }
        catch(Exception e){
           result.add(new KnowledgeArticleWrapper(null, null, null, null, true, e.getMessage()));
        }
        System.debug(result);
        return result;
    }

    // Wrapper class to hold knowledge article details
    public class KnowledgeArticleWrapper {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String Title { get; set; }
        @AuraEnabled public String Summary { get; set; }
        @AuraEnabled public String Question { get; set; }
        @AuraEnabled public String Answer { get; set; }
        @AuraEnabled public String Candidatesection { get; set; }
        @AuraEnabled public Datetime LastPublishedDate { get; set; }
        @AuraEnabled public Boolean isVisibleToPublic { get; set; }
        @AuraEnabled public String articleText { get; set; }
        @AuraEnabled public List<String> clients{ get; set; }
        @AuraEnabled public Boolean hasError{ get; set; }
        @AuraEnabled public String errorMsg{ get; set; }


        // Constructor to initialize the wrapper with article details
        public KnowledgeArticleWrapper(Knowledge__kav article, Boolean isVisibleToPublic, String articleText, List<String> clients, Boolean hasError, String errorMsg) {
            if(hasError){
                this.hasError = hasError;
                this.errorMsg = errorMsg;
            }
            else{
                this.Id = article.Id;
                this.Title = article.Title;
                this.Summary = article.Summary;
                this.Question = article.FAQ_Question__c;
                this.Answer = article.FAQ_Answer__c;
                this.Candidatesection = article.Candidate_s_Section__c;
                this.LastPublishedDate = article.LastPublishedDate;
                this.isVisibleToPublic = isVisibleToPublic;
                this.articleText = articleText;
                this.clients = clients;
            }
        }
    }

    // Utility method to truncate text to a specified number of lines
    private static String truncateText(String inputText, Integer numLines) {
        List<String> lines = inputText.split('\n');
        String truncatedText = '';       
        for (Integer i = 0; i < Math.min(numLines, lines.size()); i++) {
            truncatedText += lines[i] + '\n';
        }       
        return truncatedText;
    }

}