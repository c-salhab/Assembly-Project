extern printf
section .data
msg_max: db "The biggest value is: %d",10,0

section .bss

    
section .text
global maximum
maximum:
    
    mov rax,rdi
    mov rbx,rax               
    mov rcx,rsi
    cmp rcx,rbx
    jle last_max
    mov rbx,rcx 
    
last_max:
    mov rcx,rdx
    cmp rcx,rbx
    jle biggest_value
    mov rbx,rcx
    
biggest_value:
           

ret

