%include "include/io.inc"

extern atoi
extern printf
extern exit

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
	use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1

section .text
global main
main:
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:

    push dword[img]
    call bruteforce_singlebyte_xor
    add esp, 4

    push ecx
    push edx
    push edx
    call print_message
    add esp, 4
    pop edx
    pop ecx

    PRINT_DEC 4, ecx
    NEWLINE
    PRINT_DEC 4, edx
    NEWLINE

    jmp done

solve_task2:

    push dword[img]
    call bruteforce_singlebyte_xor
    add esp, 4

    pusha
    push edx
    call make_message
    add esp, 4
    popa

    push eax
    mov eax, 2
    mul ecx
    add eax, 3
    mov ecx, 5
    cdq
    div ecx
    sub eax, 4
    mov ecx, eax
    pop eax

    push edx
    push ecx
    mov edx, ecx
    call traverseXOR
    pop ecx
    pop edx

    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp, 12

    jmp done
solve_task3:
    ; TODO Task3
    jmp done
solve_task4:
    ; TODO Task4
    jmp done
solve_task5:
    ; TODO Task5
    jmp done
solve_task6:
    
    push 0
    push 0
    push 0
    call print_image
    add esp, 12

    pusha
    push dword[img]
    call blur
    add esp, 4
    popa

    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret

bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp

    mov eax, [img_width]
    mov ebx, [img_height]
    imul ebx
    mov ebx, eax
    mov eax, [ebp+8]

    xor ecx, ecx
    xor edx, edx

; se incearca fiecare cheie de la 0 la 255
try_key:
    mov edx, ecx
    push eax
    push ebx
    push edx
    
    pusha
    call traverseXOR
    popa

    push ecx
    call traverseMatrix
    pop ecx

    cmp edx, -2
    jne out

    pop edx
    pop ebx
    pop eax
    
    ; restaurare matrice
    pusha
    mov edx, ecx
    call traverseXOR
    popa

    inc ecx
    cmp ecx, 256
    jne try_key
    
traverseXOR:
    enter 0, 0
  
    xor ecx, ecx
    mov eax, [img]
    push edx
    push eax
    xor ebx, ebx
    mov eax, [img_width]
    mov ebx, [img_height]
    mul ebx
    mov ebx, eax
    pop eax
    pop edx

; pune in matrice valorile "xorate"
repeat:
    push edx
    xor edx, [eax+4*ecx]
    mov [eax+4*ecx], edx
    pop edx
    inc ecx
    cmp ecx, ebx
    jne repeat 
    leave
    ret

my_strcmp:
    enter 28, 0 ; o sa rezerv 7 bytes pentru 'revient'
    mov edx, 1
    push eax
    push ebx
    push ecx
    mov eax, [ebp+8]
    mov dword[ebp-4], 114 ; 'r'
    mov dword[ebp-8], 101 ; 'e'
    mov dword[ebp-12], 118 ; 'v'
    mov dword[ebp-16], 105 ; 'i'
    mov dword[ebp-20], 101 ; 'e'
    mov dword[ebp-24], 110 ; 'n'
    mov dword[ebp-28], 116 ; 't'
    mov ecx, 1
compare:
    push eax
    mov eax, [eax+4*(ecx-1)]
    push ecx
    push eax
    mov eax, -4
    mul ecx
    mov ecx, eax
    mov ebx, [ebp + ecx]
    pop eax
    pop ecx

    cmp eax, ebx
    jne stop
    inc ecx
    pop eax
    cmp ecx, 8 ; lungimea lui 'revient'
    jne compare


    pop ecx
    pop ebx
    pop eax
    mov edx, 1
    leave
    ret
stop:
    pop eax
    pop ecx
    pop ebx
    pop eax
    mov edx, -2 ; in caz de esec
    leave
    ret

traverseLine:
    enter 0, 0
    push eax
    push ebx
    push ecx

    mov eax, [ebp+8]
    push ecx
    mov ecx, [img_width]
    mul ecx
    mov ecx, 4
    mul ecx
    pop ecx
    
    mov ebx, [img]
    add ebx, eax
    mov eax, ebx
    xor ecx, ecx

go: ; se ia fiecare succesiune de 8 caractere
    push ecx
    push eax
    push eax
    call my_strcmp
    add esp , 4
    pop eax
    pop ecx
 
    cmp edx, 1
    je out
    inc ecx
    mov ebx, [img_width]
    sub ebx, 7
    
    add eax, 4

    cmp ecx, ebx
    jne go
    
    mov edx, -2

    pop ecx
    pop ebx
    pop eax
    leave
    ret

out:
    pop ecx
    pop ebx
    pop eax
    leave
    ret

traverseMatrix:
    enter 0, 0

    mov ecx, 0
traverseMatrixRepeat: ; se parcurge fiecare linie din matrice
    push ecx
    push ecx
    call traverseLine
    add esp, 4
    cmp edx, 1
    je found
    pop ecx
    
    
    inc ecx
    cmp ecx, [img_height]
    jne traverseMatrixRepeat

    leave
    ret

found:
    pop ecx
    mov edx, ecx
    leave
    ret

 ; se afiseaza propozitia de la linia data ca parametru
print_message:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    cmp eax, -2
    je out

    push ecx
    mov ecx, [img_width]
    mul ecx
    mov ecx, 4
    mul ecx
    pop ecx

    mov ebx, [img]
    add ebx, eax
    mov eax, ebx
    xor ecx, ecx

repeat_print:
    PRINT_CHAR [eax+4*ecx]
    inc ecx
    cmp dword[eax+4*ecx], 0
    jnz repeat_print
    NEWLINE

    leave
    ret

make_message: ; se hardcodeaza mesajul dorit
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    inc eax

    push ecx
    mov ecx, [img_width]
    mul ecx
    mov ecx, 4
    mul ecx
    pop ecx

    mov ebx, [img]
    add ebx, eax
    mov eax, ebx
    xor ecx, ecx

    mov dword[ebp-4], 67
    mov dword[ebp-8], 39
    mov dword[ebp-12], 101
    mov dword[ebp-16], 115
    mov dword[ebp-20], 116
    mov dword[ebp-24], 32
    mov dword[ebp-28], 117
    mov dword[ebp-32], 110
    mov dword[ebp-36], 32
    mov dword[ebp-40], 112
    mov dword[ebp-44], 114
    mov dword[ebp-48], 111
    mov dword[ebp-52], 118
    mov dword[ebp-56], 101
    mov dword[ebp-60], 114
    mov dword[ebp-64], 98
    mov dword[ebp-68], 101
    mov dword[ebp-72], 32
    mov dword[ebp-76], 102
    mov dword[ebp-80], 114    
    mov dword[ebp-84], 97
    mov dword[ebp-88], 110
    mov dword[ebp-92], 99
    mov dword[ebp-96], 97
    mov dword[ebp-100], 105
    mov dword[ebp-104], 115
    mov dword[ebp-108], 46
    mov dword[ebp-112], 0

    mov ecx, -1
    xor edx, edx
put_message:

    mov ebx, [ebp+4*ecx]
    mov [eax+4*edx], ebx
    dec ecx
    inc edx

    cmp dword[ebp+4*(ecx)], 0
    jne put_message

    mov dword[eax+4*edx], 0

    leave
    ret


blur:
    enter 0, 0
  
    mov eax, [ebp+8]
    xor ebx, ebx ; linia
    xor ecx, ecx ; coloana
    mov edx, [img_width]
    dec edx

do_again:

    cmp ebx, 0
    je next_line

    cmp ecx, 0
    je next_column

    cmp ebx, edx
    je stop2

    cmp ecx, edx
    je end_column

    push ebx
    push ecx

    push eax
    push ebx
    push edx

    xor edx, edx

    imul ebx, [img_width]
    imul ebx, 4
    imul ecx, 4

    add eax, ebx
    add eax, ecx

    add edx, [eax]
    mov ecx, [eax-4]
    add edx, ecx

    mov ecx, [eax+4]
    add edx, ecx

    mov edi, -4
    imul edi, [img_width]

    mov ecx, [eax+edi]
    add edx, ecx

    mov edi, 4
    imul edi, [img_width]

    mov ecx, [eax+edi]
    add edx, ecx

    push eax
    mov eax, edx

    mov ebx, 5

    xor edx, edx
    div ebx

    pop eax        
     
    pop edx
    pop ebx
    pop eax
    
    pop ecx
    pop ebx

    inc ecx
    jmp do_again

    leave
    ret

next_column:

    inc ecx
    jmp do_again

next_line:

    inc ebx
    xor ecx, ecx
    jmp do_again

end_column:

    xor ecx, ecx
    inc ebx
    jmp do_again

stop2:
    leave
    ret