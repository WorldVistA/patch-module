A1AEM2	;ISC-Albany/pke-forward a patch message ; 4/15/90
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;12/02/92
	;change FCOM,FVER dic 11005.1 ,scrn lookup
RCHK	;input transform on routine name x
	Q:'$D(A1AEPD)  S:'$D(TAB) TAB=42
	N VERS,APD,BEEP,AZ
	S APD=A1AEPD,VERS=$P(APD,"*",2) I VERS="DBA" S VERS=999,$P(APD,"*",2)=999
	S BEEP=" routine has previous Patches: "_$C(7)
	F AZ=0:0 S AZ=$O(^A1AE(11005,"R",X,AZ)) Q:'AZ  I $D(^A1AE(11005,AZ,0)),$P($P(^(0),"^"),"*",2)[VERS,$P(^(0),"^")'=APD DO
WR	.I $D(BEEP) W !!,"'",X,"'",BEEP,?TAB K BEEP
	.I $X>TAB W ", "
	.W "(",$TR($P(^(0),"^",8),"ucver","ucver"),")",$P(^(0),"^")
	.I $X>65 W !?TAB-1
	I '$D(BEEP) W !
	Q
FCOM	;
	S PXMZ=4 D DICC,PAT
	G Q
FVER	;
	S PXMZ=6 D DICV,PAT
	G Q
Q	K PXMZ,XMZ,A1AEIFN,DIC,A1AEPD,Y D KILL^XM
	Q
	;duz,xmz,xmy(), xmdun,xmduz ;;;Change lookup to 11005.1 dinum
PAT	;
	S DIC("A")="Select PATCH to forward: "
	S DIC="^A1AE(11005.1,",DIC(0)="AEMQ"
	;S DIC("S")="I $P(^A1AE(11005,+Y,0),U,8)'=""e"""
	S DIC("S")="I $P(^A1AE(11005,+Y,0),U,8)=$S(PXMZ=4:""c"",1:""v"")"
	D ^DIC K DIC Q:Y<0
	S A1AEIFN=+Y,A1AEPD=$P(^A1AE(11005,+Y,0),U,1)
	I $P(A1AEPD,"*",2)=999 S $P(A1AEPD,"*",2)="DBA"
	S XMZ=$P($G(^A1AE(11005.1,A1AEIFN,0)),U,PXMZ)
	I 'XMZ W !?8,"No message available" G PAT
	I '$D(^XMB(3.9,XMZ,0)) D  G:'$D(XMZ) PAT
	. N A1AERCR8,SAVX,X,A1AENEW,SEQ,D0,DA
	. W !,$C(7),"The message no longer exists."
	. K XMZ
	. I $P(^A1AE(11005,A1AEIFN,0),U,8)'="v" D  Q
	. . W !,"That patch is not released."
	. . W !,"We only create new messages for released patches."
	. W !,"That's OK - we'll create a new one.  This won't take long."
	. S A1AERCR8=1 ; Indicates that we are recreating a message.
	. S DA=A1AEIFN,(A1AENEW,SAVX)="v"
	. D EN^A1AEMAL Q:'$D(XMZ)
	. D MES^A1AEMAL
	;Ask Rcpts / XMDF means programmer call MailMan ignores KSP limits
	D XM
	N XMDF
	D DEST^XMA21 Q:$D(XMOUT)  ; Don't forward to closed domains
	D ENT1^XMD W !?8,"Message ",XMZ," has been forwarded."
	Q
XM	;
	I '$D(XMDUZ) S XMDUZ=DUZ
	S XMDUN=$P(^VA(200,XMDUZ,0),U)
	Q
DICC	; Completed/Unverified ;;;change screen to 11005.1
	;S DIC("S")="I $P(^(0),U,8)=""c"",$S($D(^A1AE(11007,+$P(^(0),U,2),""PH"",DUZ,0)):1,'$D(^A1AE(11007,+$P(^A1AE(11005,+Y,0),U,2),""PB"",DUZ,0)):0,$P(^(0),U,2)=""V"":1,1:0)"
	S DIC("S")="I $P(^(0),U,PXMZ),$S($D(^A1AE(11007,+$P(^A1AE(11005,+Y,0),U,2),""PH"",DUZ,0)):1,'$D(^A1AE(11007,+$P(^A1AE(11005,+Y,0),U,2),""PB"",DUZ,0)):0,$P(^(0),U,2)=""V"":1,1:0)"
	Q
DICV	; Verified Patch ;;; change screen to 11005.1
	;S DIC("S")="I ($P(^(0),U,8)=""v"")&($S('$D(^A1AE(11007,+$P(^(0),U,2),0)):0,$P(^(0),U,2)=""Y"":1,$P(^(0),U,4)=""y""&($D(^A1AE(11007,""AU"",DUZ,+$P(^A1AE(11005,+Y,0),U,2)))):1,1:0))"
	S DIC("S")="I $P(^(0),U,PXMZ),$S('$D(^A1AE(11007,+$P(^A1AE(11005,+Y,0),U,2),0)):0,$P(^(0),U,2)=""Y"":1,$P(^(0),U,4)=""y""&($D(^A1AE(11007,""AU"",DUZ,+$P(^A1AE(11005,+Y,0),U,2)))):1,1:0)"
	Q
