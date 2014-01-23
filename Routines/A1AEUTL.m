A1AEUTL ; RMO,MJK/ALBANY ;2014-01-22  7:02 PM
 ;;2.3;Patch Module;;Oct 17, 2007;Build 8
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
PRIMSTRM() ; Return the Primary Stream for this FORUM Patch Module config
 ; Output: Primary Stream IEN.
 ; If the Primary VA entry doesn't exist, add it.
 I '$D(^A1AE(11007.1,1,0)) D
 . S ^(0)="VA PATCH STREAM^0" ; set
 . N DA,DIK S DA=1,DIK="^A1AE(11007.1," D IX1^DIK ; index
 ;
 ; Get primary stream number using PRIM xref
 ; If not found, site is unconfigured. Use 1m+1 instead as a default.
 N PSN S PSN=$O(^A1AE(11007.1,"PRIM",1,""))
 IF 'PSN Q 10**6+1
 ELSE  Q PSN
 ;
 ; /PRIMSTRM
