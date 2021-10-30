.386
.model flat, stdcall
.stack 10214
ExitProcess PROTO,          ; exit program
    dwExitCode:DWORD        ; return code

WriteConsoleA PROTO,                   ; write a buffer to the console
    handle:DWORD,                     ; output handle
    lpBuffer:PTR BYTE,                ; pointer to buffer
    nNumberOfCharsToWrite:DWORD,      ; size of buffer
    lpNumberOfCharsWritten:PTR DWORD, ; number of chars written
    lpReserved:PTR DWORD              ; 0 (not used)

ReadConsoleA PROTO,
    handle:DWORD,                     ; input handle
    lpBuffer:PTR BYTE,                ; pointer to buffer
    nNumberOfCharsToRead:DWORD,       ; number of chars to read
    lpNumberOfCharsRead:PTR DWORD,    ; number of chars read
    lpReserved:PTR DWORD              ; 0 (not used - reserved)

GetStdHandle proto, a1:dword
CloseHandle PROTO,      ; close file handle
    handle:DWORD

;ReadFile proto, a1: dword, a2: ptr byte, a3: dword, a4:ptr dword, a5: ptr dword
ReadFile PROTO,           ; read buffer from input file
    fileHandle:DWORD,     ; handle to file
    pBuffer:PTR BYTE,     ; ptr to buffer
    nBufsize:DWORD,       ; number bytes to read
    pBytesRead:PTR DWORD, ; bytes actually read
    pOverlapped:PTR DWORD ; ptr to asynchronous info

CreateFileA PROTO,           ; create new file
    pFilename:PTR BYTE,     ; ptr to filename
    accessMode:DWORD,       ; access mode
    shareMode:DWORD,        ; share mode
    lpSecurity:DWORD,       ; can be NULL
    howToCreate:DWORD,      ; how to create the file
    attributes:DWORD,       ; file attributes
    htemplate:DWORD         ; handle to template file

WriteFile PROTO,             ; write buffer to output file
    fileHandle:DWORD,        ; output handle
    pBuffer:PTR BYTE,        ; pointer to buffer
    nBufsize:DWORD,          ; size of buffer
    pBytesWritten:PTR DWORD, ; number of bytes written
    pOverlapped:PTR DWORD    ; ptr to asynchronous info

.data
;filepath byte "F:\Projectpic.ppm",0
;filepath1 byte "F:\atv.ppm",0
display byte 0ah,"What would you like to do?",0ah,"1.) Hide",0ah,"2.) Recover",0ah,"3.) Exit",0ah
enteringmess byte "Please Specify the source PPM file name: " , 0ah
enteringmess2 byte "Please Specify the output PPM filename: " , 0ah
enteringmess3 byte "Please enter phrase to hide: " , 0ah  
success byte "The following message has been recovered from file "
sourcefile byte 25 dup(?)
outputfile byte 25 dup(?)
output byte 25 dup(?)
submit1 byte "Your message "
submit2 byte "has been submitted in file : "
buff byte 11920 dup(?)
input1 byte 3 dup(?)
encmess byte 50 dup (?)
mess byte 50 dup (?)
message byte 50 dup (?)
n2 byte "Recovered"
x dword ?
handle dword ?
text dword ?
lent dword ?
.code

main proc

Console:
;Writing onto console
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset display, lengthof display, offset x,0

invoke GetStdHandle, -10
invoke ReadConsoleA, eax, offset input1, lengthof input1, offset x,0 
mov esi, offset input1
mov al,input1
cmp al,31h
JE hide

mov al,input1
cmp al,32h
JE reco

mov al,input1
cmp al,33h
JE stop
jmp Console

hide:
jmp Hiding

reco:
jmp recover

hiding:
;Reading File
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset enteringmess, lengthof enteringmess, offset x, 0
;SourceFile Path
invoke GetStdHandle, -10
invoke ReadConsoleA, eax, offset sourcefile, lengthof sourcefile, offset x, 0
mov edx, x
sub edx, 1
mov sourcefile[edx], 0
sub edx, 1
mov sourcefile[edx], 0

invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset enteringmess2, lengthof enteringmess2, offset x, 0
;Output File Name
invoke GetStdHandle, -10
invoke ReadConsoleA, eax, offset outputfile, lengthof outputfile, offset x, 0
mov edx, x
sub edx, 1
mov outputfile[edx], 0
sub edx, 1
mov outputfile[edx], 0


invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset enteringmess3, lengthof enteringmess3, offset x, 0
invoke GetStdHandle, -10
invoke ReadConsoleA, eax, offset encmess, lengthof encmess, offset x, 0
mov edx,offset encmess
mov eax,x
mov text, eax
sub text,2
mov ebp,0
L11:
mov al,encmess[ebp]
cmp al,0dh
je outof
inc ebp
loop L11

outof:

;Readfile
invoke CreateFileA, offset sourcefile, 1 ,1,0,3, 128, 0
mov handle, eax
invoke ReadFile, eax, offset buff, lengthof buff, offset x,0
invoke CloseHandle, handle

;mov esi,0
;mov eax,1
;mov ebx,0
;mov ecx, 100
;L7:
;cmp eax,4h
;Je Encryption

;inc esi
;mov dl,buff[esi]
;cmp dl,0ah
;je incre
;jmp L7
;incre:
;inc eax
;Loop L7

Encryption:
mov eax, offset buff
mov esi,0
mov ecx, ebp
mov ebx,0
mov edx,0
mov edi,0
mov ebp,0
mov eax,0
mov al, encmess[esi]
mov esi,13
L1:

mov bl , buff[esi]
cmp ebp,8
je initialesp

ROL al,1
mov dl,0
RCL dl,1
and bl,11111110b
OR bl,dl
inc ebp
mov buff[esi] , bl
inc esi
jmp L1


initialesp:
mov eax,offset buff
inc edi
mov al, encmess[edi]
mov ebp,0

Loop L1

;Writing File
mov esi,offset buff
mov edx,offset buff
invoke CreateFileA, offset outputfile, 2 ,1,0,2, 128, 0
invoke WriteFile, eax, offset buff, lengthof buff, offset x,0

mov ecx,offset encmess
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset submit1, lengthof submit1, offset x,0 
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset encmess, text, offset x,0
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset submit2, lengthof submit2, offset x, 0
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset outputfile, lengthof outputfile, offset x, 0


mov eax,offset encmess
jmp Console


recover:


outof1:
inc ebp
;Reading File
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset enteringmess, lengthof enteringmess, offset x, 0
;SourceFile Path
invoke GetStdHandle, -10
invoke ReadConsoleA, eax, offset output, lengthof output, offset x, 0
mov edx, x
sub edx, 1
mov output[edx], 0
sub edx, 1
mov output[edx], 0

;Readfile
invoke CreateFileA, offset output, 1 ,1,0,3, 128, 0
mov handle, eax
invoke ReadFile, eax, offset buff, lengthof buff, offset x,0
invoke CloseHandle, handle

mov esi,0
mov eax,1
mov ebx,0
mov ecx, 100
L8:
cmp eax,4h
Je Recovering
inc esi
mov dl,buff[esi]
cmp dl,0ah
je increase
jmp L8
increase:
inc eax
Loop L8

Recovering:
mov eax, offset buff
mov edx,offset message
mov ecx,50
mov ebx,0
mov edx,0
mov edi,0
mov ebp,0
mov eax,0

mov dl,0
inc esi

L2:
cmp ebp,8
je placing
mov bl,buff[esi]
and bl,00000001b
ROR bl,1
RCL dl,1
inc esi
inc ebp
jmp L2

placing:
mov al,0h
cmp al,dl
je out1
mov message[edi],dl
inc edi
mov ebp,0
Loop L2

out1:
;Writing onto console
mov esi, offset success
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset success, lengthof success, offset x,0 
invoke GetStdHandle, -11
invoke WriteConsoleA, eax, offset message, lengthof message, offset x,0
mov eax,offset message
jmp Console

stop:

invoke ExitProcess,0

main endp
end main