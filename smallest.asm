extern printf
section .data
msg_min: db "The smallest value is: %d",10,0

section .bss

    
section .text
global minimum
minimum:
    
    mov rax,rdi
    mov rbx,rax                   
    mov rcx,rsi
    cmp rcx,rbx
    ja last_min
    mov rbx,rcx 
    
last_min:
    mov rcx,rdx
    cmp rcx,rbx
    ja smallest_value
    mov rbx,rcx
    
smallest_value:
ret
