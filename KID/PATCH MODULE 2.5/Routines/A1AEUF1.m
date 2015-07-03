A1AEUF1 ;ven/lgc,jli-unit tests for A1AEF1 ;2015-06-13  9:03 PM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
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
 L -^XPD(9.6):1
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL,BUILD
 Q
 ;
 ; Testing
 ;   1. REQB^A1AEF1(BUILD,.BMARR)
 ;   2. MULB^A1AEF1(BUILD,.BMARR)
 ;   3. A1AEFRQB^A1AEF1(BUILD)
 ;   4. A1AEFMUB^A1AEF1(BUILD)
 ;
 ;
UTP1 I '$G(A1AEFAIL) S X=$$GETARR("R",.RMA) I 'X D  Q
 . D FAIL^%ut("Unable to build RMA array")
 I '$G(A1AEFAIL) S X=$$CHKARR(.RMA,"R") D
 . D CHKEQ^%ut(0,X,"Testing REQB dependencies FAILED!")
 Q
 ;
UTP2 I '$G(A1AEFAIL) S X=$$GETARR("M",.RMA) I 'X D  Q
 . D FAIL^%ut("Unable to build RMA array")
 I '$G(A1AEFAIL) S X=$$CHKARR(.RMA,"M") D
 . D CHKEQ^%ut(0,X,"Testing MULB memebers FAILED!")
 Q
 ;
 ;
UTP3 I '$G(A1AEFAIL) S X=$$GETARR("R",.RMA) I 'X D  Q
 . D FAIL^%ut("Unable to build RMA array")
 I '$G(A1AEFAIL) S X=$$LOADSCD(BUILD(28),"R") D
 . D CHKEQ^%ut(0,X,"Testing LOADING REQB dependencies FAILED!")
 Q
 ;
UTP4 I '$G(A1AEFAIL) S X=$$GETARR("M",.RMA) I 'X D  Q
 . D FAIL^%ut("Unable to build RMA array")
 I '$G(A1AEFAIL) S X=$$LOADSCD(BUILD(29),"M") D
 . D CHKEQ^%ut(0,X,"Testing LOADING MULB dependencies FAILED!")
 Q
 ;
 ;
UTP5 I '$G(A1AEFAIL) D
 . N BIEN,REQBIEN,MULBIEN
 . S BIEN=$O(^XPD(9.6,"B","A1AEXTST*1*1",0)) I 'BIEN D  Q
 .. D FAIL^%ut("Unable to find BUILD A1AEXTST*1*1 in 9.6")
 .;
 . S REQBIEN=$O(^XPD(9.6,BIEN,"REQB","B","A1AEXTST*1*2",0))
 . I REQBIEN D
 ..  K ^XPD(9.6,BIEN,"REQB",REQBIEN)
 ..  K ^XPD(9.6,BIEN,"REQB","B","A1AEXTST*1*2")
 . S REQBIEN=$O(^XPD(9.6,BIEN,"REQB","B","A1AEXTST*1*2",0))
 . I REQBIEN D  Q
 .. D FAIL^%ut("Unable to clear REQB A1AEXTST*1*2")
 .;
 . S MULBIEN=$O(^XPD(9.6,BIEN,10,"B","A1AEXTST*1*2",0))
 . I MULBIEN D
 ..  K ^XPD(9.6,BIEN,10,MULBIEN)
 ..  K ^XPD(9.6,BIEN,10,"B","A1AEXTST*1*2")
 . S MULBIEN=$O(^XPD(9.6,BIEN,10,"B","A1AEXTST*1*2",0))
 . I MULBIEN D  Q
 .. D FAIL^%ut("Unable to clear MULB A1AEXTST*1*2")
 .;
 . S X='$$ADBTORM^A1AEF1(BIEN,"A1AEXTST*1*2","R")
 . S Y='$$ADBTORM^A1AEF1(BIEN,"A1AEXTST*1*2","M")
 . D CHKEQ^%ut(0,X+Y,"Testing LOADING new REQB and MULB FAILED!")
 Q
 ;
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
CHK1(N,RM) N POO K RMANODE
 S RMANODE=$NA(RMA(N))
 S RMANODE=$Q(@RMANODE) I RMANODE'["RMA(" Q 0
 ; Cut build name out of @RMANODE
 N BLDNM S BLDNM=$QS($P(@RMANODE,"="),2)
 ; Get all descendents
 N RBMB S RBMB=$S(RM["R":"REQB",RM["M":"MULB",1:1)
 Q:+RBMB=1 1
CHK2 D @(RBMB_"^A1AEF1(BLDNM,.POO)")
 ; Get first array in descendants array
 K PND S PND=$NA(POO(0,0)),PND=$Q(@PND)
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
 I 'RM?1"R",'RM?1"M" Q 1
 I RM="R" S X=$$A1AEFRQB^A1AEF1(BUILD) Q:'X 1
 I RM="M" S X=$$A1AEFMUB^A1AEF1(BUILD) Q:'X 1
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN 1
 K RMA S RMA=""
LDSCD1 N ARR,BLD,CNT,X,XXX S (CNT,X)=1
 S XXX=$S(RM="R":"A1AEFRB",RM="M":"A1AEFMB",1:"ERROR")
 Q:XXX["ERROR" 1
 F  S RMA=$T(@XXX+CNT) Q:RMA["/END/"  D  Q:'X
 . S BLD=$P(RMA,";;",2)
 . I RM="R" S X=$O(^XPD(9.6,BIEN,"REQB","B",BLD,0)) Q:'X
 . I RM="M" S X=$O(^XPD(9.6,BIEN,10,"B",BLD,0)) Q:'X
 . S CNT=CNT+1
 ; All RMA had a match in 9.6
 Q:'X 1  Q 0
 ;
 ;
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
 F  S RMA=$T(@RME+CNT) Q:RMA["/END/"  D
 . S ARR=$P($T(@RME+CNT),";;",2)
 . S CNT=CNT+1,RMA(CNT)=ARR
 ; if no RMA nodes, then error
 Q:'CNT 0
 Q 1
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
 ;
XTENT ;
 ;;UTP1;Testing gathering of all REQB descendants
 ;;UTP2;Testing gathering of all MULB descendants
 ;;UTP3;Testing gathering and loading REQB descendants
 ;;UTP4;Testing gathering and loading MULB descendants
 ;;UTP5;Testing adding new MULB and REQB to a build
 Q
 ;
 ;
REQBCHK ;;
 ;;POO(1,"A1AEXTST*1*1")=1
 ;;
 ;;POO(1,"A1AEXTST*1*2")=1
 ;;
 ;;POO(1,"A1AEXTST*1*3")=1
 ;;
 ;;POO(1,"A1AEXTST*1*4")=1
 ;;
 ;;POO(1,"A1AEXTST*1*5")=1
 ;;
 ;;POO(1,"A1AEXTST*1*6")=1
 ;;
 ;;POO(1,"A1AEXTST*1*7")=1
 ;;
 ;;POO(1,"A1AEXTST*1*8")=1
 ;;
 ;;POO(1,"A1AEXTST*1*9")=1
 ;;
 ;;POO(1,"A1AEXTST*1*10")=1
 ;;POO(2,"A1AEXTST*1*1")=2
 ;;POO(3,"A1AEXTST*1*2")=2
 ;;POO(4,"A1AEXTST*1*3")=2
 ;;POO(5,"A1AEXTST*1*4")=2
 ;;POO(6,"A1AEXTST*1*5")=2
 ;;
 ;;POO(1,"A1AEXTST*1*11")=1
 ;;POO(2,"A1AEXTST*1*12")=2
 ;;POO(3,"A1AEXTST*1*13")=2
 ;;POO(4,"A1AEXTST*1*14")=2
 ;;POO(5,"A1AEXTST*1*15")=2
 ;;
 ;;POO(1,"A1AEXTST*1*12")=1
 ;;
 ;;POO(1,"A1AEXTST*1*13")=1
 ;;
 ;;POO(1,"A1AEXTST*1*14")=1
 ;;
 ;;POO(1,"A1AEXTST*1*15")=1
 ;;
 ;;POO(1,"A1AEXTST*1*16")=1
 ;;
 ;;POO(1,"A1AEXTST*1*17")=1
 ;;
 ;;POO(1,"A1AEXTST*1*18")=1
 ;;
 ;;POO(1,"A1AEXTST*1*19")=1
 ;;
 ;;POO(1,"A1AEXTST*1*20")=1
 ;;
 ;;POO(1,"A1AEXTST*1*21")=1
 ;;
 ;;POO(1,"A1AEXTST*1*22")=1
 ;;
 ;;POO(1,"A1AEXTST*1*23")=1
 ;;
 ;;POO(1,"A1AEXTST*1*24")=1
 ;;
 ;;POO(1,"A1AEXTST*1*25")=1
 ;;
 ;;POO(1,"A1AEXTST*1*26")=1
 ;;
 ;;POO(1,"A1AEXTST*1*27")=1
 ;;
 ;;POO(1,"A1AEXTST*1*28")=1
 ;;POO(2,"A1AEXTST*1*10")=2
 ;;POO(3,"A1AEXTST*1*1")=3
 ;;POO(4,"A1AEXTST*1*2")=3
 ;;POO(5,"A1AEXTST*1*3")=3
 ;;POO(6,"A1AEXTST*1*4")=3
 ;;POO(7,"A1AEXTST*1*5")=3
 ;;POO(8,"A1AEXTST*1*11")=2
 ;;POO(9,"A1AEXTST*1*12")=3
 ;;POO(10,"A1AEXTST*1*13")=3
 ;;POO(11,"A1AEXTST*1*14")=3
 ;;POO(12,"A1AEXTST*1*15")=3
 ;;POO(13,"A1AEXTST*1*21")=2
 ;;POO(14,"A1AEXTST*1*22")=2
 ;;POO(15,"A1AEXTST*1*23")=2
 ;;POO(16,"A1AEXTST*1*24")=2
 ;;POO(17,"A1AEXTST*1*25")=2
 ;;
 ;;POO(1,"A1AEXTST*1*29")=1
 ;;POO(2,"A1AEXTST*1*28")=2
 ;;POO(3,"A1AEXTST*1*10")=3
 ;;POO(4,"A1AEXTST*1*1")=4
 ;;POO(5,"A1AEXTST*1*2")=4
 ;;POO(6,"A1AEXTST*1*3")=4
 ;;POO(7,"A1AEXTST*1*4")=4
 ;;POO(8,"A1AEXTST*1*5")=4
 ;;POO(9,"A1AEXTST*1*11")=3
 ;;POO(10,"A1AEXTST*1*12")=4
 ;;POO(11,"A1AEXTST*1*13")=4
 ;;POO(12,"A1AEXTST*1*14")=4
 ;;POO(13,"A1AEXTST*1*15")=4
 ;;POO(14,"A1AEXTST*1*21")=3
 ;;POO(15,"A1AEXTST*1*22")=3
 ;;POO(16,"A1AEXTST*1*23")=3
 ;;POO(17,"A1AEXTST*1*24")=3
 ;;POO(18,"A1AEXTST*1*25")=3
 ;;
 ;;POO(1,"A1AEXTST*1*30")=1
 ;;POO(2,"A1AEXTST*1*29")=2
 ;;POO(3,"A1AEXTST*1*28")=3
 ;;POO(4,"A1AEXTST*1*10")=4
 ;;POO(5,"A1AEXTST*1*1")=5
 ;;POO(6,"A1AEXTST*1*2")=5
 ;;POO(7,"A1AEXTST*1*3")=5
 ;;POO(8,"A1AEXTST*1*4")=5
 ;;POO(9,"A1AEXTST*1*5")=5
 ;;POO(10,"A1AEXTST*1*11")=4
 ;;POO(11,"A1AEXTST*1*12")=5
 ;;POO(12,"A1AEXTST*1*13")=5
 ;;POO(13,"A1AEXTST*1*14")=5
 ;;POO(14,"A1AEXTST*1*15")=5
 ;;POO(15,"A1AEXTST*1*21")=4
 ;;POO(16,"A1AEXTST*1*22")=4
 ;;POO(17,"A1AEXTST*1*23")=4
 ;;POO(18,"A1AEXTST*1*24")=4
 ;;POO(19,"A1AEXTST*1*25")=4
 ;;
 ;;/END/
 ;;
 ;;
 ;;
MULBCHK ;;
 ;;POO(1,"A1AEXTST*1*1")=1
 ;;
 ;;POO(1,"A1AEXTST*1*2")=1
 ;;
 ;;POO(1,"A1AEXTST*1*3")=1
 ;;
 ;;POO(1,"A1AEXTST*1*4")=1
 ;;
 ;;POO(1,"A1AEXTST*1*5")=1
 ;;
 ;;POO(1,"A1AEXTST*1*6")=1
 ;;
 ;;POO(1,"A1AEXTST*1*7")=1
 ;;
 ;;POO(1,"A1AEXTST*1*8")=1
 ;;
 ;;POO(1,"A1AEXTST*1*9")=1
 ;;
 ;;POO(1,"A1AEXTST*1*10")=1
 ;;POO(2,"A1AEXTST*1*6")=2
 ;;POO(3,"A1AEXTST*1*7")=2
 ;;POO(4,"A1AEXTST*1*8")=2
 ;;POO(5,"A1AEXTST*1*9")=2
 ;;
 ;;POO(1,"A1AEXTST*1*11")=1
 ;;POO(2,"A1AEXTST*1*16")=2
 ;;POO(3,"A1AEXTST*1*17")=2
 ;;POO(4,"A1AEXTST*1*18")=2
 ;;POO(5,"A1AEXTST*1*19")=2
 ;;POO(6,"A1AEXTST*1*20")=2
 ;;
 ;;POO(1,"A1AEXTST*1*12")=1
 ;;
 ;;POO(1,"A1AEXTST*1*13")=1
 ;;
 ;;POO(1,"A1AEXTST*1*14")=1
 ;;
 ;;POO(1,"A1AEXTST*1*15")=1
 ;;
 ;;POO(1,"A1AEXTST*1*16")=1
 ;;
 ;;POO(1,"A1AEXTST*1*17")=1
 ;;
 ;;POO(1,"A1AEXTST*1*18")=1
 ;;
 ;;POO(1,"A1AEXTST*1*19")=1
 ;;
 ;;POO(1,"A1AEXTST*1*20")=1
 ;;
 ;;POO(1,"A1AEXTST*1*21")=1
 ;;
 ;;POO(1,"A1AEXTST*1*22")=1
 ;;
 ;;POO(1,"A1AEXTST*1*23")=1
 ;;
 ;;POO(1,"A1AEXTST*1*24")=1
 ;;
 ;;POO(1,"A1AEXTST*1*25")=1
 ;;
 ;;POO(1,"A1AEXTST*1*26")=1
 ;;
 ;;POO(1,"A1AEXTST*1*27")=1
 ;;
 ;;POO(1,"A1AEXTST*1*28")=1
 ;;POO(2,"A1AEXTST*1*26")=2
 ;;POO(3,"A1AEXTST*1*27")=2
 ;;
 ;;POO(1,"A1AEXTST*1*29")=1
 ;;POO(2,"A1AEXTST*1*1")=2
 ;;POO(3,"A1AEXTST*1*11")=2
 ;;POO(4,"A1AEXTST*1*16")=3
 ;;POO(5,"A1AEXTST*1*17")=3
 ;;POO(6,"A1AEXTST*1*18")=3
 ;;POO(7,"A1AEXTST*1*19")=3
 ;;POO(8,"A1AEXTST*1*20")=3
 ;;POO(9,"A1AEXTST*1*28")=2
 ;;POO(10,"A1AEXTST*1*26")=3
 ;;POO(11,"A1AEXTST*1*27")=3
 ;;
 ;;POO(1,"A1AEXTST*1*30")=1
 ;;
 ;;/END/
 ;;
A1AEFRB ;;
 ;;A1AEXTST*1*1
 ;;A1AEXTST*1*10
 ;;A1AEXTST*1*11
 ;;A1AEXTST*1*12
 ;;A1AEXTST*1*13
 ;;A1AEXTST*1*14
 ;;A1AEXTST*1*15
 ;;A1AEXTST*1*2
 ;;A1AEXTST*1*21
 ;;A1AEXTST*1*22
 ;;A1AEXTST*1*23
 ;;A1AEXTST*1*24
 ;;A1AEXTST*1*25
 ;;A1AEXTST*1*3
 ;;A1AEXTST*1*4
 ;;A1AEXTST*1*5
 ;;/END/
 ;;
A1AEFMB ;;
 ;;A1AEXTST*1*1
 ;;A1AEXTST*1*11
 ;;A1AEXTST*1*16
 ;;A1AEXTST*1*17
 ;;A1AEXTST*1*18
 ;;A1AEXTST*1*19
 ;;A1AEXTST*1*20
 ;;A1AEXTST*1*26
 ;;A1AEXTST*1*27
 ;;A1AEXTST*1*28
 ;;/END/
