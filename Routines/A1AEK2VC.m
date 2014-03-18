A1AEK2VC ; VEN/SMH - KIDS to Version Control;2014-03-17  7:53 PM
 ;;2.4;PATCH MODULE;;
 ;
EN(P11005IEN) ; Public Entry Point.
 ; Input: 11005/11005.1 IEN
 I '$O(^A1AE(11005.1,P11005IEN,2,0)) QUIT  ; No KIDS build.
 ;
 ;
 ; Stanza: Find $KID; quit if we can't find it. Otherwise, rem where it is.
 N I,T F I=0:0 S I=$O(^A1AE(11005.1,P11005IEN,2,I)) Q:'I  S T=^(I,0) Q:($E(T,1,4)="$KID")
 I T'["$KID" QUIT
 N SVLN S SVLN=I ; Saved line
 K T
 ;
 ;
 ; Get rid of the next two lines (**INSTALL NAME** and its value)
 S SVLN=$O(^A1AE(11005.1,P11005IEN,2,SVLN))
 S SVLN=$O(^A1AE(11005.1,P11005IEN,2,SVLN))
 ;
 ;
 ; Stanza to Load the KIDS into a temp global.
 ; Why? B/c KIDS export may scramble some nodes. (Like BLD).
 ; We need to group them back together.
 N PD S PD=$$GET1^DIQ(11005,P11005IEN,.01) ; Patch description
 N ROOT S ROOT=$$GET1^DIQ(11005,P11005IEN,6.1) ; Patch path root
 K ^XTMP("K2VC")
 S ^XTMP("K2VC",0)=$$FMADD^XLFDT(DT,1)_DT_U_"KIDS to Version Control"
 N L1,L2
 N DONE S DONE=0
 F  D  Q:DONE
 . S L1=$O(^A1AE(11005.1,P11005IEN,2,SVLN))  ; first line
 . N L1TXT S L1TXT=^(L1,0)                   ; its text
 . I $E(L1TXT,1,8)="$END KID" S DONE=1 QUIT  ; quit if we are at the end
 . S L2=$O(^A1AE(11005.1,P11005IEN,2,L1))    ; second line
 . N L2TXT S L2TXT=^(L2,0)                   ; its text
 . S @("^XTMP(""K2VC"","""_PD_""","_L1TXT)=L2TXT      ; Set our data into our global
 . S SVLN=L2                                 ; move data pointer to last accessed one
 ;
 ;
 ; Stanza to process each component of loaded global
 N A1AEFAIL S A1AEFAIL=0
 N TYP S TYP=""
 F  S TYP=$O(^XTMP("K2VC",PD,TYP)) Q:TYP=""  Q:A1AEFAIL  D
 . I TYP="BLD" D BLD K ^XTMP("K2VC",PD,TYP) Q:A1AEFAIL       ; Process BUILD Section
 . I TYP="PKG" D PKG K ^XTMP("K2VC",PD,TYP) Q:A1AEFAIL       ; Process Package Section
 I A1AEFAIL D EN^DDIOL("A failure has occured")
 QUIT
 ;
BLD ; Build components - See IN+11^XPDIJ1. IEN is disposable.
 D OPEN^%ZISH("BUILD",ROOT,"Build.zwr","W")
 I POP S A1AEFAIL=1 QUIT
 U IO
 D ZWRITE($NA(^XTMP("K2VC",PD,TYP)),4,"IEN") ; Super ZWRITE.
 D CLOSE^%ZISH("BUILD")
 D EN^DDIOL("Wrote Build.zwr at "_ROOT)
 QUIT
 ;
PKG ; Package components - See PKGADD^XPDIP. IEN is disposable.
 D OPEN^%ZISH("PACKAGE",ROOT,"Package.zwr","W")
 I POP S A1AEFAIL=1 QUIT
 U IO
 D ZWRITE($NA(^XTMP("K2VC",PD,TYP)),4,"IEN")
 D CLOSE^%ZISH("PACKAGE")
 D EN^DDIOL("Wrote Package.zwr at "_ROOT)
 QUIT
 ;
MKDIR(DIR) ; Mk dir
 ; TODO: Check command return value
 N CMD S CMD="mkdir -p "_DIR
 I +$SY=47 O "p":(shell="/bin/sh":command=CMD)::"pipe" U "p" C "p"
 I +$SY=0 N % S %=$ZF(-1,CMD)
 QUIT
 ;
ZWRITE(NAME,QS,QSREP)	; Replacement for ZWRITE ; Public Proc
 ; Pass NAME by name as a closed reference. lvn and gvn are both supported.
 ; QS = Query Subscript to replace. Optional.
 ; QSREP = Query Subscrpt replacement. Optional, but must be passed if QS is.
 ; : syntax is not supported (yet)
 S QS=$G(QS),QSREP=$G(QSREP)
 I QS,'$L(QSREP) S $EC=",U-INVALID-PARAMETERS,"
 N INCEXPN S INCEXPN=""
 I $L(QSREP) S INCEXPN="S $G("_QSREP_")="_QSREP_"+1"
 N L S L=$L(NAME) ; Name length
 I $E(NAME,L-2,L)=",*)" S NAME=$E(NAME,1,L-3)_")" ; If last sub is *, remove it and close the ref
 N ORIGLAST S ORIGLAST=$QS(NAME,$QL(NAME))       ; Get last subscript upon which we can't loop further
 N ORIGQL S ORIGQL=$QL(NAME)         ; Number of subscripts in the original name
 I $D(@NAME)#2 W $S(QS:$$SUBNAME(NAME,QS,QSREP),1:NAME),"=",$$FORMAT(@NAME),!        ; Write base if it exists
 ; $QUERY through the name. 
 ; Stop when we are out.
 ; Stop when the last subscript of the original name isn't the same as 
 ; the last subscript of the Name. 
 F  S NAME=$Q(@NAME) Q:NAME=""  Q:$QS(NAME,ORIGQL)'=ORIGLAST  D
 . W $S(QS:$$SUBNAME(NAME,QS,QSREP),1:NAME),"=",$$FORMAT(@NAME),!
 QUIT
 ;
SUBNAME(N,QS,QSREP) ; Substitue subscript QS's value with QSREP in name reference N
 N VARCR S VARCR=$NA(@N,QS-1) ; Closed reference of name up to the sub we want to change
 N VAROR S VAROR=$S($E(VARCR,$L(VARCR))=")":$E(VARCR,1,$L(VARCR)-1)_",",1:VARCR_"(") ; Open ref
 N B4 S B4=$NA(@N,QS),B4=$E(B4,1,$L(B4)-1) ; Before sub piece, only used in next line
 N AF S AF=$P(N,B4,2,99) ; After sub piece
 QUIT VAROR_QSREP_AF
 ;
FORMAT(V)	; Add quotes, replace control characters if necessary; Public $$
 ;If numeric, nothing to do.
 ;If no encoding required, then return as quoted string.
 ;Otherwise, return as an expression with $C()'s and strings.
 I +V=V Q V ; If numeric, just return the value.
 N QT S QT="""" ; Quote
 I $F(V,QT) D     ;chk if V contains any Quotes
 . N P S P=0          ;position pointer into V
 . F  S P=$F(V,QT,P) Q:'P  D  ;find next "
 . . S $E(V,P-1)=QT_QT        ;double each "
 . . S P=P+1                  ;skip over new "
 I $$CCC(V) D  Q V  ; If control character is present do this and quit
 . S V=$$RCC(QT_V_QT)  ; Replace control characters in "V"
 . S:$E(V,1,3)="""""_" $E(V,1,3)="" ; Replace doubled up quotes at start
 . N L S L=$L(V) S:$E(V,L-2,L)="_""""" $E(V,L-2,L)="" ; Replace doubled up quotes at end
 Q QT_V_QT ; If no control charactrrs, quit with "V"
 ;
CCC(S)	;test if S Contains a Control Character or $C(255); Public $$
 Q:S?.E1C.E 1
 Q:$F(S,$C(255)) 1
 Q 0
 ;
RCC(NA)	;Replace control chars in NA with $C( ). Returns encoded string; Public $$
 Q:'$$CCC(NA) NA                         ;No embedded ctrl chars
 N OUT S OUT=""                          ;holds output name
 N CC S CC=0                             ;count ctrl chars in $C(
 N C255 S C255=$C(255)                   ;$C(255) which Mumps may not classify as a Control
 N C                                     ;temp hold each char
 N I F I=1:1:$L(NA) S C=$E(NA,I) D           ;for each char C in NA
 . I C'?1C,C'=C255 D  S OUT=OUT_C Q      ;not a ctrl char
 . . I CC S OUT=OUT_")_""",CC=0          ;close up $C(... if one is open
 . I CC D
 . . I CC=256 S OUT=OUT_")_$C("_$A(C),CC=0  ;max args in one $C(
 . . E  S OUT=OUT_","_$A(C)              ;add next ctrl char to $C(
 . E  S OUT=OUT_"""_$C("_$A(C)
 . S CC=CC+1
 . Q
 Q OUT
 ;
TEST D EN^XTMUNIT($T(+0),1) QUIT
T1 ; @TEST subscript substitutions
 D CHKEQ^XTMUNIT($$SUBNAME($NA(^DIPT(2332,0)),1,"IEN"),"^DIPT(IEN,0)")
 D CHKEQ^XTMUNIT($$SUBNAME($NA(^DIPT("A",123,0)),2,"IEN"),"^DIPT(""A"",IEN,0)")
 QUIT
TEST1 ; @TEST
 D EN(86192)
 QUIT
