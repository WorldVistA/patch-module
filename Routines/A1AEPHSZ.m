A1AEPHS	; RMO,MJK/ALBANY ; 20 MAR 86  1:30 PM ; 3/12/85 4pm
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	; Version 1.00
	S A1AENEW=$E(X,1),A1AEOLD=$C($A(A1AEOLD)-32),A1AEOPT=$S(A1AENEW="e":"'Entered in Error'",A1AENEW="c":"'Completed/not verified'",1:"") I A1AEOLD="C"!(A1AEOLD="E")!(A1AEOLD="U")!(A1AEOLD="V") D @A1AEOLD G Q
	;
NEW	D CHKDEV G Q:'$D(X) I A1AENEW="v" W !?3,"The Status may only be set to 'C'ompleted/not verified, 'E'ntered in error, or 'U'nder development" K X
	;
Q	K A1AEOLD,A1AENEW,A1AEOPT,A1AEX Q
	;
C	I A1AENEW="u" W !?3,"The Status may not be changed to 'U'nder development" K X Q
	I A1AENEW="e" D CHKDEV Q:'$D(X)  D CHKSTA,SENDER:X=A1AEX Q
	I A1AENEW="v",$D(^A1AE(11007,A1AEPKIF,"PB",DUZ,0)),$P(^(0),"^",2)="V" Q
	W !?3,"You are not an Authorized Verifier" K X
	Q
	;
E	W !?3,"Once the Status has been set to 'E'ntered in error it can not be changed" K X Q
	;
U	I A1AENEW'="c" W !?3,"The Status may only be changed to 'C'ompleted/not verified!" W:A1AENEW="e" !?3,"Use the 'Delete Under Development Patches' option",!?3,"rather than 'Entered in Error' status" K X Q
	D CHKDEV Q:'$D(X)  D CHKSTA Q:X'=A1AEX  S XMB="A1AE COMPLETED PATCH",XMB(1)=$P(^DIC(9.4,$P(^A1AE(11005,DA,0),"^",2),0),"^",1),XMB(2)=$P(^A1AE(11005,DA,0),"^",1),XMB(3)=$P(^(0),"^",5)
	S XMB(4)=$P($P(^DD(11005,7,0),$P(^A1AE(11005,DA,0),"^",7)_":",2),";",1)
	S A1AEX=X D M^A1AEUTL1 S X=A1AEX K A1AEX W !!,?3,"...Selected Users have been notified" Q
	;
V	I A1AENEW="e" D CHKDEV Q:'$D(X)  D CHKSTA,SENDER:X=A1AEX Q
	W !?3,"The Status may only be changed to 'E'ntered in error" K X Q
	Q
	;
CHKDEV	I '$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0)) W !?3,"You are not an Authorized Developer" K X
	Q
	;
CHKSTA	S A1AEX=X,A1AERD("A")="Are you sure you want to change status to "_A1AEOPT_"? ",A1AERD(0)="S",A1AERD(1)="Yes^change status and send a message to users",A1AERD(2)="No^leave the status the same",A1AERD("B")=2
	W ! D SET^A1AERD K A1AERD S X=$S("Y"[$E(X,1):A1AEX,1:$C($A(A1AEOLD)+32)) W:A1AEX=X !?3,"...status changed to ",A1AEOPT
	Q
	;
SENDER	S XMB="A1AE ENTERED IN ERROR PATCH",XMB(1)=$P(^DIC(9.4,$P(^A1AE(11005,DA,0),"^",2),0),"^",1),XMB(2)=$P(^A1AE(11005,DA,0),"^",1),XMB(3)=$P(^(0),"^",5) D M^A1AEUTL1 W !!?3,"...Selected Users have been notified",!
	Q
