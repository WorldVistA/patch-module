A1AEPHS	; RMO,MJK/ALBANY - Logic from DD, U triggers test Message ;2014-03-28  5:23 PM
	;;2.4;PATCH MODULE;;Mar 28, 2014;Build 8
	;
	;logic from dd,  U triggers test MESSAGE if underdevlopment
	;I A1AEOLD="c","Uu"'[$E(X_0,1) Q  ;allow c=>u in template
	Q:'$D(X)
	S A1AEOLD=$P(^A1AE(11005,DA,0),U,8),A1AEPKIF=$P(^(0),U,2)
	N DIERR ; VEN/SMH - Don't allow DIERR to leak back to DBS Fileman calls
	K TESTMES
	I "Uu"[$E(X_0,1),A1AEOLD="u" S X="u",TESTMES=1
	I A1AEOLD=$E(X,1),X'="u" Q  ;only allow u=>u if u/U entered
	;
	I '($D(DUZ)#2) W !?3,"Your user code (DUZ) must be defined to change the status of a patch." K X G Q
	N A1AE0,A1AEDA ;rwf
	S A1AEDA=DA,A1AE0=$S($D(^A1AE(11005,DA,0)):^(0),1:""),A1AENEW=$E(X,1),A1AEOLD=$C($A(A1AEOLD)-32)
	S A1AEOPT=$S(A1AENEW="c":"'Completed/NotReleased'",A1AENEW="v":"'Released'",A1AENEW="e":"'Entered in Error'",A1AENEW="r":"'Retired'",A1AENEW="x":"'Canceled'",1:"")
	;U, C, V branch here
	I A1AEOLD="U"!(A1AEOLD="C")!(A1AEOLD="V") D @A1AEOLD G Q
	;E, R branch here
	I A1AEOLD="E"!(A1AEOLD="R") D ER G Q
	;others fall thru
NEW	I A1AENEW'="u" W !?3,"The status of a new patch may only be entered as 'U'nder development!" K X G Q
	I '$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0)) W !?3,"You are not an authorized developer of this package." K X
	;
Q	K A1AEOLD,A1AENEW,A1AEOPT,A1AEX
	I $G(TESTMES) K TESTMES S X="u"
	Q
U	I "cx"'[A1AENEW,'$G(TESTMES) W !?3,"The status may only be changed to 'C'ompleted/not released  or Canceled!" K X Q
	I '$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0)) W !?3,"You are not an authorized developer of this package." K X Q
	I A1AENEW="c",$P(^A1AE(11005,DA,0),"^",9)=DUZ,'$G(TESTMES) W !?3,"Please have another developer of the package review the patch and change",!?3,"the status to 'C'ompleted/not released." K X Q
	I '$G(TESTMES) D ASKCHG Q:X'=A1AEX  S SEQ="" D GET^A1AEMAL I '$D(XMZ) K X Q
	I $G(TESTMES) D ASKTST Q:$D(DUOUT)!($D(DTOUT))!('Y)  S SEQ="" D GET^A1AEMAL I '$D(XMZ) K X Q
	D MES^A1AEMAL I $G(TESTMES) DO  Q
	.K TESTMES,TVER,TXVER,SAVX,SEQ,XMY S X="u"
	I A1AENEW="x" Q  ;Canceled exit here
	K SEQ,XMY
	F I=0:0 S I=$O(^A1AE(11007,A1AEPKIF,"PB",I)) Q:'I  I $D(^(I,0)),$P(^(0),"^",2)="V" S XMY(I)=""
	S XMY(DUZ)=""
	D BUL
	Q
	;
C	I A1AENEW="u" G NEW
	I A1AENEW'="v" W !?3,"The status may only be changed to 'V' Released!" K X Q
	I '$D(^A1AE(11007,A1AEPKIF,"PB",DUZ,0)) W !?3,"You are not authorized to release patches of this package." K X Q
	I $D(^A1AE(11007,A1AEPKIF,"PB",DUZ,0)),$P(^(0),"^",2)'="V" W !?3,"You are not authorized to release patches of this package." K X Q
	I $P(^A1AE(11005,DA,0),"^",9)=DUZ!($P(^(0),"^",13)=DUZ) W !?3,"Please have an authorized releaser, other than the developer",!?3,"who entered the patch or completed the patch, release the",!?3,"patch." K X Q
	;naked ref to this patch above .. hold date check
	S A1AEVR=$P(^(0),"^",3),Y=$P(^(0),"^",17) I Y>DT DO
	.W !?3,"This patch cannot be 'V'erified/released until: " D DT^DIQ K X
	;naked ref to same entry above
	I $D(^("Q","B")) S CHECK="" D PCHK^A1AEUTL1 K CHECK I $D(AZ("STOP")) DO  K AZ,X
	.W !?3,"This patch cannot be 'V'erified/released before patch(s):"
	.S AZ=0 F  S AZ=$O(AZ("STOP",AZ)) Q:'AZ  W:$X>60 !,?62 W ?62,$P(AZ("STOP",AZ),"^")
	I '$D(X) W $C(7) K A1AEVR Q
	;
	;check for Patch message sent/but disconnect blew away 'v'status
	I $P($G(^A1AE(11005.1,DA,0)),"^",6),$P($G(^(0)),"^",7),A1AENEW="v" D NOMESS^A1AEMAL1 K A1AEVR Q
	;
	D ASKCHG I X'=A1AEX K A1AEVR Q
	I '$D(A1AEPKV) D SEQ^A1AEUTL
	;See if we can get a Mail Message
	K XMZ
	D GET^A1AEMAL I '$D(XMZ) D DELSEQ^A1AEUTL K X
	I '$D(X) K A1AEVR Q
	;Build Mail Message
	D MES^A1AEMAL
	;After building message, update version #
	D NEWVER^A1AEUTL(A1AEPKIF,DA)
	;
BOTH	;Send Bulletin, Called from C and V. Setup address list
	K A1AEVR,SEQ,XMY
	N A1AETO,XMBTMP
	D INIT^XMXADDR
	S A1AETO=0
	I '$D(A1AEPKV) D
	. F  S A1AETO=$O(^A1AE(11007,A1AEPKIF,1,A1AETO)) Q:'A1AETO  D ADDRESS^XMXADDR(DUZ,A1AETO)
	I $D(A1AEPKV) D ADDRESS^XMXADDR(DUZ,"G.A1AE PACKAGE RELEASE")
	S XMBTMP=1,XMY(DUZ)=""
	D BUL
	Q
V	;
	I A1AENEW'="e",A1AENEW'="r"!($P(A1AE0,"^",3)'=999) W !?3,"The status may only be changed to 'E'ntered in error, or",!?3,"if it is a DBA type patch it can be 'R'etired!" K X Q
	I '$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0)) W !?3,"You are not an authorized developer of this package." K X Q
	D ASKCHG I X'=A1AEX Q
	I A1AENEW'="e" D BOTH Q
	N X
	; The bulletin for "entered in error" will be sent in 3^A1AEPH1,
	; after the developer has entered the error description.
	W !!,"Next, you will be asked for the 'Entered in Error Description'."
	W !,"Whatever you write will be included in the bulletin which will be sent"
	W !,"to all patch recipients, so make sure your description is complete.",!
	D WAIT^XMXUTIL
	Q
	;
ER	W !?3,"Once the status has been set to 'E'ntered in error or 'R'etired it can not be changed!" K X Q
	;
ASKCHG	I $D(DIFM) S A1AEX=X QUIT  ; If we are inside the DBS, don't ask... VEN/SMH...
	       S A1AEX=X,A1AERD("A")="Are you sure you want to change status to "_A1AEOPT_"? ",A1AERD(0)="S",A1AERD(1)="Yes^change status and send a message to users",A1AERD(2)="No^leave the status the same",A1AERD("B")=2
	D SET^A1AERD K A1AERD S X=$S("Y"[$E(X,1):A1AEX,1:$C($A(A1AEOLD)+32)) W !?3,"...status ",$S(A1AEX=X:"",1:"'not' "),"changed to ",A1AEOPT
	Q
	;
BUL	;
	N X,XMTEXT,A1AEX
	S XMTEXT="A1AETX(",XMB="A1AE "_$S(A1AENEW="c":"COMPLETED",A1AENEW="v":"VERIFIED",A1AENEW="e":"ENTERED IN ERROR",A1AENEW="r":"RETIRED",1:"")_" PATCH"
	S A1AEX=$P($G(^A1AE(11005,DA,4)),U) I $L(A1AEX)>2 S XMB=$P(XMB,"PATCH")_"PACKAGE" ;rwf
	S XMB(1)=$P(^DIC(9.4,+$P(A1AE0,"^",2),0),"^",1),XMB(2)=$P(A1AE0,"^",1),XMB(3)=$P(A1AE0,"^",5)
	I A1AENEW="c"!(A1AENEW="v") S XMB(4)=$P($P(^DD(11005,7,0),$P(A1AE0,"^",7)_":",2),";",1)
	I A1AENEW'="v" S:$D(A1AESUB) XMB(6)=A1AESUB S:$D(A1AEXMZ) XMB(5)=A1AEXMZ
	S $P(XMB(2),"*",2)=$S($P(XMB(2),"*",2)=999:"DBA",1:$P(XMB(2),"*",2))
	S XMB(7)="" I $D(^A1AE(11005,"AC",+$P(A1AE0,"^",2),+$P(A1AE0,"^",3),"pp",+$P(A1AE0,"^",4))) S XMB(7)=" Category of Patch: PATCH FOR A PATCH"
	S (XMB(8),XMB(9))="" I A1AENEW="v" S Y=$O(^A1AE(11005,"B",$P(A1AE0,"^",1),0)),Y=$P(^A1AE(11005,Y,0),"^",18) D DD^%DT S XMB(9)="be installed by "_Y_" in compliance with Directive 2001-23."
	S:XMB(9)'="" XMB(8)="Unless otherwise indicated in the patch description, this patch should"
	I $L(A1AEX)>2 S XMB(2)=$P(A1AEX,U) ;rwf
	D M^A1AEUTL1
	W !!,"NOTE: A bulletin has been sent to ",$S(A1AENEW="c":"the CS Team",A1AENEW="v":"select users",A1AENEW="e"!(A1AENEW="r"):"users who have viewed this patch",1:"")
	;W:A1AENEW="v" " Team"
	W:A1AENEW="c"!(A1AENEW="v") " for this package" W !?6,"informing them of this ",A1AEOPT," patch.",!
	I "^e^v^"[(U_A1AENEW_U) D ESSMSG
	Q
ESSMSG	; Send message to Remedy to let it know that a patch has been
	; released or entered-in-error
	N XMTEXT,XMINSTR,STAT,PID,PRI,REL,COMP,I,CAT,%
	S PID=$P(A1AE0,U,1) I $P(PID,"*",2)=999 S $P(PID,"*",2)="DBA" ; Patch ID
	S:$L($G(A1AEX))>2 PID=A1AEX ;rwf
	S REL=$$FMTE^XLFDT(DT,"5Z") ; Release Date
	I A1AENEW="e" D
	. S STAT=2 ; Entered-in-Error
	. S (PRI,COMP,CAT)=""
	E  D
	. S STAT=3 ; Released
	. S COMP=$$FMTE^XLFDT($P(A1AE0,U,18),"5Z") ; Install by Date
	. S PRI=$P(A1AE0,U,7) ; Priority
	. S I=0,CAT=""
	. F  S I=$O(^A1AE(11005,+$G(DA),"C",I)) Q:'I  S CAT=CAT_","_^(I,0) ; Category
	. S CAT=$E(CAT,2,999)
	S XMTEXT(1)=STAT_$$LJ^XLFSTR(PID,30)_$$LJ^XLFSTR("",30)_$$LJ^XLFSTR(REL,22)_$$LJ^XLFSTR(COMP,22)_PRI_$$LJ^XLFSTR(CAT,23)
	S XMINSTR("FROM")="POSTMASTER"
	D SENDMSG^XMXAPI(DUZ,"NPM/ESS Transaction","XMTEXT","G.A1AE PACKAGE RELEASE@FORUM.OSEHRA.ORG",.XMINSTR) ; VEN/SMH - changed.
	Q
	;
ASKTST	Q:'$D(^A1AE(11005.1,DA,0))
	W !!,?3,"Option to create a Patch message to send to test sites."
	S INXMZ=$P(^(0),"^",2)
	;S XMZ=$P(^(0),"^",8)
	S TVER=$P(^(0),"^",12)+1
	;
	;I XMZ DO  I $D(DUOUT)!($D(DTOUT))!('Y) Q
	;.W ! S DIR(0)="Y",DIR("B")="No"
	;.S DIR("A")="Add additional recipients "
	;.D ^DIR K DIR
	;
	;develope/test
	I 'INXMZ DO  I $D(DUOUT)!($D(DTOUT))!('Y) Q
	.W ! S DIR(0)="Y",DIR("B")="No"
	.S DIR("A")="This Patch has no routines, do you wish to continue "
	.D ^DIR K DIR
	;
	;save ADTM for the timestamp in 11005.1
	D NOW^%DTC S (ADTM,Y)=% D TM^A1AEUTL1
	S TXVER="TEST v"_TVER
	W !?3,TXVER
	W ?$X+3,"will be added to the Patch message subject."
	S DIR(0)="NO^1:99"
	S DIR("B")=TVER
	S DIR("A")="You may change the TEST v[#] if necessary."
	W ! D ^DIR K DIR
	I $D(DUOUT)!($D(DTOUT))!('Y) Q
	;
	I Y'=TVER DO  I $D(DUOUT)!($D(DTOUT))!('Y) Q
	.;only if they change it if not sure start over
	.S TVER=Y,TXVER="TEST v"_TVER_$P(TXVER," ",3)
	.S DIR(0)="Y",DIR("B")="NO"
	.S DIR("A")="Are you sure you want to change Test version to `TEST V"_TVER_"' "
	.D ^DIR K DIR
	;
	Q
XM	I '$D(XMDUZ) S XMDUZ=DUZ
	S XMDUN=$P(^VA(200,XMDUZ,0),U),(XMKN,XMLOCK)="",XMK=0 Q
