LIST P=18F4620
    
#include <P18F4620.INC>

config OSC = HSPLL      ; Oscillator Selection bits (HS oscillator, PLL enabled (Clock Frequency = 4 x FOSC1))
config FCMEN = OFF      ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
config IESO = OFF       ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
config PWRT = ON        ; Power-up Timer Enable bit (PWRT enabled)
config BOREN = OFF      ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
config BORV = 3         ; Brown Out Reset Voltage bits (Minimum setting)

; CONFIG2H
config WDT = OFF        ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
config WDTPS = 32768    ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
config CCP2MX = PORTC   ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
config PBADEN = OFF     ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
config LPT1OSC = OFF    ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
config MCLRE = ON       ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
config STVREN = OFF     ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will not cause Reset)
config LVP = OFF        ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
config XINST = OFF      ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
config CP0 = OFF        ; Code Protection bit (Block 0 (000800-003FFFh) not code-protected)
config CP1 = OFF        ; Code Protection bit (Block 1 (004000-007FFFh) not code-protected)
config CP2 = OFF        ; Code Protection bit (Block 2 (008000-00BFFFh) not code-protected)
config CP3 = OFF        ; Code Protection bit (Block 3 (00C000-00FFFFh) not code-protected)

; CONFIG5H
config CPB = OFF        ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
config CPD = OFF        ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
config WRT0 = OFF       ; Write Protection bit (Block 0 (000800-003FFFh) not write-protected)
config WRT1 = OFF       ; Write Protection bit (Block 1 (004000-007FFFh) not write-protected)
config WRT2 = OFF       ; Write Protection bit (Block 2 (008000-00BFFFh) not write-protected)
config WRT3 = OFF       ; Write Protection bit (Block 3 (00C000-00FFFFh) not write-protected)

; CONFIG6H
config WRTC = OFF       ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
config WRTB = OFF       ; Boot Block Write Protection bit (Boot Block (000000-0007FFh) not write-protected)
config WRTD = OFF       ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
config EBTR0 = OFF      ; Table Read Protection bit (Block 0 (000800-003FFFh) not protected from table reads executed in other blocks)
config EBTR1 = OFF      ; Table Read Protection bit (Block 1 (004000-007FFFh) not protected from table reads executed in other blocks)
config EBTR2 = OFF      ; Table Read Protection bit (Block 2 (008000-00BFFFh) not protected from table reads executed in other blocks)
config EBTR3 = OFF      ; Table Read Protection bit (Block 3 (00C000-00FFFFh) not protected from table reads executed in other blocks)

; CONFIG7H
config EBTRB = OFF      ; Boot Block Table Read Protection bit (Boot Block (000000-0007FFh) not protected from table reads executed in other blocks)

    
variables udata_acs
program_state res 1
selected_row res 1
rb0_button_state res 1
rb1_button_state res 1
rb2_button_state res 1
rb3_button_state res 1
counter_1 res 1
counter_2 res 1
counter_3 res 1
porta_shape res 1
portc_shape res 1
portd_shape res 1
blink_state res 1
candidate_line res 1
candidate_line_right_index res 1 
candidate_line_left_index res 1 
edge_state res 1 
delay_counter1_rb0 res 1
delay_counter2_rb0 res 1
delay_counter1_rb1 res 1
delay_counter2_rb1 res 1
delay_counter1_rb2 res 1
delay_counter2_rb2 res 1
delay_counter1_rb3 res 1
delay_counter2_rb3 res 1
 
 
delay200ms_count equ 0xB6 
delay10ms_count equ 0x09 
 
 
org 0x0000
    goto init

org 0x0008
    goto $
 
    
waste_1000second:	; It wastes 1000 seconds for start-up phase.
    do_while_counter_1_not_zero:	
        do_while_counter_2_not_zero:
            do_while_counter_3_not_zero:
                decf counter_3 
                bnz do_while_counter_3_not_zero
            end_do_while_counter_3_not_zero:
            decf counter_2
            bnz do_while_counter_2_not_zero
        end_do_while_counter_2_not_zero:
        decf counter_1
        bnz do_while_counter_1_not_zero
    end_do_while_counter_1_not_zero:
    return

    
   
init:
    clrf TRISA ; Port A initialization part.
    movlw 0x0F
    movwf ADCON1
    clrf PORTA  
    clrf TRISC ; Port C initialization part.
    clrf PORTC
    clrf TRISD ; Port D initialization part.
    clrf PORTD
    movlw 0x0F ; Port B initialization part.
    movwf TRISB
    bcf PORTB,4,A
    bcf PORTB,5,A
    bcf PORTB,6,A
    bcf PORTB,7,A
    setf counter_3
    setf counter_2
    movlw 0x32
    movwf counter_1
    clrf program_state ; Program state is 0 which is row selection in my implementation.
    clrf rb0_button_state ; All button states start from 0 which indicates not pressed.
    clrf rb1_button_state
    clrf rb2_button_state
    clrf rb3_button_state
    clrf porta_shape
    clrf portc_shape
    clrf portd_shape
    clrf blink_state
    clrf candidate_line
    clrf candidate_line_right_index
    clrf candidate_line_left_index  
    clrf edge_state  
    goto init_complete
    
    
init_complete:
    goto start_up_phase
    
    
start_up_phase:
    setf LATA
    setf LATC
    setf LATD
    call waste_1000second
    clrf LATA
    clrf LATC
    clrf LATD
    movlw delay200ms_count
    movwf counter_2
    movlw delay200ms_count
    movwf counter_3
    movlw delay10ms_count
    movwf delay_counter1_rb0
    movlw delay10ms_count
    movwf delay_counter2_rb0
    movlw delay10ms_count
    movwf delay_counter1_rb1
    movlw delay10ms_count
    movwf delay_counter2_rb1
    movlw delay10ms_count
    movwf delay_counter1_rb2
    movlw delay10ms_count
    movwf delay_counter2_rb2
    movlw delay10ms_count
    movwf delay_counter1_rb3
    movlw delay10ms_count
    movwf delay_counter2_rb3     
    movlw 0x01
    movwf selected_row
    goto sec_passed

sec_passed:
    goto main


rb0_released:
    movlw 0x00
    cpfseq program_state
    goto rb0_released_drawing
    goto rb0_released_row_selection

rb1_released:
    movlw 0x00
    cpfseq program_state
    goto rb1_released_drawing
    goto rb1_released_row_selection    
    
rb2_released:
    movlw 0x00
    cpfseq program_state
    goto rb2_released_drawing
    goto rb2_released_row_selection

rb3_released:
    movlw 0x00
    cpfseq program_state
    goto rb3_released_drawing
    goto rb3_released_row_selection    


save_candidate_line_to_port:
    selected_row_is_A:	
	movlw 0x01
	cpfseq selected_row
	bra selected_row_is_C
	movff porta_shape, PORTA
	movf candidate_line,0				
	IORWF PORTA
	return
    selected_row_is_C:	
	movlw 0x02
	cpfseq selected_row
	bra selected_row_is_D
	movff portc_shape, PORTC
	movf candidate_line,0				
	IORWF PORTC
	return
    selected_row_is_D:	
	movff portd_shape, PORTD
	movf candidate_line,0				
	IORWF PORTD
	return     

	
load_blink_state_to_the_selected_row:
    selected_row_is_portA:	
	movlw 0x01
	cpfseq selected_row
	bra selected_row_is_portC
	blink_state_is_now_0:
	    movlw 0x00
	    cpfseq blink_state
	    bra blink_state_is_now_1
	    clrf PORTA
	    return
	blink_state_is_now_1:
	    setf PORTA
	    return
    selected_row_is_portC:	
	movlw 0x02
	cpfseq selected_row
	bra selected_row_is_portD
	blink_state_is_now_00:
	    movlw 0x00
	    cpfseq blink_state
	    bra blink_state_is_now_11
	    clrf PORTC
	    return
	blink_state_is_now_11:
	    setf PORTC
	    return
    selected_row_is_portD:
	blink_state_is_now_000:
	    movlw 0x00
	    cpfseq blink_state
	    bra blink_state_is_now_111
	    clrf PORTD
	    return
	blink_state_is_now_111:
	    setf PORTD
	    return   



	
    
button_state:
    movlw 0x00
    cpfseq program_state
    bra drawing_phase
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Row Selection Phase - RB0 - Toggle the shape of selected row. ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    rb0_check:
	rb0_not_pressed:
	    movlw 0x00
	    cpfseq rb0_button_state
	    bra rb0_pressing
	    btfsc PORTB,0
	    bra rb1_check
	    movlw 0x01
	    movwf rb0_button_state
	    bra rb1_check
	rb0_pressing:
	    movlw 0x01
	    cpfseq rb0_button_state
	    bra rb0_pressed
	    decf delay_counter1_rb0 
	    bnz rb1_check
	    decf delay_counter2_rb0
	    bnz rb1_check
	    movlw delay10ms_count
	    movwf delay_counter1_rb0
	    movlw delay10ms_count
	    movwf delay_counter2_rb0
	    btfsc PORTB,0
	    bra rb0_is_not_actually_pressed	
	    rb0_is_actually_pressed:
		movlw 0x02
		movwf rb0_button_state
		bra rb1_check
	    rb0_is_not_actually_pressed:	    ; Bouncing condition. We should go back to not pressed state.
		movlw 0x00
		movwf rb0_button_state
		bra rb1_check		
	rb0_pressed:
	    movlw 0x02
	    cpfseq rb0_button_state
	    bra rb0_releasing
	    btfss PORTB,0
	    bra rb1_check
	    movlw 0x03
	    movwf rb0_button_state
	    bra rb1_check	    
	rb0_releasing:
	    decf delay_counter1_rb0
	    bnz rb1_check
	    decf delay_counter2_rb0
	    bnz rb1_check
	    movlw delay10ms_count
	    movwf delay_counter1_rb0
	    movlw delay10ms_count
	    movwf delay_counter2_rb0
	    btfsc PORTB,0
	    bra rb0_is_actually_released	
	    rb0_is_not_actually_released:	    ; Bouncing condition. We should go back to pressed state.
		movlw 0x02
		movwf rb0_button_state
		bra rb1_check
	    rb0_is_actually_released:	    
		goto rb0_released
		rb0_released_row_selection:
		    movlw 0x00
		    movwf rb0_button_state	
		    movlw 0x01
		    cpfseq selected_row
		    bra notporta
		    movlw 0xFF
		    xorwf porta_shape
		    return
		    notporta:
		    movlw 0x02
		    cpfseq selected_row
		    bra notportc
		    movlw 0xFF
		    xorwf portc_shape
		    return
		    notportc:
		    movlw 0xFF
		    xorwf portd_shape
		    return
	  
	    
		
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Row Selection Phase - RB1 - Down the selected row. ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 		
	  
    
    
    rb1_check:
	rb1_not_pressed:
	    movlw 0x00
	    cpfseq rb1_button_state
	    bra rb1_pressing
	    btfsc PORTB,1
	    bra rb2_check
	    movlw 0x01
	    movwf rb1_button_state
	    bra rb2_check
	rb1_pressing:
	    movlw 0x01
	    cpfseq rb1_button_state
	    bra rb1_pressed
	    decf delay_counter1_rb1 
	    bnz rb2_check
	    decf delay_counter2_rb1
	    bnz rb2_check
	    movlw delay10ms_count
	    movwf delay_counter1_rb1
	    movlw delay10ms_count
	    movwf delay_counter2_rb1
	    btfsc PORTB,1
	    bra rb1_is_not_actually_pressed	
	    rb1_is_actually_pressed:
		movlw 0x02
		movwf rb1_button_state
		bra rb2_check
	    rb1_is_not_actually_pressed:	    ; Bouncing condition. We should go back to not pressed state.
		movlw 0x00
		movwf rb1_button_state
		bra rb2_check		
	rb1_pressed:
	    movlw 0x02
	    cpfseq rb1_button_state
	    bra rb1_releasing
	    btfss PORTB,1
	    bra rb2_check
	    movlw 0x03
	    movwf rb1_button_state
	    bra rb2_check	    
	rb1_releasing:
	    decf delay_counter1_rb1
	    bnz rb2_check
	    decf delay_counter2_rb1
	    bnz rb2_check
	    movlw delay10ms_count
	    movwf delay_counter1_rb1
	    movlw delay10ms_count
	    movwf delay_counter2_rb1
	    btfsc PORTB,1
	    bra rb1_is_actually_released	
	    rb1_is_not_actually_released:	    ; Bouncing condition. We should go back to pressed state.
		movlw 0x02
		movwf rb1_button_state
		bra rb2_check
	    rb1_is_actually_released:	 
		goto rb1_released
		rb1_released_row_selection:
		    movlw 0x00
		    movwf rb1_button_state	
		    movlw 0x01
		    cpfseq selected_row
		    bra notporta_1
		    movlw 0x02		; Port A was selected. New selected will be port c.
		    movwf selected_row	; Also load the shape of A to the port a.
		    movff porta_shape, PORTA
		    call load_blink_state_to_the_selected_row
		    return
		    notporta_1:
		    movlw 0x02
		    cpfseq selected_row
		    bra notportc_1
		    movlw 0x03		; Port c was selected. New selected will be port d.
		    movwf selected_row	; Also load the shape of c to the port c. 
		    movff portc_shape, PORTC
		    call load_blink_state_to_the_selected_row
		    return
		    notportc_1:
		    return		; Port d was selected. Nothing will happen.
		
    
		
		
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Row Selection Phase - RB2 - Up the selected row. ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	
    
    
    
		
    rb2_check:
	rb2_not_pressed:
	    movlw 0x00
	    cpfseq rb2_button_state
	    bra rb2_pressing
	    btfsc PORTB,2
	    bra rb3_check
	    movlw 0x01
	    movwf rb2_button_state
	    bra rb3_check
	rb2_pressing:
	    movlw 0x01
	    cpfseq rb2_button_state
	    bra rb2_pressed
	    decf delay_counter1_rb2 
	    bnz rb3_check
	    decf delay_counter2_rb2
	    bnz rb3_check
	    movlw delay10ms_count
	    movwf delay_counter1_rb2
	    movlw delay10ms_count
	    movwf delay_counter2_rb2
	    btfsc PORTB,2
	    bra rb2_is_not_actually_pressed	
	    rb2_is_actually_pressed:
		movlw 0x02
		movwf rb2_button_state
		bra rb3_check
	    rb2_is_not_actually_pressed:	    ; Bouncing condition. We should go back to not pressed state.
		movlw 0x00
		movwf rb2_button_state
		bra rb3_check		
	rb2_pressed:
	    movlw 0x02
	    cpfseq rb2_button_state
	    bra rb2_releasing
	    btfss PORTB,2
	    bra rb3_check
	    movlw 0x03
	    movwf rb2_button_state
	    bra rb3_check	    
	rb2_releasing:
	    decf delay_counter1_rb2
	    bnz rb3_check
	    decf delay_counter2_rb2
	    bnz rb3_check
	    movlw delay10ms_count
	    movwf delay_counter1_rb2
	    movlw delay10ms_count
	    movwf delay_counter2_rb2
	    btfsc PORTB,2
	    bra rb2_is_actually_released	
	    rb2_is_not_actually_released:	    ; Bouncing condition. We should go back to pressed state.
		movlw 0x02
		movwf rb2_button_state
		bra rb3_check
	    rb2_is_actually_released:	
		goto rb2_released
		rb2_released_row_selection:
		    movlw 0x00
		    movwf rb2_button_state
		    movlw 0x01
		    cpfseq selected_row
		    bra notporta_2
		    return  ; Port A was selected. Nothing will happen.
		    notporta_2:
		    movlw 0x02
		    cpfseq selected_row
		    bra notportc_2
		    movlw 0x01		; Port c was selected. New selected will be port a.
		    movwf selected_row	; Also load the shape of c to the port c. 
		    movff portc_shape, PORTC
		    call load_blink_state_to_the_selected_row
		    return
		    notportc_2:
		    movlw 0x02		; Port d was selected. New selected will be port c.
		    movwf selected_row	; Also load the shape of d to the port d.
		    movff portd_shape, PORTD
		    call load_blink_state_to_the_selected_row
		    return
    

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Row Selection Phase - RB3 - Skip the drawing phase. ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	
    return_from_button2:
	return
    
    
    rb3_check:
	rb3_not_pressed:
	    movlw 0x00
	    cpfseq rb3_button_state
	    bra rb3_pressing
	    btfsc PORTB,3
	    return
	    movlw 0x01
	    movwf rb3_button_state
	    return
	rb3_pressing:
	    movlw 0x01
	    cpfseq rb3_button_state
	    bra rb3_pressed
	    decf delay_counter1_rb3 
	    bnz return_from_button2
	    decf delay_counter2_rb3
	    bnz return_from_button2
	    movlw delay10ms_count
	    movwf delay_counter1_rb3
	    movlw delay10ms_count
	    movwf delay_counter2_rb3
	    btfsc PORTB,3
	    bra rb3_is_not_actually_pressed	
	    rb3_is_actually_pressed:
		movlw 0x02
		movwf rb3_button_state
		return
	    rb3_is_not_actually_pressed:	    ; Bouncing condition. We should go back to not pressed state.
		movlw 0x00
		movwf rb3_button_state
		return		
	rb3_pressed:
	    movlw 0x02
	    cpfseq rb3_button_state
	    bra rb3_releasing
	    btfss PORTB,3
	    return
	    movlw 0x03
	    movwf rb3_button_state
	    return	    
	rb3_releasing:
	    decf delay_counter1_rb3
	    bnz return_from_button2
	    decf delay_counter2_rb3
	    bnz return_from_button2
	    movlw delay10ms_count
	    movwf delay_counter1_rb3
	    movlw delay10ms_count
	    movwf delay_counter2_rb3
	    btfsc PORTB,3
	    bra rb3_is_actually_released	
	    rb3_is_not_actually_released:	    ; Bouncing condition. We should go back to pressed state.
		movlw 0x02
		movwf rb3_button_state
		return
	    rb3_is_actually_released:  
		goto rb3_released
		rb3_released_row_selection:
		    movlw 0x00
		    movwf rb3_button_state	
		    movlw 0x01
		    movwf program_state
		    movff porta_shape, PORTA
		    movff portc_shape, PORTC
		    movff portd_shape, PORTD
		    clrf candidate_line			; Create candidate line which is length of 1 and starts with left edge.
		    clrf candidate_line_right_index		; It extends to the right by default.
		    clrf candidate_line_left_index  
		    clrf edge_state
		    bsf candidate_line,0
		    call save_candidate_line_to_port
		    return
											
		
		
		
    drawing_phase:
    
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Drawing Phase - RB0 - Toggle edge state.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	rb0_check_drawing:
	    rb0_not_pressed_drawing:
		movlw 0x00
		cpfseq rb0_button_state
		goto rb0_pressing_drawing
		btfsc PORTB,0
		goto rb1_check_drawing
		movlw 0x01
		movwf rb0_button_state
		goto rb1_check_drawing
	    rb0_pressing_drawing:
		movlw 0x01
		cpfseq rb0_button_state
		goto rb0_pressed_drawing
		decf delay_counter1_rb0 
		bnz rb1_check_drawing
		decf delay_counter2_rb0
		bnz rb1_check_drawing
		movlw delay10ms_count
		movwf delay_counter1_rb0
		movlw delay10ms_count
		movwf delay_counter2_rb0
		btfsc PORTB,0
		goto rb0_is_not_actually_pressed_drawing
		rb0_is_actually_pressed_drawing:
		    movlw 0x02
		    movwf rb0_button_state
		    goto rb1_check_drawing
		rb0_is_not_actually_pressed_drawing:	    ; Bouncing condition. We should go back to not pressed state.
		    movlw 0x00
		    movwf rb0_button_state
		    goto rb1_check_drawing		
	    rb0_pressed_drawing:
		movlw 0x02
		cpfseq rb0_button_state
		goto rb0_releasing_drawing
		btfss PORTB,0
		goto rb1_check_drawing
		movlw 0x03
		movwf rb0_button_state
		goto rb1_check_drawing	    
	    rb0_releasing_drawing:
		decf delay_counter1_rb0
		bnz rb1_check_drawing
		decf delay_counter2_rb0
		bnz rb1_check_drawing
		movlw delay10ms_count
		movwf delay_counter1_rb0
		movlw delay10ms_count
		movwf delay_counter2_rb0
		btfsc PORTB,0
		goto rb0_is_actually_released_drawing	
		rb0_is_not_actually_released_drawing:	    ; Bouncing condition. We should go back to pressed state.
		    movlw 0x02
		    movwf rb0_button_state
		    goto rb1_check_drawing
		rb0_is_actually_released_drawing:
		    goto rb0_released
		    rb0_released_drawing:
			movlw 0x00
			movwf rb0_button_state			    ; Released detected. Toggle the edge-state.
			movlw 0x00									    
			cpfseq edge_state
			goto edge_state_was1
			edge_state_was0:
			    movlw 0x01
			    movwf edge_state
			    return
			edge_state_was1:
			    movlw 0x00
			    movwf edge_state
			    return    

 
    goto_rb2_check_drawing:
	goto rb2_check_drawing
			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Drawing Phase - RB1 - Drawing left.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
			
	rb1_check_drawing:
	    rb1_not_pressed_drawing:
		movlw 0x00
		cpfseq rb1_button_state
		goto rb1_pressing_drawing
		btfsc PORTB,1
		goto rb2_check_drawing
		movlw 0x01
		movwf rb1_button_state
		goto rb2_check_drawing
	    rb1_pressing_drawing:
		movlw 0x01
		cpfseq rb1_button_state
		goto rb1_pressed_drawing
		decf delay_counter1_rb1 
		bnz goto_rb2_check_drawing
		decf delay_counter2_rb1
		bnz goto_rb2_check_drawing
		movlw delay10ms_count
		movwf delay_counter1_rb1
		movlw delay10ms_count
		movwf delay_counter2_rb1
		btfsc PORTB,1
		goto rb1_is_not_actually_pressed_drawing	
		rb1_is_actually_pressed_drawing:
		    movlw 0x02
		    movwf rb1_button_state
		    goto rb2_check_drawing
		rb1_is_not_actually_pressed_drawing:	    ; Bouncing condition. We should go back to not pressed state.
		    movlw 0x00
		    movwf rb1_button_state
		    goto rb2_check_drawing		
	    rb1_pressed_drawing:
		movlw 0x02
		cpfseq rb1_button_state
		goto rb1_releasing_drawing
		btfss PORTB,1
		goto rb2_check_drawing
		movlw 0x03
		movwf rb1_button_state
		goto rb2_check_drawing	    
	    rb1_releasing_drawing:
		decf delay_counter1_rb1
		bnz goto_rb2_check_drawing
		decf delay_counter2_rb1
		bnz goto_rb2_check_drawing
		movlw delay10ms_count
		movwf delay_counter1_rb1
		movlw delay10ms_count
		movwf delay_counter2_rb1
		btfsc PORTB,1
		goto rb1_is_actually_released_drawing	
		rb1_is_not_actually_released_drawing:	    ; Bouncing condition. We should go back to pressed state.
		    movlw 0x02
		    movwf rb1_button_state
		    goto rb2_check_drawing
		rb1_is_actually_released_drawing:		   
		    goto rb1_released
		    rb1_released_drawing:   
			movlw 0x00
			movwf rb1_button_state	    		    
			movlw 0x00
			cpfseq edge_state
			goto edge_state_is_11
			; Edge state is 0 (Right) . So we turn off right index and decrement right index.
			edge_state_is_01:
			    movf candidate_line_right_index,0					
			    cpfseq candidate_line_left_index					
			    goto right_index_is_01									 
			    return
			    right_index_is_01:
				movlw 0x00				    
				cpfseq candidate_line_right_index     
				goto right_index_is_11
				return
			    right_index_is_11:
				movlw 0x01
				cpfseq candidate_line_right_index     
				goto right_index_is_21
				movlw 0x00
				movwf candidate_line_right_index
				bcf candidate_line,1	
				call save_candidate_line_to_port
				return
			    right_index_is_21:
				movlw 0x02
				cpfseq candidate_line_right_index     
				goto right_index_is_31
				movlw 0x01
				movwf candidate_line_right_index
				bcf candidate_line,2
				call save_candidate_line_to_port
				return
			    right_index_is_31:
				movlw 0x03
				cpfseq candidate_line_right_index     
				goto right_index_is_41
				movlw 0x02
				movwf candidate_line_right_index
				bcf candidate_line,3
				call save_candidate_line_to_port
				return
			    right_index_is_41:
				movlw 0x04
				cpfseq candidate_line_right_index     
				goto right_index_is_51
				movlw 0x03
				movwf candidate_line_right_index
				bcf candidate_line,4
				call save_candidate_line_to_port
				return
			    right_index_is_51:
				movlw 0x05
				cpfseq candidate_line_right_index     
				goto right_index_is_61
				movlw 0x04
				movwf candidate_line_right_index
				bcf candidate_line,5
				call save_candidate_line_to_port
				return
			    right_index_is_61:
				movlw 0x06
				cpfseq candidate_line_right_index     
				goto right_index_is_71
				movlw 0x05
				movwf candidate_line_right_index
				bcf candidate_line,6
				call save_candidate_line_to_port
				return
			    right_index_is_71:
				movlw 0x06
				movwf candidate_line_right_index
				bcf candidate_line,7
				call save_candidate_line_to_port
				return


			; Edge state is 1 (Left) . So we turn on left index - 1 and decrement left index. 
			edge_state_is_11:
			    left_index_is_01:
				movlw 0x00				    
				cpfseq candidate_line_left_index     
				goto left_index_is_11
				return
			    left_index_is_11:
				movlw 0x01
				cpfseq candidate_line_left_index     
				goto left_index_is_21
				movlw 0x00
				movwf candidate_line_left_index
				bsf candidate_line,0	
				call save_candidate_line_to_port
				return
			    left_index_is_21:
				movlw 0x02
				cpfseq candidate_line_left_index     
				goto left_index_is_31
				movlw 0x01
				movwf candidate_line_left_index
				bsf candidate_line,1
				call save_candidate_line_to_port
				return
			    left_index_is_31:
				movlw 0x03
				cpfseq candidate_line_left_index     
				goto left_index_is_41
				movlw 0x02
				movwf candidate_line_left_index
				bsf candidate_line,2
				call save_candidate_line_to_port
				return
			    left_index_is_41:
				movlw 0x04
				cpfseq candidate_line_left_index     
				goto left_index_is_51
				movlw 0x03
				movwf candidate_line_left_index
				bsf candidate_line,3
				call save_candidate_line_to_port
				return
			    left_index_is_51:
				movlw 0x05
				cpfseq candidate_line_left_index     
				goto left_index_is_61
				movlw 0x04
				movwf candidate_line_left_index
				bsf candidate_line,4
				call save_candidate_line_to_port
				return
			    left_index_is_61:
				movlw 0x06
				cpfseq candidate_line_left_index     
				goto left_index_is_71
				movlw 0x05
				movwf candidate_line_left_index
				bsf candidate_line,5
				call save_candidate_line_to_port
				return
			    left_index_is_71:
				movlw 0x06
				movwf candidate_line_left_index
				bsf candidate_line,6
				call save_candidate_line_to_port
				return


				
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Drawing Phase - RB2 - Drawing right.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	    
	
	goto_rb3_check_drawing:
	    goto rb3_check_drawing
	
	
	rb2_check_drawing:
	    rb2_not_pressed_drawing:
		movlw 0x00
		cpfseq rb2_button_state
		goto rb2_pressing_drawing
		btfsc PORTB,2
		goto rb3_check_drawing
		movlw 0x01
		movwf rb2_button_state
		goto rb3_check_drawing
	    rb2_pressing_drawing:
		movlw 0x01
		cpfseq rb2_button_state
		goto rb2_pressed_drawing
		decf delay_counter1_rb2 
		bnz goto_rb3_check_drawing
		decf delay_counter2_rb2
		bnz goto_rb3_check_drawing
		movlw delay10ms_count
		movwf delay_counter1_rb2
		movlw delay10ms_count
		movwf delay_counter2_rb2
		btfsc PORTB,2
		goto rb2_is_not_actually_pressed_drawing	
		rb2_is_actually_pressed_drawing:
		    movlw 0x02
		    movwf rb2_button_state
		    goto rb3_check_drawing
		rb2_is_not_actually_pressed_drawing:	    ; Bouncing condition. We should go back to not pressed state.
		    movlw 0x00
		    movwf rb2_button_state
		    goto rb3_check_drawing		
	    rb2_pressed_drawing:
		movlw 0x02
		cpfseq rb2_button_state
		goto rb2_releasing_drawing
		btfss PORTB,2
		goto rb3_check_drawing
		movlw 0x03
		movwf rb2_button_state
		goto rb3_check_drawing	    
	    rb2_releasing_drawing:
		decf delay_counter1_rb2
		bnz goto_rb3_check_drawing
		decf delay_counter2_rb2
		bnz goto_rb3_check_drawing
		movlw delay10ms_count
		movwf delay_counter1_rb2
		movlw delay10ms_count
		movwf delay_counter2_rb2
		btfsc PORTB,2
		goto rb2_is_actually_released_drawing	
		rb2_is_not_actually_released_drawing:	    ; Bouncing condition. We should go back to pressed state.
		    movlw 0x02
		    movwf rb2_button_state
		    goto rb3_check_drawing
		rb2_is_actually_released_drawing:	
		    goto rb2_released
		    rb2_released_drawing:
			movlw 0x00
			movwf rb2_button_state			   
			movlw 0x00
			cpfseq edge_state
			goto edge_state_is_1
		    
			; Edge state is 0 (Right) . So we turn on right index + 1 and increment right index.
			edge_state_is_0:				    
			    right_index_is_0:
				movlw 0x00				    
				cpfseq candidate_line_right_index     
				goto right_index_is_1
				movlw 0x01
				movwf candidate_line_right_index
				bsf candidate_line,1
				call save_candidate_line_to_port
				return
			    right_index_is_1:
				movlw 0x01
				cpfseq candidate_line_right_index     
				goto right_index_is_2
				movlw 0x02
				movwf candidate_line_right_index
				bsf candidate_line,2	
				call save_candidate_line_to_port
				return
			    right_index_is_2:
				movlw 0x02
				cpfseq candidate_line_right_index     
				goto right_index_is_3
				movlw 0x03
				movwf candidate_line_right_index
				bsf candidate_line,3
				call save_candidate_line_to_port
				return
			    right_index_is_3:
				movlw 0x03
				cpfseq candidate_line_right_index     
				goto right_index_is_4
				movlw 0x04
				movwf candidate_line_right_index
				bsf candidate_line,4
				call save_candidate_line_to_port
				return
			    right_index_is_4:
				movlw 0x04
				cpfseq candidate_line_right_index     
				goto right_index_is_5
				movlw 0x05
				movwf candidate_line_right_index
				bsf candidate_line,5
				call save_candidate_line_to_port
				return
			    right_index_is_5:
				movlw 0x05
				cpfseq candidate_line_right_index     
				goto right_index_is_6
				movlw 0x06
				movwf candidate_line_right_index
				bsf candidate_line,6
				call save_candidate_line_to_port
				return
			    right_index_is_6:
				movlw 0x06
				cpfseq candidate_line_right_index     
				goto right_index_is_7
				movlw 0x07
				movwf candidate_line_right_index
				bsf candidate_line,7
				call save_candidate_line_to_port
				return
			    right_index_is_7: 
				return			    


					    ;Edge state is 1 (Left). So we turn off left index and increment left index.;;;    
			edge_state_is_1:				 
			    movf candidate_line_left_index,0					
			    cpfseq 	candidate_line_right_index					
			    goto left_index_is_0									 
			    return										
			    left_index_is_0:
				movlw 0x00				   
				cpfseq candidate_line_left_index     
				goto left_index_is_1
				movlw 0x01
				movwf candidate_line_left_index
				bcf candidate_line,0
				call save_candidate_line_to_port
				return
			    left_index_is_1:
				movlw 0x01
				cpfseq candidate_line_left_index     
				goto left_index_is_2
				movlw 0x02
				movwf candidate_line_left_index
				bcf candidate_line,1	
				call save_candidate_line_to_port
				return
			    left_index_is_2:
				movlw 0x02
				cpfseq candidate_line_left_index     
				goto left_index_is_3
				movlw 0x03
				movwf candidate_line_left_index
				bcf candidate_line,2
				call save_candidate_line_to_port
				return
			    left_index_is_3:
				movlw 0x03
				cpfseq candidate_line_left_index     
				goto left_index_is_4
				movlw 0x04
				movwf candidate_line_left_index
				bcf candidate_line,3
				call save_candidate_line_to_port
				return
			    left_index_is_4:
				movlw 0x04
				cpfseq candidate_line_left_index     
				goto left_index_is_5
				movlw 0x05
				movwf candidate_line_left_index
				bcf candidate_line,4
				call save_candidate_line_to_port
				return
			    left_index_is_5:
				movlw 0x05
				cpfseq candidate_line_left_index     
				goto left_index_is_6
				movlw 0x06
				movwf candidate_line_left_index
				bcf candidate_line,5
				call save_candidate_line_to_port
				return
			    left_index_is_6:
				movlw 0x06
				cpfseq candidate_line_left_index     
				goto left_index_is_7
				movlw 0x07
				movwf candidate_line_left_index
				bcf candidate_line,6
				call save_candidate_line_to_port
				return
			    left_index_is_7: 
				return			
			    
		    
		    
		    
		    
		    

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Drawing Phase - RB3 - Skip the row selection phase.;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	    
	
	rb3_check_drawing:
	    rb3_not_pressed_drawing:
		movlw 0x00
		cpfseq rb3_button_state
		goto rb3_pressing_drawing
		btfsc PORTB,3
		return
		movlw 0x01
		movwf rb3_button_state
		return
	    rb3_pressing_drawing:
		movlw 0x01
		cpfseq rb3_button_state
		goto rb3_pressed_drawing
		decf delay_counter1_rb3 
		bnz return_from_button
		decf delay_counter2_rb3
		bnz return_from_button
		movlw delay10ms_count
		movwf delay_counter1_rb3
		movlw delay10ms_count
		movwf delay_counter2_rb3
		btfsc PORTB,3
		goto rb3_is_not_actually_pressed_drawing	
		rb3_is_actually_pressed_drawing:
		    movlw 0x02
		    movwf rb3_button_state
		    return
		rb3_is_not_actually_pressed_drawing:	    ; Bouncing condition. We should go back to not pressed state.
		    movlw 0x00
		    movwf rb3_button_state
		    return		
	    rb3_pressed_drawing:
		movlw 0x02
		cpfseq rb3_button_state
		goto rb3_releasing_drawing
		btfss PORTB,3
		return
		movlw 0x03
		movwf rb3_button_state
		return	    
	    rb3_releasing_drawing:
		decf delay_counter1_rb3
		bnz return_from_button
		decf delay_counter2_rb3
		bnz return_from_button
		movlw delay10ms_count
		movwf delay_counter1_rb3
		movlw delay10ms_count
		movwf delay_counter2_rb3
		btfsc PORTB,3
		goto rb3_is_actually_released_drawing	
		rb3_is_not_actually_released_drawing:	    ; Bouncing condition. We should go back to pressed state.
		    movlw 0x02
		    movwf rb3_button_state
		    return
		rb3_is_actually_released_drawing: 
		    goto rb3_released
		    rb3_released_drawing:   
			movlw 0x00
			movwf rb3_button_state
			movlw 0x00
			movwf program_state
			movff PORTA,porta_shape
			movff PORTC,portc_shape
			movff PORTD,portd_shape
			call load_blink_state_to_the_selected_row
			return

    return_from_button:
	return

	
blink_led:	
    movlw delay200ms_count
    movwf counter_2
    movlw delay200ms_count
    movwf counter_3
    movlw 0x00
    cpfseq program_state
    bra program_state_is_1
    program_state_is_0:
	movlw 0x00
	cpfseq blink_state
	bra blink_state_was_1
	blink_state_was_0:
	    movlw 0x01
	    movwf blink_state
		movlw 0x01
		cpfseq selected_row
		bra not_a_selected_0
		setf PORTA
		bra return_from_blink_led
	    not_a_selected_0:
		movlw 0x02
		cpfseq selected_row
		bra not_c_selected_0
		setf PORTC
		bra return_from_blink_led
	    not_c_selected_0:
		setf PORTD
		bra return_from_blink_led
		
	    
	blink_state_was_1:
	    movlw 0x00
	    movwf blink_state
		movlw 0x01
		cpfseq selected_row
		bra not_a_selected_1
		clrf PORTA
		bra return_from_blink_led
	    not_a_selected_1:
		movlw 0x02
		cpfseq selected_row
		bra not_c_selected_1
		clrf PORTC
		bra return_from_blink_led
	    not_c_selected_1:
		clrf PORTD
		bra return_from_blink_led
    
    
    program_state_is_1:
	movlw 0x00
	cpfseq blink_state
	bra blink_state_was_11
	blink_state_was_00:
	    movlw 0x01
	    movwf blink_state
	    bra return_from_blink_led
	blink_state_was_11:
	    movlw 0x00
	    movwf blink_state
	    bra return_from_blink_led
    
	    
    return_from_blink_led:
	return
    
    
	
main:
    decf counter_3 
    bnz call_button_state
    decf counter_2
    bnz call_button_state
    msec200_passed:
	call blink_led
    call_button_state:
	call button_state

	
	
	
    goto main
	
	
    
end