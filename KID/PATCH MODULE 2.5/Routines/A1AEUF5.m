A1AEUF5 ;ven/lgc,jli-unit tests for A1AEF5 ;2015-06-13  9:58 PM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 D EN^%ut($T(+0),1)
 Q
 ;
STARTUP ;
 S A1AEFAIL=0 ; KILLED IN SHUTDOWN
 L +^XPD(9.6):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on BUILD [#9.6] file"
 . W !," Unable to perform testing."
 ;
 N A1AEFILE S A1AEFILE=11005,A1AENAME="DHCP PATCHES" I '$D(^DIC(11005)) S A1AEFILE=11004,A1AENAME="PATCH" ; JLI 150525
 L +^A1AE(A1AEFILE):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on "_A1AENAME_" [#"_A1AEFILE_"] file"
 . W !," Unable to perform testing."
 ;
 I '$G(A1AEFAIL) N X S X=$$DELTBLDS I 'X D  Q
 . S A1AEFAIL=1
 . W !,"Unable to clear test builds"
 . W !," Unable to perform testing."
 ;
 I '$G(A1AEFAIL) S X=$$SETUP1 I 'X D  Q
 . S A1AEFAIL=1
 . W !,"Unable to build array of BUILD names"
 . W !," Unable to perform testing."
 ;
 I '$G(A1AEFAIL) S X=$$SETUP2 I 'X D  Q
 . S A1AEFAIL=1
 . W !,"Unable to complete entry of TEST builds"
 . W !," Unable to perform testing."
 ;
 I '$G(A1AEFAIL) S X=$$SETUP3 I 'X D  Q
 . S A1AEFAIL=1
 . W !,"Unable to complete build interdependencies"
 . W !," Unable to perform testing."
 Q
 ;
SHUTDOWN I '$G(A1AEFAIL) S X=$$DELTBLDS I 'X D
 . W !,"******* WARNING ********"
 . W !,"Unable to delete test BUILD entries after testing."
 . W !,"  BUILDS with names beginning with  A1AEXTST*1*"
 . W !,"  may need to be deleted manually."
 ;
 I '$G(A1AEFAIL) S X=$$DELTBLDZ I 'X D
 . W !,"******* WARNING ********"
 . W !,"Unable to delete test BUILD entries after testing."
 . W !,"  BUILDS with names beginning with  A1AEXTST*1*"
 . W !,"  may need to be deleted manually."
 ;
 I '$G(A1AEFAIL) S X=$$DELTINST I 'X D
 . W !,"******* WARNING ********"
 . W !,"Unable to delete test INSTALL entries after testing."
 . W !,"  BUILDS with names beginning with  A1AEXTST*1*"
 . W !,"  may need to be deleted manually."
 ;
 N A1AEFILE S A1AEFILE=11005,A1AENAME="DHCP PATCHES" I '$D(^DIC(11005)) S A1AEFILE=11004,A1AENAME="PATCH" ; JLI 150525
 I '$G(A1AEFAIL) S X=$$DELPAT I 'X D
 . W !,"Unable to delete test entries in "_A1AEFILE,!
 L -^XPD(9.6):1
 L -^A1AE(A1AEFILE):1
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL,BUILD
 Q
 ;
 ; Testing
 ;   32. REQB^A1AEF1(BUILD,.BMARR)
 ;   33. MULB^A1AEF1(BUILD,.BMARR)
 ;   34. $$BACTV^A1AEF1(BUILD)
 ;
UTP32 I '$G(A1AEFAIL) N RMA S X=$$GETARR("R",.RMA) I 'X D  Q
 . D FAIL^%ut("Unable to build RMA array")
 I '$G(A1AEFAIL) S X=$$CHKARR(.RMA,"R") D
 . D CHKEQ^%ut(0,X,"Testing REQB^A1AEF1 - dependencies FAILED!")
 Q
 ;
UTP33 I '$G(A1AEFAIL) N RMA S X=$$GETARR("M",.RMA) I 'X D  Q
 . D FAIL^%ut("Unable to build RMA array")
 I '$G(A1AEFAIL) S X=$$CHKARR(.RMA,"M") D
 . D CHKEQ^%ut(0,X,"Testing MULB^A1AEF1 -  members FAILED!")
 Q
 ;
 ; Check BUILD to see if it represents current or earlier
 ;  version of a package
UTP34 I '$G(A1AEFAIL) D
 . N RTN S RTN=$T(+0)
 . N BUILD,SAVBLD
 . S X=$$SETUP4 I 'X D  Q
 .. D FAIL^%ut("Unable to build array of BUILD names")
 . S X=$$SETUP5(.BUILD) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST builds")
 . S X=$$SETUP6(.BUILD,.RTN) I 'X D  Q
 .. D FAIL^%ut("Unable to complete entry of TEST patches")
 . M SAVBLD=BUILD
 . S X=$$BACTV^A1AEF1(BUILD(921))
 . S:$$BACTV^A1AEF1(BUILD(900))'=0 X=0
 . D CHKEQ^%ut(1,X,"Testing $$BACTV^A1AEF1 - Active Package FAILED!")
 Q
 ;
 ;
 ; Check RMA array gleaned from $T data in this routine
 ;   against the descendants found in REQB or MULB call
 ; ENTER
 ;    RMA   =   array of expected builds with dependancy
 ;              levels. Retrieved by $T in this routine
 ;    RM    =   "R" for REQB check
 ;              "M" for MULB check
 ; EXIT
 ;    X     =   0 no errors, 1 error
 ; example : RMA(2)="POO(1,""A1AEXTST*1*1"")=1"
CHKARR(RMA,RM) N NODE,POON S NODE=$NA(RMA)
 N X S X=0
 Q:'$D(RMA) 1
 F  S NODE=$Q(@NODE) Q:NODE'["RMA("  I @NODE="" D  Q:X
 . ; RMA(N)=""
 .  S X=$$CHK1($QS(NODE,1),RM)
 Q X
 ;
 ; Enter with N = subscript in RMA(N) array
CHK1(N,RM) N POO,RMANODE
 S RMANODE=$NA(RMA(N))
 S RMANODE=$Q(@RMANODE) I RMANODE'["RMA(" Q 0
 ; Cut build name out of @RMANODE
 N BLDNM S BLDNM=$QS($P(@RMANODE,"="),2)
 ; Get all descendents
 N RBMB S RBMB=$S(RM["R":"REQB",RM["M":"MULB",1:1)
 Q:+RBMB=1 1
CHK2 D @(RBMB_"^A1AEF1(BLDNM,.POO)")
 ; Get first array in descendants array
 N PND S PND=$NA(POO(0,0)),PND=$Q(@PND)
 S X=0
 ; Run through RMA and POO nodes in parallel looking
 ;  for any mismatches
CHK3 F  D  Q:X  S RMANODE=$Q(@RMANODE),PND=$Q(@PND) I @RMANODE="" S X=0 Q
 . I $QS($P(@RMANODE,"="),2)'=$P(PND,"""",2) S X=1 Q
 . I @$P(@RMANODE,"=")'=@PND S X=1 Q
 Q X
 ;
 ;
 ; ENTER
 ;   BUILD  = BUILD(28) "A1AEXTST*1*28"
 ;   RM     = "R" for REQB, "M" for MULB
 ; EXIT
 ;   X      = 0 for ok, 1 for error
LOADSCD(BUILD,RM) ;
 ;Run API to find REQB dependancies and enter into the REQB
 ;   multiple of the container BUILD ("A1AEXTST*1*28")
 N X
 I 'RM?1"R",'RM?1"M" Q 1
 I RM="R" S X=$$A1AEFRQB^A1AEF1(BUILD) Q:'X 1
 I RM="M" S X=$$A1AEFMUB^A1AEF1(BUILD) Q:'X 1
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN 1
 K RMA S RMA=""
LDSCD1 N ARR,BLD,CNT,X,XXX S (CNT,X)=1
 S XXX=$S(RM="R":"A1AEFRB",RM="M":"A1AEFMB",1:"ERROR")
 Q:XXX["ERROR" 1
 F  S RMA=$T(@XXX+CNT^A1AEUF5E) Q:RMA["/END/"  Q:RMA=""  D  Q:'X
 . S BLD=$P(RMA,";;",2)
 . I RM="R" S X=$O(^XPD(9.6,BIEN,"REQB","B",BLD,0)) Q:'X
 . I RM="M" S X=$O(^XPD(9.6,BIEN,10,"B",BLD,0)) Q:'X
 . S CNT=CNT+1
 ; All RMA had a match in 9.6
 Q:'X 1  Q 0
 ;
 ;
 ; Look through routine file and find routine with a second
 ;   line which reflects active package and sufficient
 ;   patches for testing. If necessary patches will be
 ;   temporarily added to 11005.
 ;ENTER
 ;   RTN  = var for ROUTINE NAME passed by referece
 ;   POO  = array passed by reference for PATCHES needed
 ;          to build second line of selected rotine
 ;RETURN
 ;   0 = error, 1 = successful
 ;         also
 ;   RTN  = ROUTINE NAME [eg. DG10]
 ;   POO  = array of PATCHES NEEDED
 ;        example
 ;         POO("DG*5.3*232")=""
 ;         POO("DG*5.3*754")=129209   <<< patch ien into 11005
 ;         POO("DG*5.3*803")=""
BLDPARR(POO,RTN) K POO,RTN S RTN=""
 N IEN,LNG,NODE,X S NODE=$NA(^DIC(9.8,"B")),(LNG,X)=0
 F  S NODE=$Q(@NODE) Q:NODE'["^DIC(9.8,""B"""  D  Q:LNG>90
 . S IEN=$QS(NODE,4) I $O(^DIC(9.8,IEN,8,"A"),-1) D
 .. S RTN=$QS(NODE,3)
 ..; W !,RTN
 ..; Watch for routines like MPIFAPI in FOIA release
 ..;  where the package name begins with a space
 .. I $E($P($T(+2^@RTN),";",4))=" " Q
 ..; Watch for package name on 2nd line that doesn't
 ..;  match that in package file
 .. N LN2 S LN2=$T(+2^@RTN)
 .. N A1AEVR S A1AEVR=$P(LN2,";",3)
 .. N A1AESNM S A1AESNM=$$UP^A1AEF1($P(LN2,";",4))
 .. Q:A1AESNM=""
 .. N A1AESIEN S A1AESIEN=$O(^DIC(9.4,"B",A1AESNM,0))
 .. Q:A1AESIEN=""
 .. N A1AESABB S A1AESABB=$$GET1^DIQ(9.4,A1AESIEN_",",1)
 .. Q:A1AESABB=""
 ..;
 .. S LNG=$L($T(+2^@RTN)) Q:LNG<91
 ..; Build POO array of patch names from 2nd line of routine
 .. D PTC4RTN^A1AEF1(RTN,.POO) I '$D(POO) S X=0 Q
 ..; Confirm array has usable patch names
 .. S X=$$CONFRM(.POO)
 ..; If array not good, force looking for another
 .. I 'X S LNG="" Q
 ..; Make sure there are entries in 11005 for these patches
 .. S POO="" F  S POO=$O(POO(POO)) Q:POO=""  D
 ... S POO(POO)=$$MKPATCH(POO,RTN)
 Q:$G(LNG) 1  Q 0
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
 ; Build an array of bogus BUILD NAMES
 ; ENTER
 ;   nothing required
 ; RETURN
 ;   0 = error, 1 = array built
SETUP4() N I
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
SETUP5(BUILD) N X,I
 F I=900:1:921 D  Q:'X
 . S X=$$LDBLD2(BUILD(I)) Q:'X
 . S BUILD(BUILD(I))=X
 . S X=$$LDINST2(BUILD(I)) Q:'X
 . S BUILD(BUILD(I))=BUILD(BUILD(I))_"^"_X
 Q:X 1  Q X
 ;
 ; Load new patches into DHCP PATCHES [#11005] file
 ; ENTER
 ;   BUILD  = array of build names by reference
 ;   RTN    = name of running routine
 ; RETURN
 ;   0 = error, 1 = PATCHES successfully added to 11005
 ;                  BUILD array updated again
SETUP6(BUILD,RTN) N PD S PD=" "
 F  S PD=$O(BUILD(PD)) Q:PD=""  D
 . S X=$$MKPATCH(PD,.RTN) Q:'X  D
 . S BUILD(PD)=$P($G(BUILD(PD)),"^",1,2)_"^"_X
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
 ;Load new BUILD [#9.6] entry
 ;ENTER
 ;  BUILD   =  Build name
 ;RETURN
 ;  IEN of new BUILD entry OR 0_"^DIERR"
LDBLD(BUILD) ;
 N X,Y
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
 ;Load new BUILD [#9.6] entry and corresponding INSTALL entry
 ;ENTER
 ;  BUILD   =  Build name
 ;RETURN
 ;  0 = error,  n = IEN of successful entry in 9.6
LDBLD2(BUILD) ;
 Q:BUILD="" 0_"^No BUILD Name"
 S X=$O(^XPD(9.6,"B",BUILD,0)) Q:X X
 N DIERR,FDA,FDAIEN,X,Y
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
LDINST2(BUILD) ;
 Q:BUILD="" 0_"^No BUILD Name"
 S X=$O(^XPD(9.7,"B",BUILD,0)) Q:X X
 N DIERR,FDA,FDAIEN,X,Y
 S FDA(3,9.7,"?+1,",.01)=BUILD
 S FDA(3,9.7,"?+1,",.02)=3
 S FDA(3,9.7,"?+1,",2)=$$HTFM^XLFDT($H,1)
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 I $D(DIERR) Q 0
 Q +$G(FDAIEN(1))
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
 N FDA,DIERR,FDAIEN,X,Y
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
 N FDA,DIERR,FDAIEN,X,Y
 S FDA(3,9.611,"?+1,"_A1AEKI_",",.01)=RBUILD
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 Q:$D(DIERR) 0_"^DIERR"
 Q +FDAIEN(1)
 ;
 ;
 ; ENTER
 ;   RM    = "R" or "M" for REQB or MULB lookup
 ;           "F" for other
 ;   RMA   =  Passed by reference
 ; EXIT
 ;   RMA   = Array of builds from data listed
 ;           in routine
 ;   X     = 1 all ok, 0 = failure to match
GETARR(RM,RMA) ;
 I 'RM?1"R",'RM?1"M" Q 0
 N RME S RME=$S(RM="R":"REQBCHK",RM="M":"MULBCHK")
 ;I RM="F" S RME="A1AEFRB"
 K RMA
 N ARR,CNT S CNT=0
 F  S RMA=$T(@RME+CNT^A1AEUF5E) Q:RMA["/END/"  Q:RMA=""  D
 . S ARR=$P($T(@RME+CNT^A1AEUF5E),";;",2)
 . S CNT=CNT+1,RMA(CNT)=ARR
 ; if no RMA nodes, then error
 Q:'CNT 0
 Q 1
 ;
 ;
 ; Delete all test build entries
 ; RETURN
 ;  1 if no errors, 0_"^DIERR" if deletion failed
DELTBLDS() N DA,DIK,X,Y S X=1
 N NODE S NODE=$NA(^XPD(9.6,"B","A1AEXTST*1"))
 F  S NODE=$Q(@NODE) Q:NODE'["A1AEXTST*1"  D  Q:'X
 .  N DA,DIK,DIERR
 .  S DA=$QS(NODE,4)
 .  S DIK="^XPD(9.6,"
 .  D ^DIK
 .  S:$D(DIERR) X=0_"^DIERR"
 Q:X 1  Q X
 ;
 ; Delete all test build entries
 ; RETURN
 ;  1 if no errors, 0 if deletion failed
 ;  Nothing to delete returns 1 for no errors
DELTBLDZ() N DA,DIK,X,Y S X=1
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
 ; Confirm array has usable patch names (e.g. 3 * pieces)
 ; ENTER
 ;   POO   =  array of patch names
 ; RETURN
 ;   0 = not have usable names, 1 = names ok
CONFRM(POO) N PNM,X,Y S PNM="",Y=0,X=1
 F  S PNM=$O(POO(PNM)) Q:PNM=""  D  Q:'X
 .  I $L(PNM,"*")'=3 S X=0 Q
 Q X
 ;
 ;
 ; ENTER
 ;    PD   =  PATCH DESIGNATION
 ;    RTN  =  ROUTINE NAME to add to 11005 PD entry
 ; RETURNS
 ;    0 = error,  IEN of patch if successful
MKPATCH(PD,RTN) Q:PD="" 0
 N X,Y,DA,DIC,DIEN
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525
 N PKGIEN S PKGIEN=$O(^DIC(9.4,"C",$P(PD,"*"),0)) Q:PKGIEN="" 0
 N PKGAV S PKGAV=$$GET1^DIQ(9.4,PKGIEN_",",13) Q:'PKGAV 0
 N PTCHNB S PTCHNB=+$P(PD,"*",3) Q:'PTCHNB 0
 N PTSTRM S PTSTRM=$S(PTCHNB>10001:10001,1:1)
 N FDAIEN
 ; If already entry in 11005, move on to adding RTN
 I +$O(^A1AE(A1AEFILE,"B",PD,0)) D
 . S FDAIEN(1)=+$O(^A1AE(A1AEFILE,"B",PD,0))
 E  D
 . N DIERR
 . S FDA(3,A1AEFILE,"?+1,",.01)=PD
 . S FDA(3,A1AEFILE,"?+1,",.2)=PTSTRM
 . S FDA(3,A1AEFILE,"?+1,",2)=PKGIEN
 . S FDA(3,A1AEFILE,"?+1,",3)=PKGAV
 . S FDA(3,A1AEFILE,"?+1,",4)=PTCHNB
 . S FDA(3,A1AEFILE,"?+1,",5)="A1AE TEST ZZZFOR UNIT TESTS"
 . D UPDATE^DIE("","FDA(3)","FDAIEN")
 ;W "NEW ENTRY=",+$G(FDAIEN(1))
 Q:$D(DIERR) 0
 K DIERR,FDA
 N FDARIEN S FDARIEN=+$G(FDAIEN(1)) Q:'FDARIEN 0
 K FDAIEN
 S FDA(3,+(A1AEFILE_".03"),"?+1,"_FDARIEN_",",.01)=RTN
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 Q:$D(DIERR) 0
 Q FDARIEN
 ;
 ; ENTER
 ;   nothing required
 ; RETURN
 ;   0 = error, 1 = deletions complete
DELPAT() N DA,DIK,PAT,NOERR,X,Y S PAT=0,NOERR=1
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525
 F  S PAT=$O(^A1AE(A1AEFILE,PAT)) Q:'PAT  D  Q:'NOERR
 . I $P(^A1AE(A1AEFILE,PAT,0),"^",5)["A1AE TEST ZZZFOR UNIT TESTS" D
 .. S DIK="^A1AE(A1AEFILE," S DA=+PAT D ^DIK S:$D(DIERR) NOERR=0
 I NOERR S PAT=0 D
 . F  S PAT=$O(^A1AE(A1AEFILE,PAT)) Q:'PAT  D  Q:'NOERR
 .. I $P(^A1AE(A1AEFILE,PAT,0),"^",5)["A1AE TEST ZZZFOR UNIT TESTS" D
 ... S NOERR=0
 Q NOERR
 ;
 ;
UP(STR) Q $TR(STR,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 ;
 ;
XTENT ;
 ;;UTP32;Testing REQB^A1AEF1 - REQB descendants
 ;;UTP33;Testing MULB^A1AEF1 - MULB descendants
 ;;UTP34;Testing $$BACTV^A1AEF1 - Active Package
 Q
