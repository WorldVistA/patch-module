A1AEF4 ;VEN/LGC - ADD REQUIRED PATCHES OTHER STREAMS ; 11/5/14 5:53pm
 ;;2.4;PATCH MODULE;;SEP 11, 2014
 ;
 ; Enter with BUILD name
 ;  1. Add patches derived from for other stream
 ;  2. Update PAT multiple
 ;ENTER
 ;   BUILD   =  Name of parent build in question
 ;RETURN
 ;   BUILD UPDATED
 ;   0 = error,  1 = updated successfully
OTHSTRM(BUILD) ;
 N NOERR S NOERR=1
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) I 'BIEN D  Q 0
 . W !,"Build:"_BUILD_" Not found in BUILD [#9.6] file."
 . W $C(7),!,!
 ;
 ; Add patches derived for other stream
 ; Run through all REQB pre-requisites
 N REQB S REQB=""
 F  S REQB=$O(^XPD(9.6,BIEN,"REQB","B",REQB)) Q:REQB=""  D  Q:'NOERR
 .  S PD=$$DERPTC(REQB) Q:PD=""
 .  S NOERR=$$ADBTORM^A1AEF1(BIEN,PD,"R")
 ; Run through all MULB member builds
 N MULB S MULB=""
 F  S MULB=$O(^XPD(9.6,BIEN,10,"B",MULB)) Q:MULB=""  D  Q:'NOERR
 .  S PD=$$DERPTC(MULB) Q:PD=""
 .  S ERR=$$ADBTORM^A1AEF1(BIEN,PD,"M")
 ;
 ; Update PAT multiple in parent build after adding
 ;   new builds from other streams
 N BARR S (REQB,MULB)=""
 F  S REQB=$O(^XPD(9.6,BIEN,"REQB","B",REQB)) Q:REQB=""  D
 . S BARR(REQB)=""
 F  S MULB=$O(^XPD(9.6,BIEN,10,"B",MULB)) Q:MULB=""  D
 . S BARR(MULB)=""
 ; Ignore user's patch stream, just update all
 D UPDPAT^A1AEF1(BUILD,.BARR)
 Q:'NOERR 0  Q 1
 ;
 ; ENTER
 ;    PD     =   PATCH DESIGNATION (BUILD NAME) from
 ;               REQB or MULB multiple of parent build [BIEN]
 ; RETURN
 ;    NAME of patch derived from PD
DERPTC(PD) ;
 Q:PD="" PD
 N PATIEN S PATIEN=+$O(^A1AE(11005,"ADERIVED",PD,0))
 Q:PATIEN $$GET1^DIQ(11005,PATIEN_",",.01) 
 ;
 ; Adjust PD where build version includes ".0" which is not
 ;  allowed in DHCP PATCHES [#11005] file
 I $P(PD,"*",2)'?.EP1"0" Q ""
 S $P(PD,"*",2)=$P($P(PD,"*",2),".")
 S PATIEN=+$O(^A1AE(11005,"ADERIVED",PD,0))
 Q:'PATIEN ""
 Q $$GET1^DIQ(11005,PATIEN_",",.01)
 ;
 ;
EOR ; end of routine A1AEF4
