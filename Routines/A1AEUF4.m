A1AEUF4 ;VEN/LGC/JLI - UNIT TESTS FOR A1AEF4 ; 11/8/14 6:04pm
 ;;2.4;PATCH MODULE;; SEP 24, 2014
 ;
 ;
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 D EN^%ut($T(+0),1)
 Q
 ;
STARTUP S A1AEFAIL=0 ; KILLED IN SHUTDOWN
 L +^XPD(9.6):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on BUILD [#9.6] file"
 . W !," Unable to perform testing."
 ;
 L +^A1AE(11005):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on DHCP PATCHES [#11005] file"
 . W !," Unable to perform testing."
 ;
 ; X may be 0 if none to delete = normal circumstance
 ; X = 1 if previous testing incomplete = ok too
 N X
 S X=$$DELTBLDS
 S X=$$DELTINST
 S X=$$DELPAT
 Q
 ;
SHUTDOWN ;
 L -^XPD(9.6):1
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 ;
 S X=$$DELTBLDS I 'X D
 . W !,"Unable to delete test builds from 9.6",!
 S X=$$DELTINST I 'X D
 . W !,"Unable to delete test installs from 9.7",!
 S X=$$DELPAT I 'X D
 . W !,"Unable to delete test patches from 11005",!
 Q
 ;
 ;  Testing
 ;     UTP30 OTHSTRM^A1AEF4(BUILD)
 ;     UTP31 DERPTC^A1AEF4(PD)
 ;
 ;   Add 900 series patches to an entry
 ;      
 ;   Run this to see if adds OSEHRA derived patches
UTP30 I '$G(A1AEFAIL) D
 .; N BUILD,SAVBLD,X
 . S X=$$SETUP1 I 'X D  Q
 .. D FAIL^%ut("Unable to build array of BUILD names")
 . S X=$$SETUP2(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST builds")
 . S X=$$SETUP3(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST patches")
 . M SAVBLD=BUILD
 .; We must have PRIMARY set to continue
 .;  if none is set, temporarily set the 
 .;  site to FOIA VISTA as PRIMARY
 . N UTOPIEN S UTOPIEN=$$UTPRIEN
 . S $P(^A1AE(11007.1,1,0),U,2)=1
 . S $P(^A1AE(11007.1,10001,0),U,2)=0
 . N DIK,DA
 . S DIK(1)=".02",DIK="^A1AE(11007.1,"
 . D ENALL2^DIK
 . D ENALL^DIK
 .;
 .; Set up DERIVED FROM entries for OSEHRA patches
 . N A1AEIP S A1AEIP=$P(BUILD("A1AE*999*10911"),"^",3)
 . N I F I=A1AEIP:1:A1AEIP+9 D
 .. S $P(^A1AE(11005,I,5),"^",2)=I+10
 .;
 . N NODE S NODE=$NA(BUILD("A1AE*2.4*911"))
 . S I=$P(BUILD("A1AE*999*10920"),"^",3)
 . F  S NODE=$Q(@NODE) Q:NODE["A1AE*999*900"  D
 .. S I=I+1
 .. S ^A1AE(11005,"ADERIVED",$QS(NODE,1),I)=""
 .;
 . N BIEN,I
 . S BIEN=$P(BUILD("A1AE*999*910"),"^")
 . N I F I=911:1:920 S RBUILD=BUILD(I) D
 .. S X=$$LDRBLD(BIEN,RBUILD)
 .;
 .; Test function
 . S X=$$OTHSTRM^A1AEF4(BUILD(910))
 .;
 . N BIEN,A1AEIP S BIEN=$P(BUILD("A1AE*999*910"),"^")
 . S:'BIEN X=0
 . I X D  Q:'X
 .. N I F I=900:1:920 D  Q:'X
 ... Q:I=910
 ... S A1AEIP=$P(BUILD(BUILD(I)),"^",3) I 'A1AEIP Q 0
 ... S X=$O(^XPD(9.6,BIEN,"PAT","B",A1AEIP,0)) Q:'X
 ... S X=$O(^XPD(9.6,BIEN,"REQB","B",BUILD(I),0)) Q:'X
 . S:X X=1
 .;
 . D CHKEQ^%ut(1,X,"Testing pulling other stream builds FAILED!")
 .;
 . S $P(^A1AE(11007.1,1,0),U,2)=0
 . S $P(^A1AE(11007.1,10001,0),U,2)=0
 . I $G(UTOPIEN) D
 .. S $P(^A1AE(11007.1,UTOPIEN,0),U,2)=1
 . N DIK,DA
 . S DIK(1)=".02",DIK="^A1AE(11007.1,"
 . D ENALL2^DIK
 . D ENALL^DIK
 Q
 ;
 ;
 ; Testing $$DERPTC^A1AEF4(PD) to find DERIVED FROM patch
UTP31 I '$G(A1AEFAIL) D
 . N BUILD,SAVBLD,X
 . S X=$$SETUP1 I 'X D  Q
 .. D FAIL^%ut("Unable to build array of BUILD names")
 . S X=$$SETUP2(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST builds")
 . S X=$$SETUP3(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST patches")
 . M SAVBLD=BUILD
 .; We must have PRIMARY set to continue
 .;  if none is set, temporarily set the 
 .;  site to FOIA VISTA as PRIMARY
 . N UTOPIEN S UTOPIEN=$$UTPRIEN
 . S $P(^A1AE(11007.1,1,0),U,2)=1
 . S $P(^A1AE(11007.1,10001,0),U,2)=0
 . N DIK,DA
 . S DIK(1)=".02",DIK="^A1AE(11007.1,"
 . D ENALL2^DIK
 . D ENALL^DIK
 .;
 .; Set up DERIVED FROM entries for OSEHRA patches
 . N A1AEIP S A1AEIP=$P(BUILD("A1AE*999*10911"),"^",3)
 . N I F I=A1AEIP:1:A1AEIP+9 D
 .. S $P(^A1AE(11005,I,5),"^",2)=I+10
 .;
 . N NODE S NODE=$NA(BUILD("A1AE*2.4*911"))
 . S I=$P(BUILD("A1AE*999*10920"),"^",3)
 . F  S NODE=$Q(@NODE) Q:NODE["A1AE*999*900"  D
 .. S I=I+1
 .. S ^A1AE(11005,"ADERIVED",$QS(NODE,1),I)=""
 .;
 . S X=1
 . S:'$L($$DERPTC^A1AEF4("A1AE*999*10920")) X=0
 . S:$L($$DERPTC^A1AEF4("A1AE*999*900")) X=0
 . D CHKEQ^%ut(1,X,"Testing finding a derived patch FAILED!")
 .;
 . S $P(^A1AE(11007.1,1,0),U,2)=0
 . S $P(^A1AE(11007.1,10001,0),U,2)=0
 . I $G(UTOPIEN) D
 .. S $P(^A1AE(11007.1,UTOPIEN,0),U,2)=1
 . N DIK,DA
 . S DIK(1)=".02",DIK="^A1AE(11007.1,"
 . D ENALL2^DIK
 . D ENALL^DIK
 Q
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
 ;     BUILD("A1AE*2.4*911")="9537^9015^129505"
 ;     BUILD("A1AE*999*10911")="9527^9005^129506"
 ;     BUILD("A1AE*999*10912")="9528^9006^129507"
 ;     BUILD("A1AE*999*10913")="9529^9007^129508"
 ;     BUILD("A1AE*999*10914")="9530^9008^129509"
 ;     BUILD("A1AE*999*10915")="9531^9009^129510"
 ;     BUILD("A1AE*999*10916")="9532^9010^129511"
 ;     BUILD("A1AE*999*10917")="9533^9011^129512"
 ;     BUILD("A1AE*999*10918")="9534^9012^129513"
 ;     BUILD("A1AE*999*10919")="9535^9013^129514"
 ;     BUILD("A1AE*999*10920")="9536^9014^129515"
 ;     BUILD("A1AE*999*900")="9516^8994^129516"
 ;     BUILD("A1AE*999*901")="9517^8995^129517"
 ;     BUILD("A1AE*999*902")="9518^8996^129518"
 ;     BUILD("A1AE*999*903")="9519^8997^129519"
 ;     BUILD("A1AE*999*904")="9520^8998^129520"
 ;     BUILD("A1AE*999*905")="9521^8999^129521"
 ;     BUILD("A1AE*999*906")="9522^9000^129522"
 ;     BUILD("A1AE*999*907")="9523^9001^129523"
 ;     BUILD("A1AE*999*908")="9524^9002^129524"
 ;     BUILD("A1AE*999*909")="9525^9003^129525"
 ;     BUILD("A1AE*999*910")="9526^9004^129526"
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
 N DERFRM S DERFRM=$S(PTCHNB>10001:PTCHNB-10000,1:0)
 N FDAIEN
 ; If already entry in 11005, move on to adding RTN
 I +$O(^A1AE(11005,"B",PD,0)) D
 . S FDAIEN(1)=+$O(^A1AE(11005,"B",PD,0))
 E  D
 . N DIERR
 . S FDA(3,11005,"?+1,",.01)=PD
 . S FDA(3,11005,"?+1,",.2)=PTSTRM
 . S FDA(3,11005,"?+1,",2)=PKGIEN
 . S FDA(3,11005,"?+1,",3)=PKGAV
 . S FDA(3,11005,"?+1,",4)=PTCHNB
 . S FDA(3,11005,"?+1,",5)="A1AE TEST ZZZFOR UNIT TESTS"
 . D UPDATE^DIE("","FDA(3)","FDAIEN")
 ;W "NEW ENTRY=",+$G(FDAIEN(1))
 Q:$D(DIERR) 0
 S FDAIEN=+$G(FDAIEN(1))
 Q FDAIEN
 ;
 ;
 ; Load entry into REQUIRED BUILD for this Container build
 ;ENTER
 ;   A1AEKI  = IEN OF Container Build
 ;   A1AEPM  = BUILD name of Member
 ;RETURN
 ;   IEN of new Member within Container BUILD
 ;     OR 0_"^DIERR"
LDRBLD(A1AEKI,RBUILD) ;
 Q:'A1AEKI 0_"^No Container BUILD IEN"
 Q:RBUILD="" 0_"^No Member BUILD Name"
 N FDA,DIERR,FDAIEN
 S FDA(3,9.611,"?+1,"_A1AEKI_",",.01)=RBUILD
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 Q:$D(DIERR) 0_"^DIERR"
 Q +FDAIEN(1)
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
 F  S PD=$O(^A1AE(11005,"B",PD)) Q:PD'["A1AE*999"  D  Q:'NOERR
 . S PIEN=$O(^A1AE(11005,"B",PD,0)) I 'PIEN S NOERR=0 Q
 . S DIK="^A1AE(11005," S DA=+PIEN D ^DIK
 . S:$D(DIERR) NOERR=0
 N PKGIEN S PKGIEN=$O(^DIC(9.4,"C","A1AE",0))
 N ACTVER S ACTVER=$$GET1^DIQ(9.4,PKGIEN_",",13)
 N PD S PD="A1AE*"_ACTVER_"*911"
 S DA=$O(^A1AE(11005,"B",PD,0)) I DA D
 . S DIK="^A1AE(11005,"
 . D ^DIK
 . S:$D(DIERR) X=0
 Q NOERR
 ;
 ; Function to return IEN of DHCP PATCH STREAM [#11007.1]
 ;   entry having PRIMARY? [#.02] field set
UTPRIEN() ;
 N A1AEI,UTPRIM S (A1AEI,UTPRIM)=0
 F  S A1AEI=$O(^A1AE(11007.1,A1AEI)) Q:'A1AEI  D
 . I $P(^A1AE(11007.1,A1AEI,0),U,2) S UTPRIM=A1AEI
 Q UTPRIM
 ;
XTENT ;
 ;;UTP30;Add builds to REQB/MULB for other stream
 ;;UTP31;Find name DERIVED PATCH
 Q
 ;
 ;
TEST ; Set up DERIVED FROM entries for OSEHRA patches
 ;
 D TEST^A1AEUF1B
 N A1AEIP S A1AEIP=$P(BUILD("A1AE*999*10911"),"^",3)
 N I F I=A1AEIP:1:A1AEIP+9 D
 . S $P(^A1AE(11005,I,5),"^",2)=I+10
 ;
 N NODE S NODE=$NA(BUILD("A1AE*2.4*911"))
 S I=$P(BUILD("A1AE*999*10920"),"^",3)
 F  S NODE=$Q(@NODE) Q:NODE["A1AE*999*900"  D
 . S I=I+1
 . S ^A1AE(11005,"ADERIVED",$QS(NODE,1),I)=""
 ; Pull this up before test, then check A1AE*999*910
 ;   has all the patches and REQB for 900 and 10900 series
 N BIEN,I
 S BIEN=$P(BUILD("A1AE*999*910"),"^")
 N I F I=911:1:920 S RBUILD=BUILD(I) D
 . S X=$$LDRBLD(BIEN,RBUILD)
 ;
 W $$OTHSTRM^A1AEF4(BUILD(910))
 Q
 ;
TEST1 N BIEN S BIEN=$P(BUILD("A1AE*999*910"),"^")
 N I F I=900:1:920 D
 . Q:I=910
 . S A1AEIP=$P(BUILD(BUILD(I)),"^",3)
 . W !,A1AEIP
 . I $O(^XPD(9.6,BIEN,"PAT","B",A1AEIP,0)) W " *"
 . W !,BUILD(I)
 . I $O(^XPD(9.6,BIEN,"REQB","B",BUILD(I),0)) W " *"
 Q
EOR ; end of routine A1AEUF4
