; Nome: Thalita Wiederkehr
; Nome: Vinicius Mattos Marcos

; Atividade Prática Avaliativa 01 - Sequência de Padovan

; Comando de montagem e ligação:
; nasm -f elf64 Padovan.asm ; ld Padovan.o -o Padovan.x

%define tamanhoMax 3
%define createopenrw 102o ; flag open() - criar + leitura e escrita
%define userWR 644o       ; Read+Write: -rw-r--r--

section .data
    strErroMaisDeDoisCaracteres : db "Erro: Entrada com mais de dois digitos!", 10, "Arquivo de solução não criado!", 10, 0
    strErroMaisDeDoisCaracteresL: equ $ - strErroMaisDeDoisCaracteres

    strErroCharAlfabetico : db "Erro: Entrada com caractere(s) não numéricos!", 10, "Arquivo de solução não criado!", 10, 0
    strErroCharAlfabeticoL : equ $ - strErroCharAlfabetico

    fileName : db "p(n).bin", 0

section .bss
    n : resb 3                  ; Buffer para até 3 caracteres
    resultado_padovan resq 1    ; Armazenar o resultado da sequência
    charLimpaBuffer : resb 1    ; Variável para limpar o buffer de entrada
    fileHandle : resd 1         ; Handle do arquivo

section .text
    global _start

_start:
    ; Leitura de entrada do usuário
    mov rax, 0                ; syscall: read
    mov rdi, 0                ; file descriptor: stdin
    lea rsi, [n]              ; buffer para armazenar entrada
    mov rdx, 3                ; ler até 3 caracteres (2 dígitos + newline)
    syscall

    ; Verificação da entrada
    movzx rax, byte [n]       ; Primeiro caractere
    cmp byte [n], 10          ; Verifica se o primeiro caractere é "Enter"
    je Erro_CaractereAlfabetico
    cmp rax, '0'              ; Verifica se é um dígito
    jl Erro_CaractereAlfabetico
    cmp rax, '9'
    jg Erro_CaractereAlfabetico

    ; Verificar segundo caractere (se existir)
    movzx rax, byte [n+1]     ; Segundo caractere
    cmp rax, 10               ; Se for newline, pula verificação
    je conversao_ascii
    cmp rax, '0'              ; Verifica se é um dígito
    jl Erro_CaractereAlfabetico
    cmp rax, '9'
    jg Erro_CaractereAlfabetico

    ; Verificar se existe um terceiro caractere (não deveria)
    movzx rax, byte [n+2]
    cmp rax, 10               ; Se for newline, está OK
    je conversao_ascii
    jmp Erro_MaisDeDoisCaracteres

Erro_CaractereAlfabetico:
    ; Exibe a mensagem de erro e encerra o programa caso a entrada tenha caracteres não numéricos
    mov rax, 1
    mov rdi, 1
    mov rsi, strErroCharAlfabetico
    mov rdx, strErroCharAlfabeticoL
    syscall
    jmp limpar_buffer

Erro_MaisDeDoisCaracteres:
    ; Exibe a mensagem de erro e encerra o programa caso a entrada seja maior que dois caracteres
    mov rax, 1
    mov rdi, 1
    mov rsi, strErroMaisDeDoisCaracteres
    mov rdx, strErroMaisDeDoisCaracteresL
    syscall
    jmp limpar_buffer

; Conversão de ASCII para número inteiro
conversao_ascii:
    ; Converte o primeiro dígito de ASCII para número
    movzx rax, byte [n]
    sub rax, '0'   ; subtrai o valor ASCII de '0'
    mov rbx, rax   ; guarda o primeiro dígito em rbx

    ; Se tem um segundo dígito
    cmp byte [n+1], 10
    je calculo_padovan ; se for newline, pula para o cálculo

    ; Converte o segundo dígito de ASCII para número
    movzx rax, byte [n+1]
    sub rax, '0'   ; subtrai o valor ASCII de '0'
    imul rbx, rbx, 10  ; Multiplica o primeiro dígito por 10
    add rbx, rax       ; Adiciona o segundo dígito ao resultado

calculo_padovan:
    mov rcx, rbx  ; coloca n(entrada) em rcx

    mov rbx, 1    ; P(0) = 1
    mov rdx, 1    ; P(1) = 1
    mov rsi, 1    ; P(2) = 1

    ; Se n for 0, 1 ou 2, o resultado é 1
    cmp rcx, 0
    je renomeia_aqruivo
    cmp rcx, 1
    je renomeia_aqruivo
    cmp rcx, 2
    je renomeia_aqruivo

; Loop para calcular P(n)
padovan_loop:
    mov rdi, rbx    ; P(n-3)
    add rdi, rdx    ; P(n) = P(n-2) + P(n-3)
    mov rbx, rdx    ; P(n-3) = P(n-2)
    mov rdx, rsi    ; P(n-2) = P(n-1)
    mov rsi, rdi    ; P(n-1) = P(n)

    dec rcx         ; Decrementa o contador
    cmp rcx, 2      ; Continua até rcx == 2
    jg padovan_loop

    mov rsi, rdi    ; O valor final de P(n)

; Substitui o 'n' do nome do arquivo para a entrada do usuário
renomeia_aqruivo:
    movzx rax, byte [n]
    sub rax, '0'                ; Converte o primeiro dígito para valor numérico
    add rax, '0'                ; Transforma de volta para caractere ASCII
    mov byte [fileName+2], al   ; Insere o primeiro dígito no nome do arquivo

    ; Verifica se há um segundo dígito
    cmp byte [n+1], 10          ; Verifica se o segundo caractere é newline
    je unico_digito             ; Se for newline, trata como número de um dígito

    ; Caso haja um segundo dígito
    movzx rax, byte [n+1]       ; Converte o segundo dígito de ASCII para número
    sub rax, '0'
    add rax, '0'                ; Transforma de volta para caractere ASCII
    mov byte [fileName+3], al   ; Insere o segundo dígito no nome do arquivo

    ; Ajusta o parêntese de fechamento para dois dígitos
    mov byte [fileName+4], ')'  ; Fecha o parêntese após o segundo dígito
    ; Coloca o ponto e a extensão ".bin" corretamente
    mov byte [fileName+5], '.'  ; Ponto da extensão
    mov byte [fileName+6], 'b'
    mov byte [fileName+7], 'i'
    mov byte [fileName+8], 'n'
    mov byte [fileName+9], 0    ; Terminador nulo
    jmp resultado_salvo

unico_digito:
    ; Ajusta o parêntese de fechamento para um único dígito
    mov byte [fileName+3], ')'  ; Fecha o parêntese após o primeiro dígito
    ; Coloca o ponto e a extensão ".bin" corretamente
    mov byte [fileName+4], '.'  ; Ponto da extensão
    mov byte [fileName+5], 'b'
    mov byte [fileName+6], 'i'
    mov byte [fileName+7], 'n'
    mov byte [fileName+8], 0    ; Terminador nulo

resultado_salvo:
    ; Salva o resultado final de P(n) em local temporário
    mov [resultado_padovan], rsi

    ; Abre o arquivo binário
    mov rax, 2          ; syscall: open
    mov rdi, fileName   ; nome do arquivo
    mov rsi, createopenrw
    mov rdx, userWR
    syscall
    mov [fileHandle], eax

    ; Grava o resultado no arquivo binário
    mov rdi, rax
    mov rax, 1
    lea rsi, [resultado_padovan]
    mov rdx, 8
    syscall

    ; Fechar o arquivo
    mov rax, 3          ; syscall: close
    mov rdi, [fileHandle]
    syscall

limpar_buffer:
    ; Limpa o buffer extra, se necessário
    cmp byte [n+2], 10         ; Verifica se já temos newline
    je fim

loop_limpar_buffer:
    mov rax, 0 ; READ
    mov rdi, 0 ; stdin
    lea rsi, [charLimpaBuffer]
    mov rdx, 1 ; Lê 1 byte
    syscall
    cmp byte [charLimpaBuffer], 10 ; Verifica se é newline (ASCII 10)
    je fim
    jne loop_limpar_buffer         ; Continua lendo se não for newline

fim:
    ; Finaliza o programa
    mov rax, 60
    mov rdi, 0
    syscall
