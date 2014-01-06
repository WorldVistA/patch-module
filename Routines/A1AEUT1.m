A1AEUT1 ; VEN/SMH - Unit Tests for the Patch Module;2014-01-06  6:41 PM
 ;;
 ; NB: Order matters here. Each test depends on the one before it.
 D EN^XTMUNIT($T(+0),1) QUIT
 ;
STARTUP ; Delete all test data
 N DIK,DA ; fur Fileman
 N PKGAB S PKGAB="ZZZ"
 ; Get entry from package file if it exists.
 N PKIEN S PKIEN=$O(^DIC(9.4,"C",PKGAB,0))
 ; If package is there, delete everything that belongs to it
 I PKIEN D 
 . S DA="" F  S DA=$O(^A1AE(11005,"D",PKIEN,DA)) Q:'DA  D
 . . F DIK="^A1AE(11005,","^A1AE(11005.1" D ^DIK  ; PM Patch and Message files: Prob w/ Message file now.
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

MKPKGTST ; @TEST Make Package
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
MKUSRTST ; @TEST Make Users
 S DEV=$$MKUSR("PATCHMODULE,DEVELOPER","A1AE DEVELOPER")
 S COM=$$MKUSR("PATCHMODULE,COMPLETER","A1AE DEVELOPER")
 S VER=$$MKUSR("PATCHMODULE,VERIFER","A1AE PHVER")
 D ASSERT(DEV)
 D ASSERT(COM)
 D ASSERT(VER)
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
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR"
 ;
 S FDA(11007.02,"+1,"_IENS,.01)="`"_VER  ; SUPPORT PERSONNEL
 S FDA(11007.02,"+1,"_IENS,2)="V"  ; VERIFY PERSONNEL
 S FDA(11007.03,"+2,"_IENS,.01)="`"_DEV ; DEVELOPMENT PERSONNEL
 S FDA(11007.03,"+3,"_IENS,.01)="`"_COM ; DITTO
 D UPDATE^DIE("E",$NA(FDA))
 I $D(DIERR) S $EC=",U-FILEMAN-ERROR"
 D ASSERT($D(^A1AE(11007,A1AEPKIF,"PB")))  ; Verifier Nodes
 D ASSERT($D(^A1AE(11007,A1AEPKIF,"PH")))  ; Developer Nodes
 QUIT
 ;
VERSETUP ; @TEST Setup version
 ; ZEXCEPT: A1AEPKIF
 S A1AE(0)="L",X=2
 D VER^A1AEUTL
 D CHKEQ(A1AEVR,2)
 D ASSERT($D(^A1AE(11007,A1AEPKIF,"V",2,0)))
 QUIT
 ;
 ;
PATCHNO ; @TEST Obtain next patch number
 ; Next two lines required by API.
 N A1AEFL,A1AETY
 S A1AEFL=11005,A1AETY="PH"
 S DUZ=DEV
 S DIC("S")="I $D(^A1AE(11007,+Y,A1AETY,DUZ,0))"
 S DINUM=$O(^A1AE(A1AEFL," "),-1)+1
 S DIC("DR")=".001///10;5///TEST"
 S DIC(0)="L"
 D NUM^A1AEUTL
 D CHKEQ(A1AENB,1)
 D CHKEQ(A1AEPD,"ZZZ*2*1")
 D ASSERT($D(^A1AE(11005,"D",A1AEPKIF)))
 QUIT
 ;
 ;
PATCH999 ; @TEST Try to exceed 999
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
