A1AECL1	;ISF/RWF - Released Patch ROUTINE file updater ;6/14/07  16:17
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	Q
	;
	;This entry point is called when a patch is released to update the ROUTINE file
	;with the checksums from the patch.
PATCH(PIEN)	;Update routine file for one patch.
	N RTNL,PATCH
	S RTNL=$NA(^TMP("A1AECL1",$J)) K @RTNL
	S PATCH=$P(^A1AE(11005,PIEN,0),U)
	D RSUM($NA(^A1AE(11005.1,PIEN,2)),.RTNL)
	I '$L($O(@RTNL@(" "))) D HFS(RTNL)
	D SAVE(PATCH,RTNL)
	Q
	;
SAVE(PATCH,ROOT)	;
	N RN
	S RN=""
	F  S RN=$O(@ROOT@(RN)) Q:RN=""  D RTNLOG(RN,PATCH,@ROOT@(RN))
	Q
	;
	;RSUM=add/delete^nop^checksum^patchlist
RTNLOG(RN,PCH,RSUM)	;Enter/Update routine in the Routine File
	N Y,FDA,IEN
	S Y=$O(^DIC(9.8,"B",RN,0))
	I Y'>0 S IEN="?+1,",FDA(9.8,IEN,1)="R",FDA(9.8,IEN,.01)=RN
	I Y>0 S IEN=(+Y)_","
	S FDA(9.8,IEN,6)=2 ; Always track and report national patches
	I +RSUM D
	. S FDA(9.8,IEN,6.2)=PCH ;Delete routine
	I 'RSUM D
	. S FDA(9.8,IEN,7.1)=DT
	. S FDA(9.8,IEN,7.2)=$P(RSUM,U,3) ;Checksum
	. S FDA(9.8,IEN,7.3)=$P(RSUM,U,4) ;Patch List
	. S IEN="?+2,"_IEN,FDA(9.818,IEN,.01)=PCH,FDA(9.818,IEN,2)=$P(RSUM,U,3),FDA(9.818,IEN,3)=$P(RSUM,U,4)
	D UPDATE^DIE("","FDA","IEN")
	Q
	;
HFS(RET)	;Check if HFS Data
	I '$D(^A1AE(11005.5,PIEN,0)) Q
	N I,X
	S I=0
	F  S I=$O(^A1AE(11005.5,PIEN,1,I)) Q:'I  S X=^(I,0) D
	. S @RET@($P(X,U,1))=$P(X,U,2,5)
	. Q
	Q
	;
RSUM(ROOT,RET)	;
	;ROOT is the root where the message is.
	;RET will return an array of routine names and checksums
	N IX
	I $$PATFL() Q
	D BLDTMP
	I $L($O(^TMP($J,"RTN","")))>0 D SUM
	K ^TMP($J)
	Q
	;
PATFL()	;See if data is in the Patch file
	N A1,PL,RN,RSUM
	S A1=0
	F  S A1=$O(^A1AE(11005,PIEN,"P",A1)) Q:A1'>0  S A2=$G(^(A1,0)) D
	. Q:'$L($P(A2,U,2))
	. S RN=$P(A2,U),RSUM=$P(A2,U,2),PL=$P(A2,U,3)
	. S @RET@(RN)="0^0^"_RSUM_U_PL
	. Q
	Q $L($O(@RET@("")))
	;
SUM	;Build the RSUM's, Zero node is add/delete^nop^checksum
	;Add to zero node the patch list as the 4th $P
	N RN,PL S RN=""
	F  S RN=$O(^TMP($J,"RTN",RN)) Q:RN=""  D
	. S PL=$G(^TMP($J,"RTN",RN,2,0))
	. S @RET@(RN)=$G(^TMP($J,"RTN",RN))_U_$P(PL,";",5)
	. Q
	Q
	;
BLDTMP	;Build the TMP global to work from.
	N IX K ^TMP($J)
	S IX=0
	;Skip until we find $KID, then skip 2 more
	F  S IX=$O(@ROOT@(IX)) Q:IX'>0  S X=^(IX,0) Q:$E(X,1,4)="$KID"
	S IX=$O(@ROOT@(IX)) S IX=$O(@ROOT@(IX))
	;Now the real part
	F  S IX=$O(@ROOT@(IX)) Q:IX'>0  D
	. S X=^(IX,0),IX=$O(@ROOT@(IX)) Q:$E(X,2,4)'="RTN"
	. S Y=$G(^(IX,0))
	. S @("^TMP($J,"_X)=Y
	. Q
	Q
	;
	;Fix database from bad code
FIX	;
	N DA,X,Y,D1
	S DA=0
	F  S DA=$O(^DIC(9.8,DA)) Q:'DA  D
	. S X=$G(^DIC(9.8,DA,4)) I $L(X) D
	. . I X'["~" Q
	. . S Y=$P(X,"~",1)_"^"_$P($P(X,"~",2),";",5)
	. . W !,DA,?10,Y
	. . ;S ^DIC(9.8,DA,4)=Y
	. . Q
	. S D1=0 F  S D1=$O(^DIC(9.8,DA,8,D1)) Q:'Y  D
	. . S X=^DIC(9.8,DA,8,D1,0) Q:X'["~"
	. . S Y=$P(X,"~",1)
	. . W !,DA,?10,Y
	. . S ^DIC(9.8,DA,8,D1,0)=Y
	. . Q
	Q
	;
TEST(D0)	;Update ROUTINE file from the Routine list.
	N A1,A2,PH,PHL,RN,RSUM
	S A1=0,PH=$P(^A1AE(11005,D0,0),U)
	F  S A1=$O(^A1AE(11005,D0,"P",A1)) Q:A1'>0  S A2=$G(^(A1,0)) D
	. S RN=$P(A2,U),RSUM=$P(A2,U,2),PHL=$P(A2,U,3) Q:'$L(RSUM)
	. D RTNLOG(RN,PH,"0^0^"_RSUM_U_PHL)
	. Q
	Q
