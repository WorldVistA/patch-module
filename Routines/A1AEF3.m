A1AEF3 ;VEN/LGC - FIND ALL PREREQUISTE/MEMBER BUILDS ; 10/15/14 3:45pm
 ;;2.4;PATCH MODULE;;SEP 11, 2014
 ;
 ; Option for developer to 
 ;  1. Use recursive search to identify any additional
 ;     member [MULB] or prerequisite [REQB] builds dependent
 ;     in the array of each already existing in parent
 ;     build in request
 ;  2. Remove any builds not belonging to active version of
 ;     corresponding package
 ;  3. Reduce array of builds to those that install components
 ;     not replaced by subsequent build installs
 ;  4. Replace nodes needed to display inheritance
 ;  5. Ask if user wishes to see display of builds identified
 ;  6. Ask if user wishes to add to the parent build
 ;     a. all the builds identified in steps 1-2 above
 ;     b. just the minimal set identified
 ;     c. none of those extra builds identified
 ;  7. Update the PAT multiple of the parent build
 ;ENTER:
 ;   BUILD   =  Name of parent build in question
 ;EXIT
 ;   BARR    =  Array of REQUIRED BUILDS to add to the
 ;               parent after developer filtered those
 ;               found by PTC4KIDS above
 ;
SELBLDS(BUILD) ;
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) I 'BIEN D  Q
 . W !,"Build:"_BUILD_" Not found in BUILD [#9.6] file."
 . W $C(7)
 W !,"Parent BUILD under scrutiny : ",BUILD
 ;
 ;
 ; --- MULTIPLE BUILDS
 ; Check to see if parent build has members --- MULTIPLE BUILDS"
 ;
 N MB,OARR
 D MULB^A1AEF1(BUILD,.MB)
 ; Save original array from MULB call so we are able
 ;  to add back lineage later
 M OARR=MB
 ;
 I $G(MB(0))<2 D
 . W !,!,BUILD," has no members listed in MULB multiple."
 E  D
 . W !,!,BUILD," has ",$G(MB(0))," members listed in MULB multiple."
 . D REMOB^A1AEF1(.MB)
 . N MINSET D MINSET^A1AEF2(.MB)
 . D LOADINH(.MB,.OARR) ; Replace inheritance indicators
 . N Y D DISPL I Y=1 D
 ..  D DSPNODES(.MB)
 . D KEEP("M") I Y>1 D
 .. D UPDBLD(BUILD,.OARR,.MB,"M",Y)
 . D UPPAT(BUILD)
 ;
 ;Fall into PREREQUISITE [REQB] 
 ; ---- REQUIRED BUILDS
 W !,!
 ; Check is this is parent with prerequisites [REQB]
 K OARR
 N REQB,OARR
 D REQB^A1AEF1(BUILD,.REQB)
 M OARR=REQB
 I $G(REQB(0))>1 D
 . W !,!,"Parent BUILD has ",$G(REQB(0))," prerequisites."
 . D REMOB^A1AEF1(.REQB)
 . N MINSET D MINSET^A1AEF2(.REQB)
 . D LOADINH(.REQB,.OARR) ; Replace inheritance indicators
 . N Y D DISPL I Y=1 D
 ..  D DSPNODES(.REQB)
 . D KEEP("R") I Y>1 D
 .. D UPDBLD(BUILD,.OARR,.REQB,"R",Y)
 . D UPPAT(BUILD)
 Q
 ;
 ;
 ; Ask developer if they wish to display the array
 ; Returns X,Y,DUOUT
DISPL ;
 N DIR
 S DIR(0)="SO^1:Display All;2:Do Not Disp"
 S DIR("L",1)="Select one of the following:"
 S DIR("L",2)=""
 S DIR("L",3)="1. Display Patch Relationships"
 S DIR("L",4)="   Minimum set indicated by <<<"
 S DIR("L")="2. No Display desired"
 D ^DIR
 Q
 ;
 ; Ask developer how they wish to proceed
 ; ENTER
 ;   MR  = "M" or "R"
 ; RETURN
 ;   X,Y,DUOUT
 ;
KEEP(RM) I 'RM?1"R",'RM?1"M" Q
 N DIR
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
 Q
 ;
 ;
 ; Ask developer if they wish to update the parent
 ; ENTER
 ;   BUILD     = PARENT BUILD under construction
 ;   OARR      = Array of builds before minimal set calculated
 ;   MARR      = Minimal set array of builds
 ;   RM        = "M" for member [MULB] update
 ;               "R" for prerequisite [REQB] update
 ;   Y         = instructions
 ;                Y=2  Update with all BUILDS identified
 ;                Y=3  Update with only Minimum Set
 ; RETURN
 ;   Parent build updated
UPDBLD(BUILD,OARR,MARR,RM,Y) ;
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0))
 Q:'BIEN
 N UPD S UPD=Y
 N X,Y,DUOUT,DTOUT,DIR
 S DIR(0)="Y"
 S DIR("A")="Include selected builds in "_BUILD
 S DIR("B")="N"
 D ^DIR
 Q:$D(DUOUT)  Q:$D(DTOUT)
 Q:Y'=1
 ; 
 ; Asked to update either REQB or MULB multiple
 N NODE S NODE=$S(UPD=2:$NA(OARR(" ")),UPD=3:$NA(MARR(" ")),1:"")
 Q:NODE=""
 N STOP S STOP=$P(NODE,"""")
 N BLD2ADD
 F  S NODE=$Q(@NODE) Q:NODE'[STOP  D
 . S BLD2ADD=$QS(NODE,1)
 . I RM?1"R" D
 ..  N FDA,DIERR
 ..  S FDA(3,9.611,"?+1,"_BIEN_",",.01)=BLD2ADD
 ..  D UPDATE^DIE("","FDA(3)","")
 . I RM?1"M" D
 ..  N FDA,DIERR
 ..  S FDA(3,9.63,"?+1,"_BIEN_",",.01)=BLD2ADD
 ..  D UPDATE^DIE("","FDA(3)","")
 Q
 ;
 ; Display and array with parental history indentation
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
UPPAT(BUILD) ;
 N DIR,X,Y,DTOUT,DUOUT
 S DIR(0)="Y"
 S DIR("A")="Update PATCH multiple of "_BUILD
 S DIR("B")="N"
 D ^DIR
 Q:Y'=1
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) ; do we have an IEN?
 Q:'BIEN
 N BMARR S BMARR(BUILD)=""
 D UPPAT1(BUILD,.BIEN) ; add to PAT multipe of primary entry
 ;
 ; Run through all member builds (MULB) and add those to
 ;   the PATCH multiple of the parent BUILD
 N BLDNM S BLDNM=""
 F  S BLDNM=$O(^XPD(9.6,BIEN,10,"B",BLDNM)) Q:BLDNM=""  D
 . Q:$D(BMARR(BLDNM))  ; no need to continue if already have
 . D UPPAT1(BLDNM,.BIEN) ; add all its required patches
 ;
 ; Run through all prerequisite builds (REQB) and add those to
 ;   the PATCH multiple of the parent BUILD
 N BLDNM S BLDNM=""
 F  S BLDNM=$O(^XPD(9.6,BIEN,"REQB","B",BLDNM)) Q:BLDNM=""  D
 . Q:$D(BMARR(BLDNM))  ; no need to continue if already have
 . D UPPAT1(BLDNM,.BIEN) ; add all its required patches
 Q
 ;
UPPAT1(PD,BIEN) ;
 N A1AEPI S A1AEPI=$O(^A1AE(11005,"B",PD,0))
 ; If no match, try dropping the ".0"
 I 'A1AEPI,$P(PD,"*",2)?.NP1"0" D
 .  N PD0 S PD0=$P(PD,"*")_"*"_$P($P(PD,"*",2),".")_"*"_$P(PD,"*",3)
 .  S A1AEPI=$O(^A1AE(11005,"B",PD0,0))
 Q:'A1AEPI
 ; Update BUILD and entry PAT multiple
 D UPPAT2(.BIEN,.A1AEPI)
 Q
 ; Update PAT multiple in BUILD entry
UPPAT2(BIEN,A1AEPI) ;
 N FDA,DIERR
 S FDA(3,9.619,"?+1,"_BIEN_",",.01)=A1AEPI
 N NODE S NODE=$NA(FDA),NODE=$Q(@NODE) ;W !,NODE,"=",@NODE
 D UPDATE^DIE("","FDA(3)","")
 Q
 ;
REBLD70 ;
 K ^XPD(9.6,324)
 S ^XPD(9.6,324,0)="SD*5.3*70^48^0^2961029^n^^"
 S ^XPD(9.6,324,1,0)="^9.61A^1^1^3140916^^^"
 S ^XPD(9.6,324,1,1,0)="See National Patch Module for description"
 S ^XPD(9.6,324,4,0)="^9.64PA^404.91^1"
 S ^XPD(9.6,324,4,404.91,0)=404.91
 S ^XPD(9.6,324,4,404.91,2,0)="^9.641^404.91^1"
 S ^XPD(9.6,324,4,404.91,2,404.91,0)="SCHEDULING PARAMETER  (File-top level)"
 S ^XPD(9.6,324,4,404.91,2,404.91,1,0)="^9.6411^708^3"
 S ^XPD(9.6,324,4,404.91,2,404.91,1,70.01,0)="SD70 INSTALL DATE"
 S ^XPD(9.6,324,4,404.91,2,404.91,1,70.02,0)="SD70 LAST DATE"
 S ^XPD(9.6,324,4,404.91,2,404.91,1,708,0)="AMBCARE MESSAGE LINES"
 S ^XPD(9.6,324,4,404.91,222)="y^n^p^^^^n"
 S ^XPD(9.6,324,4,"APDD",404.91,404.91)=""
 S ^XPD(9.6,324,4,"APDD",404.91,404.91,70.01)=""
 S ^XPD(9.6,324,4,"APDD",404.91,404.91,70.02)=""
 S ^XPD(9.6,324,4,"APDD",404.91,404.91,708)=""
 S ^XPD(9.6,324,4,"B",404.91,404.91)=""
 S ^XPD(9.6,324,"ABPKG")="n"
 S ^XPD(9.6,324,"INIT")="SD5370PT"
 S ^XPD(9.6,324,"KRN",0)="^9.67PA^19^18"
 S ^XPD(9.6,324,"KRN",.4,0)=.4
 S ^XPD(9.6,324,"KRN",.401,0)=.401
 S ^XPD(9.6,324,"KRN",.402,0)=.402
 S ^XPD(9.6,324,"KRN",.403,0)=.403
 S ^XPD(9.6,324,"KRN",.5,0)=.5
 S ^XPD(9.6,324,"KRN",.84,0)=.84
 S ^XPD(9.6,324,"KRN",3.6,0)=3.6
 S ^XPD(9.6,324,"KRN",3.8,0)=3.8
 S ^XPD(9.6,324,"KRN",9.2,0)=9.2
 S ^XPD(9.6,324,"KRN",9.8,0)=9.8
 S ^XPD(9.6,324,"KRN",9.8,"NM",0)="^9.68A^6^5"
 S ^XPD(9.6,324,"KRN",9.8,"NM",1,0)="SCDXMSG^^0^B28708749"
 S ^XPD(9.6,324,"KRN",9.8,"NM",2,0)="SCDXMSG1^^0^B46078591"
 S ^XPD(9.6,324,"KRN",9.8,"NM",4,0)="VAFHLPV1^^0^B17046923"
 S ^XPD(9.6,324,"KRN",9.8,"NM",5,0)="VAFHLZSP^^0^B1854738"
 S ^XPD(9.6,324,"KRN",9.8,"NM",6,0)="SCDXUTL5^^0^B9885667"
 S ^XPD(9.6,324,"KRN",9.8,"NM","B","SCDXMSG",1)=""
 S ^XPD(9.6,324,"KRN",9.8,"NM","B","SCDXMSG1",2)=""
 S ^XPD(9.6,324,"KRN",9.8,"NM","B","SCDXUTL5",6)=""
 S ^XPD(9.6,324,"KRN",9.8,"NM","B","VAFHLPV1",4)=""
 S ^XPD(9.6,324,"KRN",9.8,"NM","B","VAFHLZSP",5)=""
 S ^XPD(9.6,324,"KRN",19,0)=19
 S ^XPD(9.6,324,"KRN",19,"NM",0)="^9.68A^^"
 S ^XPD(9.6,324,"KRN",19.1,0)=19.1
 S ^XPD(9.6,324,"KRN",101,0)=101
 S ^XPD(9.6,324,"KRN",409.61,0)=409.61
 S ^XPD(9.6,324,"KRN",771,0)=771
 S ^XPD(9.6,324,"KRN",869.2,0)=869.2
 S ^XPD(9.6,324,"KRN",870,0)=870
 S ^XPD(9.6,324,"KRN",8994,0)=8994
 S ^XPD(9.6,324,"KRN","B",.4,.4)=""
 S ^XPD(9.6,324,"KRN","B",.401,.401)=""
 S ^XPD(9.6,324,"KRN","B",.402,.402)=""
 S ^XPD(9.6,324,"KRN","B",.403,.403)=""
 S ^XPD(9.6,324,"KRN","B",.5,.5)=""
 S ^XPD(9.6,324,"KRN","B",.84,.84)=""
 S ^XPD(9.6,324,"KRN","B",3.6,3.6)=""
 S ^XPD(9.6,324,"KRN","B",3.8,3.8)=""
 S ^XPD(9.6,324,"KRN","B",9.2,9.2)=""
 S ^XPD(9.6,324,"KRN","B",9.8,9.8)=""
 S ^XPD(9.6,324,"KRN","B",19,19)=""
 S ^XPD(9.6,324,"KRN","B",19.1,19.1)=""
 S ^XPD(9.6,324,"KRN","B",101,101)=""
 S ^XPD(9.6,324,"KRN","B",409.61,409.61)=""
 S ^XPD(9.6,324,"KRN","B",771,771)=""
 S ^XPD(9.6,324,"KRN","B",869.2,869.2)=""
 S ^XPD(9.6,324,"KRN","B",870,870)=""
 S ^XPD(9.6,324,"KRN","B",8994,8994)=""
 S ^XPD(9.6,324,"QUES",0)="^9.62^^"
 S ^XPD(9.6,324,"REQB",0)="^9.611^6^6"
 S ^XPD(9.6,324,"REQB",1,0)="SD*5.3*44^2"
 S ^XPD(9.6,324,"REQB",2,0)="SD*5.3*55^2"
 S ^XPD(9.6,324,"REQB",3,0)="SD*5.3*56^2"
 S ^XPD(9.6,324,"REQB",4,0)="DG*5.3*94^2"
 S ^XPD(9.6,324,"REQB",5,0)="PX*1.0*9^2"
 S ^XPD(9.6,324,"REQB",6,0)="SD*5.3*10504^0"
 S ^XPD(9.6,324,"REQB","B","DG*5.3*94",4)=""
 S ^XPD(9.6,324,"REQB","B","PX*1.0*9",5)=""
 S ^XPD(9.6,324,"REQB","B","SD*5.3*10504",6)=""
 S ^XPD(9.6,324,"REQB","B","SD*5.3*44",1)=""
 S ^XPD(9.6,324,"REQB","B","SD*5.3*55",2)=""
 S ^XPD(9.6,324,"REQB","B","SD*5.3*56",3)=""
 N DA,DIK S DA=324,DIK="^XPD(9.6,"  D IX^DIK
 Q
 ;
EOR ; end of routine A1AEF3
