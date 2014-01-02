A1AEMGR	; RMO/ALBANY ; Patch Module Manager Utilities ;23 MAR 88 9:00 am
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	;*** NOT FOR GENERAL DISTRIBUTION- Sent to Milt on FORUM 3/23/88 ***
	;
SELUSR	;Update patches as printed for ALL selected packages for a select user
	G Q:'$D(^XUSEC("A1AE MGR",DUZ)) S DIC="^VA(200,",DIC(0)="AEMQ" W ! D ^DIC G Q:Y<0 S A1AEUSR=+Y,A1AEUSNM=$P(Y,"^",2) I '$D(^A1AE(11007,"AU",A1AEUSR)) W !!?3,*7,"This user has no packages currently selected." G SELUSR
	S A1AERD("A")="Are you sure you want to update the print status for "_A1AEUSNM_"? ",A1AERD(0)="S",A1AERD(1)="Yes^update print status of verified patches for user",A1AERD(2)="No^do not update print status for user"
	S A1AERD("B")=2 D SET^A1AERD G SELUSR:"N"[$E(X,1)!(X["^") D UPDATE:"Y"[$E(X,1)
	;
Q	K A1AEUSNM,A1AEDTV,A1AEIFN,A1AEPKIF,A1AEUSR
	Q
	;
UPDATE	W !!,"Overriding patch print status for ",A1AEUSNM,"'s selected packages.",! S %DT="",X="T" D ^%DT S DT=Y
	F A1AEPKIF=0:0 S A1AEPKIF=$O(^A1AE(11007,"AU",A1AEUSR,A1AEPKIF)) Q:'A1AEPKIF  I $D(^A1AE(11007,A1AEPKIF,0)),$P(^(0),"^",2)="Y",$D(^DIC(9.4,A1AEPKIF,0)) W !?3,"Updating print status for ",$P(^(0),"^",2)," patches..." D CHKDTV
	Q
	;
CHKDTV	F A1AEDTV=0:0 S A1AEDTV=+$O(^A1AE(11005,"AV",A1AEPKIF,A1AEDTV)) Q:'A1AEDTV  F A1AEIFN=0:0 S A1AEIFN=+$O(^A1AE(11005,"AV",A1AEPKIF,A1AEDTV,A1AEIFN)) Q:'A1AEIFN  I '$D(^A1AE(11005,A1AEIFN,2,A1AEUSR)) D SETPRT
	Q
	;
SETPRT	W !?6,$P(^A1AE(11005,A1AEIFN,0),"^") L ^A1AE(11005,A1AEIFN,2) S:'$D(^A1AE(11005,A1AEIFN,2,0)) ^(0)="^11005.02P^^" S:'$D(^A1AE(11005,A1AEIFN,2,A1AEUSR,0)) $P(^(0),"^",1,2)=A1AEUSR_"^"_DT,$P(^(0),"^",4)=$P(^A1AE(11005,A1AEIFN,2,0),"^",4)+1
	S $P(^A1AE(11005,A1AEIFN,2,A1AEUSR,0),"^",3)=DT,$P(^A1AE(11005,A1AEIFN,2,0),"^",3)=A1AEUSR,^A1AE(11005,"AU",A1AEUSR,+$P(^A1AE(11005,A1AEIFN,0),"^",2),(9999999-DT))="" L
	Q
