A1AEK2V0 ;ven/smh-Continuation of A1AEK2VC ;2014-03-24T15:46
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ;
RTN(FAIL,RTNGLO,ROOT) ; Routine Exporter
 ; .FAIL - Output. Did we fail? Mostly b/c of filesystem issues.
 ; RTNGLO - The KIDS global ending at "RTN". Use $NA to pass this.
 ; ROOT - File system root where we are gonna make the Routines directory
 ;
 N RTNDIR S RTNDIR=ROOT_"Routines/"
 N % S %=$$MKDIR^A1AEOS(RTNDIR)
 I % S FAIL=1 QUIT
 ;
 D EN^DDIOL("Exporting these routines to Routines/")
 ;
 N POP
 N RTN S RTN=""
 N RTNDDIOL S RTNDDIOL="" ; Output message
 F  S RTN=$O(@RTNGLO@(RTN)) Q:RTN=""  D  Q:POP
 . D OPEN^%ZISH("RTNHDR",RTNDIR,RTN_".header","W")
 . I POP S FAIL=1 QUIT
 . U IO
 . W @RTNGLO@(RTN) ; Header node.
 . D CLOSE^%ZISH("RTNHDR")
 . ;
 . ; Now write the routine code
 . D OPEN^%ZISH("RTNCODE",RTNDIR,RTN_".m","W")
 . I POP S FAIL=1 QUIT
 . U IO
 . N LN F LN=0:0 S LN=$O(@RTNGLO@(RTN,LN)) Q:'LN  W ^(LN,0),!
 . D CLOSE^%ZISH("RTNCODE")
 . ; done!
 . S RTNDDIOL=RTNDDIOL_" "_RTN ; Add to output message
 S $E(RTNDDIOL)="" ; Remove leading space
 ;
 D EN^DDIOL(RTNDDIOL)
 K @RTNGLO
 QUIT
 ;
FIA(FAIL,KIDGLO,ROOT) ; Print FIA, UP, ^DD, ^DIC, SEC, IX, KEY, KEYPTR for each file
 ; .FAIL - Output. Did we fail? Mostly b/c of filesystem issues.
 ; KIDGLO - The KIDS global (not a sub). Use $NA to pass this.
 ; ROOT - File system root where we are gonna export.
 Q:'$D(@KIDGLO@("FIA"))  ; No files to export
 ;
 N POP
 ;
 N PATH S PATH=ROOT_"Files/"
 S POP=$$MKDIR^A1AEOS(PATH)
 I POP D EN^DDIOL($$RED("Couldn't create directory")) S FAIL=1 QUIT
 ;
 D EN^DDIOL("Exporting files DD and Data to Files/")
 ;
 N FILE F FILE=0:0 S FILE=$O(@KIDGLO@("FIA",FILE)) Q:'FILE  D  Q:$G(POP)   ; For each top file in "FIA"
 . N FNUM S FNUM=FILE                                                      ; File Number
 . N FNAM S FNAM=@KIDGLO@("FIA",FILE)                                      ; File Name (Value of the first FIA node)
 . S FNAM=$TR(FNAM,"\/!@#$%^&*()","------------")                          ; Replace punc with dashes
 . N HFSNAME S HFSNAME=FNUM_"+"_FNAM_".DD.zwr"                             ; File Name
 . D OPEN^%ZISH("DD",PATH,HFSNAME,"W")                                     ; Open
 . I POP S FAIL=1 QUIT                                                     ; Open failed
 . U IO                                                                    ; Use device
 . D ZWRITE($NA(@KIDGLO@("FIA",FILE)))                                     ; DIFROM FIA Array (data on what to send)
 . I $D(@KIDGLO@("^DIC",FILE)) D ZWRITE($NA(^(FILE))) K @KIDGLO@("^DIC",FILE)              ; FOF Nodes.
 . D ZWRITE($NA(@KIDGLO@("^DD",FILE))) K @KIDGLO@("^DD",FILE)                              ; Data Dictionary
 . I $D(@KIDGLO@("SEC","^DIC",FILE)) D ZWRITE($NA(^(FILE))) K @KIDGLO@("SEC","^DIC",FILE)  ; ^DIC Security Nodes
 . I $D(@KIDGLO@("SEC","^DD",FILE)) D ZWRITE($NA(^(FILE))) K @KIDGLO@("SEC","^DD",FILE)    ; ^DD Security Nodes
 . I $D(@KIDGLO@("UP",FILE)) D ZWRITE($NA(^(FILE))) K @KIDGLO@("UP",FILE)              ; Subfile upward nodes to find parent files
 . I $D(@KIDGLO@("IX",FILE)) D ZWRITE($NA(^(FILE))) K @KIDGLO@("IX",FILE)              ; New Style Indexes
 . I $D(@KIDGLO@("KEY",FILE)) D                                            ; Keys?
 . . D ZWRITE($NA(@KIDGLO@("KEY",FILE))) K @KIDGLO@("KEY",FILE)            ; Keys...
 . . D ZWRITE($NA(@KIDGLO@("KEYPTR",FILE))) K @KIDGLO@("KEYPTR",FILE)      ; and pointer resolution to NS indexes
 . N SUBFILE F SUBFILE=0:0 S SUBFILE=$O(@KIDGLO@("FIA",FILE,SUBFILE)) Q:'SUBFILE  D
 . . I $D(@KIDGLO@("PGL",SUBFILE)) D ZWRITE($NA(@KIDGLO@("PGL",SUBFILE))) K @KIDGLO@("PGL",SUBFILE) ; Source system pointer resolution (not used at dest.)
 . D CLOSE^%ZISH("DD")                                                     ; Close. Resets IO.
 . D EN^DDIOL("Exported "_HFSNAME)
 ;
 ;
 D DATA(.FAIL,KIDGLO,PATH)                                                 ; Now Data...
 K @KIDGLO@("FIA")                                                         ; Kill this off now.
 QUIT
 ;
DATA(FAIL,KIDGLO,ROOT) ; Print DATA, FRV1, FRVL, FRV1K subscripts
 ; .FAIL - Output. Did we fail? Mostly b/c of filesystem issues.
 ; KIDGLO - The KIDS global (not a sub). Use $NA to pass this.
 ; ROOT - File system root where we are gonna export.
 Q:'$D(@KIDGLO@("DATA"))
 ;
 N POP
 N FILE F FILE=0:0 S FILE=$O(@KIDGLO@("FIA",FILE)) Q:'FILE  D  Q:$G(POP)   ; For each top file in "FIA"
 . Q:'$D(@KIDGLO@("DATA",FILE))                                            ; No Data. Skip.
 . N FNUM S FNUM=FILE                                                      ; File Number
 . N FNAM S FNAM=@KIDGLO@("FIA",FILE)                                      ; File Name (Value of the first FIA node)
 . S FNAM=$TR(FNAM,"\/!@#$%^&*()","------------")                          ; Replace punc with dashes
 . N HFSNAME S HFSNAME=FNUM_"+"_FNAM_".Data.zwr"                           ; File Name
 . D OPEN^%ZISH("DATA",ROOT,HFSNAME,"W")                                   ; Open
 . I POP S FAIL=1 QUIT                                                     ; Open failed
 . U IO                                                                    ; Use device
 . D ZWRITE($NA(@KIDGLO@("DATA",FILE))) K @KIDGLO@("DATA",FILE)            ; Export Data
 . I $D(@KIDGLO@("FRV1",FILE)) D                                           ; Pointer Resolution?
 . . D ZWRITE($NA(@KIDGLO@("FRV1",FILE))) K @KIDGLO@("FRV1",FILE)          ; Operator node. See DIFROMSR.
 . . D ZWRITE($NA(@KIDGLO@("FRVL",FILE))) K @KIDGLO@("FRVL",FILE)          ; Don't know what that is. See DIFROMSR.
 . . D ZWRITE($NA(@KIDGLO@("FRV1K",FILE))) K @KIDGLO@("FRV1K",FILE)        ; ditto
 . D CLOSE^%ZISH("DATA")                                                   ; Close. Resets IO.
 . D EN^DDIOL("Exported "_HFSNAME)
 K @KIDGLO@("DATA")
 QUIT
ZWRITE(NAME,QS,QSREP) ; Replacement for ZWRITE ; Public Proc
ZWRITE0 ; Goto Entry point for A1AEK2VC (only permitted user)
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
 N ORIGNAME S ORIGNAME=NAME          ;
 N ORIGQL S ORIGQL=$QL(NAME)         ; Number of subscripts in the original name
 I $D(@NAME)#2 W $S(QS:$$SUBNAME(NAME,QS,QSREP),1:NAME),"=",$$FORMAT(@NAME),!        ; Write base if it exists
 ; $QUERY through the name.
 ; Stop when we are out.
 ; Stop when the last subscript of the original name isn't the same as
 ; the last subscript of the Name.
 F  S NAME=$Q(@NAME) Q:NAME=""  Q:$NA(@ORIGNAME,ORIGQL)'=$NA(@NAME,ORIGQL)  D
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
FORMAT(V) ; Add quotes, replace control characters if necessary; Public $$
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
CCC(S) ;test if S Contains a Control Character or $C(255); Public $$
 Q:S?.E1C.E 1
 Q:$F(S,$C(255)) 1
 Q 0
 ;
RCC(NA) ;Replace control chars in NA with $C( ). Returns encoded string; Public $$
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
TEST D EN^%ut($T(+0),1,1) QUIT
T1 ; @TEST subscript substitutions
 D CHKEQ^%ut($$SUBNAME($NA(^DIPT(2332,0)),1,"IEN"),"^DIPT(IEN,0)")
 D CHKEQ^%ut($$SUBNAME($NA(^DIPT("A",123,0)),2,"IEN"),"^DIPT(""A"",IEN,0)")
 QUIT
 ;
RED(X) ; Convenience method for Sam to see things on the screen.
 Q $C(27)_"[41;1m"_X_$C(27)_"[0m"
 ;
