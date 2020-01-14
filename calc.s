section .data
    numOfOperations : dw 1
    head : dd 1
    temp: dd 1
    temp1: dd 1
    temp2: dd 1
    currentStacksize : dw 0
    buffLength: dd 80
section .bss
    stackSize EQU 5 
    operad_stack : resd stackSize*4
    currentNum : resb 1
    stackPointer : resb 1
    isOddNum : resb 1
    buffer : resb 80
    carry : resb 1
    addZero : resb 1
    firstRun : resb 1
    counter : resb 1
    quitFlag : resb 1
    PosError1 : resb 1
    PosError2 : resb 1
    negPowerPush1 : resb 1
    negPowerPush2 : resb 1
    debugflag : resb 1
    Pushflag : resb 1
    PopDebugflag : resb 1
    FirstRun : resb 1

section	.rodata	    
    formatNum : db "%X",0
    nextline : db 10,0
    overflowError : db "Error: Operand Stack Overflow",10,0
    popEmptyError : db "Error: Insufficient Number of Arguments on Stack",10,0
    DebugPushed : db "pushed to stack -%X",10,0
    DebugReadNumber : db "Number read from user - %X",10,0
    ErrorY : db "wrong Y value",10,0
    printcalc : db "calc: " ,0
    quitFormat : db "%X",10,0

section .text
  align 16
     global main
     extern printf
     extern fflush
     extern malloc
     extern calloc
     extern free
     extern getchar
     extern gets
     extern fgets
     extern stdin
main: 
push ebp
mov ebp,esp
mov [numOfOperations],dword 0
mov byte [quitFlag],'0'
mov byte [stackPointer] , 0
mov byte [debugflag],'0'
call myCalc
ret
myCalc:
    mov byte [firstRun] ,'0'
    cmp byte [quitFlag],'1'
    jz quit2
    mov byte[PopDebugflag],'0'
    mov byte [Pushflag],'0'
    mov byte [PosError1],'0'
    mov byte [PosError2],'0'
    mov byte [negPowerPush1],'0'
    mov byte [negPowerPush2],'0'
    mov [temp] , dword 0
    mov [temp1] , dword 0
    mov [temp2] , dword 0
    push printcalc
    call printf
    add esp,4
    mov byte [isOddNum] , '0'
    mov byte [carry] , '0'
    mov [head] , dword 0
    mov eax,0
    push eax
    push ebx
    push ecx
    push edx
    push dword [stdin]
    push buffLength
    push buffer
    call fgets
    add esp,12
    pop edx
    pop ecx
    pop ebx
    pop eax
    mov esi,0
    mov esi, buffer
    mov ecx,0
    cmp  byte [esi],'q'
    jz quit
    cmp byte [esi],'-'
    jz DebugCase
    cmp  byte [esi],43
    jz plusCase
    cmp  byte [esi],'p'
    jz popCase
    cmp  byte [esi],'d'
    jz duplicateCase
    cmp  byte [esi],'^'
    jz posPowerCase
    cmp  byte [esi],'v'
    jz negPowerCase
    cmp  byte [esi],'n'
    jz numOf1sCase
    cmp  byte [esi],'s'
   ; jz squareCase
    cmp  byte [esi],10
    jz myCalc
    jmp numberCase

    DebugCase:
    inc esi
    cmp byte [esi], 'd'
    jz DebugMode
    jmp myCalc
DebugMode:
    mov byte [debugflag],'1'
    jmp myCalc


numberCase:
checkLength:
    cmp [esi],byte 10
    jnz addToCounter
    jmp checkEven
addToCounter:
    inc ecx
    inc esi
    jmp checkLength   
checkEven: 
   mov esi, buffer ; move pointer to start of buffer again
   mov dl , [esi] 
   cmp ecx,1
   jz onlyOneDigit
   shr ecx,1 ;check if its odd length number
   jc odd
   jmp continueNum
odd:
    inc esi ;move to the second digit - we will push it back in the end.
    mov dl,[esi] 
    mov byte [isOddNum] , '1' 
    jmp continueNum

onlyOneDigit: ;act like the first digit is 0
mov ebx,0
jmp conGetSecondDigit

continueNum:
    cmp dl ,10
    jz checkOdd
    cmp dl ,'A'
    jge fromAtoZ
    sub dl,48
    jmp getSecondDigit
fromAtoZ:
    sub dl,55
    
getSecondDigit:
    mov ebx, edx
    inc esi
conGetSecondDigit:
    mov dl , [esi]
    cmp dl,'A'
    jge fromAtoZ2
    sub dl ,48
    jmp calculateDecimal
fromAtoZ2:
    sub dl ,55

calculateDecimal:
    shl ebx,4
    add edx ,ebx
    mov ecx, edx
    jmp createList
createList:
    mov eax,0
    mov eax , ecx
    mov [currentNum] , al ;currentNum hold the current number
    pushad
    push esi
    push dword 5
    push dword 1
    call calloc
    add esp,8
    pop esi
    mov ebx,0
    mov edx,0
    mov bl, byte [currentNum]
    mov  [eax+4] , bl 
    mov edx , [head]
    mov [eax], edx
    mov [head], dword eax
    inc esi
    mov dl , [esi]
    jmp continueNum
    checkOdd:
    cmp byte [isOddNum], '1' ;if its odd number , add the first num 
    jnz pushToOperandStack
addFirstNode: 
   mov esi, [head] 
   mov ebx,[head]
loopFirstNode: ;move to the end of the list to add the first digit
   cmp [ebx], dword 0
   jz addFirstNode2
   mov ecx,[ebx]
   mov ebx,ecx
   jmp loopFirstNode
addFirstNode2:;adding the first node
   push ebx
   push esi
   push 5
   push 1
   call calloc
   add esp,8
   pop esi
   pop ebx
   mov edi, buffer
   mov edx,0
   mov dl , [edi]
   cmp dl, 'A'
   jge fromAtoZ3
   sub edx, 48
   jmp addFirstNode3
fromAtoZ3:
   sub dl,55
addFirstNode3:
   mov [eax+4], dl
   mov [ebx], eax
   mov [head],  esi



pushToOperandStack:
    cmp word [currentStacksize],5
    mov byte [Pushflag],'1'
    jz overflow
    mov ebx,0
    mov ebx, [head]
    mov eax,0
    mov al,byte [stackPointer]
    shl eax , 2
    mov [operad_stack+eax] , dword ebx
    mov eax,0
    mov al,byte [stackPointer];inc stack pointer
    inc eax
    mov [stackPointer],byte al
    cmp byte [debugflag],'1'
    mov eax,ebx
    jz printList
    

PushNoDebug:    
    inc word [currentStacksize]
    cmp byte [PosError1],'1'
    jz posPowerErrorEmpty
    cmp byte [PosError2],'1' 
    jz posPowerError1Pop
    cmp byte [negPowerPush2],'1'
    jz negPowerError2
    cmp byte [negPowerPush1],'1'
    jz negPowerError1
    jmp myCalc  
                   
      
overflow:
    push overflowError
    call printf
    add esp,4
    jmp myCalc 

popCase:
    mov byte[PopDebugflag],'1'
    cmp byte [quitFlag],'1' ; not increase num of operation when using q .
    jz PopWithoutInc
    inc dword [numOfOperations]
PopWithoutInc:
    cmp word [currentStacksize] , 0
    jz emptyError
    mov edi,0
    mov edi,[currentStacksize]
    dec edi
    mov [currentStacksize] , edi
    mov ebx,0
    mov bl, [stackPointer]
    dec ebx
    mov [stackPointer] , bl
    shl ebx,2
    mov eax , dword [operad_stack+ebx]
    mov edx,eax
    cmp byte [quitFlag],'1'
    jnz printList
    push edx
    call cleanList
    add esp,4
    cmp byte [quitFlag],'1'
    jz quit2

printList:;reverse to print the number in the right order
mov  [firstRun] , byte '0'
ReverseNodesPrint:
    mov [head], dword 0
    mov ebx,eax
    mov [temp],ebx
LoopReversePrint:
    push ebx
    push dword 5
    push dword 1
    call calloc
    add esp,8
    mov ebx,0
    pop ebx
    mov ecx , dword [ebx+4]
    mov [eax+4] , dword ecx
    mov esi,0
    mov esi , [head]
    mov [eax] ,esi
    mov [head], dword eax
    mov edx, [head]
    cmp [ebx] ,dword 0
    jz afterReverse
    mov ecx,0
    mov ecx , [ebx]
    mov ebx,0
    mov ebx,ecx
    jmp LoopReversePrint  


afterReverse:    
    mov [addZero] , byte '0'
    mov ebx,0
    mov bl, [edx+4] ;start checking if we need to remove leading zero.
    cmp [firstRun] , byte '0' ;check if its the starting of the number
    jnz conAfterReverse 
    cmp bl,0 ;check if the digit is 0
    jnz conAfterReverse
    cmp [edx] ,dword  0 ;check if its only the number 0 . 
    jz conAfterReverse
    mov edx, [edx]
    jmp afterReverse
conAfterReverse:
    cmp [firstRun] , byte '0'
    je conPrintList
    cmp ebx,16; more then 15,no need zero
    jge conPrintList
    mov [addZero] , byte '1'
conPrintList:
    cmp [addZero] , byte '1' ;add zeroes to num if we are not in the start of the num 
    jnz nextNum
    push edx
    push 0
    push formatNum
    call printf
    add esp,8
    pop edx
    nextNum:
    cmp byte [PopDebugflag],'1'
    jz PrintNoDebug
    cmp byte [debugflag],'1'
    jnz PrintNoDebug

    pushad ;Print number pushed to stack in debug mode
    push ebx
    push DebugPushed
    call printf
    add esp,8
    popad

    pushad ;Print number read fro user in debug mode
    push ebx
    push DebugReadNumber
    call printf
    add esp,8
    popad


PrintNoDebug:    
    push edx
    push ebx
    push formatNum
    call printf
    add esp,8
    pop edx
    mov ecx, dword [edx]
    mov edx,ecx
    cmp edx,dword 0
    mov [firstRun] , byte '1'
    jne afterReverse
    push nextline
    call printf
    add esp,4
    cmp byte [debugflag],'1'
    jz PrintNoDebug2
    mov eax,[head]
    push eax
    call cleanList
    add esp,4
    mov eax,[temp]
    push eax
    call cleanList
    add esp,4
PrintNoDebug2:    
    cmp byte [Pushflag],'1'
    jz PushNoDebug
    jmp myCalc

emptyError:
    push popEmptyError
    call printf
    add esp,4
    jmp myCalc 
 
 duplicateCase:
    inc dword [numOfOperations]
    ;get the top number of the operad stack
    cmp word [currentStacksize] , 0
    jz emptyError
    cmp word [currentStacksize] , 5
    jz overflow
    mov ebx,0
    mov bl, [stackPointer]
    dec ebx
    mov [stackPointer] , bl
    mov edi,ebx
    shl edi,2
    mov eax , dword [operad_stack+edi]
    inc ebx
    mov [stackPointer] , bl
    mov esi,0
    mov ebx,eax

LoopDuplicate:
    push ebx
    push dword 5
    push dword 1
    call calloc
    add esp,8
    mov ebx,0
    pop ebx
    ;insert the num to the new nod and update the pointers
    mov ecx , dword [ebx+4] 
    mov [eax+4] , dword ecx
    mov esi,0
    mov esi , [head]
    mov [eax] ,esi
    mov [head], dword eax
    cmp [ebx] ,dword 0
    jz LoopDuplicate2
    mov ecx,0
    mov ecx , [ebx]
    mov ebx,0
    mov ebx,ecx
    jmp LoopDuplicate
LoopDuplicate2:
    mov eax, dword [head]
    mov [head], dword 0
    mov ebx,eax
    mov [temp] , ebx
LoopDuplicate3:
    push ebx
    push dword 5
    push dword 1
    call calloc
    add esp,8
    mov ebx,0
    pop ebx
    mov ecx , dword [ebx+4]
    mov [eax+4] , dword ecx
    mov esi,0
    mov esi , [head]
    mov [eax] ,esi
    mov [head], dword eax
    cmp [ebx] ,dword 0
    jz cleanDupAndPush
    mov ecx,0
    mov ecx , [ebx]
    mov ebx,0
    mov ebx,ecx
    jmp LoopDuplicate3


cleanDupAndPush:
    mov eax, 0
    mov eax,[temp]
    push eax
    call cleanList
    add esp,4
    jmp pushToOperandStack


  

  cleanList:
     push ebp
     mov ebp,esp
     mov eax,[ebp+8];get argument
     mov edx,0
        cleanLoop:
        cmp eax,0; eax is the list we need to delete
        je cleanFinish
        mov edx,dword[eax];edx is the next link
        pushad
        push eax
        call free
        add esp,4
        popad
        mov eax,edx
        jmp cleanLoop
        cleanFinish:
     mov esp,ebp
     pop ebp
     ret 
        
plusCase:
    mov byte [carry] , '0'
    inc dword [numOfOperations]
    cmp word [currentStacksize] , 0
    jz emptyError
    mov edi,0
    mov edi,[currentStacksize]
    dec edi
    mov [currentStacksize] , edi
    mov ebx,0
    mov bl, [stackPointer]
    dec ebx
    mov [stackPointer] , bl
    shl ebx,2
    mov edi , dword [operad_stack+ebx] ; edi holds the first argument 
    mov [temp1], edi

    cmp word [currentStacksize] , 0
    jz PushBackXAndError
    mov esi,0
    mov esi,[currentStacksize]
    dec esi
    mov [currentStacksize] , esi
    mov ebx,0
    mov bl, [stackPointer]
    dec ebx
    mov [stackPointer] , bl
    shl ebx,2
    mov esi , dword [operad_stack+ebx] ; esi holds the second argument
    mov [temp2] , esi

 calculatePlus:
    mov edx,0
    cmp [carry] , byte '1'
    jnz continueCalcPlus
    inc dl ;add the carry
continueCalcPlus:    
    add dl , [edi+4]
    jc makeCarryFlag ;check if carry
    jnc noCarryFlag
continueCalcPlus3:
    add dl, [esi+4]
    jc makeCarryFlag2 ; check if carry
continueCalcPlus2:
    ;make the node with the sum of the first two nodes
    push edi
    push esi
    push edx
    push ecx
    push dword 5
    push dword 1
    call calloc
    add esp,8
    pop ecx
    pop edx
    pop esi
    pop edi
    mov [eax+4], edx
    mov edx , [head]
    mov [eax], edx
    mov [head], dword eax
    cmp [edi] ,dword 0 ;check if finish first num
    jz finishEdiNumber
    cmp [esi] ,dword 0
    jz finishEsiNumber ;check if finish second num
    mov ebx,[edi]
    mov edi,ebx
    mov ebx,[esi]
    mov esi,ebx
    jmp calculatePlus

finishEdiNumber:
    cmp [esi] , dword 0 ;check if finish the two numbers
    jz finishsecondNumber 
    mov ebx,[esi]
    mov esi,ebx
    mov edx , dword 0
    cmp [carry] , byte '1'
    jnz finishEdiNumber2
    mov edx, dword 1 ;adding the carry
finishEdiNumber2:
    add dl, [esi+4]
    jc makeCarryFlag2
    jnz noCarryFlag2
    
finishEsiNumber:
    cmp [edi] , dword 0
    jz finishsecondNumber ;check if finish the two numbers
    mov ebx,[edi]
    mov edi,ebx
    mov edx , dword 0
    cmp [carry] , byte '1'
    jnz finishEsiNumber2
    mov edx, dword 1 ;adding the carry
   
    finishEsiNumber2:
    add dl, [edi+4]
    jc makeCarryFlag2
    jnz noCarryFlag2

finishsecondNumber:
cmp [carry],byte  '1'
jz addCarryEndCalc
jnz endPlus

makeCarryFlag:
    mov [carry] , byte '1'
    jmp continueCalcPlus3
noCarryFlag:
    mov [carry] , byte '0'
    jmp continueCalcPlus3

makeCarryFlag2:
    mov [carry] , byte '1'
    jmp continueCalcPlus2

noCarryFlag2:
    mov [carry] , byte '0'
    jmp continueCalcPlus2


addCarryEndCalc: ;add node with the number 1 if there is a carry in the end
    push dword 5
    push dword 1
    call calloc
    add esp,8
    mov [eax+4], dword 1 
    mov edx , [head]
    mov [eax], edx
    mov [head], dword eax
endPlus:    
    jmp ReverseNodes


ReverseNodes:
    mov eax, dword [head]
    mov [head], dword 0
    mov ebx,eax
    mov [temp], ebx
LoopReverse:
    push ebx
    push dword 5
    push dword 1
    call calloc
    add esp,8
    mov ebx,0
    pop ebx
    mov ecx , dword [ebx+4]
    mov [eax+4] , dword ecx
    mov esi,0
    mov esi , [head]
    mov [eax] ,esi
    mov [head], dword eax
    cmp [ebx] ,dword 0
    jz cleanPlusAndPush
    mov ecx,0
    mov ecx , [ebx]
    mov ebx,0
    mov ebx,ecx
    jmp LoopReverse  

cleanPlusAndPush:
    mov eax, 0
    mov eax,[temp]
    push eax
    call cleanList
    add esp,4
    mov eax, 0
    mov eax,[temp1]
    push eax
    call cleanList
    add esp,4
    mov eax, 0
    mov eax,[temp2]
    push eax
    call cleanList
    add esp,4
    jmp pushToOperandStack


negPowerCase:
    inc dword [numOfOperations]
    ;pop first arg
    cmp word [currentStacksize] , 0
    jz emptyError
    mov edi,0
    mov edi,[currentStacksize]
    dec edi
    mov [currentStacksize] , edi
    mov ebx,0
    mov bl, [stackPointer]
    dec ebx
    mov [stackPointer] , bl
    shl ebx,2
    mov edi , dword [operad_stack+ebx] ; edi holds the X argument 
    mov [temp1] , edi ;save for cleaning

    ;pop second arg
    cmp word [currentStacksize] , 0
    jz PushBackXAndError
    mov esi,0
    mov esi,[currentStacksize]
    dec esi
    mov [currentStacksize] , esi
    mov ebx,0
    mov bl, [stackPointer]
    dec ebx
    mov [stackPointer] , bl
    shl ebx,2
    mov esi , dword [operad_stack+ebx] 
    mov eax, [esi+4]
    mov esi,eax ;; esi holds the Y argument
    mov edx,esi
    mov [counter], dword esi
    mov esi , dword [operad_stack+ebx]
    mov [temp2] , esi ;save for cleaning





    cmp [esi], dword 0 ;Checking Error on Y argument - Y is larger than 256
    jnz negPowerErrorY
    mov ebx,0
    mov bl,byte [esi+4]
    cmp ebx,201 ; Checking Error on Y argument - Y is larger than 200
    jge negPowerErrorY
    jmp reversenegPowerCase
negPowerErrorY:
    mov [head] , dword 0
    mov [head],esi ;Push Y argument back
    mov byte [negPowerPush1],'1'
    jmp pushToOperandStack
    negPowerError1:
    mov [head] , dword 0
    mov [head],edi ;Push X argument back
    mov byte [negPowerPush2],'1'
    jmp pushToOperandStack

negPowerError2: ;print Error Y
    push ErrorY
    call printf
    add esp,8
    jmp myCalc
   
reversenegPowerCase:
    mov eax, edi
    mov [head], dword 0
    mov ebx,eax
    mov [temp] , ebx
loopReversenegPowerCase:
    push ebx
    push edx
    push dword 5
    push dword 1
    call calloc
    add esp,8
    mov ebx,0
    pop edx
    pop ebx
    mov ecx , dword [ebx+4]
    mov [eax+4] , dword ecx
    mov esi,0
    mov esi , [head]
    mov [eax] ,esi
    mov [head], dword eax
    mov edi,[head]
    cmp [ebx] ,dword 0
    jz cleanNegPowerCase
    mov ecx,0
    mov ecx , [ebx]
    mov ebx,0
    mov ebx,ecx
    jmp loopReversenegPowerCase 

cleanNegPowerCase:
    mov eax,[temp]
    push eax
    call cleanList
    add esp,4

beforeCalculateNegPowerCase1:
 cmp [firstRun] , byte '0' ;check if X or Y is zero in the first run - return X
 jnz beforeCalculateNegPowerCase
 mov [head],dword 0
     mov [head],edi
     mov esi, [counter]
     cmp esi,byte 0
     jz ZeroMinus
     mov edi,dword [head]
     mov edx,0
     mov dl,byte [edi+4] 
     cmp edx,0
     jz ZeroMinus

beforeCalculateNegPowerCase:
mov esi,edx  
mov [head] , dword 0
cmp [firstRun] , byte '0'
jz calculateNegPowerCase
cmp [edi+4],dword  0 ;check if first node is zero, if so - delete it
jnz calculateNegPowerCase
cmp [edi], dword 0 ;dont delete first node if the zero is the only node 
jz calculateNegPowerCase
mov edi , [edi]
calculateNegPowerCase:
    mov [firstRun] , byte '1'
    mov edx,0
    cmp [carry] , byte '1' 
    jnz conCalculateNegPowerCase
    mov eax , 1
    shl eax,7 ; make the carry insert to the biggest bit.
    add dl , [edi+4]
    shr dl,1
    jc makeCarryFlagLowPowerCase
    jnc noCarryFlagLowPowerCase
    
conCalculateNegPowerCase:    
    mov eax,0
    mov al,0
    add dl , [edi+4]
    shr dl,1
    jc makeCarryFlagLowPowerCase
    jnc noCarryFlagLowPowerCase
   

conCalculateNegPowerCase3:;create a node after the shifting
    push edx
    push dword 5
    push dword 1
    call calloc
    add esp,8
    pop edx
    mov [eax+4], edx
    mov edx , [head]
    mov [eax], edx
    mov [head], dword eax
    cmp [edi] ,dword 0
    jz checkFinishY
    jnz conCalculateNegPowerCase4

checkFinishY: ;when finish one iteration over the number - decrease counter and check if it zero
    mov edi, [head]
    dec byte [counter]
    cmp byte [counter],0
    jz reverseBeforePush 
    mov [head] ,dword 0
    mov [carry] , byte '0'
    jmp reversenegPowerCase

conCalculateNegPowerCase4:
    mov ebx,[edi]
    mov edi,ebx
    jmp calculateNegPowerCase



makeCarryFlagLowPowerCase: ;add the carry (if no carry so 0) and make carry flag
  add dl,  al
  mov [carry] , byte '1'
  jmp conCalculateNegPowerCase3
  

noCarryFlagLowPowerCase: ;;add the carry (if no carry so 0) and remove carry flag
  add dl, al
  mov [carry] , byte '0'
  jmp conCalculateNegPowerCase3

reverseBeforePush:
    mov eax, edi
    mov [head], dword 0
    mov ebx,eax
    mov [temp] , ebx
loopReverseBeforePush:
    push ebx
    push edx
    push dword 5
    push dword 1
    call calloc
    add esp,8
    mov ebx,0
    pop edx
    pop ebx
    mov ecx , dword [ebx+4]
    mov [eax+4] , dword ecx
    mov esi,0
    mov esi , [head]
    mov [eax] ,esi
    mov [head], dword eax
    mov edi,[head]
    cmp [ebx] ,dword 0
    jz endNegPowerCase
    mov ecx,0
    mov ecx , [ebx]
    mov ebx,0
    mov ebx,ecx
    jmp loopReverseBeforePush 



endNegPowerCase: ;remove starting zero - dont remove if its the only zero
    cmp [edi+4],dword 0
    jnz ReverseNodes
    cmp [edi] , dword 0
    jz ReverseNodes
    mov edi,[edi]
    mov [head] ,dword edi
    jmp ReverseNodes
  



posPowerCase:
    inc dword [numOfOperations]
    cmp word [currentStacksize] , 0 
    jz emptyError
    mov edi,0
    mov edi,[currentStacksize]
    dec edi
    mov [currentStacksize] , edi
    mov ebx,0
    mov bl, [stackPointer]
    dec ebx
    mov [stackPointer] , bl
    shl ebx,2
    mov edi , dword [operad_stack+ebx] ; edi holds the X argument 

    cmp edi,0
    jz posPowerErrorEmpty;Checking if the stack is empty when popping
    mov [head],edi

    cmp word [currentStacksize] , 0 
    jz PushBackXAndError
    mov esi,0
    mov esi,[currentStacksize]
    dec esi
    mov [currentStacksize] , esi
    mov ebx,0
    mov bl, [stackPointer]
    dec ebx
    mov [stackPointer] , bl
    shl ebx,2
    mov esi , dword [operad_stack+ebx] ; esi holds the Y argument

    cmp esi,0
    jz posPowerError1Pop;Checking if the stack is empty when popping

     cmp [esi], dword 0
     jnz posPowerError2Pop; Y is larger then 256 - error
     mov ebx,0
     mov bl,byte [esi+4]
     cmp ebx, 201
     jge posPowerError2Pop; Y is larger then 200 - error
     push esi ;push operand Y to stack(for free at the end)
     mov ecx,0
     mov cl,byte[esi+4]
     mov byte [carry],'0'
     cmp [esi+4],byte 0
     jz ZeroPlus
     mov edi,dword [head]
     mov edx,0
     mov dl,byte [edi+4] 
     cmp edx,0
     jz ZeroPlus
CalculatePosPower:
            mov edi,dword [head]
            mov byte [carry],'0'
            mulby2:;A loop that multiplies by 2
            mov edx,0
            mov dl,byte [edi+4] 
            shl edx,1
            cmp byte [carry],'0'
            jz noCarryfirstNode
            inc edx
            mov byte [carry],'0'
            noCarryfirstNode:
            cmp edx,256
            jl noCarryOtherNodes
            mov byte [carry],'1'
            noCarryOtherNodes:
            mov eax,dword edi
            mov [eax+4],byte dl
            mov ebx,edi;save the last node address (for carry last node)
            mov eax,dword [eax]          
            mov edi,dword eax; edi points to the next node
            cmp edi,dword 0
            jnz mulby2; Calculate next node
            cmp byte [carry],'1';Check carry at the last node
            jnz noCarryLastNode
            pushad
            push dword 5;create node with a value of 1
            push dword 1
            call calloc
            add esp,8
            mov [eax+4],byte 1
            mov [ebx],dword eax
            popad
            noCarryLastNode:
            loop CalculatePosPower,ecx
     ZeroPlus:
     call cleanList ;Clean Y operand
     add esp,4
     jmp pushToOperandStack ; reverse and push
     ZeroMinus:
        jmp LoopDuplicate2

     posPowerError2Pop:
     mov byte [PosError2],'1'
     mov [head], dword 0
     mov [head],esi ;Push Y back to stack
     jmp pushToOperandStack
     posPowerError1Pop: 
     mov byte [PosError1],'1'
     mov [head], dword 0
     mov [head],edi
     jmp pushToOperandStack ;Push X back to stack
     posPowerErrorEmpty:
        push ErrorY
        call printf
        add esp,8
        jmp myCalc

numOf1sCase:
    inc dword [numOfOperations]
    cmp word [currentStacksize] , 0
    jz emptyError
    mov edi,0
    mov edi,[currentStacksize]
    dec edi
    mov [currentStacksize] , edi
    mov ebx,0
    mov bl, [stackPointer]
    dec ebx
    mov [stackPointer] , bl
    shl ebx,2
    mov edi , dword [operad_stack+ebx]
    mov eax,edi ;eax holds the argument
    mov[temp1],edi



     mov ecx,0 ;counter
loopNumof1sCase:
     mov ebx,dword 0
     mov bl,byte [eax+4]
makeZero:
     shr ebx,1
     jnc nextLink ;carry is 0 - dont inc counter
     inc ecx
nextLink:
     cmp ebx,0
     jne makeZero     
     cmp [eax],dword 0
     mov eax,dword[eax]
     jne loopNumof1sCase
     
     mov [currentNum], cl
     push ecx
     push dword 5
     push dword 1
     call calloc
     add esp,8
     mov edx,0
     mov dl, byte [currentNum] 
     mov  [eax+4],dl
     pop ecx
     mov edi, eax ;  head of number

makeListNum1Bit:
     shr ecx,8
     cmp ecx,0
     jz endNumOf1sBit
     push ecx
     mov [currentNum], cl
     mov ebx,eax; ebx is now pointer to the last link
     push ebx
     push dword 5
     push dword 1
     call calloc
     add esp,8
     pop ebx
     mov [ebx],dword eax
     pop ecx
     mov  [eax+4],cl
     jmp makeListNum1Bit
     
endNumOf1sBit:
     mov [head],edi
     jmp cleanNAndPush
    
     
cleanNAndPush:
    mov eax,[temp1]
    push eax
    call cleanList
    add esp,4
    jmp pushToOperandStack

    
    
PushBackXAndError:
     
     
     push popEmptyError
     call printf
     add esp,8
     mov [head],dword 0
     mov [head],edi
     jmp pushToOperandStack
     
    
    
    
    
    
    quit:
        mov byte [quitFlag],'1'
        cmp word[currentStacksize],0 
        jz continueClean
        jmp popCase
    quit2:
        jmp quit   
    continueClean:
        mov esi,[numOfOperations]
        push esi
        push quitFormat
        call printf    
        add esp,8
        mov esp,ebp
        pop ebp
        ret



























