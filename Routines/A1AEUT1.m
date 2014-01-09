A1AEUT1 ; VEN/SMH - Unit Tests for the Patch Module;2014-01-08  8:00 PM
 ;;
 ; NB: Order matters here. Each test depends on the one before it.
 D EN^XTMUNIT($T(+0),1) QUIT
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
 . . F DIK="^A1AE(11005,","^A1AE(11005.1," D ^DIK  ; PM Patch and Message files: Prob w/ Message file now.
 . S DIK="^A1AE(11007,",DA=PKIEN D ^DIK  ; PM Package File
 . S DIK="^DIC(9.4,",DA=PKIEN D ^DIK  ; Package file
 ;
 QUIT
 ;
SHUTDOWN ; but don't delete test data here. I want to see it.
 K (DUZ,IO,XTMUNIT,XTMULIST)
 QUIT

SETUP ;
 QUIT

TEARDOWN ;
 QUIT

MKPKGTST ; @TEST Make Package in Package (#9.4) File
 S PKIEN=$$MKPKG()
 D ASSERT(PKIEN)
 QUIT
 ;
MKPKG() ; Create a new package
 N FDA,IEN,DIERR
 S FDA(9.4,"+1,",.01)="TEST PACKAGE"
 S FDA(9.4,"+1,",1)="ZZZ"
 S FDA(9.4,"+1,",2)="Used for testing the Patch Module"
 D UPDATE^DIE("E","FDA","IEN")
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 QUIT IEN(1)
 ;
MKUSRTST ; @TEST Make Users in NEW PERSON (#200) File
 S DUZ(0)="@" ; Necessary for the keys multiple which checks this in the Input Transform
 D DELUSR("PATCHMODULE,DEVELOPER")
 D DELUSR("PATCHMODULE,COMPLETER")
 D DELUSR("PATCHMODULE,VERIFER")

 S DEV=$$MKUSR("PATCHMODULE,DEVELOPER","A1AE DEVELOPER")
 S COM=$$MKUSR("PATCHMODULE,COMPLETER","A1AE DEVELOPER")
 S VER=$$MKUSR("PATCHMODULE,VERIFER","A1AE PHVER")
 S DUZ(0)=""
 ;
 ; Assert the user IEN, the presence of an access code, the presence of a mail box
 D ASSERT(DEV),ASSERT($L($P(^VA(200,DEV,0),U,3))),ASSERT($D(^XMB(3.7,DEV,0)))
 D ASSERT(COM),ASSERT($L($P(^VA(200,COM,0),U,3))),ASSERT($D(^XMB(3.7,COM,0)))
 D ASSERT(VER),ASSERT($L($P(^VA(200,VER,0),U,3))),ASSERT($D(^XMB(3.7,VER,0)))
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
 S C0XFDA(200.051,"?+3,?+1,",.01)="`"_$O(^DIC(19.1,"B",KEY,""))
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
 N A1AE S A1AE(0)="ML" ; Multiple indexes/Laygo
 S X="ZZZ" ; Input to ^DIC
 D PKG^A1AEUTL
 D CHKEQ(A1AEPK,"ZZZ") ; PK abbr is ZZZ
 D ASSERT(A1AEPKIF) ; Must be positive
 QUIT
 ;
PKGSETUP ; @TEST Setup package in Patch module
 ; ZEXCEPT: A1AEPKIF
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
 D UPDATE^DIE("E",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 D ASSERT($D(^A1AE(11007,A1AEPKIF,"PB")))  ; Verifier Nodes
 D ASSERT($D(^A1AE(11007,A1AEPKIF,"PH")))  ; Developer Nodes
 QUIT
 ;
VERSETUP ; @TEST Setup version
 ; ZEXCEPT: A1AEPKIF
 S A1AE(0)="L",X=2 ; X is version number; input to ^DIC
 D VER^A1AEUTL
 D CHKEQ(A1AEVR,2)
 D ASSERT($D(^A1AE(11007,A1AEPKIF,"V",2,0)))
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
 N MESS,LN0,LN
 N I F I=1:1 S LN0=$T(KIDS+I),LN=$P(LN0,";;",2,99) S MESS(I,0)=LN Q:LN["$END KID"
 N FLAGS S FLAGS("TYPE")="K"
 S DUZ=.5
 D SENDMSG^XMXAPI(DUZ,"ZZZ*2.0*1",$NA(MESS),"XXX@Q-PATCH.OSEHRA.ORG",.FLAGS,.MESSAGEIEN)
 D ASSERT(MESSAGEIEN)
 QUIT
 ;
QUE ; @TEST Get Postmaster Basket for Q-PATCH in variable QUE.
 D QUE^A1AEM
 D ASSERT(QUE>1000) ; Assert that it is a forwarding que in the Postmaster basket.
 QUIT
 ;
PATCHNO ; @TEST Obtain next patch number
 ; Next two lines required by API.
 N A1AEFL,A1AETY
 S A1AEFL=11005,A1AETY="PH"
 S DUZ=DEV
 S DIC("S")="I $D(^A1AE(11007,+Y,A1AETY,DUZ,0))"
 S DINUM=$O(^A1AE(A1AEFL," "),-1)+1
 S DIC("DR")="5///TEST"
 S DIC(0)="L"
 D NUM^A1AEUTL
 D CHKEQ(A1AENB,1)
 D CHKEQ(A1AEPD,"ZZZ*2*1")
 D ASSERT($D(^A1AE(11005,"D",A1AEPKIF)))
 QUIT
 ;
PATCHSET ; @TEST Set-Up patch a la 1+3^A1AEPH1
 ; ZEXCEPT: DA - leaked by NUM^A1AEUTL
 ; ZEXCEPT: A1AEPKIF, A1AEVR, A1AENB
 S $P(^A1AE(11005,DA,0),"^",8)="u"
 S $P(^(0),"^",9)=DUZ
 S $P(^(0),"^",12)=DT
 S ^A1AE(11005,"AS",A1AEPKIF,A1AEVR,"u",A1AENB,DA)=""
 D CHKEQ($$GET1^DIQ(11005,A1AENB,8),"UNDER DEVELOPMENT")
 QUIT
 ;
PATCHROU ; @TEST Add routine set in Message file a la 1+5^A1AEPH1
 S (X,DINUM)=DA,DIC="^A1AE(11005.1,",DIC("DR")="20///"_"No routines included" K DD,DO D FILE^DICN K DE,DQ,DR,DIC("DR")
 D CHKEQ(^A1AE(11005.1,DA,2,1,0),"No routines included")
 QUIT
 ;
 ;
LOC ; @TEST Get messages matching A1AEPD in Q-PATCH queue
 D LOC^A1AEM
 D ASSERT(A1AERD(1)["ZZZ*2.0*1")
 QUIT
 ;
PATCHCR ; @TEST Create a Patch
 N FDA,IENS
 S IENS=DA_","
 S FDA(11005,IENS,"PATCH SUBJECT")="TEST"
 S FDA(11005,IENS,"PRIORITY")="e" ; emergency
 D FILE^DIE("E",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 K FDA
 ;
 ; Category of patch
 ; S FDA(11005.05,"+1,"_IENS,.01)="d" // won't work. There is also a db.
 ; S FDA(11005.05,"+2,"_IENS,.01)="i" // ditto! inf is also there. Boo!
 ; S FDA(11005.05,"+3,"_IENS,.01)="p" // ditto! pp.
 S FDA(11005.05,"+4,"_IENS,.01)="r"
 D UPDATE^DIE("E",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR,"
 K FDA
 ;
 ; This loads the message text into field PATCH DESCRIPTION in 11005
 ; ZEXPECT A1AELINE
 S AXMZ=MESSAGEIEN,X="ALL" D LINE+2^A1AECOPD ; Returns A1AELINE: # of lines.
 S A1AEFRLN=1,A1AETOLN=A1AELINE ; from to 
 D SETUTI^A1AECOPD ; Set util global
 D ASSERT($O(^UTILITY($J,"A1AECP",0))>0)
 S A1AELNIN=0,A1AEBOT=0 ; necessary for below
 D COPY^A1AECOPD ; copy into patch description
 D ASSERT($O(^A1AE(11005,DA,"D",0))>0) ; Assert that it was copied into PATCH DESCRIPTION
 ;
 ; This loads the KIDS build from either the Mail Message or the File System.
 ; Stores it in MESSAGE TEXT in file 11005.1. Template does a Backwards Jump.
 D ASKS^A1AEM1
 D ASSERT($O(^A1AE(11005.1,1,2,0))>0)
 D ASSERT(^A1AE(11005,1,"P",1,0)="ZOSV2GTM^B7008460^**275,425**")
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
 K A1AETVR,A1AEST,A1AEKIDS
 D CHKEQ(^A1AE(11005,1,"X",1,0),"Test Comments")
 D CHKEQ(^A1AE(11005,1,5),1)
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
 S DUZ=COM ; Now I am the completer
 N A1AEPDSAV S A1AEPDSAV=A1AEPD
 N FDA
 S FDA(11005,1_",",8)="c" D FILE^DIE("E",$NA(FDA))
 D CHKEQ($P(^A1AE(11005,1,0),U,8),"c")
 S A1AEPD=A1AEPDSAV
 QUIT
 ;
PATCHVER ; @TEST Verify a Patch
 S DUZ=VER ; Now I am the verifier
 N FDA
 S FDA(11005,1_",",8)="v" D FILE^DIE("E",$NA(FDA))
 D CHKEQ($P(^A1AE(11005,1,0),U,8),"v")
 QUIT
 ;
PATCH999 ; #TEST Try to exceed 999
 ; Next two lines required by API.
 N A1AEFL,A1AETY
 S A1AEFL=11005,A1AETY="PH"
 S DUZ=DEV
 S DIC("S")="I $D(^A1AE(11007,+Y,A1AETY,DUZ,0))"
 N CNT S CNT=0
 F  D  Q:(A1AENB>999)  Q:(CNT>1010)
 . S DINUM=$O(^A1AE(A1AEFL," "),-1)+1
 . S DIC("DR")=".001///10;5///TEST"
 . S DIC(0)="L"
 . D NUM^A1AEUTL
 . S CNT=CNT+1
 . I CNT>1010 S $EC=",U-INIFITE-LOOP,"
 D CHKEQ(A1AENB,1000)
 QUIT
 ;
 ; Convenience Methods for M-Unit
CHKEQ(X,Y,Z) S Z=$G(Z) D CHKEQ^XTMUNIT(X,Y,Z) QUIT
ASSERT(X,Y) S Y=$G(Y) D CHKTF^XTMUNIT(X,Y) QUIT
 ;
KIDS ;;
 ;;$TXT Created by TESTMASTER,USER at VEN.SMH101.COM  (KIDS) on Thursday, 01/07/14 at 15:55
 ;;
 ;; This patch is the result of the Unit Test routine.
 ;; Please ignore it.
 ;; 
 ;; Patch ID: ZZZ*2.0*1
 ;; 
 ;;$END TXT
 ;;$KID ZZZ*1.0*1
 ;;**INSTALL NAME**
 ;;ZZZ*1.0*1
 ;;"BLD",9277,0)
 ;;ZZZ*1.0*1^TEST PACKAGE^0^3140102^y
 ;;"BLD",9277,1,0)
 ;;^^1^1^3140102^
 ;;"BLD",9277,1,1,0)
 ;;TEST TEST
 ;;"BLD",9277,4,0)
 ;;^9.64PA^^
 ;;"BLD",9277,6.3)
 ;;2
 ;;"BLD",9277,"KRN",0)
 ;;^9.67PA^779.2^20
 ;;"BLD",9277,"KRN",.4,0)
 ;;.4
 ;;"BLD",9277,"KRN",.401,0)
 ;;.401
 ;;"BLD",9277,"KRN",.402,0)
 ;;.402
 ;;"BLD",9277,"KRN",.403,0)
 ;;.403
 ;;"BLD",9277,"KRN",.5,0)
 ;;.5
 ;;"BLD",9277,"KRN",.84,0)
 ;;.84
 ;;"BLD",9277,"KRN",3.6,0)
 ;;3.6
 ;;"BLD",9277,"KRN",3.8,0)
 ;;3.8
 ;;"BLD",9277,"KRN",9.2,0)
 ;;9.2
 ;;"BLD",9277,"KRN",9.8,0)
 ;;9.8
 ;;"BLD",9277,"KRN",9.8,"NM",0)
 ;;^9.68A^1^1
 ;;"BLD",9277,"KRN",9.8,"NM",1,0)
 ;;ZOSV2GTM^^0^B7008460
 ;;"BLD",9277,"KRN",9.8,"NM","B","ZOSV2GTM",1)
 ;;
 ;;"BLD",9277,"KRN",19,0)
 ;;19
 ;;"BLD",9277,"KRN",19.1,0)
 ;;19.1
 ;;"BLD",9277,"KRN",101,0)
 ;;101
 ;;"BLD",9277,"KRN",409.61,0)
 ;;409.61
 ;;"BLD",9277,"KRN",771,0)
 ;;771
 ;;"BLD",9277,"KRN",779.2,0)
 ;;779.2
 ;;"BLD",9277,"KRN",870,0)
 ;;870
 ;;"BLD",9277,"KRN",8989.51,0)
 ;;8989.51
 ;;"BLD",9277,"KRN",8989.52,0)
 ;;8989.52
 ;;"BLD",9277,"KRN",8994,0)
 ;;8994
 ;;"BLD",9277,"KRN","B",.4,.4)
 ;;
 ;;"BLD",9277,"KRN","B",.401,.401)
 ;;
 ;;"BLD",9277,"KRN","B",.402,.402)
 ;;
 ;;"BLD",9277,"KRN","B",.403,.403)
 ;;
 ;;"BLD",9277,"KRN","B",.5,.5)
 ;;
 ;;"BLD",9277,"KRN","B",.84,.84)
 ;;
 ;;"BLD",9277,"KRN","B",3.6,3.6)
 ;;
 ;;"BLD",9277,"KRN","B",3.8,3.8)
 ;;
 ;;"BLD",9277,"KRN","B",9.2,9.2)
 ;;
 ;;"BLD",9277,"KRN","B",9.8,9.8)
 ;;
 ;;"BLD",9277,"KRN","B",19,19)
 ;;
 ;;"BLD",9277,"KRN","B",19.1,19.1)
 ;;
 ;;"BLD",9277,"KRN","B",101,101)
 ;;
 ;;"BLD",9277,"KRN","B",409.61,409.61)
 ;;
 ;;"BLD",9277,"KRN","B",771,771)
 ;;
 ;;"BLD",9277,"KRN","B",779.2,779.2)
 ;;
 ;;"BLD",9277,"KRN","B",870,870)
 ;;
 ;;"BLD",9277,"KRN","B",8989.51,8989.51)
 ;;
 ;;"BLD",9277,"KRN","B",8989.52,8989.52)
 ;;
 ;;"BLD",9277,"KRN","B",8994,8994)
 ;;
 ;;"BLD",9277,"QUES",0)
 ;;^9.62^^
 ;;"MBREQ")
 ;;0
 ;;"PKG",223,-1)
 ;;1^1
 ;;"PKG",223,0)
 ;;TEST PACKAGE^ZZZ^FOR FORUM
 ;;"PKG",223,22,0)
 ;;^9.49I^1^1
 ;;"PKG",223,22,1,0)
 ;;1.0
 ;;"PKG",223,22,1,"PAH",1,0)
 ;;1^3140102
 ;;"PKG",223,22,1,"PAH",1,1,0)
 ;;^^1^1^3140102
 ;;"PKG",223,22,1,"PAH",1,1,1,0)
 ;;TEST TEST
 ;;"QUES","XPF1",0)
 ;;Y
 ;;"QUES","XPF1","??")
 ;;^D REP^XPDH
 ;;"QUES","XPF1","A")
 ;;Shall I write over your |FLAG| File
 ;;"QUES","XPF1","B")
 ;;YES
 ;;"QUES","XPF1","M")
 ;;D XPF1^XPDIQ
 ;;"QUES","XPF2",0)
 ;;Y
 ;;"QUES","XPF2","??")
 ;;^D DTA^XPDH
 ;;"QUES","XPF2","A")
 ;;Want my data |FLAG| yours
 ;;"QUES","XPF2","B")
 ;;YES
 ;;"QUES","XPF2","M")
 ;;D XPF2^XPDIQ
 ;;"QUES","XPI1",0)
 ;;YO
 ;;"QUES","XPI1","??")
 ;;^D INHIBIT^XPDH
 ;;"QUES","XPI1","A")
 ;;Want KIDS to INHIBIT LOGONs during the install
 ;;"QUES","XPI1","B")
 ;;NO
 ;;"QUES","XPI1","M")
 ;;D XPI1^XPDIQ
 ;;"QUES","XPM1",0)
 ;;PO^VA(200,:EM
 ;;"QUES","XPM1","??")
 ;;^D MG^XPDH
 ;;"QUES","XPM1","A")
 ;;Enter the Coordinator for Mail Group '|FLAG|'
 ;;"QUES","XPM1","B")
 ;;
 ;;"QUES","XPM1","M")
 ;;D XPM1^XPDIQ
 ;;"QUES","XPO1",0)
 ;;Y
 ;;"QUES","XPO1","??")
 ;;^D MENU^XPDH
 ;;"QUES","XPO1","A")
 ;;Want KIDS to Rebuild Menu Trees Upon Completion of Install
 ;;"QUES","XPO1","B")
 ;;NO
 ;;"QUES","XPO1","M")
 ;;D XPO1^XPDIQ
 ;;"QUES","XPZ1",0)
 ;;Y
 ;;"QUES","XPZ1","??")
 ;;^D OPT^XPDH
 ;;"QUES","XPZ1","A")
 ;;Want to DISABLE Scheduled Options, Menu Options, and Protocols
 ;;"QUES","XPZ1","B")
 ;;NO
 ;;"QUES","XPZ1","M")
 ;;D XPZ1^XPDIQ
 ;;"QUES","XPZ2",0)
 ;;Y
 ;;"QUES","XPZ2","??")
 ;;^D RTN^XPDH
 ;;"QUES","XPZ2","A")
 ;;Want to MOVE routines to other CPUs
 ;;"QUES","XPZ2","B")
 ;;NO
 ;;"QUES","XPZ2","M")
 ;;D XPZ2^XPDIQ
 ;;"RTN")
 ;;1
 ;;"RTN","ZOSV2GTM")
 ;;0^1^B7008460
 ;;"RTN","ZOSV2GTM",1,0)
 ;;%ZOSV2 ;ISF/RWF - More GT.M support routines ;10/18/06  14:29
 ;;"RTN","ZOSV2GTM",2,0)
 ;; ;;8.0;KERNEL;**275,425**;Jul 10, 1995;Build 2
 ;;"RTN","ZOSV2GTM",3,0)
 ;; Q
 ;;"RTN","ZOSV2GTM",4,0)
 ;; ;SAVE: DIE open array reference.
 ;;"RTN","ZOSV2GTM",5,0)
 ;; ;      XCN is the starting value to $O from.
 ;;"RTN","ZOSV2GTM",6,0)
 ;;SAVE(RN) ;Save a routine
 ;;"RTN","ZOSV2GTM",7,0)
 ;; N %,%F,%I,%N,SP,$ETRAP
 ;;"RTN","ZOSV2GTM",8,0)
 ;; S $ETRAP="S $ECODE="""" Q"
 ;;"RTN","ZOSV2GTM",9,0)
 ;; S %I=$I,SP=" ",%F=$$RTNDIR^%ZOSV()_$TR(RN,"%","_")_".m"
 ;;"RTN","ZOSV2GTM",10,0)
 ;; O %F:(newversion:noreadonly:blocksize=2048:recordsize=2044) U %F
 ;;"RTN","ZOSV2GTM",11,0)
 ;; F  S XCN=$O(@(DIE_XCN_")")) Q:XCN'>0  S %=@(DIE_XCN_",0)") Q:$E(%,1)="$"  I $E(
 ;;%)'=";" W $P(%,SP)_$C(9)_$P(%,SP,2,99999),!
 ;;"RTN","ZOSV2GTM",12,0)
 ;; C %F ;S %N=$$NULL
 ;;"RTN","ZOSV2GTM",13,0)
 ;; ZLINK RN
 ;;"RTN","ZOSV2GTM",14,0)
 ;; ;C %N
 ;;"RTN","ZOSV2GTM",15,0)
 ;; U %I
 ;;"RTN","ZOSV2GTM",16,0)
 ;; Q
 ;;"RTN","ZOSV2GTM",17,0)
 ;;NULL() ;Open and use null to hide talking.  Return open name
 ;;"RTN","ZOSV2GTM",18,0)
 ;; ;Doesn't work for compile errors
 ;;"RTN","ZOSV2GTM",19,0)
 ;; N %N S %N=$S($ZV["VMS":"NLA0:",1:"/dev/nul")
 ;;"RTN","ZOSV2GTM",20,0)
 ;; O %N U %N
 ;;"RTN","ZOSV2GTM",21,0)
 ;; Q %N
 ;;"RTN","ZOSV2GTM",22,0)
 ;; ;
 ;;"RTN","ZOSV2GTM",23,0)
 ;;DEL(RN) ;Delete a routine file, both source and object.
 ;;"RTN","ZOSV2GTM",24,0)
 ;; N %N,%DIR,%I,$ETRAP
 ;;"RTN","ZOSV2GTM",25,0)
 ;; S $ETRAP="S $ECODE="""" Q"
 ;;"RTN","ZOSV2GTM",26,0)
 ;; S %I=$I,%DIR=$$RTNDIR^%ZOSV,RN=$TR(RN,"%","_")
 ;;"RTN","ZOSV2GTM",27,0)
 ;; I $L($ZSEARCH(%DIR_RN_".m",244)) ZSYSTEM "DEL "_%DIR_X_".m;*"
 ;;"RTN","ZOSV2GTM",28,0)
 ;; I $L($ZSEARCH(%DIR_RN_".obj",244)) ZSYSTEM "DEL "_%DIR_X_".obj;*"
 ;;"RTN","ZOSV2GTM",29,0)
 ;; I $L($ZSEARCH(%DIR_RN_".o",244)) ZSYSTEM "rm -f "_%DIR_X_".o"
 ;;"RTN","ZOSV2GTM",30,0)
 ;; Q
 ;;"RTN","ZOSV2GTM",31,0)
 ;; ;LOAD: DIF open array to receive the routine lines.
 ;;"RTN","ZOSV2GTM",32,0)
 ;; ;      XCNP The starting index -1.
 ;;"RTN","ZOSV2GTM",33,0)
 ;;LOAD(RN) ;Load a routine
 ;;"RTN","ZOSV2GTM",34,0)
 ;; N %
 ;;"RTN","ZOSV2GTM",35,0)
 ;; S %N=0 F XCNP=XCNP+1:1 S %N=%N+1,%=$T(+%N^@RN) Q:$L(%)=0  S @(DIF_XCNP_",0)")=%
 ;;"RTN","ZOSV2GTM",36,0)
 ;; Q
 ;;"RTN","ZOSV2GTM",37,0)
 ;; ;
 ;;"RTN","ZOSV2GTM",38,0)
 ;;LOAD2(RN) ;Load a routine
 ;;"RTN","ZOSV2GTM",39,0)
 ;; N %,%1,%F,%N,$ETRAP
 ;;"RTN","ZOSV2GTM",40,0)
 ;; S %I=$I,%F=$$RTNDIR^%ZOSV()_$TR(RN,"%","_")_".m"
 ;;"RTN","ZOSV2GTM",41,0)
 ;; O %F:(readonly):1 Q:'$T  U %F
 ;;"RTN","ZOSV2GTM",42,0)
 ;; F XCNP=XCNP+1:1 R %1:1 Q:'$T!$ZEOF  S @(DIF_XCNP_",0)")=$TR(%1,$C(9)," ")
 ;;"RTN","ZOSV2GTM",43,0)
 ;; C %F I $L(%I) U %I
 ;;"RTN","ZOSV2GTM",44,0)
 ;; Q
 ;;"RTN","ZOSV2GTM",45,0)
 ;; ;
 ;;"RTN","ZOSV2GTM",46,0)
 ;;RSUM(RN) ;Calculate a RSUM value
 ;;"RTN","ZOSV2GTM",47,0)
 ;; N %,DIF,XCNP,%N,Y,$ETRAP K ^TMP("RSUM",$J)
 ;;"RTN","ZOSV2GTM",48,0)
 ;; S $ETRAP="S $ECODE="""" Q"
 ;;"RTN","ZOSV2GTM",49,0)
 ;; S Y=0,DIF="^TMP(""RSUM"",$J,",XCNP=0 D LOAD2(RN)
 ;;"RTN","ZOSV2GTM",50,0)
 ;; F %=1,3:1 S %1=$G(^TMP("RSUM",$J,%,0)),%3=$F(%1," ") Q:'%3  S %3=$S($E(%1,%3)'=
 ;;";":$L(%1),$E(%1,%3+1)=";":$L(%1),1:%3-2) F %2=1:1:%3 S Y=$A(%1,%2)*%2+Y
 ;;"RTN","ZOSV2GTM",51,0)
 ;; K ^TMP("RSUM",$J)
 ;;"RTN","ZOSV2GTM",52,0)
 ;; Q Y
 ;;"RTN","ZOSV2GTM",53,0)
 ;; ;
 ;;"RTN","ZOSV2GTM",54,0)
 ;;RSUM2(RN) ;Calculate a RSUM2 value
 ;;"RTN","ZOSV2GTM",55,0)
 ;; N %,DIF,XCNP,%N,Y,$ETRAP K ^TMP("RSUM",$J)
 ;;"RTN","ZOSV2GTM",56,0)
 ;; S $ETRAP="S $ECODE="""" Q"
 ;;"RTN","ZOSV2GTM",57,0)
 ;; S Y=0,DIF="^TMP(""RSUM"",$J,",XCNP=0 D LOAD2(RN)
 ;;"RTN","ZOSV2GTM",58,0)
 ;; F %=1,3:1 S %1=$G(^TMP("RSUM",$J,%,0)),%3=$F(%1," ") Q:'%3  S %3=$S($E(%1,%3)'=
 ;;";":$L(%1),$E(%1,%3+1)=";":$L(%1),1:%3-2) F %2=1:1:%3 S Y=$A(%1,%2)*(%2+%)+Y
 ;;"RTN","ZOSV2GTM",59,0)
 ;; K ^TMP("RSUM",$J)
 ;;"RTN","ZOSV2GTM",60,0)
 ;; Q Y
 ;;"RTN","ZOSV2GTM",61,0)
 ;; ;
 ;;"RTN","ZOSV2GTM",62,0)
 ;;TEST(RN) ;Special GT.M Test to see if routine is here.
 ;;"RTN","ZOSV2GTM",63,0)
 ;; N %F,%X
 ;;"RTN","ZOSV2GTM",64,0)
 ;; S %F=$$RTNDIR^%ZOSV()_$TR(RN,"%","_")_".m"
 ;;"RTN","ZOSV2GTM",65,0)
 ;; S %X=$ZSEARCH("X.X",245),%X=$ZSEARCH(%F,245)
 ;;"RTN","ZOSV2GTM",66,0)
 ;; Q %X
 ;;"VER")
 ;;8.0^22.0
 ;;$END KID ZZZ*1.0*1
