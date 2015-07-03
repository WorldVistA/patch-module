A1AEUF1B ;ven/lgc,jli-unit tests for A1AEF1 cont ; 6/4/15 6:49am
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ;
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 N A1AEFAIL S A1AEFAIL=0
 D EN^%ut($T(+0),1)
 Q
 ;
STARTUP S A1AEFAIL=0 ; KILLED IN SHUTDOWN
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525
 L +^XPD(9.6):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on BUILD [#9.6] file"
 . W !," Unable to perform testing."
 ;
 L +^A1AE(A1AEFILE):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on DHCP PATCHES  [#"_A1AEFILE_"] file" ; JLI 150525
 . W !," Unable to perform testing."
 ;
 ; X may be 0 if none to delete = normal circumstance
 ; X = 1 if previous testing incomplete = ok too
 I '$G(A1AEFAIL) S X=$$DELTBLDS
 Q
 ;
SHUTDOWN S X=$$DELTBLDS I 'X D
 . W !,"Unable to clear test builds"
 . W !," It may be necessary to delete test"
 . W !," build entries in BUILD [#9.6] file"
 . W !," manually [A1AE*999*n].",!
 S X=$$DELTINST I 'X D
 . W !,"Unable to clear test builds"
 . W !," It may be necessary to delete test"
 . W !," build entries in INSTALL [#9.7] file"
 . W !," manually [A1AE*999*n].",!
 S X=$$DELPAT I 'X D
 . W !,"Unable to clear test PATCHES"
 . W !," It may be necessary to delete test"
 . ;W !," PATHC entries in DHCP PATCHES [#11005] file" ; JLI 150525 commented, replaced by following line
 . W !," PATHC entries in "_A1AENAME_" [#"_A1AEFILE_"] file"
 . W !," manually [A1AE*999*n].",!
 L -^XPD(9.6):1
 N A1AEFILE S A1AEFILE=11005,A1AENAME="DHCP PATCHES" I '$D(^DIC(11005)) S A1AEFILE=11004,A1AENAME="PATCH" ; JLI 150525
 L -^A1AE(A1AEFILE):1
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ; Testing
 ;      UTP8  PTC4KIDS(BUILD,.BARR)
 ;      UTP9  PTCSTRM^A1AEF1(.SAVBLD)
 ;      UTP10 UPDPAT^A1AEF1(BUILD,.BARR)
 ;      UTP11 UPDPAT1^A1AEF1(PD,KIEN)
 ;      UTP12 UPDPAT2^A1AEF1(A1AEKI,A1AEPI,KFILE)
 ;      UTP13 UP^A1AEF1(STR)
 ;      UTP14 REMOB^A1AEF1(.BARR)
 ;      UTP15 BACTV^A1AEF1(BUILD)
 ;
 ;   PTC4KIDS^A1AEF1(BUILD,.BARR)
 ;     Filter an array of builds to remove any where associated
 ;     patch in 11005 doesn't match site's stream
 ;     1.  Get site's PRIMARY and save
 ;     2.  Set PRIMARY to 1
 ;     3.  Build array BUILD with 20 patches
 ;         10 for stream 1 [A1AE*999*900 - 910]
 ;         10 for stream 10001 [A1AE*999*100911 -100920]
 ;     4.  Add 20 builds to BUILD 9.6
 ;     5.  Add 20 builds to DHCP PATCHES 11005
 ;     5.  Call PTC4KIDS
 ;     6.  Check only FOIA patches remain in BUILD array
 ;     7.  Reset PRIMARY
 ;     8.  Delete test builds, test patches
 ;
UTP8 N BUILD,SAVBLD
 S X=$$SETUP1 I 'X D  Q
 . D FAIL^%ut("Unable to build array of BUILD names")
 S X=$$SETUP2(.BUILD) I 'X D  Q
 . D FAIL^%ut("Unable to complete entry of TEST builds")
 S X=$$SETUP3(.BUILD) I 'X D  Q
 . D FAIL^%ut("Unable to complete entry of TEST patches")
 M SAVBLD=BUILD
 I '$G(A1AEFAIL) D
 . N UTOPIEN S UTOPIEN=$$UTPRIEN ; Save and set PRIMARY STREAM
 . D PTC4KIDS^A1AEF1("A1AE*999*900",.BUILD,"")
 . D REPPRIM
 . N PD S PD=" ",X=1
 . F  S PD=$O(BUILD(PD)) Q:PD=""  S:$P(PD,"*",3)>999 X=0
 . D CHKEQ^%ut(1,X,"Testing PTC4KIDS Builds for sequence FAILED!")
 Q
 ;
 ; This test entered with all the hard work for previous
 ;  test done and saved in SAVBLD array
UTP9 I '$G(A1AEFAIL) D
 . N UTOPIEN S UTOPIEN=$$UTPRIEN ; Save PRIMARY STREAM
 . K BUILD,SAVBLD
 .;
 . S X=$$SETUP1 I 'X D  Q
 .. D REPPRIM
 .. D FAIL^%ut("Unable to build array of BUILD names")
 . S X=$$SETUP2(.BUILD) I 'X D  Q
 .. D REPPRIM
 .. D FAIL^%ut("Unable to complete entry of TEST builds")
 . S X=$$SETUP3(.BUILD) I 'X D  Q
 .. D REPPRIM
 .. D FAIL^%ut("Unable to complete entry of TEST patches")
 . M SAVBLD=BUILD
 . D PTCSTRM^A1AEF1(.BUILD)
 . D REPPRIM
 . N PD S PD=" ",X=1
 . F  S PD=$O(BUILD(PD)) Q:PD=""  S:$P(PD,"*",3)>999 X=0
 . D CHKEQ^%ut(1,X,"Testing filtering array for patch stream FAILED!")
 .; Return primary to original setting
 Q
 ;
 ;
 ; Update PAT multiple of the BUILD and all coresponding
 ;   Installs  UPDPAT^A1AEF1(BUILD,.BARR)
UTP10 I '$G(A1AEFAIL) D
 . K BUILD,SAVBLD
 . S X=$$SETUP1 I 'X D  Q
 .. D FAIL^%ut("Unable to build array of BUILD names")
 . S X=$$SETUP2(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST builds")
 . S X=$$SETUP3(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST patches")
 . M SAVBLD=BUILD
 . S X=$$UP1
 . D CHKEQ^%ut(1,X,"Updating PAT multiples of BUILD/INSTALLS FAILED!")
 Q
UP1() N NOERR S NOERR=1
 N PIEN S PIEN=$P(BUILD(BUILD(921)),"^")
 D UPDPAT^A1AEF1(BUILD(921),.BUILD)
 N NODE S NODE=$NA(^XPD(9.6,PIEN,"PAT")),SNODE=$P(NODE,")")
 S NODE=$Q(@NODE) ; Jump over first node
 F  S NODE=$Q(@NODE) Q:NODE'[SNODE  D  Q:'NOERR
 . I @NODE["A1AE",$D(BUILD($P(@NODE,"^",2))) D  Q
 .. K BUILD($P(@NODE,"^",2))
 . E  I $QS(NODE,4)'="B" S NOERR=0
 I $O(BUILD(" "))'="" S NOERR=0
 Q:'NOERR NOERR
 K BUILD M BUILD=SAVBLD N NOERR S NOERR=1
 N PIEN S PIEN=$P(BUILD(BUILD(921)),"^",2)
 N NODE S NODE=$NA(^XPD(9.7,PIEN,"PAT")),SNODE=$P(NODE,")")
 S NODE=$Q(@NODE) ; Jump over first node
 F  S NODE=$Q(@NODE) Q:NODE'[SNODE  D  Q:'NOERR
 . I @NODE["A1AE",$D(BUILD($P(@NODE,"^",2))) D  Q
 .. K BUILD($P(@NODE,"^",2))
 . E  I $QS(NODE,4)'="B" S NOERR=0
 I $O(BUILD(" "))'="" S NOERR=0
 Q NOERR
 ;
 ; Update the PAT muliple of this BUILD and its corresponding
 ;   Installs UTP11 UPDPAT1^A1AEF1(PD,KIEN)
UTP11 I '$G(A1AEFAIL) D
 . K BUILD,SAVBLD
 . S X=$$SETUP1 I 'X D  Q
 .. D FAIL^%ut("Unable to build array of BUILD names")
 . S X=$$SETUP2(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST builds")
 . S X=$$SETUP3(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST patches")
 . M SAVBLD=BUILD
 . S X=$$UP2
 . D CHKEQ^%ut(1,X,"Updating PAT single BUILD/INSTALL pair FAILED!")
 Q
UP2() N NOERR S NOERR=1
 N PIEN S PIEN=$P(BUILD(BUILD(920)),"^")
 S PD=BUILD(921)
 D UPDPAT1^A1AEF1(PD,PIEN)
 I ^XPD(9.6,PIEN,"PAT",1,0)'[PD S NOERR=0
 N PIEN S PIEN=$P(BUILD(BUILD(920)),"^",2)
 I ^XPD(9.7,PIEN,"PAT",1,0)'[PD S NOERR=0
 Q NOERR
 ;
 ; Update the PAT mulitiple in the given BUILD or
 ;   Install entry UPDPAT2^A1AEF1(A1AEKI,A1AEPI,KFILE)
UTP12 I '$G(A1AEFAIL) D
 . K BUILD,SAVBLD
 . S X=$$SETUP1 I 'X D  Q
 .. D FAIL^%ut("Unable to build array of BUILD names")
 . S X=$$SETUP2(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST builds")
 . S X=$$SETUP3(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST patches")
 . M SAVBLD=BUILD
 . S X=$$UP3
 . D CHKEQ^%ut(1,X,"Updating PAT of  BUILD or INSTALL FAILED!")
 Q
UP3() N NOERR S NOERR=1
 N A1AEKI S A1AEKI=$P(BUILD(BUILD(918)),"^")
 N A1AEPI S A1AEPI=$P(BUILD(BUILD(919)),"^",3)
 D UPDPAT2^A1AEF1(A1AEKI,A1AEPI,9.619)
 S:+$P(^XPD(9.6,A1AEKI,"PAT",1,0),"^")'=A1AEPI NOERR=0
 Q:'NOERR NOERR
 N A1AEKI S A1AEKI=$P(BUILD(BUILD(918)),"^",2)
 N A1AEPI S A1AEPI=$P(BUILD(BUILD(919)),"^",3)
 D UPDPAT2^A1AEF1(A1AEKI,A1AEPI,9.719)
 S:+$P(^XPD(9.7,A1AEKI,"PAT",1,0),"^")'=A1AEPI NOERR=0
 Q NOERR
 ;
 ;
 ; UPPER CASE function
 ;  UP^A1AEF1(STR)
UTP13 I '$G(A1AEFAIL) D
 . N X,STR S STR="abcdefghijklmnopqrstuvwxyz1234567890"
 . S X=$$UP^A1AEF1(STR)="ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
 . D CHKEQ^%ut(1,X,"UPPERCASE function FAILED!")
 Q
 ;
 ; Remove BUILDS from array that represent earlier versions
 ;  of a package REMOB^A1AEF1(BARR)
UTP14 I '$G(A1AEFAIL) D
 . K BUILD,SAVBLD
 . S X=$$SETUP1 I 'X D  Q
 .. D FAIL^%ut("Unable to build array of BUILD names")
 . S X=$$SETUP2(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST builds")
 . S X=$$SETUP3(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST patches")
 . M SAVBLD=BUILD
 . S X=0
 . D REMOB^A1AEF1(.BUILD)
 . N BLD S BLD=$O(BUILD(" "))
 . S:SAVBLD(921)=BLD X=1
 . S:$O(BUILD(BLD))'="" X=0
 . D CHKEQ^%ut(1,X,"Remove NON-CURRENT PKG array entries FAILED!")
 Q
 ;
 ;
 ; Check BUILD to see if it represents current or earlier
 ;  version of a package
UTP15 I '$G(A1AEFAIL) D
 . K BUILD,SAVBLD
 . S X=$$SETUP1 I 'X D  Q
 .. D FAIL^%ut("Unable to build array of BUILD names")
 . S X=$$SETUP2(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST builds")
 . S X=$$SETUP3(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST patches")
 . M SAVBLD=BUILD
 . S X=$$BACTV^A1AEF1(BUILD(921))
 . S:$$BACTV^A1AEF1(BUILD(900))'=0 X=0
 . D CHKEQ^%ut(1,X,"Check BUILD for CURRENT PKG FAILED!")
 Q
 ;
 ;
 ; Build an array of bogus BUILD NAMES
 ; ENTER
 ;   nothing required
 ; RETURN
 ;   0 = error, 1 = array built
SETUP1() N I
 F I=900:1:910 D
 . S BUILD(I)="A1AE*999*"_I
 . S BUILD(I+10)="A1AE*999*"_(10000+I+10)
 N PKGIEN S PKGIEN=$O(^DIC(9.4,"C","A1AE",0))
 N ACTVER S ACTVER=$$GET1^DIQ(9.4,PKGIEN_",",13)
 S BUILD(921)="A1AE*"_ACTVER_"*911"
 Q:I=910 1  Q 0
 ;
 ; Load new builds into BUILD [#9.6] file
 ; ENTER
 ;   BUILD  = array of build names by reference
 ; RETURN
 ;   0 = error, 1 = BUILDS successfully added to 9.6
 ;                  BUILD array updated
SETUP2(BUILD) N X,I
 F I=900:1:921 D  Q:'X
 . S X=$$LDBLD(BUILD(I)) Q:'X
 . S BUILD(BUILD(I))=X
 . S X=$$LDINST(BUILD(I)) Q:'X
 . S BUILD(BUILD(I))=BUILD(BUILD(I))_"^"_X
 Q:X 1  Q X
 ;
 ; Load new patches into DHCP PATCHES [#11005] file
 ; ENTER
 ;   BUILD  = array of build names by reference
 ; RETURN
 ;   0 = error, 1 = PATCHES successfully added to 11005
 ;                  BUILD array updated again
SETUP3(BUILD) N PD S PD=" " F  S PD=$O(BUILD(PD)) Q:PD=""  D
 . S X=$$MKPATCH(PD) Q:'X  D
 . S BUILD(PD)=$G(BUILD(PD))_"^"_X
 Q:X 1  Q X
 ;  After SETUP3 we have
 ;     BUILD(900)="A1AE*999*900"
 ;     BUILD(901)="A1AE*999*901"
 ;     BUILD(902)="A1AE*999*902"
 ;     BUILD(903)="A1AE*999*903"
 ;     BUILD(904)="A1AE*999*904"
 ;     BUILD(905)="A1AE*999*905"
 ;     BUILD(906)="A1AE*999*906"
 ;     BUILD(907)="A1AE*999*907"
 ;     BUILD(908)="A1AE*999*908"
 ;     BUILD(909)="A1AE*999*909"
 ;     BUILD(910)="A1AE*999*910"
 ;     BUILD(911)="A1AE*999*10911"
 ;     BUILD(912)="A1AE*999*10912"
 ;     BUILD(913)="A1AE*999*10913"
 ;     BUILD(914)="A1AE*999*10914"
 ;     BUILD(915)="A1AE*999*10915"
 ;     BUILD(916)="A1AE*999*10916"
 ;     BUILD(917)="A1AE*999*10917"
 ;     BUILD(918)="A1AE*999*10918"
 ;     BUILD(919)="A1AE*999*10919"
 ;     BUILD(920)="A1AE*999*10920"
 ;     BUILD(921)="A1AE*2.4*911"
 ;     BUILD("A1AE*2.4*911")="9538^9016"
 ;     BUILD("A1AE*999*10911")="9487^129506"
 ;     BUILD("A1AE*999*10912")="9488^129507"
 ;     BUILD("A1AE*999*10913")="9489^129508"
 ;     BUILD("A1AE*999*10914")="9490^129509"
 ;     BUILD("A1AE*999*10915")="9491^129510"
 ;     BUILD("A1AE*999*10916")="9492^129511"
 ;     BUILD("A1AE*999*10917")="9493^129512"
 ;     BUILD("A1AE*999*10918")="9494^129513"
 ;     BUILD("A1AE*999*10919")="9495^129514"
 ;     BUILD("A1AE*999*10920")="9496^129515"
 ;     BUILD("A1AE*999*900")="9476^129516"
 ;     BUILD("A1AE*999*901")="9477^129517"
 ;     BUILD("A1AE*999*902")="9478^129518"
 ;     BUILD("A1AE*999*903")="9479^129519"
 ;     BUILD("A1AE*999*904")="9480^129520"
 ;     BUILD("A1AE*999*905")="9481^129521"
 ;     BUILD("A1AE*999*906")="9482^129522"
 ;     BUILD("A1AE*999*907")="9483^129523"
 ;     BUILD("A1AE*999*908")="9484^129524"
 ;     BUILD("A1AE*999*909")="9485^129525"
 ;     BUILD("A1AE*999*910")="9486^129526"
 ;
 ;
 ;Load new BUILD [#9.6] entry and corresponding INSTALL entry
 ;ENTER
 ;  BUILD   =  Build name
 ;RETURN
 ;  0 = error,  n = IEN of successful entry in 9.6
LDBLD(BUILD) ;
 Q:BUILD="" 0_"^No BUILD Name"
 S X=$O(^XPD(9.6,"B",BUILD,0)) Q:X X
 N DIERR,FDA,FDAIEN
 N PKGIEN S PKGIEN=+$O(^DIC(9.4,"C",$P(BUILD,"*"),0))
 S FDA(3,9.6,"?+1,",.01)=BUILD
 S FDA(3,9.6,"?+1,",1)=PKGIEN
 S FDA(3,9.6,"?+1,",2)=0
 S FDA(3,9.6,"?+1,",.02)=$$HTFM^XLFDT($H,1)
 S FDA(3,9.6,"?+1,",5)="n"
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 I $D(DIERR) Q 0
 Q +$G(FDAIEN(1))
 ;
 ;Load new BUILD [#9.6] entry and corresponding INSTALL entry
 ;ENTER
 ;  BUILD   =  Build name
 ;RETURN
 ;  0 = error,  n = IEN of successful entry in 9.7
LDINST(BUILD) ;
 Q:BUILD="" 0_"^No BUILD Name"
 S X=$O(^XPD(9.7,"B",BUILD,0)) Q:X X
 N DIERR,FDA,FDAIEN
 S FDA(3,9.7,"?+1,",.01)=BUILD
 S FDA(3,9.7,"?+1,",.02)=3
 S FDA(3,9.7,"?+1,",2)=$$HTFM^XLFDT($H,1)
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 I $D(DIERR) Q 0
 Q +$G(FDAIEN(1))
 ;
 ; ENTER
 ;    PD   =  PATCH DESIGNATION
 ;    RTN  =  ROUTINE NAME to add to 11005 PD entry
 ; RETURNS
 ;    0 = error,  IEN of patch if successful
MKPATCH(PD) Q:PD="" 0
 N X,Y,DA,DIC,DIEN
 N PKGIEN S PKGIEN=$O(^DIC(9.4,"C",$P(PD,"*"),0)) Q:PKGIEN="" 0
 N PKGAV S PKGAV=$$GET1^DIQ(9.4,PKGIEN_",",13) Q:'PKGAV 0
 N PTCHNB S PTCHNB=+$P(PD,"*",3) Q:'PTCHNB 0
 N PTSTRM S PTSTRM=$S(PTCHNB>10001:10001,1:1)
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525
 N FDAIEN
 ; If already entry in 11005, move on to adding RTN
 I +$O(^A1AE(A1AEFILE,"B",PD,0)) D  ; JLI 150525
 . S FDAIEN(1)=+$O(^A1AE(A1AEFILE,"B",PD,0)) ; JLI 150525
 E  D
 . N DIERR
 . S FDA(3,A1AEFILE,"?+1,",.01)=PD ; JLI 150525
 . S FDA(3,A1AEFILE,"?+1,",.2)=PTSTRM
 . S FDA(3,A1AEFILE,"?+1,",2)=PKGIEN
 . S FDA(3,A1AEFILE,"?+1,",3)=PKGAV
 . S FDA(3,A1AEFILE,"?+1,",4)=PTCHNB
 . S FDA(3,A1AEFILE,"?+1,",5)="A1AE TEST ZZZFOR UNIT TESTS"
 . D UPDATE^DIE("","FDA(3)","FDAIEN")
 ;W "NEW ENTRY=",+$G(FDAIEN(1))
 Q:$D(DIERR) 0
 S FDAIEN=+$G(FDAIEN(1))
 Q FDAIEN
 ;
 ;
 ; Delete all test build entries
 ; RETURN
 ;  1 if no errors, 0 if deletion failed
 ;  Nothing to delete returns 1 for no errors
DELTBLDS() N DA,DIK,X,Y S X=1
 N NODE S NODE=$NA(^XPD(9.6,"B","A1AE*999"))
 F  S NODE=$Q(@NODE) Q:NODE'["A1AE*999"  D  Q:'X
 .  N DA,DIK,DIERR
 .  S DA=$QS(NODE,4)
 .  S DIK="^XPD(9.6,"
 .  D ^DIK
 .  S:$D(DIERR) X=0
 N PKGIEN S PKGIEN=$O(^DIC(9.4,"C","A1AE",0))
 N ACTVER S ACTVER=$$GET1^DIQ(9.4,PKGIEN_",",13)
 N PD S PD="A1AE*"_ACTVER_"*911"
 S DA=$O(^XPD(9.6,"B",PD,0)) I DA D
 . S DIK="^XPD(9.6,"
 . D ^DIK
 . S:$D(DIERR) X=0
 Q X
 ;
 ; Delete all test INSTALL entries
 ; RETURN
 ;  1 if no errors, 0 if deletion failed
 ;  Nothing to delete returns 1 for no errors
DELTINST() N DA,DIK,X,Y S X=1
 N NODE S NODE=$NA(^XPD(9.7,"B","A1AE*999"))
 F  S NODE=$Q(@NODE) Q:NODE'["A1AE*999"  D  Q:'X
 .  N DA,DIK,DIERR
 .  S DA=$QS(NODE,4)
 .  S DIK="^XPD(9.7,"
 .  D ^DIK
 .  S:$D(DIERR) X=0
 N PKGIEN S PKGIEN=$O(^DIC(9.4,"C","A1AE",0))
 N ACTVER S ACTVER=$$GET1^DIQ(9.4,PKGIEN_",",13)
 N PD S PD="A1AE*"_ACTVER_"*911"
 S DA=$O(^XPD(9.7,"B",PD,0)) I DA D
 . S DIK="^XPD(9.7,"
 . D ^DIK
 . S:$D(DIERR) X=0
 Q X
 ;
 ; ENTER
 ;   nothing required
 ; RETURN
 ;   0 = error, 1 = deletions complete
DELPAT() N PD,PIEN,DIK,DA,DIERR,NOERR S PD="A1AE*999*",NOERR=1
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525
 F  S PD=$O(^A1AE(A1AEFILE,"B",PD)) Q:PD'["A1AE*999"  D  Q:'NOERR
 . S PIEN=$O(^A1AE(A1AEFILE,"B",PD,0)) I 'PIEN S NOERR=0 Q
 . S DIK="^A1AE(A1AEFILE," S DA=+PIEN D ^DIK
 . S:$D(DIERR) NOERR=0
 N PKGIEN S PKGIEN=$O(^DIC(9.4,"C","A1AE",0))
 N ACTVER S ACTVER=$$GET1^DIQ(9.4,PKGIEN_",",13)
 N PD S PD="A1AE*"_ACTVER_"*911"
 S DA=$O(^A1AE(A1AEFILE,"B",PD,0)) I DA D
 . S DIK="^A1AE(A1AEFILE,"
 . D ^DIK
 . S:$D(DIERR) X=0
 Q NOERR
 ;
 ; Function to return IEN of DHCP PATCH STREAM [#11007.1]
 ;   entry having PRIMARY? [#.02] field set
 ;   while then setting FOIA VISTA to primary
UTPRIEN() ;
 N A1AEI,UTPRIM S (A1AEI,UTPRIM)=0
 F  S A1AEI=$O(^A1AE(11007.1,A1AEI)) Q:'A1AEI  D
 . I $P(^A1AE(11007.1,A1AEI,0),U,2) S UTPRIM=A1AEI
 S $P(^A1AE(11007.1,1,0),U,2)=1 ; Set PRIMARY TO FOIA VISTA
 S $P(^A1AE(11007.1,10001,0),U,2)=0
 N DIK,DA
 S DIK(1)=".02",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 D ENALL^DIK
 Q UTPRIM
 ;
 ; Put PATCH STREAM PRIMARY back as it was
REPPRIM S $P(^A1AE(11007.1,1,0),U,2)=0
 S $P(^A1AE(11007.1,10001,0),U,2)=0
 S:$G(UTOPIEN) $P(^A1AE(11007.1,UTOPIEN,0),U,2)=1
 N DIK,DA
 S DIK(1)=".02",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 D ENALL^DIK
 Q
 ;
UP(STR) Q $TR(STR,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 ;
XTENT ;
 ;;UTP8;Testing collecting patches for KIDS
 ;;UTP9;Testing filtering array for PATCH STREAM
 ;;UTP10;Testing Updating PAT multiples of BUILD/INSTALLS
 ;;UTP11;Testing Updating PAT single BUILD/INSTALL pair
 ;;UTP12;Testing Updating PAT of  BUILD or INSTALL
 ;;UTP13;Testing UPPERCASE function
 ;;UTP14;Testing Remove NON-CURRENT PKG array entries
 ;;UTP15;Testing Check BUILD for CURRENT PKG
 ;
TEST K BUILD,SAVBLD
 S X=$$DELTBLDS
 S X=$$DELTINST
 S X=$$DELPAT
 S X=$$SETUP1
 S X=$$SETUP2(.BUILD)
 S X=$$SETUP3(.BUILD)
 M SAVBLD=BUILD
 S $P(^A1AE(11007.1,1,0),U,2)=1
 S $P(^A1AE(11007.1,10001,0),U,2)=1
 N DIK,DA
 S DIK(1)=".02",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 D ENALL^DIK
TEST1 W !,"LAST BUILD=",$O(^XPD(9.6,"A"),-1),!
 W !,"LAST INSTALL=",$O(^XPD(9.7,"A"),-1),!
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525
 W !,"LAST PATCH=",$O(^A1AE(A1AEFILE,"A"),-1),!
 Q
 ;
EOR ; end of routine A1AEUF1B
