mem_fault: halt
;io_handle: jump getchar

;In general:
;R0 - char i = 0;
;R1 - int startOfWord = 1;//where 1 is true and 0 is false
;R2 - int gotMinus = 0;
;R3 - ;
;R4 - int integer = 0;
;R5 - inputComparison (eg. + - etc)
;R6 - pop1
;R7 - void, temp and pop2

0x0100: load ONE R1;start of word = true
main:   load 0xfff1 R0
        jumpnz R0 getchar
        jump main
        

;i = getchar()
getchar: load 0xfff0 R0 ;loading char into register
         store R0 0xfff0 ;outputting char to screen
         
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
           ;ignoring exit for now
nohalt:    jumpz R2 notminus
           pop R6
           pop R7
           sub R7 R6 R7;check correctness of order
           push R7
           load ZERO R2;got minus = false
notminus:  pop R7;put answer into R7
display:   load #'0' R1;displaying integer in R7 as chars
dcheckneg: jumpn R7 displayneg
           jump displaynum
displayneg:load #'-' R5;displaying negative sign
           store R5 0xfff0
           mult R7 MONE R7;negate
displaynum:load thousandmillion R3;maximum required display int is 2147483647           
           load #10 R2
           load ZERO R0;true if the start of the integer has been found
           jump rdisplay
reduce:    div R3 R2 R3
           sub R3 ONE R6
           jumpz R6 complete;found a one so complete
rdisplay:  div R7 R3 R6
           jumpnz R0 jumpcheck;number found already so display all 0's
           jumpz R6 reduce
jumpcheck: add R1 R6 R6
           store R6 0xfff0
           mod R7 R3 R7
           load ONE R0
           jump reduce
complete:  add R1 R7 R7;displaying ones column
           store R7 0xfff0
reset:     load ONE R1;start of word = true
           load ZERO R2;got minus = false
           load ZERO R4;integer = 0
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
          load ZERO R2;got minus = false
          mult R4 MONE R4;negate integer
pushint:  push R4;push integer
          load ONE R1;start of word = true
          load ZERO R4;zero integer
checksub: jumpz R2 main;if got minus then perform subtraction
          pop R6
          pop R7
          sub R7 R6 R7
          push R7
          load ZERO R2;got minus = false           
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
     add R6 R7 R7
     push R7
     jump main

;    else if(i == '-') gotMinus = 1;      
sub: load #'-' R5
     sub R0 R5 R5
     jumpnz R5 mul
     load ONE R2;got minus = true
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
     mult R6 R7 R7
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
     div R6 R7 R7
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
     mod R6 R7 R7
     push R7
     jump main

     
;void power()
;{
;  //stack - 3 = var
;  //stack - 2 = iter
;  //stack - 1 = original base
;  
;  if(stack[stackPointer - 2] == 1) return;//finished power
;  
;  stack[stackPointer - 3] *= stack[stackPointer - 1];
;  stack[stackPointer - 2] -= 1;
;  power();
;}
;
;
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
rpow:     
     jump main

     
;void factorial()
;{
;  //stack - 3 = var
;  //stack - 2 = iter
;  //stack - 1 = target
;  
;  //Important: factorial zero must result in 0 not 1
;
;  if((stack[stackPointer - 1] - stack[stackPointer - 2]) < 0) return;//finished factorial
;  printf("var: %d iter: %d target: %d\n", stack[stackPointer - 3], stack[stackPointer - 2], stack[stackPointer - 1]);
;  stack[stackPointer - 3] *= stack[stackPointer - 2];
;  stack[stackPointer - 2] += 1;
;  factorial();
;}
;
;    
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
     jumpnz R5 num;not a useful character so must be part of a number
rfac:
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
     load ZERO R1;start of integer = false
     jump main
          
thousandmillion: block #1000000000