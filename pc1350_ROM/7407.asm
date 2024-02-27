; CALL &1CEF 
; content of A stored in LCD position DPX, DPY
; where DPY is at &7880 and DPY is at &7881
.ORG	7407

	LIDP	30848 ; &10 &7880  &7880 --> DP
	LDD           ; &57        (DP) --> A
	CAL	236       ; &FC &D0   ????  
	LIDP	30849 ; &10 &7881
	LDD
	CPIA	4
	JRCP	LB0
	PUSH
	LP	6
	LIB	2
	LIA	0
	ADB
	POP
	INCA

LB2:	SBIA	5
	CPIA	5
	JRCP	LB1
	PUSH
	LP	6
	LIB	2
	LIA	0
	ADB
	POP
	JRM	LB2
	LIB	0
	LIA	6
	LP	6
	ADB
	POP

LB1:	LP	3
	RC
	SL
	EXAM
	LDM
	SL
	ADM
	EXAB
	LIB	0
	LP	6
	ADB
	RTN

;;;;;;
.ORG	236

	JRM	10468
	
;;;;;
.ORG 10468
