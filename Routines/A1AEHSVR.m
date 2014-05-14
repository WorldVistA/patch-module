A1AEHSVR	;ISF/RWF - HFS Checksum Msg server ;10/17/07  15:19
	;;2.4;PATCH MODULE;;Mar 28, 2014;Build 8
EN	;Save the HFS Checksum message for when the patch is released.
	N IEN,TYPE,DATE,PATCH,PACKAGE,FDA,FIE,Y,X,CNT,EXIT
	K ^TMP("A1AE",$J)
	S XMER=0,(PACKAGE,PATCH)="",CNT=0,FDA=$NA(^TMP("A1AE",$J))
	F  X XMREC Q:XMER  D  Q:'IEN
	. S TYPE=+$P(XMRG,"~~",2),DATA=$E(XMRG,5,255)
	. I $T(@TYPE) D @TYPE
	. Q
	I PATCH="" D ERR("BAD MESSAGE")
	D FWD ;Send copy to mail group
	K ^TMP("A1AE",$J)
	Q
	;
1	;Patch name
	N C,I,%
	S PATCH=DATA I PATCH="" Q
	I PATCH[" " S %=$L(PATCH," "),PATCH=$P(PATCH," ",1,%-1)_"*"_$P(PATCH," ",%)_"*0"
	I $L(PATCH,"*")=3 S $P(PATCH,"*",2)=+$P(PATCH,"*",2)
	;
	S IEN=$$FIND1^DIC(11005,,"M",PATCH,)
	I 'IEN D:0 ERR("Could not find patch: "_PATCH) Q
	S C=^A1AE(11005,IEN,0) I $P(C,U,8)'="u" S IEN=0 Q  ;Only save if underdev
	I '$D(^A1AE(11005.5,IEN,0)) D  I IEN<1 D ERR("COULD NOT ADD: "_PATCH) Q
	. S DIC(0)="ML",DIC="^A1AE(11005.5,",X=PATCH D ^DIC
	. S IEN=+Y
	S PACKAGE=$P(^A1AE(11005,IEN,0),U,2)
	S @FDA@(11005.5,IEN_",",2)=XMZ,@FDA@(11005.5,IEN_",",3)=$$NOW^XLFDT
	Q
	;
2	;Linked Patchs
	S CNT=CNT+1,FIE="?+"_CNT_","_IEN_",",@FDA@(11005.521,FIE,.01)=DATA
	Q
	;
3	;Add Routines. RTN^install/delete^ien_in_build^Checksum~patch list
	N RN,CS,ID,PL
	S DATA=$TR(DATA,"~","^") ;Fix bad version
	S RN=$P(DATA,"^",1),ID=$P(DATA,"^",2),CS=$P(DATA,"^",4),PL=$P(DATA,"^",5)
	S CNT=CNT+1,FIE="?+"_CNT_","_IEN_","
	S @FDA@(11005.511,FIE,.01)=RN,@FDA@(11005.511,FIE,2)=ID,@FDA@(11005.511,FIE,3)=CS,@FDA@(11005.511,FIE,5)=PL
	K FIE
	Q
	;
8	;From Domain
	N X,Y,IX,FD,CD
	S @FDA@(11005.5,IEN_",",5)=DATA
	S FD=$RE(DATA)
	;See if from a authorized sender
	I 'PACKAGE K FDA Q
	S IX=0,CD="",X=0
	F  S IX=$O(^DIC(9.4,PACKAGE,25,IX)) Q:'IX  S Y=^(IX,0) D  Q:X
	. S Y=$P(^DIC(4.2,+Y,0),U)
	. S CD=$RE(Y),X=($E(FD,1,$L(CD))=CD)
	. Q
	I 'X K FDA ;Don't accept if not from authorized domain
	Q
	;Save data
9	;
	Q:'$D(FDA)  Q:'IEN
	D  ;Remove any previous routine info
	. K ^A1AE(11005.5,IEN,1)
	. Q
	D  ;Clear Patch link
	. N DA,DIK
	. S DA(1)=IEN,DA=0,DIK="^A1AE(11005.5,"_IEN_",2,"
	. F  S DA=$O(^A1AE(11005.5,IEN,2,DA)) Q:'DA  D ^DIK
	. Q
	K FIE D UPDATE^DIE("",FDA,"FIE")
	Q
	;
ERR(MSG)	;Report error
	;For now just send an alert
	N XQA,XQAMSG,XQAOPT,XQAROU
	S XQAMSG="HFS SERVER: "_MSG,XQA("G.A1AE PATCH ERRORS")=""
	D SETUP^XQALERT
	Q
	;
FWD	;Forward message
	Q:'$D(XMZ)
	N XMDUZ
	S XMY("G.A1AE HFS MESSAGES")=""
	D ENT1^XMD
	Q
	;
TEST	;
	N XMRG,XMER,XMREC,XMZ
	W !,"Message number: " R XMZ:300 Q:'XMZ
	S XMREC="D REC^XMS3"
	D EN
	Q
