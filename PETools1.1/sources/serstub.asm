; #########################################
; # SERIAL PORT EXTENSION STUB for        #
; # PE Tools - a toolkit to extend the    #
; # possibilities of the sharp 1403(H)    #
; # This is a dummy - it makes it         #
; # possible to call the serial port      #
; # extension call addresses without      #
; # crashing to 1403.                     # 
; # author   : Puehringer Edgar           #
; # date     : 07.08.2002                 #
; # version  : 1.1                        #
; # assembler: YASM 1.1                   #
; #########################################

	ORG $84CF		; 33999 = next free address after 
				; PE Tools part two

; #########################################
; # SAVAIL since 1.1                      #
; # serial extension availability flag    #
; # if 0 -> serial port ext. not avail.   #
; # if 1 -> serial port ext. available    #
; #########################################

SAVAIL:	DB	$00		; not available !

; #########################################
; # REMOTE since 1.1                      #
; # Starts the serial remote mode. A      #
; # prompt is displayed one a connected   #
; # terminal.                             #
; #                                       #
; # Side effects of this procedure:       #
; #  - GMODE "replace" is called          #
; #  - Std. var. M is used                #
; #########################################

;REMOTE:	CALL	REMOTI
REMOTE:	NOPW
	NOPW
	NOPW

	RTN

; #########################################
; # SPRINT since 1.1                      #
; # Prints the print text buffer to the   #
; # serial port                           #
; #########################################

;SPRINT:	CALL	SPRNTI
SPRINT:	NOPW
	NOPW
	NOPW

	RTN

; #########################################
; # SPRNTN since 1.1                      #
; # Prints the print text buffer to the   #
; # serial port; after this, a lf or a    #
; # cr-lf is sent. Which line end         #
; # character is used depends on the      #
; # setting of function CRLF              #
; #########################################

;SPRNTN:	CALL	SPRNTI
SPRNTN:	NOPW
	NOPW
	NOPW

	NOPW

; #########################################
; # CRLF since 1.1                        #
; # Prints a lf or a cr-lf to the serial  #
; # port                                  #
; #                                       #
; # If you want to use lf:                #
; #   Poke $0A to address CRLF+1          #
; # If you want to use cr-lf:             #
; #   Poke $0D to address CRLF+1          #
; #########################################

CRLF:	LIA	$0D
;	JRP	CRLFI
	NOPW
	RTN

; #########################################
; # CTRLZ since 1.1                       #
; # Prints a Ctrl-Z to the serial port    #
; #########################################

CTRLZ:	LIA	$1A
;	JRP	SENDC
	NOPW
	RTN

; #########################################
; # SINPUT since 1.1                      #
; # Reads from serial port and stores the #
; # result into the least refenced field  #
; # variable                              #
; #########################################

;SINPUT:	CALL	SINPTI
SINPUT:	NOPW
	NOPW
	NOPW

	RTN

; #########################################
; # LLIST since 1.1                       #
; # Writes the basic listing to the       #
; # serial port.                          #
; # Note: The tokens must be decoded on   #
; # the host system                       #
; #########################################

;LLIST:	CALL	LLISTI
LLIST:	NOPW
	NOPW
	NOPW

	RTN

; #########################################
; # SLOAD since 1.1                       #
; # Reads a basic listing from the serial #
; # port and stores it into the RAM. An   #
; # existing program is replaced.         #            
; # Note: The tokens must be decoded on   #
; # the host system                       #
; #########################################

;SLOAD:	CALL	SLOADI
SLOAD:	NOPW
	NOPW
	NOPW

	RTN

; #########################################
; # SMERGE since 1.1                      #
; # Reads a basic listing from the serial #
; # port and stores it into the RAM. The  #
; # program is merged to the existing     #
; # program.                              #
; # Note: The tokens must be decoded on   #
; # the host system                       #
; #########################################

;SMERGE:	CALL	SMERGI
SMERGE:	NOPW
	NOPW
	NOPW

	RTN
