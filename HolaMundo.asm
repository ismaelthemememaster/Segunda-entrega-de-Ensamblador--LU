
;C�digo programado por Ismael Restrepo Y Juan Fernando Misas

;Este programa soluciona ecuaciones matriciales con la descomposicion LU


INCLUDE Irvine32.inc
.386					;No se que tiene de diferente usar el 686; asi que mejor hagamosle a este, por si acaso
.MODEL FLAT, STDCALL
.stack 


;----------------------------------------------------------------------------------------------------
;Aqui se declaran bytes de impresion para mostrar mensajes al usuario
;----------------------------------------------------------------------------------------------------

.data

	;Los "strings" necesarios para darle la bienvenida al usuario
	bienvenida		BYTE	"Bienvenido al �nico codigo que soluciona ecuaciones matriciales con la descomposicion LU que existe ", 0
	asignatura		BYTE	"Este programa ha sido realizado para el curso de Arquitectura de computadores, primer semestre del 2017", 0
	identificacion	BYTE	"Programado por Ismael Restrepo y Juan Fernando Misas,", 0
	CC				BYTE	"identificados con CC 1152712444 y ######## respectivamente", 0
	

	query			BYTE	"Ingrese el tamano de la matriz", 0
	nfilas			BYTE	"Ingrese el numero de filas",0
	ncolumnas		BYTE	"Ingrese el numero de columnas",0
	efilas			BYTE	"Tamano invalido para las filas el tamano maximo es 10",0
	ecolumnas		BYTE	"Tamano invalido para las columnas el tamano maximo es 10",0
eMatrizNoCuadrada	BYTE	"El metodo de Jacobi solo se aplica para matrices cuadradas", 0
	otravez			BYTE	"Intente otra vez",0
    eNumeroInvalido BYTE	"Ingrese un numero entre 2 y 10", 0
	capturado		BYTE	"capturado",0
	popd			BYTE	"se hizo pop",0
	coma			BYTE	",",0
	posicion		BYTE	"Ingrese el numero en la posicion ",0
	EsSimetrica		BYTE	"La matriz ingresada es simetrica", 0
	NoEsSimetrica	BYTE	"La matriz ingresada no es simetrica", 0
	transpuesto		BYTE	"El numero transpuesto es ", 0
	posicionMat		BYTE	"Lo que esta en esi en la matriz", 0
	posicionTrans	BYTE	"Lo que esta en esi en la transpuesta", 0
	NumeroMayor		BYTE	"El mayor numero de la matriz es ", 0


;----------------------------------------------------------------------------------------------------
;Aqu� solo variables
;----------------------------------------------------------------------------------------------------
	coordena	BYTE ?
	x			DWORD 0			;Estas dos antes eran Bytes
	y			DWORD 0
	filas		BYTE ?
	columnas	BYTE ?
	index		DWORD ?
	numero		REAL10 ?
	aux			DWORD ?
numeroFila		DWORD ?
numerosTotales	DWORD ?
	AuxReal		REAL10	?
	AgregarEn	DWORD 0
	AuxY		BYTE 0
	AuxX		BYTE 0				;Para la tranpuesta
	ContCiclos	DWORD 0				;Para contar cuantos numeros ha transpuesta
	ContX		BYTE 0
	ContY		BYTE 0				;Para ir cambiando la posici�n donde debe a�adir 
	BoolComp	BYTE 0				;Si es 0 cuanta como falso, y mas de 0 es verdadero


;----------------------------------------------------------------------------------------------------
;Empieza el main
;----------------------------------------------------------------------------------------------------
.code
main PROC

;-------------------------------------------
	;La bienvenida a nuestro programa

	mov edx, OFFSET bienvenida
	call writeString
	call crlf
	mov edx, OFFSET asignatura
	call writeString
	call crlf
	mov edx, OFFSET identificacion
	call writeString
	call crlf
	mov edx, OFFSET CC
	call writeString
	call crlf
	

;-------------------------------------------   

	
	
	mov edx, OFFSET query					; Esto es para leer el "string" que pide las filas
	numeroMatriz:
		call writeString
		call crlf

		numeroFilas:						;Con esto se le pide el numero de filas al usuario
			mov edx, OFFSET nfilas
			call writeString
			call crlf	
			call readInt
			call Clrscr
			
			.IF (al > 10)					;Si la entrada es mayor a 10 salta un error y se debe volver a intentar
				call tamanoInvalidoFilas			;"Excepcion" creado por nosotros en la parte de abajo del documento, solo imprime texto
				jmp numeroFilas
			.ELSEIF (al < 2)				;Lo mismo si la entrada es menor a 2
				call numeroInvalidoFilas			;Otra "excepcion" que no pide ningun dato y solo imprime el error que representa
				jmp numeroFilas
			.ENDIF

			call crlf	
			mov filas,al

		numeroColumnas:						;Ahora se le piden las columnas al usuario de la misma forma que las filas
			mov edx,offset ncolumnas
			call writeString
			call crlf	
			call readInt
			call Clrscr

			.IF (al > 10)					;Si la entrada es mayor a 10 salta un error llamado por el proc de abajo
				call tamanoInvalidoFilas
				jmp numeroColumnas
			.ELSEIF (al < 2)				;Si la entrada es menor a 2 salta el error por pantalla y se pide volver a ingresar las columnas
				call numeroInvalidoFilas
				jmp numeroColumnas
			.ENDIF

			call crlf	
			mov Columnas,al
		
		cuadrada:

			.IF (al != filas)					;Si la la matriz no es cuadrada se pide que se vuelva a ingresar
				call tamanoInvalidoFilas
				jmp numeroFilas
			.ENDIF

			;Para fijar el "tama�o" de la matriz segun l n�mero de elementos en las filas
			.IF (al == 2)
				mov numeroFila, 1
				mov numerosTotales, 4
			.ELSEIF (al == 3)
				mov numeroFila, 2
				mov numerosTotales ,  9
			.ELSEIF (al == 4)
				mov numeroFila, 3 
				mov numerosTotales ,  16
			.ELSEIF (al == 5)
				mov numeroFila, 4
				mov numerosTotales ,  25
			.ELSEIF (al == 6)
				mov numeroFila, 5
				mov numerosTotales ,  36
			.ELSEIF (al == 7)
				mov numeroFila, 6
				mov numerosTotales ,  49
			.ELSEIF (al == 8)
				mov numeroFila, 7
				mov numerosTotales ,  64
			.ELSEIF (al == 9)
				mov numeroFila, 8
				mov numerosTotales ,  81
			.ELSEIF (al == 10)
				mov numeroFila, 9
				mov numerosTotales ,  100
			.ENDIF



			.data
			matriz REAL10 10 DUP(10 DUP(0.0))				;Crea la maxima matriz, 10 X 10
			transpuesta REAL10 10 DUP(10 DUP(0.0))				;Para guardar la transpuesta

			.code
			mov eax, numerosTotales
			mov ebx, 10
			mul ebx
			mov numerosTotales, eax
			mov esi, 0
			mov x, 0
			mov y, 0

			;Operaciones con las matrices
			IngresandoDatos:
				mov esi, index

				;Imprimiendo la posicion que el usuario debe ingresar en la matriz, un num racional
				mov edx, OFFSET posicion
				call writeString 
				call crlf
				mov eax, x
				call writeDec
				mov edx, OFFSET coma
				call writeString
				mov eax, y
				call writeDec
				call crlf
				finit

				;Anadiendo los valores a la matriz
				call readFloat

				;Para avanzar el indice de la matriz original
				mov eax, x
				mov ebx, 100
				mul ebx
				mov aux, eax

				mov eax, y
				mov ebx, 10
				mul ebx

				add eax, aux
				mov esi, eax

				fstp matriz[esi]					;Agregando el n�mero agregado a la matriz
				
				;Para avanzar el indice de la matriz transpuesta
				mov eax, y
				mov ebx, 100
				mul ebx
				mov aux, eax

				mov eax, x
				mov ebx, 10
				mul ebx

				add eax, aux
				mov esi, eax

				
				fstp transpuesta[esi]							;Agregando el n�mero ingresado a la matriz transpuesta

				finit


				mov eax, y
				cmp eax, numeroFila							;Comparando la x con el numero maximo que esta puede alzanzar para reiniciarla
				je reinicioX2
				mov eax, y
				inc eax
				mov y, eax

				jmp aumentoESI2

				reinicioX2:
					
					mov eax, 0
					mov y, eax			;Reiniciando y		
					mov eax, x
					inc eax				;Incrementando x
					mov x, eax
				aumentoESI2:
					mov eax, index
					add eax, 10				;Aumentando el contador de veces que se ha guardado un numero
					mov index, eax
					cmp eax, numerosTotales					;Comparando cuantos numeros hay guardados ya en la matriz con los que debe entrar el usuario
					je finPrograma
		
				jmp IngresandoDatos


			finPrograma:				;Para terminar de a�adir los datos

			;---------------------------------------------------------------------------------------------------------------------------

			
			
			.data			;Datos que necesita este "metodo" de buscar el mayor numero
				
				mayorX DWORD ?
				mayorY DWORD ?
				indiceMayor DWORD ?
				comparar REAL10 0.0
				numMatriz DWORD ?
				numComp	  DWORD ?

			.code

			mov esi,0
			mov eax,0
			mov x,eax
			mov y,eax

			mayorAbsoluto:

				mov eax, y
				mov ebx, x
				cmp eax, ebx
				je SonIguales
			  
				  finit
				  fld matriz[esi]		;Guardar en el stack

				  fabs					;Hacer a todos los numeros positivos para buscar el mayor
				  fld comparar

				  fcompp
			
					fnstsw ax
					sahf
					
					jae seguir		;Aqui esta el error, porque siempre es true; ya intente con todos los metodos, comparaciones y mover los reales al ax


					remplazar:			;Guardar la posicion e indice del mayor numero de la matriz
						mov eax, x
						mov mayorX, eax
						mov eax, y
						mov mayorY, eax
						mov eax, esi

						mov indiceMayor, eax
						
			  SonIguales:

				seguir:
					mov eax,esi
					add eax,10
					mov esi, eax
					cmp eax, 1000
					jge acabo			;Terminar el "metodo" de buscar el mayor cuando haya recorrido todo el arreglo

					mov eax, y
					inc eax
					mov y, eax
					cmp eax, 10
					jge reiniciarY			;Reiniciar la coordenada Y cuando llegue a su mayor expresion permitida

					jmp mayorAbsoluto		;Reiniciar el ciclo de buscar el mayor
						

						reiniciarY:
							mov eax,0
							mov y,eax		;Reiniciar Y a cero
							mov eax, x
							inc eax
							mov x, eax		;Incrementar X en 1
					jmp mayorAbsoluto		;Volver al "metodo"


			acabo:

			;Ahora para el final imprime el mayor numero de la matriz
			
			call Clrscr
			mov edx, OFFSET NumeroMayor
			call writeString 
			call crlf
			mov esi, indiceMayor
			finit
			fld matriz[esi]
			call writeFloat
			call crlf
			finit


			;---------------------------------------------------------------------------------------------------------------------------


			;Calculando la matrix ortogonal a partir de la normal

			.data
			numeroReal3		REAL10	2.0
			numeroReal4		REAL10	1.0
			numeroReal5		REAL10	-1.0
			yValue			REAL10	?
			xValue			REAL10	?
			zvalue			REAL10	?
			cValue			REAL10	?
			sValue			REAL10	?
			testValue		REAL10	?	
			testValue2		REAL10	?
			position		DWORD ?
			x1				DWORD ?
			y1				DWORD ?
			xpp				DWORD ?
			ypp				DWORD ?
			matrizOrtogonal REAL10 10 DUP(10 DUP(0.0))
			realNumber1 DWORD ?
			.code
			
			mov eax, xpp
			mov x1, eax
			mov eax, ypp								;Las coordenadas xpp, ypp del elemento con mayor valor absoluto de la matriz (sin contar la diagonal)
			mov y1, eax

			mov eax, x1
			mov position, eax							;Indexo la posicion xpp, xpp en la matriz
			dec position
			mov eax, position
			mov ebx, 100
			mul ebx
			mov position, eax
			mov eax, x1
			dec eax
			mov ebx, 10
			mul ebx
			add position, eax

			finit
			mov esi, position
			fld matriz[esi]								;Guandando el valor
			fstp yValue	

			mov eax, y1
			mov position, eax							;Indexo la posicion ypp, ypp en la matriz
			dec position
			mov eax, position
			mov ebx, 100
			mul ebx
			mov eax, y1
			dec eax
			mov ebx, 10
			mul ebx
			add position, eax

			finit
			mov esi, position
			fld matriz[esi]								;Guardo el valor y lo resto con xpp, xpp para obtener Y
			fstp testValue
			finit
			fld yValue
			fld testValue
			fadd st(0), st(1)
			fstp yValue

			mov eax, x1
			mov position, eax							;Indexo la posicion xpp, ypp en la matriz
			dec position
			mov eax, position
			mov ebx, 100
			mul ebx
			mov eax, y1
			dec eax
			mov ebx, 10
			mul ebx
			add position, eax						

			finit										;Guardo el valor y lo multiplico por 2 para obtener X
			mov esi, position
			fld matriz[esi]						
			fld numeroReal3
			fmul st(0), st(1)
			fstp xValue

			finit										;Calcula la raiz cuadrada de (x*x+y*y) y la guarda en Z
			fld xValue
			fstp zValue	
			finit
			fld zValue
			fld xValue								
			fmul st(0), st(1)
			fstp zValue
			finit
			fld yValue
			fstp testValue
			finit
			fld yValue
			fld testValue
			fmul st(0), st(1)
			fstp testValue
			finit
			fld zValue
			fld testValue
			fadd st(0), st(1)
			fstp zValue
			finit
			fld zValue
			fsqrt
			fstp zValue

			finit										;Calcula la raiz cuadrada de ((z+y)/(2*z)) y la guarda en C
			fld zValue
			fld numeroReal3
			fmul st(0), st(1)
			fstp cValue
			finit
			fld zValue
			fld yValue
			fadd st(0), st(1)
			fstp testValue
			finit
			fld testValue
			fld cValue
			fdiv st(0), st(1)
			fstp cValue
			finit
			fld cValue
			fsqrt
			fstp cValue

			finit										;Calcula la raiz cuadrada de ((z-y)/(2*z)) y la guarda en S
			fld numeroReal3
			fld zValue
			fmul st(0), st(1)
			fstp sValue
			finit
			fld zValue
			fld yValue
			fsub st(0), st(1)
			fstp testValue
			finit 
			fld testValue
			fld sValue
			fdiv st(0), st(1)
			fstp sValue
			finit
			fld sValue
			fsqrt
			fstp sValue
			finit										;La var Y se multiplica por el signo de (X/Y)
			fld xValue
			fld yValue
			fdiv st(0), st(1)
			fstp testValue
			finit
			fld testValue
			fld realNumber1
			fcomp
			jle my_comparison3
				finit
				fld sValue
				fld numeroReal5
				fmul st(0), st(1)
				fstp sValue
			my_comparison3:
			
			mov eax, x1									;Agrego a la matriz ortogonal en la posicion X,X el valor de C
			mov position, eax							
			dec position
			mov eax, position
			mov ebx, 100
			mul ebx
			mov position, eax
			mov eax, x1
			dec eax
			mov ebx, 10
			mul ebx
			add position, eax
			finit
			fld cValue
			mov esi, position
			fstp matrizOrtogonal[esi]

			mov eax, y1									;Agrego a la matriz ortogonal en la posicion Y,Y el valor de C
			mov position, eax							
			dec position
			mov eax, position
			mov ebx, 100
			mul ebx
			mov position, eax
			mov eax, y1
			dec eax
			mov ebx, 10
			mul ebx
			add position, eax
			finit
			fld cValue
			mov esi, position
			fstp matrizOrtogonal[esi]

			mov eax, x1									;Agrego a la matriz ortogonal en la posicion X,Y el valor de S
			mov position, eax							
			dec position
			mov eax, position
			mov ebx, 100
			mul ebx
			mov position, eax
			mov eax, y1
			dec eax
			mov ebx, 10
			mul ebx
			add position, eax
			finit
			fld sValue
			mov esi, position
			fstp matrizOrtogonal[esi]

			mov eax, y1									;Agrego a la matriz ortogonal en la posicion Y,X el valor de -S
			mov position, eax							
			dec position
			mov eax, position
			mov ebx, 100
			mul ebx
			mov position, eax
			mov eax, x1
			dec eax
			mov ebx, 10
			mul ebx
			add position, eax
			finit
			fld sValue
			fld numeroReal5
			fmul st(0), st(1)
			fstp testValue
			finit
			fld testValue
			mov esi, position
			fstp matrizOrtogonal[esi]
			
		;----------------------------------------------------------------------------------

		 ;multiplcacion
		   .data
		   i		DWORD ?
		   j		DWORD ?
		   k		DWORD ?
		   xtemp	DWORD ?
		   aux1		DWORD ?
		   aux2		DWORD ?
		   matrizNueva		 REAL10 10 DUP(10 DUP(0.0))			;Crea la maxima matriz, 10 X 10
		   numeroNuevaMatriz REAL10 ?
		   numeroSegundaMatriz REAL10 ?
		   numeroPrimeraMatriz REAL10 ?
		   numeroPrimerMatriz DWORD ?
		   resultado REAL10 ?
		   .code
   
 
   
		   multiplicacion:
				mov esi,0
				mov eax,0
				mov i,eax
				mov ecx,10
				;L1:
					mov i,eax
					mov aux1,ecx
					mov eax,0
					mov j,eax
					mov ecx ,10
					;L2:
						mov aux2,ecx
						mov eax,0
						mov k,eax
						mov ecx,10
						;L3:
							mov eax,i
							mov ebx, 100
							mul ebx
							mov xtemp,eax
							mov eax,k
							mov ebx, 10
							mul ebx
							add	eax, xtemp
							mov esi,eax
					
							fstp matriz[esi]
							mov numeroPrimerMatriz, eax
							mov eax,k
							mov ebx, 100
							mul ebx
							mov xtemp,eax
							mov eax,i
							mov ebx, 10
							mul ebx
							add eax, xtemp
							mov esi,eax
					
							fld numeroSegundaMatriz		;Guardar en el stack
							fstp matriz[esi]			;Sacar del stack
					
							finit
							fld numeroSegundaMatriz
							fld numeroPrimeraMatriz
							fstp st(1)
							fmulp
					
							fstp resultado 
							mov eax, i
							mov ebx, 100
							mul ebx
							mov xtemp, eax
							mov eax, j
							mov ebx, 10
							mul ebx
							add eax, xtemp
							mov esi,eax

							fld numeroNuevaMatriz		;Guardar en el stack
							fstp matrizNueva[esi]			;Sacar del stack

							finit
							fld numeroNuevaMatriz
							fld resultado
							fadd st(0),st(1)

							fstp matrizNueva[esi]

							mov eax,k
							inc eax
							mov k,eax
						;loop L3
						mov eax,j
						inc eax
						mov j,eax
						mov ecx,aux2
					;loop L2
					mov eax,i
					inc eax
					mov i,eax
					mov ecx,aux1
				;loop L1

	
exit
main ENDP										;El fin del main




;---------------------------------------------------------------------------------
;Procesos varios
;Este es para imprimir error si el usuario ingresa un tamano mayor a 10 para las filas
;Recive: nada
;Retorna: nada
;Requiere: nada
;---------------------------------------------------------------------------------
tamanoInvalidoFilas PROC

		call Clrscr
		mov edx,offset efilas			;Imprime tamano no valido
		call writeString
		call crlf	
		mov edx,offset otravez			;Imprime que lo intente de nuevo
		call writeString
		call crlf

	ret	
tamanoInvalidoFilas ENDP

;---------------------------------------------------------------------------------
;Este es para imprimir error si el usuario ingresa un tamano mayor a 10 para las columnas
;Recive: nada
;Retorna: nada
;Requiere: nada
;---------------------------------------------------------------------------------
tamanoInvalidoColumnas PROC

		call Clrscr
		mov edx,offset ecolumnas			;Imprime tamano no valido
		call writeString
		call crlf	
		mov edx,offset otravez			;Imprime que lo intente de nuevo
		call writeString
		call crlf

	ret									
tamanoInvalidoColumnas ENDP							


;---------------------------------------------------------------------------------
;Este es para imprimir error si el usuario ingresa las filas diferentes a las columnas
;Recive: nada
;Retorna: nada
;Requiere: nada
;---------------------------------------------------------------------------------
matrizNoCuadrada PROC

		call Clrscr
		mov edx,offset eMatrizNoCuadrada
		call writeString
		call crlf	
		mov edx,offset otravez			;Imprime que lo intente de nuevo
		call writeString
		call crlf
		;jmp numeroFilas
	
	ret									
matrizNoCuadrada ENDP										


;---------------------------------------------------------------------------------
;Este es para imprimir error si el usuario ingresa un numero menor a 2 en las filas
;Recive: nada
;Retorna: nada
;Requiere: nada
;---------------------------------------------------------------------------------
numeroInvalidoFilas PROC

		call Clrscr
		mov edx,offset eNumeroInvalido			;Imprime tamano no valido
		call writeString
		call crlf
		mov edx,offset otravez			;Imprime que lo intente de nuevo
		call writeString
		call crlf

	ret
numeroInvalidoFilas ENDP				


;---------------------------------------------------------------------------------
;Este es para imprimir error si el usuario ingresa un numero menor a 2 en las columnas
;Recive: nada
;Retorna: nada
;Requiere: nada
;---------------------------------------------------------------------------------
numeroInvalidoColumnas PROC

		call Clrscr
		mov edx,offset eNumeroInvalido			;Imprime tamano no valido
		call writeString
		call crlf
		mov edx,offset otravez			;Imprime que lo intente de nuevo
		call writeString
		call crlf

	ret																		
numeroInvalidoColumnas ENDP		


;---------------------------------------------------------------------------------
;Esta es para poner todos los objetos de la matriz de 1 al maximo e imprimirlos
;Recive: eax = numerosTotales
;Retorna: nada, solo imprime
;Requiere: nada
;---------------------------------------------------------------------------------






;---------------------------------------------------------------------------------
;Esta es la plantilla que usamos para los proc
;Recive: 
;Retorna: 
;Requiere: nada
;---------------------------------------------------------------------------------
;talcosa PROC													;Con esto bautiza el proceso


	
;	ret														;No olvidar esto o el programa se bloquea
;talcosa ENDP												;Vital cerrar el programa
;----------------------------------------------------------------------------------



END main					;Y el fin del programa
