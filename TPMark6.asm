.data

mensajePrincipal:
    .ascii "Bienvenido a programa incriptar y descriptador"

mensajeACriptar:
    .asciz "hola como estas"

mensaje_nueva_linea:
    .asciz "\n"   @ Carácter de nueva línea

mensajeFinal:
    .ascii "ave, true to Caesar mean"


desplazamientos:
    .word 3, 4, 2, 1, 5

.bss
mensaje_cifrado:
    .space 30
    .align 4

.text
.global main

main:
    @ Mostrar el mensaje principal en pantalla
    mov r7, #4          @ Número de servicio para imprimir
    mov r0, #1          @ Descriptor de archivo
    mov r2, #45         @ Tamaño de la cadena
    ldr r1, =mensajePrincipal
    swi 0               @ Llamada al sistema para escribir en la salida estándar

    bl espacio

    @ Mostrar el mensaje a cifrar en pantalla
    mov r7, #4          @ Número de servicio para imprimir
    mov r0, #1          @ Descriptor de archivo 
    mov r2, #15         @ Tamaño de la cadena
    ldr r1, =mensajeACriptar
    swi 0               @ Llamada al sistema para escribir en la salida estándar

    bl espacio

    @ Cargar la dirección de mensaje en r8
    ldr r8, =mensajeACriptar

    @ Cargar la dirección de mensaje_cifrado en r9
    ldr r9, =mensaje_cifrado

    @ Cargar la dirección de desplazamientos en r10
    ldr r10, =desplazamientos

    @ Llamar a la función de cifrado
    bl cifrar_mensaje


    @ Mostrar el mensaje cifrado en pantalla
    mov r7, #4          @ Número de servicio para imprimir
    mov r0, #1          @ Descriptor de archivo 
    mov r2, #15         @ Tamaño de la cadena
    mov r1, r9
    swi 0               @ Llamada al sistema para escribir en la salida estándar


    bl espacio


    @ Mostrar el mensaje a final en pantalla
    mov r7, #4          @ Número de servicio para imprimir
    mov r0, #1          @ Descriptor de archivo 
    mov r2, #24         @ Tamaño de la cadena
    ldr r1, =mensajeFinal
    swi 0               @ Llamada al sistema para escribir en la salida estándar	

    @ Salir del programa
    mov r7, #1          @ Número de servicio para salir del programa
    mov r0, #0          @ Código de retorno
    swi 0

espacio:
    @ Mostrar una nueva linea
    mov r7, #4          @ Número de servicio para imprimir
    mov r0, #1          @ Descriptor de archivo 
    mov r2, #1         @ Tamaño de la cadena
    ldr r1, =mensaje_nueva_linea
    swi 0               @ Llamada al sistema para escribir en la salida estándar
    bx lr

cifrar_mensaje:
    @ Inicializar registros
    mov r3, #0          @ Índice de mensaje
    mov r4, #0          @ Índice de desplazamientos

bucle_cifrado:
    ldrb r5, [r8, r3]   @ Cargar el carácter actual del mensaje
    ldr r6, [r10, r4]    @ Cargar el desplazamiento actual

    @ Verificar si el carácter es una letra minúscula
    cmp r5, #'a'
    blt no_cifrar
    cmp r5, #'z'
    bgt no_cifrar

    @ Aplicar el desplazamiento
    add r5, r5, r6
    cmp r5, #'z'
    ble caracter_cifrado
    sub r5, r5, #26

caracter_cifrado:
    strb r5, [r9, r3]   @ Almacenar el carácter cifrado

no_cifrar:
    @ Actualizar índices
    add r3, r3, #1
    add r4, r4, #4

    @ Verificar si hemos llegado al final del mensaje
    ldrb r7, [r8, r3]
    cmp r7, #0
    bne bucle_cifrado

    @ Terminar la cadena cifrada con un carácter nulo
    strb r7, [r9, r3]

    bx lr