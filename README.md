### Universidade Estadual do Oeste do Paraná
### Disciplina: Linguagens de Montagem

---

#### **Trabalho proposto:**
- Criar um algoritmo em Assembly que realiza o cálculo de Padovan dada a entrada do usuário e armazenar o resultado em um arquivo.
- Detalhes podem ser encontrados no PDF [LM - Atividade Avaliativa 01 v2024](https://github.com/yVinicin/Padovan---Assembly/blob/main/LM%20-%20Atividade%20Avaliativa%2001%20v2024.pdf).

---

### Uso:

Para montar:
```
nasm -f elf64 Padovan.asm
```

Para linkar:
```
ld Padovan.o -o Padovan.x
```

Para executar:
```
./Padovan.x
```
