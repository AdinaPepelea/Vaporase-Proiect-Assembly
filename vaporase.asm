.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Vaporase",0
area_width EQU 650
area_height EQU 460
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

m1 dd 0FF0000h, 0FF0000h, 0FF0000h, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh
   dd 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh
   dd 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh
   dd 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 0FF0000h, 0FF0000h, 0FF0000h, 00c5ffh, 00c5ffh
   dd 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh
   dd 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh
   dd 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh
   dd 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 0FF0000h, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh
   dd 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 0FF0000h, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh
   dd 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 0FF0000h, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh, 00c5ffh
   
  x dd 0
  y dd 0
   
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

patrat proc
	push ebp
	mov ebp, esp
	pusha

	mov eax, [ebp+arg2]
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg1]
	shl eax, 2
	add eax, area
	mov ecx, [ebp+arg3]

bucla_linie_orizontala_1:
	mov dword ptr[eax], 0
	;mov eax, 0
	add eax, 4
	loop bucla_linie_orizontala_1

	mov eax, [ebp+arg2]
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg1]
	shl eax, 2
	add eax, area
	mov ecx, [ebp+arg3]

bucla_linie_verticala_1:
	mov dword ptr[eax], 0
	add eax, area_width * 4
	loop bucla_linie_verticala_1

	mov eax, [ebp+arg2]
	add eax, [ebp+arg3]
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg1]
	shl eax, 2
	add eax, area
	mov ecx, [ebp+arg3]

bucla_linie_orizontala_2:
	mov dword ptr[eax], 0
	add eax, 4
	loop bucla_linie_orizontala_2

	mov eax, [ebp+arg2]
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg1]
	add eax, [ebp+arg3]
	shl eax, 2
	add eax, area
	mov ecx, [ebp+arg3]

bucla_linie_verticala_2:
	mov dword ptr[eax], 0
	add eax, area_width * 4
	loop bucla_linie_verticala_2
	popa
	mov esp, ebp
	pop ebp
	ret
patrat endp

patrat_rosu proc
	push ebp
	mov ebp, esp
	pusha

	mov eax, [ebp+arg2]
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg1]
	shl eax, 2
	add eax, area
	mov ecx, [ebp+arg3]

bucla_linie_orizontala_1:
	mov dword ptr[eax], 0FF0000h
	add eax, 4
	loop bucla_linie_orizontala_1

	mov eax, [ebp+arg2]
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg1]
	shl eax, 2
	add eax, area
	mov ecx, [ebp+arg3]

bucla_linie_verticala_1:
	mov dword ptr[eax], 0FF0000h
	add eax, area_width * 4
	loop bucla_linie_verticala_1

	mov eax, [ebp+arg2]
	add eax, [ebp+arg3]
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg1]
	shl eax, 2
	add eax, area
	mov ecx, [ebp+arg3]

bucla_linie_orizontala_2:
	mov dword ptr[eax], 0FF0000h
	add eax, 4
	loop bucla_linie_orizontala_2

	mov eax, [ebp+arg2]
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg1]
	add eax, [ebp+arg3]
	shl eax, 2
	add eax, area
	mov ecx, [ebp+arg3]

bucla_linie_verticala_2:
	mov dword ptr[eax], 0FF0000h
	add eax, area_width * 4
	loop bucla_linie_verticala_2
	popa
	mov esp, ebp
	pop ebp
	ret
patrat_rosu endp

matrice proc
	push ebp
	mov ebp, esp

	mov eax, [ebp+arg1]
	mov ebx, [ebp+arg2]
	mov ecx, [ebp+arg3]

bucla_linii:
	mov eax, [ebp+arg1]

bucla_coloane:
	pusha
	push ecx
	push ebx
	push eax
	call patrat
	add esp, 12
	popa
	add eax, ecx
	cmp eax, 640
	jl bucla_coloane
	add ebx, 40
	cmp ebx, 440
	jl bucla_linii

	mov esp, ebp
	pop ebp
	ret
matrice endp

colorare_patrate proc
	push ebp
	mov ebp, esp
	pusha 
	
	mov eax, [ebp+arg2]
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg1]
	shl eax, 2
	add eax, area
	mov ecx, [ebp+arg3]
	mov edx, [ebp+arg4]
bucla:
	mov dword ptr [eax], edx
	add eax, 4
loop bucla
	popa
	mov esp, ebp
	pop ebp
	ret 16;
colorare_patrate endp
	
coordonata_x proc;x
	push ebp
	mov ebp, esp
	pusha 
	
	mov eax, [ebp+arg1]
	mov ecx, 40
	mov edx, 0
	div ecx
	mov edx, 0
	mul ecx
	mov x, eax
	
	popa
	mov esp, ebp
	pop ebp
	ret 
coordonata_x endp
	
coordonata_y proc;y
	push ebp
	mov ebp, esp
	pusha 
	
	mov eax, [ebp+arg1]
	mov ecx, 40
	mov edx, 0
	div ecx
	mov edx, 0
	mul ecx
	mov y, eax
	
	popa
	mov esp, ebp
	pop ebp
	ret 
coordonata_y endp
	
colorare_patrat_rosu proc
	push ebp
	mov ebp, esp
	pusha 
	
	mov ecx, [ebp+arg3]
	dec ecx ; dimensiunea patratului - 1
	mov edx, y ; coordonata y de unde sa deseneze
	add edx, ecx ; adunam dimensiunea patratului
	mov ebx, x
	inc x ;coordonata x+1
bucla_culoare:
	push edx ; salvam vechea valoare a patratului
	push 0FF0000h
	push ecx ; dimensiunea patratului - 1
	push edx
	push ebx ; coordonata x + 1
	call colorare_patrate
	pop edx ; luam vechea valoare a patratului
	dec edx 
loop bucla_culoare
	popa
	mov esp, ebp
	pop ebp
	ret 20
colorare_patrat_rosu endp

colorare_patrat_negru proc
	push ebp
	mov ebp, esp
	pusha 
	
	mov ecx, [ebp+arg3]
	dec ecx ; dimensiunea patratului - 1
	mov edx, [ebp+arg2] ; coordonata y de unde sa deseneze
	add edx, ecx ; adunam dimensiunea patratului
	mov ebx, [ebp+arg1]
	inc ebx ;coordonata x+1
bucla_culoare:
	push edx ; salvam vechea valoare a patratului
	push 00c5ffh
	push ecx ; dimensiunea patratului - 1
	push edx
	push ebx ; coordonata x + 1
	call colorare_patrate
	pop edx ; luam vechea valoare a patratului
	dec edx 
loop bucla_culoare
	popa
	mov esp, ebp
	pop ebp
	ret 20
colorare_patrat_negru endp

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	; mov eax, [ebp+arg2]
	; mov ebx, 40
	; mov edx,0
	; div ebx
	; shl eax, 4
	; push eax
	
	; mov eax, [ebp+arg3]
	; sub eax, 50
	; mov ecx, 40
	; mov edx, 0
	; div ecx
	; push eax
	
	; call coordonata_x
	; call coordonata_y
	
	; pop ecx ;y
	; pop edx ;x
	
	; mov eax, ecx
	; mov ebx, 16
	; mul ebx
	; add eax, edx
	; shl eax, 2
	; add eax, m1
	
	; cmp m1[ecx][edx], 0FF0000h
	; je colorare_patrat_rosu
	
	
	push [ebp+arg1]
	call coordonata_x
	add esp, 4
	
	push [ebp+arg2]
	call coordonata_y
	add esp, 4
	
	mov ecx, 39 ; dimensiunea patratului - 1
	mov edx, y ; coordonata y de unde sa deseneze
	add edx, ecx ; adunam dimensiunea patratului
	bucla_culoare:
	push edx ; salvam vechea valoare a patratului
	push 00c5ffh
	push 39 ; dimensiunea patratului - 1
	push edx
	inc x
	push x ; coordonata x + 1
	call colorare_patrate
	pop edx ; luam vechea valoare a patratului
	dec edx ;
	loop bucla_culoare
	
	
	
	jmp final_draw
	
evt_timer:
	inc counter
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	make_text_macro 'V', area, 110, 15
	make_text_macro 'A', area, 120, 15
	make_text_macro 'P', area, 130, 15
	make_text_macro 'O', area, 140, 15
	make_text_macro 'R', area, 150, 15
	make_text_macro 'A', area, 160, 15
	make_text_macro 'S', area, 170, 15
	make_text_macro 'E', area, 180, 15

	push 40
	push 50
	push 0
	call matrice
	add esp, 12
	
	push 40
	push 50
	push 0
	call patrat_rosu 
	add esp, 12
	push 40
	push 50
	push 40
	call patrat_rosu 
	add esp, 12
	push 40
	push 50
	push 80
	call patrat_rosu 
	add esp, 12
	
	push 40
	push 330
	push 280
	call patrat_rosu 
	add esp, 12
	push 40
	push 370
	push 280
	call patrat_rosu 
	add esp, 12
	push 40
	push 410
	push 280
	call patrat_rosu 
	add esp, 12
	
	push 40
	push 170
	push 440
	call patrat_rosu 
	add esp, 12
	push 40
	push 170
	push 480
	call patrat_rosu 
	add esp, 12
	push 40
	push 170
	push 520
	call patrat_rosu 
	add esp, 12
	
	;int 3
	; push [ebp+arg1]
	; call coordonata_x
	; add esp, 4
	
	; push [ebp+arg2]
	; call coordonata_y
	; add esp, 4
	
	; mov ecx, 39 ; dimensiunea patratului - 1
	; mov edx, y ; coordonata y de unde sa deseneze
	; add edx, ecx ; adunam dimensiunea patratului
	; bucla_culoare:
	; push edx ; salvam vechea valoare a patratului
	; push 00c5ffh
	; push 39 ; dimensiunea patratului - 1
	; push edx
	; inc x
	; push x ; coordonata x + 1
	; call colorare_patrate
	; pop edx ; luam vechea valoare a patratului
	; dec edx ;
	; loop bucla_culoare
	
	; mov ecx, 39 
	; mov edx, 50 
	; add edx, ecx 
	; bucla_culoare1:
	; push edx 
	; push 0FF0000h
	; push 39 
	; push edx
	; push 1
	; call colorare_patrate
	; pop edx 
	; dec edx 
	; loop bucla_culoare1

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20

	;terminarea programului
	push 0
	call exit
end start
