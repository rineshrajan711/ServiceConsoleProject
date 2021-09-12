({
    getContactRecord : function(component, event, helper) {
        var chatId = component.get('v.recordId');
        console.log('ID:::'+chatId);
        var action = component.get('c.getContactFromId');
        action.setParams({ 
            "chatId" : chatId 
        });
        action.setCallback(this, function(response){
            component.set('v.record', response.getReturnValue());
        });
     $A.enqueueAction(action);
    }
})