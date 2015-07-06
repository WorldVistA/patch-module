A1AEUF5C ;ven/lgc,jli-unit tests for A1AEF5 ; 6/4/15 1:00am
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
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
 N A1AEFILE S A1AEFILE=11005,A1AENAME="DHCP PATCHES" I '$D(^DIC(11005)) S A1AEFILE=11004,A1AENAME="PATCH" ; JLI 150525 
 L +^A1AE(A1AEFILE):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on "_A1AENAME_" [#"_A1AEFILE_"] file"
 . W !," Unable to perform testing."
 Q
 ;
SHUTDOWN L -^XPD(9.6):1
 N A1AEFILE S A1AEFILE=11005,A1AENAME="DHCP PATCHES" I '$D(^DIC(11005)) S A1AEFILE=11004,A1AENAME="PATCH" ; JLI 150525 
 L -^A1AE(A1AEFILE):1
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ;
 ; Count total nodes in ^XTMP($J as indicator of
 ;  complexity of relationships
 ; ENTER
 ;   ^XTMP($J
 ; RETURN
 ;   Count of nodes
 ; --- CNTNODES()
UTP45  I '$G(A1AEFAIL) D
 . N TSTBLD S TSTBLD=$$FNDONE
 . N BUILD S BUILD=$P(TSTBLD,"^")
 . I (BUILD="")!('$O(^XPD(9.6,"B",BUILD,0))) D  Q
 .. D FAIL^%ut("Unable to find suitable test BUILD")
 . N MSG S MSG=$$FNDALL^A1AEF5(BUILD,1)
 . I MSG="" D  Q
 .. D FAIL^%ut("Unable to build array in ^XTMP($J)")
 . N CNTNODES S CNTNODES=$$CNTNODES^A1AEF5
 . I '$G(CNTNODES) D  Q
 .. D FAIL^%ut("Unable count nodes in ^XTMP($J)")
 . N NODE,SNODE S NODE=$NA(^XTMP($J)),SNODE=$P(NODE,")")
 . N NEWCNT S NEWCNT=0
 . F  S NODE=$Q(@NODE) Q:NODE'[SNODE  S NEWCNT=NEWCNT+1
 . N X S X=(CNTNODES=NEWCNT)
 . D CHKEQ^%ut(1,X,"Testing $$CNTNODES^A1AEF5 - Counting nodes in ^XTMP($J) FAILED!")
 Q
 ;
 ;
 ; ENTER
 ;   Nothing required
 ; RETURNS
 ;   CNT  =  Count of BUILDS in ^XTMP array that
 ;           represent a current version of their package
 ; --- CNTBLDS()
UTP46 I '$G(A1AEFAIL) D
 . N TSTBLD S TSTBLD=$$FNDONE
 . N BUILD S BUILD=$P(TSTBLD,"^")
 . I (BUILD="")!('$O(^XPD(9.6,"B",BUILD,0))) D  Q
 .. D FAIL^%ut("Unable to find suitable test BUILD")
 . N MSG S MSG=$$FNDALL^A1AEF5(BUILD,1)
 . I MSG="" D  Q
 .. D FAIL^%ut("Unable to build array in ^XTMP($J)")
 . N CNTBLDS S CNTBLDS=$$CNTBLDS^A1AEF5
 . I '$G(CNTBLDS) D  Q
 .. D FAIL^%ut("Unable to find builds in ^XTMP($J)")
 . N BLD,NEWCNT S BLD=" ",NEWCNT=0
 . F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 ..  S:$$BACTV^A1AEF1(BLD) NEWCNT=NEWCNT+1
 . N X S X=(CNTBLDS=NEWCNT)
 . D CHKEQ^%ut(1,X,"Testing $$CNTBLDS^A1AEF5 - Counting builds in ^XTMP($J) FAILED!")
 Q
 ;
 ;
 ; Build array of all routines contained in a BUILD
 ; ENTER
 ;   BUILD  = NAME OF BUILD
 ;   RTNARR = ARRAY PASSED BY REFERENCE
 ; RETURN
 ;   RTNARR   = ARRAY OF ROUTINES IN BUILD
 ; --- RTNSINB(BUILD,RTNARR)
 ; Look for build with lots of routines
UTP47 I '$G(A1AEFAIL) D
 . N BIEN,CNT,RTNARR,X S (BIEN,CNT)=0
 . F  Q:$G(CNT)>10  S BIEN=$O(^XPD(9.6,BIEN)) Q:'BIEN  D
 .. S CNT=$P($G(^XPD(9.6,BIEN,"KRN",9.8,"NM",0)),"^",4)
 . S:'BIEN X=0
 . N BUILD S BUILD=$P($G(^XPD(9.6,BIEN,0)),"^")
 . D RTNSINB^A1AEF5(BUILD,.RTNARR)
 . N RTN S RTN=0,X=1
 . F  Q:'X  S RTN=$O(^XPD(9.6,BIEN,"KRN",9.8,"NM","B",RTN)) Q:RTN=""  D
 .. S:'$D(RTNARR(RTN)) X=0
 . D CHKEQ^%ut(1,X,"Testing RTNSINB^A1AEF5 - Building array of RTNS in a build FAILED!")
 Q
 ;
 ;
 ;
 ; Display all builds associated with the parent BUILD
 ;   which belong to a currently active package
 ; ENTER
 ;    BUILD = name of parent BUILD under inspection
 ;    MSG   = 1:build MSGTXT
 ;            0:print statistics to terminal
 ; RETURN
 ;    Number of builds displayed to terminal
 ;DISP(BUILD,MSG)
UTP48 I '$G(A1AEFAIL) D
 . N TSTBLD S TSTBLD=$$FNDONE
 . N BUILD S BUILD=$P(TSTBLD,"^")
 . I (BUILD="")!('$O(^XPD(9.6,"B",BUILD,0))) D  Q
 .. D FAIL^%ut("Unable to find suitable test BUILD")
 . N MSG S MSG=$$FNDALL^A1AEF5(BUILD,1)
 . I MSG="" D  Q
 .. D FAIL^%ut("Unable to build array in ^XTMP($J)")
 . N BLDS S BLDS=$$DISP^A1AEF5(BUILD,1)
 . N BLD,CNT S BLD=" ",CNT=0
 . F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. I $$BACTV^A1AEF1(BLD) S CNT=CNT+1
 . N X S X=(BLDS=CNT)
 . D CHKEQ^%ut(1,X,"$$DISP^A1AEF5 - Display all associated builds FAILED!")
 Q
 ;
 ;
 ; Display all builds associated with the parent BUILD
 ;   which belong to a currently active package
 ; AND
 ;   Limiting associated builds to a single example
 ;     of each patch array not belonging to the
 ;     package of the parent BUILD being examined
 ; ENTER
 ;    BUILD = name of parent BUILD under inspection
 ;    MSG   = 1:build MSGTXT
 ;            0:print statistics to terminal
 ; RETURN
 ;    BLDARR    = array of builds identified
 ;    BLDARR(0) = Number of builds displayed to terminal
 ; --- DISPLMT(BUILD,BLDARR)
UTP49 I '$G(A1AEFAIL) D
 . N TSTBLD S TSTBLD=$$FNDONE
 . N BUILD S BUILD=$P(TSTBLD,"^")
 . I (BUILD="")!('$O(^XPD(9.6,"B",BUILD,0))) D  Q
 .. D FAIL^%ut("Unable to find suitable test BUILD")
 . N MSG S MSG=$$FNDALL^A1AEF5(BUILD,1)
 . I MSG="" D  Q
 .. D FAIL^%ut("Unable to build array in ^XTMP($J)")
 . N BLDARR D DISPLMT^A1AEF5(BUILD,.BLDARR)
 . N LMTCNT S LMTCNT=$G(BLDARR(0))
 . I '$G(LMTCNT) D  Q
 .. D FAIL^%ut("Unable to calculate Limited Builds count!")
 . N BLD S BLD=" "
 . K BLDARR
 . F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. I $$BACTV^A1AEF1(BLD) D
 ... I $P(BLD,"*")=$P(BUILD,"*") S BLDARR($P(BLD,"*"))="" Q
 ... Q:$D(BLDARR($P(BLD,"*")))
 ... S BLDARR($P(BLD,"*"))=""
 . N CNT,NODE S CNT=0,NODE=$NA(BLDARR)
 . F  S NODE=$Q(@NODE) Q:NODE'["BLDARR("  D
 ..  S CNT=CNT+1
 . N X S X=(LMTCNT=CNT)
 . D CHKEQ^%ut(1,X,"Testing DISPLMT^A1AEF5 - Display limited array of builds FAILED!")
 Q
 ;
 ;
 ;
UTP50 I '$G(A1AEFAIL) D
 . N BLDMSG,BUILD,BIEN,CNT,REQBIEN
 . S BLDMSG=$$FNDONE(),BUILD=$P(BLDMSG,"^")
 . N BIEN S BIEN=$P(BLDMSG,"^",2)
 . I BIEN'=$O(^XPD(9.6,"B",BUILD,0)) D  Q
 .. D FAIL^%ut("BIEN from FNDONE call in error!")
 . S REQBIEN=0
 . F  S REQBIEN=$O(^XPD(9.6,BIEN,"REQB",REQBIEN)) Q:'REQBIEN  D
 ..  S CNT=$G(CNT)+1
 . N X S X=(CNT=$P(BLDMSG,"^",3))
 . D CHKEQ^%ut(1,X,"Testing FINDONE^A1AEUF5C - Find a build with several REQB FAILED!")
 Q
 ;
 ; Look through BUILD [#9.6] file and find one with a
 ;   number of REQB entries.  Hopefully this will flesh
 ;   out to one with enough components to allow for
 ;   a good test of these APIs.
 ; Enter
 ;   nothing required
 ; Return
 ;   A string with BuildName^BuildIEN^NumberOfREQB
FNDONE() N BIEN,CNT,I F I=40:-1:1 D  Q:BIEN
 . S (BIEN,CNT)=0
 . F  Q:$G(CNT)>I  S BIEN=$O(^XPD(9.6,BIEN)) Q:'BIEN  D
 .. S CNT=$P($G(^XPD(9.6,BIEN,"REQB",0)),"^",4)
 Q $P($G(^XPD(9.6,BIEN,0)),"^")_"^"_BIEN_"^"_$P($G(^XPD(9.6,BIEN,"REQB",0)),"^",4)
 ;
XTENT ;
 ;;UTP45;Testing $$CNTNODES^A1AEF5 - Counting nodes in ^XTMP($J
 ;;UTP46;Testing $$CNTBLDS^A1AEF5 - Counting builds in ^XTMP($J
 ;;UTP47;Testing RTNSINB^A1AEF5 - Building array of RTNS in a build
 ;;UTP48;Testing $$DISP^A1AEF5 - Display all associated builds
 ;;UTP49;Testing DISPLMT^A1AEF5 - Display limited array of builds
 ;;UTP50;Testing FINDONE^A1AEUF5C - Find a build with several REQB
 Q
 ;
 ;
EOR ; end of routine A1AEUF5C
