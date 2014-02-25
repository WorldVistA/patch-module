A1AEUTL ;RMO,MJK/ALBANY,VEN/SMH&TOAD - Patch Utilities ; 2/25/14 5:41pm
 ;;2.4;Patch Module;;Oct 17, 2007;Build 8
 ;
 ; Change History:
 ;
 ; 2007 01 11: previous change; by Wally Fort of the Oakland VA Field
 ; Office (ISF/RWF).
 ;
 ; 2014 01 06: Sam Habiel of the VISTA Expertise Network (VEN/SMH):
 ; in SETNUM, DIC(0) will be taken from the symbol table if it is
 ; defined to make the output silent for Unit Testing. Otherwise, it
 ; will default to LE.
 ;
 ; 2014 01 10: (VEN/SMH) replace awkward logic in SETNUM based on
 ; traditional simple index AB on file DHCP Patches (11005) to be
 ; based on replacement new-style compound index AB. Old algorithm
 ; was hard-coded to a limit of 999 as the highest patch number.
 ; New algorithm uses reverse $order to get last patch number, with
 ; no hard-coded limit.
 ;
 ; 2014 01 22: (VEN/SMH) introduce new variable A1AESTRM and logic
 ; to set initial sequence number and patch number based on new file
 ; DHCP Patch Stream (11007.1)'s field Patch Number Start (.001).
 ; Changes in SEQ, NUM, SETNUM, & $$PRIMSTRM.
 ;
 ; 2014 02 10-11,25: Rick Marshall of the VISTA Expertise Network
 ; (VEN/TOAD): added change history, new subroutine ID11005 to
 ; replace file DHCP Patches (11005)'s WRITE identifier logic,
 ; changed $$PRIMSTRM to use new APRIM index instead of old PRIM
 ; index to avoid letting users select DHCP Patch Stream records
 ; by typing YES or NO. Changed name of default record from
 ; "VA PATCH STREAM" to "FOIA VISTA" and set its field Abbreviation
 ; (.05) to "FV". Fixed an intermediate-calculation bug in the WRITE
 ; ID logic - if patch had status of cancel, it calculated as
 ; "cancel^0" instead of "cancel" before extracting just the first
 ; three characters; the results were correct, but the intermediate
 ; value was wrong.
 ;
 ;
 ;logic to get and set seq#
 ; VEN/SMH - Stream logic here -- done, second trail.
SEQ L +^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PR"):60
 S A1AESTREAM=$$PRIMSTRM()
 ; S SEQ=$G(^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PR"))+1,^("PR")=SEQ ; VEN/SMH - old
 S SEQ=$G(^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PR"),A1AESTREAM-1)+1,^("PR")=SEQ  ; VEN/SMH - new. 1st seq # is stream number - 1.
 I A1AENEW="v" S $P(^A1AE(11005,DA,0),"^",6)=SEQ
 L -^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PR") Q
 ;
 ;if mail message generate fails
DELSEQ L +^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PR"):60
 I $D(^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PR")),^("PR") S ^("PR")=^("PR")-1
 L -^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PR") Q
 ;
IN ;Called from the Input transform file 11005, field .01
 N X1,X2
 S X1=$P(X,"*",1) I X1']""!'($P(X,"*",2)=+$P(X,"*",2)) K X Q
 S X2=$O(^DIC(9.4,"C",X1,0)) I 'X2 W !?3,"'",X1,"' is not a valid namespace" K X Q
 I '$D(^A1AE(11007,"B",X2)) W !?3,"'",X1,"' is not a package in the 'DHCP Patch/Problem' file" K X Q
 I '$D(A1AETY) W !?3,"Please use the Edit Template." K X Q
 I A1AETY="PH",'$D(^A1AE(11007,X2,"V",+$P(X,"*",2),0)) W !?3,"'",$P(X,"*",2),"' is not a valid version number for this package" K X Q
 I A1AETY="PK",$D(^A1AE(11007,X2,"V",+$P(X,"*",2))) W !,?3,"'",$P(X,"*",2),"' is not a new package version." K X Q
 I '$D(^A1AE(11007,X2,$S(A1AEX=11005:"PH",1:"PB"),DUZ,0)) W !?3,"You are not an authorized user" K X Q
 I $D(^A1AE(A1AEX,"B",X)) W !?3,"Another error designation with the '",X,"' specification already exists" K X Q
 Q
 ;
PKG K A1AEPKIF,A1AEPK S DIC("A")="Select PACKAGE: ",DIC="^A1AE(11007,",DIC(0)=$S($D(A1AE(0)):A1AE(0),1:"AEMQZ") W ! D ^DIC K DIC,A1AE(0) Q:Y<0  S A1AEPKIF=+Y
 I $D(^DIC(9.4,A1AEPKIF,0)) S A1AEPKNM=$P(^(0),"^",1),A1AEPK=$P(^(0),"^",2)
 Q
 ;
VER F A1AEVR=0:0 S A1AEVR=$O(^A1AE(11007,A1AEPKIF,"V",A1AEVR)) Q:'A1AEVR  S:A1AEVR'=999 DIC("B")=A1AEVR
 S:'$D(^A1AE(11007,A1AEPKIF,"V",0)) ^(0)="^11007.01I^^"
 K A1AEVR S DA=A1AEPKIF,DIC="^A1AE(11007,A1AEPKIF,""V"",",DIC(0)=$S($D(A1AE(0)):A1AE(0),1:"AEQ")
 D ^DIC S:Y>0 A1AEVR=+Y K DIC,A1AE(0)
 Q
 ;
 ;
 ;
NUM ; Entry point for obtaining the next patch number
 S A1AESTREAM=$$PRIMSTRM()                                           ; Obtain primary stream
 L +^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY):3 E  D  Q
 . W $C(7),!!,"Someone else is adding a patch at the moment."
 . W !,"Please try again later."
 S:'$D(^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PB")) ^("PB")=A1AESTREAM     ; VEN/SMH - changed! Initial Problem number. Not used.
 S:'$D(^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PH")) ^("PH")=A1AESTREAM     ; VEN/SMH - changed! Initial Patch number.
 S $P(^A1AE(11007,A1AEPKIF,"V",0),"^",3)=A1AEVR ; Why??              ; VEN/SMH - not my comment.
 S A1AENB=^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY)                    ; if first patch, we start at stream top (TY="PH")
 ;
SETNUM ; New Logic - VEN/SMH for v2.4 - using new AB index
 S X=A1AEPK_"*"_A1AEVR_"*"_A1AENB                                    ; Start ZZZ*2*last number per package file.
 I $D(^A1AE(11005,"AB",A1AEPK,A1AEVR)) D                             ; If package/version has patches already
 . N XEND S XEND=$O(^A1AE(11005,"AB",A1AEPK,A1AEVR,A1AESTREAM+9999),-1) ; Get last patch in stream (greatest number)
 . I XEND<A1AENB                                                     ; If our number is greater or equal to the greatest, ok
 . E  S A1AENB=XEND+1,$P(X,"*",3)=A1AENB                             ; else our patch is one greater than greatest.
 ;
 ;returns x for patch,a1aenb
 S DIC="^A1AE(A1AEFL,",DIC(0)=$G(DIC(0),"LE") ; VEN/SMH old : DIC(0)="LE"
 D ^DIC
 I Y>0 S ^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY)=A1AENB
 L -^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY)
 Q:Y<0
 S DA=+Y,A1AEPD=$P(Y,"^",2),$P(^A1AE(A1AEFL,DA,0),"^",2,4)=A1AEPKIF_"^"_A1AEVR_"^"_A1AENB,^A1AE(A1AEFL,"D",A1AEPKIF,DA)=""
 Q
 ;
 ; /END NUM
 ;
PRT ;Record Printed by
 L +^A1AE(11005,D0,2):60
 S:'$D(^A1AE(11005,D0,2,0)) ^(0)="^11005.02P^^" S:'$D(^A1AE(11005,D0,2,DUZ,0)) $P(^(0),"^",1,2)=DUZ_"^"_DT,$P(^(0),"^",4)=$P(^A1AE(11005,D0,2,0),"^",4)+1
 S $P(^A1AE(11005,D0,2,DUZ,0),"^",3)=DT,$P(^A1AE(11005,D0,2,0),"^",3)=DUZ,^A1AE(11005,"AU",DUZ,+$P(^A1AE(11005,D0,0),"^",2),(9999999-DT))=""
 L -^A1AE(11005,D0,2)
 Q
 ;
ENVER ;This entry point is for permitting Verifiers to clean-up
 ;patches which had to be verified by the Postmaster for
 ;version 2.0 of the patch module.
 W !!?27,"*** NOTE ***",!!?3,*7,"This option will update the Verified information section of a patch",!?3,"to a valid verifier, yourself, rather than the Postmaster."
 W !!?3,"It will put your name in as the Verifier and assign the current date",!?3,"as the date the patch was verified."
 W !!?3,"Once you have verified the patch it will not appear as new again",!?3,"to the user and the 'New Patch Bulletin' will not be sent since these",!?3,"occurred when the patch was originally completed."
 ;
ASKPAT S DIC("A")="Select PATCH: ",DIC("S")="I $P(^(0),U,8)=""v"",$P(^(0),U,14)=.5,$P(^(0),U,9)'=DUZ,$P(^(0),U,13)'=DUZ,$D(^A1AE(11007,+$P(^(0),U,2),""PB"",DUZ,0)),$P(^(0),U,2)=""V""",DIC="^A1AE(11005,",DIC(0)="AEMQ"
 W ! D ^DIC K DIC("A"),DIC("S") G Q^A1AEPH1:Y<0 S DA=+Y,A1AEPD=$P(Y,U,2) S %DT="",X="T" D ^%DT S DT=Y
 S A1AERD("A")="Are you sure you want to verify patch "_A1AEPD_"? ",A1AERD(0)="S",A1AERD(1)="Yes^assign yourself as the Verifier",A1AERD(2)="No^leave the verifier as the Postmaster",A1AERD("B")=2
 D SET^A1AERD K A1AERD,Y G Q^A1AEPH1:X["^" I $E(X,1)["Y" W !!?3,"...please wait ",A1AEPD," is being verified..." S DIE="^A1AE(11005,",DR="8////v;11////"_DT_";14////"_DUZ D ^DIE K DE,DQ W "done"
 D Q^A1AEPH1
 G ASKPAT
 ;
NEWVER(PKIEN,PCHIEN) ;Setup a new version of package.  Called when a Package is released
 N FDA,IEN,X,Y,NAME,PV
 ;^A1AE(11007,A1AEPKIF,"V",A1AEVR)
 S X=$G(^A1AE(11005,PCHIEN,0))
 S NAME=$P($G(^A1AE(11005,PCHIEN,4)),U) Q:'$L(NAME)  ;Not a package release
 S PV=+$P(NAME," ",$L(NAME," ")),IEN="+1,"_PKIEN_",",IEN(1)=PV
 S FDA(11007.01,IEN,.01)=PV,FDA(11007.01,IEN,2)=$$DT^XLFDT
 K IEN D UPDATE^DIE("","FDA","IEN")
 Q
 ;
 ;
PRIMSTRM() ; Return the Primary Stream for this FORUM Patch Module config
 ;;private;function;clean;silent;SAC-compliant
 ; called by: SEQ, NUM
 ; calls: IX1^DIK
 ; input: index PRIM of file DHCP Patch Stream (11007.1)
 ; output = field Patch Number Start (.001/IEN) of primary stream
 ;   if file contains no records, initialize FOIA VISTA record
 ;
 ; if no records, add FOIA VISTA
 I '$D(^A1AE(11007.1,1,0)) D
 . S ^(0)="FOIA VISTA^0^^^FV" ; set Name, Primary?, & Abbreviation
 . N DA,DIK S DA=1,DIK="^A1AE(11007.1," D IX1^DIK ; cross-reference
 ;
 ; get primary stream number using APRIM index
 N PSN S PSN=$O(^A1AE(11007.1,"APRIM",1,"")) ; primary stream #
 ; if not found, site is unconfigured
 I 'PSN S PSN=10**6+1 ; default to 1,000,001
 ;
 QUIT PSN ; return primary stream #; end of $$PRIMSTRM
 ;
 ;
ID11005 ; WRITE Identifier on DHCP Patches file (11005)
 ;;private;procedure;clean;output;SAC-compliant
 ; called by: ^DD(11005,0,"ID","WRITE")
 ; calls: none
 ; input:
 ;   $X
 ;   file DHCP Patches (11005), current record:
 ;     field Patch Stream (.2)
 ;       :file DHCP Patch Stream (11007.1)
 ;       :field Abbreviation (.05)
 ;     field Patch Subject (5)
 ;     field Status of Patch (8)
 ;       :DD definition of set of codes
 ;     field User Entering (9)
 ;       :file New Person (200)
 ;       :field Initial (1)
 ; output to current device (definition):
 ;   IEN  Designation  [Stream]Subject  Status  User
 ; output in silent mode:
 ;   [Stream]Subject|Status|User
 ;
 ; Fields IEN (.001) and Patch Designation (.01) are provided by File
 ; Manager and are not part of this identifier. Everything after that
 ; - the spaces, field Abbreviation (.05) of file DHCP Patch Stream
 ; (11007.1) record pointed to by field Patch Stream (.2), truncated
 ; field Patch Subject (5), abbreviated field Status of Patch (8), and
 ; abbreviated field Initial (1) of file New Person (200) record of
 ; field User Entering (9) - are output as part of this write
 ; identifier. If this Patch Module supports only a single patch stream
 ; then field .2 will be empty, so it will be omitted from this ID.
 ;
 ; output to current device (sample):
 ;
 ; Select DHCP PATCHES PATCH DESIGNATION: ??
 ;
 ;   Choose from:
 ;   12           TIU*1*246    [FV]TESTING TESTING               UND TOA
 ;   13           TIU*1*10002  [OV]TEST                          UND TOA
 ;   14           ZZZ*2*10001  [OV]TEST                          VER USP
 ;
 N ID S ID="" ; initialize identifier
 N X S X=$X ; current X position
 N IDLEN S IDLEN=80-X ; maximum room for identifier
 N DELIM S DELIM=" " ; write ID component delimiter, default to space
 I $G(DIQUIET) S DELIM="|" ; | delim in silent mode
 ;
 N PATCH S PATCH=^(0) ; DHCP Patches record's header
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
 ; padding:
 N PAD S $P(PAD," ",IDLEN-8)="" ; create pad
 I '$G(DIQUIET) S ID=ID_PAD ; add pad to ID
 ;
 ; Status:
 N STATUS S STATUS=$P(PATCH,U,8) ; field Status of Patch (8)
 N DDSTATUS S DDSTATUS=^DD(11005,8,0) ; definition of field 8, header
 N DDSET S DDSET=$P(DDSTATUS,U,3) ; definition of set of codes
 N STATCODE S STATCODE=$P($P(DDSET,STATUS_":",2),";") ; external val
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
 N TAB S TAB=$S(X<19:18,1:X-1) ; tab for terminal
 I $G(DIQUIET) S TAB=0 ; don't tab for GUI
 D EN^DDIOL(ID,"","?"_TAB) ; output the write ID
 ;
 QUIT  ; end of ID11005
 ;
 ;
EOR ; end of routine A1AEUTL
