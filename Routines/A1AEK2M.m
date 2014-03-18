A1AEK2M ; VEN/SMH - Load an HFS KIDS file into the Patch Module;2014-03-17  7:22 PM
 ;;2.4;PATCH MODULE;
 ;
 ; Based on code written by Dr. Cameron Schlehuber.
 ;
 ; Notes on the KIDS format and conversion procedure.
 ; NB: Notes moved to A1AEK2M0 to make space in this routine.
 ;
 ; TODO: File package entry into our system if it can't be found
 ;       - Hint: Finds KIDS EP that does the PKG subs
 ;
SD ; Restore patches from a single directory.
 ; Get path to HFS patches
 ; Order through all messages
 ; N DUZ S DUZ=.5,DUZ(0)="" ; Save DUZ from previous caller.
 N DIR,X,Y,DIROUT,DIRUT,DTOUT,DUOUT,DIROUT ; fur DIR
 S DIR(0)="F^2:255",DIR("A")="Full path of patches to load, up to but not including patch names"
 S DIR("B")=$G(^DISV(DUZ,"A1AEK2M-SB"))
 D ^DIR
 QUIT:Y="^"
 N ROOT S ROOT("SB")=Y  ; where we load files from... Single Build Root
 S ^DISV(DUZ,"A1AEK2M-SB")=Y
 ;
 S DIR(0)="F^2:255",DIR("A")="Full path of Multibuilds directory, in case I can't find a patch"
 S DIR("B")=$G(^DISV(DUZ,"A1AEK2M-MB"))
 D ^DIR
 QUIT:Y="^"
 S ROOT("MB")=Y ; Multi Build Root
 S ^DISV(DUZ,"A1AEK2M-MB")=Y
 D SILENT(.ROOT)
 QUIT
 ;
RECURSE ; Restore patches from a directory tree
 ; TODO: Document and clean.
 N DIR,X,Y,DIROUT,DIRUT,DTOUT,DUOUT,DIROUT ; fur DIR
 S DIR(0)="F^2:255",DIR("A")="Full path of patches to load, up to but not including patch names"
 S DIR("B")=$G(^DISV(DUZ,"A1AEK2M-RP")) ; Recurse Path
 D ^DIR
 QUIT:Y="^"
 N ROOT
 S ROOT=Y
 S ^DISV(DUZ,"A1AEK2M-RP")=ROOT
 N LVL S LVL=0
 N PATCHROOTS
 S PATCHROOTS=ROOT
 N MBROOT
 S PATCHROOTS("MB")=$$RECURSE2(PATCHROOTS)
 D RECURSE1(ROOT,.PATCHROOTS)
 QUIT
 ;
RECURSE1(ROOT,PATCHROOTS) ; Recurser
 ; TODO: Document and clean.
 ; ZEXCEPT: LVL - Newed above
 ; ZEXCEPT: L - no such variable. XINDEX is tripping up.
 N % ; Throw away variable
 S LVL=$G(LVL,0)
 N ARRAY S ARRAY("*")=""
 N FILES,TXTFILES
 I $$DEFDIR^%ZISH(ROOT)="/"!('$$LIST^%ZISH(ROOT,"ARRAY","FILES")) QUIT  ; DEFDIR bug!
 S ARRAY("*.txt")="",ARRAY("*.TXT")="",%=$$LIST^%ZISH(ROOT,"ARRAY","TXTFILES")
 I $D(TXTFILES) S PATCHROOTS("SB")=ROOT D SILENT(.PATCHROOTS)
 N F S F="" F  S F=$O(FILES(F)) Q:F=""  D
 . I $E(F)="." QUIT  ; Hidden file
 . W:$D(KBANDEBUG) ?LVL*5,F,!
 . S LVL=LVL+1
 . D RECURSE1(ROOT_F_"/")
 . S LVL=LVL-1
 QUIT
 ;
RECURSE2(ROOT) ; $$;Recurser to Find the Multibuild
 ; TODO: Document and clean.
 ; ZEXCEPT: MBROOT ; Newed at the caller
 ; ZEXCEPT: LVL - Newed above
 ; ZEXCEPT: L - no such variable. XINDEX is tripping up.
 I $$UP^XLFSTR(ROOT)["MULTIBUILD" S MBROOT=ROOT
 S LVL=$G(LVL,0)
 N ARRAY S ARRAY("*")=""
 N FILES
 I $$DEFDIR^%ZISH(ROOT)="/"!('$$LIST^%ZISH(ROOT,"ARRAY","FILES")) QUIT ""  ; DEFDIR bug!
 N F S F="" F  S F=$O(FILES(F)) Q:F=""  D  Q:$D(MBROOT)
 . I $E(F)="." QUIT  ; Hidden file
 . I $$DEFDIR^%ZISH(ROOT_F_"/")="/"!('$$LIST^%ZISH(ROOT_F_"/","ARRAY","FILES")) QUIT  ; DEFDIR bug!
 . W:$D(KBANDEBUG) ?LVL*5,F,!
 . S LVL=LVL+1
 . N % S %=$$RECURSE2(ROOT_F_"/")
 . S LVL=LVL-1
 QUIT $G(MBROOT)
 ;
SILENT(ROOT) ; Don't talk.
 ; All output is sent via EN^DDIOL. Set DIQUIET to redirect to a global.
 N FILES ; retrun array
 ;
 ; Load text files first
 N ARRAY
 S ARRAY("*.TXT")=""
 S ARRAY("*.txt")=""
 N Y S Y=$$LIST^%ZISH(ROOT("SB"),"ARRAY","FILES") I 'Y D EN^DDIOL("Error getting directory list") QUIT
 ;
 ; Loop through each text patches.
 N ERROR
 N PATCH S PATCH=""
 N RESULT ; Result of Load
 F  S PATCH=$O(FILES(PATCH)) Q:PATCH=""  D LOAD(.ROOT,PATCH,.ERROR,.RESULT) Q:$D(ERROR)
 ;
 ; Print out the patches we couldn't find.
 N I S I=""
 F  S I=$O(RESULT(I)) Q:I=""  I $D(RESULT(I,"CANTLOAD")) D 
 . D EN^DDIOL("Patch "_I_" from "_RESULT(I,"TXT")_" doesn't have a KIDS file")
 . D EN^DDIOL("Please load these KIDS files manually into the patch module.")
 ;
 ; Send bulletin regarding loaded patches
 D MAIL(.RESULT)
 ;
 QUIT
 ;
MAIL(RESULT) ; Private Proc to Package; Mail the result of the load to 
 ;  -> interested parties using the bulletin A1AE LOAD RELEASED PATCH
 N WP,CNT S CNT=1
 N I S I="" F  S I=$O(RESULT(I)) Q:I=""  D
 . S WP(CNT)="Patch designated as "_I_" has been loaded into the Patch Module.",CNT=CNT+1
 . S WP(CNT)="Text file: "_RESULT(I,"TXT"),CNT=CNT+1
 . I '$D(RESULT(I,"CANTLOAD")) S WP(CNT)="KID file: "_RESULT(I,"KID"),CNT=CNT+1
 . E  S WP(CNT)="KID file couldn't be loaded. Use the Edit Patch option to load the KIDS file in.",CNT=CNT+1
 . S WP(CNT)="Patch Module Entries: ",CNT=CNT+1
 . N J F J=0:0 S J=$O(RESULT(I,"MSG",J)) Q:'J  S WP(CNT)="Entry: "_J_" with designation "_$P(^A1AE(11005,J,0),U),CNT=CNT+1
 . S WP(CNT)=" ",CNT=CNT+1
 K I,CNT
 N PARM S PARM(1)=$$GET1^DIQ(200,DUZ,.01)
 D SENDBULL^XMXAPI(DUZ,"A1AE LOAD RELEASED PATCH",.PARM,$NA(WP))
 QUIT
 ;
LOAD(ROOT,PATCH,ERROR,RESULT) ; Load TXT message, find KIDS, then load KIDS and mail.
 ; ROOT = File system directory (Ref)
 ; PATCH = File system .TXT patch name (including the .TXT) (Value)
 ; ERROR = Ref variable to indicate error.
 ; RESULT = Ref variable containing the results, including whether we could load the KIDS patch
 ;
 ; NB: I start from 2 just in case there is something I need to put in 1 (like $TXT)
 K ^TMP($J,"TXT")
 D EN^DDIOL("Loading description "_PATCH)
 N Y S Y=$$FTG^%ZISH(ROOT("SB"),PATCH,$NA(^TMP($J,"TXT",2,0)),3) I 'Y W !,"Error copying TXT to global" S ERROR=1 Q
 D CLEANHF^A1AEK2M0($NA(^TMP($J,"TXT"))) ; add $TXT/$END TXT if necessary
 ;
 ; Analyze message and extract data from it.
 N RTN ; RPC style return
 ;
 ;
 ; N OET S OET=$ET
 N $ET,$ES S $ET="D ANATRAP^A1AEK2M2(PATCH)" ; try/catch
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
 N INFOONLY S INFOONLY=$$INFOONLY(.RTN) ; Info Only patch?
 I INFOONLY D EN^DDIOL(PATCH_" is an Info Only patch.")
 ;
 ; Load KIDS message starting into the last subscript + 1 from the text node
 ; Only if not informational!!! -- THIS CHANGED NOW B/C VA HAS SOME PATCHES THAT ARE INFORMATIONAL AND HAVE KIDS BUILDS
 K ^TMP($J,"KID")
 N KIDFIL S KIDFIL=$$KIDFIL^A1AEK2M0(.ROOT,PATCH,.RTN,$NA(^TMP($J,"KID"))) ; Load the KIDS file
 ;
 ; Fill in results array
 S RESULT(RTN("DESIGNATION"),"TXT")=PATCH
 S RESULT(RTN("DESIGNATION"),"KID")=KIDFIL
 I INFOONLY S RESULT(RTN("DESIGNATION"),"KID")="Info Only Patch"
 N CANTLOAD S CANTLOAD=0
 ; if we can't find it, and it isn't info, put it in this array.
 I KIDFIL="",'INFOONLY S RESULT(RTN("DESIGNATION"),"CANTLOAD")=PATCH,CANTLOAD=1
 ;
 ; If we loaded the KIDS build, move it over.
 I $D(^TMP($J,"KID")) D
 . N I F I=1:1 Q:'$D(^TMP($J,"KID",I))  S ^TMP($J,"MSG",LASTSUB+I,0)=^TMP($J,"KID",I)
 ; 
 ; debug
 ; S $ET="B"
 ; debug
 ;
 ; Add dependencies in description (temporary or permanent... I don't know now).
 D PREREQAD(.RTN)
 ;
 ; Load whole thing and split
 D ADD0(.RTN,$NA(^TMP($J,"MSG")),CANTLOAD,INFOONLY,.RESULT,$$DEFDIR^%ZISH("./")_ROOT("SB"),PATCH,KIDFIL)
 ;
 ;
 ; Deliver the message
 ; DON'T DO THIS ANYMORE -- WILL DELETE
 ; N XMERR,XMZ
 ; D SENDMSG^XMXAPI(.5,XMSUBJ,$NA(^TMP($J,"MSG")),"XXX@Q-PATCH.OSEHRA.ORG",,.XMZ) ; after
 ; I $D(XMERR) W !,"MailMan error, see ^TMP(""XMERR"",$J)" S ERROR=1 Q
 ; Set MESSAGE TYPE to KIDS build
 ; S $P(^XMB(3.9,XMZ,0),"^",7)="K"
 ;
 ; Kill temp globals
 K ^TMP($J,"KID"),^("TXT"),^("MSG")
 ;
 QUIT
 ;
ADD0(RTN,MSGGLO,CANTLOAD,INFOONLY,RESULT,ROOTPATH,TXTFIL,KIDFIL) ; Wrapper around all addition functions
 ; ** WARNING ** NEXT 2 LINES ARE IMPORTANT AND CONFUSING - I WOULD LOVE TO CHANGE IT.
 ; Change designation into Patch Module format from KIDS format
 ; 
 N OLDDESIGNATION S OLDDESIGNATION=RTN("DESIGNATION")
 S RTN("DESIGNATION")=$$K2PMD(RTN("DESIGNATION"))
 ; ZEXCEPT: A1AEPKIF is created by PKGADD in the ST.
 D PKGADD(RTN("DESIGNATION"))            ; Add to Patch Module Package file
 D PKGSETUP(A1AEPKIF,.RTN)               ; And set it up.
 D VERSETUP(A1AEPKIF,RTN("DESIGNATION")) ; Add its version; ZEXCEPT: A1AEVR - Version leaks
 N DA S DA=$$ADDPATCH^A1AEK2M0(A1AEPKIF,A1AEVR,.RTN,MSGGLO,CANTLOAD,INFOONLY,ROOTPATH,TXTFIL,KIDFIL)  ; ZEXCEPT: A1AENB,A1AEPD
 D ASSERT(DA)                            ; Assert that we obtained an IEN
 D ASSERT($P(RTN("DESIGNATION"),"*",3)=A1AENB) ; Assert that the Number is the same as the patch number
 D ASSERT(RTN("DESIGNATION")=A1AEPD) ; Assert that the designation is the same as the Patch Designation
 ; 
 S RESULT(OLDDESIGNATION,"MSG",DA)="" ; have to use old design b/c we just changed it.
 ; Now, add the Primary forked version of the patch
 N DA D
 . N DERIVEDPATCH M DERIVEDPATCH=RTN
 . N PRIM S PRIM=$$PRIMSTRM^A1AEUTL()
 . S DERIVEDPATCH("ORIG-DESIGNATION")=DERIVEDPATCH("DESIGNATION")
 . S $P(DERIVEDPATCH("DESIGNATION"),"*",3)=$P(DERIVEDPATCH("DESIGNATION"),"*",3)+PRIM-1
 . S DA=$$ADDPATCH^A1AEK2M0(A1AEPKIF,A1AEVR,.DERIVEDPATCH,MSGGLO,CANTLOAD,INFOONLY,ROOTPATH,TXTFIL,KIDFIL)  ; ZEXCEPT: A1AENB,A1AEPD
 . D ASSERT(DA)                            ; Assert that we obtained an IEN
 . D ASSERT($$GET1^DIQ(11005,DA,5.2)=DERIVEDPATCH("ORIG-DESIGNATION")) ; Original designation should be retained in derived field
 . D EN^DDIOL("Forked "_DERIVEDPATCH("ORIG-DESIGNATION")_" into "_DERIVEDPATCH("DESIGNATION"))
 . S RESULT(OLDDESIGNATION,"MSG",DA)="" ; ditto... see above.
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
 N X,A1AE S A1AE(0)="L" ; X is version number; input to ^DIC
 S X=$P(DESIGNATION,"*",2)
 D VER^A1AEUTL ; Internal API
 D ASSERT(A1AEVR=$P(DESIGNATION,"*",2))
 QUIT
 ;
INFOONLY(TXTINFO) ; Private to Package; Is this patch Info Only?
 N INFOONLY S INFOONLY=0
 N I F I=0:0 S I=$O(TXTINFO("CAT",I)) Q:'I  I TXTINFO("CAT",I)="Informational" S INFOONLY=1
 N I F I=0:0 S I=$O(TXTINFO("CAT",I)) Q:'I  I TXTINFO("CAT",I)="Routine" S INFOONLY=0   ; B/c somebody might screw up by adding addtional stuff.
 Q INFOONLY
 ;
PREREQAD(TXTINFO) ; Private to Package; Add pre-requisites to txt message
 I $O(TXTINFO("PREREQ","")) D                              ; If we have prerequisites
 . N LS S LS=$O(TXTINFO("DESC"," "),-1)                    ; Get last sub
 . N NS S NS=LS+1                                      ; New Sub
 . S TXTINFO("DESC",NS)=" ",NS=NS+1                        ; Empty line
 . S TXTINFO("DESC",NS)="Associated patches:",NS=NS+1      ; Put the data into (this line and next)
 . N I F I=1:1 Q:'$D(TXTINFO("PREREQ",I))  S TXTINFO("DESC",NS)=" - "_TXTINFO("PREREQ",I),NS=NS+1
 QUIT
 ;
 ;
ASSERT(X,Y) ; Assertion engine
 ; ZEXCEPT: XTMUNIT - Newed on a lower level of the stack if using M-Unit
 ; I X="" BREAK
 I $D(XTMUNIT) D CHKTF^XTMUNIT(X,$G(Y)) QUIT  ; if we are inside M-Unit, assert using that engine.
 I 'X D EN^DDIOL($G(Y)) S $EC=",U-ASSERTION-ERROR,"  ; otherwise, throw error if assertion fails.
 QUIT
