A1AEPH6	; RMO/ALBANY ;6/29/07  11:01
	;;2.4;PATCH MODULE;;Mar 28, 2014;Build 8
COMDIS	;Display a Completed/NotReleased Patch
	S DIC("A")="Select PATCH: ",DIC("S")="I $P(^(0),U,8)=""c"",$S($D(^A1AE(11007,+$P(^(0),U,2),""PH"",DUZ,0)):1,'$D(^A1AE(11007,+$P(^A1AE(11005,+Y,0),U,2),""PB"",DUZ,0)):0,$P(^(0),U,2)=""V"":1,1:0)",DIC="^A1AE(11005,",DIC(0)="AEMQ"
	W ! D ^DIC K DIC("A"),DIC("S") G Q:Y<0 S (A1AEIFN,D0)=+Y,A1AEPD=$P(Y,U,2),A1AEVPR="",A1AEHD="DHCP Completed/NotReleased Patch Display"
	W ! S %ZIS="",A1AEPGE=0 D ^%ZIS G Q:POP K IOP,%ZIS U IO S ^UTILITY($J,1)="D HD^A1AEPH2",DIWF="B4X" K ^UTILITY($J,"W"),DXS D HD^A1AEPH2,^A1AEP K DN,DXS I $D(A1AEOUT),A1AEOUT["^" G Q ;SO DI*22*152
	D Q G COMDIS
	;
PATDIS	;Display a Patch
	;                  Verified      !ent.in err!retired    &
	S DIC("S")="I ($P(^(0),U,8)=""v""!($P(^(0),U,8)=""e"")!($P(^(0),U,8)=""r""))&($S('$D(^A1AE(11007,+$P(^(0),U,2),0)):0,$P(^(0),U,2)=""Y"":1,$P(^(0),U,4)=""y""&($D(^A1AE(11007,""AU"",DUZ,+$P(^A1AE(11005,+Y,0),U,2)))):1,1:0))"
	S DIC("S")=DIC("S")_"!$D(^A1AE(11007,""AD"",DUZ,+$P(^A1AE(11005,+Y,0),U,2)))"
	; ( not no 11007 record for package ! user selection permitted ! ("test site only"& user is [self]"selected" for package )
	S DIC("A")="Select PATCH: ",DIC="^A1AE(11005,",DIC(0)="AEMQ" W ! D ^DIC K DIC("A"),DIC("S") G Q:Y<0 S (A1AEIFN,D0)=+Y,A1AEPD=$P(Y,U,2),A1AEVPR="",A1AEHD="DHCP Patch Display"
	S $P(A1AEPD,"*",2)=$S($P(A1AEPD,"*",2)=999:"DBA",1:$P(A1AEPD,"*",2))
	;I $P(^A1AE(11005,A1AEIFN,0),"^",8)="e"!($P(^(0),"^",8)="r") S DHD="@",L=0,DIC="^A1AE(11005," D SETFLDS S BY="'INTERNAL(#.01)",(FR,TO)=A1AEIFN W ! S IOP="HOME" D EN1^DIP
	I $P(^A1AE(11005,A1AEIFN,0),"^",8)="e"!($P(^(0),"^",8)="r") S DHD="@",L=0,DIC="^A1AE(11005," D SETFLDS S BY="",(FR,TO)=A1AEIFN W !  D EN1^DIP G Q
	I $P(^A1AE(11005,A1AEIFN,0),"^",8)="v"!$D(^A1AE(11007,"AD",DUZ,+$P(^A1AE(11005,+A1AEIFN,0),U,2))) W ! S %ZIS="",A1AEPGE=0 D ^%ZIS G Q:POP D  I $D(A1AEOUT),A1AEOUT["^" G Q
	.  K IOP,%ZIS U IO S ^UTILITY($J,1)="D HD^A1AEPH2",DIWF="B4X" K ^UTILITY($J,"W"),DXS D HD^A1AEPH2,^A1AEP K DN,DXS ;SO DI*22*152
	D Q G PATDIS
	;
SETFLDS	I $P(^A1AE(11005,A1AEIFN,0),"^",8)="e" S FLDS="D HD^A1AEPH2;X;"""",""Subject:"";C1;S1,5;"""",""Entered in Error Description:"";C1;S1,8.5;C1;S1;"""""
	I $P(^A1AE(11005,A1AEIFN,0),"^",8)="r" S FLDS="D HD^A1AEPH2;X;"""",""Subject:"";C1;S1,5;"""",""Description:"";C1;S1,5.5;C1;S1;"""",""Retired After Version:"";C1;S1,15;"""",""Retirement Comments:"";C1;S1,15.5;C1;S1;"""""
	Q
	;
EXTDIS	;Extended Display of a Patch
	S DIC("A")="Select PATCH: ",DIC("S")="I $D(^A1AE(11007,+$P(^(0),U,2),""PH"",DUZ,0))",DIC="^A1AE(11005,",DIC(0)="AEMQ" W ! D ^DIC K DIC("A"),DIC("S") G Q:Y<0 S (DA,A1AEIFN)=+Y D USRPMT G Q:X="^"
	D Q G EXTDIS
	;
USRPMT	;Developer can display when a select user printed a patch, or the
	;entire patch including all users who printed it.
	S A1AERD("A")="Do you want to know when a specific user printed this patch? ",A1AERD(0)="S",A1AERD(1)="Yes^print when a specific user saw this patch",A1AERD(2)="No^print patch details WITHOUT selected users",A1AERD("B")=2 ; << REW
	W ! D SET^A1AERD K A1AERD Q:X="^"  G USR:"Y"[$E(X,1) I "N"[$E(X,1) S DR="0;C;D;E;P" W ! D EN^DIQ ; ;2 deleted to remove who/when info.  <<  REW
	Q
	;
USR	S DIC="^VA(200,",DIC(0)="AEMQ" W ! D ^DIC Q:Y<0  S A1AEDUZ=+Y
	I $D(^A1AE(11005,A1AEIFN,2,A1AEDUZ,0)) W !!?3,"Printed patch initially on " S Y=$P(^(0),"^",2) D DT^DIQ I $P(^(0),"^",2)'=$P(^(0),"^",3) W " and last on " S Y=$P(^(0),"^",3) D DT^DIQ
	W:'$D(^A1AE(11005,A1AEIFN,2,A1AEDUZ,0)) !!?3,"Never printed patch" K A1AEDUZ G USR
	;
Q	W ! K ^UTILITY($J),DN,D0,DXS,DIS(0),A1AEOUT,A1AES,A1AED0,A1AEIX,A1AEJ,A1AEN,A1AEI,A1AEAB,A1AED,A1AEHD,A1AELNE,IOP,FLDS,BY,L,FR,TO,DIS,A1AEPD
	K A1AEIFN,A1AESCN,A1AEVPR,A1AEPKIF,A1AEPKNM,A1AEPK,A1AEVR,A1AETY,A1AEVPR,POP,PGM,VAR,A1AEPGE D CLOSE^A1AEUTL1 Q
	;
	      
