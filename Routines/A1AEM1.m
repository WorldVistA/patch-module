A1AEM1	;ISC-Albany/pke - copy message ;6/14/07  16:26
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
MES	;copy mesage into file #11005.1
	N X,Y,A1AERD,AN,GLOBAL,GLOBAL0,RTXT,RSTART,RVER,LINE2
	S A1AERD("A")="Do you want to copy "_$S($D(QMSUB):"'"_QMSUB_"'",1:"a packman message")_" into the Message Text? "
	S A1AERD(1)="Yes^copy a message "_$S($D(QMSUB):"'"_QMSUB_"'",1:" containing "_$P(A1AEPD,"*",1,2))
	S A1AERD(2)="No^Do not copy a message"
	S A1AERD(0)="S"
	S A1AERD("B")=2 D SET^A1AERD K A1AERD
	S A1AEKIDS=0 ;Used to jump in the DIE template
	I X["Y" D ASKS ;Get KIDS message
	I X'["Y" D HFS ;Get HFS message
QMES	K A1AERD,AN,AXMY,GLOBAL,GLOBAL0,RTXT,RSTART,RVER,REND,RVER,MARK,AXMZ,RNAM,QMSUB,QUE
	Q
	;
ASKS	;at this point AXMZ defined will avoid the select question
	N X
	I $D(AXMZ) S QMSUB=$P(^XMB(3.9,AXMZ,0),U) D FND Q
	;this is for AXMZ
	S SHOW=10 D QUE^A1AEM,LOC^A1AEM I '$D(QUE) Q
	I $D(X)<10 W !!?3,"No message in queue has subject containing ",$P(A1AEPD,"*",1,2) Q
	S A1AERD(0)="S",A1AERD("A")="Select Message to copy : "
	D SET^A1AERD
	I X["^" Q
	S AXMZ=X(X),QMSUB=$P(^XMB(3.9,AXMZ,0),U)
FND	W !?5,"Using message '",QMSUB,"'  "
	;
	S RTXT="$TXT Created by",LINE2=""
	;bug in textprint
	S RTXTEND="$END TXT"
	S RSTART="$ROU "
	S REND="$END ROU "
	S GLOBAL="^A1AE(11005.1,"_DA_",2,"
	;
	W "Checking the input .." ;find $txt in case message was edited
	S AZ=0
	F  S AZ=$O(^XMB(3.9,AXMZ,2,AZ)) Q:'AZ  I $D(^(AZ,0)),$E(^(0),1,15)="$TXT Created by" S RTXT(1)=AZ Q
	;
	I '$D(RTXT(1)) DO  D KIL QUIT
	.W !?5,*7,"Input message missing standard text '",RTXT,"'"
	.W !,"           Message NOT copied!!"
	;
	;kids here
	I "XK"[$E($P(^XMB(3.9,AXMZ,0),"^",7)_0) DO  QUIT
	. S $P(^A1AE(11005.1,DA,0),"^",11)=$P(^XMB(3.9,AXMZ,0),"^",7) ;Copy Message type
	. ;
	. D TRASH
	. W !?3,"Merge KIDS message into patch message text",!
	. MERGE ^A1AE(11005.1,DA,2)=^XMB(3.9,AXMZ,2)
	. ;get rid of .00n nodes
	. S AZ=0 F  S AZ=$O(^A1AE(11005.1,DA,2,AZ)) Q:AZ'<1  DO
	. . K ^A1AE(11005.1,DA,2,AZ)
	. ;
	. S A1AEKIDS=1
	. S $P(^A1AE(11005.1,DA,2,0),"^",5)=DT
	. S $P(^A1AE(11005.1,DA,2,0),"^",2)=""
	. S $P(^A1AE(11005.1,DA,0),"^",2,3)=AXMZ_"^"_DT
	. D RTNBLD(DA) ;Build RTN multiple
	. ;If we load from a message get rid of the HFS data.
	. I $D(^A1AE(11005.5,DA,0)) N DIK S DIK="^A1AE(11005.5," D ^DIK
	. Q
	;
	;packman here
	E  DO  I '$D(RSTART) QUIT
	.S $P(^A1AE(11005.1,DA,0),"^",11)="P" ;message type
	.F AZ=RTXT(1):0 S AZ=$O(^XMB(3.9,AXMZ,2,AZ)) Q:'AZ  I $D(^(AZ,0)),$E(^(0),1,5)="$ROU " S:$E(^(0),1,5)=RSTART RSTART(AZ)=^(0) I $E(^(0),1,5)'=RSTART S RSTART(0)=^(0)
	.I $D(RSTART)<10 W *7,"Input message missing '",RSTART,"..'" D KIL Q
	.D TRASH
	.S AN=1,@(GLOBAL_AN_",0)")=^XMB(3.9,AXMZ,2,RTXT(1),0)
	.S AN=2,@(GLOBAL_AN_",0)")=""
	.S AN=3,@(GLOBAL_AN_",0)")="$END TXT"
	.;$o(rstart(0))=1st az  of $rou line in XMB  , A1AE.1 can get offset
	.F AZ=$O(RSTART(0))-1:0 S AZ=$O(^XMB(3.9,AXMZ,2,AZ)) Q:'AZ  I $D(^(AZ,0)) S AN=AN+1,@(GLOBAL_AN_",0)")=^(0)
	.;set zero node
	.I AN>1 S GLOBAL0=GLOBAL_"0)" S $P(@(GLOBAL0),"^",3,5)=AN_"^"_AN_"^"_DT S $P(^A1AE(11005.1,DA,0),U,2,3)=AXMZ_"^"_DT
	.E  W !,?5,*7,"Message not copied "
	S MARK=1
MARK	;this is entered from above and at mark for release of verified
	S AN=1,AP=$P(A1AEPD,"*",3),NV="<<= NOT VERIFIED >"
	S RSTART="$ROU "
	;
CHANG	;
	I "KX"[$E($P($G(^A1AE(11005.1,DA,0)),"^",11)_0) K RVER,FL Q
	I MARK W !?10,"Adding  <<= NOT VERIFIED > to the first line"
	E  W !?10,"Removing  <<= NOT VERIFIED > from the first line"
	;
	F AZ=0:0 S AZ=$O(^A1AE(11005.1,DA,2,AZ)) Q:'AZ  I $D(^(AZ,0)),$E(^(0),1,5)=RSTART S:$D(^A1AE(11005.1,DA,2,AZ+1,0)) FL=^(0) D FL S:$D(FL) ^(0)=FL I MARK S:$D(^A1AE(11005.1,DA,2,AZ+2,0)) RVER=^(0) D CHECK I $D(RVER) S ^(0)=RVER D WR S AZ=AZ+3
	;
KIL	K RVER,AZ,PC,NV,AP,MARK,RNSPACE,LCASE,Y,Y1,RSTART
	Q
	;
WR	W !,$J("line ("_(AZ+2)_")",20),"  ",RVER
	Q
	;
CHECK	;fix for RVER ok check+1
	I $E($G(FL),1,8)="XPDPINIT" K RVER,FL Q
	S ZZN=$S($D(A1AEPD):$P(A1AEPD,"*",3),1:0) I ZZN,$S($F(RVER,"**"_ZZN_"**"):1,$F(RVER,","_ZZN_"**"):1,$F(RVER,","_ZZN_","):1,$F(RVER,"**"_ZZN_","):1,1:0) K RVER Q
	I $L(RVER)>240 W !,*7,"Version line too long to modify " H 2 K RVER Q
	; ;v or ;;v
	;S PC=4 I RVER?1" ;;".E S PC=5
	S PC=4 I $P(RVER," ",2)?1";;".E S PC=5
	I RVER'["**" S $P(RVER,";",PC)="**"_AP_"**" D LST Q
	E  S $P(RVER,"**",2)=$P(RVER,"**",2)_","_AP D LST Q
	W !,"Unable to mark version line '",RVER,"'" K RVER
	Q
	;
LST	I '$F(RVER,";",$F(RVER,"**")) S RVER=RVER_";" Q
	Q
	;
LCASE	; cvrts 2 + % if there
	S Y=$P(LCASE,"$ROU ",2),Y=$E(Y,1,$S($E(Y)'="%":2,1:3)),Y1=Y
	S Y=$TR(Y,"ABCDEFGHIJKLMNOPQRSTUVWXYZ%","abcdefghijklmnopqrstuvwxyz%")
	S LCASE="$ROU "_Y_$P(LCASE,Y1,2) K:'$L(LCASE) LCASE Q
	Q
FL	;1st line
	I 'MARK S FL=$P(FL,NV) Q
	I $E(FL,1,8)="XPDPINIT" W !?10,"Skipping XPDPINIT" Q
	I $L(FL)>240 W !,*7,"First line too long to add '<<= NOT VERIFIED >'" H 2 K FL Q
	I FL[NV Q
	S FL=FL_NV Q
	;
TRASH	;Remove old msg from queue.
	I $D(^A1AE(11005.1,DA,0)),$P(^(0),"^",2),$P(^(0),"^",2)'=AXMZ DO
	.N AXMZ S AXMZ=$P(^(0),"^",2) D TRASH^A1AEM
	.W !?3,"Removing old message from que"
	;
	W "   Deleting old text .."
	;S AZ=0 F  S AZ=$O(@(GLOBAL_AZ_")")) Q:'AZ  K ^(AZ)
	K ^A1AE(11005.1,DA,2) Q
	;
RTNBLD(A1AEDA)	;Build Routine multiple
	N FDA,IEN,A1,A2,A3,A4,DIK,DA
	;Load
	S A1=1,LINE2=""
	F  S A1=$O(^A1AE(11005.1,A1AEDA,2,A1)) Q:'A1  I $E(^(A1,0),1,5)="""RTN""" Q
	Q:'A1  ;At start of routines.
	K ^TMP("A1AE",$J)
	S A1=$O(^A1AE(11005.1,A1AEDA,2,A1))
	F  S A1=$O(^A1AE(11005.1,A1AEDA,2,A1)) Q:'A1  D
	. S X=^A1AE(11005.1,A1AEDA,2,A1,0) I $E(X,2,4)'="RTN" S A1=" " Q
	. S A1=$O(^A1AE(11005.1,A1AEDA,2,A1)),Y=^(A1,0)
	. S @("^TMP(""A1AE"",$J,"_X)=Y ;Build global
	. Q
	S A1="",A3=0
	F  S A1=$O(^TMP("A1AE",$J,"RTN",A1)) Q:A1=""  S A2=^(A1) D
	. S A4=$G(^TMP("A1AE",$J,"RTN",A1,2,0)) S:'$L(LINE2) LINE2=A4 S A4=$P(A4,";",5)
	. ;.01 RTN name, 3 RSUM, 4 Patch List, 5 Old Rsum - set at Release
	. S A3=A3+1,IEN="?+"_A3_","_A1AEDA_",",FDA(11005.03,IEN,.01)=A1
	. S FDA(11005.03,IEN,3)=$S(+A2:"Delete",1:$P(A2,"^",3)) ;Only set if sending routine
	. S FDA(11005.03,IEN,4)=A4
	. I A3>99 D UPDATE^DIE("","FDA") S A3=0 K FDA
	. Q
	I A3 D UPDATE^DIE("","FDA")
	I $L(LINE2) S ^A1AE(11005,A1AEDA,"P2")=$P(LINE2,";",1,4)_";**[Patch List]**;"_$P(LINE2,";",6,99)
	;Remove Unused ROUTINE's from multiple
	D RTNREM
	K ^TMP("A1AE",$J)
	Q
	;
RTNREM	;Remove routines from the Routine multipule
	;Will not remove a routine name in ^TMP("A1AE",$J,"RTN",name)
	N DIK,DA
	S DIK="^A1AE(11005,"_A1AEDA_",""P"",",DA(1)=A1AEDA,DA=0
	F  S DA=$O(^A1AE(11005,DA(1),"P",DA)) Q:'DA  S A1=$P($G(^(DA,0)),U) I '$D(^TMP("A1AE",$J,"RTN",A1)) D ^DIK
	Q
HFS	;
	N X,MZ
	S X=$G(^A1AE(11005.5,DA,0)),MZ=$G(^XMB(3.9,+$P(X,U,2),0))
	Q:'$L(X)
	I MZ="" S $P(MZ,U,2)=$P(X,U,5),$P(MZ,U,3)=$$FMTE^XLFDT($P(X,U,3))
	W !,"Want to copy HFS cache,",!,"  From: ",$P(MZ,U,2),!,"    On: ",$P(MZ,U,3)
	S A1AERD("A")="Do you want to copy Routine Names and Checksums from the HFS cache file. "
	S A1AERD(1)="Yes^Copy Routine Names and Checksums."
	S A1AERD(2)="No^Do not copy Routine data."
	S A1AERD(0)="S"
	S A1AERD("B")=$S($D(^A1AE(11005.1,DA,0)):2,1:1) D SET^A1AERD
	I X["Y" D HFS2(DA)
	Q
	;
HFS2(A1AEDA)	;Move Routine Info from HFS file to Routine sub-file.
	N A1,A2,A3,FDA,DA,IEN,DIK
	S A1AEKIDS=1 ;Can skip Routine multiple
	;Remove any Message Text
	;S DA=A1AEDA,DIK="^A1AE(11005.1," D ^DIK
	K ^A1AE(11005.1,A1AEDA,2)
	;Clear out any current Routine data
	K ^TMP("A1AE",$J)
	D RTNREM
	;.01 RTN name, 3 RSUM, 4 Patch List
	;^A1AE(11005.5,DA(1),1,DA,0)= RTN name^Send^^Checksum^Patch List
	;MOVE
	S A1=0,A3=0
	F  S A1=$O(^A1AE(11005.5,A1AEDA,1,A1)) Q:'A1  S A2=$G(^(A1,0)) D
	. S A3=A3+1,IEN="?+"_A1_","_A1AEDA_","
	. S FDA(11005.03,IEN,.01)=$P(A2,U),FDA(11005.03,IEN,3)=$S($P(A1,U,2):"Delete",1:$P(A2,U,4))
	. S FDA(11005.03,IEN,4)=$P(A2,U,5)
	. I A3>99 D UPDATE^DIE("","FDA") S A3=0 K FDA
	. Q
	I A3 D UPDATE^DIE("","FDA") K FDA
	W !,"Routine Name's and Checksums moved."
	Q
