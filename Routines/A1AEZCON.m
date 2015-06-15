A1AEZCON ;isa/rmo ;2014-03-28T17:00
 ;;2.5;PATCH MODULE;;Jun 13, 2015;
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;Version 2.0 ; *** NOT FOR GENERAL DISTRIBUTION ***
 ;
 ;
CONPAT ;Package prefix conversion entry point.
 I '$D(^XUSEC("A1AE MGR",DUZ)) W !,*7,"You must hold the 'A1AE MGR' key to proceed with this option." G Q
 W !!,*7,"WARNING: This routine ASSUMES you are dealing with a prefix change within",!?9,"the same package in the patch module."
 W !!?9,"The routine also ASSUMES you have updated the prefix in the",!?9,"package file to the 'NEW' one for future patches."
 W !!?9,"Do NOT use this routine to transfer patches from one package",!?9,"name to another."
 S DIC("A")="Select PACKAGE: ",DIC="^A1AE(11007,",DIC(0)="AEMQ" W ! D ^DIC K DIC G Q:Y<0 S A1AEPKIF=+Y
 R !!,"'CURRENT' PACKAGE PREFIX IN PATCH FILE: ",X:DTIME G Q:'$T!(X="")!(X["^") S A1AECPRE=X,A1AEIFN=$O(^A1AE(11005,"D",A1AEPKIF,0))
 G Q:'$D(^A1AE(11005,+A1AEIFN,0)) I $P($P(^(0),"^"),"*",1)'=A1AECPRE W !?3,*7,"Invalid Namespace for selected package!" G Q
 R !,"'NEW'     PACKAGE PREFIX IN PACKAGE FILE: ",X:DTIME G Q:'$T!(X="")!(X["^") S A1AENPRE=X I '$D(^DIC(9.4,"C",X,A1AEPKIF)) W !?3,*7,"The 'NEW' prefix must be in the package file to continue!" G Q
 S A1AERD("A")="Are you sure you want to convert all '"_A1AECPRE_"' patches to '"_A1AENPRE_"'? ",A1AERD(0)="S",A1AERD(1)="Yes^convert.",A1AERD(2)="No^not convert.",A1AERD("B")=2 D SET^A1AERD K A1AERD G Q:X'["Yes"
 W !!,"...searching for patches prefixed by ",A1AECPRE,!
 S A1AEPD="" F A1AELP=0:0 S A1AEPD=$O(^A1AE(11005,"B",A1AEPD)) Q:A1AEPD=""  I $P(A1AEPD,"*")=A1AECPRE S A1AEIFN=$O(^(A1AEPD,0)) I A1AEIFN,$D(^A1AE(11005,A1AEIFN,0)) D CHGPAT
Q K A1AEIFN,A1AELP,A1AEPD,A1AEPKIF,A1AECPRE,A1AENPRE,A1AEPAT,X,Y
 Q
 ;
CHGPAT S A1AEPAT=A1AENPRE_"*"_$P(A1AEPD,"*",2)_"*"_$P(A1AEPD,"*",3) I $D(^A1AE(11005,"B",A1AEPAT)) W !,"...",A1AEPD," not changed ",A1AEPAT," already exists" Q
 S DA=A1AEIFN,DIE="^A1AE(11005,",DR=".01////"_A1AEPAT D ^DIE K DA,DE,DQ,DIE W !,"...",A1AEPD," changed to ",A1AEPAT
 Q
