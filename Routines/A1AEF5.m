A1AEF5 ;ven/lgc-find every related build ;2015-02-16T17:31
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-11-28: version 2.4 released
 ;
 ;
 ; Enter with BUILD name
 ;   1. Save ^XTMP($J,PARENT BUILD,PARENT BUILD)=PARENTIEN
 ;   1. Find all REQB for parent build
 ;   2. Save in ^XTMP($J,PARENT BUILD,ASSOC BUILD)=ASBLDIEN
 ;   3. Find all MULB for parent build
 ;   4. Save in ^XTMP($J,PARENT BUILD,ASSOC BUILD)=ASBLDIEN
 ;   5. Find all MULB for all REQB
 ;
 ;   6. Go through every build (PARENT and ASSOCIATE)
 ;      a. Find all routines
 ;         Save patches requred for this routine
 ;            use  PTCRTNS^A1AEF1(A1AEPIEN,.PTCHARR) 
 ;         ^XTMP($J,PARENT BUILD,ASSOCIATED BUILD,ROUTINE)=
 ;            PATCH NAME
 ;      b. Find every component in build
 ;         Use LOADXTMP^A1AEF2(PARENT BUILD,ASSBIEN,DTINS)
 ;            Note: this doesn't clear so can do repeatedly
 ;                  for each build
 ;      c. Run through every component and find every 
 ;         build that contained this component or file
 ;         add to ^XTMP($J,PARENT BUILD,ASSOC BUILD,COMPONENT)
 ;
 ;   7. Show totals for all builds associated and total
 ;      number of ^XTMP($J nodes [indication of complexity
 ;      of relationships.
 ;      Include total blds associated and then reduced
 ;      limited number of builds by removing all but
 ;      leading build of non-related packages.
 ;
 ; ENTER
 ;   BUILD  = Parent BUILD under scrutiny
 ;   MSG    = 1:build MSGTXT
 ;            0:print statistics to terminal
 ; RETURN
 ;   MSG    = 1:return MSGTXT as function
 ;            0:return "" as function AND
 ;              print full statistics with comments to terminal
FNDALL(BUILD,MSG) ;
 K ^XTMP($J)
 S:'$G(MSG) MSG=0
 N MSGTXT,REQB,MULB S (MSGTXT,REQB,MULB)=""
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN
 S ^XTMP($J,BUILD,BUILD)=BIEN
 W:'$G(MSG) !,"$J=",$J," BUILD being evaluated : ",BUILD
 ;
 I $G(MSG) D
 . N CNT S CNT=0
 . S (REQB,MULB)=""
 . F  S REQB=$O(^XPD(9.6,BIEN,"REQB","B",REQB)) Q:REQB=""  D
 .. S CNT=CNT+1
 . S MSGTXT="REQB^"_CNT_"^",CNT=0
 . F  S MULB=$O(^XPD(9.6,BIEN,10,"B",MULB)) Q:MULB=""  D
 .. S CNT=CNT+1
 . S MSGTXT=MSGTXT_"MULB^"_CNT_"^"
 . S (REQB,MULB)=""
 ;
 ; Get recursive built array of all REQB and MULB
 ;  for the parent build
 D REQB^A1AEF1(BUILD,.REQB)
 D MULB^A1AEF1(BUILD,.MULB)
 S REQB=" " F  S REQB=$O(REQB(REQB)) Q:REQB=""  D
 .  S ^XTMP($J,BUILD,REQB)=REQB(REQB)
 S MULB=" " F  S MULB=$O(MULB(MULB)) Q:MULB=""  D
 .  S ^XTMP($J,BUILD,MULB)=MULB(MULB)
 ;
 I '$G(MSG) D
 . W !,"REQB and MULB run individually",!
 . W !,!,"TOTAL NODES IN ^XTMP = ",$$CNTNODES
 . W !,"TOTAL BUILDS ASSOCIATED = ",$$CNTBLDS
 . W !,!
 E  D
 . N TOTRMR S TOTRMR=$$CNTBLDS
 . S MSGTXT=MSGTXT_"TOTRMR^"_TOTRMR_"^"
 ;
 D FND1(BUILD,MSG,.MSGTXT)
 D FND2(BUILD,MSG,.MSGTXT)
 D FND3(BUILD,MSG,.MSGTXT)
 D FND4(BUILD,MSG,.MSGTXT)
 D FND5(BUILD,MSG,.MSGTXT)
 Q:$G(MSG) BUILD_"^"_MSGTXT
 Q
 ;
 ; Now we have checked for all REQB, but not for
 ;  all MULT builds OF THE REQUIRED BUILDS
 ; ENTER
 ;    BUILD = name of PARENT build under inspection
 ;    MSG   = 1:build MSGTXT
 ;            0:print statistics to terminal
 ;    ^XTMP($J,BUILD under construction
 ; RETURN
 ;    ^XTMP($J,BUILD updated
FND1(BUILD,MSG,MSGTXT) ; Check REQB for MULB
 N MULBTMP,BLD
 S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 . D MULB^A1AEF1(BLD,.MULB)
 . M MULBTMP=MULB
 ; Pull these into ^XTMP array
 S MULB=" " F  S MULB=$O(MULBTMP(MULB)) Q:MULB=""  D
 .  S ^XTMP($J,BUILD,MULB)=MULBTMP(MULB)
 ; Now we have all the REQB and MULB for those builds
 ;   entered into the PARENT BUILDS REQB and MULB fields
 ;
 I '$G(MSG) D
 . W !,"Adding MULB of the REQB",!
 . W !,!,"TOTAL NODES IN ^XTMP = ",$$CNTNODES
 . W !,"TOTAL BUILDS ASSOCIATED = ",$$CNTBLDS
 . W !,!
 E  D
 . N TOTRMRM S TOTRMRM=$$CNTBLDS
 . S MSGTXT=MSGTXT_"TOTRMRM^"_TOTRMRM_"^"
 Q
 ;
 ; Add PATCHES (BUILDS) required to build the second
 ;   line of every routine contained in all builds
 ; ENTER
 ;    BUILD = name of PARENT build under inspection
 ;    MSG   = 1:build MSGTXT
 ;            0:print statistics to terminal
 ;    ^XTMP($J,BUILD array under construction
 ; RETURN
 ;    ^XTMP($J,BUILD updated
FND2(BUILD,MSG,MSGTXT) ; Add all patches to build routines
 N BLD,RTNARR,RTNNM,PTCH,PTCHIEN,PTCHARR
 S BLD=" " F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 . D RTNSINB(BLD,.RTNARR)
 . S RTNNM="" F  S RTNNM=$O(RTNARR(RTNNM)) Q:RTNNM=""  D
 .. D PTC4RTN^A1AEF1(RTNNM,.PTCHARR)
 .. Q:'$D(PTCHARR)
 .. S PTCH=" " F  S PTCH=$O(PTCHARR(PTCH)) Q:PTCH=""  D
 ...; Fix patches integer and no .0
 ... I $P(PTCH,"*",2)=$P($P(PTCH,"*",2),".") D
 .... S $P(PTCH,"*",2)=$P(PTCH,"*",2)_".0"
 ... S PTCHIEN=+$O(^XPD(9.6,"B",PTCH,0))
 ... S ^XTMP($J,BUILD,PTCH)=PTCHIEN
 ... S ^XTMP($J,BUILD,PTCH,RTNNM,"R")=""
 ;
 I '$G(MSG) D
 . N A1AEFILE S A1AEFILE=11004,A1AENAME="PATCH" I '$D(^DIC(11004)) S A1AEFILE=11005,A1AENAME="DHCP PATCHES" ; JLI 150525 
 . W !,"Adding all patches (BUILDS) found in the"
 . W !," second line of all routines associated with"
 . W !," the full array of BUILDS identified to date"
 . W !,"Note: the patch names are built from the"
 . W !," information in the routine.  Thus, these"
 . W !," patches (BUILDS) may not be in either the"
 . ;W !," DHCP PATCHES [#11005] nor BUILDS [#9.6] file.",! ; JLI 150525 commented out replaced by next line
 . W !," "_A1AENAME_" [#"_A1AEFILE_"] nor BUILDS [#9.6] file.",! ; JLI 150525 works for either file
 . W !,!,"TOTAL NODES IN ^XTMP = ",$$CNTNODES
 . W !,"TOTAL BUILDS ASSOCIATED = ",$$CNTBLDS
 . W !,!
 E  D
 . N TOTP4R S TOTP4R=$$CNTBLDS
 . S MSGTXT=MSGTXT_"TOTP4R^"_TOTP4R_"^"
 Q
 ;
 ;
 ; Now look through every build's components and find
 ;  every build that also touched these components
 ; NOTE: *** Some patches will not be in 9.6, therefore
 ;       will not be included in looking at components
 ; ENTER
 ;    BUILD = name of PARENT build under inspection
 ;    MSG   = 1:build MSGTXT
 ;            0:print statistics to terminal
 ;    ^XTMP($J,BUILD under construction
 ; RETURN
 ;    ^XTMP($J,BUILD updated
FND3(BUILD,MSG,MSGTXT) ; Find every build with similar components
 N BLD,BLDIEN,DTINS S BLD=" "
 F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 .  S BLDIEN=+$G(^XTMP($J,BUILD,BLD))
 .  I BLDIEN D
 ..  S DTINS=$$DTINS^A1AEF2(BLD)
 ..  D:DTINS LOADXTMP^A1AEF2(BUILD,BLDIEN,DTINS)
 ;
 I '$G(MSG) D
 . W !,"Adding nodes to ^XTMP for all components in "
 . W !," the array of builds. "
 . W !,"Note: this pulls only components INSTALLED, thus"
 . W !," if there is no record of install in file #9.7"
 . W !," the component would not be captured at this point",!
 . W !,!,"TOTAL NODES IN ^XTMP = ",$$CNTNODES
 . W !,"TOTAL BUILDS ASSOCIATED = ",$$CNTBLDS
 . W !,!
 Q
 ;
 ; In ^XPD
 ;  $QS(NODE,3)="KRN"
 ;  $QS(NODE,4)="B"
 ;  $QS(NODE,5)= numeric for component
 ;  $QS(NODE,6)= name of component
 ;    unless file, then
 ;  $QS(NODE,3)= 4
 ;  $QS(NODE,4)= file number
 ;^XPD(9.6,BIEN,4,FILE#)=FILE#           FILES
 ;^XPD(9.6,BIEN,"KRN","B",.4,CI) =       PRINT TEMPLATES
 ;^XPD(9.6,BIEN,"KRN","B",.401,CI) =     SORT TEMPLATES
 ;^XPD(9.6,BIEN,"KRN","B",.402,CI) =     INPUT TEMPLATES
 ;^XPD(9.6,BIEN,"KRN","B",.403,CI) =     FORMS
 ;^XPD(9.6,BIEN,"KRN","B",.5,CI) =       FUNCTIONS
 ;^XPD(9.6,BIEN,"KRN","B",.84,CI) =      DIALOG
 ;^XPD(9.6,BIEN,"KRN","B",3.6,CI) =      BULLETINS
 ;^XPD(9.6,BIEN,"KRN","B",9.2,CI) =      HELP FRAME
 ;^XPD(9.6,BIEN,"KRN","B",9.8,CI) =      ROUTINES
 ;^XPD(9.6,BIEN,"KRN","B",19,CI) =       OPTIONS
 ;^XPD(9.6,BIEN,"KRN","B",19.1,CI) =     SECURITY KEYS
 ;^XPD(9.6,BIEN,"KRN","B",101,CI) =      PROTOCOL
 ;^XPD(9.6,BIEN,"KRN","B",409.61,CI) =   LIST TEMPLATE
 ;^XPD(9.6,BIEN,"KRN","B",8994,CI) =     REMOTE PROCEDURE
 ;
 ; In ^XTMP
 ;  $QS(NODE,2)= numeric for component
 ;  $QS(NODE,3)= name of component or number of file
 ;^XTMP(17311,.4,"DG SI LIST    FILE #2",7019669.857859,"SD*5.3*70",1382)
 ;^XTMP(17311,3.8,"YS MHA-MHNDB",6899291.839066,"SD*5.3*70",8300)
 ;^XTMP(17311,3.8,"YS MHA-MHNDB",6919796.778282,"SD*5.3*70",7452)
 ;^XTMP(17311,4,.11,6999795.859968,"SD*5.3*70",2699)
 ;^XTMP(17311,4,.11,7009279.885882,"SD*5.3*70",2367)
 ;
 ;  $QS(NODE,3)="KRN"
 ;  $QS(NODE,4)="B"
 ;  $QS(NODE,5)= numeric for component
 ;  $QS(NODE,6)= name of component
 ;    unless file, then
 ;  $QS(NODE,3)= 4
 ;  $QS(NODE,4)= file number
 ;  $QS(NODE,5)= 0  to prevent getting info nodes
 ; ENTER
 ;    BUILD = name of PARENT build under inspection
 ;    MSG   = 1:build MSGTXT
 ;            0:print statistics to terminal
 ;    ^XTMP($J = array of builds from previous LOADXTMP call
 ; RETURN
 ;    ^XTMP($J,BUILD updated
FND4(BUILD,MSG,MSGTXT) ; Get all builds for components in ^XTMP
 N NODE,BIEN,NMCMP,NMRICMP S NODE=$NA(^XPD(9.6))
 F  S NODE=$Q(@NODE) Q:NODE'["^XPD(9.6"  D
 . S BIEN=+$QS(NODE,2)
 . I $QS(NODE,3)=4,$QS(NODE,2),$QS(NODE,4),$QS(NODE,5)=0 D
 .. N FNMBR S FNMBR=$QS(NODE,4)
 .. I $D(^XTMP($J,4,FNMBR)) D  Q
 ... S ^XTMP($J,BUILD,$P(^XPD(9.6,BIEN,0),"^"),"F")=+$QS(NODE,2)_"^"_FNMBR
 .;
 . I $QS(NODE,3)["KRN",$QS(NODE,4)["B" D
 .. S NMRICMP=$QS(NODE,5)
 .. S NMCMP=$QS(NODE,6)
 .. I $D(^XTMP($J,NMRICMP,NMCMP)) D
 ... S ^XTMP($J,BUILD,$P(^XPD(9.6,BIEN,0),"^"),"C")=BIEN_"^"_NMRICMP_"^"_NMCMP
 ;
 I '$G(MSG) D
 . W !,"Adding every build which touched the components found"
 . W !,"  in the search above, and adding the component info"
 . W !,"  to the ^XTMP array",!
 . W !,!,"TOTAL NODES IN ^XTMP = ",$$CNTNODES
 . W !,"TOTAL BUILDS ASSOCIATED = ",$$CNTBLDS
 . W !,!
 E  D
 . N TOTCMP S TOTCMP=$$CNTBLDS
 . S MSGTXT=MSGTXT_"TOTCMP^"_TOTCMP_"^"
 .; W !,BUILD,"^",MSGTXT
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
FND5(BUILD,MSG,MSGTXT) ; Limit builds to one from other packages
 N BLDARR D DISPLMT(BUILD,.BLDARR)
 I '$G(MSG) D
 . W !,"Limiting associated builds to a single example"
 . W !,"  of each patch array not belonging to the"
 . W !,"  package of the parent BUILD being examined",!
 . W !,"Also remove all BUILDS not associated with an"
 . W !,"  ACTIVE version of the package represented.",!
 . W !,"TOTAL BUILDS ASSOCIATED = ",$G(BLDARR(0))
 . W !,!
 E  D
 . S MSGTXT=MSGTXT_"LMTD^"_$G(BLDARR(0))_"^"
 Q
 ;
 ; Count total nodes in ^XTMP($J as indicator of
 ;  complexity of relationships
 ; ENTER
 ;   ^XTMP($J = array of builds from previous LOADXTMP call
 ; RETURN
 ;   Count of nodes
CNTNODES() ; Count total nodes in ^XTMP
 N NODE,CNT S NODE=$NA(^XTMP($J)),CNT=0
 F  S NODE=$Q(@NODE) Q:NODE'[("^XTMP("_$J)  S CNT=CNT+1
 Q CNT
 ;
 ;
 ; ENTER
 ;   ^XTMP($J = array of builds from previous LOADXTMP call
 ; RETURNS
 ;   CNT  =  Count of BUILDS in ^XTMP array that
 ;           represent a current version of their package
CNTBLDS() ; Count all builds in ^XTMP
 N BLD,CNT S BLD=" ",CNT=0
 F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 . S:$$BACTV^A1AEF1(BLD) CNT=CNT+1
 Q CNT
 ;
 ;
 ; Build array of all routines contained in a BUILD
 ; ENTER
 ;   BUILD  = NAME OF BUILD
 ;   RTNARR = ARRAY PASSED BY REFERENCE
 ; RETURN
 ;   RTNARR   = ARRAY OF ROUTINES IN BUILD
RTNSINB(BUILD,RTNARR) ; Return array of patches from RTN 2nd line
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
 ; Display all builds associated with the parent BUILD
 ;   which belong to a currently active package
 ; ENTER
 ;    BUILD    = name of parent BUILD under inspection
 ;    MSG      = 1:build MSGTXT
 ;               0:print statistics to terminal
 ;    ^XTMP($J = array of builds from previous LOADXTMP call
 ; RETURN
 ;    MSG   = 0: Number of builds displayed to terminal
 ;               null returned as function
 ;          = 1: Number of builds returned as function
DISP(BUILD,MSG) ; Display all builds associated with parent
 N BLD,CNT S BLD=" ",CNT=0
 F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 . I $$BACTV^A1AEF1(BLD) S CNT=CNT+1
 . W:'$G(MSG) !,BLD
 I '$G(MSG) D  Q ""
 . W !,!,"Number of builds : ",CNT
 E  Q CNT
 Q
 ;
 ; Display all builds associated with the parent BUILD
 ;   which belong to a currently active package
 ; AND
 ;   Limiting associated builds to a single example
 ;     of each patch array not belonging to the
 ;     package of the parent BUILD being examined
 ; ENTER
 ;    BUILD = name of parent BUILD under inspection
 ;    MSG   = 1:build MSGTXT
 ;            0:print statistics to terminal
 ;    ^XTMP($J = array of builds from previous LOADXTMP call
 ; RETURN
 ;    BLDARR    = array of builds identified
 ;    BLDARR(0) = Number of builds identified
DISPLMT(BUILD,BLDARR) ; Display limited array of builds
 N BLD S BLD=" "
 K BLDARR
 F  S BLD=$O(^XTMP($J,BUILD,BLD)) Q:BLD=""  D
 . I $$BACTV^A1AEF1(BLD) D
 .. I $P(BLD,"*")=$P(BUILD,"*") S BLDARR($P(BLD,"*"))="" Q
 .. Q:$D(BLDARR($P(BLD,"*")))
 .. S BLDARR($P(BLD,"*"))=""
 N CNT,NODE S CNT=0,NODE=$NA(BLDARR)
 F  S NODE=$Q(@NODE) Q:NODE'["BLDARR("  D
 .  S CNT=CNT+1
 S BLDARR(0)=CNT
 Q
 ;
TESTIT(BLD96) ; Temporary test of FINDALL for all builds in 9.6
 S:'$D(BLD96) BLD96=""
 F  S BLD96=$O(^XPD(9.6,"B",BLD96)) Q:BLD96=""  D
 . I $E(BLD96)'=" " W !,$$FNDALL^A1AEF5(BLD96,1)
 Q
 ;
EOR ; end of routine A1AEF5
