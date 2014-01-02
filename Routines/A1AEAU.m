A1AEAU	; RMO,MJK/ALBANY ; DHCP Problem/Patch File Edits ;24 NOV 87 11:00 am
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;12/02/92
	G:$D(^DOPT("A1AEAU",6)) A S ^DOPT("A1AEAU",0)="Authorized Users Menu Option^1N^" F I=1:1 S X=$T(@I) Q:X=""  S ^DOPT("A1AEAU",I,0)=$P(X,";;",2,99)
	S DIK="^DOPT(""A1AEAU""," D IXALL^DIK
A	W !! S DIC="^DOPT(""A1AEAU"",",DIC(0)="AEQM" D ^DIC Q:Y<0  D @+Y G A
	;
1	;;Entry/Edit Authorized Users
	S DIC("S")="I $D(^A1AE(11007,+Y,""PH"",DUZ,0))" D PKG^A1AEUTL Q:'$D(A1AEPK)  W !!,"Adding Authorized Users to: ",A1AEPKNM,! S DA=A1AEPKIF,DIE="^A1AE(11007,",DR="[A1AE ADD/EDIT USERS]",DIE("NO^")="" D ^DIE K DIE("NO^"),DE,DQ,DIE D KEY^A1AEKEY
	Q
	;
2	;;Select Packages for Notification
	G LIST
ADDUSR	K A1AEDEL S DIC="^A1AE(11007,",DIC(0)="EMQ" R !!,"Select PACKAGE: ",X:DTIME G Q:'$T!(X="^")!(X="") S:$E(X,1)="-" X=$E(X,2,99),A1AEDEL=""  G:"ALLall"[$E(X,1,3)&($L(X)=3) SETUSR
	S DIC("S")="I $P(^(0),U,2)=""Y""" D ^DIC K DIC("S") I Y>0 S A1AEPKIF=+Y,A1AEPKNM=$P(^DIC(9.4,+Y,0),"^",1) G SELUSR
	W:X'["?" *7 W !!,"Enter 'ALL' or a specific package you want to be included in."
LIST	I '$D(^A1AE(11007,"AU",DUZ)) W !!?3,"You currently have no packages selected for immediate notification." G ADDUSR
	W !!?3,"You currently have the following packages selected:"
	F A1AEPKIF=0:0 S A1AEPKIF=$O(^A1AE(11007,"AU",DUZ,A1AEPKIF)) Q:'A1AEPKIF  I $D(^A1AE(11007,A1AEPKIF,0)),$P(^(0),"^",2)="Y",$D(^DIC(9.4,A1AEPKIF,0)) W !?7,$P(^(0),"^",2),?12,"-",?14,$P(^(0),"^",1)
	K A1AEPKIF G ADDUSR
	;
SETUSR	W !
	I "ALLall"[$E(X_0,1,3),$L(X)=3
	IF  S DIR(0)="YO",DIR("B")="NO"
	IF  S DIR("A")="  Are you sure you want to "_$S($D(A1AEDEL):"DE-SELECT",1:"select")_" 'ALL' packages for notification " IF 1
	IF  S DIR("?")=" Enter 'Y' to continue" D ^DIR I $D(DUOUT)!($D(DTOUT))!('Y) K DIR G ADDUSR
	K DIR
	F A1AEPKIF=0:0 S A1AEPKIF=+$O(^A1AE(11007,A1AEPKIF)) Q:'A1AEPKIF  I $P(^(A1AEPKIF,0),"^",2)="Y" S A1AEPKNM=$P(^DIC(9.4,A1AEPKIF,0),"^",1) DO
	.IF '$D(A1AEDEL) DO
	. .I $D(^A1AE(11007,A1AEPKIF,1,DUZ,0)) W !?3,"...already on ",A1AEPKNM," list" Q
	. .D SETNOD
	.E  DO
	. .I '$D(^A1AE(11007,A1AEPKIF,1,DUZ,0)) Q
	. .S DIK="^A1AE(11007,"_A1AEPKIF_",1,",DA(1)=A1AEPKIF,DA=DUZ
	. .D ^DIK W !?3,"...deleted from ",A1AEPKNM
	. .K DIK,DA
	;
	G ADDUSR
	;
Q	K A1AEPKNM,A1AEPKIF,A1AEPK,DIE,DIC,DIR,DA,DR,D0,DI,D0,D1,DE,DQ Q
	;
SELUSR	I '$D(^A1AE(11007,A1AEPKIF,1,DUZ,0)),'$D(A1AEDEL) D SETNOD G ADDUSR
	;naked reference to tag SELUSR
	I '$D(^(0)),$D(A1AEDEL) W !?3,*7,"...currently not in the ",A1AEPKNM," list" G ADDUSR
	I $D(^(0)),$D(A1AEDEL) G DELUSR
	W !!,"You already receive automatic notification and printing of ",A1AEPKNM," patches.",!,"Do you want this to stop? No// "
	R X:DTIME G Q:'$T!(X="^"),ADDUSR:"Nn"[$E(X,1),DELUSR:"Yy"[$E(X,1) W:X'["?" *7 W !!,"Enter Y to delete, or N to exit." G SELUSR
	;
SETNOD	S DA=A1AEPKIF,DIE="^A1AE(11007,",DR="50///`"_DUZ,DR(2,11007.05)="2///T" K DE,DQ D ^DIE I '$D(Y) W !?3,"...added to ",A1AEPKNM
	Q
	;
DELUSR	S DIK="^A1AE(11007,"_A1AEPKIF_",1,",DA(1)=A1AEPKIF,DA=DUZ D ^DIK W !?3,"...deleted from ",A1AEPKNM G ADDUSR
	;
3	;;Add Package to Patch Module
	Q:'$D(^XUSEC("A1AE MGR",DUZ))  S A1AE(0)="AEMLQ" D PKG^A1AEUTL Q:'$D(A1AEPK)  S DA=A1AEPKIF,DR="[A1AE ADD/EDIT USERS]",DIE="^A1AE(11007," D ^DIE K DQ,DE,A1AEPKIF,A1AEPKNM,A1AEPK Q
	;
4	;;List of Package Users
	S DIC("S")="I $D(^A1AE(11007,+Y,""PH"",DUZ,0))" D PKG^A1AEUTL Q:'$D(A1AEPK)
	S DIC="^A1AE(11007,",FLDS="[A1AE PACKAGE USERS]",BY=".01",(FR,TO)=A1AEPKNM,L=0 D EN1^DIP K FLDS,TO,FR,BY,A1AEPKIF,A1AEPK,A1AEPKNM Q
	;
5	;;Patch Options Documentation
	S DIC="^DIC(19,",FLDS="[A1AE PATCH OPTS DOC]",BY="@.01",FR="A1AE",TO="A1AEZ",DIS(0)="I $P(^DIC(19,D0,0),U,1)'[""PB"",$P(^(0),U,1)'[""A1AE MGR"",$P(^(0),U,1)'[""A1AE XUSEC""",L=0 W ! D EN1^DIP K FLDS,BY,FR,TO,DIS(0) Q
	;
6	;;Key Allocation for Patch Functions
	D ASKKEY^A1AEKEY
