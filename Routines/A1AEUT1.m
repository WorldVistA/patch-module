A1AEUT1 ;ven/smh-unit tests for the patch module ;2015-07-17  7:49 PM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;
 ; Change History:
 ;
 ; 2014 01 22: Sam Habiel of the VISTA Expertise Network (VEN/SMH)
 ; developed this routine throughout January 2014, with this date
 ; being his most recent edit.
 ;
 ; 2014 02 25: Rick Marshall of the VISTA Expertise Network (VEN/TOAD)
 ; edited MKSTREAM to use the new standardized name for patch stream
 ; OSEHRA VISTA, set field Abbreviation (.05) to OV, to change
 ; field 2 with field .02, comment with field names, and change from
 ; index PRIM to APRIM. In PATCHVER, fix bug by replacing hardcoded 1
 ; with DA.
 ;
 ; NB: Order matters here. Each test depends on the one before it.
 ; TODO:
 ; 1. Write a Unit Test to check for the presence of the checksums
 ;    after a patch is verified in the stream file routine multiple.
 D EN^%ut($T(+0),1,1) QUIT
 ;
STARTUP ; Delete all test data
 N DIK,DA ; fur Fileman
 S DUZ=.5 ; Must be defined for auditing.
 N PKGAB S PKGAB="ZZZ"
 ; Get entry from package file if it exists.
 N PKIEN S PKIEN=$O(^DIC(9.4,"C",PKGAB,0))
 ; If package is there, delete everything that belongs to it
 I PKIEN D 
 . S DA="" F  S DA=$O(^A1AE(11005,"D",PKIEN,DA)) Q:'DA  D
 . . F DIK="^A1AE(11005,","^A1AE(11005.1," D ^DIK  ; PM Patch and Message files
 . S DIK="^A1AE(11007,",DA=PKIEN D ^DIK  ; PM Package File
 . S DIK="^DIC(9.4,",DA=PKIEN D ^DIK  ; Package file
 ;
 ; Delete the Stream Entries.
 QUIT:$$PROD^XUPROD()
 S DIK="^A1AE(11007.1," S DA=0 F  S DA=$O(^A1AE(11007.1,DA)) Q:'DA  D ^DIK
 ;
 QUIT
 ;
SHUTDOWN ; but don't delete test data here. I want to see it.
 ; ZEXCEPT: %ut,%utLIST - belong to M-Unit and are scoped there.
 D
 . N %ut,%utLIST
 . D KILL^XUSCLEAN
 QUIT
 ;
SETUP ;
 QUIT
 ;
TEARDOWN ;
 QUIT
 ;
MKSTREAM ; @TEST Make OSEHRA Stream
 N % S %=$$PRIMSTRM^A1AEUTL()
 D ASSERT(%<10**6+1,"No primary stream should give us 1m+1")
 D ASSERT($D(^A1AE(11007.1,1,0)),"VA Stream should be created by default")
 ;
 ; Quit if you are on production
 I $$PROD^XUPROD() QUIT
 ;
 ; Create OSEHRA Patch Stream
 N FDA,IENS,IEN
 S IENS="+1,"
 S IEN(1)=10001 ; field Patch Number Start (.001)
 S FDA(11007.1,IENS,.01)="OSEHRA VISTA" ; Name
 S FDA(11007.1,IENS,.02)="YES" ; Primary?
 S FDA(11007.1,IENS,.05)="OV" ; Abbreviation
 N DIERR,ERR
 D UPDATE^DIE("E",$NA(FDA),$NA(IEN),$NA(ERR))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 ; OSEHRA Patch stream is now primary
 N % S %=$$PRIMSTRM^A1AEUTL()
 D CHKEQ(%,10001)
 ;
 ; Get the old primary stream
 N OLDPRIM S OLDPRIM=$O(^A1AE(11007.1,"APRIM",1,""))
 I 'OLDPRIM S OLDPRIM=1
 ;
 ; Make VA patch stream primary then switch back. Test APRIM1 xref logic.
 N DA,DIE,DR S DA=1,DIE="^A1AE(11007.1,",DR=".02///1" D ^DIE
 D CHKEQ($$PRIMSTRM^A1AEUTL(),1)
 ;
 N DA,DIE,DR S DA=OLDPRIM,DIE="^A1AE(11007.1,",DR=".02///1" D ^DIE
 D CHKEQ($$PRIMSTRM^A1AEUTL(),10001)
 QUIT
 ;
MKPKGTST ; @TEST Make Package in Package (#9.4) File
 ; ZEXCEPT: PKIEN - leak to the symbol table
 S PKIEN=$$MKPKG()
 D ASSERT(PKIEN)
 QUIT
 ;
MKPKG() ; Create a new package
 N FDA,IEN,DIERR
 S FDA(9.4,"+1,",.01)="TEST PACKAGE"
 S FDA(9.4,"+1,",1)="ZZZ"
 S FDA(9.4,"+1,",2)="Used for testing the Patch Module"
 S FDA(9.49,"+2,+1,",.01)="1.0" ; version number
 D UPDATE^DIE("E","FDA","IEN")
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 QUIT IEN(1)
 ;
MKUSRTST ; @TEST Make Users in NEW PERSON (#200) File
 ; ZEXCEPT: DEV,COM,VER,USR - Create these here and leak to the ST
 S DUZ(0)="@" ; Necessary for the keys multiple which checks this in the Input Transform
 D DELUSR("PATCHMODULE,DEVELOPER")
 D DELUSR("PATCHMODULE,COMPLETER")
 D DELUSR("PATCHMODULE,VERIFER")
 D DELUSR("PATCHMODULE,USER")
 ;
 S DEV=$$MKUSR("PATCHMODULE,DEVELOPER","A1AE DEVELOPER")
 S COM=$$MKUSR("PATCHMODULE,COMPLETER","A1AE DEVELOPER")
 S VER=$$MKUSR("PATCHMODULE,VERIFER","A1AE PHVER")
 S USR=$$MKUSR("PATCHMODULE,USER")
 S DUZ(0)=""
 ;
 ; Assert the user IEN, the presence of an access code, the presence of a mail box
 D ASSERT(DEV),ASSERT($L($P(^VA(200,DEV,0),U,3))),ASSERT($D(^XMB(3.7,DEV,0)))
 D ASSERT(COM),ASSERT($L($P(^VA(200,COM,0),U,3))),ASSERT($D(^XMB(3.7,COM,0)))
 D ASSERT(VER),ASSERT($L($P(^VA(200,VER,0),U,3))),ASSERT($D(^XMB(3.7,VER,0)))
 D ASSERT(USR),ASSERT($L($P(^VA(200,USR,0),U,3))),ASSERT($D(^XMB(3.7,USR,0)))
 ;
 QUIT
 ;
DELUSR(NAME) ; Remove user and their mailbox
 N DA S DA=$O(^VA(200,"B",NAME,0)) Q:'DA
 S DUZ=.5 D TERMMBOX^XMXAPIB(DA) ; DUZ must be .5 for this to work
 N DIK S DIK="^VA(200," D ^DIK
 QUIT
 ;
MKUSR(NAME,KEY) ; Make Users for the Package
 Q:$O(^VA(200,"B",NAME,0)) $O(^(0)) ; Quit if the entry exists with entry
 ;
 N C0XFDA,C0XIEN,C0XERR,DIERR
 S C0XFDA(200,"?+1,",.01)=NAME ; Name
 S C0XFDA(200,"?+1,",1)="USP" ; Initials
 S C0XFDA(200,"?+1,",28)="SMART" ; Mail Code
 S C0XFDA(200.05,"?+2,?+1,",.01)="`144" ; Person Class - Allopathic docs.
 S C0XFDA(200.05,"?+2,?+1,",2)=2700101 ; Date active
 S:$L($G(KEY)) C0XFDA(200.051,"?+3,?+1,",.01)="`"_$O(^DIC(19.1,"B",KEY,""))
 ;
 N DIC S DIC(0)="" ; An XREF in File 200 requires this.
 D UPDATE^DIE("E",$NA(C0XFDA),$NA(C0XIEN),$NA(C0XERR)) ; Typical UPDATE
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 K C0XFDA
 S C0XFDA(200,C0XIEN(1)_",",2)=$TR(NAME,",",".") ; Access Code
 D FILE^DIE("",$NA(C0XFDA),$NA(C0XERR))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 I $D(^XMB(3.7,C0XIEN(1),0))[0 N Y S Y=C0XIEN(1) D NEW^XM ;Make sure has a Mailbox
 ;
 Q C0XIEN(1) ;Provider IEN ;
 ;
PKGADD ; @TEST - Add package to Patch Module
 ; ZEXCEPT: A1AEPK,A1AEPKIF,A1AEPKNM - Created by PKG^A1AEUTL
 N A1AE S A1AE(0)="ML" ; Multiple indexes/Laygo
 N X S X="ZZZ" ; Input to ^DIC
 D PKG^A1AEUTL
 D CHKEQ(A1AEPK,"ZZZ") ; PK abbr is ZZZ
 D ASSERT(A1AEPKIF) ; Must be positive
 QUIT
 ;
PKGSETUP ; @TEST Setup package in Patch module
 ; ZEXCEPT: A1AEPKIF - Created by PKGADD
 ; ZEXCEPT: VER,DEV,COM,USR - Created by MKUSRTST
 N IENS S IENS=A1AEPKIF_","
 N FDA,DIERR
 S FDA(11007,IENS,2)="NO" ; USER SELECTION PERMITTED//^S X="NO"
 S FDA(11007,IENS,4)="NO" ; FOR TEST SITE ONLY?//^S X="NO"
 S FDA(11007,IENS,5)="YES" ; ASK PATCH DESCRIPTION COPY
 D FILE^DIE("EKT",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 S FDA(11007.02,"+1,"_IENS,.01)="`"_VER  ; SUPPORT PERSONNEL
 S FDA(11007.02,"+1,"_IENS,2)="V"  ; VERIFY PERSONNEL
 S FDA(11007.03,"+2,"_IENS,.01)="`"_DEV ; DEVELOPMENT PERSONNEL
 S FDA(11007.03,"+3,"_IENS,.01)="`"_COM ; DITTO
 S FDA(11007.05,"+4,"_IENS,.01)="`"_USR ; USERS
 S FDA(11007.05,"+4,"_IENS,2)="T" ; Today
 D UPDATE^DIE("E",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 D ASSERT($D(^A1AE(11007,A1AEPKIF,"PB")))  ; Verifier Nodes
 D ASSERT($D(^A1AE(11007,A1AEPKIF,"PH")))  ; Developer Nodes
 QUIT
 ;
VERSETUP ; @TEST Setup version
 ; ZEXCEPT: A1AEPKIF - Created by PKGADD
 ; ZEXCEPT: A1AEVR - Created here by VER^A1AEUTL
 N X,A1AE S A1AE(0)="L",X=1 ; X is version number; input to ^DIC
 D VER^A1AEUTL
 D CHKEQ(A1AEVR,1)
 D ASSERT($D(^A1AE(11007,A1AEPKIF,"V",1,0)))
 QUIT
 ;
DELMSGS ; @TEST Delete all Messages in Q-PATCH basket.
 N XMDUZ,XMK,XMZ
 S XMDUZ=.5
 N % S %=$O(^XMB(3.7,.5,2,"B","Q-PATCH"))
 S XMK=$O(^XMB(3.7,.5,2,"B",%,0))
 S XMZ=0 F  S XMZ=$O(^XMB(3.7,.5,2,XMK,1,XMZ)) Q:'XMZ  D KL^XMA1B
 D ASSERT($O(^XMB(3.7,.5,2,XMK,1,0))="")
 QUIT
 ;
MAILKIDS ; @TEST Mail a KIDS build to XXX@Q-PATCH.OSEHRA.ORG
 ; ZEXCEPT: MESSAGEIEN - Leak to symbol table
 ; ZEXCEPT: A1AEUT1PD - Used by this routine. Overrides default patch name for UT checks.
 N MESS,LN0,LN
 N I F I=1:1 S LN0=$T(KIDS+I^A1AEUT2),LN=$P(LN0,";;",2,99) S MESS(I,0)=LN Q:LN["$END KID"
 N FLAGS S FLAGS("TYPE")="K" ; KIDS
 S DUZ=.5
 N PD S PD=$G(A1AEUT1PD,"ZZZ*1.0*1")
 D SENDMSG^XMXAPI(DUZ,PD,$NA(MESS),"XXX@Q-PATCH.OSEHRA.ORG",.FLAGS,.MESSAGEIEN)
 D ASSERT(MESSAGEIEN)
 QUIT
 ;
QUE ; @TEST Get Postmaster Basket for Q-PATCH in variable QUE.
 ; ZEXCEPT: QUE
 D QUE^A1AEM
 D ASSERT(QUE>1000) ; Assert that it is a forwarding que in the Postmaster basket.
 QUIT
 ;
PATCHNO ; @TEST Obtain next patch number
 ; Next two lines required by API.
 ; ZEXCEPT: A1AENB - Created by NUM^A1AEUTL
 ; ZEXCEPT: A1AEUT1PN - Used by this Unit Testing routine to override default patch no
 ; ZEXCEPT: DEV,COM,VER,USR
 ; ZEXCEPT: A1AEPD - Created by PKGADD
 ; ZEXCEPT: A1AESTREAM - Gets the stream used in NUM^A1AEUTL.
 N A1AEFL,A1AETY
 S A1AEFL=11005,A1AETY="PH"
 S A1AESTREAM=$$PRIMSTRM^A1AEUTL()
 S DUZ=DEV
 N DIC,DINUM
 S DIC("S")="I $D(^A1AE(11007,+Y,A1AETY,DUZ,0))"
 S DINUM=$O(^A1AE(A1AEFL," "),-1)+1
 S DIC("DR")="5///TEST"
 S DIC(0)="L"
 D NUM^A1AEUTL
 N PATNUMTOCHECK S PATNUMTOCHECK=$S(A1AESTREAM>1:A1AESTREAM+1,1:A1AESTREAM) ; cuz first patch now is switch patch; next patch is the new one.
 I $D(A1AEUT1PN) S A1AEUT1PN=$S(A1AESTREAM>1:A1AEUT1PN+1,1:A1AEUT1PN)
 D CHKEQ(A1AENB,$G(A1AEUT1PN,PATNUMTOCHECK))
 D ASSERT(A1AEPD["ZZZ*1")
 D ASSERT($D(^A1AE(11005,"D",A1AEPKIF)))
 QUIT
 ;
PATCHSET ; @TEST Set-Up patch a la 1+3^A1AEPH1
 ; ZEXCEPT: DA - leaked by NUM^A1AEUTL
 ; ZEXCEPT: A1AEPKIF,A1AEVR,A1AENB
 S $P(^A1AE(11005,DA,0),"^",8)="u"
 S $P(^(0),"^",9)=DUZ
 S $P(^(0),"^",12)=DT
 S ^A1AE(11005,"AS",A1AEPKIF,A1AEVR,"u",A1AENB,DA)=""
 N FDA,DIERR S FDA(11005,DA_",",.2)=$$GETSTRM^A1AEK2M0(A1AEPD)
 D FILE^DIE("",$NA(FDA)) I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 D CHKEQ($$GET1^DIQ(11005,DA,8),"UNDER DEVELOPMENT")
 QUIT
 ;
PATCHROU ; @TEST Add routine set in Message file a la 1+5^A1AEPH1
 ; NB: There is an error here. You MUST LEAK the DIC(0) variable as it is reused from a previous call.
 ; ZEXCEPT: DA - leaked by NUM^A1AEUTL
 NEW DIC,X,DINUM,DD,DO,DE,DQ,DR
 S DIC(0)="L"
 S (X,DINUM)=DA,DIC="^A1AE(11005.1,",DIC("DR")="20///"_"No routines included" K DD,DO D FILE^DICN K DE,DQ,DR,DIC("DR")
 D CHKEQ(^A1AE(11005.1,DA,2,1,0),"No routines included")
 QUIT
 ;
 ;
LOC ; @TEST Get messages matching A1AEPD in Q-PATCH queue in variable A1AERD
 ; ZEXCEPT: A1AEPD,A1AERD,A1AEUT1PD - patch description, return variable
 D LOC^A1AEM
 D ASSERT(A1AERD(1)[$G(A1AEUT1PD,"ZZZ*1.0*1"))
 QUIT
 ;
PATCHCR ; @TEST Create a Patch
 ; ZEXCEPT: DA - leaked by NUM^A1AEUTL
 ; ZEXCEPT: MESSAGEIEN - leaked by MAILKIDS
 N FDA,IENS
 N DIERR
 S IENS=DA_","
 S FDA(11005,IENS,"PATCH SUBJECT")="TEST"
 S FDA(11005,IENS,"PRIORITY")="e" ; emergency
 D FILE^DIE("E",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 K FDA
 ;
 ; Category of patch
 S FDA(11005.05,"+1,"_IENS,.01)="d"
 S FDA(11005.05,"+2,"_IENS,.01)="i"
 S FDA(11005.05,"+3,"_IENS,.01)="p"
 S FDA(11005.05,"+4,"_IENS,.01)="r"
 D UPDATE^DIE("",$NA(FDA)) ; NB: Internal format b/c some codes won't parse with external as e.g there is d and dd.
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 K FDA
 ;
 ; This loads the message text into field PATCH DESCRIPTION in 11005
 N A1AELINE ; returned by LINE^A1AECOPD
 N X,AXMZ ; X - User Input; AXMZ = Patch Message IEN
 S AXMZ=MESSAGEIEN,X="ALL" D LINESIL^A1AECOPD ; Returns A1AELINE: # of lines.
 ;
 N A1AEFRLN,A1AETOLN S A1AEFRLN=1,A1AETOLN=A1AELINE ; from to 
 D SETUTI^A1AECOPD ; Set util global
 D ASSERT($O(^UTILITY($J,"A1AECP",0))>0)
 N A1AELNIN,A1AEBOT S A1AELNIN=0,A1AEBOT=0 ; necessary for below
 D COPY^A1AECOPD ; copy into patch description
 D ASSERT($O(^A1AE(11005,DA,"D",0))>0) ; Assert that it was copied into PATCH DESCRIPTION
 ;
 ; This loads the KIDS build from either the Mail Message or the File System.
 ; Stores it in MESSAGE TEXT in file 11005.1. Template does a Backwards Jump.
 ; ZEXCEPT: A1AEKIDS - ASKS^A1AEM1 leaks that when it detects the the Mail message type is a KIDS message.
 D ASKS^A1AEM1
 D ASSERT($O(^A1AE(11005.1,DA,2,0))>0)
 D ASSERT(^A1AE(11005,DA,"P",1,0)="ZOSV2GTM^B7008460^**275,425**")
 ;
 ; Because ^A1AECOPY and ^A1AECOPR both reference Packman
 ; formats in SETUTI, it's most likely that Wally intended for us to skip this.
 ; ^A1AECOPY uses Cache's ZLOAD.
 ; 
 ; ROUTINE NAME
 ;    ROUTINE NAME
 ;    W !?20,"editing DESCRIPTION OF ROUTINE CHANGES"
 ;    D ^A1AECOPY
 ;    D ^A1AECOPR
 ;    DESCRIPTION OF ROUTINE CHANGES
 ;    ROUTINE CHECKSUM
 ; @8
 S FDA(11005,IENS,"DISPLAY ROUTINE PATCH LIST")="Yes"
 N DIERR
 D FILE^DIE("E",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ;
 N WP
 S WP(1,0)="Test Comments"
 N DIERR
 D WP^DIE(11005,IENS,16,"K",$NA(WP))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 ; PATCH RELEASE CHECK
 ;    ALL
 ; W !
 ; @10
 ; ZEXCEPT: A1AETVR,A1AEST - Copied from Input Template. I don't have a clue what these do now.
 K A1AETVR,A1AEST,A1AEKIDS
 D CHKEQ(^A1AE(11005,DA,"X",1,0),"Test Comments")
 D CHKEQ(^A1AE(11005,DA,5),1)
 QUIT
 ; STATUS OF PATCH
 ; S Y=$S(X="e":"@20",X="r":"@30",1:"@99")
 ; @20
 ; ENTERED IN ERROR DESCRIPTION
 ; S Y="@99"
 ; @30
 ; RETIRED AFTER VERSION
 ; RETIREMENT COMMENTS
 ; @99
 ;
PATCHCOM ; @TEST Complete a Patch
 ; ZEXCEPT: COM - Created by MKUSRTST
 ; ZEXCEPT: A1AEPD - Created by PKGADD
 ; ZEXCEPT: DA - leaked by NUM^A1AEUTL
 S DUZ=COM ; Now I am the completer
 N A1AEPDSAV S A1AEPDSAV=A1AEPD
 N FDA
 S FDA(11005,DA_",",8)="c" D FILE^DIE("E",$NA(FDA))
 D CHKEQ($P(^A1AE(11005,DA,0),U,8),"c")
 S A1AEPD=A1AEPDSAV
 QUIT
 ;
PATCHVER ; @TEST Verify a Patch
 ; ZEXCEPT: DA - leaked by NUM^A1AEUTL
 ; ZEXCEPT: VER - Created by MKUSRTST
 S DUZ=VER ; Now I am the verifier
 N FDA
 S FDA(11005,DA_",",8)="v" D FILE^DIE("E",$NA(FDA))
 D CHKEQ($P(^A1AE(11005,DA,0),U,8),"v")
 QUIT
 ;
PATCH2 ; @TEST Create a second patch - complete this one
 N DIC
 D PKGADD,VERSETUP
 N A1AEUT1PD S A1AEUT1PD="ZZZ*1.0*2" ; override patch in mail kids
 D MAILKIDS
 D QUE
 N A1AEUT1PN S A1AEUT1PN=$$PRIMSTRM^A1AEUTL()+1 ; override patch number
 D PATCHNO,PATCHSET,PATCHROU
 D LOC
 D PATCHCR
 D PATCHCOM
 QUIT
 ;
PATCH3 ; @TEST Create a third patch - don't complete or verify
 N DIC
 D PKGADD,VERSETUP
 N A1AEUT1PD S A1AEUT1PD="ZZZ*1.0*3" ; override patch in mail kids
 D MAILKIDS
 D QUE
 N A1AEUT1PN S A1AEUT1PN=$$PRIMSTRM^A1AEUTL()+2 ; override patch number
 D PATCHNO,PATCHSET,PATCHROU
 D LOC
 D PATCHCR
 QUIT
 ;
WRITEID ; @TEST Test write identifier on the Patch Module
 D FIND^DIC(11005,,"@;WID","PQ","ZZZ","B") ; Find ZZZ patches in B index
 D ASSERT(^TMP("DILIST",$J,1,0)["|")  ; This format is introduced with patch module 2.4 if DIQUIET is turned on.
 N P1IEN S P1IEN=+^TMP("DILIST",$J,1,0) ; 1st IEN
 N P2IEN S P2IEN=+^TMP("DILIST",$J,2,0) ; 2nd IEN
 N FDA S FDA(11005,P2IEN_",","DERIVED FROM PATCH")=P1IEN ; populate this
 D FILE^DIE("",$NA(FDA)) ; ditto
 D FIND^DIC(11005,,"@;WID","A",P2IEN) ; A = Use IEN for lookup
 D ASSERT(^TMP("DILIST",$J,"ID","WRITE",1,2)["erived from") ; Contains derived from...
 QUIT
 ;
A1AEPH25 ; @TEST Test Report 5^A1AEPH2
 ; ZEXCEPT: DEV - Created by MKUSRTST
 S DUZ=DEV
 N %ZIS
 N DIC
 D PKGADD,VERSETUP
 N A1AEREV S A1AEREV=1
 N A1AEDEV S A1AEDEV="HFS;80;99999"
 S %ZIS("HFSMODE")="W"
 S %ZIS("HFSNAME")="A1AEPH25.TXT"
 D DQ5^A1AEPH2
 ;
 ; Read it back now
 N POP
 D OPEN^%ZISH("FILE1",$$DEFDIR^%ZISH(),"A1AEPH25.TXT","R")
 I POP D FAIL^%ut("IO problems") QUIT
 U IO
 N ARR,CNT
 S CNT=1
 N X
 F  R X:1 Q:$$STATUS^%ZISH()  I $E(X,1,3)="ZZZ" S ARR(CNT)=X,CNT=CNT+1
 U $P D CLOSE^%ZISH("FILE1")
 D ASSERT($D(ARR))
 N % S %("A1AEPH25.TXT")=""
 S %=$$DEL^%ZISH($$DEFDIR^%ZISH(),$NA(%))
 QUIT
 ;
A1AEPH21 ; @TEST Test Report 1^A1AEPH2
 ; ZEXCEPT: DEV - Created by MKUSRTST
 ; Index: AB - By designation
 ; Index: AC - By category
 ; Index: AP - By priority
 ; Index: AS - By Status
 N A1AEHD ; Header - used below
 N A1AEIX F A1AEIX="AB","AC","AP","AS" D
 . S DUZ=DEV
 . N DIC,DIS
 . D PKGADD,VERSETUP
 . N A1AES ; Suppress asking for sorting by status
 . S DIS(0)="I $P(^A1AE(11005,D0,0),U,8)=""c""",A1AEHD="Completed/NotReleased DHCP Patches Report",A1AES=""
 . N A1AEHDSAV S A1AEHDSAV=A1AEHD ; HD is killed off
 . S DIC("S")="I $S($D(^A1AE(11007,+Y,""PH"",DUZ,0)):1,'$D(^A1AE(11007,+Y,""PB"",DUZ,0)):0,$P(^(0),U,2)=""V"":1,1:0)"
 . N FN S FN="A1AEPH21-"_A1AEIX_".TXT"
 . N POP
 . D OPEN^%ZISH("FILE1",$$DEFDIR^%ZISH(),FN,"W")
 . I POP D FAIL^%ut("IO problems") QUIT
 . D START^A1AEPH3
 . D CLOSE^%ZISH("FILE1")
 . D OPEN^%ZISH("FILE1",$$DEFDIR^%ZISH(),FN,"R")
 . I POP D FAIL^%ut("IO problems") QUIT
 . U IO
 . N X F  R X:0 Q:$$STATUS^%ZISH()  Q:X[A1AEHDSAV
 . U $P D CLOSE^%ZISH("FILE1")
 . D ASSERT(X[A1AEHDSAV)
 . N % S %(FN)="",%=$$DEL^%ZISH($$DEFDIR^%ZISH(),$NA(%))
 QUIT
 ;
 ; Convenience Methods for M-Unit
CHKEQ(X,Y,Z) S Z=$G(Z) D CHKEQ^%ut(X,Y,Z) QUIT
ASSERT(X,Y) S Y=$G(Y) D CHKTF^%ut(X,Y) QUIT
FAIL(X) S X=$G(X) D FAIL^%ut(X) QUIT
 ;
