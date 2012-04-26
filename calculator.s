mem_fault: halt

;Arrian Purcell u5015666 ANU Comp2300 Semester 1 2012

;General register use
;R0 - char i = 0; input char
;R1 - int startOfWord = 1; where 1 is true and 0 is false
;R2 - int gotMinus = 0; where 1 is true and 0 is false
;R3 - temp
;R4 - int integer = 0; input integer
;R5 - temp
;R6 - temp
;R7 - temp

;Main
0x0100: load #1 R1;start of word = true
main:   load 0xfff1 R0
        jumpnz R0 getchar
        jump main
        
;Getting input char
getchar: load 0xfff0 R0 ;loading char into register
         ;store R0 0xfff0 ;debug outputting char to screen    
         load #0x0200 R3
         add R0 R3 R3
         move R3 PC;jump to ascii lookup table
         
;Operation lookup table
0x020a:jump newline;'\n'
0x0220:jump space;' '
0x0221:jump fac;'!'
0x0225:jump rem;'%'
0x022a:jump mul;'*'
0x022b:jump add;'+'
0x022d:load #1 R2;'-' got minus = true
       jump main
0x022f:jump div;'/'
0x0230:jump zero;'0'
0x0231:jump num
0x0232:jump num
0x0233:jump num
0x0234:jump num
0x0235:jump num
0x0236:jump num
0x0237:jump num
0x0238:jump num
0x0239:jump num

;Power procedure
0x025e:pop R6;'^' iter
       sub R6 ONE R6;need 1 less multiplication than given
       pop R5;original base
       move R5 R7;final value
       jumpz R7 rpowdone;zero base, return 0

;Recursive power procedure
rpow:jumpz R6 rpowdone
     mult R7 R5 R7
     jumpz R7 zeropow
     sub R6 ONE R6
     jump rpow
zeropow:  load #1 R7;if the power is zero then need a one on stack
rpowdone: push R7
          jump main
        
 
;Newline character
newline:
checkinteger:jumpz R4 checkstack;no new number
             jumpz R2 display;no negate sign
             mult R4 MONE R4;negate
             jump display
checkstack:load #0x7000 R6;stopping only if stack is empty
           move SP R7;get stack pointer
           sub R6 R7 R7;check if stack has items
           jumpnz R7 nohalt
           halt
nohalt:    pop R4
           jumpz R2 display;no subtract sign
           pop R7
           sub R7 R4 R4;perform end of line subtraction
           
;hasstack:       
;hasneg:
;hassub:


;Displaying final answer
display:    load #'0' R7;displaying integer in R4 as chars
            load #10 R1
            load #0x7000 R6
dcheckneg:  jumpn R4 displayneg
            jump displaynum
displayneg: load #'-' R5;displaying negative sign
            store R5 0xfff0
            mult R4 MONE R4;negate
displaynum: mod R4 R1 R2
            div R4 R1 R4
            add R7 R2 R2
            push R2
            jumpz R4 rstack
            jump displaynum
rstack:     pop R1
            store R1 0xfff0
            sub R6 SP R5
            jumpz R5 reset
            jump rstack
reset:      store R0 0xfff0;newline
            load #1 R1;start of word = true
            load #0 R2;got minus = false
            load #0 R4;integer = 0
            jump main

;Space character
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
       
;Add character
add: pop R6
     pop R7
     add R7 R6 R7
     push R7
     jump main

;Multiply character
mul: pop R6
     pop R7
     mult R7 R6 R7
     push R7
     jump main

;Divide character
div: pop R6
     pop R7
     div R7 R6 R7
     push R7
     jump main

;Modulus character
rem: pop R6
     pop R7
     mod R7 R6 R7
     push R7
     jump main
     
;Factorial character
fac: pop R7
     load #factoriallookup R6;loading factorial from lookup table
     add R6 R7 R7
     load R7 R7
     push R7
     jump main

;Zero character - if zero is first character then must push to stack
zero: jumpnz R4 num;integer has contents...handle zero normally
      push ZERO;need to push zero to stack
      jump main
     
;Number character - must construct integer from input characters
num: load #'0' R5;ascii base
     sub R0 R5 R5;convert char to int
     load #10 R7;promote existing integer by factor of ten
     mult R4 R7 R4
     add R4 R5 R4;combine promoted integer and input integer
     load #0 R1;start of integer = false
     jump main

;Maximum display divisor - 32bit integer
thousandmillion: block #1000000000

;Factorial lookup table
factoriallookup: block #1;0!
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