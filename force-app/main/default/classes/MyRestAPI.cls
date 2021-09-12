@RestResource(urlMapping='/salesforceprodinfo1/')
global class MyRestAPI {
    @HttpGet
    global static void productInfo(){
        Map<string, string> paramsMap = RestContext.request.params;	
        RestResponse res = RestContext.response;
        if (res == null) {
        	res = new RestResponse();
        	RestContext.response = res;
    	}
        string uuId = paramsMap.get('Id');
        String productInfo = '';
        String countryInfo = '';
        
        try{
        Product_Management__c mapProdInfo = new Product_Management__c();
        Contact conlist = [SELECT id,Name,Email, Product__c,Home_Country__c,UUID__c 
                           FROM Contact 
                           WHERE UUID__c =: uuId LIMIT 1];
        
        if(conlist != null) {
            productInfo = conlist.Product__c;
            countryInfo = conlist.Home_Country__c;
            
            mapProdInfo = [ SELECT  ATM_Fee_in_other_currencies__c,Card_Replacement_Cost__c,Cost_per_Calendar_Month__c,
                                       Country__c,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,
                                       LastReferencedDate,LastViewedDate,Name,OwnerId,SystemModstamp,Unique_Id__c 
                            FROM Product_Management__c WHERE   Country__c = :countryInfo AND Name = :productInfo LIMIT 1];
            
            Map<String, Object> cfn = parse(conlist,mapProdInfo);
            
            res.responseBody = Blob.valueOf(JSON.serializepretty(cfn));
        	res.statusCode = 200;
        }
        }catch(Exception e){
            res.responseBody = Blob.valueOf('Error: '+e.getMessage());
        	res.statusCode = 400;
        }
    }
      
    public static Map<String,Object> parse(Contact contInfo,Product_Management__c mapProdInfo ) {
        
        Map<String,Object> cProdInfo =  new Map<String,Object>();
        cProdInfo.put('contactName',contInfo.Name);
        cProdInfo.put('email',contInfo.email);
        cProdInfo.put('product',contInfo.Product__c);
        cProdInfo.put('homeCountry',contInfo.Home_Country__c);
        cProdInfo.put('costPerCalendarMonth',mapProdInfo.Cost_per_Calendar_Month__c);
        cProdInfo.put('atmFeeInOtherCurrencies', mapProdInfo.ATM_Fee_in_other_currencies__c);
        cProdInfo.put('cardReplacementCost', mapProdInfo.Card_Replacement_Cost__c);
        return cProdInfo;
    }
}