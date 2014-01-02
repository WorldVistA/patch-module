A1AEUTL3	; PKE,RMO,MJK/ALBANY ; Utility add SEQ # ;10 OCT 92 11:00 pm
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;12/02/92
	;
	I $D(DIFROM)
	E  W !?3,$C(7),"This routine should only be after v2.2 inits "
	E  W !?3,"This routine locks SEQ # by package version" Q
EN	W !?0,"Post initialization running ...  "
	D NOW^%DTC S Y=% D DD^%DT W Y,!
	D GET
	S CT=0,IFN=0
	W !?3,"Finding verified patches for last 2 versions",!
	F  S IFN=$O(^A1AE(11005,IFN)) Q:'IFN  I $D(^(IFN,0)) S IF0=^(0) DO
	.S A1AEPKIF=+$P(IF0,"^",2),A1AEVR=+$P(IF0,"^",3),VDT=+$P(IF0,"^",11)
	.;I $D(^TMP("A1AEV",A1AEPKIF,A1AEVR)),$P(IF0,"^",8)="v" DO
	.I $D(^TMP("A1AEV",A1AEPKIF,A1AEVR)),"ver"[$E($P(IF0,"^",8)_0) DO
	..S ^TMP("A1AEV",A1AEPKIF,A1AEVR,VDT,IFN)="",CT=CT+1
	..W:CT#10=0 "." W:$X>65 !
	W !
	;Q
SET	S A1AEPKIF=0,CT=0,A1AENEW="v",SEQ=0
	W !?3,"Adding SEQ # to verified patches",!
	F  S A1AEPKIF=$O(^TMP("A1AEV",A1AEPKIF)) Q:'A1AEPKIF  DO
	.S A1AEVR=0
	.F  S A1AEVR=$O(^TMP("A1AEV",A1AEPKIF,A1AEVR)) Q:'A1AEVR  DO
	..W !?3,^(A1AEVR),"*",A1AEVR,?15
	..L +^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PR")
	..S VDT=0
	..F  S VDT=$O(^TMP("A1AEV",A1AEPKIF,A1AEVR,VDT)) Q:'VDT  DO
	...S IFN=0
	...F  S IFN=$O(^TMP("A1AEV",A1AEPKIF,A1AEVR,VDT,IFN)) Q:'IFN  DO
	....S DA=IFN D SEQ
	....S CT=CT+1 W SEQ,"  " W:$X>67 !?15 Q
	..L -^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PR") Q
	;
	W !
	W !?0,"... Post initialization complete:  "
	D NOW^%DTC S Y=% D DD^%DT W Y,!!
	K AZ,A1AEPKIF,A1AEVR,A1AENEW,VDT,IFN,DA,Y
	;K ^TMP("A1AEV")
	Q
SEQ	S:'$D(^A1AE(11007,A1AEPKIF,"V",A1AEVR,"PR")) ^("PR")=0 S SEQ=^("PR")+1,^("PR")=SEQ
	I A1AENEW="v" S $P(^A1AE(11005,DA,0),"^",6)=SEQ
	Q
	;
	;sets tmp for all packages,versions
GET	S A1AEPKIF=0 K ^TMP("A1AEV")
	W !?3,"Finding last 2 versions of packages",!
	F  S A1AEPKIF=$O(^A1AE(11007,A1AEPKIF)) Q:'A1AEPKIF  DO
	.S A1AEVR=0
	.F  S A1AEVR=$O(^A1AE(11007,A1AEPKIF,"V",A1AEVR)) Q:'A1AEVR  DO
	..S AZ(A1AEPKIF,A1AEVR)=""
	..I A1AEVR'=999
	..E  S ^TMP("A1AEV",A1AEPKIF,999)=$P(^DIC(9.4,A1AEPKIF,0),"^",2)
	.;
	.S A1AEVR=999 ;skip db versions 999
	.F N=1:1 S A1AEVR=$O(AZ(A1AEPKIF,A1AEVR),-1) Q:'A1AEVR  DO
	..I N>2 Q
	..S ^TMP("A1AEV",A1AEPKIF,A1AEVR)=$P(^DIC(9.4,A1AEPKIF,0),"^",2) Q
	Q
