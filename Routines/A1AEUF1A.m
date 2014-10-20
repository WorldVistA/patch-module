A1AEUF1A ;VEN/LGC/JLI - UNIT TESTS FOR A1AEF1 CONT ; 10/20/14 7:06am
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
 Q
 ;
SHUTDOWN L -^XPD(9.6):1
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ; Testing 
 ;   1. PTC4RTN^A1AEF1(A1AERTNM,.PTCHARR)
 ;   2. PTCRTNS^A1AEF1(A1AEPIEN,.PTCHARR)
 ;   3. PTC4KIDS^A1AEF1(BUILD,.BARR)
 ;   4. PTCSTRM^A1AEF1(.BARR)
 ;   5. UPDPAT^A1AEF1(BUILD.BARR)
 ;
UTP5 I '$G(A1AEFAIL) S X=$$PTC4RTN D
 . D CHKEQ^%ut(1,X,"Testing REQB dependencies FAILED!")
 Q
 ;
UTP6 I '$G(A1AEFAIL) S X=$$PTCRTNS D
 . D CHKEQ^%ut(0,X,"Testing REQB dependencies FAILED!")
 Q
 ;
 ;
 ; Testing PTC4RTN logic 
 ;   1. Look in routine file for a routine with significant patching
 ;   2. Run PTC4RTN^A1AEF1 for this routine
 ;   3. Pull up 2nd line of the routine and run through
 ;      each "," delimited patch
 ;   4. Check this patch is in POO global
 ;   5. Check this patch in 11005 if POO(xxx)=ien into 11005
 ;   6. Kill each POO node after check to be certain not
 ;      excess POO nodes
 ;
PTC4RTN() S X=1
 D P4RTN(.POO,.RTN)
 Q:RTN="" 0
 ; Pick up 2nd line and run through each patch listed
 ;   is there a POO(name) array entry
 ;   if POO(name)>0 (=IEN in file 11005) 
 ;      check the patch is in 11005
 ;      check the routine is in the patch
P1 N A1AE2LN S A1AE2LN=$T(+2^@RTN)
 N A1AEVR S A1AEVR=$P(A1AE2LN,";",3)
 I A1AEVR?.NP1"0" S A1AEVR=$P(A1AEVR,".")
 N A1AESNM S A1AESNM=$P(A1AE2LN,";",4) Q:A1AESNM="" 0
 S A1AESNM=$$UP(A1AESNM)
 N A1AESIEN S A1AESIEN=$O(^DIC(9.4,"B",A1AESNM,0)) Q:'A1AESIEN 0
 N A1AESABB S A1AESABB=$$GET1^DIQ(9.4,A1AESIEN_",",1) Q:A1AESABB="" 0
 S A1AE2LN=$P(A1AE2LN,"**",2)
 N CNT,PNMB
 F CNT=1:1:$L(A1AE2LN,",") S PNMB=$P(A1AE2LN,",",CNT) D  Q:'X
 . S PNM=A1AESABB_"*"_A1AEVR_"*"_PNMB
 . I '$D(POO(PNM)) S X=0 Q
 . I +POO(PNM),'$D(^A1AE(11005,+POO(PNM))) S X=0 Q
 . I +POO(PNM),'$O(^A1AE(11005,+POO(PNM),"P","B",RTN,0)) S X=0
 . K POO(PNM)
 I $D(POO) Q 0
 Q X
 ; Look through routine file and find routine with a second
 ;   line with necessary fields PACKAGE,VERSION and 
 ;   with a number of patches reflected by a patch line
 ;   of greater than 90 characters 
 ; Further, require that at least one of these patches
 ;   is found in the DHCP PATCHES [#11005] file
P4RTN(POO,RTN) K POO,RTN S RTN=""
 N IEN,NODE,X S NODE=$NA(^DIC(9.8,"B")),X=0
 F  S NODE=$Q(@NODE) Q:NODE'["^DIC(9.8,""B"""  D  Q:X>90
 . S IEN=$QS(NODE,4) I $O(^DIC(9.8,IEN,8,"A"),-1) D 
 ..  S X=$L(^DIC(9.8,IEN,8,$O(^DIC(9.8,IEN,8,"A"),-1),0))
 ..  S RTN=$QS(NODE,3)
 ..  S X=$L($T(+2^@RTN)) ; confirm RTN exists & length of second ln
 ..  D PTC4RTN^A1AEF1(RTN,.POO) I '$D(POO) S X=0 Q
 ..  S X=$$P4RTN2(.POO,X)  ; confirm array has usable patch names
 Q
P4RTN2(POO,X) N PNM,Y S PNM="",Y=0
 F  S PNM=$O(POO(PNM)) Q:PNM=""  D  Q:'X
 .  I $L(PNM,"*")'=3 S X=0 Q
 .  I POO(PNM)>0 S Y=1
 Q:Y +$G(X)
 Q 0
 ;
 ;
 ; Testing PTCRTNS^A1AEF1
PTCRTNS() N X S X=0
 ; Find a routine with several patches - at least one
 ;  of which is found in DHCP PATHES [#11005]
 D P4RTN(.POO,.RTN)
 S RTN="" F  S RTN=$O(POO(RTN)) Q:RTN=""  Q:POO(RTN)>0
 Q:RTN="" 1
 ; Run through returned array assuring that each
 ;   patch notes is, if fact, in the second line
 ;   of the active routine noted.
 ; AND further, if the array shows an IEN into
 ;   the DHCP PATCHES file, check that the 
 ;   indicated routine was included in this patch
 D PTCRTNS^A1AEF1(+POO(RTN),.POO)
 ; Example entry array nodes returned by call
 ;   POO("DG10","DG*5.3*642")=""
 ;   POO("DG10","DG*5.3*658")=""
 ;   POO("DG10","DG*5.3*773")=129211
 ;   POO("DGMTCOR","DG*5.3*182")=""
 ;   POO("DGMTCOR","DG*5.3*21")=""
 S NODE=$NA(POO)
 N RTN,PCH,A1AEIEN,LN2
 F  S NODE=$Q(@NODE) Q:NODE'["POO("  D  Q:X
 .; Pull out RTN name, PATCH name, and 11005
 .  S RTN=$QS(NODE,1),PCH=","_$P($QS(NODE,2),"*",3)_",",A1AEIEN=@NODE
 .; Capture line 2 of active routine on system
 .  S LN2=","_$P($T(+2^@RTN),"**",2)_","
 .; Check patch number on line 2
 .  I LN2'[PCH S X=1 Q
 .; If indication patch is in 11005, check routine part of patch
 .  I A1AEIEN,'$O(^A1AE(11005,A1AEIEN,"P","B",RTN,0)) S X=1
 Q X
 ;
 ;
 ;
UP(STR) Q $TR(STR,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 ;
XTENT ;
 ;;UTP5;Testing gathering a routine's line2 patches
 ;;UTP6;Testing gathering all patches routines
 Q
 ;
 ;
EOR ; end of routine A1AEUF1A
