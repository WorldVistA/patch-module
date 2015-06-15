A1AEK2VC ;ven/smh-kids to version control ;2014-03-24T15:17
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4, released
 ;
 ;
IX(X,DA) ; Private Entry Point for file 11005 index
 ; Set off from Field Status (#8)
 ; i2 -> In review
 N CURIMP S CURIMP=$P(^A1AE(11005,DA,0),U,21) ; Currently importing
 I CURIMP,X'="i2" QUIT                        ; If we are currently importing, don't run until we are in-review.
 D EN(DA)                                     ; Otherwise, always run
 QUIT
 ;
EN(P11005IEN) ; Public Entry Point. Rest are private.
 ; Break out a KIDS build in 11005.1 into Version Controlled Components
 ; Input: 11005/11005.1 IEN
 I '$O(^A1AE(11005.1,P11005IEN,2,0)) QUIT  ; No KIDS build.
 ;
 ; DEBUG
 N DIQUIET  ; Trick Fileman into talking again... When we are trigerred by the DBS, we are silent by default
 ; DEBUG
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
 N % S %=$$MKDIR^A1AEOS(ROOT)
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
 D FIA^A1AEK2V0(.A1AEFAIL,SN,ROOT)                  ; All file components (DD + data)... Killing done internally.
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
 D RTN^A1AEK2V0(.A1AEFAIL,$NA(@SN@("RTN")),ROOT)
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
 ;
 ;
 ;
KRN(FAIL,KIDGLO,ROOT) ; Print OPT and KRN sections
 ; .FAIL - Output. Did we fail? Mostly b/c of filesystem issues.
 ; KIDGLO - The KIDS global (not a sub). Use $NA to pass this.
 ; ROOT - File system root where we are gonna export.
 N POP
 N ORD S ORD="" F  S ORD=$O(@KIDGLO@("ORD",ORD)) Q:ORD=""  D  Q:$G(POP)    ; For each item in ORD
 . N FNUM S FNUM=$O(@KIDGLO@("ORD",ORD,0))                                 ; File Number
 . N FNAM S FNAM=^(FNUM,0) ; **NAKED to above line**                       ; File Name
 . N PATH S PATH=ROOT_FNAM_"/"                                             ; Path to export to
 . S POP=$$MKDIR^A1AEOS(PATH)                                                     ; Mk dir for the specific component
 . I POP D EN^DDIOL($$RED("Couldn't create directory")) S FAIL=1 QUIT             ;
 . D OPEN^%ZISH("ORD",PATH,"ORD.zwr","W")                                  ; Order Nodes
 . I POP S FAIL=1 QUIT                                                     ; Open failed
 . U IO                                                                    ;
 . D ZWRITE($NA(@KIDGLO@("ORD",ORD,FNUM)))                                 ; Zwrite the ORD node
 . D CLOSE^%ZISH("ORD")                                                    ; Done with ORD
 . D EN^DDIOL("Wrote ORD.zwr for "_FNAM)                                   ; Say so                            
 . K @KIDGLO@("ORD",ORD,FNUM)                                              ; KILL this entry
 . ;
 . N IENQL S IENQL=$QL($NA(@KIDGLO@("KRN",FNUM,0)))                        ; Where is the IEN sub?
 . N CNT S CNT=0                                                           ; Sub counter for export
 . N IEN F IEN=0:0 S IEN=$O(@KIDGLO@("KRN",FNUM,IEN)) Q:'IEN  D  Q:$G(POP)  ; For each Kernel component IEN
 . . N ENTRYNAME S ENTRYNAME=$P(@KIDGLO@("KRN",FNUM,IEN,0),U)              ; .01 for the component
 . . S ENTRYNAME=$TR(ENTRYNAME,"\/!@#$%^&*()","------------")              ; Replace punc with dashes
 . . D OPEN^%ZISH("ENT",PATH,ENTRYNAME_".zwr","W")                         ; Open file
 . . I POP S FAIL=1 QUIT
 . . U IO
 . . D ZWRITE($NA(@KIDGLO@("KRN",FNUM,IEN)),IENQL,"IEN+"_CNT) ; Zwrite, replacing the IEN with IEN+CNT
 . . I FNUM=.403 D FORM(KIDGLO,IEN,IENQL)                     ; Special processing for Forms
 . . I FNUM=8989.51 D PARM(KIDGLO,IEN,IENQL)                  ; Special processing for Parameters
 . . I FNUM=8989.52 D PARM2(KIDGLO,IEN,IENQL)                 ; Special processing for Parameter templates
 . . S CNT=CNT+1                                              ; ++
 . . D CLOSE^%ZISH("ENT")                                     ; Done with this entry
 . . D EN^DDIOL("Exported "_ENTRYNAME_".zwr"_" in "_FNAM)     ; Export
 . . K @KIDGLO@("KRN",FNUM,IEN)                               ; KILL this entry
 QUIT
 ;
FORM(KIDGLO,IEN,IENQL) ; Export Blocks
 N CNT S CNT=0
 N I F I=0:0 S I=$O(@KIDGLO@("KRN",.403,IEN,40,I)) Q:'I  D                 ; Loop thourgh pages
 . N J F J=0:0 S J=$O(@KIDGLO@("KRN",.403,IEN,40,I,40,J)) Q:'J  D          ; Loop through blocks
 . . N Z S Z=^(J,0)                                                        ; zero node of block
 . . N BLNM1 S BLNM1=$P(Z,U)                                               ; its name
 . . N BLOCKIEN S BLOCKIEN=$$FNDBLK(KIDGLO,BLNM1)                          ; Block IEN
 . . I BLOCKIEN D                                                           ; if found, print it out and then
 . . . D ZWRITE($NA(@KIDGLO@("KRN",.404,BLOCKIEN)),IENQL,"IEN+"_CNT)
 . . . S CNT=CNT+1
 . . . K @KIDGLO@("KRN",.404,BLOCKIEN)                                     ; delete block
 . ;
 . ;
 . ; Export Header block if there is one...
 . N P0 S P0=@KIDGLO@("KRN",.403,IEN,40,I,0)                               ; Page zero node
 . N HB S HB=$P(P0,U,2)                                                    ; Header block
 . I $L(HB) D                                                              ; If we have it
 . . N BLOCKIEN S BLOCKIEN=$$FNDBLK(KIDGLO,HB)                             ; Find its IEN in the Transport Global
 . . I BLOCKIEN D                                                          ; Print it out if we found it.
 . . . D ZWRITE($NA(@KIDGLO@("KRN",.404,BLOCKIEN)),IENQL,"IEN+"_CNT)       ;
 . . . S CNT=CNT+1
 . . . K @KIDGLO@("KRN",.404,BLOCKIEN)                                     ; delete block
 QUIT
 ;
FNDBLK(KIDGLO,BLNM) ; $$; Find a block in the transport global; Return block IEN
 N SBN S SBN=""                                                   ; Searched block name
 N K F K=0:0 S K=$O(@KIDGLO@("KRN",.404,K)) Q:'K  D  Q:(SBN=BLNM)  ; Now loop through transported blocks
 . N Z S Z=^(K,0),SBN=$P(Z,U)                                     ; ...
 . Q:(SBN=BLNM)                                                   ; until we find the block with our name
 QUIT K
 ;
PARM(KIDGLO,IEN,IENQL) ; Export Parameter Definitions and Package level parameters exported by KIDS
 N PARMNM S PARMNM=$P(@KIDGLO@("KRN",8989.51,IEN,0),U)      ; Get the param name
 N PKGPARM D FNDPRM(.PKGPARM,KIDGLO,PARMNM)                 ; Find matching 8989.5 parameters
 N CNT S CNT=0
 N J F J=0:0 S J=$O(PKGPARM(J)) Q:'J  D                     ; for each one found
 . D ZWRITE($NA(@KIDGLO@("KRN",8989.5,J)),IENQL,"IEN+"_CNT) ; print it out
 . S CNT=CNT+1
 . K @KIDGLO@("KRN",8989.5,J)                               ; and then remove it.
 QUIT
 ;
FNDPRM(RTN,KIDGLO,PARMNM) ; Find exported parameters in 8989.5 in the transport global matching PARMNM
 ; Turns out there is more than 1... so we have to catch them all...
 N I F I=0:0 S I=$O(@KIDGLO@("KRN",8989.5,I)) Q:'I  D
 . N Z S Z=^(I,0) ; **NAKED TO ABOVE**
 . N THISNAME S THISNAME=$P(Z,U,2)
 . I THISNAME=PARMNM S RTN(I)=""
 QUIT
 ;
PARM2(KIDGLO,IEN,IENQL) ; Export Parameters in 8989.51 if sent as part of Parameter templates.
 N CNT S CNT=0
 N I F I=0:0 S I=$O(@KIDGLO@("KRN",8989.52,IEN,10,I)) Q:'I  D  ; for each parameter in the set
 . N PARMNM S PARMNM=$P(^(I,0),U,2)                            ; Get Parameter name
 . N P8989P51 S P8989P51=$$FNDPRM2(KIDGLO,PARMNM)              ; See if it is in 8989.51
 . I P8989P51 D                                                ; if so, print and delete from our global
 . . D ZWRITE($NA(@KIDGLO@("KRN",8989.51,P8989P51)),IENQL,"IEN+"_CNT)
 . . K @KIDGLO@("KRN",8989.51,P8989P51)
 . . S CNT=CNT+1
 QUIT
 ;
FNDPRM2(KIDGLO,PARMNM) ; $$ ; Find IEN of parameter in 8989.51 matching PARMNM
 N OUT S OUT=0
 N I F I=0:0 S I=$O(@KIDGLO@("KRN",8989.51,I)) Q:'I  D  Q:OUT
 . N NM S NM=$P(^(I,0),U)
 . I NM=PARMNM S OUT=I
 QUIT OUT
 ;
ZWRITE(NAME,QS,QSREP) ; Replacement for ZWRITE ; Public Proc
 GOTO ZWRITE0^A1AEK2V0 ; Moved to extension routine for size
 ;
RED(X) ; Convenience method for Sam to see things on the screen.
 Q $C(27)_"[41;1m"_X_$C(27)_"[0m"
 ;
TEST D EN^%ut($T(+0),1,1) QUIT
 ;
T3 ; @TEST Export components for one KIDS build
 N I F I=0:0 S I=$O(^A1AE(11005,I)) Q:'I  D EN(I)
 QUIT
 ;
ASSERT(X,Y) ; Internal assertion function
 N MUNIT S MUNIT=$$INMUNIT()
 I MUNIT D CHKTF^%ut(X,$G(Y))
 E  I 'X S $EC=",U-ASSERTION-FAILED,"
 QUIT
 ;
INMUNIT() ; Am I being invoked from M-Unit?
 N MUNIT S MUNIT=0
 N I F I=1:1:$ST I $ST(I,"PLACE")["%ut" S MUNIT=1
 Q MUNIT
