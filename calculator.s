mem_fault: halt
;io_handle: jump getchar

;Arrian Purcell u5015666 ANU Comp2300 Semester 1 2012

;In general:
;R0 - char i = 0;
;R1 - int startOfWord = 1;//where 1 is true and 0 is false
;R2 - int gotMinus = 0;
;R3 - ;
;R4 - int integer = 0;
;R5 - inputComparison (eg. + - etc)
;R6 - pop1
;R7 - void, temp and pop2

0x0100: load #1 R1;start of word = true
main:   load 0xfff1 R0
        jumpnz R0 getchar
        jump main
        

;i = getchar()
getchar: load 0xfff0 R0 ;loading char into register
         ;store R0 0xfff0 ;debug outputting char to screen
         
;    if(i == '\n')
;    {
;      if(stackPointer == 0) exit(1);
;      else 
;      {
;        if(gotMinus == 1)//subtract
;        {
;          stack[stackPointer - 2] -= stack[stackPointer - 1];
;          gotMinus = 0;
;          pop();
;        }
;        printf("answer: %d\n", stack[0]);//output answer
;        pop();//clearing stack
;        startOfWord = 1;//begin new line
;        integer = 0;//clear integer. not sure if necessary
;      }
;    }
newline:   load #'\n' R5
           sub R0 R5 R5
           jumpnz R5 space
checkinteger:jumpz R4 checkstack;no new number
             jumpz R2 pushnew;no negation sign
             mult R4 MONE R4;negate
             ;load #0 R2;dealt with negate
pushnew:     push R4;integer was found at end of line
             jump notminus;stack has entry so don't halt and dealt with negative
checkstack:load #0x7000 R6;stopping only if stack is empty
           move SP R7;get stack pointer
           sub R6 R7 R7;check if stack has items
           jumpnz R7 nohalt
           halt
nohalt:    jumpz R2 notminus
           pop R6
           pop R7
           sub R7 R6 R7;perform end of line subtraction
           push R7
           ;load #0 R2;got minus = false
notminus:  pop R7;put answer into R7
display:   load #'0' R1;displaying integer in R7 as chars
dcheckneg: jumpn R7 displayneg
           jump displaynum
displayneg:load #'-' R5;displaying negative sign
           store R5 0xfff0
           mult R7 MONE R7;negate;not sure if necessary
displaynum:load thousandmillion R3;maximum required display int is 2147483647           
           load #10 R2
           load #0 R0;true if the start of the integer has been found
           jump rdisplay
reduce:    div R3 R2 R3
           sub R3 ONE R6
           jumpz R6 complete;found ones column so complete
rdisplay:  div R7 R3 R6
           jumpnz R0 jumpcheck;number found already so display all 0's
           jumpz R6 reduce
jumpcheck: add R1 R6 R6
           store R6 0xfff0
           mod R7 R3 R7
           load #1 R0
           jump reduce
complete:  add R1 R7 R7;displaying ones column
           store R7 0xfff0
           load #'\n' R1
           store R1 0xfff0;newline
reset:     load #1 R1;start of word = true
           load #0 R2;got minus = false
           load #0 R4;integer = 0
           ;load #0x7000 SP;reset stack
           jump main

;    else if(i == ' ')
;    {
;      if(startOfWord == 0)
;      {
;        if(gotMinus == 1)//not sure if this block should be here
;        {
;          gotMinus = 0;
;          integer *= -1;//handling minus sign
;        }
;        push(integer);//set top of stack to integer
;        startOfWord = 1;
;        integer = 0;
;      }
;      
;      if(gotMinus == 1)//subtract
;      {
;        stack[stackPointer - 2] -= stack[stackPointer - 1];
;        gotMinus = 0;
;        pop();
;      }
;    }
space:    load #' ' R5
          sub R0 R5 R5
          jumpnz R5 add
          ;to succeed in pushing int R1=0
checkword:jumpnz R1 checksub;if not start of word then push integer
checkneg: jumpz R2 pushint;if got minus then negate integer
          load #0 R2;got minus = false
          mult R4 MONE R4;negate integer
pushint:  push R4;push integer
          load #1 R1;start of word = true
          load #0 R4;integer = 0
checksub: jumpz R2 main;if got minus then perform subtraction
          pop R6
          pop R7
          sub R7 R6 R7
          push R7
          load #0 R2;got minus = false           
          jump main
       
;    else if(i == '+') 
;    { 
;      stack[stackPointer - 2] += stack[stackPointer - 1];
;      pop();
;    }
add: load #'+' R5
     sub R0 R5 R5
     jumpnz R5 sub
     pop R6
     pop R7
     add R7 R6 R7
     push R7
     jump main

;    else if(i == '-') gotMinus = 1;      
sub: load #'-' R5
     sub R0 R5 R5
     jumpnz R5 mul
     load #1 R2;got minus = true
     jump main
     
;    else if(i == '*') 
;    {
;      stack[stackPointer - 2] *= stack[stackPointer - 1];
;      pop();
;    }
mul: load #'*' R5
     sub R0 R5 R5
     jumpnz R5 div
     pop R6
     pop R7
     mult R7 R6 R7
     push R7
     jump main

;    else if(i == '/')
;    {    
;      stack[stackPointer - 2] /= stack[stackPointer - 1];
;      pop();
;    }
div: load #'/' R5
     sub R0 R5 R5
     jumpnz R5 rem
     pop R6
     pop R7
     div R7 R6 R7
     push R7
     jump main

;    else if(i == '%') 
;    {
;      stack[stackPointer - 2] %= stack[stackPointer - 1];
;      pop();
;    }
rem: load #'%' R5
     sub R0 R5 R5
     jumpnz R5 pow
     pop R6
     pop R7
     mod R7 R6 R7
     push R7
     jump main

     

;    else if(i == '^')
;    {
;      push(stack[stackPointer - 2]);//power function needs to retain original value
;      power();
;      pop();
;      pop();
;    }
pow: load #'^' R5
     sub R0 R5 R5
     jumpnz R5 fac
     pop R6;iter
     sub R6 ONE R6;need 1 less multiplication than given
     pop R5;original base
     move R5 R7;final value
     jumpz R7 rpowdone;zero base, return 0
;void power()
;{
;  //stack - 3 = var = R7
;  //stack - 2 = iter = R6
;  //stack - 1 = original base = R5
;  //temp = R3
;  
;  if(stack[stackPointer - 2] == 1) return;//finished power
;  
;  stack[stackPointer - 3] *= stack[stackPointer - 1];
;  stack[stackPointer - 2] -= 1;
;  power();
;}
rpow:jumpz R6 rpowdone
     mult R7 R5 R7
     jumpz R7 zeropow
     sub R6 ONE R6
     jump rpow
zeropow: load #1 R7;if the power is zero then need a one on stack
rpowdone: push R7
          jump main
        
;    else if(i == '!') 
;    {
;      push(1);//iter
;      push(stack[stackPointer - 2]);//retain original value as target iter
;      stack[stackPointer - 3] = 1;//need to start the factorial at one
;      factorial();
;      pop();//only need two pops because factorial takes one argument
;      pop();
;    }
fac: load #'!' R5
     sub R0 R5 R5
     jumpnz R5 zerohandle;not a useful character so must be part of a number
     load #1 R6
     load #1 R7;final value
     pop R5
     jumpnz R5 rfac;need to return a zero if zero given
     push R5
     jump main
;void factorial()
;{
;  //stack - 3 = var = R7
;  //stack - 2 = iter = R6
;  //stack - 1 = target = R5
;  //temp = R3
;  
;  //Important: factorial zero must result in 0 not 1
;
;  if((stack[stackPointer - 1] - stack[stackPointer - 2]) < 0) return;//finished factorial
;  printf("var: %d iter: %d target: %d\n", stack[stackPointer - 3], stack[stackPointer - 2], stack[stackPointer - 1]);
;  stack[stackPointer - 3] *= stack[stackPointer - 2];
;  stack[stackPointer - 2] += 1;
;  factorial();
;}
rfac: sub R5 R6 R3
      add ONE R3 R3;temp debug
      jumpz R3 rfacdone
      mult R7 R6 R7
      add R6 ONE R6;increase multiplier
      jump rfac
rfacdone:push R7
         jump main


     
;Got zero on first char so push zero to stack
zerohandle: jumpnz R4 num;integer has contents...handle normally
            load #'0' R5
            sub R0 R5 R5
            jumpnz R5 num
            push ZERO;zero needs to be on the stack
            jump main
     
;    else 
;    {
;      integer = integer * 10 + (i - 48);
;      startOfWord = 0;
;    }
num: load #'0' R5
     sub R0 R5 R5;convert char to int
     load #10 R7;promote current integer by factor of ten
     mult R4 R7 R4
     add R4 R5 R4;combine promoted integer and input integer
     load #0 R1;start of integer = false
     jump main
          
thousandmillion: block #1000000000