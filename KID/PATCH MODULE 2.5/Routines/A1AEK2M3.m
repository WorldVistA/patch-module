A1AEK2M3 ;ven/smh-Interactive kids loading utilities ;2014-03-28T16:08
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;Called from A1AEM1. No other permitted callers.
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ;
SELFILQ(DA) ; Protected; Interactive entry point; Load a Patch from the File System
 ; DA = DHCP PATCH IEN
 ; Select a Patch from the File system for a KIDS build
 N PATCH S PATCH=$$GET1^DIQ(11005,DA,.01)
 N LISTINGOK
 N KIDFIL S KIDFIL=""
 N Y
 N DONE
 F  D  Q:$G(DONE)!(Y=U)
 . N DIR,X,DIROUT,DIRUT,DTOUT,DUOUT,DIROUT ; fur DIR
 . S DIR(0)="F^1:255"
 . S DIR("A")="Import KIDS build from this directory"
 . D ^DIR
 . I $D(DTOUT)!$D(DUOUT)!(U[Y)!(Y[U) S Y=U QUIT
 . N ARRAY S ARRAY("*.KI*")="",ARRAY("*.ki*")="",ARRAY("*.k")=""
 . N FILE
 . S LISTINGOK=$$LIST^%ZISH(Y,$NA(ARRAY),$NA(FILE))
 . I 'LISTINGOK DO  QUIT
 . . W "Couldn't find any KID files here. Try again or '^'."
 . S KIDFIL=$$SELFIL(.FILE,,"Select a KIDS build to match to "_PATCH)
 . ;
 . I U[KIDFIL S Y=U QUIT
 . ;
 . K ^TMP($J,"TKID"),^("ANKID") ; Temp KID; Analysis KID
 . N % S %=$$FTG^%ZISH(Y,KIDFIL,$NA(^TMP($J,"TKID",1,0)),3)   ; To Global
 . I '% S $EC=",U-FILE-DISAPPEARED,"
 . D ANALYZE^A1AEK2M1($NA(^TMP($J,"ANKID")),$NA(^TMP($J,"TKID"))) ; Analyze the file
 . ;
 . ; Loop through every patch in the file and make sure at least one matches.
 . N P S P=""
 .  F  S P=$O(^TMP($J,"ANKID",P)) Q:P=""  I $$K2PMD^A1AEK2M(P)=PATCH QUIT
 . I P="" W !,"None of the patches in this KID file match "_PATCH,! QUIT
 . ;
 . ; Okay. Wow. We can finally load this baby into 11005.1. But we have to append it to the $TXT first.
 . K ^TMP($J,"MSG")
 . N % S %=$$GET1^DIQ(11005,DA,5.5,"Z",$NA(^TMP($J,"MSG")))  ; Load WP with zero nodes after each sub
 . ;
 . ; Move over one for the $TXT line added by CLEANHF
 . K ^TMP($J,"MSG2")
 . N I F I=0:0 S I=$O(^TMP($J,"MSG",I)) Q:'I  S ^TMP($J,"MSG2",I+1,0)=^(I,0)
 . K ^TMP($J,"MSG") ; Make sure it dead so I won't use it by mistake
 . ;
 . D CLEANHF^A1AEK2M0($NA(^TMP($J,"MSG2")))
 . N LS S LS=$O(^TMP($J,"MSG2"," "),-1)
 . N NS S NS=LS+1
 . ;
 . N L,LN F L=0:0 S L=$O(^TMP($J,"ANKID",P,L)) Q:'L  S LN=^(L),^TMP($J,"MSG2",NS,0)=LN,NS=NS+1
 . D LDKID^A1AEK2M0($NA(^TMP($J,"MSG2")),DA,0)
 . S DONE=1
 . S A1AEKIDS=1 ; ZEXCEPT: A1AEKIDS - Leak out as this operates the input template
 K ^TMP($J,"TKID"),^("ANKID"),^("MSG"),^("MSG2")
 QUIT
 ;
SELFIL(FILES,EXTFILTER,DIRA) ; Public; INTERACTIVE ; Select a file from a list
 ; FILES = Ref List of files from LIST^%ZISH
 ; EXTFILTER = Val .TXT or so
 ; DIRA = Val What to ask the user for
 ; Uses fileman calls to ease the pain of selecting stuff.
 ;
 N I S I=""
 ; Filter away using the extension
 I $L($G(EXTFILTER)) F  S I=$O(FILES(I)) Q:I=""  D
 . I $E($RE(I),1,$L(EXTFILTER))'=$RE(EXTFILTER) K FILES(I)
 ;
 ; If no files left, quit with an empty string
 Q:'$L($O(FILES(""))) ""
 ;
 ; Create a global for DIR/DIC
 K ^TMP($J,"FILES")
 S ^TMP($J,"FILES",0)="File List"
 N CNT S CNT=1
 F  S I=$O(FILES(I)) Q:I=""  S ^TMP($J,"FILES",CNT,0)=I,CNT=CNT+1
 ;
 ; Index
 N DIK,DA S DIK="^TMP($J,""FILES""," D IXALL^DIK
 ; Select
 N DIR,X,Y,DIROUT,DIRUT,DTOUT,DUOUT,DIROUT
 S DIR(0)="P^TMP($J,""FILES"",",DIR("A")=$G(DIRA,"Select a file from the list") D ^DIR
 I $D(DTOUT)!$D(DUOUT)!(U[Y)!(Y[U) S Y=U QUIT ""
 ; Bye
 K ^TMP($J,"FILES")
 ;
 I $L(Y,U)=2 Q $P(Y,U,2)
 E  QUIT ""
 ;
