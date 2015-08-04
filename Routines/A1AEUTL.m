A1AEUTL ;ven/toad-patch tools ;2015-08-04  5:32 PM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ; (c) VISTA Expertise Network
 ;
 ; ***** COMMENTS IN A1AEUTLC ****
 ;
SEQ ; get & set sequence #
 ; called by:
 ;   C^A1AEPHS
 ;   S2R2^A1AEPHS
 ; input:
 ;   DA  =  IEN into DHCP PATCHES [#11005] file
 ;
 ; stream logic here, second trail
 ; sequence number is sensitive to patch stream
 ;
 N A1AESTRM S A1AESTRM=$$GSTRMP(DA)
 ; If the lookup fails fall back on looking at field primary? field in
 ; file dhcp patch stream (11007.1)
 S:'$G(A1AESTRM) A1AESTRM=$$PRIMSTRM()
 L +^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,"PR"):60
 ; 1st seq # is stream number - 1, under stream
 ; use old stream sequence number if no previous
 S SEQ=$G(^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,"PR"))
 I +SEQ=0 D
 . N ISEQ
 . ; get old value for VA FOIA:
 . S ISEQ=$G(^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PR"))
 . ; and if greater than new style set new style to it:
 . I ISEQ>$G(^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,1,"PR")) D
 . . S ^("PR")=ISEQ
 . . Q
 . ; set for va foia as original stream:
 . S ISEQ=$G(^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,1,"PR"))
 . ; set sequence number 1 above the current sequence number
 . ; and finish splitting the stream for the package:
 . I A1AESTRM'=1 D
 . . S PATCHID=$P(^A1AE(11005,DA,0),U)
 . . S PATCHID=$P(PATCHID,"*",1,2)_"*"_A1AESTRM
 . . S DAIEN=$O(^A1AE(11005,"B",PATCHID,"")) I DAIEN'>0 D
 . . . ; create info-only patch for stream:
 . . . D SETPACKG^A1AESPLT(A1AEPKIF,A1AEVR,A1AESTRM)
 . . . S DAIEN=$O(^A1AE(11005,"B",PATCHID,""))
 . . . Q
 . . S SEQ=ISEQ+1 D RELSSTRM^A1AESPLT(DAIEN,A1AEPKIF,A1AEVR,SEQ)
 . . S ^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,"PR")=SEQ
 . . Q
 . Q
 S SEQ=SEQ+1,^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,"PR")=SEQ
 ;
 I A1AENEW="v" D
 . S $P(^A1AE(11005,DA,0),"^",6)=SEQ
 ;
 L -^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,"PR")
 ;
 QUIT  ; end of SEQ
 ;
 ;
DELSEQ ; delete sequence #
 ; called by:
 ;   C^A1AEPHS
 ;   S2R2^A1AEPHS
 ;   RELSSTRM^A1AESPLT
 ;   (if mail message generate fails)
 ; input:
 ;   DA  =  IEN into DHCP PATCHES [#11005] file
 ; output:
 ;   rolls back SEQUENCE NUMBER field in 11007
 ;
 ; sequence # uses correct patch stream
 ;
 ; DA into 11005 should be available
 N A1AESTRM S A1AESTRM=$$GSTRMP($G(DA))
 I 'A1AESTRM D
 . S A1AESTRM=$$PRIMSTRM()
 . Q
 L +^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,"PR"):60
 I $D(^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,"PR")),^("PR") D
 . S ^("PR")=^("PR")-1
 . Q
 L -^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,"PR")
 ;
 QUIT  ; end of DELSEQ
 ;
 ;
IN ; input transform for field .01 in file 11005
 ; called from the input transform file 11005, field .01
 N X1,X2
 S X1=$P(X,"*",1)
 I X1']""!'($P(X,"*",2)=+$P(X,"*",2)) D  Q
 . K X
 . Q
 S X2=$O(^DIC(9.4,"C",X1,0))
 I 'X2 D  Q
 . W !?3,"'",X1,"' is not a valid namespace"
 . K X
 . Q
 ;
 ; if this is not a forum site we do not need the rest of
 ; this input transform
 ;
 N PRIM S PRIM=+$O(^A1AE(11007.1,"APRIM",1,0))
 N FMAIL S FMAIL=$$GET1^DIQ(4.3,"1,",.01)
 Q:FMAIL=""
 Q:'$D(^A1AE(11007.1,"AFORUM",FMAIL,PRIM))
 ;
 I '$D(^A1AE(11007,"B",X2)) D  Q
 . W !?3,"'",X1
 . W "' is not a package in the 'DHCP Patch/Problem' file"
 . K X
 . Q
 I '$D(A1AETY) D  Q
 . W !?3,"Please use the Edit Template."
 . K X
 . Q
 I A1AETY="PH",'$D(^A1AE(11007,X2,"V",+$P(X,"*",2),0)) D  Q
 . W !?3,"'",$P(X,"*",2)
 . W "' is not a valid version number for this package"
 . K X
 . Q
 I A1AETY="PK",$D(^A1AE(11007,X2,"V",+$P(X,"*",2))) D  Q
 . W !,?3,"'",$P(X,"*",2)
 . W "' is not a new package version."
 . K X
 . Q
 ; check for A1AE IMPORT besides the user
 N A1AEIMP S A1AEIMP=$D(^XUSEC("A1AE IMPORT",DUZ))
 I '$D(^A1AE(11007,X2,$S(A1AEX=11005:"PH",1:"PB"),DUZ,0)),'A1AEIMP D  Q
 . W !?3,"You are not an authorized user"
 . K X
 . Q
 I $D(^A1AE(A1AEX,"B",X)) D  Q
 . W !?3,"Another error designation with the '"
 . W X,"' specification already exists"
 . K X
 . Q
 ;
 QUIT  ;  end of IN-FORUM
 ;
 ;
PKG ; select a patch/problem package
 ; called throughout patch module
 ;
 K A1AEPKIF,A1AEPK
 S DIC("A")="Select PACKAGE: "
 S DIC="^A1AE(11007,"
 S DIC(0)=$S($D(A1AE(0)):A1AE(0),1:"AEMQZ")
 W !
 D ^DIC
 K DIC,A1AE(0)
 Q:Y<0
 S A1AEPKIF=+Y
 I $D(^DIC(9.4,A1AEPKIF,0)) D
 . S A1AEPKNM=$P(^(0),"^",1)
 . S A1AEPK=$P(^(0),"^",2)
 . Q
 ;
 QUIT  ; end of PKG
 ;
 ;
VER ; select an application version
 ; called throughout patch module
 ;
 F A1AEVR=0:0 D  Q:'A1AEVR
 . S A1AEVR=$O(^A1AE(11007,A1AEPKIF,"V",A1AEVR))
 . Q:'A1AEVR
 . Q:A1AEVR=999
 . S DIC("B")=A1AEVR
 I '$D(^A1AE(11007,A1AEPKIF,"V",0)) D
 . S ^(0)="^11007.01I^^"
 . Q
 K A1AEVR
 S DA=A1AEPKIF
 S DIC="^A1AE(11007,A1AEPKIF,""V"","
 S DIC(0)=$S($D(A1AE(0)):A1AE(0),1:"AEQ")
 D ^DIC
 S:Y>0 A1AEVR=+Y
 K DIC,A1AE(0)
 ;
 QUIT  ; end of VER
 ;
 ;
NUM ; SEE Comments
 ; get primary stream & lock:
 N A1AESTRM S A1AESTRM=$$PRIMSTRM ; get primary stream
 L +^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY):3 E  D  Q  ; lock
 . W $C(7),!!,"Someone else is adding a patch at the moment."
 . W !,"Please try again later."
 . Q
 ;
 D NUMINIT(A1AEPKIF,A1AEVR,A1AESTRM,"PB","A1AEPB") ; init next problem #
 D NUMINIT(A1AEPKIF,A1AEVR,A1AESTRM,"PH","A1AEPH") ; init next patch #
 ;
 ; get number & unlock:
 S $P(^A1AE(11007,A1AEPKIF,"V",0),U,3)=A1AEVR
 S A1AENB=^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,A1AETY)
 L -^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY) ; unlock
 ;
 D SETNUM ; get & set last # and create stub record
 ;
 QUIT  ; end of NUM
 ;
 ;
NUMINIT(A1AEPKIF,A1AEVR,A1AESTRM,A1AETY,A1AEVAR) ; See comments
 ; 1. ensure next # defined for application version
 ;
 ; if next patch/problem # is not yet defined for this app version
 I '$D(^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY)) D
 . ; then initialize next patch/problem number by primary stream
 . S ^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY)=A1AESTRM
 . Q
 ;
 ; 2. ensure next # defined for foia vista patch stream
 ;
 ; if next # for this app version for foia vista is not defined
 I '$D(^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,1,A1AETY)) D
 . ; we initialize next # for foia vista (next # = 1)
 . S ^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,1,A1AETY)=1
 . Q
 ;
 ; 3. ensure next # defined for current patch stream
 ;
 ; if next # for this app version for current stream isn't defined
 I '$D(^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,A1AETY)) D
 . ; if this is a patch, then we must be splitting the app-version's
 . ; stream for the first time, so we need to:
 . I A1AETY="PH" D  ; create the info-only patch for split stream:
 . . D SETPACKG^A1AESPLT(A1AEPKIF,A1AEVR,A1AESTRM)
 . . Q
 . ; we initialize next # based for the current stream (e.g., 10001)
 . S ^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,A1AETY)=A1AESTRM
 . Q
 ;
 ; 4. get next # based on current patch stream
 ;
 ; e.g., set A1AEPH based on PH node for current stream
 S @A1AEVAR=^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,A1AETY)
 ;
 ; 5. ensure next # is within range for current stream
 ;
 ; if next # is outside the range for current stream
 ; I (A1AEPH<A1AESTRM)!(A1AEPH>(A1AESTRM+999)) D  ; JLI 150607 commented out A1AEPH undefined
 I (@A1AEVAR<A1AESTRM)!(@A1AEVAR>(A1AESTRM+999)) D  ; JLI 150607 replaces previous line
 . ; reset current stream's next # to start of range
 . S ^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,A1AESTRM,A1AETY)=A1AESTRM
 . ; and get next # based on that
 . S @A1AEVAR=A1AESTRM
 . Q
 ;
 QUIT  ; end of NUMINIT
 ;
 ;
 ; The logic under NUM always assigns the original form of PH and PB
 ; values to the stream number, with the ones that now are broken out
 ; under the streams, the code checked for whether the ones under VA
 ; FOIA existed or not, and if not set them to that value.  Well for a
 ; new version, which doesn't have a VA FOIA equivalent, this ended up
 ; setting the VA FOIA to the stream value for the other stream...
 ; So, yes, it needs to be changed.
 ;
 ;
SETNUM ; get & set last number & create stub record
 ;private;procedure
 ; called by:
 ;   SETNUM
 ;   ADDPATCH^A1AEK2M0: importing patches
 ; input:
 ;   A1AEPK = application prefix
 ;   A1AEVR = version #
 ;   A1AENB = patch/problem #
 ;   A1AEFL = file to update (11005)
 ; output:
 ;   DA = new patch/problem record #
 ;   A1AEPD = new patch's ID
 ; sets last # using new ab index
 ;
 ; a. retrieve primary patch stream, if missing
 ;
 ; if called from ADDPATCH^A1AEK2M0, init primary stream
 I '$D(A1AESTRM) N A1AESTRM D
 . S A1AESTRM=$$PRIMSTRM
 . Q
 ;
 ; b. set patch/problem id for new patch/problem
 ;
 ; patch laygo lookup value, e.g., ZZZ*2*next #
 N X S X=A1AEPK_"*"_A1AEVR_"*"_A1AENB ; set draft patch/problem id
 ; for passing into SETNUM1, as input to its ^DIC call
 ;
 ; if version has patches/problems
 I $D(^A1AE(A1AEFL,"AB",A1AEPK,A1AEVR)) D
 . ; get last patch/problem in stream (greatest number)
 . N XEND S XEND=$O(^A1AE(A1AEFL,"AB",A1AEPK,A1AEVR,A1AESTRM+990),-1)
 . ; nb use above of 990 instead of 999; that's to leave room for
 . ; utility patches, like XU*8*991, which are not actually part of the
 . ; main VA FOIA patch stream and should not be involved in the
 . ; last-patch calculation.
 . I XEND<A1AENB ; if our number is >= greatest, ok
 . E  D  ; else our patch is one greater than greatest
 . . S A1AENB=XEND+1 ; move next #
 . . S $P(X,"*",3)=A1AENB ; and update laygo lookup value
 . . Q
 ;
 ; c. create stub record
 ;
 N Y ; unneeded output from SETNUM1's ^DIC call
 D SETNUM1 ; create patch/problem stub record with new #
 ;
 ; d. update version & stream's next #
 ;
 I Y>0 D  ; if laygo lookup worked, update the last used
 . ; try lock for 1 sec, otherwise, quit. acuracy not that important
 . L +^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY):1 E  Q
 . S ^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY)=A1AENB+1 ; set next #
 . ; and set it at the stream level as well:
 . S ^A1AE(11007,A1AEPKIF,"V",A1AEVR,1,$$PRIMSTRM,A1AETY)=A1AENB+1
 . L -^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY) ; unlock
 ;
 QUIT  ; end of SETNUM
 ;
 ;
SETNUM1 ; create patch/problem stub record
 ;private;procedure;not especially clean;silent;sac-compliant
 ; called by:
 ;   SETNUM
 ;   ADDPATCH^A1AEK2M0: importing patches
 ; input:
 ;   A1AEFL = file to update (11005)
 ;   A1AENB = new patch # to assign
 ;   A1AEPKIF = new patch's package namespace
 ;   A1AEVR = new patch's version #
 ;   X = new patch's ID
 ; output:
 ;   DA = new patch's record #
 ;   A1AEPD = new patch's ID
 ;   Y = new patch's record #
 ;
 S DIC="^A1AE(A1AEFL," ; either patch (11005) or problem (11006) file
 S DIC(0)=$G(DIC(0),"LE") ; laygo, echo, unless already defined
 D ^DIC ; do laygo lookup
 Q:Y<0
 S DA=+Y
 S A1AEPD=$P(Y,U,2) ; patch/problem id
 S $P(^A1AE(A1AEFL,DA,0),U,2,4)=A1AEPKIF_U_A1AEVR_U_A1AENB ; stub record
 S ^A1AE(A1AEFL,"D",A1AEPKIF,DA)="" ; ensure D index entry is made
 ;
 QUIT  ; end of SETNUM1
 ;
 ;
PRT ; print field record printed by
 ; Called by last line of print template A1AE STANDARD PRINT
 ;
 L +^A1AE(11005,D0,2):60
 ;
 I '$D(^A1AE(11005,D0,2,0)) D
 . S ^(0)="^11005.02P^^"
 . Q
 I '$D(^A1AE(11005,D0,2,DUZ,0)) D
 . S $P(^(0),U,1,2)=DUZ_"^"_DT
 . S $P(^(0),U,4)=$P(^A1AE(11005,D0,2,0),U,4)+1
 . Q
 S $P(^A1AE(11005,D0,2,DUZ,0),U,3)=DT
 S $P(^A1AE(11005,D0,2,0),U,3)=DUZ
 S ^A1AE(11005,"AU",DUZ,+$P(^A1AE(11005,D0,0),U,2),(9999999-DT))=""
 ;
 L -^A1AE(11005,D0,2)
 ;
 QUIT  ; end of PRT
 ;
EASCREEN(PATHDR) ; screen patch selection for option A1AE POST VERIFY
 ; called by DIC("S") by ^DIC from ENVER
 ; input:
 ;   PATHDR = header (0) node of patch record in file 11005
 ; output = true (1) if patch may be selected, else false (0)
 ;
 N ALLOW S ALLOW=0 ; default to not allowing selection
 D
 . Q:$P(PATHDR,U,8)'="v"  ; field patch status (8) must be verified
 . Q:$P(PATHDR,U,14)'=.5  ; field user verify (14) must be postmaster
 . Q:$P(PATHDR,U,9)=DUZ  ; field user entering (9) can't be current user
 . Q:$P(PATHDR,U,13)=DUZ  ; field user completion (13) can't be current
 . ; get hdr node of record for current user in subfile support
 . ; personnel (100/11007.02) in file dhcp patch/problem package (11007)
 . N USER S USER=$G(^A1AE(11007,+$P(PATHDR,U,2),"PB",DUZ,0))
 . Q:USER=""  ; current user must be listed as support personnel
 . ; current user's field verify personnel (2) must indicate current
 . Q:$P(USER,U,2)'="V"  ; user is a verifier for this application
 . S ALLOW=1 ; if patch passes all those tests, we can select it
 ;
 QUIT ALLOW
 ;
NEWVER(PKIEN,PCHIEN) ; set up a new version for application
 ; called when a new version of an application is released
 ; called by:
 ;   C^A1AEPHS
 ;   S2R2^A1AEPHS
 ;
 ;^A1AE(11007,A1AEPKIF,"V",A1AEVR)
 N X S X=$G(^A1AE(11005,PCHIEN,0))
 N NAME S NAME=$P($G(^A1AE(11005,PCHIEN,4)),U)
 Q:'$L(NAME)  ; not an application-version release
 N PV S PV=+$P(NAME," ",$L(NAME," "))
 N IEN S IEN="+1,"_PKIEN_","
 S IEN(1)=PV
 N FDA S FDA(11007.01,IEN,.01)=PV
 S FDA(11007.01,IEN,2)=$$DT^XLFDT
 K IEN
 N Y
 D UPDATE^DIE("","FDA","IEN")
 ;
 QUIT
 ;
 ;
PRIMSTRM() ; See comments
 ; if no records, add FOIA VISTA
 I '$D(^A1AE(11007.1,1,0)) D
 . S ^(0)="FOIA VISTA^0^^^FV^1^FORUM.VA.GOV" ; set Name, Primary?, & Abbreviation
 . N DA S DA=1
 . N DIK S DIK="^A1AE(11007.1,"
 . D IX1^DIK ; cross-reference
 . Q
 ;
 ; get primary stream number using APRIM index
 N PSN S PSN=$O(^A1AE(11007.1,"APRIM",1,"")) ; primary stream #
 ; if not found, site is unconfigured
 I 'PSN S PSN=10**6+1 ; default to 1,000,001
 ;
 QUIT PSN
 ;
 ;
ID11005 ; See comments
 N IEN S IEN=Y ; Internal entry number is in Y
 N ID S ID="" ; initialize identifier
 I '$G(DIQUIET),$X<33 W ?32 ; align subject column
 N X S X=$X ; current X position
 N IDLEN S IDLEN=80-X ; maximum room for identifier
 N DELIM S DELIM=" " ; write ID component delimiter, default to space
 I $G(DIQUIET) S DELIM="|" ; | delim in silent mode
 ;
 N PATCH S PATCH=^A1AE(11005,IEN,0) ; DHCP Patches record's header
 N NODE5 S NODE5=$G(^A1AE(11005,IEN,5)) ; DHCP Patches record's node 5
 ;
 ; [Stream]Subject
 S ID=$$STRMSUBJ(.IDLEN,PATCH,DELIM)
 ;
 ; padding:
 N PAD S $P(PAD," ",IDLEN-8)="" ; create pad
 I '$G(DIQUIET) S ID=ID_PAD ; add pad to ID
 ;
 ; Status:
 N STATUS S STATUS=$P(PATCH,U,8) ; field Status of Patch (8)
 N DDSTATUS S DDSTATUS=^DD(11005,8,0) ; definition of field 8, header
 N DDSET S DDSET=$P(DDSTATUS,U,3) ; definition of set of codes
 N STATCODE S STATCODE=$P($P(DDSET,STATUS_":",2),";") ; external val
 I $E(STATUS)=2 D  ; special abbreviations for sec statuses
 . I STATUS="i2" S STATCODE="2IR" Q  ; in review
 . I STATUS="d2" S STATCODE="2UN" Q  ; sec development
 . I STATUS="s2" S STATCODE="2CO" Q  ; sec completion
 . I STATUS="r2" S STATCODE="2VE" Q  ; sec release
 . I STATUS="n2" S STATCODE="2NO" Q  ; not for sec release
 S ID=ID_$E(STATCODE,1,3)_DELIM ; add Status to ID
 ;
 ; User:
 N USERENTR S USERENTR=+$P(PATCH,U,9) ; field User Entering (9)
 N USER S USER=$G(^VA(200,USERENTR,0)) ; New Person record's header
 N INITIAL S INITIAL=$P(USER,U,2) ; field Initial (1) of file 200
 I INITIAL="" S INITIAL="unknown" ; if no user or no initials
 S ID=ID_$E(INITIAL,1,3) ; add User to ID
 ;
 ; output write ID:
 N TAB S TAB=$S(X<33:32,1:X-1) ; tab for terminal
 I $G(DIQUIET) S TAB=0 ; don't tab for GUI
 D EN^DDIOL(ID,"","?"_TAB) ; output the write ID
 ;
 N DERIVED S DERIVED=$P(NODE5,U,2) ; field Derived from Patch
 Q:'DERIVED  ; line 2 of identifier is only for derived patches
 N ORIG S ORIG=$G(^A1AE(11005,DERIVED,0)) ; derived patch's header
 Q:ORIG=""  ; if no real patch, then no line 2
 ;
 ; derived from [Stream]Subject
 S IDLEN=45 ; plenty of room
 N IDLINE2 S IDLINE2="derived from "_$$STRMSUBJ(.IDLEN,ORIG,DELIM)
 S IDLINE2=$P(IDLINE2,"]")_"]"_$P(ORIG,U) ; **FIX THIS LATER**
 ;
 ; output write ID:
 S TAB=32 ; tab for terminal
 I $G(DIQUIET) S TAB=0 ; don't tab for GUI
 D EN^DDIOL(IDLINE2,"","!?"_TAB) ; output the write ID
 ;
 QUIT  ; end of ID11005
 ;
 ;
STRMSUBJ(IDLEN,PATCH,DELIM) ; [Stream]Subject; See comments
 N ID S ID="" ; return value
 ;
 ; Stream:
 N STREAMDA S STREAMDA=$P(PATCH,U,20) ; field Patch Stream (.2)
 N STREAM S STREAM=$G(^A1AE(11007.1,+STREAMDA,0)) ; record hdr
 S STRABB=$P(STREAM,U,5) ; field Abbreviation (.05)
 I STRABB'="" D  ; skip stream if empty
 . S ID="["_STRABB_"]" ; add Stream to ID
 . S IDLEN=IDLEN-$L(ID) ; decrease room
 ;
 ; Subject:
 N SUBJECT S SUBJECT=$P(PATCH,U,5) ; field Patch Subject (5)
 N SUBJABB S SUBJABB=$E(SUBJECT,1,IDLEN-10) ; make it fit
 S ID=ID_SUBJABB_DELIM ; add Subject to ID
 S IDLEN=IDLEN-$L(SUBJABB) ; decrease room
 ;
 QUIT ID ; end of $$STRMSUBJ(): return [Stream]Subject
 ;
 ;
ASUBCNG(D0) ; See comments
 N DIERR,A1AEFDA,A1AEFDAI
 S A1AEFDA(3,11007.12,"+1,"_D0_",",.01)=$$HTFM^XLFDT($H)
 S A1AEFDA(3,11007.12,"+1,"_D0_",",1)=$G(DUZ)
 D UPDATE^DIE("","A1AEFDA(3)","A1AEFDAI")
 QUIT
 ;
STRMBPN ; get PATCH STREAM by evaluating the PATCH NUMBER
 ; input:
 ;   DA = entry under construction in file DHCP PATCHES (11005)
 ; output:
 ;   sets field patch stream (.2) based on patch number
 ;
 ; 1. id patch's proper stream
 ;
 Q:'DA
 N STRM S STRM=$$GSTRMP(DA) ; get patch's stream
 Q:'STRM
 ;
 ; 2. assign stream and repair index
 ;
 S $P(^A1AE(11005,DA,0),U,20)=STRM ; save in field .2
 ;
 N DIK S DIK="^A1AE(11005,"
 S DIK(1)=.2
 D EN1^DIK ; reindex
 ;
 QUIT  ; end of STRMBPN
 ;
 ;
GSTRMP(DA) ; get PATCH STREAM by evaluating the PATCH NUMBER
 ; input:
 ;  DA into DHCP PATCHES [#11005] file
 ; output:
 ;  PATCH STREAM or 0
 ;
 ; 1. id patch
 ;
 Q:'$G(DA) 0
 Q:'$D(^A1AE(11005,DA,0)) 0
 N PNM S PNM=$P($P($G(^A1AE(11005,DA,0)),U),"*",3)
 Q:'PNM 0
 ;
 ; 2. id its stream
 ;
 ; Find STRM by checking patch number against 11007.1
 N STRM S STRM=$O(^A1AE(11007.1,PNM),-1)
 S:'STRM STRM=$O(^A1AE(11007.1,PNM+1),-1)
 ;
 QUIT STRM ; end of $$GSTRMP ; return patch stream
