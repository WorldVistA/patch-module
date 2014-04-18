A1AEZTST ; A1AE/PKE - check messages;2014-04-16  7:54 PM
	;;2.4;PATCH MODULE;;Mar 28, 2014;Build 8
	;pke
ENC	S (Z,Z1)="Completed/Unverified",Z3="",TOT=0 D SIZE Q
ENV	S (Z,Z1)="Verified ",Z3="SEQ #",TOT=0 D SIZE Q
	;
ENIN	W !!?10,"Q-PATCH input routines",!!
	S TOT=0
        S %1=$O(^XMB(3.7,.5,2,"B","Q-PATCH")),QUE=$O(^XMB(3.7,.5,2,"B",%1,0)) I 'QUE Q
	S XMZ=0 F  S XMZ=$O(^XMB(3.7,.5,2,QUE,1,XMZ)) Q:'XMZ  DO
	.I '$D(^XMB(3.9,XMZ,0)) Q
	.W !,$P(^(0),"^")
	.S (I,X,Y)=0
	.F  S X=$O(^XMB(3.9,XMZ,2,X)) Q:X=""  S I=I+1,Y=Y+$L(^(X,0)) I I#100=0 W "." I $X>70 W !
	.S TOT=TOT+Y
	.W !?40,Y,?60,"Total KB = ",$P(TOT/1024,"."),!!
	.R ZZZ:0 I  Q
	Q
	;
SIZE	F Z2=0:1 S Z=$O(^XMB(3.9,"B",Z)) Q:Z'[Z1  S XMZ=$O(^(Z,0)) I XMZ DO
	.I Z'[Z3 Q
	.S (I,X,Y)=0
	.F  S X=$O(^XMB(3.9,XMZ,2,X)) Q:X=""  S I=I+1,Y=Y+$L(^(X,0)) I I#100=0 W "." I $X>70 W !
	.S TOT=TOT+Y
	.W !?3,Y,?20,Z,?60,"Total KB = ",$P(TOT/1024,"."),!
	.R ZZZ:0 I  Q
	Q
	;
