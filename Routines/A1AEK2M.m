A1AEK2M ;ven/smh,toad-options a1ae import * ; 6/9/15 6:14pm
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ; contents
 ;
 ; IMPORT: option import patch
 ;   [A1AE IMPORT PATCH]
 ; SD: option import patches in a single directory
 ;   [A1AE IMPORT SINGLE DIR]
 ; RECURSE: option import patches recursive from a directory tree
 ;   [A1AE IMPORT RECURSIVE]
 ; RECURSE1: import from directory & subdirectories
 ; $$RECURSE2: find the multibuild directory
 ; SILENT: silently import all patches from a directory
 ; MAIL: send bulletin re loaded patches
 ; LOAD: load a patch's hfs files
 ; ADD0: load foia patch msg & its osehra copy
 ; $$K2PMD: convert patch id from kids to pm
 ; PKGADD: add pkg to pm
 ; PKGSETUP: setup pkg in pm
 ; $$MKUSER: make users for the pm pkg
 ; VERSETUP: add pkg version
 ; $$INFOONLY: is patch info only?
 ; PREREQAD: add dependencies in description
 ; ASSERT: assertion engine
 ;
 ;
 ; change history:
 ;
 ; Based on code written by Dr. Cameron Schlehuber.
 ;
 ; 2014-04-16 routine A1AEK2M created by Sam Habiel (ven/smh)
 ;
 ; 2015-05-25 Rick Marshall of the VISTA Expertise Network (ven/toad)
 ; added structure comments in SD and called subroutines in prep for
 ; creating option A1AE IMPORT HFS DISTRIBUTION. SD, SILENT, LOAD, MAIL,
 ; ADD0, $$INFOONLY, PREREQAD, PKGADD, PKGSETUP, VERSETUP, $$MKUSER,
 ; ASSERT.
 ;
 ; 2015-05-26 ven/toad: create option A1AE IMPORT HFS DISTRIBUTION
 ; (just a shell for now, fill in later), contents, more structural
 ; comments, change ADD0 to *not* create an OSEHRA patch for each FOIA
 ; patch it imports. IMPORT, SD, RECURSE, RECURSE1, $$RECURSE2, ADD0,
 ; $$INFOONLY.
 ;
 ; 2015-05-28, ven/lgc: ^XTMP set when routine called at top is for unit
 ; testing
 ;
 ; 2015-05-30, ven/toad: prevent user error code at MKUSR+17^A1AEK2M
 ; as a result of the updater call, which did not like setting the
 ; security key to '561; changed to just set it to KEY, since the E
 ; flag will allow external values. prevent error in PKGSETUP & MKUSR
 ; where VA redacts names, causing crashes in updater call.
 ;
 ; Notes on the KIDS format and conversion procedure.
 ; NB: Notes moved to A1AEK2M0 to make space in this routine.
 ;
 ; TODO: File package entry into our system if it can't be found
 ;       - Hint: Finds KIDS EP that does the PKG subs
 ; TODO: I created fields latterly that hold the file names and file
 ;       paths to use. They are only used in the KIDs Version Control
 ;       breakout. They can be used to track all the mail information
 ;       rather than keep them in variables.
 ; TODO: The recursion code is very very first draft... needs to be
 ;       refined.
 ;
 S ^XTMP($J,"A1AEK2M FROM TOP")=$$HTFM^XLFDT($H,5)_"^"_$$HTFM^XLFDT($H,5)
 Q
 ;
IMPORT ; option import a patch [A1AE IMPORT HFS DISTRIBUTION]
 ;private;procedure;clean?;silent?;sac-compliant?
 ; called by option A1AE IMPORT HFS DISTRIBUTION
 ;
 ; 1. prompt for a patch file
 ;
 ;
 ; 2. import that patch
 ;
 D EN^DDIOL("Patch ??? selected.")
 ;
 QUIT  ; end of IMPORT
 ;
 ;
SD ; option import patches in a single directory [A1AE IMPORT SINGLE DIR]
 ;private;procedure;clean?;silent?;sac-compliant?
 ; called by option A1AE IMPORT SINGLE DIR
 ;
 ; N DUZ S DUZ=.5,DUZ(0)="" ; Save DUZ from previous caller.
 ;
 ; 1. prompt for directory to load all patches from
 ;
 N DIR,X,Y,DIROUT,DIRUT,DTOUT,DUOUT,DIROUT ; fur DIR
 S DIR(0)="F^2:255",DIR("A")="Full path of patches to load, up to but not including patch names"
 S DIR("B")=$G(^DISV(DUZ,"A1AEK2M-SB"))
 D ^DIR
 QUIT:Y="^"
 N ROOT S ROOT("SB")=Y  ; where we load files from... Single Build Root
 S ^DISV(DUZ,"A1AEK2M-SB")=Y
 ;
 ; 2. prompt for directory to load multi-builds from
 ;
 S DIR(0)="F^2:255",DIR("A")="Full path of Multibuilds directory, in case I can't find a patch"
 S DIR("B")=$G(^DISV(DUZ,"A1AEK2M-MB"))
 D ^DIR
 QUIT:Y="^"
 S ROOT("MB")=Y ; Multi Build Root
 S ^DISV(DUZ,"A1AEK2M-MB")=Y
 ;
 ; 3. silently load all kids distributions from that directory
 ;
 D SILENT(.ROOT)
 ;
 QUIT  ; end of SD
 ;
 ;
RECURSE ; option import patches recursive from a directory tree
 ;   [A1AE IMPORT RECURSIVE]
 ;private;procedure;clean?;silent?;sac-compliant?
 ; called by option A1AE IMPORT RECURSIVE
 ;
 ; TODO: Document and clean.
 ;
 ; 1. prompt for directory to load patches from
 ;
 N DIR,X,Y,DIROUT,DIRUT,DTOUT,DUOUT,DIROUT ; fur DIR
 S DIR(0)="F^2:255",DIR("A")="Full path of patches to load, up to but not including patch names"
 S DIR("B")=$G(^DISV(DUZ,"A1AEK2M-RP")) ; Recurse Path
 D ^DIR
 QUIT:Y="^"
 N ROOT
 S ROOT=Y
 S ^DISV(DUZ,"A1AEK2M-RP")=ROOT
 ;
 ; 2. import all patches from directories & subdirectories
 ;
 N LVL S LVL=0
 N PATCHROOTS
 S PATCHROOTS=ROOT
 N MBROOT
 S PATCHROOTS("MB")=$$RECURSE2(PATCHROOTS) ; find multibuild directory
 D RECURSE1(ROOT,.PATCHROOTS) ; import all patches from dir & subdirs
 ;
 QUIT  ; end of RECURSE
 ;
 ;
RECURSE1(ROOT,PATCHROOTS) ; import from directory & subdirectories
 ;private;procedure;clean?;silent?;sac-compliant?
 ; called by RECURSE
 ;
 ; TODO: Document and clean.
 ;
 ; 1. initialize
 ;
 ; ZEXCEPT: LVL - Newed above
 ; ZEXCEPT: L - no such variable. XINDEX is tripping up.
 N % ; Throw away variable
 S LVL=$G(LVL,0)
 N ARRAY S ARRAY("*")=""
 N FILES,TXTFILES
 ; DEFDIR bug!:
 I $$DEFDIR^%ZISH(ROOT)="/"!('$$LIST^%ZISH(ROOT,"ARRAY","FILES")) QUIT
 ;
 ; 2. load list of .txt files in directory
 ;
 S ARRAY("*.txt")=""
 S ARRAY("*.TXT")=""
 S %=$$LIST^%ZISH(ROOT,"ARRAY","TXTFILES")
 ;
 ; 3. base case: silently import all patches from a directory
 ;
 I $D(TXTFILES) D
 . S PATCHROOTS("SB")=ROOT
 . D SILENT(.PATCHROOTS)
 ;
 ; 4. recursive case: for each subdirectory, call RECURSE1 to process it
 ;
 N F S F="" F  S F=$O(FILES(F)) Q:F=""  D
 . I $E(F)="." QUIT  ; Hidden file
 . W:$D(KBANDEBUG) ?LVL*5,F,!
 . S LVL=LVL+1
 . D RECURSE1(ROOT_F_"/")
 . S LVL=LVL-1
 ;
 QUIT  ; end of RECURSE1
 ;
 ;
RECURSE2(ROOT) ; find the multibuild directory
 ;private;function;clean?;silent?;sac-compliant?
 ; called by RECURSE
 ;
 ; TODO: Document and clean.
 ;
 ; 1. initialize
 ;
 ; ZEXCEPT: MBROOT ; Newed at the caller
 ; ZEXCEPT: LVL - Newed above
 ; ZEXCEPT: L - no such variable. XINDEX is tripping up.
 I $$UP^XLFSTR(ROOT)["MULTIBUILD" S MBROOT=ROOT
 S LVL=$G(LVL,0)
 N ARRAY S ARRAY("*")=""
 N FILES
 ; DEFDIR bug!:
 I $$DEFDIR^%ZISH(ROOT)="/"!('$$LIST^%ZISH(ROOT,"ARRAY","FILES")) QUIT ""
 ;
 ; 2. recursively search for multibuild directory
 ;
 N F S F="" F  S F=$O(FILES(F)) Q:F=""  D  Q:$D(MBROOT)
 . I $E(F)="." QUIT  ; Hidden file
 . ; DEFDIR bug!:
 . I $$DEFDIR^%ZISH(ROOT_F_"/")="/"!('$$LIST^%ZISH(ROOT_F_"/","ARRAY","FILES")) QUIT
 . W:$D(KBANDEBUG) ?LVL*5,F,!
 . S LVL=LVL+1
 . N % S %=$$RECURSE2(ROOT_F_"/")
 . S LVL=LVL-1
 ;
 QUIT $G(MBROOT) ; end of $$RECURSE2 ; return multi-build root
 ;
 ;
SILENT(ROOT) ; silently import all patches from a directory
 ; All output is sent via EN^DDIOL. Set DIQUIET to redirect to a global.
 ;
 ; 1. load list of kids text files
 ;
 N ARRAY
 S ARRAY("*.TXT")=""
 S ARRAY("*.txt")=""
 N FILES ; return array
 N Y S Y=$$LIST^%ZISH(ROOT("SB"),"ARRAY","FILES")
 I 'Y D EN^DDIOL("Error getting directory list") QUIT
 ;
 ; 2. traverse text patches, load each
 ;
 N ERROR
 N PATCH S PATCH=""
 N RESULT ; Result of Load
 F  S PATCH=$O(FILES(PATCH)) Q:PATCH=""  D LOAD(.ROOT,PATCH,.ERROR,.RESULT) Q:$D(ERROR)
 ;
 ; 3. report patches without .kid files
 ;
 N I S I=""
 F  S I=$O(RESULT(I)) Q:I=""  I $D(RESULT(I,"CANTLOAD")) D
 . D EN^DDIOL("Patch "_I_" from "_RESULT(I,"TXT")_" doesn't have a KIDS file")
 . D EN^DDIOL("Please load these KIDS files manually into the patch module.")
 ;
 ; 4. send bulletin re loaded patches
 ;
 D MAIL(.RESULT)
 ;
 QUIT  ; end of SILENT
 ;
 ;
MAIL(RESULT) ; send bulletin re loaded patches
 ; Private Proc to Package
 ; Mail the result of the load to interested parties using the bulletin
 ; A1AE LOAD RELEASED PATCH
 ;
 ; 1. build bulletin text for each patch
 ;
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
 ;
 ; 2. send bulletin
 ;
 N PARM S PARM(1)=$$GET1^DIQ(200,DUZ,.01)
 D SENDBULL^XMXAPI(DUZ,"A1AE LOAD RELEASED PATCH",.PARM,$NA(WP))
 ;
 QUIT  ; end of MAIL
 ;
 ;
LOAD(ROOT,PATCH,ERROR,RESULT) ; load a patch's hfs files
 ; Load TXT message, find KIDS, then load KIDS and mail.
 ; ROOT = File system directory (Ref)
 ; PATCH = File system .TXT patch name (including the .TXT) (Value)
 ; ERROR = Ref variable to indicate error.
 ; RESULT = Ref variable containing the results, including whether we could load the KIDS patch
 ;
 ; 1. load patch description from .txt file
 ;
 ; NB: I start from 2 just in case there is something I need to put in 1 (like $TXT)
 K ^TMP($J,"TXT")
 D EN^DDIOL("Loading description "_PATCH)
 N Y S Y=$$FTG^%ZISH(ROOT("SB"),PATCH,$NA(^TMP($J,"TXT",2,0)),3)
 I 'Y W !,"Error copying TXT to global" S ERROR=1 Q
 D CLEANHF^A1AEK2M0($NA(^TMP($J,"TXT"))) ; add $TXT/$END TXT if necessary
 ;
 ; 2. analyze message and extract data from it
 ;
 N RTN ; RPC style return
 ; N OET S OET=$ET
 N $ET,$ES S $ET="D ANATRAP^A1AEK2M2(PATCH)" ; try/catch
 D ANALYZE^A1AEK2M2(.RTN,$NA(^TMP($J,"TXT")))
 ; S $ET=OET
 ; K OET
 ;
 ; 3. move description to msg array
 ; ensure we have room for $TXT
 ;
 K ^TMP($J,"MSG") ; Message array eventually to be mailed.
 N I F I=0:0 S I=$O(RTN("DESC",I)) Q:'I  S ^TMP($J,"MSG",I+1,0)=RTN("DESC",I)
 S ^TMP($J,"MSG",1,0)=RTN("$TXT") ; $TXT
 N LS S LS=$O(^TMP($J,"MSG"," "),-1)
 S ^TMP($J,"MSG",LS+1,0)="$END TXT" ; $END TXT
 K I,LS
 N LASTSUB S LASTSUB=$O(^TMP($J,"TXT"," "),-1)
 ;
 ; 4. info-only patch?
 ;
 N INFOONLY S INFOONLY=$$INFOONLY(.RTN) ; Info Only patch?
 I INFOONLY D EN^DDIOL(PATCH_" is an Info Only patch.")
 ;
 ; 5. load patch payload from .kid file
 ;
 ; Load KIDS message starting into the last subscript
 ; + 1 from the text node
 ; Only if not informational!!!
 ; THIS CHANGED NOW B/C VA HAS SOME PATCHES THAT ARE INFORMATIONAL
 ; YET HAVE KIDS BUILDS
 K ^TMP($J,"KID")
 N KIDFIL ; Load the KIDS file:
 S KIDFIL=$$KIDFIL^A1AEK2M0(.ROOT,PATCH,.RTN,$NA(^TMP($J,"KID")))
 ;
 ; 6. fill in results array
 ;
 S RESULT(RTN("DESIGNATION"),"TXT")=PATCH
 S RESULT(RTN("DESIGNATION"),"KID")=KIDFIL
 I INFOONLY D
 . S RESULT(RTN("DESIGNATION"),"KID")="Info Only Patch"
 N CANTLOAD S CANTLOAD=0
 ; if we can't find it, and it isn't info, put it in this array.
 I KIDFIL="",'INFOONLY D
 . S RESULT(RTN("DESIGNATION"),"CANTLOAD")=PATCH
 . S CANTLOAD=1
 ;
 ; 7. move payload to msg array
 ;
 I $D(^TMP($J,"KID")) D
 . N I F I=1:1 Q:'$D(^TMP($J,"KID",I))  D
 . . S ^TMP($J,"MSG",LASTSUB+I,0)=^TMP($J,"KID",I)
 ;
 ; debug
 ; S $ET="B"
 ; debug
 ;
 ; 8. add dependencies in description
 ;
 ; (temporary or permanent... I don't know now)
 D PREREQAD(.RTN)
 ;
 ; 9. load FOIA patch msg & its OSEHRA copy
 ;
 D ADD0(.RTN,$NA(^TMP($J,"MSG")),CANTLOAD,INFOONLY,.RESULT,$$DEFDIR^%ZISH("./")_ROOT("SB"),PATCH,KIDFIL)
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
 QUIT  ; end of LOAD
 ;
 ;
ADD0(RTN,MSGGLO,CANTLOAD,INFOONLY,RESULT,ROOTPATH,TXTFIL,KIDFIL) ; load foia patch msg & its osehra copy
 ;
 ; Wrapper around all addition functions
 ;
 ; 1. set defaults for Server call
 ; In case we are invoked from A1AEPSVR, default these so we won't crash
 S ROOTPATH=$G(ROOTPATH)
 S TXTFIL=$G(TXTFIL)
 S KIDFIL=$G(KIDFIL)
 ;
 ; ** WARNING ** NEXT 2 LINES ARE IMPORTANT AND CONFUSING - I WOULD LOVE TO CHANGE IT.
 ;
 ; 2. convert patch id from kids to pm
 ;
 N OLDDESIGNATION S OLDDESIGNATION=RTN("DESIGNATION")
 ; Change designation into Patch Module format from KIDS format
 S RTN("DESIGNATION")=$$K2PMD(RTN("DESIGNATION"))
 ;
 ; 3. add pkg to pm
 ;
 ; ZEXCEPT: A1AEPKIF is created by PKGADD in the ST.
 D PKGADD(RTN("DESIGNATION"))
 ;
 ; 4. setup pkg in pm
 ;
 D PKGSETUP(A1AEPKIF,.RTN)
 ;
 ; 5. add pkg version
 ;
 D VERSETUP(A1AEPKIF,RTN("DESIGNATION"))
 ; ZEXCEPT: A1AEVR - Version leaks
 ;
 ; 6. add foia-stream patch
 ;
 N DA S DA=$$ADDPATCH^A1AEK2M0(A1AEPKIF,A1AEVR,.RTN,MSGGLO,CANTLOAD,INFOONLY,ROOTPATH,TXTFIL,KIDFIL)
 ; ZEXCEPT: A1AENB,A1AEPD
 ; Assert that we obtained an IEN:
 D ASSERT(DA)
 ; Assert that the Number is the same as the patch number:
 D ASSERT($P(RTN("DESIGNATION"),"*",3)=A1AENB)
 ; Assert that the designation is the same as the Patch Designation:
 D ASSERT(RTN("DESIGNATION")=A1AEPD)
 ;
 ; 7. add equiv osehra-stream patch
 ; NO - WE NO LONGER DO THIS; LEFT OVER FROM PHASE 1
 ; TO DO: CREATE A NEW OPTION TO MANUALLY DO THIS FROM A PATCH
 ;
 ; have to use old design b/c we just changed it:
 ; S RESULT(OLDDESIGNATION,"MSG",DA)=""
 ; Now, add the Primary forked version of the patch:
 ; N DA D
 ; . N DERIVEDPATCH M DERIVEDPATCH=RTN
 ; . N PRIM S PRIM=$$PRIMSTRM^A1AEUTL()
 ; . S DERIVEDPATCH("ORIG-DESIGNATION")=DERIVEDPATCH("DESIGNATION")
 ; . S $P(DERIVEDPATCH("DESIGNATION"),"*",3)=$P(DERIVEDPATCH("DESIGNATION"),"*",3)+PRIM-1
 ; . S DA=$$ADDPATCH^A1AEK2M0(A1AEPKIF,A1AEVR,.DERIVEDPATCH,MSGGLO,CANTLOAD,INFOONLY,ROOTPATH,TXTFIL,KIDFIL)
 ; . ; ZEXCEPT: A1AENB,A1AEPD
 ; . ; Assert that we obtained an IEN:
 ; . D ASSERT(DA)
 ; . ; Original designation should be retained in derived field:
 ; . D ASSERT($$GET1^DIQ(11005,DA,5.2)=DERIVEDPATCH("ORIG-DESIGNATION"))
 ; . D EN^DDIOL("Forked "_DERIVEDPATCH("ORIG-DESIGNATION")_" into "_DERIVEDPATCH("DESIGNATION"))
 ; . S RESULT(OLDDESIGNATION,"MSG",DA)="" ; ditto... see above.
 ;
 QUIT  ; end of ADD0
 ;
 ;
K2PMD(PATCH) ; convert patch id from kids to pm
 ; Private to package
 ; $$; Kids to Patch Module designation
 ; Code by Wally from A1AEHSVR.
 N %
 I PATCH[" " D
 . S %=$L(PATCH," ")
 . S PATCH=$P(PATCH," ",1,%-1)_"*"_$P(PATCH," ",%)_"*0"
 I $L(PATCH,"*")=3 D
 . S $P(PATCH,"*",2)=+$P(PATCH,"*",2)
 ;
 Q PATCH ; end of $$K2PMD ; return pm patch id
 ;
 ;
PKGADD(DESIGNATION) ; add pkg to pm
 ; Proc; Private to this routine
 ; Add package to Patch Module
 ; Input: Designation: Patch designation AAA*1*22; By value
 ; ZEXCEPT: A1AEPK,A1AEPKIF,A1AEPKNM - Created by PKG^A1AEUTL
 ;
 ; When doing lookups for laygo, only look in the Package file's
 ; C index for designation.
 N DIC S DIC("PTRIX",11007,.01,9.4)="C"
 N A1AE S A1AE(0)="XLM" ; eXact match, Laygo, Multiple Indexes
 N X S X=$P(DESIGNATION,"*") ; Input to ^DIC
 D PKG^A1AEUTL
 ; ZEXCEPT: Y leaks from PKG^A1AEUTL
 I $P($G(Y),U,3) D
 . D EN^DDIOL("Added Package "_DESIGNATION_" to "_$P(^A1AE(11007,0),U))
 ;
 ; Check that the output variables from PKG^A1AEUTL are defined.
 D ASSERT(A1AEPKIF) ; Must be positive
 D ASSERT(A1AEPK=$P(DESIGNATION,"*")) ; PK must be the AAA
 D ASSERT($L(A1AEPKNM)) ; Must be defined.
 ;
 QUIT  ; end of PKGADD
 ;
 ;
PKGSETUP(A1AEPKIF,TXTINFO) ; setup pkg in pm
 ; Private
 ;
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
 D  ; SUPPORT & VERIFY PERSONNEL
 . N VER
 . S VER=TXTINFO("VER") S:VER="" VER="PATCHMODULE,VERIFIER"
 . S A1AEFDA(11007.02,"?+1,"_IENS,.01)="`"_$$MKUSR(VER,"A1AE PHVER") ; SUPPORT
 . S A1AEFDA(11007.02,"?+1,"_IENS,2)="V"  ; VERIFY
 . Q
 D  ; DEVELOPMENT PERSONNEL
 . N DEV
 . S DEV=TXTINFO("DEV") S:DEV="" DEV="PATCHMODULE,DEVELOPER"
 . S A1AEFDA(11007.03,"?+2,"_IENS,.01)="`"_$$MKUSR(DEV,"A1AE DEVELOPER")
 . Q
 D  ; COMPLETER
 . N COM
 . S COM=TXTINFO("COM") S:COM="" COM="PATCHMODULE,COMPLETER"
 . S A1AEFDA(11007.03,"?+3,"_IENS,.01)="`"_$$MKUSR(COM,"A1AE DEVELOPER")
 . Q
 I $D(A1AEFDA) D
 . D UPDATE^DIE("E",$NA(A1AEFDA))
 . I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 . D ASSERT($D(^A1AE(11007,A1AEPKIF,"PB")))  ; Verifier Nodes
 . D ASSERT($D(^A1AE(11007,A1AEPKIF,"PH")))  ; Developer Nodes
 . Q
 ;
 QUIT  ; end of PKGSETUP
 ;
 ;
MKUSR(NAME,KEY) ; make users for the pm pkg
 ; Private
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
 S:$L($G(KEY)) A1AEFDA(200.051,"?+3,?+1,",.01)=KEY
 ;
 N DIC S DIC(0)="" ; An XREF in File 200 requires this.
 D UPDATE^DIE("E",$NA(A1AEFDA),$NA(A1AEIEN),$NA(A1AEERR)) ; Typical UPDATE
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 Q A1AEIEN(1) ;end of $$MKUSER: return user ien
 ;
 ;
VERSETUP(A1AEPKIF,DESIGNATION) ; add pkg version
 ; Private
 ; setup version in 11007
 ; Input: - A1AEPKIF - Package IEN in 11007, value
 ;        - DESIGNATION - Package designation (XXX*1*3)
 ; Output: (In symbol table:) A1AEVR
 ;
 ; ZEXCEPT: A1AEVR - Created here by VER^A1AEUTL
 N X,A1AE S A1AE(0)="L" ; X is version number; input to ^DIC
 S X=$P(DESIGNATION,"*",2)
 D VER^A1AEUTL ; Internal API
 D ASSERT(A1AEVR=$P(DESIGNATION,"*",2))
 ;
 QUIT  ; end of VERSETUP
 ;
 ;
INFOONLY(TXTINFO) ; is patch info only?
 ; Private to Package
 N INFOONLY S INFOONLY=0
 N I F I=0:0 S I=$O(TXTINFO("CAT",I)) Q:'I  D
 . I TXTINFO("CAT",I)="Informational" S INFOONLY=1
 N I F I=0:0 S I=$O(TXTINFO("CAT",I)) Q:'I  D
 . I TXTINFO("CAT",I)="Routine" S INFOONLY=0
 . ; B/c somebody might screw up by adding additional stuff
 ;
 Q INFOONLY ; end of INFOONLY: return true if info-only
 ;
 ;
PREREQAD(TXTINFO) ; add dependencies in description
 ; Private to Package
 ; Add pre-requisites to txt message
 I $O(TXTINFO("PREREQ","")) D  ; If we have prerequisites:
 . N LS S LS=$O(TXTINFO("DESC"," "),-1) ; Get last sub
 . N NS S NS=LS+1 ; New Sub
 . S TXTINFO("DESC",NS)=" ",NS=NS+1 ; Empty line
 . ; Put the data into (this line and next):
 . S TXTINFO("DESC",NS)="Associated patches:",NS=NS+1
 . N I F I=1:1 Q:'$D(TXTINFO("PREREQ",I))  D
 . . S TXTINFO("DESC",NS)=" - "_TXTINFO("PREREQ",I),NS=NS+1
 ;
 QUIT  ; end of PREREQAD
 ;
 ;
ASSERT(X,Y) ; assertion engine
 ;
 ; ZEXCEPT: %ut - Newed on a lower level of the stack if using M-Unit
 ; I X="" BREAK
 I $D(%ut) D  Q  ; if we are inside M-Unit:
 . D CHKTF^%ut(X,$G(Y)) ; assert using that engine
 I 'X D  ; otherwise
 . D EN^DDIOL($G(Y))
 . S $EC=",U-ASSERTION-ERROR," ; throw error if assertion fails
 ;
 QUIT  ; end of ASSERT
 ;
 ;
EOR ; end of routine A1AEK2M
