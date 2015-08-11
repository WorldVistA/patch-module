A1AEUALL ;ven/jli-unit tests for all A1AEU* tests ;2015-06-15  9:03 PM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
TESTONLY ;
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(A1AEFILE)) S A1AEFILE=11004
 I A1AEFILE=11005 W !!,"RUNNING A1AEUBL1:" D TESTIT^A1AEUBL1
 I A1AEFILE=11005 W !!,"RUNNING A1AEUBLD:" D ^A1AEUBLD,^A1AEBLD,VERBOSE^A1AEBLD
 W !!,"RUNNING A1AEUDD:" D ^A1AEUDD
 W !!,"RUNNING A1AEUF1:" D ^A1AEUF1
 W !!,"RUNNING A1AEUF1A:" D ^A1AEUF1A
 I $D(^A1AE(11005)) W !!,"RUNNING A1AEUF1B:" D ^A1AEUF1B
 W !!,"RUNNING A1AEUF2:" D ^A1AEUF2
 W !!,"RUNNING A1AEUF3:" D ^A1AEUF3
 W !!,"RUNNING A1AEUF4:" D ^A1AEUF4
 W !!,"RUNNING A1AEUF5:" D ^A1AEUF5
 W !!,"RUNNING A1AEUF5A:" D ^A1AEUF5A
 W !!,"RUNNING A1AEUF5B:" D ^A1AEUF5B
 W !!,"RUNNING A1AEUF5C:" D ^A1AEUF5C
 W !!,"RUNNING A1AEUF5D:" D ^A1AEUF5D
 I $D(^A1AE(11005)) W !!,"RUNNING A1AEUK1:" D ^A1AEUK1
 I $D(^A1AE(11005)) W !!,"RUNNING A1AEUK2:" D ^A1AEUK2
 W !!,"RUNNING A1AEUPS1:" D ^A1AEUPS1
 I $D(^A1AE(11005)) W !!,"RUNNING A1AEUPS2:" D ^A1AEUPS2
 W !!,"RUNNING A1AEUK3:" D ^A1AEUK3
 I $D(^A1AE(11005)) W !!,"RUNNING A1AEUSPL:" D EN^%ut("A1AEUSPL",1)
        ; have to check on use of these, they clear out 11007.1, create entries they
 ; don't remove in PACKAGE and DHCP PATCHES files, etc.
 ;W !!,"RUNNING A1AEUT2:" D ^A1AEUT2 ; DATA ONLY
 W !!,"RUNNING A1AEUT1:" D ^A1AEUT1
 W !!,"RUNNING A1AEUT3:" D ^A1AEUT3
 I $D(^A1AE(11005)) W !!,"RUNNING A1AEK2MT:" D ^A1AEK2MT
 I $D(^A1AE(11005)) W !!,"RUNNING A1AEUT4:" D ^A1AEUT4
 I $D(DOALL),$D(^A1AE(11005)) D
 . W !!,"RUNNING A1AEUT1:" D EN^%ut("A1AEUT1",1) ; D ^A1AEUT1 activates BREAK on problem
 . W !!,"RUNNING A1AEK2MT:" D EN^%ut("A1AEK2MT",1)
 . W !!,"RUNNING A1AE2V0:" D EN^%ut("A1AE2V0",1)
 . W !!,"RUNNING A1AEK2MT:" D EN^%ut("A1AE2VC",1)
 . Q
        Q
 ;
COVERSUM ; summary with break down by tag
 N TYPE S TYPE=1
 D COVERAGE
 Q
 ;
COVERMIN ; MINIMAL summary coverage analysis output ONLY
 N TYPE S TYPE=0
 D COVERAGE
 Q
 ;
COVERAGE  ; complete coverage analysis output LISTS LINES NOT COVERED
 I '$D(TYPE) N TYPE S TYPE=2
 D COV^%ut1("A1AE*","D TESTONLY^A1AEUALL",-1)
 ; the following indicates that routines beginning with the following 
 ; characters, comma separated are to be included in the analysiS
 ;
 ;S ROULIST=",A1AE2POS,A1AEBLD,A1AEDD1,A1AEF1,A1AEF2,A1AEF3,A1AEF4,A1AEF5,A1AEK1,A1AEK2,A1AEK2M0,A1AEM,A1AEM1,A1AEPH1,A1AECOPD,A1AEPH2,A1AEPH3,A1AERD,A1AEUTL,A1AEUTL1,"
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(A1AEFILE)) S A1AEFILE=11004
 S ROULIST=",A1AE2POS,A1AEDD1,A1AEF1,A1AEF2,A1AEF3,A1AEF4,A1AEF5,A1AEK1,A1AEK2," I A1AEFILE=11005 S ROULIST=ROULIST_"A1AEBLD,"
 D LIST(ROULIST,TYPE)
 Q
 ;
LIST(ROULIST,TYPE)   ;
 ; ZEXCEPT: TYPE1  - NEWed and set below for recursion
 ; input - ROULIST - a comma separated list of routine names that will
 ;       be used to identify desired routines.  Any name
 ;       that begins with one of the specified values will
 ;       be included
 ; input - TYPE - value indicating amount of detail desired, 1=full,
 ;       0=summary
 ;
 D TRIMDATA(ROULIST) ; remove undesired routines from data
 ;
 N JOB,NAME,BASE,GLOB
 S GLOB=$NA(^TMP("%utCOVREPORT",$J))
 S TOTCOV=0,TOTLIN=0
 ; F NAME="%utCOVREPORT","%utCOVRESULT","%utCOVCOHORT","%utCOVCOHORTSAV" D
 I TYPE>0 S ROUNAME="" F  S ROUNAME=$O(@GLOB@(ROUNAME)) Q:ROUNAME=""  S XVAL=^(ROUNAME) D
 . S CURRCOV=$P(XVAL,"/"),CURRLIN=$P(XVAL,"/",2)
 . W !!,"Routine ",ROUNAME,"   ",CURRCOV," out of ",CURRLIN," lines covered"
 . I CURRLIN>0 W "  (",$P((100*CURRCOV)/CURRLIN,"."),"%)"
 . I TYPE=1 W "  - Summary"
 . S TAG="" F  S TAG=$O(@GLOB@(ROUNAME,TAG)) Q:TAG=""  S XVAL=^(TAG) D
 . . S LINCOV=$P(XVAL,"/"),LINTOT=$P(XVAL,"/",2)
 . . W !," Tag ",TAG,"^",ROUNAME,"   ",LINCOV," out of ",LINTOT," lines covered"
 . . I TYPE=1 Q
 . . I LINCOV=LINTOT Q
 . . W !,"   the following is a list of lines NOT covered"
 . . S LINE="" F  S LINE=$O(@GLOB@(ROUNAME,TAG,LINE)) Q:LINE=""  D
 . . . I LINE=0 W !,"   ",TAG,"  ",@GLOB@(ROUNAME,TAG,LINE) Q
 . . . W !,"   ",TAG,"+",LINE,"  ",@GLOB@(ROUNAME,TAG,LINE)
 . . . Q
 . . Q
 . Q
 ; for type=1 generate a summary at bottom after detail
 I TYPE=2 N TYPE1 S TYPE1=1 D LIST(ROULIST,1) K TYPE1
 I TYPE=1,$G(TYPE1) Q  ; CAME IN FROM ABOVE LINE
 ; summarize by just routine name
 S ROUNAME="" F  S ROUNAME=$O(@GLOB@(ROUNAME)) Q:ROUNAME=""  S XVAL=^(ROUNAME) D
 . S CURRCOV=$P(XVAL,"/"),CURRLIN=$P(XVAL,"/",2)
 . S TOTCOV=TOTCOV+CURRCOV,TOTLIN=TOTLIN+CURRLIN
 . W !,"Routine ",ROUNAME,"   ",CURRCOV," out of ",CURRLIN," lines covered"
 . I CURRLIN>0 W "  (",$P((100*CURRCOV)/CURRLIN,"."),"%)"
 W !!,"Overall Analysis ",TOTCOV," out of ",TOTLIN," lines covered"
 I TOTLIN>0 W " (",$P((100*TOTCOV)/TOTLIN,"."),"% coverage)"
 Q
 ;
TRIMDATA(ROULIST)    ;
 F TYPNAME="%utCOVREPORT","%utCOVRESULT","%utCOVCOHORT","%utCOVCOHORTSAV" D
 . S ROUNAME="" F  S ROUNAME=$O(^TMP(TYPNAME,$J,ROUNAME)) Q:ROUNAME=""  D
 . . S FOUND=0
 . . I ROUNAME["A1AEU",ROUNAME'["A1AEUTL" K ^TMP(TYPNAME,$J,ROUNAME) ; REMOVE UNIT TESTS
 . . Q
 . . ; PREVIOUS CODE FOLLOWS
 . . I ROULIST[(","_ROUNAME_",") S FOUND=1
 . . I 'FOUND K ^TMP(TYPNAME,$J,ROUNAME)
 . . Q
 . Q
 Q
 ;
JUSTTEST ;
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(A1AEFILE)) S A1AEFILE=11004
 I A1AEFILE=11005 W !!,"RUNNING A1AEUBLD:",! D EN^%ut("A1AEUBLD")
 W !!,"RUNNING A1AEUDD:",! D EN^%ut("A1AEUDD")
 W !!,"RUNNING A1AEUF1:",! D EN^%ut("A1AEUF1")
 W !!,"RUNNING A1AEUF1A:",! D EN^%ut("A1AEUF1A")
 I $D(^A1AE(11005)) W !!,"RUNNING A1AEUF1B:",! D EN^%ut("A1AEUF1B")
 W !!,"RUNNING A1AEUF2:",! D EN^%ut("A1AEUF2")
 W !!,"RUNNING A1AEUF3:",! D EN^%ut("A1AEUF3")
 W !!,"RUNNING A1AEUF4:",! D EN^%ut("A1AEUF4")
 W !!,"RUNNING A1AEUF5:",! D EN^%ut("A1AEUF5")
 W !!,"RUNNING A1AEUF5A:",! D EN^%ut("A1AEUF5A")
 W !!,"RUNNING A1AEUF5B:",! D EN^%ut("A1AEUF5B")
 W !!,"RUNNING A1AEUF5C:",! D EN^%ut("A1AEUF5C")
 W !!,"RUNNING A1AEUF5D:",! D EN^%ut("A1AEUF5D")
 I $D(^A1AE(11005)) W !!,"RUNNING A1AEUK1:",! D EN^%ut("A1AEUK1")
 I $D(^A1AE(11005)) W !!,"RUNNING A1AEUK2:",! D EN^%ut("A1AEUK2")
 W !!,"RUNNING A1AEUPS1:",! D EN^%ut("A1AEUPS1")
 I $D(^A1AE(11005)) W !!,"RUNNING A1AEUPS2:",! D EN^%ut("A1AEUPS2")
 W !!,"RUNNING A1AEUK3:" D EN^%ut("A1AEUK3")
 ; have to check on use of these, they clear out 11007.1, create entries they
 ; don't remove in PACKAGE and DHCP PATCHES files, etc.
 ;W !!,"RUNNING A1AEUT1:",! D EN^%ut("A1AEUT1")
 ;W !!,"RUNNING A1AEUT2:",! D EN^%ut("A1AEUT2")
 W !!,"RUNNING A1AEUT3:",! D EN^%ut("A1AEUT3")
 W !!,"RUNNING A1AEUT4:",! D EN^%ut("A1AEUT4")
 Q
 ;
