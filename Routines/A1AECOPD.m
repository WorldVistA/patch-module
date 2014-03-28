A1AECOPD	;ISC-Albany/pke-copy message into patch description ;2014-03-28  5:31 PM
	;;2.4;PATCH MODULE;;Mar 28, 2014;Build 8
	;
EN	N X,Y
	I $P(^A1AE(11007,$O(^DIC(9.4,"C",$P(A1AEPD,"*"),0)),0),U,5)'="y" Q
ASK	S A1AERD("A")="Do you want to copy lines from a message into the Patch Description? "
	S A1AERD(1)="Yes^select a message, subject contains "_$P(A1AEPD,"*",1,2)
	S A1AERD(2)="No^not copy any messages ",A1AERD("B")=2
	S A1AERD(0)="S"
	D SET^A1AERD K A1AERD D ASKS:"Y"[$E(X,1)
	;
Q	W ! K QUE,A1AEROU,^UTILITY($J,"A1AECP"),A1AELINE,A1AEFRLN,A1AETOLN,A1AEOFF,A1AEBLK,A1AEPGLN,A1AELNCT,A1AELNB,A1AELNIN,A1AEBOT,A1AENMSP,A1AEWFLG
	K AFIND
	Q
ASKS	;AXMZ
	I $D(AXMZ) S QMSUB=$P(^XMB(3.9,AXMZ,0),U) D FND Q
	;this is for axmz
	S SHOW=10 D QUE^A1AEM,LOC^A1AEM I '$D(QUE) Q
	I $D(X)<10 W !!?3,"No message in queue has subject containing ",$P(A1AEPD,"*",1,2) Q
	S A1AERD(0)="S",A1AERD("A")="Select Message to copy : "
	D SET^A1AERD
	I X["^" Q
	S AXMZ=X(X),QMSUB=$P(^XMB(3.9,AXMZ,0),U)
	Q:'$D(AXMZ)
FND	K A1AERD D ASKLIN
	Q
	;
ASKLIN	S IOP="HOME" D ^%ZIS K IOP S A1AERD("A")="from" W ! D LINE Q:X="^"!(X="")  S A1AEFRLN=A1AELINE,A1AERD("A")="through",A1AERD("B")=A1AELINE+1 D LINE Q:X="^"  S A1AETOLN=A1AELINE K A1AERD
	;
	D SETUTI,ASKCOP:$D(^UTILITY($J,"A1AECP")) W:'$D(^UTILITY($J,"A1AECP")) !?3,"...No lines to copy"
	Q
	;
LINE	W !?2,"Copy ",A1AERD("A")," line: " W:$D(A1AERD("B")) A1AERD("B")_"// " R X:DTIME S:'$T X="^" Q:X="^"!(X="")  I X["?" W !?3,"Enter line to copy ",A1AERD("A")_$S(A1AERD("A")'["th":"",1:" or 'ALL'") G LINE
	I 'X,"ALLall"'[$E(X_0,1,3)!(A1AERD("A")["fr") W !?3,*7,"Enter numeric line number" G LINE
LINESIL	S (AFIND,FIND)=0 F AZ=.9999999:0 S AZ=$O(^XMB(3.9,AXMZ,2,AZ)) Q:'AZ  S AFIND=AZ I $D(^(AZ,0)),AZ=X!($E(^(0),1,8)="$END TXT") S FIND=AZ,A1AELINE=AZ-1 S:$E(^(0),1,8)="$END TXT" A1AELINE=AZ-2 S AFIND=0 Q
	I "ALLall"[$E(X_0,1,3),'FIND,AFIND S A1AELINE=AFIND-1
	E  I 'FIND,X,AFIND,AFIND<X S A1AELINE=AFIND-1
	E  I 'FIND W !?3,*7,"Line ",X," not found in " K FIND G LINE
	;
	I $D(A1AEFRLN),A1AELINE<A1AEFRLN W !?3,*7,"Line copying through precedes line copying from" G LINE
	Q
	;
SETUTI	K ^UTILITY($J,"A1AECP") S A1AELNCT=0
	F AZ=$S(A1AEFRLN<1:.99,1:A1AEFRLN):0:A1AETOLN S AZ=$O(^XMB(3.9,AXMZ,2,AZ)) Q:'AZ  I $D(^(AZ,0)) S A1AELNCT=A1AELNCT+1,^UTILITY($J,"A1AECP",A1AELNCT)=^(0)
	Q
	;cc
ASKCOP	W ! F A1AELNB=1:1:A1AELNCT I $D(^UTILITY($J,"A1AECP",A1AELNB)) W !,A1AELNB,"> ",^(A1AELNB)
	S A1AERD("A")="Do you want to copy "_$S(A1AELNCT=1:"this line",1:"these "_A1AELNCT_" lines")_"? "
	S A1AERD(0)="S",A1AERD(1)="Yes^copy these lines into the patch description",A1AERD(2)="No^not copy these lines",A1AERD("B")=2 D SET^A1AERD K A1AERD Q:X="^"  ;;;!("N"[$E(X,1))
	I "nN"[$E(X,1) G ASKLIN
	S A1AEBOT=$S($D(^A1AE(11005,DA,"D",0)):$P(^(0),"^",3),1:0),A1AELNIN=0 D INSERT:A1AEBOT,COPY:'A1AEBOT
	Q
	;
INSERT	R !!,"Insert code after what description line: ",X:DTIME Q:'$T!(X="^")  I X<0!(X>A1AEBOT)!(X'?1N.N)!(X["?") G HELP
	S A1AELNIN=X I A1AELNIN<A1AEBOT S A1AEFRLN=A1AEBOT+A1AELNCT,A1AETOLN=A1AELNIN+1+A1AELNCT F I=A1AEFRLN:-1:A1AETOLN S ^A1AE(11005,DA,"D",I,0)=^A1AE(11005,DA,"D",(I-A1AELNCT),0)
A	D COPY
	Q
	;
HELP	I X["??" W @IOF F I=0:0 S I=+$O(^A1AE(11005,DA,"D",I)) Q:'I  W !,I,"> ",^(I,0) I ($Y+6)>IOSL D CRCHK Q:X1="^"  W @IOF
	I X'["??" W:X'["?" *7 W !!?3,"Enter a line number between 0 and ",A1AEBOT,", or",!?3,"'??' to list current description."
	G INSERT
	;
COPY	S A1AELNB=0,A1AEFRLN=A1AELNIN+1,A1AETOLN=A1AELNIN+A1AELNCT F I=A1AEFRLN:1:A1AETOLN S A1AELNB=A1AELNB+1,^A1AE(11005,DA,"D",I,0)=^UTILITY($J,"A1AECP",A1AELNB) I ^(0)["|" S A1AEWFLG=""
	S:'$D(^A1AE(11005,DA,"D",0)) ^(0)="" S $P(^A1AE(11005,DA,"D",0),"^",3)=A1AEBOT+A1AELNCT
	Q
	;
CRCHK	I $E(IOST,1)="C" W !!,*7,"Press RETURN to continue or '^' to stop " R X1:DTIME
	Q
