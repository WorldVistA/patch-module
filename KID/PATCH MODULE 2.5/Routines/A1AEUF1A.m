A1AEUF1A ;ven/lgc,jli-unit tests for A1AEF1 cont ;2015-05-26T15:56
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
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 L +^XPD(9.6):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on BUILD [#9.6] file"
 . W !," Unable to perform testing."
 ;
 L +^A1AE(A1AEFILE):1 I '$T D  Q  ; JLI 150525
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on PATCHES [#"_A1AEFILE_"] file" ; JLI 150525
 . W !," Unable to perform testing."
 Q
 ;
SHUTDOWN L -^XPD(9.6):1
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 L -^A1AE(A1AEFILE):1 ; JLI 150525
 I '$$DELPAT D
 . W !,"Unable to delete test entries in "_A1AEFILE,!
 ;
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ; Testing 
 ;   1. PTC4RTN^A1AEF1(A1AERTNM,.PTCHARR)
 ;   2. PTCRTNS^A1AEF1(A1AEPIEN,.PTCHARR)
 ;
UTP6 I '$G(A1AEFAIL) S X=$$PTC4RTN D
 . D CHKEQ^%ut(1,X,"Testing REQB dependencies FAILED!")
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
PTC4RTN() S X=1
 ; Find a routine with several patches - at least one
 ;  of which is found in DHCP PATHES [#11005]
 N POO I '$$BLDPARR(.POO,.RTN) D  Q
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
 N CNT,PNMB
 F CNT=1:1:$L(A1AE2LN,",") S PNMB=$P(A1AE2LN,",",CNT) D  Q:'X
 . S PNM=A1AESABB_"*"_A1AEVR_"*"_PNMB
 . I '$D(POO(PNM)) S X=0 Q
 . N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 . I +POO(PNM),'$D(^A1AE(A1AEFILE,+POO(PNM))) S X=0 Q
 . I +POO(PNM),'$O(^A1AE(A1AEFILE,+POO(PNM),"P","B",RTN,0)) S X=0
 . K POO(PNM)
 Q:$O(POO(""))="" 1
 Q X
 ;
 ;
 ;
UTP7 I '$G(A1AEFAIL) S X=$$PTCRTNS D
 . D CHKEQ^%ut(0,X,"Testing REQB dependencies FAILED!")
 Q
 ;
 ; Testing PTCRTNS^A1AEF1
 ; ENTER
 ;    RTN  =  ROUTINE NAME
 ;    POO  =  Array of patch names with IEN into 11005
 ; RETRUN
 ;    0 = successful, 1 = error
PTCRTNS() N X S X=0
 ; Find a routine with several patches - at least one
 ;  of which is found in DHCP PATHES [#11005]
 N POO I '$$BLDPARR(.POO,.RTN) D  Q
 . S X=1
 . W !,"Unable to find suitably patched routine"
 . W !," Unable to perform testing."
 ;
 N PD,A5IEN S PD=$O(POO("")),A5IEN=$G(POO(PD))
 N PPP D PTCRTNS^A1AEF1(A5IEN,.PPP)
 N LN2,RTN,PCH,A1AEIEN
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 N NODE S NODE=$NA(PPP(" "))
 F  S NODE=$Q(@NODE) Q:NODE'["PPP("  D  Q:X
 .; Pull out RTN name, PATCH name, and 11005
 .  S RTN=$QS(NODE,1)
 .  S PCH=","_$P($QS(NODE,2),"*",3)_","
 .  S A1AEIEN=@NODE
 .; Capture line 2 of active routine on system
 .  S LN2=","_$P($T(+2^@RTN),"**",2)_","
 .; Check patch number on line 2
 .  I LN2'[PCH S X=1 Q
 .; If indication patch is in 11005, check routine part of patch
 .  I A1AEIEN,'$O(^A1AE(A1AEFILE,A1AEIEN,"P","B",RTN,0)) S X=1 ; JLI 150525
 Q X
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
 ;   nothing required
 ; RETURN
 ;   0 = error, 1 = deletions complete
DELPAT() N DA,DIK,PAT,NOERR S PAT=0,NOERR=1
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
 ; ENTER
 ;    PD   =  PATCH DESIGNATION
 ;    RTN  =  ROUTINE NAME to add to 11005 PD entry
 ; RETURNS
 ;    0 = error,  IEN of patch if successful
MKPATCH(PD,RTN) Q:PD="" 0
 N X,Y,DA,DIC,DIEN
 N PKGIEN S PKGIEN=$O(^DIC(9.4,"C",$P(PD,"*"),0)) Q:PKGIEN="" 0
 N PKGAV S PKGAV=$$GET1^DIQ(9.4,PKGIEN_",",13) Q:'PKGAV 0
 N PTCHNB S PTCHNB=+$P(PD,"*",3) Q:'PTCHNB 0
 N PTSTRM S PTSTRM=$S(PTCHNB>10001:10001,1:1)
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
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
 ;
UP(STR) Q $TR(STR,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 ;
 ;
XTENT ;
 ;;UTP6;Testing gathering a routine's line2 patches
 ;;UTP7;Testing gathering all patches routines
 Q
 ;
 ;
EOR ; end of routine A1AEUF1A
