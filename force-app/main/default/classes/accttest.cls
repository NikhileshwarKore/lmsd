public class accttest {
  public List<Account> queryAccounts(){
    List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 10];
    for(Account a : accounts){
      System.debug(a.Name);
    }
    return accounts;
  }
}