A1AEF1 ;ven/lgc-functions builds and installs ;2015-02-15T17:37
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-09-11: version 2.4 released
 ;
 ;
 ; CHANGE LGC - 9/18/2014
 ;    Modified REQB to build double array
 ;    BMARR(BUILD)=IEN into 9.6
 ;    BMARR(n,BUILD)=Depth in descendants
 ;
 ; CHANGE LGC - 10/1/2014
 ;    Note requirement to kill array passed
 ;    by reference in REQB and MULB before
 ;    calling API.
 ;    A1AEFRQB edited to N BMARR
 ;    A1AEFMUB edited to N BMARR
 ;
 ; CHANGE LGC - 12/1/2014
 ;    Modified BACTV to find PACKAGE IEN by either
 ;    direct lookup into entry in 9.6 OR by
 ;    looking up package abb in the "C" cross
 ;
 ; Return in BMARR array all REQUIRED BUILDS for
 ;  a the BUILD entry in BUILDS [#9.6]
 ; Code by Rick Marshall and Joel Ivey during dev conference call
 ;    discussing recursion practices
 ; ENTER
 ;   BUILD   =  bill name 
 ;   BMARR   =  array passed by reference
 ;              *** Array must be empty
 ; EXIT
 ;   BMARR   =  array of names of all REQUIRED BUILDS
REQB(BUILD,BMARR) ; Return array of all REQ builds
 S:'$D(BMARR(0)) BMARR(0)=0,BMARR(0,0)=1
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) ; do we have an IEN?
 Q:'BIEN  ; skip if no record
 S BMARR(BUILD)=$O(^XPD(9.6,"B",BUILD,0)) ; add to requirements
 I BMARR(0,0)>0 S BMARR(0)=BMARR(0)+1,BMARR(BMARR(0),BUILD)=BMARR(0,0)
 N REQB S REQB=""
 F  S REQB=$O(^XPD(9.6,BIEN,"REQB","B",REQB)) Q:REQB=""  D
 . Q:$D(BMARR(REQB))  ; already have
 . S BMARR(0,0)=BMARR(0,0)+1
 . D REQB(REQB,.BMARR) ; add all its required builds
 S BMARR(0,0)=BMARR(0,0)-1 Q
 ;
 ; Return in BMARR array all MULTIPLE BUILDS for
 ;  a the BUILD entry in BUILDS [#9.6]
 ; ENTER
 ;   BUILD   =  bill name 
 ;   BMARR   =  array passed by reference
 ;              *** array must be empty
 ; EXIT
 ;   BMARR   =  array of names of all Multiple Builds
MULB(BUILD,BMARR) ; Return array of all MULB builds
 S:'$D(BMARR(0)) BMARR(0)=0,BMARR(0,0)=1
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) ; do we have an IEN?
 Q:'BIEN  ; skip if no record
 S BMARR(BUILD)=$O(^XPD(9.6,"B",BUILD,0)) ; add to requirements
 I BMARR(0,0)>0 S BMARR(0)=BMARR(0)+1,BMARR(BMARR(0),BUILD)=BMARR(0,0)
 N MULB S MULB=""
 F  S MULB=$O(^XPD(9.6,BIEN,10,"B",MULB)) Q:MULB=""  D
 . Q:$D(BMARR(MULB))  ; already have
 . S BMARR(0,0)=BMARR(0,0)+1
 . D MULB(MULB,.BMARR) ; add all its MULTIPLE builds
 S BMARR(0,0)=BMARR(0,0)-1 Q
 ;
 ;
 ; Use the REQB function above to find all decendents of the
 ;   present REQUIRED BUILD entries for this parent build
 ;   and push them into the REQUIRED BUILDS [#11] multiple
 ; ENTER
 ;   BUILD    =  Name of parent build to edit REQB multiple
 ; EXIT
 ;   RETURN X =  0=error  1=ok
A1AEFRQB(BUILD) ; File REQUIRED BUILDS
 Q:BUILD=""
 N X
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN
 N BMARR D REQB(BUILD,.BMARR)
 Q:'$D(BMARR)
 ; CHANGE 9/18/2014 BLDNM=" " rather than BLDNM=""
 ;   to account for modification of REQB to double array
 N BLDNM,DIERR S BLDNM=" "
 F  S BLDNM=$O(BMARR(BLDNM)) Q:BLDNM=""  D  Q:'X
 .  Q:BUILD=BLDNM
 .  S X=$$ADBTORM(BIEN,BLDNM,"R")
 Q:X 1
 Q X
 ;
 ;
 ; Use the MULB function above to find all decendents of the
 ;   present MULTIPLE BUILD entries for this parent build
 ;   and push them into the MULTIPLE BUILDS [#10] multiple
 ; ENTER
 ;   BUILD    =  Name of parent build to edit MULB  multiple
 ; EXIT
 ;   RETURN X =  0=error  1=ok
A1AEFMUB(BUILD) ; File MULTIPLE BUILDS
 Q:BUILD=""
 N X
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN
 N BMARR D MULB(BUILD,.BMARR)
 Q:'$D(BMARR)
 N BLDNM,DIERR S BLDNM=" "
 F  S BLDNM=$O(BMARR(BLDNM)) Q:BLDNM=""  D  Q:'X
 .  Q:BUILD=BLDNM
 .  S X=$$ADBTORM(BIEN,BLDNM,"M")
 Q:X 1
 Q X
 ;
 ;
 ; Add a build name to either the MULB or REQB multiple
 ; ENTER
 ;    BIEN     =  Parent BUILD 
 ;    BLDNM    =  member or prerequisite build being added
 ;    RM       =  "R" prerequisite REQB
 ;             =  "M" for member MULB
 ; RETURN
 ;    1        =  new entry added
 ;    0        =  error
ADBTORM(BIEN,BLDNM,RM) ; Add build to either REQB or MULB
 I RM'?1"R",RM'?1"M" Q 0
 I 'BIEN Q 0
 I '$D(^XPD(9.6,BIEN)) Q 0
 I BLDNM="" Q 0
 I '$O(^XPD(9.6,"B",BLDNM,0)) Q 0
 N FDA,DIERR,FDAIEN
 S:RM?1"R" FDA(3,9.611,"?+1,"_BIEN_",",.01)=BLDNM
 S:RM?1"M" FDA(3,9.63,"?+1,"_BIEN_",",.01)=BLDNM
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 Q:+FDAIEN(1) +FDAIEN(1)
 Q 0
 ;
 ; Given a routine, trace out all the patches in 11005
 ;  containing that routine
 ; Note: DHCP PATCHES file very incomplete at this time
 ; Note: How handle routines without version or package?
 ; ENTER
 ;   A1AERTNM   =  Routine Name
 ;   PTCHARR    =  Array of Patches required to build
 ;                 second line of routine
 ; RETURNS
 ;   PTCHARR   = example below.  129215=ien found 11005
 ;             POO("DG*5.3*673")=""
 ;             POO("DG*5.3*688")=""
 ;             POO("DG*5.3*797")=129215
 ;             POO("DG*5.3*842")=129243
 ; VARIABLES
 ;   A1AE005    =  IEN of patch in file 11005
 ;   A1AE2LN    =  Second line of the routine
 ;   A1AEPLST   =  List of patches from routine second line
 ;   A1AESBB    =  Package abbreviation
 ;   A1AESIEN   =  Package IEN in file 9.4
 ;   A1AESNM    =  Package name from second line
 ;   A1AEVR     =  Version from second line
 ;   A1AEPNM    =  Patch Name built from routine second line
 ;
PTC4RTN(A1AERTNM,PTCHARR) ; Find all patches touching Routine
 K PTCHARR Q:A1AERTNM=""
 ; Get 2nd line of routine
 N A1AE2LN S A1AE2LN=$T(+2^@A1AERTNM)
 Q:A1AE2LN=""  ; No second line, bail out.
 ; Write 2nd line of routine
 ;W !,A1AE2LN,!
 ; Get version of routine's package.  Remember .0 issue
 N A1AEVR S A1AEVR=$P(A1AE2LN,";",3) ; get version
 I A1AEVR?.NP1"0" S A1AEVR=$P(A1AEVR,".")
 ; Get routine's package abbreviation
 N A1AESNM S A1AESNM=$$UP($P(A1AE2LN,";",4)) ; get package name
 Q:A1AESNM=""
 N A1AESIEN S A1AESIEN=$O(^DIC(9.4,"B",A1AESNM,0))
 Q:A1AESIEN=""
 N A1AESABB S A1AESABB=$$GET1^DIQ(9.4,A1AESIEN_",",1)
 Q:A1AESABB=""
 ; Get listing of patches from routines second line
 ; Assumption is routine list follows double **
 ;  and each patch number delimited by ","
 N A1AEPLST S A1AEPLST=$P(A1AE2LN,"**",2)
 N CNT,A1AEPNM
 ; Look for patches required to build second line
 ; Save necessary patches in array with IEN of patch
 ;   in file 11005 if found
 N A1AE005 ; *** ADDED 10/3/2014
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 F CNT=1:1:$L(A1AEPLST,",") D
 . S A1AEPNM=A1AESABB_"*"_A1AEVR_"*"_$P(A1AEPLST,",",CNT)
 . S PTCHARR(A1AEPNM)=""
 .; Added ^ in below. was $O(A1AE(11005...
 . S A1AE005=$O(^A1AE(A1AEFILE,"B",A1AEPNM,0)) ; JLI 150525 replaced 11005 with A1AEFILE
 .; I A1AE005 W "  DHCP PATCH ENTRY:",A1AE005
 . S PTCHARR(A1AEPNM)=A1AE005
 Q
 ;
 ; Given a patch
 ;   Find every routine in this patch
 ;   Find all patches for 2nd line of each routine as
 ;     occurs on the system.  
 ;   Return all patches needed to build every routine
 ;     in the original patch
 ;   As the necessary patches may not be in 11005
 ;     keep an array of all patch names necessary and
 ;     the IEN into the DHCP PATCHES [#11005] if found
 ; NOTE: Remember the routine second line listed in the
 ;   patch in may not represent the second line of the
 ;   routine as now active in the system, so use 2nd line
 ;   of the active routine
 ; Logic
 ;  Identify every routine in a patch 
 ;     ^A1AE(11005,PATCH IEN,"P",SS,0)=ROUTINE^CHKSM^**123,231**
 ;   With each routine idenfity every patch with that routine
 ;       ^A1AE(11005,"R",RTN,11005IEN,SS WITHIN PATCH)
 ;       Run the above
 ;    Get the second line from the active routine
 ;       Run the above
 ; ENTER
 ;    A1AEPIEN   =  IEN in 11005 of patch under scrutiny
 ;    PTCHARR    =  Array passed by reference
 ; RETURN
 ;    PTCHARR    =  Array of all patches needed to build
 ;                  every routine in the patch under
 ;                  scrutiny
PTCRTNS(A1AEPIEN,PTCHARR) ; Return array of all patches to build Routine
 K PTCHARR
 Q:'$G(A1AEPIEN)
 ; 1. Get routines in the patch
 ; 2. Get array of patches for each routine using PTC4RTN
 ;    necessary as can't trust DHCP PATCHES to have
 ;    the necessary patches.  PTC4RTN builds an array
 ;    of all patches necessary for the second line of
 ;    the routine REGARDLESS of the patches existence
 ;    in 11005
 ;
 ; 1. Build array of routines in the patch
 ;    Double array   ARR(RTN,"ACTIVE")=LINE2 RTN IN SYSTEM
 ;                   ARR(RTN,P,IEN,SS)=PATCH ENTRY DISP LINE2
 N A1AER,A1AERR,A1AERRS,A1AERSS S A1AERSS=0
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 F  S A1AERSS=$O(^A1AE(A1AEFILE,A1AEPIEN,"P",A1AERSS)) Q:'A1AERSS  D  ; JLI 150525 changed 11005 to A1AEFILE
 .  S A1AER=^A1AE(A1AEFILE,A1AEPIEN,"P",A1AERSS,0) ; JLI 150525 changed 11005 to A1AEFILE
 .  S A1AERTNM=$P(A1AER,"^"),A1AEPLST=$P(A1AER,"^",3)
 .  S PTCHARR(A1AERTNM,"P",A1AEPIEN,A1AERSS)=A1AEPLST
 .  S PTCHARR(A1AERTNM,"ACTIVE")=$T(+2^@A1AERTNM)
 ;
 ; 2. Get array of patches for each routine active in system
 ;
 N CNT,RTN,TMPARR,RTNARR
 S CNT=0,RTN=""
P2 F  S RTN=$O(PTCHARR(RTN)) Q:RTN=""  D
 .  D PTC4RTN^A1AEF1(RTN,.TMPARR) M RTNARR(RTN)=TMPARR
 K PTCHARR M PTCHARR=RTNARR
 Q
 ;
 ;
 ; Required patch list name in KIDS considering patch stream of
 ;   developer's site
 ; Logic
 ;   1. Enter with BMARR array of all BUILDS under
 ;      consideration
 ;   2. Get Patch Stream for this developer from 11007.1
 ;   3. Look up each build in DHCP PATCHES 11005 file
 ;   4. If found, remove array node if Stream wrong
 ;   5. Return list of BUILDS matching developer's Stream
 ; Example
 ;   SD*5.3*70 would have had 5 entries in REQUIRED BUILDS
 ;      and returned a BARR array with 9 as a few more
 ;      were found with the REQB function
 ;      All are VISTA BUILDS.  Unfortunately none are
 ;       in 11005
 ;   However, I added SD*5.3*10504 as an additional REQB
 ;      Now when I run REQB^A1AEF1
 ;      I am returned 213 nodes in array as 10504 is
 ;      an OSEHRA build based on SD*5.3*504.  All,except
 ;      one of these SD*5.3*10504 is missing in 11005.
 ;      However, with this logic, they would have been
 ;      deleted anyway as they would be listed as VISTA
 ;      stream (PRIMARY set to 1 for FOIA VISTA
 ;   So, now to test the splitting off of REQUIRED BUILDS
 ;      (and the associated patches in 11005), I will
 ;      remove all BUILD nodes in the original array that do
 ;      not have corresponding OSEHRA patches in 11005
 ;
 ; ENTER
 ;    BUILD   =  Parent build
 ;    BARR    =  Array of builds under consideration
 ;    MR      =  Indicator for whether the array of builds
 ;               represents
 ;                 "R" builds from the parents REQB multiple
 ;                 "M" builds from the parents MULB multiple
 ;                 "" unknown
 ; EXIT
 ;    BARR    =  Array of builds belonging to user's site's
 ;               patch stream.  
 ;               MR = "" all builds filtered for stream
 ;               MR = "R" filtered list minus REQB entries
 ;               MR = "M" filtered list minus MULB entries
PTC4KIDS(BUILD,BARR,MR) ; Filter build's REQB and MULB for patch stream
 ; PTSTRM will be 0,1,or 10001
 N PTSTRM S PTSTRM=$O(^A1AE(11007.1,"APRIM",1,0))
 ;W !,"PTSTRM=",PTSTRM
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN
 N PDIEN
 S NODE=$NA(BARR(" ")) F  S NODE=$Q(@NODE) Q:NODE'["BARR"  D
 . S PD=$QS(NODE,1)
 . I MR?1"R" D
 .. ; Remove BARR node if = BUILD, or already in Required Builds
 .. I (PD=BUILD) K @NODE
 .. I $D(^XPD(9.6,BIEN,"REQB","B",PD)) K @NODE
 . I MR?1"M" D
 .. ; Remove BARR node if = BUILD, or already in Multiple Builds
 .. I (PD=BUILD) K @NODE
 .. I $D(^XPD(9.6,BIEN,10,"B",PD)) K @NODE
 .; correct for builds with ".0" in version
 . I $P(PD,"*",2)?.NP1"0" D
 .. S PD=$P(PD,"*")_"*"_$P($P(PD,"*",2),".")_"*"_$P(PD,"*",3)
 .; If BUILD does not have corresponding entryDHCP PATCHES file,
 .;   then delete this node from incoming array
 . N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 . S PDIEN=$O(^A1AE(A1AEFILE,"B",PD,0)) ; JLI 150525
 .; Local change to increase returned list size
 . I 'PDIEN K @NODE Q
 . I $$GET1^DIQ(A1AEFILE,PDIEN_",",.2,"I")'=PTSTRM K @NODE ; JLI 150525
 Q
 ;
 ;
 ; Filter incoming array to include only names found
 ;  in the DHCP PATCHES file AND which are assigned
 ;  the same stream as in use at this site.
 ; May be used to filter BUILD, INSTALL, or PATCH names
 ; ENTER
 ;   BARR  =  array by reference. BUILDS, INSTALLS, or PATCHES
 ; RETURN
 ;   BARR  =  array filtered for names found in 
 ;            DHCP PATCHES [#11005] and correct patch stream
PTCSTRM(BARR) ; Filter build array to match site's patch stream
 ; PTSTRM will be 0,1,or 10001
 N PTSTRM S PTSTRM=$O(^A1AE(11007.1,"APRIM",1,0))
 S NODE=$NA(BARR(" ")) F  S NODE=$Q(@NODE) Q:NODE'["BARR"  D
 . S PD=$QS(NODE,1)
 .; correct for builds with ".0" in version
 . I $P(PD,"*",2)?.NP1"0" D
 .. S PD=$P(PD,"*")_"*"_$P($P(PD,"*",2),".")_"*"_$P(PD,"*",3)
 . N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 . S PDIEN=$O(^A1AE(A1AEFILE,"B",PD,0)) ; JLI 150525 changed 11005 to A1AEFILE
 . I 'PDIEN K @NODE Q
 .; Must match patch stream
 . I $$GET1^DIQ(A1AEFILE,PDIEN_",",.2,"I")'=PTSTRM K @NODE ; JLI 150525 changed 11005 to A1AEFILE
 Q
 ;
 ; Given a parent BUILD, and an array of other BUILD names,
 ;   Update the PAT multiple of the parent BUILD [#9.6]
 ;   and any corresponding INSTALLs [#9.7]
 ; ENTER
 ;    BUILD  =  parent build under scrutiny
 ;    BARR   =  array of BUILD NAMES passed by reference
 ; RETURN
 ;    BUILD's PAT multiple updated
UPDPAT(BUILD,BARR) ; Update PAT multiple of a build
 S KIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'KIEN
 S NODE=$NA(BARR(" ")) F  S NODE=$Q(@NODE) Q:NODE'["BARR"  D
 . S PD=$QS(NODE,1)
 .; Update BUILDS (and any corresponding INSTALL) PAT multiple
 . D UPDPAT1(PD,KIEN)
 Q
 ; Load PAT multiples
 ; Looks in DHCP PATCHES [#11005] for Patch Designation
 ;   matching the BUILD name (PD)
 ;   If found, the patch is entered in the primary BUILD
 ;             primary BUILD's PAT [#19] multiple 
 ;               and into
 ;             all corresponding INSTALLS' PAT [#19] multiple
 ; ENTER
 ;   PD    =  Patch Designation to lookup in 11005
 ;              (same name as build now under review)
 ;   KIEN  =  IEN of primary Build in which PAT is being built
 ; RETURN
 ;   BUILD (and INSTALLS) updated
 ; Variables
 ;   A1AEPI  =  IEN of Patch matching name of PD
 ;   IIEN    =  IEN of INSTALLS(s) matching KIEN entry
UPDPAT1(PD,KIEN) ; Add a patch entry to the PAT multiple of a build
 N A1AEFILE S A1AEFILE=11005 I '$D(^DIC(11005)) S A1AEFILE=11004 ; JLI 150525 
 S A1AEPI=$O(^A1AE(A1AEFILE,"B",PD,0))
 ; If no match, try dropping the ".0"
 I 'A1AEPI,$P(PD,"*",2)?.NP1"0" D
 .  N PD0 S PD0=$P(PD,"*")_"*"_$P($P(PD,"*",2),".")_"*"_$P(PD,"*",3)
 .  S A1AEPI=$O(^A1AE(A1AEFILE,"B",PD0,0)) ; JLI 150525
 Q:'A1AEPI
 ; Update BUILD and entry PAT multiple
 D UPDPAT2(KIEN,A1AEPI,9.619)
 ; Update this and all similar named INSTALL entries PAT multiple
 N IIEN S IIEN=$O(^XPD(9.7,"B",$P(^XPD(9.6,KIEN,0),"^"),0))
 I IIEN D
 . N PMI S PMI=$P(^XPD(9.7,IIEN,0),"^")
 . N INODE S INODE=$NA(^XPD(9.7,"B",PMI))
 . F  S INODE=$Q(@INODE) Q:$QS(INODE,3)'[PMI  D
 .. S IIEN=$QS(INODE,4) D UPDPAT2(IIEN,A1AEPI,9.719)
 Q
 ; Update PAT multiple in BUILD/INSTALL entry
 ; ENTER
 ;     A1AEKI  =  IEN of BUILD [#9.6] or INSTALL [#9.7]
 ;     A1AEPI  =  IEN of PATCH into 11005
 ;     KFILE   =  file to update
 ;                9.619 for BUILDs, 9.719 for INSTALLs
 ; RETURN
 ;     BUILD / INSTALL entry PAT multiple updated
UPDPAT2(A1AEKI,A1AEPI,KFILE) ; Update a single PAT entry in a build
 ;W !,"A1AEKI=",A1AEKI," A1AEPI=",A1AEPI," KFILE=",KFILE
 N FDA,DIERR
 S FDA(3,KFILE,"?+1,"_A1AEKI_",",.01)=A1AEPI
 N NODE S NODE=$NA(FDA),NODE=$Q(@NODE) ;W !,NODE,"=",@NODE
 D UPDATE^DIE("","FDA(3)","")
 Q
 ;
 ; ENTER
 ;    STR   =  String to set to upper case
 ; RETURN
 ;    STR   =  all uppercase
UP(STR) ; Return string as all uppercase
 Q $TR(STR,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 ;
 ;
 ; Remove old versions
 ; ENTER
 ;     BARR  =  array of BUILD names passed by reference
 ; RETURN
 ;     BARR  =  array with BUILDS after removing those
 ;              not representing current package versions.
REMOB(BARR) ; Remove non-current pkg builds from array
 Q:'$D(BARR)
 N TMP
 S NODE=$NA(BARR(" "))
 F  S NODE=$Q(@NODE) Q:NODE'["BARR("  D
 . I $$BACTV($QS(NODE,1)) S TMP($QS(NODE,1))=""
 K BARR M BARR=TMP
 Q
 ; Check BUILD for its association with a current
 ;   package version
 ; Note PACKAGE [#9.4] and BUILD [#9.6] maintain the
 ;  decimal node of a version even when 0
 ; ENTER
 ;  BUILD   =  NAME of BUILD
 ; RETURN
 ;  1 for active version, 0 for older version member
BACTV(BUILD) ; Check build represents current package version
 Q:BUILD="" 0
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0))
 ;N PKGIEN S PKGIEN=$$GET1^DIQ(9.6,BIEN_",",1,"I") Q:'PKGIEN 0
 N PKGIEN
 I BIEN S PKGIEN=$$GET1^DIQ(9.6,BIEN_",",1,"I")
 E  S PKGIEN=$O(^DIC(9.4,"C",$P(BUILD,"*"),0))
 Q:'PKGIEN 0
 N ACTVER S ACTVER=$$GET1^DIQ(9.4,PKGIEN_",",13)
 ; Regular case where build has x*y*z structure
 I $L(BUILD,"*")=3,+$P(BUILD,"*",2)=+ACTVER Q 1
 ; Case where build has "X Y Z 1.0" style
 I +$P(BUILD," ",$L(BUILD," "))=+ACTVER Q 1
 Q 0
 ;
 ;
EOR ; end of routine A1AEF1
