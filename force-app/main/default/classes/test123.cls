public class test123 {
    public static void display(){
        
        integer caseid;
        string names;
        system.debug(caseid);
        system.debug(names);
        
         system.debug('integer-----'+caseid);
        system.debug('vinod-----'+names);
        
        caseid = 100;
        names= 'stignf,dddd';
    system.debug('integer-----'+caseid);
        system.debug('vinod-----'+names);
        
    }
          public static void maths(){
              
 decimal number1,number2,sum,mult,div,sub;
              number1=300;
         number2=200;
              
             sum = number1 + number2;
              system.debug('sum of two number'+sum);
              
            sub  = number1 - number2;
              system.debug('sub of two number'+sub);
           div  = number1 / number2;
              system.debug('div of two number'+div);
        mult  = number1 * number2;
              system.debug('mult of two number'+mult);  
              
              if(number2>number1)
              {
                  
                                system.debug('mult of two number'+mult);  

              }
              else{
                  system.debug('number 2 is not small so no execution');
              }
                if(number2<number1)
              {
                  
                                system.debug('mult of two number'+mult);  

              }

          }
    

              public static void seasons(){
      integer monthnumber;
                  
                  monthnumber=10;
                      
                      if(monthnumber>1&& monthnumber<=4){
                          system.debug('this is a jan,feb,march');
                              
                      }
                        else if (monthnumber >= 4 && monthnumber<6){
                          system.debug('this is a apr,fmayeb,june');
                              
                      }
                       else if (monthnumber >= 6 && monthnumber<12){
                          system.debug('june -december');
                              
                      }
                  else {
                          system.debug('cant recognize ');
}
    
}
    
    public static void results (){

decimal telugu,hindi,english,maths,science,total,average;
    
        telugu=90;
       hindi=89;
        english=90;
        maths=95;
        science=9;
        total=telugu+hindi+english+maths+science;
        average=total/5;
       
        
        if(telugu>= 60 && hindi>= 60 && english>= 60 && maths>= 60 && science>= 60 ){
                        system.debug('congratulations you are passed. ');

            system.debug('you are passed., your total marks are'+total);
            
            if (average >= 60){
                                    system.debug('you are passed., your grade is A '+average);

        }
            if (average >=50 && average <= 59){
                                    system.debug('you are passed., your grade is B '+average);

        }
            if (average >=40 && average <= 49){
                                    system.debug('you are passed., your grade is c '+average);

        }
        }
        else {
            system.debug('sorrry you are FAILED' );
        }
    
        

    
    }

}