.686
.model flat
extern __read : PROC
extern __write : PROC
extern _ExitProcess@4 : PROC

public _main
.data
; wczytywanie liczby dziesiêtnej z klawiatury – po
; wprowadzeniu cyfr nale¿y nacisn¹æ klawisz Enter
; liczba po konwersji na postaæ binarn¹ zostaje wpisana
; do rejestru EAX
; deklaracja tablicy do przechowywania wprowadzanych cyfr
; (w obszarze danych)
obszar db 12 dup (?)
dziesiec dd 10			; mno¿nik
znaki db 12 dup (?)
dekoder db '0123456789ABCDEF'

.code

wyswietl_EAX PROC
	; wyœwietlanie zawartoœci rejestru EAX
	; w postaci liczby szesnastkowej
	pusha ; przechowanie rejestrów

	; rezerwacja 12 bajtów na stosie (poprzez zmniejszenie
	; rejestru ESP) przeznaczonych na tymczasowe przechowanie
	; cyfr szesnastkowych wyœwietlanej liczby
	sub esp, 12
	mov edi, esp ; adres zarezerwowanego obszaru
	; pamiêci
	; przygotowanie konwersji
	mov ecx, 8 ; liczba obiegów pêtli konwersji
	mov esi, 1 ; indeks pocz¹tkowy u¿ywany przy
	; zapisie cyfr
	; pêtla konwersji
	ptl3hex:
	; przesuniêcie cykliczne (obrót) rejestru EAX o 4 bity w lewo
	; w szczególnoœci, w pierwszym obiegu pêtli bity nr 31 - 28
	; rejestru EAX zostan¹ przesuniête na pozycje 3 - 0
	rol eax, 4
	; wyodrêbnienie 4 najm³odszych bitów i odczytanie z tablicy
	; 'dekoder' odpowiadaj¹cej im cyfry w zapisie szesnastkowym
	mov ebx, eax ; kopiowanie EAX do EBX
	and ebx, 0000000FH ; zerowanie bitów 31 - 4 rej.EBX
	mov dl, dekoder[ebx] ; pobranie cyfry z tablicy
	; przes³anie cyfry do obszaru roboczego
	mov [edi][esi], dl
	inc esi ;inkrementacja modyfikatora
	loop ptl3hex ; sterowanie pêtl¹

	; wpisanie znaku nowego wiersza przed i po cyfrach
	mov byte PTR [edi][0], 10
	mov byte PTR [edi][9], 10

	mov ecx, 1
	
	zamien_zera:
		cmp byte PTR [edi][ecx], '0'
		je wymien
		jmp dalej

	wymien:
		mov byte PTR [edi][ecx], 32 ;kod spacji
		inc ecx
		jmp zamien_zera

	dalej:
	; wyœwietlenie przygotowanych cyfr
	push 10 ; 8 cyfr + 2 znaki nowego wiersza
	push edi ; adres obszaru roboczego
	push 1 ; nr urz¹dzenia (tu: ekran)
	call __write ; wyœwietlenie
	; usuniêcie ze stosu 24 bajtów, w tym 12 bajtów zapisanych
	; przez 3 rozkazy push przed rozkazem call
	; i 12 bajtów zarezerwowanych na pocz¹tku podprogramu
	add esp, 24

	popa ; odtworzenie rejestrów
	ret ; powrót z podprogramu
wyswietl_EAX ENDP

wczytaj_EAX PROC

	push ebx						
	push ecx

	push dword PTR 12				; max iloœæ znaków wczytywanej liczby
	push dword PTR OFFSET obszar	; adres obszaru pamiêci
	push dword PTR 0				; numer urz¹dzenia (0 dla klawiatury)
	call __read			; odczytywanie znaków z klawiatury (dwa znaki podkreœlenia przed read)
	add esp, 12			; usuniêcie parametrów ze stosu

					; bie¿¹ca wartoœæ przekszta³canej liczby przechowywana jest
					; w rejestrze EAX; przyjmujemy 0 jako wartoœæ pocz¹tkow¹
	mov eax, 0
	mov ebx, OFFSET obszar ; adres obszaru ze znakami

	pobieraj_znaki:
	mov cl, [ebx]		; pobranie kolejnej cyfry w kodzie ASCII
	inc ebx				; zwiêkszenie indeksu
	cmp cl,10			; sprawdzenie czy naciœniêto Enter
	je byl_enter		; skok, gdy naciœniêto Enter
	sub cl, 30H			; zamiana kodu ASCII na wartoœæ cyfry
	movzx ecx, cl		; przechowanie wartoœci cyfry w
					; rejestrze ECX
					; mno¿enie wczeœniej obliczonej wartoœci razy 10
	mul dword PTR dziesiec
	add eax, ecx		; dodanie ostatnio odczytanej cyfry
	jmp pobieraj_znaki	; skok na pocz¹tek pêtli

	byl_enter:
	pop ecx
	pop ebx
	ret
wczytaj_EAX ENDP
					; wartoœæ binarna wprowadzonej liczby znajduje siê teraz w rejestrze EAX

_main PROC
	call wczytaj_EAX
	call wyswietl_EAX
	push 0
	call _ExitProcess@4
_main ENDP

END