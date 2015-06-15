A1AEK2M0 ;ven/smh,toad-option A1AE import single dir ;2015-06-13  8:38 PM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ; CHANGE ven/lgc 2015 05 28
 ;   ^XTMP set when routine called at top is for unit testing
 ; 2015-05-30, ven/toad: fix bug in CLEANHF caused by refactoring:
 ; <UNDEF>CLEANHF+7^A1AEK2M0, PATT undefined.
 ;
 S ^XTMP($J,"A1AEK2M0 FROM TOP")=$$HTFM^XLFDT($H,5)_"^"_$$HTFM^XLFDT($H,5)
 Q
 ;
KIDFIL(ROOT,PATCH,TXTINFO,KIDGLO) ; load patch payload from .kid file
 ; $$; Private
 ; Find the KIDS file that corresponds to a patch designation
 ; input:
 ;   ROOT: Ref, File system roots (MP = Multibuild folder)
 ;   PATCH: Val, Text file name
 ;   TXTINFO: Ref, the analyzed Text array
 ;   KIDGLO: Name, the Global into which to load the KIDS contents
 ;      in PM format
 ;
 ; This code is pretty iterative.
 ; It keeps trying different things until it finds the patch.
 ;
 N NOEXT S NOEXT=$P(PATCH,".",1,$L(PATCH,".")-1) ; no extension name
 N KIDFIL0 ; Trial iteration variable
 N DONE ; Loop exit
 ;
 ; 1. load based on .txt file name
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
 . F  S P=$O(^TMP($J,"ANKID",P)) Q:P=""  I $$K2PMD^A1AEK2M(P)=TXTINFO("DESIGNATION") S DONE=1 QUIT
 . I $G(DONE) DO  QUIT
 . . M @KIDGLO=^TMP($J,"ANKID",P)
 . . D EN^DDIOL("Found patch "_TXTINFO("DESIGNATION")_" in "_KIDFIL0)
 ;
 ; 2. search all .kid files for patch id & load
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
 . ; Make sure that the patch doesn't contain spaces (package release)
 . F  S F=$O(FILES(F)) Q:F=""  I TXTINFO("DESIGNATION")'[" ",F[$P(TXTINFO("DESIGNATION"),"*",3) D  Q:$G(DONE)
 . . K ^TMP($J,"TKID"),^("ANKID") ; Temp KID; Analysis KID
 . . N % S %=$$FTG^%ZISH(ROOT("SB"),F,$NA(^TMP($J,"TKID",1,0)),3)   ; To Global
 . . I '% S $EC=",U-FILE-DISAPPEARED,"
 . . D ANALYZE^A1AEK2M1($NA(^TMP($J,"ANKID")),$NA(^TMP($J,"TKID"))) ; Analyze the file
 . . ;
 . . ; Now, make sure that the TXT file's designation is the same as the KIDS' patch no.
 . . ; Loop through every patch in the file and make sure at least one matches.
 . . N P S P=""
 . . F  S P=$O(^TMP($J,"ANKID",P)) Q:P=""  I $$K2PMD^A1AEK2M(P)=TXTINFO("DESIGNATION") S DONE=1 QUIT
 . . I $G(DONE) DO  QUIT
 . . . M @KIDGLO=^TMP($J,"ANKID",P)
 . . . D EN^DDIOL("Found patch "_TXTINFO("DESIGNATION")_" in "_F)
 . . . S KIDFIL0=F
 . ;
 . ; Patch zero special case (package release)
 . ; If true, analyze each file for the patch zero notation
 . I KIDFIL0="",(TXTINFO("DESIGNATION")'["*"!($P(TXTINFO("DESIGNATION"),"*",3)=0)) D
 . . N F S F=""
 . . F  S F=$O(FILES(F)) Q:F=""  D
 . . . K ^TMP($J,"TKID"),^("ANKID") ; Temp KID; Analysis KID
 . . . N % S %=$$FTG^%ZISH(ROOT("SB"),F,$NA(^TMP($J,"TKID",1,0)),3)   ; To Global
 . . . I '% S $EC=",U-FILE-DISAPPEARED,"
 . . . D ANALYZE^A1AEK2M1($NA(^TMP($J,"ANKID")),$NA(^TMP($J,"TKID"))) ; Analyze the file
 . . . N P S P=""
 . . . F  S P=$O(^TMP($J,"ANKID",P)) Q:P=""  I $$K2PMD^A1AEK2M(P)=$$K2PMD^A1AEK2M(TXTINFO("DESIGNATION")) S DONE=1 QUIT
 . . . I $G(DONE) DO  QUIT
 . . . . M @KIDGLO=^TMP($J,"ANKID",P)
 . . . . D EN^DDIOL("Found patch "_TXTINFO("DESIGNATION")_" in "_F)
 . . . . S KIDFIL0=F
 ;
 ; 3. search all multiblds for patch id & load
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
 . . F  S P=$O(^XTMP(XTMPS,F,P)) Q:P=""  I $$K2PMD^A1AEK2M(P)=TXTINFO("DESIGNATION") S DONE=1 QUIT
 . . I $G(DONE) D  QUIT
 . . . M @KIDGLO=^XTMP(XTMPS,F,P)
 . . . D EN^DDIOL("Found patch "_TXTINFO("DESIGNATION")_" in "_F)
 . . . S KIDFIL0=F
 ;
 ; If we still can't find it. Oh well! Can't do nuthin.
 K ^TMP($J,"TKID"),^("ANKID")
 ;
 QUIT $G(KIDFIL0) ; end of $$KIDFILE: return name of .kid file
 ;
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
 . N MIN S MIN=I-1 ; For Patch zero (e.g. package release XOBV*1.6*0)
 . N MAX S MAX=I+998 ; up to 999
 . I PN'<MIN&(PN'>MAX) S STRM=I  ; Really this is IF MIN<=PN<=MAX...
 Q STRM
 ;
 ;
CLEANHF(MSGGLO) ; load patch description from .txt file
 ; Private
 ; Clean header and footer in message global
 ; WARNING - Naked all over inside the do block.
 N S S S=$O(@MSGGLO@("")) ; first numeric sub.
 I @MSGGLO@(S,0)'["$TXT Created by " D
 . ; First line is invalid. Try various patterns.
 . N PATT
 . N I F I=1:1 D  Q:($$TRIM^XLFSTR(PATT)=">>END<<")
 . . S PATT=$T(CLNPATT+I)
 . . S PATT=$P(PATT,";;",2)
 . . Q:($$TRIM^XLFSTR(PATT)=">>END<<")
 . . I $$TRIM^XLFSTR(^(0))=$$TRIM^XLFSTR(PATT) D
 . . . S ^(0)="$TXT Created by UNKNOWN,UNKNOWN at DOWNLOADS.VA.GOV  (KIDS)"
 . ; If still not there, put in first node before the message.
 . I ^(0)'["$TXT Created by " D
 . . S @MSGGLO@(S-1,0)="$TXT Created by UNKNOWN,UNKNOWN at DOWNLOADS.VA.GOV  (KIDS)"
 ;
 N LASTSUB S LASTSUB=$O(@MSGGLO@(" "),-1)
 I @MSGGLO@(LASTSUB,0)'["$END TXT" D
 . S @MSGGLO@(LASTSUB+1,0)="$END TXT"
 ;
 QUIT  ; end of CLEANHF
 ;
 ;
CLNPATT ;; Headers to substitute if present using a contains operator. 1st one is just a blank -- INTENTIONAL
 ;;
 ;;*********************
 ;;Original message:
 ;;This informational patch
 ;;>>END<<
 ;
 ;
ADDPATCH(A1AEPKIF,A1AEVR,TXTINFO,PATCHMSG,KIDMISSING,INFOONLY,ROOTPATH,TXTFIL,KIDFIL) ; add patch from msg to pm
 ; Private $$
 ; Add patch to 11005 (non-importing version is at NUM^A1AEUTL)
 ; Input:
 ;   A1AEPKIF = pkg ien
 ;   A1AEVR = version #
 ;  .TXTINFO
 ;      ("DESIGNATION") = patch id
 ;      ("ORIG-DESIGNATION") = patch id of original patch
 ;   PATCHMSG = name of array containing patch msg, $NA(^TMP($J,"MSG"))
 ;   KIDMISSING = 1 if not info-only but kids file missing
 ;   INFOONLY = 1 if info-only
 ;   ROOTPATH = full path to directory containing hfs distribution
 ;   TXTFIL = name of .tst file
 ;   KIDFIL = name of .kid file
 ; output = ien of new record created in file 11005
 ;
 ; 1. don't add patch if already exists
 ;
 N DESIGNATION S DESIGNATION=TXTINFO("DESIGNATION")
 ;
 ; Don't add a patch if it already exists in the system
 ; This first code is for derived patches
 I $D(TXTINFO("ORIG-DESIGNATION")),$D(^A1AE(11005,"ADERIVED",TXTINFO("ORIG-DESIGNATION"))) DO  QUIT $O(^(TXTINFO("ORIG-DESIGNATION"),""))
 . D EN^DDIOL($$RED^A1AEK2M1("Patch already exists. Not adding again."))
 . S A1AENB=$P(DESIGNATION,"*",3) ; leak this
 . S A1AEPD=DESIGNATION ; and also this
 ;
 ; This code is for original patches (not derived)
 I '$D(TXTINFO("ORIG-DESIGNATION")),$D(^A1AE(11005,"B",DESIGNATION)) DO  QUIT $O(^(DESIGNATION,""))
 . D EN^DDIOL($$RED^A1AEK2M1("Patch already exists. Not adding again."))
 . S A1AENB=$P(DESIGNATION,"*",3) ; leak this
 . S A1AEPD=DESIGNATION ; and also this
 ;
 ; 2. create patch
 ;
 ; This block adds the entry to 11005 using the SETNUM API.
 N X S X=DESIGNATION
 S A1AENB=$P(DESIGNATION,"*",3) ; ZEXCEPT: A1AENB leak this
 N A1AETY S A1AETY="PH"
 N A1AEFL S A1AEFL=11005
 N DIC,Y S DIC(0)="LX" ; Laygo, Exact match
 ; ZEXCEPT: DA,A1AEPD Leaked by A1AEUTL
 I $D(TXTINFO("ORIG-DESIGNATION")) D  ; Derived patch!!
 . D SETNUM^A1AEUTL   ; This adds the patch based on the latest patch number
 . ; Derived from patch field:
 . N FDA S FDA(11005,DA_",",5.2)=TXTINFO("ORIG-DESIGNATION")
 . ; File--external b/c this is a pointer, lock:
 . N DIERR D FILE^DIE("EK",$NA(FDA))
 . I $D(DIERR) D
 . . S $EC=",U-FILEMAN-ERROR,"
 E  D  ; original patch!!
 . D SETNUM1^A1AEUTL ; This forces the current patch number in
 ;
 ; Lock the record
 LOCK +^A1AE(11005,DA):0 E  S $EC=",U-FAILED-TO-LOCK," ; should never happen
 ;
 ; Put stream, and that we are currently loading, and some extra fields
 N STREAM S STREAM=$$GETSTRM^A1AEK2M0(DESIGNATION) ; PATCH STREAM
 N FDA
 S FDA(11005,DA_",",.2)=STREAM      ; Current Stream
 S FDA(11005,DA_",",.21)=1          ; Currently Importing
 S FDA(11005,DA_",",6.1)=ROOTPATH   ; Import Path
 S FDA(11005,DA_",",5.3)=TXTFIL     ; Text File Name
 S FDA(11005,DA_",",5.4)=KIDFIL     ; KID File Name
 S FDA(11005,DA_",",5.6)=KIDMISSING ; Are we missing the KID file?
 N DIERR
 D FILE^DIE("",$NA(FDA),$NA(ERR))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 ; Change status to Under Development and add developer in
 S $P(^A1AE(11005,DA,0),U,8)="u" ; field Status of Patch (8)
 ;
 ; Get developer
 N DEV
 N NAME S NAME=TXTINFO("DEV")
 D STDNAME^XLFNAME(.NAME) ; Remove funny stuff (like dots at the end)
 S DEV=$$FIND1^DIC(200,"","QX",NAME,"B") ; Get developer
 D ASSERT(DEV,"Developer "_TXTINFO("DEV")_" couldn't be resolved")
 S $P(^A1AE(11005,DA,0),U,9)=DEV ; field User Entering (9)
 ;
 ; File Date
 N X,Y S X=TXTINFO("DEV","DATE") D ^%DT
 S $P(^A1AE(11005,DA,0),U,12)=Y ; field Date Patch First Entered (12)
 ; Hand cross-reference
 S ^A1AE(11005,"AS",A1AEPKIF,A1AEVR,"u",A1AENB,DA)=""
 ;
 ; Add subject and priority and a default and sequence number
 N FDA,IENS
 N DIERR
 S IENS=DA_","
 S FDA(11005,IENS,"PATCH SUBJECT")=TXTINFO("SUBJECT") ; field 5
 S FDA(11005,IENS,"PRIORITY")=TXTINFO("PRIORITY") ; field 7
 S FDA(11005,IENS,"DISPLAY ROUTINE PATCH LIST")="Yes" ; field 103
 D FILE^DIE("E",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 ; Get Categories from DD (abstractable function; maybe do that)
 N CATDD D FIELD^DID(11005.05,.01,,"POINTER",$NA(CATDD))  ; Categories DD
 N CATS ; Categories
 ; d:DATA DICTIONARY;i:INPUT TEMPLATE;
 N I F I=1:1:$L(CATDD("POINTER"),";") D  ; for each
 . N CATIE S CATIE=$P(CATDD("POINTER"),";",I) ; each
 . Q:CATIE=""  ; last piece is empty. Make sure we aren't tripped up.
 . N EXT,INT ; External Internal forms
 . S INT=$P(CATIE,":"),EXT=$P(CATIE,":",2) ; get these
 . S CATS(EXT)=INT ; set into array for use below
 K CATDD
 ;
 N FDA
 N I F I=1:1 Q:'$D(TXTINFO("CAT",I))  D  ; for each
 . N CAT S CAT=TXTINFO("CAT",I) ; each
 . S CAT=$$UP^XLFSTR(CAT) ; uppercase. PM Title cases them.
 . ; Remove parens from 'Enhancement (Mandatory)':
 . I CAT["ENHANCE" S CAT=$P(CAT," ")
 . N INTCAT S INTCAT=CATS(CAT) ; Internal Category
 . S FDA(11005.05,"+"_I_","_IENS,.01)=INTCAT ; Addition FDA
 N DIERR ; Fileman error flag
 D UPDATE^DIE("",$NA(FDA),$NA(ERR)) ; Add data
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR," ; Chk for error
 ; Assert that there is at least one:
 D ASSERT($O(^A1AE(11005,+IENS,"C",0)))
 K FDA
 K CATS ; don't need this anymore
 ;
 ; Add Description to the patch
 ; Reference code is COPY^A1AECOPD, but this time we use Fileman
 ;
 ; Now put in the whole WP field in the file.
 N DIERR
 D WP^DIE(11005,IENS,5.5,"",$NA(TXTINFO("DESC")),$NA(ERR))
 I $D(DIERR) D
 . S $EC=",U-FILEMAN-ERROR,"         ; Chk for error
 ; Assert that it was copied into PATCH DESCRIPTION:
 D ASSERT($O(^A1AE(11005,DA,"D",0))>0)
 ;
 ; Now, load the full KIDS build
 ; Reference code: ^A1AEM1
 ;
 ; 1st Create stub entry in 11005.1
 ; whether or not we have KIDS file to populate
 NEW DIC,X,DINUM,DD,DO,DE,DQ,DR
 S DIC(0)="L"
 S (X,DINUM)=DA
 S DIC="^A1AE(11005.1,"
 S DIC("DR")="20///"_"No routines included"
 K DD,DO
 D FILE^DICN
 K DE,DQ,DR,DIC("DR")
 ;
 ; Now load either the KIDS file
 ; or the HFS data from the remote system that was sent to us
 I 'INFOONLY D
 . D LDKID(PATCHMSG,DA,KIDMISSING) ; Load KIDS into 11005.1/11005.5
 ;
 ; Assertions
 N HASRTN S HASRTN=0 ; Has Routines?
 N I F I=1:1 Q:'$D(TXTINFO("CAT",I))  D
 . I TXTINFO("CAT",I)="Routine" S HASRTN=1  ; oh yes it does
 I HASRTN,'KIDMISSING D  ; Routine information in Patch
 . D ASSERT($O(^A1AE(11005,DA,"P",0)),"Patch says routine must be present")
 I 'KIDMISSING D
 . D ASSERT($O(^A1AE(11005.1,DA,2,0)),"11005.1 entry must exist for each loaded patch")
 ;
 ; complete & verify patch
 ; but don't run the input transforms b/c they send mail msgs
 ; NB: B/c of the Daisy chain triggers,
 ; the current DUZ and date will be used for users.
 N N F N="COM","VER" D
 . N DUZ
 . N NAME S NAME=TXTINFO(N)
 . D STDNAME^XLFNAME(.NAME) ; Remove funny stuff (like dots at the end)
 . S DUZ=$$FIND1^DIC(200,"","QX",NAME,"B") ; Get developer
 . D ASSERT(DUZ,"User "_NAME_" couldn't be resolved")
 . N FDA,DIERR
 . I N="COM" D
 . . S FDA(11005,IENS,8)="c"
 . . D FILE^DIE("",$NA(FDA))
 . . I $D(DIERR) D
 . . . S $EC=",U-FILEMAN-ERROR,"
 . I N="VER" D
 . . S FDA(11005,IENS,8)="v"
 . . D FILE^DIE("",$NA(FDA))
 . . I $D(DIERR) D
 . . . S $EC=",U-FILEMAN-ERROR,"
 . N X,Y S X=TXTINFO(N,"DATE")
 . D ^%DT
 . N FDA,DIERR
 . ; 10=DATE PATCH COMPLETED; 11=DATE PATCH VERIFIED:
 . S FDA(11005,IENS,$S(N="COM":10,1:11))=Y
 . D FILE^DIE("",$NA(FDA))
 . I $D(DIERR) D
 . . S $EC=",U-FILEMAN-ERROR,"
 ;
 ; Now, put the patches into a review status
 ; and remove the currently importing flag
 N FDA,DIERR
 S FDA(11005,IENS,8)="i2" ; STATUS
 S FDA(11005,IENS,.21)="@" ; CURRENTLY IMPORTING delete
 D FILE^DIE("",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 ; Now keep associated patches for later filing in a holding area
 ; No locks necessary since no increments used.
 ; namespaced subscript in ^XTMP:
 N XTMPS S XTMPS=$T(+0)_"-ASSOCIATED-PATCHES"
 N START S START=$$NOW^XLFDT() ; Now
 ; hold for two years:
 N PURGDT S PURGDT=$$FMADD^XLFDT(START,365.24*2+1\1)
 S ^XTMP(XTMPS,0)=PURGDT_U_START_U_"Associated Patches Holding Area"
 ;
 ; Here we add our dependents if they are there
 N FDA,DIERR
 N I F I=1:1 Q:'$D(TXTINFO("PREREQ",I))  D
 . ; 1. Check that the destination patch exists (the dependent)
 . I $D(^A1AE(11005,"B",TXTINFO("PREREQ",I))) D
 .. N SUBIENS S SUBIENS="+"_I_","_IENS
 .. S FDA(11005.09,SUBIENS,.01)=TXTINFO("PREREQ",I)
 .. S FDA(11005.09,SUBIENS,2)=TXTINFO("PREREQ",I,"v")
 .. K ^XTMP(XTMPS,DESIGNATION,TXTINFO("PREREQ",I))
 .. K ^XTMP(XTMPS,"B",TXTINFO("PREREQ",I),DESIGNATION)
 . E  D  ; 2. If it doesn't exist, put in ^XTMP
 .. S ^XTMP(XTMPS,DESIGNATION,TXTINFO("PREREQ",I))=TXTINFO("PREREQ",I,"v")
 .. S ^XTMP(XTMPS,"B",TXTINFO("PREREQ",I),DESIGNATION)=""
 ; 3. File if we have located dependencies already in the patch file
 D:$D(FDA) UPDATE^DIE("E",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 ; Here we add ourselves if you find 
 ; If previously in ^XTMP, then we have a previously loaded patch
 ; that does not have dependencies resolved.
 N US S US=DESIGNATION
 N THEM S THEM=""
 F  S THEM=$O(^XTMP(XTMPS,"B",US,THEM)) Q:THEM=""  D
 . N FDA,DIERR
 . N PATCHIEN S PATCHIEN=$O(^A1AE(11005,"B",THEM,"")) ; get parent ien
 . N SUBIENS S SUBIENS="+"_1_","_PATCHIEN_","                        ; prep to add
 . S FDA(11005.09,SUBIENS,.01)=US
 . S FDA(11005.09,SUBIENS,2)=^XTMP(XTMPS,THEM,US)
 . K ^XTMP(XTMPS,THEM,US)
 . K ^XTMP(XTMPS,"B",US,THEM)
 . D:$D(FDA) UPDATE^DIE("E",$NA(FDA))
 . I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 ; 11. file sequence # for FOIA patches
 ;
 ; Sequence number
 ; (only for VA patches and real patches not package releases)
 N FDA,DIERR
 I STREAM=1,$P(DESIGNATION,"*",3)'=0 D  ; only for VA patches
 . S FDA(11005,IENS,"SEQUENTIAL RELEASE NUMBER")=TXTINFO("SEQ")
 I $D(FDA) D
 . D FILE^DIE("E",$NA(FDA))
 I $D(DIERR) D
 . S $EC=",U-FILEMAN-ERROR,"
 ;
 LOCK -^A1AE(11005,DA) ; unlock new patch record
 QUIT DA
 ;
 ;
LDKID(PATCHMSG,DA,KIDMISSING) ; create patch payload
 ; Private to package
 ; Load KIDS into 11005.1/11005.5
 ; new code
 I KIDMISSING Q  ; if no kids file found:
 ; old code
 ; I KIDMISSING D  Q  ; if no kids file found:
 ; D HFS2^A1AEM1(DA) ; nb: deletes 2 node (field 20) on 11005.1
 ;
 ; We have a KIDS file
 ; FND+19  ; Type of message is KIDS not DIFROM:
 S $P(^A1AE(11005.1,DA,0),U,11)="K"
 ; TRASH+7 ; remove old KIDS build:
 K ^A1AE(11005.1,DA,2)
 ; FND+23  ; Load the new one in:
 MERGE ^A1AE(11005.1,DA,2)=@PATCHMSG
 ; DATE PATCH FIRST ENTERED (#12):
 N DEVDATE S DEVDATE=$P(^A1AE(11005,DA,0),U,12)
 ; FND+29  ; ditto:
 S $P(^A1AE(11005.1,DA,2,0),U,5)=DEVDATE
 ; FND+30  ; Message IEN; We didn't load this from Mailman:
 S $P(^A1AE(11005.1,DA,2,0),U,2)=""
 ; FND+31  ; Message date; ditto:
 S $P(^A1AE(11005.1,DA,2,0),U,3)=""
 ; FND+32  ; Load routine info into 11005 from kids msg:
 D RTNBLD^A1AEM1(DA)
 ; FND+34  ; if load kids get rid of hfs "shadow" copy:
 I $D(^A1AE(11005.5,DA,0)) D
 . N DIK S DIK="^A1AE(11005.5,"
 . D ^DIK
 ;
 QUIT
 ;
 ;
ASSERT(X,Y) ; assertion engine
 ;
 ; ZEXCEPT: %ut - Newed on a lower level of the stack if using M-Unit
 I $D(%ut) D  Q
 . D CHKTF^%ut(X,$G(Y)) ; assert using that engine
 I 'X D  ; otherwise
 . D EN^DDIOL($G(Y)) S:+$H=63703 ^TMP("MHERR")=$G(Y)
 . S $EC=",U-ASSERTION-ERROR,"
 ;
 QUIT
