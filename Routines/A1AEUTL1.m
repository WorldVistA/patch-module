A1AEUTL1	; RMO,MJK/ALBANY ;2014-03-27  1:54 PM
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	;
PCHK	;call if $d(^(d0,"q","b")), return az(), k az,print
	S AZ=0 F  S AZ=$O(^A1AE(11005,D0,"Q",AZ)) Q:'AZ  I $D(^(AZ,0)) S AZ0=^(0),AZ(+AZ0)=$S($D(^A1AE(11005,+AZ0,0)):"("_$P(^(0),"^",8)_")"_$P(^(0),"^"),1:"patch not available") DO
	.F  Q:AZ(+AZ0)'["*999*"  DO
	. .S AZ(+AZ0)=$P(AZ(+AZ0),"*999*",1)_"*DBA*"_$P(AZ(+AZ0),"*999*",2,99) Q
	.I $P(AZ0,"^",2)="y" S AZ("STOP",+AZ0)=AZ(+AZ0),AZ(+AZ0)=$E(AZ(+AZ0)_"     ",1,15)_"<<= must be installed BEFORE"_$S($D(A1AEPD):" `"_A1AEPD_"'",1:"") Q
	.E  S AZ(+AZ0)=$E(AZ(+AZ0)_"          ",1,19)_"install with patch"_$S($D(A1AEPD):"       `"_A1AEPD_"'",1:"") Q
	K AZ0
	I $D(AZ)=11 S AZ("TX",1)="Associated patches: "
	I $D(CHECK) DO
	.S AZ=0 F  S AZ=$O(AZ("STOP",AZ)) Q:'AZ  I $D(^A1AE(11005,AZ,0)),$P(^(0),"^",8)="v" K AZ("STOP",AZ)
	.K STP Q
	Q:'$D(PRINT)  Q:'$O(AZ(0))
	;
	W !,AZ("TX",1)
	S AZ=0 F  S AZ=$O(AZ(AZ)) Q:'AZ  W:$X>25 !?20 I AZ(AZ)'["<<" W AZ(AZ),!?20
	S AZ=0 F  S AZ=$O(AZ(AZ)) Q:'AZ  W:$X>25 !?20 I AZ(AZ)["<<" W AZ(AZ),!?20
	Q
	;
Q	K IO("Q") R !,"REQUESTED TIME TO RUN JOB: NOW// ",X:DTIME Q:X["^"  S Y=$H I $P("NOW",X,1)]"" S:X'["@" X="T@"_X S %DT(0)=0,%DT="TXE" D ^%DT K %DT G Q:Y<1 S X=+Y D H^%DTC S Y=Y_"000",Y=%H_","_($E(Y,9,10)*60+$E(Y,11,12)*60)
Q1	;Entry point for background jobs
	;S X=Y L ^%ZTSK S (^%ZTSK(0),ZTSK)=^%ZTSK(0)+1 L  X ^%ZOSF("UCI")
	S X=Y X ^%ZOSF("UCI") S ZTUCI=Y
	;S ^%ZTSK(ZTSK,0)="DQ^A1AEUTL1^"_$S($D(DUZ)#2:DUZ,1:"")_"^"_Y_"^"_$H,^("ZTSK")=ZTSK,^("VAR")=VAR,^("VAL")=VAL,^("PGM")=PGM S:$D(DIS(0)) ^("DIS(0)")=DIS(0)
	F J="VAR","VAL","PGM","DIS(0)" S:$D(@J) ZTSAVE(J)=""
	S ZTRTN="DQ^A1AEUTL1",ZTIO=ION,ZTDTH=X,ZTDESC="Patch Module Task"
	;S ^%ZTSCH(X,ZTSK)=ION_$S(ION]"":";"_IOST_";"_IOSL,1:"") K PGM,VAR,VAL,ZTSK W:ION]"" !,"REQUEST QUEUED!",! Q
	D ^%ZTLOAD W:ION]"" !,"Request queued!",! K PGM,VAR,VAL,ZTSK Q
	Q
DQ	;S PGM=^%ZTSK(ZTSK,"PGM"),VAR=^("VAR"),VAL=^("VAL") S:$D(^("DIS(0)")) DIS(0)=^("DIS(0)") S IOP=IO D:IO]"" ^%ZIS K ^%ZTSK(ZTSK)
	F A1AEI=1:1 Q:$P(VAR,"^",A1AEI)']""  S @($P(VAR,"^",A1AEI))=$P(VAL,"^",A1AEI)
	S X="T",%DT="" D ^%DT S DT=Y G @PGM
	;
ZIS	S %ZIS="QFM" D ^%ZIS K %ZIS K:POP IO("Q") Q:POP  I $D(IO("Q")) X "S VAL="""" F A1AEI=1:1 Q:$P(VAR,""^"",A1AEI)']""""  S VAL=VAL_@($P(VAR,""^"",A1AEI))_""^""" D Q S POP=1 Q
	;I $D(IO("C")) W !!,"EXIT",! C IO(0) Q
	Q
	;
CLOSE	;G H^XUS:$D(IO("C"))
	D ^%ZISC U IO(0) S IOP="HOME" D ^%ZIS K IOP Q
	;
	;S PGM="MDQ^A1AEUTL1",VAR="A1AEPKIF^XMB^DUZ" F I=1:1 Q:'$D(XMB(I))  S VAR=VAR_"^XMB("_I_")",ION=""
	;X "S VAL="""" F A1AEI=1:1 Q:$P(VAR,""^"",A1AEI)']""""  S VAL=VAL_@($P(VAR,""^"",A1AEI))_""^"""
	;S X="NOW",%DT(0)=0,%DT="TXE" D ^%DT K %DT G Q:Y<1 S X=+Y D H^%DTC S Y=Y_"000",Y=%H_","_($E(Y,9,10)*60+$E(Y,11,12)*60) D Q1 K A1AEI Q
	;
M	;Send Bulletins to appropriate users stored in XMY
	K:$P(^A1AE(11007,A1AEPKIF,0),"^",2)'="Y"&($P(^(0),"^",4)'="y") ^TMP("XMY",$J),XMY
	Q:'$D(^TMP("XMY",$J))&('$D(XMY))!('$D(DUZ))
	S XMDUZ=DUZ D EN^XMB K ^TMP("XMY",$J),XMY
	Q
	;
DATE	;Ask Date Range of Verified patches
	S POP=0 K BEGDATE,ENDDATE W !!,"**** Date Range of Released Patches ****"
	W ! S %DT="APEX",%DT("A")="   Beginning DATE : " D ^%DT S:Y<0 POP=1 Q:Y<0  S (%DT(0),BEGDATE)=Y
	W ! S %DT="APEX",%DT("A")="   Ending    DATE : " D ^%DT K %DT S:Y<0 POP=1 Q:Y<0  W ! S ENDDATE=Y
	Q
XTM	S Y=$E(Y,4,5)_"/"_$E(Y,6,7)_"/"_$E(Y,2,3)_$P("@"_$E(Y_0,9,10)_":"_$E(Y_"000",11,12),"^",Y[".") S:Y="//" Y="" Q
TM	X ^DD("DD") Q  ; Expect Y and output Y.
	Q
