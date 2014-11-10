A1AEF3 ;VEN/LGC - FIND ALL PREREQUISTE/MEMBER BUILDS ; 11/10/14 12:11am
 ;;2.4;PATCH MODULE;;SEP 11, 2014
 ;
 ; Option for developer to 
 ;  1. Use recursive search to identify any additional
 ;     member [MULB] or prerequisite [REQB] builds dependent
 ;     in the array of each already existing in parent
 ;     build in request
 ;     D MULB^A1AEF1  D REQB^A1AEF1
 ;  2. Remove any builds not belonging to active version of
 ;     corresponding package
 ;     D REMOB^A1AEF1
 ;  3. Reduce array of builds to those that install components
 ;     not replaced by subsequent build installs
 ;     D MINSET^A1AEF2
 ;  4. Replace nodes needed to display inheritance
 ;     D LOADINH
 ;  5. Ask if user wishes to see display of builds identified
 ;     $$DISPL
 ;  6. Ask if user wishes to add to the parent build
 ;     a. all the builds identified in steps 1-2 above
 ;     b. just the minimal set identified
 ;     c. none of those extra builds identified
 ;     $$KEEP
 ;  7. If developer asks to add builds, update
 ;     $$UPDBLD
 ;  8. Ask if user wishes to pull in BUILDS Derived from
 ;     the existing Pre-requisite and Member entries
 ;     in this BUILD
 ;     $$UPDDERQ
 ;  9. If derived builds requested, pull in these builds
 ;     OTHSTRM^A1AEF4
 ;  10. Ask if user wishes to update PAT multiples in BUILD
 ;     and associated INSTALLs
 ;     $$UPDPATQ
 ;  11. If instructed to do so, Update the PAT multiples
 ;     UPPAT(BUILD)
 ;
 ;ENTER:
 ;   BUILD   =  Name of parent build in question
 ;EXIT
 ;   BARR    =  Array of REQUIRED BUILDS to add to the
 ;               parent after developer filtered those
 ;               found by PTC4KIDS above
 ;
SELBLDS(BUILD) ;
 N ERR S ERR=0
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) I 'BIEN D  Q
 . W !,"Build:"_BUILD_" Not found in BUILD [#9.6] file."
 . W $C(7)
 W !,"Parent BUILD under scrutiny : ",BUILD
 ;
 ;
 ; --- MULTIPLE BUILDS
 ; Check to see if parent build has members --- MULTIPLE BUILDS"
 ;
 N MB,OARR,UPD
 D MULB^A1AEF1(BUILD,.MB)
 ; Save original array from MULB call so we are able
 ;  to add back lineage later
 M OARR=MB
 ;
 I $G(MB(0))<2 D
 . W !,!,BUILD," has no members listed in MULB multiple."
 . H 2
 E  D
 . W !,!,BUILD," has ",$G(MB(0))," members listed in MULB multiple."
 . D REMOB^A1AEF1(.MB)
 . N NODE,CNT S CNT=0,NODE=$NA(MB(" "))
 . F  S NODE=$Q(@NODE) Q:NODE'["MB("  S CNT=CNT+1
 . W !,!,"Parent BUILD has ",CNT," members after removing"
 . W !,"  Builds representing old versions of packages",!
 . N MINSET D MINSET^A1AEF2(.MB)
 . D LOADINH(.MB,.OARR) ; Replace inheritance indicators
 . D:$$DISPL DSPNODES(.MB)
 .; KEEP returns 1=ignore , 2=keep all, 3=keep minimu, 0=ignore
 . S UPD=$$KEEP("M") I UPD>1 D
 .. W !,"Adding ",$S(UPD=2:"ALL",UPD=3:"MINIMUM",1:"")," Builds.",!
 .. S ERR=$$UPDBLD(BUILD,.OARR,.MB,"M",UPD)
 ;
 ;Fall into PREREQUISITE [REQB] 
 ; ---- REQUIRED BUILDS
 W !,!
 ; Check is this is parent with prerequisites [REQB]
 K OARR
 N REQB
 D REQB^A1AEF1(BUILD,.REQB)
 M OARR=REQB
 I $G(REQB(0))<2 D
 . W !,!,BUILD," has no members listed in REQB multiple."
 . H 2
 E  D
 . W !,!,"Parent BUILD has ",$G(REQB(0))," prerequisites."
 . D REMOB^A1AEF1(.REQB)
 . N NODE,CNT S CNT=0,NODE=$NA(REQB(" "))
 . F  S NODE=$Q(@NODE) Q:NODE'["REQB("  S CNT=CNT+1
 . W !,!,"Parent BUILD has ",CNT," prerequisites after removing"
 . W !,"  Builds representing old versions of packages",!
 . N MINSET D MINSET^A1AEF2(.REQB)
 . D LOADINH(.REQB,.OARR) ; Replace inheritance indicators
 . D:$$DISPL DSPNODES(.REQB)
 .; KEEP returns 1=ignore , 2=keep all, 3=keep minimu, 0=ignore
 . S UPD=$$KEEP("R") I UPD>1 D
 .. W !,"Adding ",$S(UPD=2:"ALL",UPD=3:"MINIMUM",1:"")," Builds.",!
 .. S ERR=$$UPDBLD(BUILD,.OARR,.REQB,"R",UPD)
 ;
 ; Update REQB and MULB multiples with patches derived for
 ;  other streams
 I $$UPDDERQ D
 . W !,"Pulling in builds derived from from Pre-requisite and"
 . W !," Member multiples for other streams."
 . S X=$$OTHSTRM^A1AEF4(BUILD)
 ;
 ; Update PAT multiple with patches corresponding to entries
 ;  in the REQB and MULB multiples
 ; Updates PAT multiple of all corresponding INSTALLs as well
 I $$UPDPATQ(BUILD) D
 . W !,"Updating the PATCH multiple of "_BUILD_" and"
 . W !,"  corresponding INSTALLS.",!
 . D UPPAT(BUILD)
 Q
 ;
 ;
 ; Ask developer if they wish to display the array
 ; ENTER
 ;    nothing required
 ; RETURNS
 ;    1 = Display, 2 = DO NOT display, 0 = DO NOT display
DISPL() N DIR,X,Y,DTOUT,DUOUT
 S DIR(0)="SO^1:Display All;2:Do Not Disp"
 S DIR("L",1)="Select one of the following:"
 S DIR("L",2)=""
 S DIR("L",3)="1. Display Patch Relationships"
 S DIR("L",4)="   Minimum set indicated by <<<"
 S DIR("L")="2. No Display desired"
 D ^DIR
 Q +$G(Y)
 ;
 ; Ask developer how they wish to proceed
 ; ENTER
 ;   MR  = "M" or "R"
 ; RETURN
 ;   1 = ignore builds found, 2 = keep all, 3 = keep minimum set
 ;   0 = didn't answer
KEEP(RM) I 'RM?1"R",'RM?1"M" Q 0
 N DIR,X,Y,DTOUT,DUOUT
 S DIR(0)="SO^1:Ignore;2:Keep all identified;3:Keep only minimum set"
 S DIR("L",1)="Select one of the following:"
 S DIR("L",2)=""
 I RM?1"M" D
 . S DIR("L",3)="1. Ignore all additional member builds identified"
 . S DIR("L",4)="2. Keep all additional member builds identified"
 I RM?1"R" D
 . S DIR("L",3)="1. Ignore all additional prerequisites identified"
 . S DIR("L",4)="2. Keep all additional prerequiites identified"
 S DIR("L")="3. Keep only Minimum Set "
 D ^DIR
 Q +$G(Y)
 ;
 ;
 ; Ask whether to update the BUILDS 
 ; ENTER
 ;   BUILD = name of BUILD to potentially update
 ; RETURN
 ;   1 = update BUILDS multiple, 0 = do NOT update BUILDS multiple
UPDBLDQ(BUILD) N DIR,X,Y,DTOUT,DUOUT
 S DIR(0)="Y"
 S DIR("A")="Include selected builds in "_BUILD
 S DIR("B")="N"
 D ^DIR
 Q +$G(Y)
 ;
 ;
 ; Ask whether to bring in DERIVED BUILDS
 ; ENTER
 ;   BUILD = name of BUILD to potentially update
 ; RETURN
 ;   1 = update, 0 = do NOT update
UPDDERQ() N DIR,X,Y,DTOUT,DUOUT
 S DIR(0)="Y"
 S DIR("A")="Bring in BUILDS derived for other stream(s)"
 S DIR("B")="N"
 D ^DIR
 Q +$G(Y)
 ;
 ;
 ; Ask whether to update the PAT multiple of BUILD and INSTALLS
 ; ENTER
 ;   BUILD = name of BUILD to potentially update
 ; RETURN
 ;   1 = update PAT multiple, 0 = do NOT update PAT multiple
UPDPATQ(BUILD) N DIR,X,Y,DTOUT,DUOUT
 S DIR(0)="Y"
 S DIR("A")="Update PATCH multiple of "_BUILD_" and its INSTALLS"
 S DIR("B")="N"
 D ^DIR
 Q +$G(Y)
 ;
 ;
 ; Ask developer if they wish to update the parent
 ; ENTER
 ;   BUILD     = PARENT BUILD under construction
 ;   OARR      = Array of builds before minimal set calculated
 ;   MARR      = Minimal set array of builds
 ;   RM        = "M" for member [MULB] update
 ;               "R" for prerequisite [REQB] update
 ;   UPD       = instructions
 ;                UPD = 2  Update with all BUILDS identified
 ;                UPD = 3  Update with only Minimum Set
 ; RETURN
 ;   Parent build updated if directed to do so
 ;   0 = error OR not request update,  1 = update successful
UPDBLD(BUILD,OARR,REQB,RM,UPD) ;
 N ERR S ERR=0
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0))
 Q:'BIEN ERR
 ; 
 ; Asked to update either REQB or MULB multiple
 N NODE S NODE=$S(UPD=2:$NA(OARR(" ")),UPD=3:$NA(REQB(" ")),1:"")
 Q:NODE=""
 N STOP S STOP=$P(NODE,"""")
 N BLD2ADD
 F  S NODE=$Q(@NODE) Q:NODE'[STOP  D  Q:'ERR
 . S BLD2ADD=$QS(NODE,1)
 . S ERR=$$ADBTORM^A1AEF1(BIEN,BLD2ADD,RM)
 Q ERR
 ;
 ; Display and array with parental history indentation
 ; ENTER
 ;    DPLARR  =  Array of BUILDS with parental history
 ;               identification
 ;               e.g. 
 ; RETURN
 ;    No variables returned or modified
DSPNODES(DPLARR) ;
 N CNT
 N NODE S NODE=$NA(DPLARR(0,0))
 F  S NODE=$Q(@NODE) Q:$QS(NODE,2)=""  D
 .  W ! F CNT=1:1:@NODE W "."
 .  W $QS(NODE,2)
 .  I $D(MINSET($QS(NODE,2))) W " <<<"
 Q
 ;
 ; Load inheritance nodes generated at the REQB or MULB 
 ;   call in A1AEF1 before minimal set and patch stream
 ;   subroutines pulled out unnecessary nodes
 ; NOTE: the OARR array needed to be saved immediately
 ;   following the REQB or MULB call
 ; ENTER
 ;   OARR    =  Original array from REQB or MULB in A1AEF1
 ;   RARR    =  Reduced minimal set array
 ; RETURN
 ;   OARR    =  RARR with new RARR(n,PD)=numeric inheritance
 ; e.g. ENTER
 ;   ENTER
 ;      RARR("DG*5.3*147")=""
 ;      OARR("DG*5.3*147")=1863 and OARR(133,"DG*5.3*147")=14
 ;   RETURN
 ;      RARR("DG*5.3*147")="" and RARR(133,"DG*5.3*147")=14
LOADINH(RARR,OARR) ;
 N NODE S NODE=$NA(OARR(0,0))
 F  S NODE=$Q(@NODE) Q:NODE'["OARR("  Q:'$QS(NODE,1)  D
 .  I $D(RARR($QS(NODE,2))) D
 ..  S RARR($QS(NODE,1),$QS(NODE,2))=@NODE
 Q
 ;
 ; Update PAT multiple. Must be done AFTER the steps
 ;  above adding new member and new prerequisite builds
 ;  as the entries in the REQB and MULB multiple of the
 ;  indicated BUILD will be used to find all corresponding
 ;  patches in the DHCP PATCHES [#11005] file and add
 ;  to the PAT multiple of the BUILD as well as to
 ;  the PAT multiple of all corresponsing INSTALLS
 ;  NOTE: This build may have been installed more than
 ;        once on this system
 ; ENTER
 ;    BUILD = Name of build to update
 ; RETURN
 ;    PAT multiple of BUILD, and INSTALLS
 ;        filled with all PATCHES [#11005] associated
 ;        with each entry in the REQB (prerequisite) and
 ;        MULB (member) multiple
UPPAT(BUILD) N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) ; do we have an IEN?
 Q:'BIEN
 D UPDPAT1^A1AEF1(BUILD,.BIEN) ; add to PAT multipe of primary entry
 ;
 ; Run through all member builds (MULB) and add those to
 ;   the PATCH multiple of the parent BUILD
 N PD S PD=""
 F  S PD=$O(^XPD(9.6,BIEN,10,"B",PD)) Q:PD=""  D
 . D UPDPAT1^A1AEF1(PD,.BIEN)
 ;
 ; Run through all prerequisite builds (REQB) and add those to
 ;   the PATCH multiple of the parent BUILD
 S PD=""
 F  S PD=$O(^XPD(9.6,BIEN,"REQB","B",PD)) Q:PD=""  D
 . D UPDPAT1^A1AEF1(PD,.BIEN)
 Q
 ;
 ;
EOR ; end of routine A1AEF3
