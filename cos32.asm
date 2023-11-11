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
dziesiec dd 13			; mno¿nik
znaki db 12 dup (?)
flaga dd 0 
dekoder db '0123456789ABC'

.code

wyswietl_EAX PROC

mov esi, 10 ; indeks w tablicy 'znaki'
mov ebx, 10 ; dzielnik równy 10
;mov eax, 5804
mov byte PTR znaki [1], '+'
cmp eax, 0
jl ujemna
jmp konwersja

ujemna:
neg eax
mov byte PTR znaki [1], '-'

konwersja:
mov edx, 0 ; zerowanie starszej czêœci dzielnej
div ebx ; dzielenie przez 10, reszta w EDX,
; iloraz w EAX
cmp dl, 0AH
jnge dodaj_cyfra

add dl, 55
jmp dalej

dodaj_cyfra:
add dl, 30H ; zamiana reszty z dzielenia na kod
; ASCII
dalej:
mov znaki[esi], dl; zapisanie cyfry w kodzie ASCII
dec esi ; zmniejszenie indeksu
cmp eax, 0 ; sprawdzenie czy iloraz = 0
jne konwersja ; skok, gdy iloraz niezerowy
; wype³nienie pozosta³ych bajtów spacjami i wpisanie
; znaków nowego wiersza

wypeln:
cmp esi, 1
je wyswietl ; skok, gdy ESI = 0
mov byte PTR znaki [esi], 20H ; kod spacji
dec esi ; zmniejszenie indeksu
jmp wypeln

wyswietl:
mov byte PTR znaki [0], 0AH ; kod nowego wiersza
mov byte PTR znaki [11], 0AH ; kod nowego wiersza
; wyœwietlenie cyfr na ekranie
push dword PTR 12 ; liczba wyœwietlanych znaków
push dword PTR OFFSET znaki ; adres wyœw. obszaru
push dword PTR 1; numer urz¹dzenia (ekran ma numer 1)
call __write ; wyœwietlenie liczby na ekranie

add esp, 12 ; usuniêcie parametrów ze stosu
ret
wyswietl_EAX ENDP

wczytaj_EAX PROC

push ebx
push ecx
push dword PTR 12
push dword PTR OFFSET obszar
push dword PTR 0
call __read
add esp, 12

mov eax, 0
mov ebx, OFFSET obszar
pobieraj_znaki:
mov cl, [ebx]
inc ebx

cmp cl, '-'
je ujemna
jmp cos



cos:
cmp cl, 10
je byl_enter

cmp cl, 55
jnge dodaj_cyfra

sub cl, 55
jmp dalej

dodaj_cyfra:
sub cl, 30H

dalej:
movzx ecx, cl

mul dword PTR dziesiec
add eax, ecx
jmp pobieraj_znaki

ujemna:
mov edx, 1
mov flaga, edx

jmp pobieraj_znaki

byl_enter:
mov edx, flaga
cmp edx, 1
je ng
jmp dsk
ng: 
neg eax
dsk:
pop ecx
pop ebx
ret

wczytaj_EAX ENDP



_main PROC
	call wczytaj_EAX
	sub eax, 10
	call wyswietl_EAX
	push 0
	call _ExitProcess@4
_main ENDP

END



