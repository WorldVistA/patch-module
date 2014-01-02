A1AECOPR	;ISC-Albany/pke-copy routines into routine text ;5/1/90
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;12/02/92
	S A1AEROU=X
EN	S SAVEX=X
	;
ASK	S A1AERD("A")="Copy routine lines from a packman message into the description? "
	S A1AERD(1)="Yes^select a message, subject contains "_$P(A1AEPD,"*",1,2)
	S A1AERD(2)="No^not copy any messages ",A1AERD("B")=2
	S A1AERD(0)="S"
	D SET^A1AERD K A1AERD D ASKS:"Y"[$E(X,1)
	;
	D Q^A1AECOPD Q
ASKS	;
	I $D(AXMZ) S QMSUB=$P(^XMB(3.9,AXMZ,0),U) D FND Q
	;
	S SHOW=10 D QUE^A1AEM,LOC^A1AEM I '$D(QUE) Q
	I $D(X)<10 W !!?3,"No message in queue has subject containing ",$P(A1AEPD,"*",1,2) Q
	S A1AERD(0)="S",A1AERD("A")="Select Message to copy : "
	D SET^A1AERD
	I X["^" Q
	S AXMZ=X(X),QMSUB=$P(^XMB(3.9,AXMZ,0),U)
	Q:'$D(AXMZ)
FND	D FCOPY^A1AEM I '$D(RNAM) W !!?3,"Routine '",A1AEROU,"' not found in message '",QMSUB,"'" Q
	K A1AERD D ASKLIN
	Q
	;
ASKLIN	S IOP="HOME" D ^%ZIS K IOP S A1AERD("A")="from" W ! D LINE Q:X="^"!(X="")  S A1AEFRLN=A1AELINE,A1AERD("A")="through",A1AERD("B")=$S(A1AEOFF:X_"+"_A1AEOFF,1:X) D LINE Q:X="^"  S A1AETOLN=$S(X="":A1AEFRLN,1:A1AELINE) K A1AERD
	;
	D SETUTI,ASKCOP:$D(^UTILITY($J,"A1AECP")) W:'$D(^UTILITY($J,"A1AECP")) !?3,"...No lines to copy"
	Q
	;
LINE	W !?2,"Copy ",A1AERD("A")," line: " W:$D(A1AERD("B")) A1AERD("B")_"// " R X:DTIME S:'$T X="^" Q:X="^"!(X="")  I X["?" W !?3,"Enter line to copy ",A1AERD("A") G LINE
	S A1AEOFF=+$P(X,"+",2) I X["+",'A1AEOFF W !?3,*7,"Line offset should be a numeric value" G LINE
B	S X=$P(X,"+",1) I '(X?1U.UN!(X?1"%".UN)!(X?1N.N))!($L(X)>8) W !?3,*7,"Line label should be 1-8 characters" G LINE
	S FIND=0 F AZ=$P(RNAM,U,2):0:$P(RNAM,U,3) S AZ=$O(^XMB(3.9,AXMZ,2,AZ)) Q:'AZ  I $D(^(AZ,0)),$L($P(^(0)," ")),$P(^(0)," ")=X S FIND=AZ,A1AELINE=AZ+A1AEOFF-1 Q
	I 'FIND W !?3,*7,"Line label ",X," not found in ",A1AEROU K FIND G LINE
	;
	S FIND1=1 I A1AEOFF F AZ=FIND:0:A1AELINE+A1AEOFF S AZ=$O(^XMB(3.9,AXMZ,2,AZ)) Q:'AZ  I $D(^(AZ,0)),'$L($P(^(0)," ",2)) S FIND1=0 Q
	I 'FIND1,A1AEOFF W !?3,*7,"Line ",X,"+",A1AEOFF," not found in ",A1AEROU K FIND1 G LINE
	;
	I $D(A1AEFRLN),A1AELINE<A1AEFRLN W !?3,*7,"Line copying through precedes line copying from" G LINE
	Q
	;
SETUTI	K ^UTILITY($J,"A1AECP") S A1AELNCT=0 F AZ=A1AEFRLN:0:A1AETOLN S AZ=$O(^XMB(3.9,AXMZ,2,AZ)) Q:'AZ  I $D(^(AZ,0)) S A1AELNCT=A1AELNCT+1,^UTILITY($J,"A1AECP",A1AELNCT)=$S("$TXT$ROU$END"'[$E(^(0),1,4):^(0),1:"xxxx"_$E(^(0),5,245))
	Q
	;
ASKCOP	W ! F A1AELNB=1:1:A1AELNCT I $D(^UTILITY($J,"A1AECP",A1AELNB)) W !,A1AELNB,"> ",^(A1AELNB)
	S A1AERD("A")="Do you want to copy "_$S(A1AELNCT=1:"this line",1:"these "_A1AELNCT_" lines")_"? "
	S A1AERD(0)="S",A1AERD(1)="Yes^copy these lines into the routine description",A1AERD(2)="No^not copy these lines",A1AERD("B")=2 D SET^A1AERD K A1AERD Q:X="^"  ;;;!("N"[$E(X,1))
	I "nN"[$E(X,1) G ASKLIN
	S A1AEBOT=$S($D(^A1AE(11005,DA(1),"P",DA,"D",0)):$P(^(0),"^",3),1:0),A1AELNIN=0 D INSERT:A1AEBOT,COPY:'A1AEBOT
	Q
	;
INSERT	R !!,"Insert code after what description line: ",X:DTIME Q:'$T!(X="^")  I X<0!(X>A1AEBOT)!(X'?1N.N)!(X["?") G HELP
	S A1AELNIN=X I A1AELNIN<A1AEBOT S A1AEFRLN=A1AEBOT+A1AELNCT,A1AETOLN=A1AELNIN+1+A1AELNCT F I=A1AEFRLN:-1:A1AETOLN S ^A1AE(11005,DA(1),"P",DA,"D",I,0)=^A1AE(11005,DA(1),"P",DA,"D",(I-A1AELNCT),0)
A	D COPY
	Q
	;
HELP	I X["??" W @IOF F I=0:0 S I=+$O(^A1AE(11005,DA(1),"P",DA,"D",I)) Q:'I  W !,I,"> ",^(I,0) I ($Y+6)>IOSL D CRCHK Q:X1="^"  W @IOF
	I X'["??" W:X'["?" *7 W !!?3,"Enter a line number between 0 and ",A1AEBOT,", or",!?3,"'??' to list current description."
	G INSERT
	;
COPY	S A1AELNB=0,A1AEFRLN=A1AELNIN+1,A1AETOLN=A1AELNIN+A1AELNCT F I=A1AEFRLN:1:A1AETOLN S A1AELNB=A1AELNB+1,^A1AE(11005,DA(1),"P",DA,"D",I,0)=^UTILITY($J,"A1AECP",A1AELNB) I ^(0)["|" S A1AEWFLG=""
	S:'$D(^A1AE(11005,DA(1),"P",DA,"D",0)) ^(0)="" S $P(^A1AE(11005,DA(1),"P",DA,"D",0),"^",3)=A1AEBOT+A1AELNCT
	Q
	;
CRCHK	I $E(IOST,1)="C" W !!,*7,"Press RETURN to continue or '^' to stop " R X1:DTIME
	Q
