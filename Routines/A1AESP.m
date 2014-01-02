A1AESP	;ISF/RWF - Special load of package releases ;08/19/2010  5079.826506
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
EN	;Read an HFS Package release.
	W !,"Use LDINS entry point" Q
	N PACKAGE,RTN,NOW,RR,X,Y,DONE
	S NOW=$$NOW^XLFDT
	S %ZIS="M",%ZIS("A")="Package Build file: " D ^%ZIS I POP W !,"No Device" Q
	U IO F  R X:1 Q:(X="**INSTALL NAME**")!(X="$$END")
	U $P I X["END" W !,"END OF FILE" Q
	U IO R PACKAGE:1
	U $P W !,"Loading Package: ",PACKAGE
	;Now find routines
	U IO F  R X:2,Y:2 Q:($E(X,1,5)="""RTN""")!(X["**END**")
	;Start real work
	S DONE=0,RR="""RTN""A)"
	F  D  Q:DONE
	. U IO R X:2,Y:2
	. I $E(X,2,4)'="RTN" U $P W !,"Stopping: ",X S DONE=1 Q
	. I $E(RR,1,$L(RR)-1)'=$E(X,1,$L(RR)-1) D
	. . S RR=X
	. . D RTNLOAD2(PACKAGE,RR,Y)
	. . Q
	. Q
	D ^%ZISC
	U $P W !,"DONE"
	Q
	;
RTNLOAD2(PKG,REF,Y)	;
	N RN,CHK
	S RN=$P($RE(REF),",")
	S RN=$RE($E(RN,3,$L(RN)-1))
	S CHK=$P(Y,U,3)
	D RTNLOAD(PKG,RN,CHK)
	Q
	;
RTNLOAD(RN,PCH,CHKSUM,PL)	;
	N FDA,IEN
	I '$D(NOW) S NOW=$$NOW^XLFDT
	S IEN=$O(^DIC(9.8,"B",RN,0))
	;I IEN K ^DIC(9.8,IEN,8) ;Remove Patch History ???
	I IEN S IEN=IEN_","
	E  S IEN="?+1,",FDA(9.8,IEN,.01)=RN
	S FDA(9.8,IEN,1)="R",FDA(9.8,IEN,6)=2
	S FDA(9.8,IEN,7.1)=NOW,FDA(9.8,IEN,7.2)=CHKSUM,FDA(9.8,IEN,7.3)=$G(PL)
	S IEN="?+2,"_IEN
	S FDA(9.818,IEN,.01)=PCH,FDA(9.818,IEN,2)=CHKSUM S:$L($G(PL)) FDA(9.818,IEN,3)=PL
	D UPDATE^DIE("","FDA")
	U $P W !,"Routine ",RN," filed"
	Q
	;
	;
HFS	;Fix ~ in checksum
	N DA,A1,A2
	S DA=0
	F  S DA=$O(^A1AE(11005.5,DA)),A1=0 Q:'DA  D
	. F  S A1=$O(^A1AE(11005.5,DA,1,A1)) Q:'A1  S X=^(A1,0) D
	. . I X["~" S ^A1AE(11005.5,DA,1,A1,0)=$TR(X,"~","^")
	. . Q
	. Q
	Q
	;
SEARCH	   ;Search Patch file for routines
	N RN,FDA,IEN,X,A1,A2,DA
	S DA=0
	F  S DA=$O(^A1AE(11005,DA)) Q:'DA  I $P(^A1AE(11005,DA,0),U,8)="u" D
	. S A1=0
	. F  S A1=$O(^A1AE(11005,DA,"P",A1)) Q:'A1  S X=^(A1,0) D
	. . S RN=$P(X,U),OLD=$P(X,U,4) D:OLD["~"  ;Look for something
	. . . S $P(^A1AE(11005,DA,"P",A1,0),U,4)=$P(OLD,"~")
	. . Q
	. Q
	Q
	;
	;
	;Check for DUP routines in patch.
DUP	;
	N A1,A2,A3,A4
	S A1=0
	F  S A1=$O(^A1AE(11005,A1)) Q:'A1  I "uc"[$P($G(^(A1,0)),U,8) D
	. S A2=""
	. F  S A2=$O(^A1AE(11005,A1,"P","B",A2)) Q:A2=""  D
	. . S A3=$O(^A1AE(11005,A1,"P","B",A2,0)),A4=$O(^(A3))
	. . I A4 W !,A1,?10,A2,?20,A3,?25,A4
	. . Q
	. Q
	Q
	;
PCHDUP	;Check for dup patchs in routine file.
	N D0,D1,D2,X,Y,DIK,DA
	S D0=0
	F  S D0=$O(^DIC(9.8,D0)),D1="" Q:'D0  D
	. F  S D1=$O(^DIC(9.8,D0,8,"B",D1)),DA(1)=D0 Q:D1=""  D
	. . S X=$O(^DIC(9.8,D0,8,"B",D1,0)),Y=$O(^(X))
	. . I Y>X W !,$P(^DIC(9.8,D0,0),U),?10,D1 S DA=Y,DIK="^DIC(9.8,DA(1),8," D ^DIK
	. . Q
	. Q
	Q
	;
RTNCHK(PCH)	;Check patch routines against Routine file
	N D0,D1,DA,R1,R2,RN,X,Y
	S D0=$O(^A1AE(11005,"B",PCH,0)) I 'D0 W !,"Patch not found" Q
	W !,"Patch ",PCH," ien: ",D0
	S D1=0
	F  S D1=$O(^A1AE(11005,D0,"P",D1)) Q:D1'>0  D
	. S R1=^A1AE(11005,D0,"P",D1,0),RN=$P(R1,U)
	. S DA=$O(^DIC(9.8,"B",RN,0)) I 'DA D  W ! Q
	. . W !,"Routine ",RN," not found",!,?5,R1
	. . R !,"Load? ",X:DTIME Q:$E(X)'="Y"
	. . D RTNLOAD(RN,PCH,$P(R1,U,2),$P(R1,U,3))
	. . Q
	. W !,RN,?10,^DIC(9.8,DA,4)
	. Q
	Q
	;
LDINS	;File routines from Install file
	N DA,D0,D1,IX,X,Y,DIC,FDA,PCH,NOW
	S NOW=$$NOW^XLFDT()
	S DIC="^XPD(9.7,",DIC(0)="AEMQ" D ^DIC Q:Y<1
	S IX=+Y,RN="",PCH=$P(Y,U,2) S:PCH["*" $P(PCH,"*",2)=+$P(PCH,"*",2)
	F  S RN=$O(^XTMP("XPDI",IX,"RTN",RN)) Q:RN=""  D
	. S X=^XTMP("XPDI",IX,"RTN",RN),Y=$G(^(RN,2,0))
	. D RTNLOAD(RN,PCH,$P(X,U,3),$P(Y,";",5))
	. Q
	Q
	;
MAKECUR	;Make a patch the current checksum for its routines
	N RN,PCH,DA,D0,D1,IX,X,Y
	R !,"Enter Patch Number: ",PCH:600
	S D0=0
	F  S D0=$O(^DIC(9.8,D0)),D1=0 Q:'D0  D
	. S RN=$P(^DIC(9.8,D0,0),U)
	. S D1=$O(^DIC(9.8,D0,8,"B"),-1) Q:'D1  S X=^DIC(9.8,D0,8,D1,0) Q:$P(X,U)'=PCH
	. S CHK=$P(X,U,2)
	. W !,RN,"  ",PCH,"  ",CHK
	. D RTNLOAD(RN,PCH,CHK,"")
	. Q
	Q
	;
DIC	;Look up IEN of a patch.
	N DIC
	S DIC=11005,DIC(0)="AEMQ" D ^DIC W !,Y
	Q
	;To load Routines from the Patch message
	;DO RTNBLD^A1AEM1(IEN)
	;
BACKOUT	;Backout a patch,  Entered in error
	N RN,PDA,PCH,DA,DO,D1,IX,OCS,X,Y
	W !,"Patch to Backout."
	S DIC=11005,DIC(0)="AEMQ" D ^DIC Q:Y<1
	S PDA=+Y,PCH=$P(Y,U,2)
	S IX=0
	F  S IX=$O(^A1AE(11005,PDA,"P",IX)) Q:'IX  S R1=^(IX,0) D
	. S RN=$P(R1,U,1),OCS=$P(R1,U,4)
	. W !,"Routine ",RN
	. D BKOT(RN,PCH,OCS)
	. Q
	W !,"DONE"
	Q
	;
BKOT(RN,PCH,OCS)	;Backout Checksum from Routine file.
	N DA,DB,DC,FDA,IEN
	S DB=$$FIND1^DIC(9.8,,"X",RN) Q:'DB
	S DC=$$FIND1^DIC(9.818,","_DB_",","X",PCH) Q:'DC
	S IEN=DB_",",FDA(9.8,IEN,7.1)="@",FDA(9.8,IEN,7.2)=OCS,FDA(9.8,IEN,7.3)="@"
	S IEN=DC_","_IEN,FDA(9.818,IEN,.01)="@"
	D FILE^DIE("K","FDA")
	I $D(^TMP("DIERR",$J)) S %ZT($NA(^TMP("DIERR",$J)))="" D ^%ZTER Q
	Q
