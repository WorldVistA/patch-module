A1AEUF3 ;VEN/LGC/JLI - UNIT TESTS FOR A1AEF3 ; 11/10/14 12:27am
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
 Q
 ;
SHUTDOWN L -^XPD(9.6):1
 L -^A1AE(11005)
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
XTENT ;
 ;;UTP21;Testing Display Builds query
 ;;UTP22;Testing KEEP query
 ;;UTP23;Testing Update Build query
 ;;UTP24;Testing Bring in DERIVED query
 ;;UTP25;Testing Update Patches query
 Q
 ;
 ;
EOR ; end of routine A1AEUF3
