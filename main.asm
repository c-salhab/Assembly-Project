;external functions from us
%include "biggest.asm"
%include "smallest.asm"
%include "determinant.asm"

extern maximum
extern minimum

; external functions from X11 library

extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XDrawPoint
extern XFillArc
extern XNextEvent

; external functions from stdio library (ld-linux-x86-64.so.2)    
extern printf
extern exit

%define StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask	4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress	           4
%define Expose                    12
%define ConfigureNotify	22
%define CreateNotify             16

%define NB_TRIANGLES 6
%define TAILLE_FENETRE 500
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1

global generate_random_number
generate_random_number:
    rdrand r15w
    mov ax, r15w
    mov bx,TAILLE_FENETRE
    xor dx, dx
    div bx 
ret

global generate_triangle_coordinates
generate_triangle_coordinates:
        call generate_random_number
        mov [A], dx
        call generate_random_number
        mov [A+QWORD], dx
        
        call generate_random_number
        mov [B], dx
        call generate_random_number
        mov [B+QWORD], dx
        
        call generate_random_number
        mov [C], dx
        call generate_random_number
        mov [C+QWORD], dx
ret

global initialize_color_jump
initialize_color_jump:
    
    mov eax, [based_color]
    mov ebx, NB_TRIANGLES
    xor edx, edx
    div ebx
    sub ebx, 1  
ret

global change_color
change_color:
    
    call initialize_color_jump
    add dword[actual_color], eax
    mov rdi,qword[display_name]
    mov rsi,qword[gc]
    mov edx,[actual_color]
    call XSetForeground
ret   

global main

section .bss
display_name:	resq	1
screen:	         resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1

xmax: resq 1
ymax: resq 1
xmin: resq 1
ymin: resq 1

xcurrent: resq 1
ycurrent: resq 1

det_points: resq 3
 
section .data

resultat: db "Resultat : (%d,%d)", 10 ,0

event:      times	24 dq 0

;######POINTS######
A: dq 0,0
B: dq 0,0
C: dq 0,0
P: dq 0,0 
;##################

based_color: dd 0xFF0000
actual_color: dd 0xFF0000

i: db 0   
j: db 0   
section .text
	
;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:

push rbp

xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,TAILLE_FENETRE	; largeur
mov r9,TAILLE_FENETRE	; hauteur
push 0xFFFFFF	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

boucle: ; boucle de gestion des évènements
mov rdi,qword[display_name]
mov rsi,event
call XNextEvent

cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
je dessin							; on saute au label 'dessin'

;#########################################
;#		DEBUT DE LA ZONE DE DESSIN		 #
;#########################################
dessin:
    
    mov byte[i], NB_TRIANGLES
    loop_triangle:
    
    call generate_triangle_coordinates
    
    mov rdi,qword[display_name]
    mov rsi,qword[gc]
    mov edx,0x000000
    call XSetForeground
    
    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]
    mov rcx,qword[A]	; coordonnée source en x
    mov r8,qword[A+QWORD]	; coordonnée source en y
    mov r9,qword[B]	; coordonnée destination en x
    push qword[B+QWORD]		; coordonnée destination en y
    call XDrawLine
    
    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]
    mov rcx,qword[B]	; coordonnée source en x
    mov r8,qword[B+QWORD]	; coordonnée source en y
    mov r9,qword[C]	; coordonnée destination en x
    push qword[C+QWORD]		; coordonnée destination en y
    call XDrawLine
    
    mov rdi,qword[display_name]
    mov rsi,qword[window]
    mov rdx,qword[gc]
    mov rcx,qword[C]	; coordonnée source en x
    mov r8,qword[C+QWORD]	; coordonnée source en y
    mov r9,qword[A]	; coordonnée destination en x
    push qword[A+QWORD]		; coordonnée destination en y
    call XDrawLine
    
 ;########################################
 ;##############RECTANGLES################
 ;########################################   
  
    mov rdi, qword[A]
    mov rsi, qword[B]
    mov rdx, qword[C]  
    call maximum
    mov qword[xmax], rbx
    
    mov rdi, qword[A]
    mov rsi, qword[B]
    mov rdx, qword[C]  
    call minimum
    mov qword[xmin], rbx
    
    mov rdi, qword[A+QWORD]
    mov rsi, qword[B+QWORD]
    mov rdx, qword[C+QWORD]  
    call maximum
    mov qword[ymax], rbx
    
    mov rdi, qword[A+QWORD]
    mov rsi, qword[B+QWORD]
    mov rdx, qword[C+QWORD]  
    call minimum
    mov qword[ymin], rbx
    
    mov rax, qword[xmin]
    mov rbx, qword[ymin]
    
    mov qword[xcurrent], rax
    mov qword[ycurrent], rbx
    
    call change_color
   
    outerLoop:
    
        mov rcx, qword[xcurrent]
        cmp  rcx, qword[xmax]
        ja done
            
        mov rbx, qword[ymin]
        mov qword[ycurrent], rbx
        
    innerLoop:
            
        ;DETERMINANT AB AP
        mov rdi, qword[A]
        mov rsi, qword[A+QWORD] 
        mov rdx, qword[B]
        mov rcx, qword[B+QWORD] 
        mov r8, qword[xcurrent]
        mov r9, qword[ycurrent] 
        
        call vecteurs
        
        push rax ; On sauvegarde le déterminant
        
        ;DETERMINANT BC BP
        mov rdi, qword[B]
        mov rsi, qword[B+QWORD] 
        mov rdx, qword[C]
        mov rcx, qword[C+QWORD] 
        mov r8, qword[xcurrent]
        mov r9, qword[ycurrent] 
    
        call vecteurs
        
        push rax ; On sauvegarde le déterminant
          
        ;DETERMINANT CA CP
        mov rdi, qword[C]
        mov rsi, qword[C+QWORD] 
        mov rdx, qword[A]
        mov rcx, qword[A+QWORD] 
        mov r8, qword[xcurrent]
        mov r9, qword[ycurrent] 
    
        call vecteurs
        
        push rax ; On sauvegarde le déterminant
        
        ;TRIANGLE DETERMINANT
        mov rdi, qword[A]
        mov rsi, qword[A+QWORD] 
        mov rdx, qword[B]
        mov rcx, qword[B+QWORD] 
        mov r8, qword[C]
        mov r9, qword[C+QWORD] 
        
        call vecteurs
        
        mov [det_points], rax
        pop rax
        mov [det_points + 1 * QWORD], rax
        pop rax
        mov [det_points + 2 * QWORD], rax    
        pop rax
        
        mov byte[j], 0
    
        verification:
            movzx ecx, byte[j]
            
            cmp rax, [det_points + ecx * QWORD]
            jne fin_coloriage
            inc byte[j]
            cmp byte[j], 3
            jb verification
                        
            mov rdi,qword[display_name]
            mov rsi,qword[window]
            mov rdx,qword[gc]
            mov ecx,dword[xcurrent] ; coordonnée source en x
            mov r8d,dword[ycurrent] ; coordonnée source en y
            call XDrawPoint
            
        fin_coloriage:  
        
      ;##########################
        mov ebx, dword[ycurrent]
        cmp ebx, dword[ymax]
        je innerLoopDone
        inc dword[ycurrent] 
        jmp innerLoop
      ;##########################
    innerLoopDone:
        inc dword[xcurrent]
        jmp outerLoop
    done:
   
    dec byte[i]
    cmp byte[i], 0
    ja loop_triangle       
; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################

jmp flush

flush:
mov rdi,qword[display_name]
call XFlush
;jmp boucle
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit
	
    pop rbp
    mov rax, 60
    mov rdi, 0
    syscall
ret