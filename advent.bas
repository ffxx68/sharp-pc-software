10 REM *** Descrizine stanze ***
20 DIM S$(5)
30 S$(1) = "Questa stanza è molto grande"
40 S$(2) = "In questa stanza c'e' un mostro!"
50 S$(3) = "Al centro della stanza scintilla un tesoro enorme!"
60 S$(4) = "In questa stanza c'è una trappola mortale."
70 S$(5) = "Qui una delle porte si apre verso la liberta'."

80 DIM O$(5)
90 O$(1) = "Spada"
100 O$(2) = "Scudo"
110 O$(3) = "Pozione"
120 O$(4) = "Cibo"
130 O$(5) = "Tesoro"

140 DIM P$(2)
150 P$(1) = "Mostro"
160 P$(2) = "Guardiano"

170 DIM I$(5)
180 FOR X = 1 TO 5: I$(X) = "": NEXT X

190 REM *** Definizione delle connessioni tra le stanze ***
200 DIM N(5), D(5), E(5), W(5)
210 N(1) = 2: D(2) = 1
220 E(1) = 3: W(3) = 1
230 W(2) = 4: E(4) = 2
240 N(3) = 5: D(5) = 3

250 REM *** Definizione degli oggetti posseduti dai personaggi ***
260 DIM Q$(2)
270 Q$(1) = "Chiave"
280 Q$(2) = "Pozione"

290 REM *** Oggetti nelle stanze ***
291 DIM M(5)
292 M(1) = 1


293 REM *** Personaggi nelle stanze ***
294 DIM R(2)
295 R(1) = 1: R(2) = 4

300 REM *** Gestione del flusso di gioco ***
310 PRINT "Benvenuto nell'avventura di Dungeon & Dragons!"
320 LET Z = 1
330 GOSUB 500

340 PRINT "Cosa vuoi fare?"
350 INPUT "Inserisci il tuo comando: ", A$
360 IF A$ = "nord" THEN IF N(Z) <> 0 THEN LET Z = N(Z): GOSUB 500: GOTO 340
365 IF N(Z) = 0 THEN PRINT "Non puoi andare a nord.": GOTO 340
370 IF A$ = "sud" THEN IF D(Z) <> 0 THEN LET Z = D(Z): GOSUB 500: GOTO 340
375 IF D(Z) = 0 THEN PRINT "Non puoi andare a sud.": GOTO 340
380 IF A$ = "est" THEN IF E(Z) <> 0 THEN LET Z = E(Z): GOSUB 500: GOTO 340
385 IF E(Z) = 0 THEN PRINT "Non puoi andare a est.": GOTO 340
390 IF A$ = "ovest" THEN IF W(Z) <> 0 THEN LET Z = W(Z): GOSUB 500: GOTO 340
395 IF W(Z) = 0 THEN PRINT "Non puoi andare a ovest.": GOTO 340
400 IF A$ = "prendi" THEN GOSUB 700: GOTO 340
410 IF A$ = "usa" THEN GOSUB 800: GOTO 340
420 PRINT "Comando non valido. Prova di nuovo."
430 GOTO 340

500 REM *** Routine per descrivere la stanza corrente ***
510 PRINT S$(Z)
515 IF M(Z) <> 0 THEN PRINT "Qui vedo: "; O(M(Z)) 
520 IF Z = 2 THEN GOSUB 600
530 IF Z = 5 THEN PRINT "Hai completato il gioco con successo!": END
540 RETURN

600 REM *** Incontro con il mostro ***
610 PRINT "C'e' un mostro qui! Vuoi combattere o scappare?"
620 INPUT "Inserisci il tuo comando: ", B$
630 IF B$ = "combatti" THEN PRINT "Hai sconfitto il mostro! Complimenti!": END
640 IF B$ = "scappa" THEN PRINT "Sei scappato in sicurezza. Fine del gioco.": END
650 PRINT "Comando non valido. Prova di nuovo."
660 GOTO 620

700 REM *** Routine per prendere un oggetto ***
710 PRINT "Quale oggetto vuoi prendere?"
720 INPUT "Inserisci il nome dell'oggetto: ", C$
730 FOR X = 1 TO 5
740 IF O$(X) = C$ THEN I$(X) = C$: PRINT "Hai preso: "; C$: RETURN
750 NEXT X
760 PRINT "Oggetto non trovato."
770 RETURN

800 REM *** Routine per usare un oggetto ***
810 PRINT "Quale oggetto vuoi usare?"
820 INPUT "Inserisci il nome dell'oggetto: ", D$
830 FOR X = 1 TO 5
840 IF I$(X) = D$ THEN GOSUB 880: RETURN
850 NEXT X
860 PRINT "Oggetto non trovato nell'inventario."
870 RETURN

880 REM *** Effetti degli oggetti ***
890 IF D$ = "Spada" THEN PRINT "Hai brandito la spada. Ti senti piu' forte!"
900 IF D$ = "Scudo" THEN PRINT "Hai sollevato lo scudo. Ti senti piu' protetto!"
910 IF D$ = "Pozione" THEN PRINT "Hai bevuto la pozione. Ti senti rinvigorito!"
920 IF D$ = "Cibo" THEN PRINT "Hai mangiato il cibo. Ti senti sazio e pieno di energia!"
930 I$(X) = ""
940 RETURN

950 REM *** Routine per ottenere oggetti dai personaggi sconfitti ***
960 PRINT "Hai trovato un oggetto sul personaggio sconfitto!"
970 FOR X = 1 TO 2
980 IF Q$(X) <> "" THEN PRINT "Hai trovato: "; Q$(X): I$(X) = Q$(X): Q$(X) = "": RETURN
990 NEXT X
1000 RETURN

1100 REM *** Combattimento con il mostro ***
1110 FOR X = 1 TO 5
1120 IF I$(X) = "Spada" THEN 
1130 NEXT X

