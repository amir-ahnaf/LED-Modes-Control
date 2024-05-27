; Embedded Computing
; This program intends to display the light in 3 modes: PWM, Strobing, and Linear feedback shift register (LFSR)
; PWM: light turns ON based on registered duty cycle
; Strobing: Lights moves from right to left
; LFSR: Light turns ON based on the feedback register

#include	ECH_1.inc
	
; Place your SUBROUTINE(S) (if any) here ...  
;{ 
ISR	CODE	H'20'
ISR	nop
	; Reset required variables to go to main loop from mode loops
	bsf	M_Flag, 0		; M_Flag (Main Flag) will only set if interrupt is called
	bsf	STATUS, Z		; Set Z bit in STATUS register for SSs function 
	clrf	SSs_Ctr		; Clear the SSs counter
	
	; Reset the interrupt ensuring the this interrupt is only called when it is required
	banksel	PORTB		; Sleect PORTB bank
	clrf	PORTB		; Clear the PORTB
	banksel	INTCON		; Select INTCON bank
	bcf	INTCON, INTF	; Clearing the INTF
	bcf	INTCON, INTE	; Clear the INTE interrupt to ensure it is called only when needded
	retfie

; These sub routine is to check the change in AN0
; Only be used if the program can detect AN0 changes
In_ADC	nop			
	call	ReadADC		 ; Check ADC value
	movfw	ADRESH
	movwf	M_Temp		; Store value of ADRESH for a moment
	rlf	M_Temp, f
	rlf	M_Temp, f
	rlf	M_Temp, f
	movfw	M_Temp
	andlw	D'3'
	return			; Store the first 2 bit in the ADRESH 
	
M_Chk	nop			; Check iff there is a change in AN0
	call	In_ADC
	movwf	M_Cur
	xorwf	M_Old, w
	btfss	STATUS, Z
	goto	Upd_M_F
	movfw	ADH_Tmp
	movwf	ADRESH
	return
	
Upd_M_F	bsf	Mod_F, 0		; Update the new Mod_F if there is any changes
	movfw	M_Cur
	movwf	M_Old
	movfw	ADH_Tmp
	movwf	ADRESH
	return
	
    
; SubRoutine for inserting the input, this subroutine is made to ensure the INTE is clear before getting the input
Put_Input   nop	
	movfw	ADRESH
	movwf	ADH_Tmp
	bcf	INTCON, INTE
	call	SelectB		; Call selectB, insert the input and saved in the W
	movwf	PI_Temp
	movfw	ADH_Tmp
	movwf	ADRESH
	movfw	PI_Temp
	return
	
	
; For Speed selection function, use CALL as this function has return
; This function is to return the selected speed based on input selection
SpdSel	nop
	movlw	D'100'
	call	DelWms
	call	Put_Input		; Obtain input from the user
	movwf	Spd_Opt		; Save the Speed option in Spd_Opt
	
	; If function to choose the Speed option and return the speed based on the selection
	; compare the input to selection 0
	movlw	0		; Move 0 into W
	subwf	Spd_Opt,w		; Compare the Spd_Opt with 0 in W
	btfsc	STATUS, Z		; If its 0, go to SpdSel0
	goto	SpdSel0
    
	; compare the input to selection 1
	movlw	1		; Move 1 into W
	subwf	Spd_Opt,w		; Compare the Spd_Opt with 1 in W
	btfsc	STATUS, Z		; If its 1, go to SpdSel1
	goto	SpdSel1
    
	; compare the input to selection 2
	movlw	2		; Move 2 into W
	subwf	Spd_Opt,w		; Compare the Spd_Opt with 2 in W
	btfsc	STATUS, Z		; If its 2, go to SpdSel2
	goto	SpdSel2
	
	; compare the input to selection 3
	movlw	3		; Move 3 into W
	subwf	Spd_Opt,w		; Compare the Spd_Opt with 3 in W
	btfsc	STATUS, Z		; If its 0, go to SpdSel3
	goto	SpdSel3
	
	; if its is not all of them (default), go to EnSpdSel for protection
	goto	EnSpdSel
	
SpdSel0	movlw	D'50'		; Save the speed at Selection 0 to the W
	goto	EnSpdSel
    
SpdSel1	movlw	D'100'		; Save the speed at Selection 1 to the W
	goto	EnSpdSel
    
SpdSel2	movlw	D'150'		; Save the speed at Selection 2 to the W
	goto	EnSpdSel
	
SpdSel3	movlw	D'255'		; Save the speed at Selection 3 to the W
	goto	EnSpdSel
    
EnSpdSel	nop			; at End Speed Selection, the function is returned
	return
	
	
; Brightness selection
; For Brightness selection function, use CALL as this function has return
; This function is to return the selected brightness based on input selection
BrgSel	nop 
	call	Put_Input		; Obtain input from the user
	movwf	Brg_Opt		; Save it in Brg_Opt
	
	; compare the input to selection 0
	movlw	0		; Move 0 to W
	subwf	Brg_Opt, w		; Comapre Brightness option with 0 in W
	btfsc	STATUS, Z		; If its 0, go to the BrgSel0
	goto	BrgSel0		
    
	; compare the input to selection 1
	movlw	1		; Move 1 to W
	subwf	Brg_Opt, w		; Comapre Brightness option with 1 in W
	btfsc	STATUS, Z		; If its 1, go to the BrgSel1
	goto	BrgSel1
    
	; compare the input to selection 2
	movlw	2		; Move 2 to W
	subwf	Brg_Opt, w		; Comapre Brightness option with 2 in W
	btfsc	STATUS, Z		; If its 2, go to the BrgSel2
	goto	BrgSel2
	
	; compare the input to selection 3
	movlw	3		; Move 3 to W
	subwf	Brg_Opt, w		; Comapre Brightness option with 3 in W
	btfsc	STATUS, Z		; If its 3, go to the BrgSel3
	goto	BrgSel3
	
	; if its is not all of them (default), go to EnBrgSel for protection
	goto	EnBrgSel
	
BrgSel0	movlw	D'30'		; Save brightness selection 0 in W
	goto	EnBrgSel
    
BrgSel1	movlw	D'100'		; Save brightness selection 1 in W
	goto	EnBrgSel
    
BrgSel2	movlw	D'150'		; Save brightness selection 2 in W
	goto	EnBrgSel
	
BrgSel3	movlw	D'230'		; Save brightness selection 3 in W
	goto	EnBrgSel
    
EnBrgSel	nop			; At the End Brightness Selection, return to the previous function
	return

	
; PWM_Disp is a function to display the PWM mode after all the required parameter already given in PWM_rou
; PWM_Disp function will keep looping until interrupt is called, and back to main loop
PWM_Disp	nop
	
	; PWM_Disp initialization, initiate required variable, and control some peripheral
	; INTF will be clear and INTE is set to enable this interrupt after it was turned off in the user selection
	banksel	INTCON		; Select INTCON bank
	bcf	INTCON, INTF	; Clear INTF to reset the interrupt, preventing previous interruption
	bsf	INTCON, INTE	; Setting up INTE
	clrf	M_Flag		; Clear M_Flag to reset the main flag
	
	; Compare the Brg1 and Brg 2, if they are same, return to the previous function
	movfw	PWM_Brg1		; Move PWM_Brg1 value into W
	movwf	PWM_Cur		; Save it in PWM_Cur (Current PWM value)
	xorwf	PWM_Brg2, w	; Compare it with PWM_Brg2
	btfsc	STATUS, Z		; If they are not same, proceed wirth displaying the PWM
	goto	PWM_rou		; If they are same, return to main function
	
; PWM_Lop will keep looping until PWM_Brg1 value same as PWM_Brg2
PWM_Lp	nop
	movfw	PWM_Spd		; Move PWM Speed value into the W
	call	DelWms		; Delay is for the speed
	
	
	
	; Check if the interrupt is called or not, if it's called, M_Flag is set, and return to main function
	btfsc	M_Flag, 0		; Check the first bit of M_Flag, return if it's set
	goto	PWM_in
	
	movfw	PWM_Cur		; Move PWM_Cur into W
	movwf	LEDs		; PWM_Cur value is displayed in the LEDs
	incf	PWM_Cur		; Increase the value of PWM_Cur
	xorwf	PWM_Brg2, w	; Compare current PWM value to the second brightness value
	; SHLDNT BE ANYTHG BT XOR AND STATUS CHK	
	; interrupt
	; If current PWM value have not reach the PWM_Brg2, goto PWM_Lp
	btfss	STATUS, Z		; If they are asame already, go to the PWM_Disp
	goto	PWM_Lp		; Goto PWM_Lp loop until they are same
	
	goto	PWM_Disp		; Goto the PWM_Disp function if they reach the same value
	
	
; PWM subroutine, when PWM mode is opted, this function is called, obtaining the required input from user and display it to the LED	
PWM_rou	nop
	;default value
	movlw	D'255'
	movwf	PWM_Spd
	movlw	D'5'
	movwf	PWM_Brg1
	movlw	D'70'
	movwf	PWM_Brg2
	
	btfss	M_Flag, 0		; If no interrupt, go by default value
	goto	PWM_Disp
	
	; 1st configuration: PWM Speed
PWM_in	nop
	call	SpdSel		; Call the speed selection fucntion to get the speed
	movwf	PWM_Spd		; Save it in PWM_Spd
	
	; 2nd configuration: PWM Brightness 1
	call	BrgSel		; Call the brightness selection to obtain Brightness 1
	movwf	PWM_Brg1		; Save it in PWM_Brg1
	
	; 3rd configuration: PWM Brightness 2
	call	BrgSel		; Call the brightness selection to obtain Brightness 2
	movwf	PWM_Brg2		; Save it in PWM_Brg2
	
	bsf	INTCON, INTE
	bcf	M_Flag, 0
	
	; Call the PWM_Displ to display the PWM mode depending on the given parameters
	goto	PWM_Disp		
	
PWM_End	goto	EnMSel			; Return to the main function

	
; These are subroutines for Side to Side Strobe function
; right_dir moving the SSs brightness to the right
right_dir	movlw	0x09		; Set loop count to 7
	movwf	SSs_Ctr		; Save in the
r_loop	movfw	SSs_Cry
	movwf	STATUS
	rrf	SSs_Brg,w		; Rotate SSs_Brg right through carry, save the new value into W
	movwf	SSs_Brg		; Save the value in SSs_Brg
	movwf	LEDs		; Show the value into LEDs
	movfw	STATUS
	movwf	SSs_Cry
	
	movfw	SSs_Spd		; Move the SSs_speed value into W
	call	DelWms		; Call the delay function
	
	; Check if the intterupt is called or not, if it is, return to the main function
	btfsc	M_Flag, 0		; If M_Flag haven;t called (M_FLag is 0), skip the return
	return			; Return if the interrupt was called
	
	decfsz	SSs_Ctr, f		; Decrement loop count and check if zero
	goto	r_loop		; Loop back if not zero
	; Finish one rotation
	return

; left_dir moving the SSs brightness to the left
left_dir	movlw	0x09		; Set loop count to 7
	movwf	SSs_Ctr		; Save in the
	clrf	Mod_F
l_loop	movfw	SSs_Cry
	movwf	STATUS
	rlf	SSs_Brg,w		; Rotate SSs_Brg right through carry, save the new value into W
	movwf	SSs_Brg		; Save the value in SSs_Brg
	movwf	LEDs		; Show the value into LEDs
	movfw	STATUS
	movwf	SSs_Cry
	movfw	SSs_Spd		; Move the SSs_speed value into W
	call	DelWms		; Call the delay function
	
	; Check if the intterupt is called or not, if it is, return to the main function
	btfsc	M_Flag, 0		; If M_Flag haven;t called (M_FLag is 0), skip the return
	return			; Return if the interrupt was called
	
	decfsz	SSs_Ctr, f		; decrement loop count and check if zero
	goto	l_loop		; Loop back if not zero
	; Finish one rotation
	return

	
	
	
; Direction loop
; If SSs_dir is 0 or 1, one_dir is called, which only go to right direction
one_dir	nop
	call	right_dir		; Call right_dir loop
	clrf	SSs_Cry
	goto	SSs_end		; Goto SSs_end loop if right_dir is finished
	
; If SSs_dir is 2 or 3, bc_n_fr is called, moving the variable back and forth
bc_n_fr	nop
	call	right_dir		; Call right_dir loop
	clrf	SSs_Cry
	call	left_dir		; After moving right, call left_dir to move the brightness to left
	clrf	SSs_Cry
	goto	SSs_end		; Goto SSs_end loop if left_dir is finished
	
SSs_end	nop
	; if its here, so interrupt was called, but we dont exit the loop, instead, just select new
	btfsc	M_Flag, 0
	goto	SSs_conf		; If it is not, go back to the SSs_loop
	goto	SSs_loop
	
	
; Side to Side strobe (SSs function) will take 2 configuration, speed and direction
; For the direction, if the user selection is 0 or 1, it will be in one direction, if it's 2 or 3, it will be back and forth
SSs_rou	nop
	
	; In this function, the brightness is set as 5 (0b00000101)
	movlw	D'5'		; Put 5 into the W		
	movwf	SSs_Brg		; Save it as SSs_Brg
	movlw	D'200'
	movwf	SSs_Spd
	movlw	D'2'
	movwf	SSs_Dir
	
	btfss	M_Flag, 0		; If no interrupt, go by default value
	goto	SSs_loop
	
SSs_conf    nop
	banksel	INTCON		
	bcf	INTCON, INTF	; Clear INTF for RB0 interrupt
	bcf	INTCON, INTE	; Set the INTE interrupt 
	call	SpdSel		; Call SpdSel to select speed of SSs mode
	movwf	SSs_Spd		; Store the value in SSs_Spd
	
	call	Put_Input		; Get user input for the direction
	movwf	SSs_Dir		; Save the direction selection in SSs_Dir

SSs_loop	nop			; SSs_loop will keep looping until interrupt is called
	; Required peripheral and variable reset
	banksel	INTCON		
	bcf	INTCON, INTF	; Clear INTF for RB0 interrupt
	bsf	INTCON, INTE	; Set the INTE interrupt 
	clrf	M_Flag		; Clear Main flag 
	
	clrf	SSs_Cry
	btfss	SSs_Dir, 1		; If SSs_Dir is 2 or 3 (0b0000001X), skip the next line
	goto	one_dir		; if is 0 or 1 (0b0000000X), go to one_dir loop
	
	; if direction option is selection 2 or 3
	btfsc	SSs_Dir, 1		; if is 0 or 1 (0b0000000X), skip the next line, just for protection
	goto	bc_n_fr		; if is 2 or 3, goto bc_n_fr loop
	
	btfss	M_Flag, 0		; If no interrupt, go by default value
	goto	SSs_loop
	goto	SSs_conf
	
SSs_back	goto	EnMSel		; SHLDNT BE USED YET, only with AN0 changes
	
	
; LSFR function	
LFSR_rou    nop
	; LFSR Speed configuration
	movlw	D'255'
	movwf	LFSR_Spd
	btfss	M_Flag, 0		; If no interrupt, go by default value
	goto	LFSR_init
	
LFSR_conf   nop
	call	SpdSel		; Obatin input from user
	movwf	LFSR_Spd		; Save it in LFSR_Spd
	bcf	INTCON, INTF	; Clear the INTF bit
	clrf	M_Flag		; Clear the interrupt flag
    
LFSR_init   nop
	; setting initialization
	bsf	INTCON, INTE	
	
	; Display the current LFSR value
	movfw	LFSR
	movwf	LEDs		; Show the value into LEDs

	; Perform the Galois LFSR
	movfw	LFSR
	andlw	0x01		; Get the LSB
	movwf	LFSR_temp		; Store the LSB into LFSR_temp

	; Check the LSB
	movfw	LFSR_temp
	btfsc	STATUS, Z		; If zero flag is set, LSB is 0
	goto	Rotate		; Skip the feedback if LSB is 0

	movlw	0xB8		; Feedback for 8-bit maximal period Galois LFSR
	xorwf	LFSR, f		; XOR the LFSR with the feedback

Rotate	nop
	rrf	LFSR, f		; Right shift the LFSR
	
	; interrupt check
	btfsc	M_Flag, 0		; If no interrupt, go by default value
	goto	LFSR_conf
	
	;delay for each value
	movfw	LFSR_Spd
	call	DelWms		
	
	; Compare with the original value
	movfw	LFSR
	xorwf	ORIG, w		; XOR with the original value
	movwf	LFSR_temp		; Store the result into LFSR_temp

	; Check the result
	movfw	LFSR_temp
	btfss	STATUS, Z		; If zero flag is set, values are equal
	goto	LFSR_init
	
	;delay for each value
	movfw	LFSR_Spd		; If the LFSR value is same with the original value, 
	call	DelWms		; The delay is longer than other LFSR value
	movfw	LFSR_Spd
	call	DelWms 
	movfw	LFSR_Spd
	call	DelWms 
	goto	LFSR_rou
	
LFSR_end    goto	EnMSel		; return to EnMSel if there is AN0 change, wouldnt be used in partial sign off
  
	
ModeSel	nop
	
	call	In_ADC		; Select the Mode from user
	movwf	M_Old
	movwf	Mode		; Save the value in A, A used for mode selection
	
	; Show the mode at RD6 and RD7
	movwf	Temp		; Move the Mode into Temp 
	rrf	Temp, f		; Rotate the Temp to the right from LD1 to LD7
	rrf	Temp, f
	rrf	Temp, w
	movwf	LEDs		; Show the rotated value into LEDs
    
	; compare Mode to 0
	movlw	0		; Move 0 into W
	subwf	Mode, w 		; Compare Mode with 0
	btfsc	STATUS, Z		; If they are same, go to mode1
	goto	mode1
	
	; compare Mode to 1
	movfw	M_Old
	movwf	Mode
	movlw	2		; Move 2 into W
	subwf	Mode, w		; Compare Mode with 2
	btfsc	STATUS, Z		; If they are same, go to mode2
	goto	mode2
	
	; compare Mode to 2
	movfw	M_Old
	movwf	Mode
	movlw	3		; Move 3 into W
	subwf	Mode, w		; Compare Mode with 3
	btfsc	STATUS, Z		; If they are same, go to mode3
	goto	mode3	    
    
	; handle invalid mode selection
	goto	EnMSel		; goto EnMSel if other than selected mode value is given

mode1	
	clrf	Mod_F
	movfw	Mode	
	movwf	M_Cur
	goto	PWM_rou		; Call the subroutine for PWM mode
	goto	EnMSel
    
mode2
	movfw	Mode	
	movwf	M_Cur
	clrf	Mod_F
	goto	SSs_rou		; Call the subroutine for Side to Side Strobe mode
	goto	EnMSel
    
mode3
	clrf	Mod_F
	call	LFSR_rou		; Call the subroutine for Linear Feedback Shift Register mode
	goto	EnMSel
    
EnMSel	return			; Return back to main loop
	
;} end of your subroutines


; Main loop
Main	nop
#include ECH_INIT.inc
	; Peripheral initialization
	banksel	PORTB		; Select PORTB bank
	clrf	PORTB		; Clear PORTB
	banksel	TRISB		; Select TRIB bank
	movlw	0b00000001	; Move 1 into W
	movwf     TRISB		; Move 1 into TRISB
	banksel	INTCON		; Select INTCON bank
	bcf	INTCON, INTE	; Clear INTE bit
	bcf	OPTION_REG, INTEDG ; Clear INTEDG bit to choose the falling edge
	bsf	INTCON, GIE	; Enable global interrupts
	
	movlw	0xc3
	movwf	LFSR		; initiate LFSR and ORIG value
	movwf	ORIG		; Save the original value
; end of your initialisation

MLoop	nop

; place your superloop code here ...  
;{	
	; For the working code, only call   ModeSel will be called
	; Since it is not working, we will call each of the subroutine
	
	; AN0 checking subroutine
	;call	Put_Input
	;call	M_Chk
	
	; subroutine for each mode
	;call	PWM_rou
	;call	SSs_rou
	call	LFSR_rou
	
	;call	ModeSel		; Call Mode Selection Loop
	clrf	Mod_F
;}	
; end of your superloop code
	goto	MLoop
	
	end