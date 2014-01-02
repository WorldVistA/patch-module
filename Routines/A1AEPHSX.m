A1AEPHS	; RMO,MJK/ALBANY ; Edit Checks for Status of Patch ; 3/12/85 4pm
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	; Version 1.00
	S A1AENEW=$E(X,1),A1AEOLD=$C($A(A1AEOLD)-32) I A1AEOLD="C"!(A1AEOLD="E")!(A1AEOLD="U")!(A1AEOLD="V") D @A1AEOLD G Q
	;
NEW	D CHKDEV G Q:'$D(X) I A1AENEW="v" W !?3,"The Status may only be set to 'C'ompleted/not verified, 'E'ntered in error, or 'U'nder development" K X
	;
Q	K A1AEOLD,A1AENEW Q
	;
C	I A1AENEW="u" W !?3,"The Status may not be changed to 'U'nder development" K X Q
	I A1AENEW="e" D CHKDEV,CHKERR:$D(X) Q
	I A1AENEW="v",$D(^A1AE(11007,A1AEPKIF,"PB",DUZ,0)),$P(^(0),"^",2)="V" Q
	W !?3,"You are not an Authorized Verifier" K X
	Q
	;
E	W !?3,"Once the Status has been set to 'E'ntered in error it can not be changed" K X Q
	;
U	I A1AENEW'="c" W !?3,"The Status may only be changed to 'C'ompleted/not verified!" W:A1AENEW="e" !?3,"Use the 'Delete Under Development Patches' option",!?3,"rather than 'Entered in Error' status" K X Q
	D CHKDEV Q:'$D(X)  S XMB="A1AE COMPLETED PATCH",XMB(1)=$P(^DIC(9.4,$P(^A1AE(11005,DA,0),"^",2),0),"^",1),XMB(2)=$P(^A1AE(11005,DA,0),"^",1),XMB(3)=$P(^(0),"^",5)
	S XMB(4)=$P($P(^DD(11005,7,0),$P(^A1AE(11005,DA,0),"^",7)_":",2),";",1)
	S A1AEX=X D M^A1AEUTL1 S X=A1AEX K A1AEX W !!,?3,"...Selected Users have been notified" Q
	;
V	I A1AENEW="e" D CHKDEV,CHKERR:$D(X) Q
	W !?3,"The Status may only be changed to 'E'ntered in error" K X Q
	Q
	;
CHKDEV	I '$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0)) W !?3,"You are not an Authorized Developer" K X
	Q
	;
CHKERR	R !!,"Are you sure you want to change the status to 'ENTERED IN ERROR'? No// ",X1:DTIME I '$T!(X1="^")!("Nn"[$E(X1,1)) S X=$C($A(A1AEOLD)+32) Q
	I "Yy"[$E(X1,1) W !?3,"...Status changed to 'E'ntered in error" D SENDER Q
	W:X1'["?" *7 W !!,"Enter Y to change the Status to 'E'ntered in Error, or N to leave the same." G CHKERR
	;
SENDER	S XMB="A1AE ENTERED IN ERROR PATCH",XMB(1)=$P(^DIC(9.4,$P(^A1AE(11005,DA,0),"^",2),0),"^",1),XMB(2)=$P(^A1AE(11005,DA,0),"^",1),XMB(3)=$P(^(0),"^",5) D M^A1AEUTL1 W !!?3,"...Selected Users have been notified",!
	Q
