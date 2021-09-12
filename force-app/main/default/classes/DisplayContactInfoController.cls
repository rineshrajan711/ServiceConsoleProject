public class DisplayContactInfoController {
@AuraEnabled
    public static Contact getContactFromId(Id chatId){
        Set<id> conid = new Set<id>();
        List<LiveChatTranscript> LChat = [SELECT ContactId,id FROM LiveChatTranscript WHERE Id=:chatId];
        system.debug('Livechatid::'+LChat);
        //if(LChat != null && !LChat.isEmpty()) {
            
        for(LiveChatTranscript LC: LChat){
            conid.add(LC.ContactId);
        }
        
        List<Contact> conlist = [SELECT id, Product__c, Home_Country__c FROM contact WHERE Id IN:conid];
            system.debug('Contact::'+conlist);
        //}    
        return conlist[0];
}
}