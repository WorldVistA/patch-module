A1AEK2M ; VEN/SMH - Load an HFS KIDS file into the Patch Module;2014-02-27  6:52 PM
 ;;2.4;PATCH MODULE;
 ;
 ; Based on code written by Dr. Cameron Schlehuber.
 ;
 ; Notes on the KIDS format and conversion procedure.
 ;
 ; Conversion procedure from a VA PM HFS-extracted KIDS (complete):
 ;^TMP(28177,1,0)="Released TIU*1*241 SEQ #237" <-- $TXT prepended
 ;^TMP(28177,2,0)="Extracted from mail message" <-- this becomes the txt
 ;^TMP(28177,3,0)="**KIDS**:TIU*1.0*241^"       <-- $END TXT replaced
 ;^TMP(28177,4,0)="" --> becomes $KID append whatever is in 6
 ;^TMP(28177,5,0)="**INSTALL NAME**"
 ;^TMP(28177,6,0)="TIU*1.0*241"
 ;---
 ;^TMP(28177,1189,0)="**END**" --> becomes $END KID whatever is in 6
 ;^TMP(28177,1190,0)="**END**" --> DELETED
 ;
 ; A few random notes on various KIDS issues
 ; If the original is a mail message, it will looks like this
 ; 
 ; >> Released GMRA*4*44 SEQ #41
 ; >> Extracted from mail message
 ; >> **KIDS**:GMRA*4.0*44^
 ; >> 
 ; >> **INSTALL NAME** etc..
 ; >> kids contents
 ; >> **END**
 ; >> **END**
 ;
 ; If the original isn't a PM HFS-extracted KIDS build, but a Straight from 
 ; KIDS KIDS-build, then the KIDS first line looks like this:
 ;
 ; >> KIDS Distribution saved on Apr 30, 2013@05:31:47
 ; >> OR*371
 ; >> **KIDS**:OR*3.0*371^
 ; >> <blank line>
 ; >> **INSTALL NAME**
 ;
 ; Multibuilds look like this:
 ; 
 ; >> KIDS Distribution saved on Sep 23, 2011@17:42:57
 ; >> IB/PRCA Remedy Ticket Fixes
 ; >> **KIDS**:IB*2.0*459^PRCA*4.5*280^
 ; >> <blank line>
 ; >> **INSTALL NAME**
 ; >> text of first KIDS build
 ; >> **INSTALL NAME**
 ; >> text of second KIDS build
 ; >> **END**
 ; >> **END**
 ;
 ; A KIDS sent from another system via KIDS/MM has the following contents.
 ;$TXT Created by TESTMASTER,USER at VEN.SMH101.COM  (KIDS) on Thursday, 01/07/14 at 15:55
 ; <contents>
 ;$END TXT
 ;$KID ZZZ*1.0*1
 ;**INSTALL NAME**
 ; <contents>
 ;$END KID ZZZ*1.0*1
 ;
 ; TODO: File package entry into our system if it can't be found
 ;       - Hint: Finds KIDS EP that does the PKG subs
 ;
DBAKID2M ; Restore patches from HFS files to MailMan
 ; Get path to HFS patches
 ; Order through all messages
 N OLDDUZ S OLDDUZ=DUZ ; Keep for ^DISV
 ; N DUZ S DUZ=.5,DUZ(0)="" ; Save DUZ from previous caller.
 N DIR,X,Y,DIROUT,DIRUT,DTOUT,DUOUT,DIROUT ; fur DIR
 S DIR(0)="F^2:255",DIR("A")="Full path of patches to load, up to but not including patch names"
 S DIR("B")=$G(^DISV(OLDDUZ,"A1AEK2M-SB"))
 D ^DIR
 QUIT:Y="^"
 N ROOT S ROOT("SB")=Y  ; where we load files from... Single Build Root
 S ^DISV(OLDDUZ,"A1AEK2M-SB")=Y
 ;
 S DIR(0)="F^2:60",DIR("A")="Full path of Multibuilds directory, in case I can't find a patch"
 S DIR("B")=$G(^DISV(OLDDUZ,"A1AEK2M-MB"))
 D ^DIR
 QUIT:Y="^"
 S ROOT("MB")=Y ; Multi Build Root
 S ^DISV(OLDDUZ,"A1AEK2M-MB")=Y
 ;
SILENT ; Don't talk. Pass ROOT in Symbol Table.
 ; Fall through from above, but can be silently called if you pass ROOT in ST.
 ; All output is sent via EN^DDIOL. Set DIQUIET to redirect to a global.
 N FILES ; retrun array
 ;
 ; Load text files first
 N ARRAY
 S ARRAY("*.TXT")=""
 S ARRAY("*.txt")=""
 N Y S Y=$$LIST^%ZISH(ROOT("SB"),"ARRAY","FILES") I 'Y W !,"Error getting directory list" QUIT
 ;
 ; Loop through each text patches.
 N ERROR
 N PATCH S PATCH=""
 N CANTLOAD ; Patches for whom we cannot find a KIDS file
 F  S PATCH=$O(FILES(PATCH)) Q:PATCH=""  D LOAD(.ROOT,PATCH,.ERROR,.CANTLOAD) Q:$D(ERROR)
 ;
 ; Print out the patches we couldn't find.
 I $D(CANTLOAD) D
 . N I S I=""
 . F  S I=$O(CANTLOAD(I)) Q:I=""  D EN^DDIOL("Patch "_I_" from "_CANTLOAD(I)_" doesn't have a KIDS file")
 . D EN^DDIOL("Please load these KIDS files manually into the patch module.")
 QUIT
 ;
LOAD(ROOT,PATCH,ERROR,CANTLOAD) ; Load TXT message, find KIDS, then load KIDS and mail.
 ; ROOT = File system directory (Ref)
 ; PATCH = File system .TXT patch name (including the .TXT) (Value)
 ; ERROR = Ref variable to indicate error.
 ; CANTLOAD = Ref variable containing the KIDS patches we can't load b/c we can't find them.
 ;
 ; NB: I start from 2 just in case there is something I need to put in 1 (like $TXT)
 K ^TMP($J,"TXT")
 D EN^DDIOL("Loading description "_PATCH)
 N Y S Y=$$FTG^%ZISH(ROOT("SB"),PATCH,$NA(^TMP($J,"TXT",2,0)),3) I 'Y W !,"Error copying TXT to global" S ERROR=1 Q
 D CLEANHF($NA(^TMP($J,"TXT"))) ; add $TXT/$END TXT if necessary
 ;
 ; Analyze message and extract data from it.
 N RTN ; RPC style return
 ;
 ;
 ; N OET S OET=$ET
 N $ET,$ES S $ET="D ANATRAP^A1AEK2M(PATCH)" ; try/catch
 D ANALYZE^A1AEK2M2(.RTN,$NA(^TMP($J,"TXT")))
 ; S $ET=OET
 ; K OET
 ;
 K ^TMP($J,"MSG") ; Message array eventually to be mailed.
 ;
 ; Move the description into the msg array, making sure we have room for the $TXT.
 N I F I=0:0 S I=$O(RTN("DESC",I)) Q:'I  S ^TMP($J,"MSG",I+1,0)=RTN("DESC",I)
 S ^TMP($J,"MSG",1,0)=RTN("$TXT") ; $TXT
 N LS S LS=$O(^TMP($J,"MSG"," "),-1)
 S ^TMP($J,"MSG",LS+1,0)="$END TXT" ; $END TXT
 K I,LS
 ;
 N LASTSUB S LASTSUB=$O(^TMP($J,"TXT"," "),-1)
 ;
 ; Info only patch?
 N INFOONLY S INFOONLY=0 ; Info Only patch?
 N I F I=0:0 S I=$O(RTN("CAT",I)) Q:'I  I RTN("CAT",I)="Informational" S INFOONLY=1
 K I
 ;
 I INFOONLY D EN^DDIOL(PATCH_" is an Info Only patch.")
 ;
 ; Load KIDS message starting into the last subscript + 1 from the text node
 ; Only if not informational!!!
 K ^TMP($J,"KID")
 I 'INFOONLY D
 . N KIDFIL S KIDFIL=$$KIDFIL(.ROOT,PATCH,.RTN,$NA(^TMP($J,"KID"))) ; Load the KIDS file
 . I KIDFIL="" S CANTLOAD(RTN("DESIGNATION"))=PATCH ; if we can't find it, put it in this array.
 ;
 ; If we loaded the KIDS build, move it over.
 I $D(^TMP($J,"KID")) D
 . N I F I=1:1 Q:'$D(^TMP($J,"KID",I))  S ^TMP($J,"MSG",LASTSUB+I,0)=^TMP($J,"KID",I)
 ; 
 ; Mail Subject
 N XMSUBJ S XMSUBJ=RTN("DESIGNATION")_" SEQ# "_RTN("SEQ")
 ;
 N PATSUBJ S PATSUBJ=RTN("SUBJECT") ; Not used right now. Will be used when we file directly into patch file.
 ;
 ; debug
 S $ET="B"
 ; debug
 ;
 ; ZEXCEPT: A1AEPKIF is created by PKGADD in the ST.
 D PKGADD(RTN("DESIGNATION"))            ; Add to Patch Module Package file
 D PKGSETUP(A1AEPKIF,.RTN)               ; And set it up.
 D VERSETUP(A1AEPKIF,RTN("DESIGNATION")) ; Add its version; ZEXCEPT: A1AEVR - Version leaks
 N DA S DA=$$ADDPATCH(A1AEPKIF,A1AEVR,.RTN,$NA(^TMP($J,"KID"))) ; ZEXCEPT: A1AENB,A1AEPD
 D ASSERT(DA)                            ; Assert that we obtained an IEN
 D ASSERT($P($$K2PMD(RTN("DESIGNATION")),"*",3)=A1AENB) ; Assert that the Number is the same as the patch number
 D ASSERT($$K2PMD(RTN("DESIGNATION"))=A1AEPD) ; Assert that the designation is the same as the Patch Designation
 ;
 ; Deliver the message
 N XMERR,XMZ
 D SENDMSG^XMXAPI(.5,XMSUBJ,$NA(^TMP($J,"MSG")),"XXX@Q-PATCH.OSEHRA.ORG",,.XMZ) ; after
 I $D(XMERR) W !,"MailMan error, see ^TMP(""XMERR"",$J)" S ERROR=1 Q
 ; Set MESSAGE TYPE to KIDS build
 S $P(^XMB(3.9,XMZ,0),"^",7)="K"
 ;
 ; Kill temp globals
 K ^TMP($J,"KID"),^("TXT"),^("MSG")
 ;
 QUIT
 ;
KIDFIL(ROOT,PATCH,TXTINFO,KIDGLO) ; $$; Private; Find the KIDS file that corresponds to a patch designation
 ; ROOT: Ref, File system roots (MP = Multibuild folder)
 ; PATCH: Val, Text file name
 ; TXTINFO: Ref, the analyzed Text array
 ; KIDGLO: Name, the Global into which to load the KIDS contents in PM format.
 ;
 ; This code is pretty iterative. It keeps trying different things until it finds the patch.
 ;
 N NOEXT S NOEXT=$P(PATCH,".",1,$L(PATCH,".")-1) ; no extension name
 N KIDFIL0 ; Trial iteration variable
 N DONE ; Loop exit
 ;
 ; Try by file name!
 N % F %="KID","kid","KIDS","kids","KIDs","kidS" D  Q:$G(DONE)
 . S KIDFIL0=NOEXT_"."_%
 . N POP
 . D OPEN^%ZISH("KID0",ROOT("SB"),KIDFIL0,"R")
 . I POP S KIDFIL0="" QUIT
 . D CLOSE^%ZISH("KID0")
 . ;
 . ; Okay. At this point we confirmed that the file exists. Is it right though?
 . K ^TMP($J,"TKID"),^("ANKID") ; Temp KID; Analysis KID
 . N % S %=$$FTG^%ZISH(ROOT("SB"),KIDFIL0,$NA(^TMP($J,"TKID",1,0)),3)   ; To Global
 . I '% S $EC=",U-FILE-DISAPPEARED,"
 . D ANALYZE^A1AEK2M1($NA(^TMP($J,"ANKID")),$NA(^TMP($J,"TKID"))) ; Analyze the file
 . ;
 . ; Now, make sure that the TXT file's designation is the same as the KIDS' patch no.
 . ; Loop through every patch in the file and make sure at least one matches.
 . N P S P=""
 . F  S P=$O(^TMP($J,"ANKID",P)) Q:P=""  I $$K2PMD(P)=TXTINFO("DESIGNATION") S DONE=1 QUIT
 . I $G(DONE) DO  QUIT
 . . M @KIDGLO=^TMP($J,"ANKID",P)
 . . D EN^DDIOL("Found patch "_TXTINFO("DESIGNATION")_" in "_KIDFIL0)
 ;
 ; If we don't have it, get all KIDS files and grab any one that has the
 ; patch number in its name.
 I $G(KIDFIL0)="" D  ; Still we don't have it.
 . N A S A("*.kid")="",A("*.KID")=""  ; Search for these files
 . S A("*.kid?")="",A("*.KID?")=""    ; and these too; but not the .json ones.
 . N FILES  ; rtn array by name
 . N % S %=$$LIST^%ZISH(ROOT("SB"),$NA(A),$NA(FILES)) ; ls
 . ; I '% S $EC=",U-DIRECTORY-DISAPPEARED," ; should never happen; WRONG: It's a possibility.
 . I '% QUIT  ; Try the multibuild directory next
 . K %,A ; bye
 . ;
 . N F S F="" ; file looper
 . N DONE ; control flag
 . ; here's the core search for the file name containing a patch number
 . F  S F=$O(FILES(F)) Q:F=""  I F[$P(TXTINFO("DESIGNATION"),"*",3) D  Q:$G(DONE)
 . . K ^TMP($J,"TKID"),^("ANKID") ; Temp KID; Analysis KID
 . . N % S %=$$FTG^%ZISH(ROOT("SB"),F,$NA(^TMP($J,"TKID",1,0)),3)   ; To Global
 . . I '% S $EC=",U-FILE-DISAPPEARED,"
 . . D ANALYZE^A1AEK2M1($NA(^TMP($J,"ANKID")),$NA(^TMP($J,"TKID"))) ; Analyze the file
 . . ;
 . . ; Now, make sure that the TXT file's designation is the same as the KIDS' patch no.
 . . ; Loop through every patch in the file and make sure at least one matches.
 . . N P S P=""
 . . F  S P=$O(^TMP($J,"ANKID",P)) Q:P=""  I $$K2PMD(P)=TXTINFO("DESIGNATION") S DONE=1 QUIT
 . . I $G(DONE) DO  QUIT
 . . . M @KIDGLO=^TMP($J,"ANKID",P)
 . . . D EN^DDIOL("Found patch "_TXTINFO("DESIGNATION")_" in "_F)
 . . . S KIDFIL0=F
 ;
 ; Now we have the hard case. We still don't have the file. 
 ; Let's look in the Multibuilds directory
 I $G(KIDFIL0)="" D
 . ; Set-up XTMP
 . ; NB: NO LOCKS B/C IT'S OKAY FOR MULTIPLE USERS TO FILE THIS SIMULTANEOUSLY
 . ; NB (CONT): THERE ARE NO COUNTERS WHICH NEED TO BE SYNCHRONIZED.
 . N XTMPS S XTMPS=$T(+0)
 . N START S START=$$NOW^XLFDT()
 . N PURGDT S PURGDT=$$FMADD^XLFDT(START,30)
 . S ^XTMP(XTMPS,0)=PURGDT_U_START_U_"Analyzed Multibuilds Holding Area"
 . ;
 . ; Load the Multibuild file names
 . N A S A("*.kid")="",A("*.KID")=""  ; Search for these files
 . S A("*.kid?")="",A("*.KID?")=""    ; and these too; but not the .json ones.
 . N FILES  ; rtn array by name
 . N % S %=$$LIST^%ZISH(ROOT("MB"),$NA(A),$NA(FILES)) ; ls
 . I '% S $EC=",U-DIRECTORY-DISAPPEARED," ; should never happen
 . K %,A ; bye
 . ;
 . N F S F="" ; file looper
 . N DONE ; control flag
 . ; Analyze each Multibuild
 . F  S F=$O(FILES(F)) Q:F=""  D  Q:$G(DONE)
 . . D EN^DDIOL("Analyzing Multibuild file "_F) ; print out
 . . I '$D(^XTMP(XTMPS,F)) D  ; If it isn't loaded already...
 . . . K ^TMP($J,"TKID"),^("ANKID") ; Temp KID; Analysis KID
 . . . N % S %=$$FTG^%ZISH(ROOT("MB"),F,$NA(^TMP($J,"TKID",1,0)),3)   ; To Global
 . . . I '% S $EC=",U-FILE-DISAPPEARED,"
 . . . D ANALYZE^A1AEK2M1($NA(^TMP($J,"ANKID")),$NA(^TMP($J,"TKID"))) ; Analyze the file
 . . . M ^XTMP(XTMPS,F)=^TMP($J,"ANKID") ; Put into XTMP
 . . ; Now, make sure that the TXT file's designation is the same as the KIDS' patch no.
 . . ; Loop through every patch in the file and make sure at least one matches.
 . . N P S P=""
 . . F  S P=$O(^XTMP(XTMPS,F,P)) Q:P=""  I $$K2PMD(P)=TXTINFO("DESIGNATION") S DONE=1 QUIT
 . . I $G(DONE) D  QUIT
 . . . M @KIDGLO=^XTMP(XTMPS,F,P)
 . . . D EN^DDIOL("Found patch "_TXTINFO("DESIGNATION")_" in "_F)
 . . . S KIDFIL0=F
 ;
 ; If we still can't find it. Oh well! Can't do nuthin.
 K ^TMP($J,"TKID"),^("ANKID")
 QUIT $G(KIDFIL0)
 ;
SELFILQ ; Public; Interactive entry point... ; TODO
 ; This code is a NO-OP right now.
 ; I probably would use it in the future, but not now.
 ; ZEXCEPT: ROOT,PATCH
 N KIDFIL
 N ARRAY S ARRAY("*.KI*")="",ARRAY("*.ki*")=""
 N FILE
 N Y S Y=$$LIST^%ZISH(ROOT("SB"),$NA(ARRAY),$NA(FILE))
 I 'Y  ; TODO!!! -- probably ask the user to try again since directory has no KIDS files.
 S KIDFIL=$$SELFIL(.FILE,,"Select a KIDS build to match to "_PATCH)
 QUIT KIDFIL
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
 ; Bye
 K ^TMP($J,"FILES")
 ;
 I $L(Y,U)=2 Q $P(Y,U,2)
 E  QUIT ""
 ;
CLEANHF(MSGGLO) ; Private... Clean header and footer in message global
 ; WARNING - Naked all over inside the do block.
 N S S S=$O(@MSGGLO@("")) ; first numeric sub.
 I @MSGGLO@(S,0)'["$TXT Created by " D
 . ; First line is invalid. Try various patterns.
 . N I F I=1:1 N PATT S PATT=$T(CLNPATT+I),PATT=$P(PATT,";;",2) Q:($$TRIM^XLFSTR(PATT)=">>END<<")  D
 . . I $$TRIM^XLFSTR(^(0))=$$TRIM^XLFSTR(PATT) S ^(0)="$TXT Created by UNKNOWN,UNKNOWN at DOWNLOADS.VA.GOV  (KIDS)"
 . ; If still not there, put in first node before the message.
 . I ^(0)'["$TXT Created by " S @MSGGLO@(S-1,0)="$TXT Created by UNKNOWN,UNKNOWN at DOWNLOADS.VA.GOV  (KIDS)"
 ;
 N LASTSUB S LASTSUB=$O(@MSGGLO@(" "),-1)
 I @MSGGLO@(LASTSUB,0)'["$END TXT" S @MSGGLO@(LASTSUB+1,0)="$END TXT"
 QUIT
 ;
CLNPATT ;; Headers to substitute if present using a contains operator. 1st one is just a blank -- INTENTIONAL
 ;;
 ;;*********************
 ;;Original message:
 ;;This informational patch
 ;;>>END<<
 ;
ANATRAP(PATCH) ; Analysis Trap -- use this to capture errors from ANALYZE^A1AEK2M2.
 ; YOU MUST NEW $ET AND $ES AND SET $ET="DO ANATRAP^A1AEK2M2(PATCH)"
 I $EC[",U-NOT-MESSAGE," DO EN^DDIOL(PATCH_" IS NOT A PATCH MESSAGE") S $ET="G UNWIND^ZU",$EC=",UQUIT," QUIT
 QUIT
 ;
K2PMD(PATCH) ; Private to package; $$; Kids to Patch Module designation. Code by Wally from A1AEHSVR.
 N %
 I PATCH[" " S %=$L(PATCH," "),PATCH=$P(PATCH," ",1,%-1)_"*"_$P(PATCH," ",%)_"*0"
 I $L(PATCH,"*")=3 S $P(PATCH,"*",2)=+$P(PATCH,"*",2)
 Q PATCH
 ;
PKGADD(DESIGNATION) ; Proc; Private to this routine; Add package to Patch Module
 ; Input: Designation: Patch designation AAA*1*22; By value
 ; ZEXCEPT: A1AEPK,A1AEPKIF,A1AEPKNM - Created by PKG^A1AEUTL
 ;
 S DESIGNATION=$$K2PMD(DESIGNATION) ; Convert space format (XOBW 1.0) to PM format (XOBW*1*0)
 ;
 ; When doing lookups for laygo, only look in the Package file's C index for designation.
 N DIC S DIC("PTRIX",11007,.01,9.4)="C"
 N A1AE S A1AE(0)="XLM" ; eXact match, Laygo, Multiple Indexes
 N X S X=$P(DESIGNATION,"*") ; Input to ^DIC
 D PKG^A1AEUTL
 ; ZEXCEPT: Y leaks from PKG^A1AEUTL
 I $P($G(Y),U,3) D EN^DDIOL("Added Package "_DESIGNATION_" to "_$P(^A1AE(11007,0),U))
 ;
 ; Check that the output variables from PKG^A1AEUTL are defined.
 D ASSERT(A1AEPKIF) ; Must be positive
 D ASSERT(A1AEPK=$P(DESIGNATION,"*")) ; PK must be the AAA
 D ASSERT($L(A1AEPKNM)) ; Must be defined.
 QUIT
 ;
PKGSETUP(A1AEPKIF,TXTINFO) ; Private; Setup package in Patch module
 ; ZEXCEPT: A1AEPKIF - Created by PKGADD
 N IENS S IENS=A1AEPKIF_","
 N A1AEFDA,DIERR
 S A1AEFDA(11007,IENS,2)="NO" ; USER SELECTION PERMITTED//^S X="NO"
 S A1AEFDA(11007,IENS,4)="NO" ; FOR TEST SITE ONLY?//^S X="NO"
 S A1AEFDA(11007,IENS,5)="YES" ; ASK PATCH DESCRIPTION COPY
 D FILE^DIE("EKT",$NA(A1AEFDA)) ; External, lock, transact
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 N A1AEFDA
 S A1AEFDA(11007.02,"?+1,"_IENS,.01)="`"_$$MKUSR(TXTINFO("VER"),"A1AE PHVER")  ; SUPPORT PERSONNEL
 S A1AEFDA(11007.02,"?+1,"_IENS,2)="V"  ; VERIFY PERSONNEL
 S A1AEFDA(11007.03,"?+2,"_IENS,.01)="`"_$$MKUSR(TXTINFO("DEV"),"A1AE DEVELOPER") ; DEVELOPMENT PERSONNEL
 S A1AEFDA(11007.03,"?+3,"_IENS,.01)="`"_$$MKUSR(TXTINFO("COM"),"A1AE DEVELOPER") ; DITTO
 D UPDATE^DIE("E",$NA(A1AEFDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 D ASSERT($D(^A1AE(11007,A1AEPKIF,"PB")))  ; Verifier Nodes
 D ASSERT($D(^A1AE(11007,A1AEPKIF,"PH")))  ; Developer Nodes
 QUIT
 ;
MKUSR(NAME,KEY) ; Private; Make Users for the Package
 Q:$O(^VA(200,"B",NAME,0)) $O(^(0)) ; Quit if the entry exists with entry
 ;
 ; Get initials
 D STDNAME^XLFNAME(.NAME,"CP")
 N INI S INI=$E(NAME("GIVEN"))_$E(NAME("MIDDLE"))_$E(NAME("FAMILY"))
 ;
 ; File user with key
 N A1AEFDA,A1AEIEN,A1AEERR,DIERR
 S A1AEFDA(200,"?+1,",.01)=NAME ; Name
 S A1AEFDA(200,"?+1,",1)=INI ; Initials
 S A1AEFDA(200,"?+1,",28)="NONE" ; Mail Code
 S:$L($G(KEY)) A1AEFDA(200.051,"?+3,?+1,",.01)="`"_$O(^DIC(19.1,"B",KEY,""))
 ;
 N DIC S DIC(0)="" ; An XREF in File 200 requires this.
 D UPDATE^DIE("E",$NA(A1AEFDA),$NA(A1AEIEN),$NA(A1AEERR)) ; Typical UPDATE
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 Q A1AEIEN(1) ;Provider IEN
 ;
VERSETUP(A1AEPKIF,DESIGNATION) ; Private; Setup version in 11007
 ; Input: - A1AEPKIF - Package IEN in 11007, value
 ;        - DESIGNATION - Package designation (XXX*1*3)
 ; Output: (In symbol table:) A1AEVR
 ; ZEXCEPT: A1AEVR - Created here by VER^A1AEUTL
 S DESIGNATION=$$K2PMD(DESIGNATION) ; Convert space format (XOBW 1.0) to PM format (XOBW*1*0)
 N X,A1AE S A1AE(0)="L" ; X is version number; input to ^DIC
 S X=$P(DESIGNATION,"*",2)
 D VER^A1AEUTL ; Internal API
 D ASSERT(A1AEVR=$P(DESIGNATION,"*",2))
 QUIT
 ;
ADDPATCH(A1AEPKIF,A1AEVR,TXTINFO,KIDINFO) ; Private $$ ; Add patch to 11005
 ; Input: TBD
 ; Non-importing version is at NUM^A1AEUTL
 N DESIGNATION S DESIGNATION=$$K2PMD(TXTINFO("DESIGNATION")) ; Convert space format (XOBW 1.0) to PM format (XOBW*1*0)
 N X S X=DESIGNATION
 S A1AENB=$P(X,"*",3) ; ZEXCEPT: A1AENB leak this
 N A1AETY S A1AETY="PH"
 N DIC,Y S DIC="^A1AE(11005,",DIC(0)="L" D ^DIC
 ; ZEXCEPT: A1AEPD ; leak this
 N DA
 S DA=+Y,A1AEPD=$P(Y,"^",2),$P(^A1AE(11005,DA,0),"^",2,4)=A1AEPKIF_"^"_A1AEVR_"^"_A1AENB,^A1AE(11005,"D",A1AEPKIF,DA)=""
 ;
 ; Put stream
 N FDA S FDA(11005,DA_",",.2)=$$GETSTRM(DESIGNATION) ; PATCH STREAM
 N DIERR
 D FILE^DIE("",$NA(FDA),$NA(ERR))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 ; Change status to Under Development and add developer in
 S $P(^A1AE(11005,DA,0),U,8)="u"
 ;
 ; Get developer
 N DEV
 D  ; Protect DA from FM Monster
 . N DA
 . N NAME S NAME=TXTINFO("DEV")
 . D STDNAME^XLFNAME(.NAME) ; Remove funny stuff (like dots at the end)
 . S DEV=$$FIND1^DIC(200,"","QX",NAME,"B") ; Get developer
 ;
 D ASSERT(DEV,"Developer "_TXTINFO("DEV")_" couldn't be resolved")
 ;
 S $P(^A1AE(11005,DA,0),U,9)=DEV
 ; File Date
 N X,Y S X=TXTINFO("DEV","DATE") D ^%DT
 S $P(^A1AE(11005,DA,0),U,12)=Y
 ; Hand cross-reference
 S ^A1AE(11005,"AS",A1AEPKIF,A1AEVR,"u",A1AENB,DA)=""
 ;
 ; Add subject and priority
 N FDA,IENS
 N DIERR
 S IENS=DA_","
 S FDA(11005,IENS,"PATCH SUBJECT")=TXTINFO("SUBJECT")
 S FDA(11005,IENS,"PRIORITY")=TXTINFO("PRIORITY")
 D FILE^DIE("E",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 K FDA
 ;
 ;
 ; TODO: Add KIDS fild to 11005.1 along with routines in routine mulitple
 QUIT DA
 ;
GETSTRM(DESIGNATION) ; Private to package; $$; Get the Stream for a designation using a patch number
 ; Input: DESIGNATION XXX*1.0*5
 ; Output: Stream IEN in 11007.1
 N PN
 I $L(DESIGNATION,"*")>1 S PN=$P(DESIGNATION,"*",3)
 E  S PN=0
 I PN=0 QUIT 1  ; VA Patch Stream
 N STRM
 N I F I=0:0 S I=$O(^A1AE(11007.1,I)) Q:'I  D  Q:$G(STRM)
 . N MIN S MIN=I
 . N MAX S MAX=I+998
 . I PN'<MIN&(PN'>MAX) S STRM=I  ; Really this is IF MIN<=PN<=MAX...
 Q STRM
 ;
ASSERT(X,Y) ; Assertion engine
 ; ZEXCEPT: XTMUNIT - Newed on a lower level of the stack if using M-Unit
 I $D(XTMUNIT) D CHKTF^XTMUNIT(X,$G(Y)) QUIT  ; if we are inside M-Unit, assert using that engine.
 I 'X D EN^DDIOL($G(Y)) S $EC=",U-ASSERTION-ERROR,"  ; otherwise, throw error if assertion fails.
 QUIT
