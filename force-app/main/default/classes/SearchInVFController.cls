public class SearchInVFController {
	public List<wrapAccount> acc {get;set;}
    public String searchKey {get;set;}

    public SearchInVFController() {}

    public void search(){
        List<List<SObject>> searchList = [FIND :searchKey IN NAME FIELDS 
                                      RETURNING Account(ID, Name, Counter__c), Contact(ID, Name, Counter__c)];

        Account[] searchAccounts = (Account[])searchList[0];
        Contact[] searchContacts = (Contact[])searchList[1];

        acc = new List<wrapAccount>();
        for (Account a : searchAccounts) {
            acc.add(new wrapAccount(a.Name, 'Account', a.ID, a.Counter__c));
        }

        for (Contact c : searchContacts) {
            acc.add(new wrapAccount(c.Name, 'Contact', c.ID, c.Counter__c));
        }
    }

    public void clear(){
        acc.clear();
    }

    @RemoteAction
    public static Decimal increment(Id rcID) {
        String sObjName = rcID.getSObjectType().getDescribe().getName();
        Decimal result = 0;
        
        if (sObjName == 'Account') {
            Account acc = [Select Id, Counter__c from Account where Id = :rcID];
            
            Decimal counter = acc.Counter__c == NULL ? 0 : acc.Counter__c;
            acc.Counter__c = result = counter + 1;

            update acc;
        }

        if (sObjName == 'Contact') {
            Contact acc = [Select Id, Counter__c from Contact where Id = :rcID];
            
            Decimal counter = acc.Counter__c == NULL ? 0 : acc.Counter__c;
            acc.Counter__c = result = counter + 1;

            update acc;
        }

        return result;
    }
    
    public class wrapAccount {
        public String name {get; set;}
        public String rcType {get; set;}
        public ID rcId {get; set;}
        public Decimal rcCounter {get; set;}
 
        public wrapAccount(String name, String rcType, ID rcID, Decimal rcCounter) {
            this.name = name;
            this.rcType = rcType;
            this.rcId = rcId;
            this.rcCounter = rcCounter != NULL ? rcCounter : 0;
        }
    }
}