.section .data
mensaje_total: .asciz "Hola como estas;3,4,2,1,5;c"


mensaje_nueva_linea: .asciz "\n"   @ Carácter de nueva línea


.bss

mensaje:
    .space 30
    .align 4

mensaje_cifrado:
    .space 30
    .align 4


codificador:
    .space 30
    .align 4

tipo:
    .space 30
    .align 4

.section .text
.globl main

main:
    @ Dirección del mensaje
    ldr r6, =mensaje_total

    @ Registro para almacenar el índice
    mov r2, #0

    ldr r4, =mensaje
    bl loop
    mov r8, r4



    add r6, r6, r2
    pop {r2, r3, r4}
    ldr r4, =codificador

    mov r2, #0  

    bl loop
    mov r12, r4
    add r6, r6, r2
    mov r11, r6

    @ Cargar la dirección de mensaje en r8
    mov r1, r8
    bl mostrar_mensaje
    bl espacio


    @ Cargar la dirección de desplazamientos en r12
    mov r1, r12

    bl mostrar_mensaje
    bl espacio



    @ Cargar la opcion en r11
    mov r1, r11


    bl mostrar_mensaje

    mov r10, r12
    pop {r0, r1, r2, r3, r4, r5, r6, r7}
    @ Cargar la dirección de mensaje_cifrado en r9
    ldr r9, =mensaje_cifrado

    bl cifrar_mensaje


    @ Mostrar el mensaje cifrado en pantalla
    mov r7, #4          @ Número de servicio para imprimir
    mov r0, #1          @ Descriptor de archivo 
    mov r2, #15         @ Tamaño de la cadena
    mov r1, r9
    swi 0               @ Llamada al sistema para escribir en la salida estándar


    bl espacio


    @ Salir del programa
    mov r7, #1          @ Número de servicio para salir del programa
    mov r0, #0          @ Código de retorno
    swi 0               @ Llamada al sistema para escribir en la salida estándar

espacio:
    @ Mostrar una nueva linea
    mov r7, #4          @ Número de servicio para imprimir
    mov r0, #1          @ Descriptor de archivo 
    mov r2, #1         @ Tamaño de la cadena
    ldr r1, =mensaje_nueva_linea
    swi 0               @ Llamada al sistema para escribir en la salida estándar
    bx lr



mostrar_mensaje:
    @ Mostrar el mensaje a por pantalla
    mov r7, #4          @ Número de servicio para imprimir
    mov r0, #1          @ Descriptor de archivo 
    mov r2, #15         @ Tamaño de la cadena
    swi 0               @ Llamada al sistema para escribir en la salida estándar
    bx lr

loop:
    @ Cargar el byte actual del mensaje
    ldrb r3, [r6, r2]

    @ Comparar el byte del mensaje con el separador
    cmp r3, #';'
    @ Si son iguales, terminar el loop
    beq end_loop

    cmp r3, #','
    beq saltear  

    @ Si no son iguales, incrementar el índice
    strb r3, [r4, r2]
    add r2, r2, #1
    @ Volver al inicio del loop
    b loop

end_loop:
    @ Asignar un byte nulo al final de la cadena
    add r2, r2, #1
    bx lr

saltear:
    add r2, r2, #1
    b loop


no_espacio:
    strb r5, [r9, r3]   @ Almacenar el carácter cifrado
    add r3, r3, #1
    b bucle_cifrado

reset_index:
    mov r4, #0  @ Resetea el índice a 0 si alcanza 5
    b bucle_cifrado  @ Salto de vuelta al inicio del bucle



cifrar_mensaje:
    @ Inicializar registros
    mov r3, #0          @ Índice de mensaje
    mov r4, #0          @ Índice de desplazamientos

bucle_cifrado:
    ldrb r5, [r8, r3]   @ Cargar el carácter actual del mensaje
    ldr r6, [r10, r4]  @ Cargar el desplazamiento actual

    cmp r4, #4  @ Comprueba si r4 alcanzó el límite
    beq reset_index  @ Si r4 = 5, reinicia el índice a 0


    @ Verifica que no cifrar el espacio
    cmp r5, #' '      @ Aquí es donde se compara con el espacio
    beq no_espacio

    @ Aplicar el desplazamiento
    add r5, r5, r6
    cmp r5, #'z'
    ble caracter_cifrado

    ldrb r7, [r8, r3]
    cmp r7, #0
    bx lr

caracter_cifrado:
    strb r5, [r9, r3]   @ Almacenar el carácter cifrado
    add r3, r3, #1
    add r4, r4, #1
    b bucle_cifrado