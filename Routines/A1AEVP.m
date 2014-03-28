A1AEVP	; RMO,MJK/ALBANY ; Screen Display and Print of New Verified Patches ;24 NOV 87 11:00 am
	;;2.4;PATCH MODULE;;Mar 28, 2014;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;12/02/92
DSPNEW	D CHKNEW G Q:'Y
	W !!,"..please wait checking number of new patches for your selected package(s).." S IOP="HOME" D ^%ZIS K IOP,^TMP("A1AE",$J,"SCN"),A1AEPKIF D GETPKG G Q:'$D(^TMP("A1AE",$J,"SCN")) S A1AEHD="Number of New DHCP Patches" D HD S A1AEPKNM=""
	F A1AEI1=0:0 S A1AEPKNM=$O(^TMP("A1AE",$J,"SCN",A1AEPKNM)) Q:A1AEPKNM=""  I $P(^TMP("A1AE",$J,"SCN",A1AEPKNM),"^",1) S A1AENEW="" D SCNPRT
	W:'$D(A1AENEW) !!?3,"...no new patches for your selected package(s)..." D CRCHK:($Y+8)>IOSL G Q
	;
SCNPRT	D HD:($Y+4)>IOSL W !,$P(A1AEPKNM,"-",1),?$X+(4-$L($P(A1AEPKNM,"-",1))),"-",$E($P(A1AEPKNM,"-",2),1,14),?25,$P(^TMP("A1AE",$J,"SCN",A1AEPKNM),"^",1) S Y=$P(^TMP("A1AE",$J,"SCN",A1AEPKNM),"^",2) W ?35 D DT^DIQ
	Q
	;
PRTNEW	D CHKNEW
	S A1AEVPR="" K ^TMP("A1AE",$J,"SCN"),A1AEPKIF D @($S($D(^A1AE(11007,"AU",DUZ)):"PKGPMT",1:"PKGSEL")) G Q:X="^"!($D(A1AENOSL)) S PGM="START^A1AEVP",VAR=$S($D(A1AEPKIF):"A1AEPKIF^DUZ^A1AEVPR",1:"DUZ^A1AEVPR") W ! D ZIS^A1AEUTL1 G Q:POP
	;
START	U IO D GETPKG G ENDPRT:'$D(^TMP("A1AE",$J,"SCN")) S A1AEHD="New DHCP Patches",(A1AEPKNM,A1AEOUT)="",^UTILITY($J,1)="D HD^A1AEPH2" F A1AEI=0:0 S A1AEPKNM=$O(^TMP("A1AE",$J,"SCN",A1AEPKNM)) Q:A1AEPKNM=""!(A1AEOUT["^")  D PRT
ENDPRT	W:'$D(^TMP("A1AE",$J,"SCN")) !?3,"...no new patches for your selected package(s)" G Q
	;
PKGPMT	R !!,"Do you want to Print Patches for a Specific Package? No// ",X:DTIME G Q:'$T!(X="^") S:X="" X="N" G PKGSEL:"Yy"[$E(X,1) Q:"Nn"[$E(X,1)  W:X'["?" *7 D PKGHLP G PKGPMT
	;
PKGHLP	W !!,"Enter Yes to print patches for any package in the Patch File.",!,"Enter No to print patches for all your selected packages."
	Q
	;
PKGSEL	S DIC("S")="I $P(^(0),U,2)=""Y""!($P(^(0),U,4)=""y""&($D(^A1AE(11007,""AU"",DUZ,+Y))))" D PKG^A1AEUTL S:'$D(A1AEPK) A1AENOSL="" Q:$D(A1AENOSL)  D PKGADD:'$D(^A1AE(11007,"AU",DUZ,A1AEPKIF))
	Q
	;
PKGADD	W !!,"Do you want to receive automatic notification and printing",!,"of ",A1AEPKNM,"? No// " R X:DTIME Q:'$T!(X="^")  S:X="" X="N" I "NYny"'[$E(X,1) W:X'["?" *7 W !!,"Enter Y to Add ",A1AEPKNM,", or N continue." G PKGADD
	I "Yy"[$E(X,1) D SETNOD^A1AEAU
	Q
	;
PRT	S A1AEPD="" F A1AEI1=0:0 S A1AEPD=$O(^TMP("A1AE",$J,"SCN",A1AEPKNM,A1AEPD)) Q:A1AEPD=""!(A1AEOUT["^")  D PRT1
	Q
	;
PRT1	F A1AEIFN=0:0 S A1AEIFN=+$O(^TMP("A1AE",$J,"SCN",A1AEPKNM,A1AEPD,A1AEIFN)) Q:'A1AEIFN!(A1AEOUT["^")  S DIWF="B4|",D0=A1AEIFN K ^UTILITY($J,"W"),DXS D HD^A1AEPH2,^A1AEP K DN,DXS,^UTILITY($J,"W")
	Q
	;
Q	W ! K ^UTILITY($J),DN,DXS,A1AEPD,A1AEPK,A1AEOUT,A1AEIFN,^TMP("A1AE",$J,"SCN"),A1AELTP,A1AEDTV,A1AEPKIF,A1AEPKNM,A1AEPGE,A1AEVPR,A1AEHD,A1AEI,A1AEI1,A1AETOT,A1AENOSL,A1AENEW,A1AEPGE,POP,PGM,VAR D CLOSE^A1AEUTL1
	Q
	;
GETPKG	I $D(A1AEPKIF) D GETDTV Q
	F A1AEPKIF=0:0 S A1AEPKIF=+$O(^A1AE(11007,"AU",DUZ,A1AEPKIF)) Q:'A1AEPKIF  I $P(^A1AE(11007,A1AEPKIF,0),"^",2)="Y"!($P(^(0),"^",4)="y") W "." D GETDTV
	Q
	;
GETDTV	Q:'$D(^DIC(9.4,A1AEPKIF,0))  S A1AELTP=+$O(^A1AE(11005,"AU",DUZ,A1AEPKIF,0)) S:'A1AELTP A1AELTP=9999999 S A1AEPKNM=$P(^DIC(9.4,A1AEPKIF,0),"^",2)_"-"_$P(^DIC(9.4,A1AEPKIF,0),"^",1) I '$D(A1AEVPR) S A1AETOT=0
	F A1AEDTV=0:0 S A1AEDTV=+$O(^A1AE(11005,"AV",A1AEPKIF,A1AEDTV)) Q:'A1AEDTV  D GETIFN
	I '$D(A1AEVPR) S $P(^TMP("A1AE",$J,"SCN",A1AEPKNM),"^",1)=A1AETOT,$P(^TMP("A1AE",$J,"SCN",A1AEPKNM),"^",2)=$S(A1AELTP=9999999:"Never Printed",1:9999999-A1AELTP)
	Q
	;
GETIFN	F A1AEIFN=0:0 S A1AEIFN=+$O(^A1AE(11005,"AV",A1AEPKIF,A1AEDTV,A1AEIFN)) Q:'A1AEIFN  I '$D(^A1AE(11005,A1AEIFN,2,DUZ)) S:'$D(A1AEVPR) A1AETOT=A1AETOT+1 D SETLOC:$D(A1AEVPR)
	Q
	;
SETLOC	S ^TMP("A1AE",$J,"SCN",A1AEPKNM,$S($D(^A1AE(11005,A1AEIFN,0)):$P(^(0),"^",1),1:"UNKNOWN"),A1AEIFN)=""
	Q
	;
HD	S:'$D(A1AEPGE) A1AEPGE=0 D CRCHK W @IOF,!,A1AEHD S A1AEPGE=A1AEPGE+1,Y=DT W ?55 D DT^DIQ W ?70,"Page: ",A1AEPGE W ! F I=1:1:78 W "="
	W !!,"Package",?25,"Number",?35,"Date Last Printed",!,"-------------------",?25,"------",?35,"-----------------"
	Q
	;
CRCHK	I A1AEPGE,$E(IOST,1)="C" W !!,"Press RETURN to continue " R X:DTIME
	Q
	;
CHKNEW	S %DT="",X="T" D ^%DT S DT=Y,Y=1 I '$D(^A1AE(11007,"AU",DUZ)) W !!?3,*7,"You have not selected any packages for automatic notification and",!?3,"printing of patches." S Y=0
	Q
