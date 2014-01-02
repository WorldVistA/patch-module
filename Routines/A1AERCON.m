A1AERCON	;CJS/SLC - Check for routie overlap on unreleased patchs ;4/25/05  18:59
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
EN	K ^TMP($J) S LINE=0,DIC=11005,DIC(0)="AEMQ",DIC("S")="I ""cu""[$P(^(0),U,8)" D ^DIC S PATCH=+Y G:PATCH'>0 EXIT
	S DIR(0)="NO^0:999:0",DIR("A")="Include patches released within how many months? (0 for only active overlaps)",DIR("B")=0 D ^DIR S MONTHS=Y
	S VER=$P(^A1AE(11005,PATCH,0),"*",2),RLIST=0 F  S RLIST=$O(^A1AE(11005,PATCH,"P",RLIST)) Q:RLIST'>0  D
	. S PROU=$P($G(^A1AE(11005,PATCH,"P",RLIST,0)),U)
	. S OTHERP=0 F  S OTHERP=$O(^A1AE(11005,"R",PROU,OTHERP)) Q:OTHERP'>0  D
	. . Q:OTHERP=PATCH
	. . S LINE0=$G(^A1AE(11005,OTHERP,0)),PNAME=$P(LINE0,U),REL="            " Q:$P(PNAME,"*",2)'=VER
	. . I MONTHS=0 Q:"cu"'[$P(LINE0,U,8)
	. . I MONTHS Q:"cuv"'[$P(LINE0,U,8)  I $P(LINE0,U,8)="v" S X1=DT,(X2,REL)=$P($G(^A1AE(11005.1,OTHERP,0)),U,7)\1 D ^%DTC Q:%Y=0  Q:X/30>MONTHS  S Y=REL D DD^%DT S REL=Y
	. . S LINE=LINE+1,^TMP($J,PROU,LINE)=PROU_$E("          ",$L(PROU),10)_PNAME_$E("              ",$L(PNAME),14)_REL_"  "_$P($G(^VA(200,+$P(LINE0,U,9),0)),U)
	. . Q
	. Q
	W !,"Routines in entered or completed patches that overlap with ",$P(^A1AE(11005,PATCH,0),U)
	W !,"Routine    Patch          Release Date  Patch Entered by"
	S PROU="" F  S PROU=$O(^TMP($J,PROU)) Q:PROU=""  D
	. S LINE=0 F  S LINE=$O(^TMP($J,PROU,LINE)) Q:LINE'>0  D
	. . W !,^TMP($J,PROU,LINE)
	. . Q
	. Q
EXIT	K ^TMP($J),PATCH,RLIST,PROU,OTHERP,LINE,LINE0,PNAME,MONTHS,REL,VER
	Q
