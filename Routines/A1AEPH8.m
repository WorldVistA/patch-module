A1AEPH8	; RMO/ALBANY ; Copy a Patch into a New Patch ;24 NOV 87 11:00 am
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;11/23/92
	;added logic to copy 11005.1 if present, PCOPY
COPY	S DIC("A")="Select PATCH TO COPY: ",DIC("S")="I $D(^A1AE(11007,+$P(^(0),U,2),""PH"",DUZ,0))",DIC="^A1AE(11005,",DIC(0)="AEMQZ" W ! D ^DIC K DIC("A"),DIC("S") Q:Y<0  S A1AEIFN=+Y,A1AEOLPD=$P(Y(0),"^",1),A1AEPKIF=$P(Y(0),"^",2)
	K A1AEVR I $P(A1AEOLPD,"*",2)=999 S $P(A1AEOLPD,"*",2)="DBA",A1AEVR=999
	S A1AERD("A")="Do you want to copy patch "_A1AEOLPD_"? ",A1AERD(0)="S",A1AERD(1)="Yes^copy "_A1AEOLPD_" patch information",A1AERD(2)="No^not copy patch information",A1AERD("B")=2 D SET^A1AERD K A1AERD G Q:X="^",COPY:"N"[$E(X,1)
	I $D(^DIC(9.4,A1AEPKIF,0)) S A1AEPKNM=$P(^(0),"^",1),A1AEPK=$P(^(0),"^",2)
	K ^UTILITY($J,"A1AECOP") S %X="^A1AE(11005,A1AEIFN,",%Y="^UTILITY($J,""A1AECOP""," W !!?3,"...copying ",A1AEOLPD," patch into utility global" D %XY^%RCR
NEW	G Q:'$D(A1AEPK) S A1AEFL=11005,A1AETY="PH",A1AE(0)="AEQL" W !!,"Copy into a new patch for: ",A1AEPKNM,! I '$D(A1AEVR) D VER^A1AEUTL G Q:'$D(A1AEVR)
	I A1AEVR=999,$P(A1AEOLPD,"*",2)'="DBA" W !!?3,*7,"This version is reserved for 'DBA' type patches!" K A1AEVR G NEW
	D NUM^A1AEUTL G Q:'$D(A1AEPD) W !!?3,"...modifying utility global for new patch "
	S $P(A1AEPD,"*",2)=$S($P(A1AEPD,"*",2)=999:"DBA",1:$P(A1AEPD,"*",2))
	S $P(^UTILITY($J,"A1AECOP",0),"^",1,5)=$P(^A1AE(A1AEFL,DA,0),"^",1,5),$P(^UTILITY($J,"A1AECOP",0),"^",8,14)="u"_"^"_DUZ_"^^^"_DT_"^^" K ^UTILITY($J,"A1AECOP",2),^("E")
	;
	S %X="^UTILITY($J,""A1AECOP"",",%Y="^A1AE(11005,DA," W !!?3,"...copying modified utility global into new patch ",A1AEPD D %XY^%RCR S DIK="^A1AE(11005," D IX1^DIK K DIK
	;
PCOPY	S (AXMZ,ADT)="" I $P(A1AEOLPD,"*",1,2)'=$P(A1AEPD,"*",1,2) W !!?3,*7,"...different versions!  patch MESSAGE text not copied" D FILE,ADD G Q
	I $D(^A1AE(11005.1,A1AEIFN,0)) S AXMZ=$P(^(0),"^",2),ADT=$P(^(0),"^",3)
	D FILE
	I $D(^A1AE(11005.1,A1AEIFN,2)) S %X="^A1AE(11005.1,A1AEIFN,2,",%Y="^A1AE(11005.1,DA,2," W !!?3,"...copying patch message" D %XY^%RCR S $P(^A1AE(11005.1,DA,2,0),U,5)=DT
ADD	W !!,"Patch Added: ",A1AEPD,! S DIE="^A1AE(11005,",DR="[A1AE ADD/EDIT PATCHES]" D ^DIE K DQ,DE,DIE
	;remove SEQ # and COMPLIANCE DATE if its there.
	I $G(DA) S $P(^A1AE(11005,DA,0),"^",6)="",$P(^A1AE(11005,DA,0),"^",18)=""
	;
Q	K DA,AXMZ,ADT K ^UTILITY($J,"A1AECOP"),A1AEOLPD,A1AE0,A1AEPKIF,A1AEPKNM,A1AEPD,A1AEPK,A1AEVR,A1AENB,A1AEFL,A1AETY Q
	;added (x,)
FILE	S (X,DINUM)=DA,DIC="^A1AE(11005.1,",DIC("DR")="2///"_AXMZ_";3///"_ADT_";20///"_"No routines included" K DD,DO D FILE^DICN K DE,DQ,DR,DIC("DR") Q
