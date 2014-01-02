A1AEKEY6	; RMO,MJK/ALBANY ; Allocate Patch Function Keys ;24 NOV 87 11:00 am
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;12/02/92
	;----------------------------------------------------------------
	; This module has two separate entry points:
	;      ASKKEY -- is used to prompt the patch user for patch keys
	;                and to enter/edit holders
	;      KEY    -- for automatic allocation of patch keys to users
	;                in a specific package
	; Called if Kernel 7 not installed
	;----------------------------------------------------------------
ASKKEY	;Prompt for patch function key
	S DIC("A")="Select PATCH KEY: ",DIC("S")="S A1AEX=^(0) I $E($P(^(0),U,1),1,4)=""A1AE"",$S($D(^XUSEC(""A1AE MGR"",DUZ)):1,($P(A1AEX,U,1)'=""A1AE XUSEC"")&($P(A1AEX,U,1)'=""A1AE MGR""):1,1:0) K A1AEX",DIC="^DIC(19.1,",DIC(0)="AEMQZ"
	W ! D ^DIC K DIC("A"),DIC("S") Q:Y<0  S A1AEKYIF=+Y,A1AEKEY=$P(Y,U,2) S:'$D(^DIC(19.1,A1AEKYIF,2,0)) ^(0)="^19.12PA^^" D ASKHLD K A1AEKEY,A1AEUSR,A1AEXRF,A1AEDES,A1AEKYIF,A1AEHDIF,A1AEUSNM Q:X="^"  G ASKKEY
	;
ASKHLD	;Prompt for key holder
	S A1AEDUZ0=DUZ(0),DUZ(0)="@",DA(1)=A1AEKYIF,DIC="^DIC(19.1,A1AEKYIF,2,",DIC(0)="AELMQ" W ! D ^DIC S DUZ(0)=A1AEDUZ0 K A1AEDUZ0 Q:Y<0  S A1AEHDIF=+Y,A1AEUSR=$P(Y,U,2) I $P(Y,U,3) W !?3,"...added as an ",A1AEKEY," key holder" G ASKHLD
	S A1AEUSNM=$S($D(^VA(200,A1AEUSR,0)):$E($P(^(0),U,1),1,20),1:"UNKNOWN")
	D LIST:A1AEKEY="A1AE DEVELOPER"!(A1AEKEY="A1AE SUPPORT")!(A1AEKEY="A1AE PHVER"),ASKDEL G ASKHLD
	;
LIST	;List the packages the selected holder may require this key for
	S A1AEXRF=$S(A1AEKEY="A1AE DEVELOPER":"AD",A1AEKEY="A1AE SUPPORT":"AS",A1AEKEY="A1AE PHVER":"AV",1:""),A1AEDES=$S(A1AEXRF="AD":"developer",A1AEXRF="AS":"support person",A1AEXRF="AV":"verifier",1:"")
	I '$D(^A1AE(11007,A1AEXRF,A1AEUSR)) W !!?3,A1AEUSNM," is not a ",A1AEDES," for any package in the Patch file." Q
	I $D(^A1AE(11007,A1AEXRF,A1AEUSR)) W !!?3,A1AEUSNM," is a ",A1AEDES," for:" F A1AEPKIF=0:0 S A1AEPKIF=+$O(^A1AE(11007,A1AEXRF,A1AEUSR,A1AEPKIF)) Q:'A1AEPKIF  I $D(^DIC(9.4,A1AEPKIF,0)) W !?7,$P(^(0),"^",2),?12,"-",?14,$P(^(0),"^",1)
	Q
	;
ASKDEL	;Prompt for deleting the key holder
	S A1AERD("A")="Do you want to delete "_A1AEUSNM_" as an "_A1AEKEY_" key holder? ",A1AERD(0)="S",A1AERD(1)="Yes^delete key holder",A1AERD(2)="No^not delete",A1AERD("B")=2 D SET^A1AERD K A1AERD Q:X="^"!("N"[$E(X,1))
	S DIK="^DIC(19.1,A1AEKYIF,2,",DA(1)=A1AEKYIF,DA=A1AEHDIF D ^DIK W !?3,"...deleted as an ",A1AEKEY," key holder"
	Q
	;
KEY	;Automatic allocation of A1AE SUPPORT, A1AE PHVER, A1AE DEVELOPER keys
	;for a specific package
	W !!?3,"...allocating A1AE SUPPORT, A1AE PHVER, and A1AE DEVELOPER keys" S A1AESKY=+$O(^DIC(19.1,"B","A1AE SUPPORT",0)),A1AEVKY=+$O(^DIC(19.1,"B","A1AE PHVER",0)),A1AEDKY=+$O(^DIC(19.1,"B","A1AE DEVELOPER",0))
	D SUPPORT:A1AESKY,DEVELOP:A1AEDKY W:'A1AESKY !?6,"A1AE SUPPORT key does not exist" W:'A1AEVKY !?6,"A1AE DEVELOPER key does not exist" W:'A1AEDKY !?6,"A1AE DEVELOPER key does not exist"
	K A1AESKY,A1AEVKY,A1AEDKY,A1AEUSR,A1AEVR,A1AEUSNM
	Q
	;
SUPPORT	F A1AEUSR=0:0 S A1AEUSR=+$O(^A1AE(11007,A1AEPKIF,"PB",A1AEUSR)) Q:'A1AEUSR  S A1AEVR=$P(^(A1AEUSR,0),"^",2),DA=A1AESKY D SETKEY:'$D(^XUSEC("A1AE SUPPORT",A1AEUSR)) I A1AEVR="V",A1AEVKY D VERIFY
	Q
	;
VERIFY	S DA=A1AEVKY D SETKEY:'$D(^XUSEC("A1AE PHVER",A1AEUSR))
	Q
	;
DEVELOP	F A1AEUSR=0:0 S A1AEUSR=+$O(^A1AE(11007,A1AEPKIF,"PH",A1AEUSR)) Q:'A1AEUSR  S DA=A1AEDKY D SETKEY:'$D(^XUSEC("A1AE DEVELOPER",A1AEUSR))
	Q
	;
SETKEY	S A1AEUSNM=$S($D(^VA(200,A1AEUSR,0)):$E($P(^(0),U,1),1,20),1:"UNKNOWN")
	W "." S A1AEDUZ0=DUZ(0),DUZ(0)="@",DIE="^DIC(19.1,",DR="2///"_A1AEUSNM,DR(2,19.12)="1///"_DUZ_";2///T" D ^DIE S DUZ(0)=A1AEDUZ0 K DE,DQ,DIE,A1AEDUZ0
	Q
