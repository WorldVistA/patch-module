A1AEUF3 ;ven/lgc,jli-unit tests for A1AEF3 ;2015-01-01T17:32
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
 L +^A1AE(A1AENAME):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on "_A1AENAME_" [#"_A1AEFILE_"] file"
 . W !," Unable to perform testing."
 ;
 Q
 ;
SHUTDOWN L -^XPD(9.6):1
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 L -^A1AE(A1AEFILE)
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ;  Testing
 ;     UTP20 SELBLDS^A1AEF3(BUILD)
 ;     UTP21 DISPL^A1AEF3
 ;     UTP22 KEEP^A1AEF3(RM)
 ;     UTP23 UPDBLDQ^A1AEF3(BUILD)
 ;     UTP24 UPDDERQ^A1AEF3
 ;     UTP25 UPDPATQ^A1AEF3(BUILD)
 ;     UTP26 UPDBLD^A1AEF3(BUILD,OARR,MARR,RM,UPD)
 ;     UTP27 DSPNODES^A1AEF3(DPLARR)
 ;     UTP28 LOADINH^A1AEF3(.RARR,.OARR)
 ;     UTP29 UPPAT^A1AEF3(BUILD)
 ;
 ;
UTP21 N X,MYDT S MYDT=DTIME
 S DTIME=1,X=$$DISPL^A1AEF3,DTIME=MYDT
 D CHKEQ^%ut(0,X,"Testing DISPLAY builds query FAILED!")
 Q
 ;
UTP22 N X,MYDT S MYDT=DTIME
 S DTIME=1,X=$$KEEP^A1AEF3("R"),DTIME=MYDT
 I 'X S DTIME=1,X=$$KEEP^A1AEF3("M"),DTIME=MYDT
 D CHKEQ^%ut(0,X,"Testing KEEP query FAILED!")
 Q
 ;
UTP23 N X,MYDT S MYDT=DTIME
 S DTIME=1,X=$$UPDBLDQ^A1AEF3("TEST BUILD"),DTIME=MYDT
 D CHKEQ^%ut(0,X,"Testing Update Build query FAILED!")
 Q
 ;
UTP24 N X,MYDT S MYDT=DTIME
 S DTIME=1,X=$$UPDDERQ^A1AEF3,DTIME=MYDT
 D CHKEQ^%ut(0,X,"Testing Bring In DERIVED query FAILED!")
 Q
 ;
UTP25 N X,MYDT S MYDT=DTIME
 S DTIME=1,X=$$UPDPATQ^A1AEF3("TEST BUILD"),DTIME=MYDT
 D CHKEQ^%ut(0,X,"Testing Update Patches query FAILED!")
 Q
 ;
 ;
UTP25A N POO D BLDTXTA^A1AEF3("TXTZ",.POO)
 N CNT,TXT,X,BUILD S (X,CNT)=0
 F  S TXT=$P($T(TXTZ+CNT),";;",2) Q:TXT["*END*"  D  Q:'X
 . S CNT=CNT+1
 . I '$L($P(TXT,"^",2)) D  Q
 ..  S X=(TXT=POO(CNT))
 . S TXT=$P(TXT,"^",2) D  Q
 .. I '$D(@TXT) D  Q
 ... S TXT="MISSING VAR:"_TXT
 ... S X=(TXT=POO(CNT))
 .. E  D  Q
 ... S TXT=@TXT
 ... S X=(TXT=POO(CNT))
 D CHKEQ^%ut(1,X,"Testing building TXT array for display FAILED!")
 Q
 ;
 ;
TXTZ ;;
 ;;Testing BLDTXTA in A1AEF3 
 ;;^BUILD
 ;;Testing Testing Testing
 ;;
 ;; Testing
 ;;
 ;;*END*
XTENT ;
 ;;UTP21;Testing Display Builds query
 ;;UTP22;Testing KEEP query
 ;;UTP23;Testing Update Build query
 ;;UTP24;Testing Bring in DERIVED query
 ;;UTP25;Testing Update Patches query
 ;;UTP25A;Testing Building text array to display
 Q
 ;
 ;
EOR ; end of routine A1AEUF3
