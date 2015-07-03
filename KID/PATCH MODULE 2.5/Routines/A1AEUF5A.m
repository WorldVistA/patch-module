A1AEUF5A ;ven/lgc,jli-unit tests for A1AEF5 ; 6/4/15 1:02am
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
 I '$$DELPAT D
 . W !,"Unable to delete test entries in "_A1AEFILE,!
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ; Testing
 ;   35. Testing $$PTC4RTN^A1AEF1 - patches to build RTN 2nd line
 ;   36. Testing LOADXTMP^A1AEF2 - Load Build Components
 ;   37. Testing $$DTINS^A1AEF2 - get INVERSE Install DT
 ;
 ;
UTP35 I '$G(A1AEFAIL) S X=$$PTC4RTN D
 . D CHKEQ^%ut(1,X,"$$PTC4RTN^A1AEF1 - patches to build RTN 2nd line FAILED!")
 Q
 ;
 ; Testing PTC4RTN logic
 ;   1. Enter with RTN and POO array of patches
 ;   2. Run PTC4RTN^A1AEF1 for this routine
 ;   3. Pull up 2nd line of the routine and run through
 ;      each "," delimited patch
 ;   4. Check this patch is in POO global
 ;   5. Check this patch in 11005 if POO(xxx)=ien into 11005
 ;   6. Kill each POO node after check to be certain not
 ;      excess POO nodes
 ; ENTER
 ;    nothing required
 ; RETRUN
 ;    0 = error, 1 = successful
PTC4RTN() N X S X=1
 ; Find a routine with several patches - at least one
 ;  of which is found in DHCP PATHES [#11005]
 N POO,RTN I '$$BLDPARR(.POO,.RTN) D  Q
 . S X=0
 . W !,"Unable to find suitably patched routine"
 . W !," Unable to perform testing."
 ;
 ; Pick up 2nd line and run through each patch listed
 ;   is there a POO(name) array entry
 ;   if POO(name)>0 (=IEN in file 11005)
 ;      check the patch is in 11005
 ;      check the routine is in the patch
P1 N A1AE2LN S A1AE2LN=$T(+2^@RTN)
 N A1AEVR S A1AEVR=$P(A1AE2LN,";",3)
 S:A1AEVR?.EP1"0" A1AEVR=$P(A1AE2LN,";",3)
 N A1AESNM S A1AESNM=$P(A1AE2LN,";",4) Q:A1AESNM="" 0
 S A1AESNM=$$UP(A1AESNM)
 N A1AESIEN S A1AESIEN=$O(^DIC(9.4,"B",A1AESNM,0)) Q:'A1AESIEN 0
 N A1AESABB S A1AESABB=$$GET1^DIQ(9.4,A1AESIEN_",",1) Q:A1AESABB="" 0
 S A1AE2LN=$P(A1AE2LN,"**",2)
 N CNT,PNM,PNMB
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525
 F CNT=1:1:$L(A1AE2LN,",") S PNMB=$P(A1AE2LN,",",CNT) D  Q:'X
 . S PNM=A1AESABB_"*"_A1AEVR_"*"_PNMB
 . I '$D(POO(PNM)) S X=0 Q
 . I +POO(PNM),'$D(^A1AE(A1AEFILE,+POO(PNM))) S X=0 Q
 . I +POO(PNM),'$O(^A1AE(A1AEFILE,+POO(PNM),"P","B",RTN,0)) S X=0
 . K POO(PNM)
 Q:$O(POO(""))="" 1
 Q X
 ;
 ;
UTP36 N X S X=$$ENLD
 D CHKEQ^%ut(1,X,"Testing LOADXTMP^A1AEF2 - Load Build Components into ^XTMP FAILED!")
 Q
 ;
ENLD() N BLD,CNT,FNDONE,NODE,SNODE,X S BLD=0
 F  S BLD=$O(^XPD(9.6,BLD)) Q:'BLD  Q:$G(FNDONE)  D
 .  S NODE=$NA(^XPD(9.6,BLD,"KRN")),CNT=0
 .  S SNODE=$P(NODE,")")
 .  F  S NODE=$Q(@NODE) Q:NODE'[SNODE  D
 ..  S CNT=CNT+1 I CNT>150 S FNDONE=BLD
 ;W !,FNDONE
 N BLDARR M BLDARR("KRN")=^XPD(9.6,FNDONE,"KRN")
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
UTP37 N PD,PDIEN,DTIC,DTICIV S PD="DG"
 F  S PD=$O(^XPD(9.7,"B",PD)) Q:PD=""  D  Q:DTIC
 .  S PDIEN=$O(^XPD(9.7,"B",PD,0)) Q:'PDIEN
 .  S DTIC=$$GET1^DIQ(9.7,PDIEN_",",17,"I")
 S DTICIV=9999999.999999-DTIC
 S X=(DTICIV=$$DTINS^A1AEF2(PD))
 D CHKEQ^%ut(1,X,"Testing $$DTINS^A1AEF2 - get INVERSE Install DT  FAILED!")
 Q
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
 ;         POO("DG*5.3*417")=""
 ;         POO("DG*5.3*451")=""
 ;         POO("DG*5.3*454")=""
 ;         POO("DG*5.3*491")=""
 ;         POO("DG*5.3*513")=""
 ;         POO("DG*5.3*564")=""
 ;         POO("DG*5.3*672")=""
 ;         POO("DG*5.3*688")=""
 ;         POO("DG*5.3*717")=""
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
 N A1AEFILE S A1AEFILE=11005,A1AENAME="DHCP PATCHES" I '$D(^DIC(11005)) S A1AEFILE=11004,A1AENAME="PATCH" ; JLI 150525
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
 N A1AEFILE S A1AEFILE=11005,A1AENAME="DHCP PATCHES" I '$D(^DIC(11005)) S A1AEFILE=11004,A1AENAME="PATCH" ; JLI 150525
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
 ;;UTP35;Testing $$PTC4RTN^A1AEF1 - patches to build RTN 2nd line
 ;;UTP36;Testing LOADXTMP^A1AEF2 - Load Build Components
 ;;UTP37;Testing $$DTINS^A1AEF2 - get INVERSE Install DT
 Q
 ;
EOR ; end of routine A1AEUF5A
