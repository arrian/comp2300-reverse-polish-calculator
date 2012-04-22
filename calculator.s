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
         load #0x0200 R3
         add R0 R3 R3
         move R3 PC;jump to ascii lookup table
         
;static ascii input lookup table 
0x020a:jump newline
0x0220:jump space
0x0221:jump fac
0x0225:jump rem
0x022a:jump mul
0x022b:jump add
0x022d:jump sub
0x022f:jump div
0x0230:jump zero
0x0231:jump num
0x0232:jump num
0x0233:jump num
0x0234:jump num
0x0235:jump num
0x0236:jump num
0x0237:jump num
0x0238:jump num
0x0239:jump num
0x025e:jump pow
         
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
newline:   
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
space:    jumpnz R1 checksub;if not start of word then push integer
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
add: pop R6
     pop R7
     add R7 R6 R7
     push R7
     jump main

;    else if(i == '-') gotMinus = 1;      
sub: load #1 R2;got minus = true
     jump main
     
;    else if(i == '*') 
;    {
;      stack[stackPointer - 2] *= stack[stackPointer - 1];
;      pop();
;    }
mul: pop R6
     pop R7
     mult R7 R6 R7
     push R7
     jump main

;    else if(i == '/')
;    {    
;      stack[stackPointer - 2] /= stack[stackPointer - 1];
;      pop();
;    }
div: pop R6
     pop R7
     div R7 R6 R7
     push R7
     jump main

;    else if(i == '%') 
;    {
;      stack[stackPointer - 2] %= stack[stackPointer - 1];
;      pop();
;    }
rem: pop R6
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
pow: pop R6;iter
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
fac: pop R7
     load #factoriallookup R6;loading factorial from lookup table
     add R6 R7 R7
     load R7 R7
     push R7
     jump main


     
;Got zero on first char so push zero to stack
zero: jumpnz R4 num;integer has contents...handle normally
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

factoriallookup: block #0;0!
                 block #1
                 block #2
                 block #6
                 block #24
                 block #120
                 block #720
                 block #5040
                 block #40320
                 block #362880
                 block #3628800
                 block #39916800
                 block #479001600;12!