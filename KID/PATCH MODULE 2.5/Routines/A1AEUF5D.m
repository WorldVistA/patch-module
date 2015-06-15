A1AEUF5D ;ven/lgc,jli-unit tests for A1AEF5 ;2015-06-13  10:07 PM
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
 Q
 ;
SHUTDOWN L -^XPD(9.6):1
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 L -^A1AE(A1AEFILE):1
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ;
 ; ENTER
 ;    BUILD = name of PARENT build under inspection
 ;    MSG   = 1:build MSGTXT
 ;            0:print statistics to terminal
 ;    ^XTMP($J,BUILD
 ; RETURN
 ;    ^XTMP($J,BUILD updated
 ; --- FND4(BUILD,MSG,MSGTXT)
UTP42 I '$G(A1AEFAIL) D
 . N BLDMSG S BLDMSG=$$FNDONE^A1AEUF5B
 . N BUILD S BUILD=$P(BLDMSG,"^")
 . K ^XTMP($J)
 . N REQB,MULB S (REQB,MULB)=""
 . N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN
 . S ^XTMP($J,BUILD,BUILD)=BIEN
 .;
 . N CNT S CNT=0
 . S (REQB,MULB)=""
 . F  S REQB=$O(^XPD(9.6,BIEN,"REQB","B",REQB)) Q:REQB=""  D
 .. S CNT=CNT+1
 . F  S MULB=$O(^XPD(9.6,BIEN,10,"B",MULB)) Q:MULB=""  D
 .. S CNT=CNT+1
 .;
 . S (REQB,MULB)=""
 . D REQB^A1AEF1(BUILD,.REQB)
 . D MULB^A1AEF1(BUILD,.MULB)
 . S REQB=" " F  S REQB=$O(REQB(REQB)) Q:REQB=""  D
 .. S ^XTMP($J,BUILD,REQB)=REQB(REQB)
 . S MULB=" " F  S MULB=$O(MULB(MULB)) Q:MULB=""  D
 .. S ^XTMP($J,BUILD,MULB)=MULB(MULB)
 .;FND1
 . N MULBTMP,BLD
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D MULB^A1AEF1(BLD,.MULB)
 .. M MULBTMP=MULB
 .; Pull these into ^XTMP array
 . S MULB=" " F  S MULB=$O(MULBTMP(MULB)) Q:MULB=""  D
 .. S ^XTMP($J,BUILD,MULB)=MULBTMP(MULB)
 .;FND2
 . N RTNARR,RTNNM
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D RTNSINB^A1AEUF5B(BLD,.RTNARR)
 .. N PTCH,PTCHIEN,PTCHARR
 .. S RTNNM="" F  S RTNNM=$O(RTNARR(RTNNM)) Q:RTNNM=""  D
 ... D PTC4RTN^A1AEF1(RTNNM,.PTCHARR)
 ... Q:'$D(PTCHARR)
 ... S PTCH=" " F  S PTCH=$O(PTCHARR(PTCH)) Q:PTCH=""  D
 ....; Fix patches integer and no .0
 .... I $P(PTCH,"*",2)=$P($P(PTCH,"*",2),".") D
 ..... S $P(PTCH,"*",2)=$P(PTCH,"*",2)_".0"
 .... S PTCHIEN=+$O(^XPD(9.6,"B",PTCH,0))
 .... S ^XTMP($J,BUILD,PTCH)=PTCHIEN
 .... S ^XTMP($J,BUILD,PTCH,RTNNM,"R")=""
 .;FND3
 . N BLDIEN,DTINS S BLD=" "
 . F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. S BLDIEN=+$G(^XTMP($J,BUILD,BLD))
 .. I BLDIEN D
 ... S DTINS=$$DTINS^A1AEF2(BLD)
 ... D:DTINS LOADXTMP^A1AEF2(BUILD,BLDIEN,DTINS)
 .;FND4
 . N NMRICMP,NMCMP,NODE S NODE=$NA(^XPD(9.6))
 . F  S NODE=$Q(@NODE) Q:NODE'["^XPD(9.6"  D
 .. S BIEN=+$QS(NODE,2)
 .. I $QS(NODE,3)=4,$QS(NODE,2),$QS(NODE,4),$QS(NODE,5)=0 D
 ... N FNMBR S FNMBR=$QS(NODE,4)
 ... I $D(^XTMP($J,4,FNMBR)) D  Q
 .... S ^XTMP($J,BUILD,$P(^XPD(9.6,BIEN,0),"^"),"F")=+$QS(NODE,2)_"^"_FNMBR
 ..;
 .. I $QS(NODE,3)["KRN",$QS(NODE,4)["B" D
 ... S NMRICMP=$QS(NODE,5)
 ... S NMCMP=$QS(NODE,6)
 ... I $D(^XTMP($J,NMRICMP,NMCMP)) D
 .... S ^XTMP($J,BUILD,$P(^XPD(9.6,BIEN,0),"^"),"C")=BIEN_"^"_NMRICMP_"^"_NMCMP
 .; Save manual production
 . K ^TMP($J) M ^TMP($J)=^XTMP($J)
 .; Now run FND4 
 . K ^XTMP($J)
 . N REQB,MULB S (REQB,MULB)=""
 . N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN
 . S ^XTMP($J,BUILD,BUILD)=BIEN
 .;
 . N CNT S CNT=0
 . S (REQB,MULB)=""
 . F  S REQB=$O(^XPD(9.6,BIEN,"REQB","B",REQB)) Q:REQB=""  D
 .. S CNT=CNT+1
 . F  S MULB=$O(^XPD(9.6,BIEN,10,"B",MULB)) Q:MULB=""  D
 .. S CNT=CNT+1
 .;
 . S (REQB,MULB)=""
 . D REQB^A1AEF1(BUILD,.REQB)
 . D MULB^A1AEF1(BUILD,.MULB)
 . S REQB=" " F  S REQB=$O(REQB(REQB)) Q:REQB=""  D
 .. S ^XTMP($J,BUILD,REQB)=REQB(REQB)
 . S MULB=" " F  S MULB=$O(MULB(MULB)) Q:MULB=""  D
 .. S ^XTMP($J,BUILD,MULB)=MULB(MULB)
 .;FND1
 . N MULBTMP,BLD
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D MULB^A1AEF1(BLD,.MULB)
 .. M MULBTMP=MULB
 .; Pull these into ^XTMP array
 . S MULB=" " F  S MULB=$O(MULBTMP(MULB)) Q:MULB=""  D
 .. S ^XTMP($J,BUILD,MULB)=MULBTMP(MULB)
 .;FND2
 . N RTNARR,RTNNM
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D RTNSINB^A1AEUF5B(BLD,.RTNARR)
 .. N PTCH,PTCHIEN,PTCHARR
 .. S RTNNM="" F  S RTNNM=$O(RTNARR(RTNNM)) Q:RTNNM=""  D
 ... D PTC4RTN^A1AEF1(RTNNM,.PTCHARR)
 ... Q:'$D(PTCHARR)
 ... S PTCH=" " F  S PTCH=$O(PTCHARR(PTCH)) Q:PTCH=""  D
 ....; Fix patches integer and no .0
 .... I $P(PTCH,"*",2)=$P($P(PTCH,"*",2),".") D
 ..... S $P(PTCH,"*",2)=$P(PTCH,"*",2)_".0"
 .... S PTCHIEN=+$O(^XPD(9.6,"B",PTCH,0))
 .... S ^XTMP($J,BUILD,PTCH)=PTCHIEN
 .... S ^XTMP($J,BUILD,PTCH,RTNNM,"R")=""
 .;FND3
 . S BLD=" "
 . F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. S BLDIEN=+$G(^XTMP($J,BUILD,BLD))
 .. I BLDIEN D
 ... S DTINS=$$DTINS^A1AEF2(BLD)
 ... D:DTINS LOADXTMP^A1AEF2(BUILD,BLDIEN,DTINS)
 .; 
 . N MSG,MSGTXT S MSG=1,MSGTXT=""
 . D FND4^A1AEF5(BUILD,.MSG,.MSGTXT)
 ;
 ; Now compare the two globals
 S X=1
 N NX,SNX S NX=$NA(^XTMP($J)),SNX=$P(NX,")")
 N NXT,SNXT S NXT=$NA(^TMP($J)),SNXT=$P(NXT,")")
 F  S NX=$Q(@NX) Q:NX'[SNX  S NXT=$Q(@NXT) Q:NXT'[SNXT  D  Q:'X
 . I ($P(NX,",",2,$L(NX,",")))'=($P(NXT,",",2,$L(NXT))) D  Q:'X
 .. S X=0
 . I @NX'=@NXT S X=0
 K ^XTMP($J),^TMP($J)
 D CHKEQ^%ut(1,X,"Testing FND4^A1AEF5 all BLDS in 9.6 with similar components FAILED!")
 Q
 ;
 ;
 ; ENTER
 ;    BUILD = name of PARENT build under inspection
 ;    MSG     = 1:build MSGTXT
 ;              0:print statistics to terminal
 ;    MSGTXT  = Summary statistics message
 ;    BLDARR  = array of associated builds after limiting
 ;              BLDARR(0)=total number
 ; RETURN
 ;    MSG = 1, MSGTXT updated
 ;    MSG = 0, informational text and total to terminal
 ; --- FND5(BUILD,MSG,MSGTXT)
UTP43 I '$G(A1AEFAIL) D
 . N TSTBLD S TSTBLD=$$FNDONE^A1AEUF5B
 . N BUILD S BUILD=$P(TSTBLD,"^")
 . I (BUILD="")!('$O(^XPD(9.6,"B",BUILD,0))) D  Q
 .. D FAIL^%ut("Unable to find suitable test BUILD")
 .; Run FND5^A1AEF5 and capture MSGTXT
 . N MSG,MSGTXT S MSG=1,MSGTXT=""
 . D FND5^A1AEF5(BUILD,.MSG,.MSGTXT)
 . I MSGTXT="" D  Q
 .. D FAIL^%ut("Unable to calculate Limited BLDs from ^XTMP($J)")
 .; Calculate Limited build count manually
 . N BLDARR,BLD S BLD=" "
 . F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. I $$BACTV^A1AEF1(BLD) D
 ... I $P(BLD,"*")=$P(BUILD,"*") S BLDARR($P(BLD,"*"))="" Q
 ... Q:$D(BLDARR($P(BLD,"*")))
 ... S BLDARR($P(BLD,"*"))=""
 . N CNT,NODE S CNT=0,NODE=$NA(BLDARR)
 . F  S NODE=$Q(@NODE) Q:NODE'["BLDARR("  D
 ..  S CNT=CNT+1
 . N X S X=($P(MSGTXT,"^",2)=CNT)
 . D CHKEQ^%ut(1,X,"Testing FND5^A1AEF5 Limited Cnt in ^XTMP($J) FAILED!")
 Q
 ;
 ;
UTP44 I '$G(A1AEFAIL) D
 . N BLDMSG,BUILD,BIEN,CNT,REQBIEN
 . S BLDMSG=$$FNDONE^A1AEUF5B(),BUILD=$P(BLDMSG,"^")
 . N BIEN S BIEN=$P(BLDMSG,"^",2)
 . I BIEN'=$O(^XPD(9.6,"B",BUILD,0)) D  Q
 .. D FAIL^%ut("BIEN from FNDONE call in error!")
 . S REQBIEN=0
 . F  S REQBIEN=$O(^XPD(9.6,BIEN,"REQB",REQBIEN)) Q:'REQBIEN  D
 ..  S CNT=$G(CNT)+1
 . N X S X=(CNT=$P(BLDMSG,"^",3))
 . D CHKEQ^%ut(1,X,"Testing FNDONE^A1AEUF5B API for build with REQBs failed!")
 Q
XTENT ;
 ;;UTP42;Testing FND4^A1AEF5 - Adding BLDS in 9.6 matching components
 ;;UTP43;Testing FND5^A1AEF5 - Compute limited set of builds
 ;;UTP44;Testing FNDONE^A1AEUF5B - Find build with multiple REQB
 Q
