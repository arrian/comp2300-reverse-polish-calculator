mem_fault: halt
io_handle: jump getchar

0x0100: load 0xfff1 R0
        jumpnz R0 getchar
        jump 0x0100

;In general:
;R0 - results
;R1 - tester
;R7 - is new word (1 when previous char was a space)


getchar: load 0xfff0 R0
         store R0 0xfff0
         jumpz R7 add
space: load #' ' R1
       sub R0 R1 R7
       jumpnz R1 add
       jump 0x0100
       
add: load #'+' R1
     sub R0 R1 R1
     jumpnz R1 sub
     pop R1
     pop R2
     add R1 R2 R0
     jump complete

sub: load #'-' R1
     sub R0 R1 R1
     jumpnz R1 mul
     pop R1
     pop R2
     sub R1 R2 R0
     jump complete

mul: load #'*' R1
     sub R0 R1 R1
     jumpnz R1 div
     pop R1
     pop R2
     mult R1 R2 R0
     jump complete

div: load #'/' R1
     sub R0 R1 R1
     jumpnz R1 rem
     pop R1
     pop R2
     div R1 R2 R0
     jump complete

rem: load #'%' R1
     sub R0 R1 R1
     jumpnz R1 pow
     pop R1
     pop R2
     mod R1 R2 R0
     jump complete

pow: load #'^' R1
     sub R0 R1 R1
     jumpnz R1 fac
     ;todo: implement power
     jump complete

fac: load #'!' R1
     sub R0 R1 R1
     jumpnz R1 isnum
     ;todo: implement factorial
     jump complete
     
isnum: load #'0' R1
       sub R0 R1 R0
       jumpnz R7 complete ;is not the same number as previous char
       pop R2
       load #10 R3 ;promote integer by factor of ten
       mult R2 R3 R2
       add R0 R2 R0
complete: push R0
          load #1 R7;not new word
          jump 0x0100