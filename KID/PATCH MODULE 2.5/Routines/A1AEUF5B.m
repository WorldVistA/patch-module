A1AEUF5B ;ven/lgc,jli-unit tests for A1AEF5 ;2015-06-13  10:09 PM
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
 ; Logic for test
 ;   1. Find a build with mutiple REQB
 ;   2. Run S RSLTMSG=$$FNDALL^A1AEF5(BUILD,1)
 ;      a. Confirm suitability
 ;
 ; ENTER
 ;   BUILD  = Parent BUILD under scrutiny
 ;   MSG    = 1:build MSGTXT
 ;            0:print statistics to terminal
 ; RETURN
 ;   Display statistics to terminal
 ; --- FNDALL(BUILD,MSG)
UTP38 I '$G(A1AEFAIL) D
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
 .. D RTNSINB(BLD,.RTNARR)
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
 . N NODE,NMCMP,NMRICMP S NODE=$NA(^XPD(9.6))
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
 .;Compare Globals
 . K ^TMP($J)
 . M ^TMP($J)=^XTMP($J)
 . S X=$$FNDALL^A1AEF5(BUILD,1)
 .; Now compare the two globals
 . S X=1
 . N NX,SNX S NX=$NA(^XTMP($J)),SNX=$P(NX,")")
 . N NXT,SNXT S NXT=$NA(^TMP($J)),SNXT=$P(NXT,")")
 . F  S NX=$Q(@NX) Q:NX'[SNX  S NXT=$Q(@NXT) Q:NXT'[SNXT  D  Q:'X
 .. I ($P(NX,",",2,$L(NX,",")))'=($P(NXT,",",2,$L(NXT))) D  Q:'X
 ... S X=0
 .. I @NX'=@NXT S X=0
 . K ^XTMP($J),^TMP($J)
 . D CHKEQ^%ut(1,X,"Testing FNDALL^A1AEF5 pulling all associated builds  FAILED!")
 Q
 ;
 ;
 ; ENTER
 ;    BUILD = name of PARENT build under inspection
 ;    MSG   = 1:build MSGTXT
 ;            0:print statistics to terminal
 ;    ^XTMP($J,BUILD under construction
 ; RETURN
 ;    ^XTMP($J,BUILD updated
 ; --- FND1(BUILD,MSG,MSGTXT)
UTP39  I '$G(A1AEFAIL) D
 . N TSTBLD S TSTBLD=$$FNDONE
 . N BUILD S BUILD=$P(TSTBLD,"^")
 . I (BUILD="")!('$O(^XPD(9.6,"B",BUILD,0))) D  Q
 .. D FAIL^%ut("Unable to find suitable test BUILD")
 .;
 . K ^XTMP($J)
 . N MSG S MSG=1
 . N MSGTXT,REQB,MULB S (MSGTXT,REQB,MULB)=""
 . N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN
 . S ^XTMP($J,BUILD,BUILD)=BIEN
 . N CNT S CNT=0
 . S (REQB,MULB)=""
 . F  S REQB=$O(^XPD(9.6,BIEN,"REQB","B",REQB)) Q:REQB=""  D
 .. S CNT=CNT+1
 . S MSGTXT="REQB^"_CNT_"^",CNT=0
 . F  S MULB=$O(^XPD(9.6,BIEN,10,"B",MULB)) Q:MULB=""  D
 .. S CNT=CNT+1
 . S MSGTXT=MSGTXT_"MULB^"_CNT_"^"
 . S (REQB,MULB)=""
 .; Get recursive built array of all REQB and MULB
 .;  for the parent build
 . D REQB^A1AEF1(BUILD,.REQB)
 . D MULB^A1AEF1(BUILD,.MULB)
 . S REQB=" " F  S REQB=$O(REQB(REQB)) Q:REQB=""  D
 ..  S ^XTMP($J,BUILD,REQB)=REQB(REQB)
 . S MULB=" " F  S MULB=$O(MULB(MULB)) Q:MULB=""  D
 ..  S ^XTMP($J,BUILD,MULB)=MULB(MULB)
 . D FND1^A1AEF5(BUILD,MSG,.MSGTXT)
 .; Now check that any new findings were set in ^XMTP($J) by
 .;  the FND1 call
 . N MULBTMP,BLD
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D MULB^A1AEF1(BLD,.MULB)
 . M MULBTMP=MULB
 .;
 . N X S X=0
 . S MULB=" " F  S MULB=$O(MULBTMP(MULB)) Q:MULB=""  D  Q:'X
 .. I $D(^XTMP($J,BUILD,MULB)),^XTMP($J,BUILD,MULB)=MULBTMP(MULB) S X=1
 . D CHKEQ^%ut(1,X,"Testing FND1^A1AEF5 adding MULB of REQB ^XTMP($J) FAILED!")
 Q
 ;
 ;
 ;
 ; ENTER
 ;    BUILD = name of PARENT build under inspection
 ;    MSG   = 1:build MSGTXT
 ;            0:print statistics to terminal
 ;    ^XTMP($J,BUILD array under construction
 ; RETURN
 ;    ^XTMP($J,BUILD updated
 ; --- FND2(BUILD,MSG,MSGTXT)
UTP40 I '$G(A1AEFAIL) D
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
 ..  S ^XTMP($J,BUILD,REQB)=REQB(REQB)
 . S MULB=" " F  S MULB=$O(MULB(MULB)) Q:MULB=""  D
 ..  S ^XTMP($J,BUILD,MULB)=MULB(MULB)
 .;FND1
 . N MULBTMP,BLD
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D MULB^A1AEF1(BLD,.MULB)
 .. M MULBTMP=MULB
 .; Pull these into ^XTMP array
 . S MULB=" " F  S MULB=$O(MULBTMP(MULB)) Q:MULB=""  D
 ..  S ^XTMP($J,BUILD,MULB)=MULBTMP(MULB)
 .;FND2
 . N RTNARR,RTNNM
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D RTNSINB(BLD,.RTNARR)
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
 .;
 . K ^TMP($J) M ^TMP($J)=^XTMP($J)
 .;
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
 ..  S ^XTMP($J,BUILD,REQB)=REQB(REQB)
 . S MULB=" " F  S MULB=$O(MULB(MULB)) Q:MULB=""  D
 ..  S ^XTMP($J,BUILD,MULB)=MULB(MULB)
 .;FND1
 . N MULBTMP,BLD
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D MULB^A1AEF1(BLD,.MULB)
 .. M MULBTMP=MULB
 .; Pull these into ^XTMP array
 . S MULB=" " F  S MULB=$O(MULBTMP(MULB)) Q:MULB=""  D
 ..  S ^XTMP($J,BUILD,MULB)=MULBTMP(MULB)
 .;FND2
 . N MSG,MSGTXT S MSG=1,MSGTXT=""
 . D FND2^A1AEF5(BUILD,.MSG,.MSGTXT)
 .; Now compare the two globals
 . S X=1
 . N NX,SNX S NX=$NA(^XTMP($J)),SNX=$P(NX,")")
 . N NXT,SNXT S NXT=$NA(^TMP($J)),SNXT=$P(NXT,")")
 . F  S NX=$Q(@NX) Q:NX'[SNX  S NXT=$Q(@NXT) Q:NXT'[SNXT  D  Q:'X
 .. I ($P(NX,",",2,$L(NX,",")))'=($P(NXT,",",2,$L(NXT))) D  Q:'X
 ... S X=0
 .. I @NX'=@NXT S X=0
 . K ^XTMP($J),^TMP($J)
 . D CHKEQ^%ut(1,X,"Testing FND2^A1AEF5 pulling routine patches FAILED!.")
 Q
 ;
 ;
 ; ENTER
 ;    BUILD = name of PARENT build under inspection
 ;    MSG   = 1:build MSGTXT
 ;            0:print statistics to terminal
 ;    ^XTMP($J,BUILD under construction
 ; RETURN
 ;    ^XTMP($J,BUILD updated
 ; --- FND3(BUILD,MSG,MSGTXT)
UTP41 I '$G(A1AEFAIL) D
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
 ..  S ^XTMP($J,BUILD,REQB)=REQB(REQB)
 . S MULB=" " F  S MULB=$O(MULB(MULB)) Q:MULB=""  D
 ..  S ^XTMP($J,BUILD,MULB)=MULB(MULB)
 .;FND1
 . N MULBTMP,BLD
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D MULB^A1AEF1(BLD,.MULB)
 .. M MULBTMP=MULB
 .; Pull these into ^XTMP array
 . S MULB=" " F  S MULB=$O(MULBTMP(MULB)) Q:MULB=""  D
 ..  S ^XTMP($J,BUILD,MULB)=MULBTMP(MULB)
 .;FND2
 . N RTNARR,RTNNM
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D RTNSINB(BLD,.RTNARR)
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
 ..  S BLDIEN=+$G(^XTMP($J,BUILD,BLD))
 ..  I BLDIEN D
 ...  S DTINS=$$DTINS^A1AEF2(BLD)
 ...  D:DTINS LOADXTMP^A1AEF2(BUILD,BLDIEN,DTINS)
 .; Save manually built results
 . K ^TMP($J) M ^TMP($J)=^XTMP($J)
 .;
 . K ^XTMP($J)
 . N REQB,MULB S (REQB,MULB)=""
 . N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN
 . S ^XTMP($J,BUILD,BUILD)=BIEN
 .;
 . N CNT S CNT=0
 . S (REQB,MULB)=""
 . F  S REQB=$O(^XPD(9.6,BIEN,"REQB","B",REQB)) Q:REQB=""  D
 .. S CNT=CNT+1
 .F  S MULB=$O(^XPD(9.6,BIEN,10,"B",MULB)) Q:MULB=""  D
 .. S CNT=CNT+1
 .;
 . S (REQB,MULB)=""
 . D REQB^A1AEF1(BUILD,.REQB)
 . D MULB^A1AEF1(BUILD,.MULB)
 . S REQB=" " F  S REQB=$O(REQB(REQB)) Q:REQB=""  D
 ..  S ^XTMP($J,BUILD,REQB)=REQB(REQB)
 . S MULB=" " F  S MULB=$O(MULB(MULB)) Q:MULB=""  D
 ..  S ^XTMP($J,BUILD,MULB)=MULB(MULB)
 .;FND1
 . N MULBTMP,BLD
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D MULB^A1AEF1(BLD,.MULB)
 .. M MULBTMP=MULB
 .; Pull these into ^XTMP array
 . S MULB=" " F  S MULB=$O(MULBTMP(MULB)) Q:MULB=""  D
 ..  S ^XTMP($J,BUILD,MULB)=MULBTMP(MULB)
 .;FND2
 . N RTNARR,RTNNM
 . S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .. D RTNSINB(BLD,.RTNARR)
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
 .;
 . N MSG,MSGTXT S MSG=1,MSGTXT=""
 . D FND3^A1AEF5(BUILD,.MSG,.MSGTXT)
 .;
 .; Now compare the two globals
 . S X=1
 . N NX,SNX S NX=$NA(^XTMP($J)),SNX=$P(NX,")")
 . N NXT,SNXT S NXT=$NA(^TMP($J)),SNXT=$P(NXT,")")
 . F  S NX=$Q(@NX) Q:NX'[SNX  S NXT=$Q(@NXT) Q:NXT'[SNXT  D  Q:'X
 .. I ($P(NX,",",2,$L(NX,",")))'=($P(NXT,",",2,$L(NXT))) D  Q:'X
 ... S X=0
 .. I @NX'=@NXT S X=0
 . K ^XTMP($J),^TMP($J)
 . D CHKEQ^%ut(1,X,"Testing FND3^A1AEF5 add components to ^XTMP FAILED!")
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
 ;
 ; Build array of all routines contained in a BUILD
 ; ENTER
 ;   BUILD  = NAME OF BUILD
 ;   RTNARR = ARRAY PASSED BY REFERENCE
 ; RETURN
 ;   RTNARR   = ARRAY OF ROUTINES IN BUILD
RTNSINB(BUILD,RTNARR) ;
 K RTNARR
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN
 N RTNNM,RTNSS S RTNSS=0
 F  S RTNSS=$O(^XPD(9.6,BIEN,"KRN",9.8,"NM",RTNSS)) Q:'RTNSS  D
 . S RTNNM=$P($G(^XPD(9.6,BIEN,"KRN",9.8,"NM",RTNSS,0)),"^")
 . I $L(RTNNM) D
 ..;Take care of cases where routine name in B cross has " "
 .. S:$E(RTNNM)=" " RTNNM=$E(RTNNM,2,$L(RTNNM))
 .. S RTNARR(RTNNM)=""
 Q
 ;
 ;
XTENT ;
 ;;UTP38;Testing FNDALL^A1AEF5 - Finding every related build
 ;;UTP39;Testing FND1^A1AEF5 - Finding all MULB for all REQB
 ;;UTP40;Testing FND2^A1AEF5 - Adding patches required for routines
 ;;UTP41;Testing FND3^A1AEF5 - Adding components from blds in ^XTMP
 Q
 ;
 ;
EOR ; end of routine A1AEUF5B
