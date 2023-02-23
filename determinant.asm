global vecteurs

section .text
vecteurs:
    
    push rbp
    mov rbp, rsp
    ;rdi : Xa
    ;rsi : Ya
    ;rdx : Xb
    ;rcx : Yb
    ;r8  : Xc || Xp
    ;r9  : Yc || Yp
    
    sub rdx, rdi ;Xab
    sub rcx, rsi ;Yab
    
    sub r8, rdi ;Xac || Xap
    sub r9, rsi ;Yac || Yap
    
    ;push rdx 
    ;push rcx 
    ;push r8
    ;push r9
    
    mov rdi, rdx ;Xab
    mov rsi, rcx ;Yab
    mov rdx, r8  ;Xac || Xap
    mov rcx, r9  ;Yac || Yap
    
    mov rsp, rbp
    pop rbp
    
    call determinant
    
ret

global determinant
section .text    
determinant:
    
    mov r8, 0
    imul rdi, rcx
    imul rsi, rdx
    sub rdi, rsi
    
    call signe
ret

global signe

signe:
    
    cmp rdi, 0
    jl indirect
    direct:
        mov rax, 1
        ;mov rdi, resultat_positif
        ;mov rax, 0
        ;call printf
       jmp fin_signe
    indirect:
        mov rax, 0
        ;mov rdi, resultat_negatif
        ;mov rax, 0
        ;call printf
    fin_signe:
ret
