A1AEUF2 ;ven/lgc,jli-unit tests for A1AEF2 ;2014-12-18T00:17
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
 D EN^%ut($T(+0),1)
 Q
 ;
STARTUP S A1AEFAIL=0 ; KILLED IN SHUTDOWN
 N A1AEFILE S A1AEFILE=11005,A1AENAME="DHCP PATCHES" I '$D(^DIC(11005)) S A1AEFILE=11004,A1AENAME="PATCH" ; JLI 150525 
 L +^XPD(9.6):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on BUILD [#9.6] file"
 . W !," Unable to perform testing."
 ;
 L +^A1AE(A1AEFILE):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on "_A1AENAME_" [#"_A1AEFILE_"] file"
 . W !," Unable to perform testing."
 ;
 Q
 ;
SHUTDOWN L -^XPD(9.6):1
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 L -^A1AE(A1AEFILE):1
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ;  Testing
 ;     UTP16 MINSET^A1AEF2(.BARR)
 ;     UTP17 LOADXTMP^A1AEF2(BUILD,BIEN,DTINS)
 ;     UTP18 DTINS^A1AEF2(BUILD)
 ;     UTP19 BLDMS^A1AEF2
 ;
 ; D LOADXTMP^A1AEF2("SD*5.3*41",60,7039284.85578)
 ;  This patch installed 2960715.144219 in FOIA accounts
 ;   should be same for all sites and produce equivalent
 ;   XTMP arrays.  Thus, we will match with one saved
 ;   at the end of this routine.
 ;
 ;
UTP16 N MINSET
 D MINSET^A1AEF2("SD*5.3*41")
 N PD S PD="",PD=$O(MINSET(PD)) S X=PD["SD*5.3*41"
 S PD=$O(MINSET(PD)) S X=PD=""
 D CHKEQ^%ut(1,X,"Testing Minimal Set from BUILD  FAILED!")
 Q
 ;
 ;
UTP17 N X S X=$$ENLD
 D CHKEQ^%ut(1,X,"Testing Load Build Components into XTMP FAILED!")
 Q
 ;
ENLD() N BLD,CNT,FNDONE,NODE,X S BLD=0
 F  S BLD=$O(^XPD(9.6,BLD)) Q:'BLD  Q:$G(FNDONE)  D
 .  S NODE=$NA(^XPD(9.6,BLD,"KRN")),CNT=0
 .  S SNODE=$P(NODE,")")
 .  F  S NODE=$Q(@NODE) Q:NODE'[SNODE  D
 ..  S CNT=CNT+1 I CNT>150 S FNDONE=BLD
 ;W !,FNDONE
 K BLDARR M BLDARR("KRN")=^XPD(9.6,FNDONE,"KRN")
 M BLDARR(4)=^XPD(9.6,FNDONE,4)
 ;
 K ^XTMP($J)
 D LOADXTMP^A1AEF2("LOADXTMP",FNDONE,12345)
 ;
 N X S X=0
 S NODE=$NA(BLDARR)
 F  S NODE=$Q(@NODE) Q:NODE'["BLDARR"  D
 .  I $QS(NODE,1)=4,$QS(NODE,2)="B" D
 ..  S X=$D(^XTMP($J,4,$QS(NODE,3))) Q:'X
 .  I $QS(NODE,1)="KRN",$QS(NODE,3)="NM",$QS(NODE,4)="B" D
 ..  S X=$D(^XTMP($J,$QS(NODE,2),$QS(NODE,5))) Q:'X
 ;W !,"X=",X,!!!
 Q:'X X
 ;
 S X=0
 S NODE=$NA(^XTMP($J)),SNODE=$P(NODE,")")
 F  S NODE=$Q(@NODE) Q:NODE'[SNODE  D
 . I $QS(NODE,2)=4 D
 ..; W !,NODE
 .. S X=$D(BLDARR(4,$QS(NODE,3))) Q:'X
 . E  D  Q:'X
 ..; W !,NODE
 .. S X=$D(BLDARR("KRN",$QS(NODE,2),"NM","B",$QS(NODE,3)))
 ;W !,"X=",X
 Q:'X X  Q 1
 ;
 ;
 ; Look for build with a date install completed
 ;  Pull date and calculate inverse manuall
 ;  See if matches answer with function
UTP18 N PD,PDIEN,DTIC,DTICIV S PD="DG"
 F  S PD=$O(^XPD(9.7,"B",PD)) Q:PD=""  D  Q:DTIC
 .  S PDIEN=$O(^XPD(9.7,"B",PD,0)) Q:'PDIEN
 .  S DTIC=$$GET1^DIQ(9.7,PDIEN_",",17,"I")
 S DTICIV=9999999.999999-DTIC
 S X=(DTICIV=$$DTINS^A1AEF2(PD))
 D CHKEQ^%ut(1,X,"Testing pulling INVERSE Date Installed  FAILED!")
 Q
 ;
 ; 
 ;K ^XTMP($J) D LOADXTMP^A1AEF2("SD*5.3*41",60,7039284.85578)
 ;Now duplicate what is in ^XTMP($J) except change
 ; inverse date to earlier.  Except those representing
 ; file changes, as we keep all file changing builds
 ;D BLDMS^A1AEF2 should delete the extra and run same test
UTP19 K ^XTMP($J) N X,XTMP
 D LOADXTMP^A1AEF2("SD*5.3*41",60,7039285.85578)
 M XTMP($J)=^XTMP($J) K ^XTMP($J)
 D LOADXTMP^A1AEF2("SD*5.3*41",60,7039284.85578)
 S NODE=$NA(XTMP) F  S NODE=$Q(@NODE) Q:NODE=""  Q:$QS(NODE,1)'=$J  D
 . S X=NODE,$P(X,",",5)="""SD*5.3*44""",X="^"_X
 . S:'(+$P(X,",",2)=4) @X=""
 D BLDMS^A1AEF2
 N PD S PD="",PD=$O(MINSET(PD)) S X=PD["SD*5.3*41"
 S PD=$O(MINSET(PD)) S X=PD=""
 D CHKEQ^%ut(1,X,"Testing Minimal Set from XTMP array  FAILED!")
 Q
 ;
 ;
XTENT ;
 ;;UTP16;Testing minimum set from BUILD
 ;;UTP17;Testing Loadinb BUILD components into XTMP
 ;;UTP18;Testing Inverse Date Most Recent Install
 ;;UTP19;Testing building MINSET from ^XTMP array
 Q
 ;
EOR ; end of routine A1AEUF2
