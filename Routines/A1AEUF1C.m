A1AEUF1C ;VEN/LGC/JLI - UNIT TESTS FOR A1AEF1 CONT ; 11/6/14 10:35pm
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
 S X=$$DLTSBLDS
 S X=$$DELTBLDS
 Q
 ;
SHUTDOWN I '$G(A1AEFAIL) S X=$$PTC4KID5^A1AEUF1B I 'X D
 . D FAIL^%ut("Unable to clear test builds")
 L -^XPD(9.6):1
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ;    Testing
 ;      UTP10 UPDPAT^A1AEF1(BUILD,.BARR)
 ;      UTP11 UPDPAT1^A1AEF1(PD,KIEN)
 ;      UTP12 UPDPAT2^A1AEF1(A1AEKI,A1AEPI,KFILE)
 ;      UTP13 UP^A1AEF1(STR)
 ;      UTP14 REMOB^A1AEF1(.BARR)
 ;      UTP15 BACTV^A1AEF1(BUILD)
 ;
 ; Update PAT multiple of the BUILD and all coresponding
 ;   Installs  UPDPAT^A1AEF1(BUILD,.BARR)
 ;   NOTE: Must add one more BUILD entry
 ;      S PKGIEN=$O(^DIC(9.4,"C","A1AE",0))
 ;      S ACTVER=$$GET1^DIQ(9.4,PKGIEN_",",13)
 ;      S BUILD="A1AE*"_ACTVER_"*911"
 ;         Must also add an INSTALL entry
UTP10 ;
 ;
 ; Update the PAT muliple of this BUILD and its corresponding
 ;   Installs UTP11 UPDPAT1^A1AEF1(PD,KIEN)
UTP11 ;
 ;
 ; Update the PAT mulitiple in the given BUILD or
 ;   Install entry UPDPAT2^A1AEF1(A1AEKI,A1AEPI,KFILE)
UTP12 ;
 ;
 ; UPPER CASE function
 ;  UP^A1AEF1(STR)
UTP13 ;
 ;
 ; Remove BUILDS from array that represent earlier versions
 ;  of a package REMOB^A1AEF1(BARR)
UTP14 ;
 ;
 ; Check BUILD to see if it represents current or earlier
 ;  version of a package
UTP15 ;
 ;
 ;
 ;
 .S X=$$SETUP1 I 'X D  Q
 .. D FAIL^%ut("Unable to build array of BUILD names")
 .S X=$$SETUP2 I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST builds")
 .S X=$$SETUP3 I 'X D  Q
 .. D FAIL^%ut("Unable to complete build interdependencies")
 N SEQ,SEQ1,SEQ2
 I '$G(A1AEFAIL) D
 . S X=$$PTC4KID1 I 'X D  Q
 .. D FAIL^%ut("Unable to obtain 10 builds for each seqence")
 . S X=$$PTC4KID2 I 'X D  Q
 .. D FAIL^%ut("Unable to complete additional build dependencies")
 . S X=$$PTC4KID3 I 'X D  Q
 .. D FAIL^%ut("Unable to add new REQB to new build entries")
 . S X=$$PTC4KID4 I 'X D  Q
 .. D FAIL^%ut("Unable to add new REQB to new build entries")
 ;
 I '$G(A1AEFAIL) D
 . D PTCSTRM^A1AEF1(.POO)
 I '$G(A1AEFAIL) N X,PD,PDIEN S X=1
 I '$G(A1AEFAIL) N PTSTRM S PTSTRM=$O(^A1AE(11007.1,"APRIM",1,0))
 I '$G(A1AEFAIL) D
 . S PD=" " F  S PD=$O(POO(PD)) Q:PD=""  D  Q:'X
 .. S PDIEN=$O(^A1AE(11005,"B",PD,0)) I 'PDIEN S X=0 Q
 .. S:($P($G(^A1AE(11005,PDIEN,0)),"^",20)'=PTSTRM) X=0
 . D CHKEQ^%ut(1,X,"Testing PTCSTRM Builds for sequence FAILED!")
 Q
 ;
 ;
 ; Hop over to DHCP PATCHES and find 10 each of
 ;  VISTA and OSEHRA stream
 ; Pass on patches with n.0 version
PTC4KID1() N PD,NODE S NODE=$NA(^A1AE(11005))
 F  S NODE=$Q(@NODE) Q:NODE'["^A1AE(11005,"  D  I $G(SEQ1)>10,$G(SEQ2)>10 Q
 . I $QS(NODE,3)=0  D
 .. I $P(@NODE,"^",20)=1 D:$G(SEQ1)<10
 ... I $P($P($G(^A1AE(11005,$QS(NODE,2),0)),"^"),"*",2)'?.NP Q
 ... S SEQ1=$G(SEQ1)+1,SEQ1(SEQ1)=$QS(NODE,2)
 .. I $P(@NODE,"^",20)=10001 D:$G(SEQ2)<10
 ... I $P($P($G(^A1AE(11005,$QS(NODE,2),0)),"^"),"*",2)'?.NP Q
 ... S SEQ2=$G(SEQ2)+1,SEQ2(SEQ2)=$QS(NODE,2)
 I $G(SEQ1)=10,$G(SEQ2)=10 Q 1
 Q 0
 ;
 ; Make sure there are entries in BUILD [#9.6] file for each
 ;  of the collected patches from 11005
 ; If any do not have corresponding BUILD entries, add them
 ;  now.  Also give each a REQB of A1AEXTST*1*1 so they may
 ;  be recognized later for deletion
PTC4KID2() S SEQ=0 F  S SEQ=$O(SEQ1(SEQ)) Q:'SEQ  D
 .  S PD=$P($G(^A1AE(11005,SEQ1(SEQ),0)),"^")
 .  I '$O(^XPD(9.6,"B",PD,0)) D
 ..;  W !,"ADDING SEQ1 ",PD
 ..  S X=$$LDBLD^A1AEUF1(PD)
 ..  I X S X=$$LDRBLD^A1AEUF1(X,BUILD(1))
 S SEQ=0 F  S SEQ=$O(SEQ2(SEQ)) Q:'SEQ  D
 .  S PD=$P($G(^A1AE(11005,SEQ2(SEQ),0)),"^")
 .  I '$O(^XPD(9.6,"B",PD,0)) D
 ..;  W !,"ADDING SEQ2 ",PD
 ..  S X=$$LDBLD^A1AEUF1(PD)
 ..  I X S X=$$LDRBLD^A1AEUF1(X,BUILD(1))
 Q X
 ; 
 ; Add to A1AE*999*900 the REQB multiple A1AE*999*901 - 910
 ; Remeber that none of these represent current package
 ;   so all will be cleared
 ; Find current version of A1AE and add one BUILD of this
 ;   version A1AE*vrn*9
ADDRBLD() N B29IEN S B29IEN=$O(^XPD(9.6,"B",BUILD(29),0)) Q:'B29IEN
 S SEQ=0 F  S SEQ=$O(SEQ1(SEQ)) Q:'SEQ  D
 . S PD=$P($G(^A1AE(11005,SEQ1(SEQ),0)),"^") Q:PD=""
 . S X=$$LDRBLD(B29IEN,PD)
 S SEQ=0 F  S SEQ=$O(SEQ2(SEQ)) Q:'SEQ  D
 . S PD=$P($G(^A1AE(11005,SEQ2(SEQ),0)),"^") Q:PD=""
 . S X=$$LDRBLD(B29IEN,PD)
 Q:X 1  Q 0
 ;
 ; Build POO array using REQB 
PTC4KID4() ;
 ; We must have PRIMARY set to continue
 ;  if none is set, temporarily set the 
 ;  site to FOIA VISTA as PRIMARY
 N UTOPIEN S UTOPIEN=$$UTPRIEN
 I 'UTOPIEN S $P(^A1AE(11007.1,1,0),U,2)=1 D
 . N DIK,DA
 . S DIK(1)=".02",DIK="^A1AE(11007.1,"
 . D ENALL2^DIK
 . D ENALL^DIK
 S X=1
 N POO D REQB^A1AEF1(BUILD(29),.POO)
 ; Filter out those of wrong stream
 D PTC4KIDS^A1AEF1(BUILD(29),.POO,"")
 ; Now see if remaining match POO array for 
 ;   this stream
 N PRIM S PRIM=$O(^A1AE(11007.1,"APRIM",1,0))
 Q:'PRIM 0
 N SEQA S SEQA=$S(PRIM=1:"SEQ1",PRIM=10001:"SEQ2",1:"")
 Q:SEQA="" 0
 S SEQ=0,X=1
 ; Check that all patches left in the SEQA array
 ;   belong to this site's PRIMARY stream.
 ;   If we find one of another stream, X will
 ;   be returned as 0.  Otherwise, X will say as 1
 F  S SEQ=$O(@SEQA@(SEQ)) Q:'SEQ  D  Q:'X
 . S PD=$P(^A1AE(11005,@SEQA@(SEQ),0),"^")
 . S:'$D(POO(PD)) X=0
 S $P(^A1AE(11007.1,1,0),U,2)=+$G(UTOPIEN) D
 . N X,DIK,DA
 . S DIK(1)=".02",DIK="^A1AE(11007.1,"
 . D ENALL2^DIK
 . D ENALL^DIK
 Q X
 ;
PTC4KID5() S X=$$DLTSBLDS
 S X=$$DELTBLDS
 K BUILD
 Q X
 ;
 ; Build an array of bogus BUILD NAMES
SETUP1() N I
 F I=1:1:30 S BUILD(I)="A1AEXTST*1*"_I
 Q:I=30 1  Q 0
 ;
 ; Load new builds into BUILD [#9.6] file
SETUP2() N X,I F I=1:1:30 S X=$$LDBLD(BUILD(I)) Q:'X  D
 . S BUILD(BUILD(I))=X
 Q:X 1  Q X
 ;
 ; Use test builds to build an interdependant
 ;   array of CONTAINERS, PREREQUISITES, and
 ;   MEMBERS
SETUP3() ; BUILD(10)
 ;   REQUIRED BUILD multiple entries
 ;      BUILD(1)-BUILD(5)
 F I=1:1:5 S X=$$LDRBLD(BUILD(BUILD(10)),BUILD(I)) Q:'X
 Q:'X X
 ;   MULTIPLE BUILD multiple entries
 ;      BUILD(6)-BUILD(10)
 F I=6:1:10 S X=$$LDMBLD(BUILD(BUILD(10)),BUILD(I)) Q:'X
 Q:'X X
 ;
 ; BUILD(11)
 ;   REQUIRED BUILD multiple entries
 ;      BUILD(12)-BUILD(15)
 F I=12:1:15 S X=$$LDRBLD(BUILD(BUILD(11)),BUILD(I)) Q:'X
 Q:'X X
 ;   MULTIPLE BUILD multiple entries
 ;      BUILD(16)-BUILD(20)
 F I=16:1:20 S X=$$LDMBLD(BUILD(BUILD(11)),BUILD(I)) Q:'X
 Q:'X X
 ;
 ; BUILD(28)
 ;   REQUIRED BUILD multiple entries
 ;      BUILD(21)-BUILD(25)
 ;      BUILD(10)-BUILD(11)
 F I=21:1:25 S X=$$LDRBLD(BUILD(BUILD(28)),BUILD(I)) Q:'X
 Q:'X X
 F I=10:1:11 S X=$$LDRBLD(BUILD(BUILD(28)),BUILD(I)) Q:'X
 Q:'X X
 ;   MULTIPLE BUILD multiple entries
 ;      BUILD(26)-BUILD(27)
 F I=26,27 S X=$$LDMBLD(BUILD(BUILD(28)),BUILD(I)) Q:'X
 Q:'X X
 ;
 ; BUILD(29)
 ;   REQUIRED BUILD multiple entries
 ;      BUILD(28)
 S X=$$LDRBLD(BUILD(BUILD(29)),BUILD(28)) Q:'X
 Q:'X X
 ;   MULTIPLE BUILD multiple entries
 ;      BUILD(1)
 ;      BUILD(11)
 F I=1,11 S X=$$LDMBLD(BUILD(BUILD(29)),BUILD(I)) Q:'X
 Q:'X X
 ;
 ; BUILD(30)
 ;   REQUIRED BUILD multiple entries
 ;      BUILD(29)
 S X=$$LDRBLD(BUILD(BUILD(30)),BUILD(29)) Q:'X
 Q:'X X
 ;   MULTIPLE BUILD multiple entries
 ;      BUILD(28)
 S X=$$LDMBLD(BUILD(BUILD(29)),BUILD(28)) Q:'X
 Q:'X X
 Q 1
 ;
 ;Load new BUILD [#9.6] entry
 ;ENTER
 ;  BUILD   =  Build name
 ;RETURN
 ;  IEN of new BUILD entry OR 0_"^DIERR"
LDBLD(BUILD) ;
 Q:BUILD="" 0_"^No BUILD Name"
 N A1AEKI,A1AEPM,DIERR,FDA,FDAIEN
 S FDA(3,9.6,"?+1,",.01)=BUILD
 S FDA(3,9.6,"?+1,",2)=0
 S FDA(3,9.6,"?+1,",.02)=$$HTFM^XLFDT($H,1)
 S FDA(3,9.6,"?+1,",5)="n"
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 I $D(DIERR) Q 0_"^DIERR"
 Q +FDAIEN(1)
 ;
 ; Load entry into MULTIPLE BUILD for this Container build
 ;ENTER
 ;   A1AEKI  = IEN OF Container Build
 ;   A1AEPM  = BUILD name of Member
 ;RETURN
 ;   IEN of new Member within Container BUILD
 ;     OR 0_"^DIERR"
LDMBLD(A1AEKI,MBUILD) ;
 Q:'A1AEKI 0_"^No Container BUILD IEN"
 Q:MBUILD="" 0_"^No Member BUILD Name"
 N FDA,DIERR,FDAIEN
 S FDA(3,9.63,"?+1,"_A1AEKI_",",.01)=MBUILD
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 Q:$D(DIERR) 0_"^DIERR"
 Q +FDAIEN(1)
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
 ;
 ; Delete all test build entries
 ; RETURN
 ;  1 if no errors, 0 if deletion failed
 ;  Nothing to delete returns 1 for no errors
DELTBLDS() N DA,DIK,X,Y S X=1
 N NODE S NODE=$NA(^XPD(9.6,"B","A1AEXTST*1"))
 F  S NODE=$Q(@NODE) Q:NODE'["A1AEXTST*1"  D  Q:'X
 .  N DA,DIK,DIERR
 .  S DA=$QS(NODE,4)
 .  S DIK="^XPD(9.6,"
 .  D ^DIK
 .  S:$D(DIERR) X=0
 Q X
 ;
 ; Delete special builds
 ; Returns  1 = no errors, 0 = deletion failed
 ;  Nothing to delete returns 1 for no errors
DLTSBLDS() N DA,DIERR,X,Y S X=1
 N BIEN S BIEN=0
 F  S BIEN=$O(^XPD(9.6,BIEN)) Q:'BIEN  D
 .  S X=$O(^XPD(9.6,BIEN,"REQB","B","A1AEXTST*1*1",0)) Q:'X
 .  S DA=BIEN,DIK="^XPD(9.6," D ^DIK
 .  S:$D(DIERR) X=0
 Q X
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
 ;;UTP10;Testing updating PAT multiple for BUILD/INSTALLS
 ;;UTP11;Testing updating PAT multiple for single BUILD/INSTALLS
 ;;UTP12;Testing updating PAT multiple for a BUILD or INSTALL
 ;;UTP13;Testing UPPER CASE function
 ;;UTP14;Testing removing BUILDS representing outdated packages
 ;;UTP15;Testing a single BUILD for outdated package
 Q
 ;
 ;
EOR ; end of routine A1AEUF1C
