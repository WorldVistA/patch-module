A1AEK2VC ; VEN/SMH - KIDS to Version Control;2014-03-20  8:31 PM
 ;;2.4;PATCH MODULE;;
 ;
EN(P11005IEN) ; Public Entry Point. Rest are private.
 ; Break out a KIDS build in 11005.1 into Version Controlled Components
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
 I ROOT="" QUIT                              ; No root path
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
 ; Make directory for exporting KIDS compoents
 S ROOT=ROOT_"KIDComponents/"
 N % S %=$$MKDIR(ROOT)
 I % D EN^DDIOL($$RED("Couldn't create KIDCommponents directory")) QUIT
 ; 
 ; Say that we are exporting
 N MSG S MSG(1)="Exporting Patch "_PD
 S MSG(1,"F")="!!!!!"
 S MSG(2)="Exporting at "_ROOT
 S MSG(2,"F")="!"
 D EN^DDIOL(.MSG)
 ;
 ; Stanza to process each component of loaded global
 N A1AEFAIL S A1AEFAIL=0
 N SN S SN=$NA(^XTMP("K2VC",PD)) ; Short name... I am tired of typing.
 D EXPORT(.A1AEFAIL,SN,ROOT)
 ; I $D(^XTMP("K2VC",PD,"DATA")) BREAK
 I A1AEFAIL D EN^DDIOL($$RED("A failure has occured"))
 QUIT
 ;
EXPORT(A1AEFAIL,SN,ROOT) ; Export KIDS patch to the File system
 ; .A1AEFAIL = Catch failures
 ; SN = Short name for Global
 ; ROOT = File system Root
 ;
 ; BLD - Build
 D GENOUT(.A1AEFAIL,$NA(@SN@("BLD")),ROOT,"Build.zwr",4,"IEN") ; Process BUILD Section
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export BLD")) QUIT
 K @SN@("BLD")
 D ASSERT('A1AEFAIL)
 ;
 ; FIA, ^DD, ^DIC, SEC, DATA, FR* nodes
 D FIA(.A1AEFAIL,SN,ROOT)                  ; All file components (DD + data)... Killing done internally.
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export FIA, ^DD, ^DIC, SEC, DATA, FR*")) QUIT
 D ASSERT('A1AEFAIL)
 ;
 ; PKG - Package
 D GENOUT(.A1AEFAIL,$NA(@SN@("PKG")),ROOT,"Package.zwr",4,"IEN")
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export PKG")) QUIT
 K @SN@("PKG")
 D ASSERT('A1AEFAIL)
 ;
 ; VER - Kernel and Fileman Versions
 D GENOUT(.A1AEFAIL,$NA(@SN@("VER")),ROOT,"KernelFMVersion.zwr")
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export VER")) QUIT
 K @SN@("VER")
 D ASSERT('A1AEFAIL)
 ;
 ; PRE - Env Check
 D GENOUT(.A1AEFAIL,$NA(@SN@("PRE")),ROOT,"EnvironmentCheck.zwr")
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export PRE")) QUIT
 K @SN@("PRE")
 D ASSERT('A1AEFAIL)
 ;
 ; INI - Pre-Init
 D GENOUT(.A1AEFAIL,$NA(@SN@("INI")),ROOT,"PreInit.zwr")
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export INI")) QUIT
 K @SN@("INI")
 D ASSERT('A1AEFAIL)
 ;
 ; INIT - Post-Install
 D GENOUT(.A1AEFAIL,$NA(@SN@("INIT")),ROOT,"PostInstall.zwr")
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export INIT")) QUIT
 K @SN@("INIT")
 D ASSERT('A1AEFAIL)
 ;
 ; MBREQ - Required Build
 D GENOUT(.A1AEFAIL,$NA(@SN@("MBREQ")),ROOT,"RequiredBuild.zwr")
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export MBREQ")) QUIT
 K @SN@("MBREQ")
 D ASSERT('A1AEFAIL)
 ;
 ; QUES - Install Questions
 D GENOUT(.A1AEFAIL,$NA(@SN@("QUES")),ROOT,"InstallQuestions.zwr")
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export QUES")) QUIT
 K @SN@("QUES")
 D ASSERT('A1AEFAIL)
 ;
 ; RTN - Routines
 D RTN(.A1AEFAIL,$NA(@SN@("RTN")),ROOT)
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export RTN")) QUIT
 D ASSERT('A1AEFAIL)
 ; Kill is done in RTN
 ;
 ; KRN and ORD - Kernel Components
 D KRN(.A1AEFAIL,SN,ROOT)
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export KRN")) QUIT
 D ASSERT('A1AEFAIL)
 ; Kill is done in KRN
 ;
 ; TEMP - Transport Global
 D GENOUT(.A1AEFAIL,$NA(@SN@("TEMP")),ROOT,"TransportGlobal.zwr")
 I A1AEFAIL D EN^DDIOL($$RED("Couldn't export TEMP")) QUIT
 K @SN@("TEMP")
 D ASSERT('A1AEFAIL)
 ;
 ; Make sure that the XTMP global is now empty. If there is anything there, we have a problem.
 D ASSERT('$D(@SN))
 ;
 QUIT
 ;
 ;
GENOUT(FAIL,EXGLO,ROOT,FN,QLSUB,SUBNAME) ; Generic Exporter
 ; .FAIL - Output to tell us if we failed
 ; EXGLO - Global NAME (use $NA) to export
 ; ROOT - File system root where to write the file
 ; FN - File name
 ; QLSUB - Substitute this nth subscript WITH...
 ; SUBNAME - ...subname
 ;
 I '$D(@EXGLO) QUIT  ; No data to export
 ;
 N POP
 D OPEN^%ZISH("EXPORT",ROOT,FN,"W")
 I POP S FAIL=1 QUIT
 U IO
 D ZWRITE(EXGLO,$G(QLSUB),$G(SUBNAME))
 D CLOSE^%ZISH("EXPORT")
 D EN^DDIOL("Wrote "_FN)
 QUIT
 ;
RTN(FAIL,RTNGLO,ROOT) ; Routine Exporter
 ; .FAIL - Output. Did we fail? Mostly b/c of filesystem issues.
 ; RTNGLO - The KIDS global ending at "RTN". Use $NA to pass this.
 ; ROOT - File system root where we are gonna make the Routines directory
 ;
 N RTNDIR S RTNDIR=ROOT_"Routines/"
 N % S %=$$MKDIR(RTNDIR)
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
MKDIR(DIR) ; $$; mkdir DIR name. Unix output for success and failure.
 N CMD S CMD="mkdir -p '"_DIR_"'" ; mk sure that we take in account spaces
 N OUT ; Exit value of command.
 I +$SY=47 D  ; GT.M
 . O "p":(shell="/bin/sh":command=CMD)::"pipe" U "p" C "p"
 . I $ZV["V6.1" S OUT=$ZCLOSE ; GT.M 6.1 only returns the status!!
 . E  S OUT=0
 I +$SY=0 S OUT=$ZF(-1,CMD) ; Cache
 QUIT OUT
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
 S POP=$$MKDIR(PATH)
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
 ;
 ;
KRN(FAIL,KIDGLO,ROOT) ; Print OPT and KRN sections
 ; .FAIL - Output. Did we fail? Mostly b/c of filesystem issues.
 ; KIDGLO - The KIDS global (not a sub). Use $NA to pass this.
 ; ROOT - File system root where we are gonna export.
 N POP
 N ORD F ORD=0:0 S ORD=$O(@KIDGLO@("ORD",ORD)) Q:'ORD  D  Q:$G(POP)   ; For each item in ORD
 . N FNUM S FNUM=$O(@KIDGLO@("ORD",ORD,0))                                 ; File Number
 . N FNAM S FNAM=^(FNUM,0) ; **NAKED to above line**                       ; File Name
 . N PATH S PATH=ROOT_FNAM_"/"                                             ; Path to export to
 . S POP=$$MKDIR(PATH)                                                     ; Mk dir for the specific component
 . I POP D EN^DDIOL($$RED("Couldn't create directory")) S FAIL=1 QUIT             ;
 . D OPEN^%ZISH("ORD",PATH,"ORD.zwr","W")                                  ; Order Nodes
 . I POP S FAIL=1 QUIT                                                     ; Open failed
 . U IO                                                                    ;
 . D ZWRITE($NA(@KIDGLO@("ORD",ORD,FNUM)))                                 ; Zwrite the ORD node
 . D CLOSE^%ZISH("ORD")                                                    ; Done with ORD
 . D EN^DDIOL("Wrote ORD.zwr for "_FNAM)                                   ; Say so                            
 . ;
 . N IENQL S IENQL=$QL($NA(@KIDGLO@("KRN",FNUM,0)))                        ; Where is the IEN sub?
 . N CNT S CNT=0                                                           ; Sub counter for export
 . N IEN F IEN=0:0 S IEN=$O(@KIDGLO@("KRN",FNUM,IEN)) Q:'IEN  D  Q:$G(POP)  ; For each Kernel component IEN
 . . N ENTRYNAME S ENTRYNAME=$P(@KIDGLO@("KRN",FNUM,IEN,0),U)              ; .01 for the component
 . . S ENTRYNAME=$TR(ENTRYNAME,"\/!@#$%^&*()","------------")              ; Replace punc with dashes
 . . D OPEN^%ZISH("ENT",PATH,ENTRYNAME_".zwr","W")                         ; Open file
 . . I POP S FAIL=1 QUIT
 . . U IO
 . . D ZWRITE($NA(@KIDGLO@("KRN",FNUM,IEN)),IENQL,"IEN+"_CNT)              ; Zwrite, replacing the IEN with IEN+CNT
 . . S CNT=CNT+1                                                           ; ++
 . . D CLOSE^%ZISH("ENT")                                                  ; Done with this entry
 . . D EN^DDIOL("Exported "_ENTRYNAME_".zwr"_" in "_FNAM)                  ; Export
 K @KIDGLO@("ORD"),@KIDGLO@("KRN")                                         ; Don't need these anymore.
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
 N ORIGNAME S ORIGNAME=NAME          ; Get last subscript upon which we can't loop further
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
RED(X) ; Convenience method for Sam to see things on the screen.
 Q $C(27)_"[41;1m"_X_$C(27)_"[0m"
 ;
TEST D EN^XTMUNIT($T(+0),1,1) QUIT
T1 ; @TEST subscript substitutions
 D CHKEQ^XTMUNIT($$SUBNAME($NA(^DIPT(2332,0)),1,"IEN"),"^DIPT(IEN,0)")
 D CHKEQ^XTMUNIT($$SUBNAME($NA(^DIPT("A",123,0)),2,"IEN"),"^DIPT(""A"",IEN,0)")
 QUIT
T2 ; @TEST Make a directory
 N % S %=$$MKDIR("/tmp/test/sam")
 D CHKEQ^XTMUNIT(%,0,"Status of mkdir should be zero")
 QUIT
 ;
T3 ; @TEST Export components for one KIDS build
 N I F I=0:0 S I=$O(^A1AE(11005,I)) Q:'I  D EN(I)
 QUIT
 ;
ASSERT(X,Y) ; Internal assertion function
 N MUNIT S MUNIT=$$INMUNIT()
 I MUNIT D CHKTF^XTMUNIT(X,$G(Y))
 QUIT
 ;
INMUNIT() ; Am I being invoked from M-Unit?
 N MUNIT S MUNIT=0
 N I F I=1:1:$ST I $ST(I,"PLACE")["XTMUNIT" S MUNIT=1
 Q MUNIT
