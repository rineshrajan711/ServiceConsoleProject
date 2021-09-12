public class UIElementDataController {
	@AuraEnabled
    public static Object getUIDataInfo(String ComponentName, Map<String, String> filters){
        
        try{
            UI_Management__mdt uiManageData = fetchUIManageMetadata(ComponentName);
            if(uiManageData != null){
               String soqlQuery =  prepareSOQLQuery(uiManageData,filters);
               List<SObject> uiData = Database.query(soqlQuery);
               return prepareUIDataPackage(uiManageData,uiData);
            }else{
            	return handleErrors('Unable to find the UI Configuration');    
            }
            
        }catch(Exception e){
            System.debug('error : '+e);
            return handleErrors(e.getMessage()); 
        }
       
    }
    /* Method Name    : fetchUIManageMetadata
     * Description    : Fetches the custom metadata information which configures the UI
     * Developer Name : Rinesh Rajan
     */
    
    public static UI_Management__mdt fetchUIManageMetadata(String ComponentName){
         UI_Management__mdt uiManageData = [SELECT Id,MasterLabel,Data_Source__c,Format__c,UI_Icon__c,
                                            	(SELECT MasterLabel,Field_API_Name__c,Sort_Order__c,Data_Type__c 
                                            	 FROM UI_Management_Elements__r 
                                                 ORDER BY Sort_Order__c ASC
                                                )
                                           FROM UI_Management__mdt
                                           WHERE MasterLabel =: ComponentName LIMIT 1];
        return uiManageData;
    }
    
    public static String prepareSOQLQuery(UI_Management__mdt uiManageData, Map<String, String> filters ){
        
        String soqlQuery = 'SELECT Id ';
        
        for(UI_Management_Element__mdt uiElements : uiManageData.UI_Management_Elements__r){
                soqlQuery += ', '+ uiElements.Field_API_Name__c ;
        }
        soqlQuery += ' FROM '+ uiManageData.Data_Source__c;

        if(!filters.isEmpty()){
            soqlQuery += ' WHERE ';
            Boolean isFirstFilter = true;
            for(String filterFields : filters.keySet()){
                if(!isFirstFilter){
                    soqlQuery += ' AND ';
                }
                isFirstFilter = false;
           		soqlQuery += filterFields + ' = \'' + String.escapeSingleQuotes(filters.get(filterFields).trim()) + '\' ';
            }
        }
        return soqlQuery;
    }
    
    public static Object prepareUIDataPackage(UI_Management__mdt uiManageData, List<SObject> uiData ){
    	Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('Title',uiManageData.MasterLabel);
        dataMap.put('Format',uiManageData.Format__c);
        dataMap.put('Icon',uiManageData.UI_Icon__c);
        List<Object> data = new List<Object>();
        Map<String,Object> fieldLevelMap = new Map<String,Object>();
        List<Object> columns = new List<Object>();
        Boolean isFirstFilter = true;
        for(SObject dataVal : uiData){        
            for(UI_Management_Element__mdt uiElements : uiManageData.UI_Management_Elements__r){
                if(isFirstFilter){
                    Map<String,Object> columnElements = new Map<String,Object>();
                    columnElements.put('label',uiElements.MasterLabel);
                    columnElements.put('fieldName',uiElements.Field_API_Name__c);
                    columnElements.put('type',uiElements.Data_Type__c);
                    if(uiElements.Data_Type__c == 'currency'){    
                        Map<String,Object> elementAttType = new Map<String,Object>();
                        elementAttType.put('currencyCode','EUR');
                        elementAttType.put('maximumSignificantDigits',5);
                        columnElements.put('typeAttributes',elementAttType);
                    }
                    columns.add(columnElements);
                }
                fieldLevelMap.put(uiElements.Field_API_Name__c, dataVal.get(uiElements.Field_API_Name__c));
            }
			isFirstFilter = false;
			data.add(fieldLevelMap);
        }
        dataMap.put('columns',columns);
        dataMap.put('data',data);
        return dataMap;
    }
    
    public static Object handleErrors(String errorMessage){
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('Title', 'Error');
        dataMap.put('Format', 'Error Message');
        dataMap.put('Message', errorMessage);
        return dataMap;
    }
}