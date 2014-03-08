A1AEUTL2	;ISF/RWF - Utility: Routine Info ;2014-03-07  7:51 PM
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	Q
	;Called from the FM Print template [A1AE STANDARD PRINT]
	; and A1AEMAL to show the routine info
RTNINFO(MAL)	;
	N A1,A2,A3,AX,OLD,NEW,RN,PL,X,AEQ,DIR,DIRUT,DUOUT,PATCH,NC,L2
	S MAL=$G(MAL)
	I '$O(^A1AE(11005,D0,"P",0)) D OUT("No routines included.") Q
	;See if New Checksums
	S D1=0,NC=0
	F  S D1=$O(^A1AE(11005,D0,"P",D1)) Q:'D1  S AX=^(D1,0) I $L($P(AX,U,2)) S NC=1 Q
	;
	S L2=$G(^A1AE(11005,D0,"P2"))
	I $L(L2) D OUT("The second line of each of these routines now looks like:"),OUT(L2),OUT("")
	I NC D OUT("The checksums below are new checksums, and"),OUT(" can be checked with CHECK1^XTSUMBLD."),OUT("")
	K ^TMP("A1AEPL",$J)
	S D1=0,$P(AEQ,"=",78)="",PATCH=+$P(^A1AE(11005,D0,0),U,4),RN=""
	F  S RN=$O(^A1AE(11005,D0,"P","B",RN)) Q:RN=""  D
	. S D1=$O(^A1AE(11005,D0,"P","B",RN,0)) Q:'D1  S AX=^A1AE(11005,D0,"P",D1,0) D
	. I 'MAL,$E(IOST,1,2)="C-",$Y+3>IOSL S DIR(0)="E" D ^DIR W:Y @IOF I 'Y S RN="{"  Q
	. ;See if we have a KIDS checksum
	. S NEW="",NEW=$P(AX,U,2),PL=$P(AX,U,3),OLD=$P(AX,U,4)
	. I PATCH D PTLBLD(PL,PATCH)
	. I '$L(OLD) S OLD=$$BCS(D0,RN) I $G(A1AENEW)="v" S $P(^A1AE(11005,D0,"P",D1,0),U,4)=OLD ;Save the old at the time of release
	. D OUT("Routine Name: "_RN)
	. ;S:OLD=""!(OLD=NEW) OLD="n/a"
	. S:OLD="" OLD="n/a"
	. I $L(NEW) D
	. . D WRAP("    Before:"_$J(OLD,10)_"   After:"_$J(NEW,10)_"  ",PL)
	. S D2=0
	. ;Display entered checksums if can't find KIDS checksum.
	. I '$L(NEW),$O(^A1AE(11005,D0,"P",D1,"X",0))>0 D
	. . D OUT("    Checksum:")
	. . F  S D2=$O(^A1AE(11005,D0,"P",D1,"X",D2)) Q:'D2  S X=$G(^(D2,0)) D OUT("  "_X)
	. . Q
	. ;Show Description if entered.
	. I $O(^A1AE(11005,D0,"P",D1,"D",0))>0 D
	. . D OUT(" Description of Changes:")
	. . S D2=0
	. . F  S D2=$O(^A1AE(11005,D0,"P",D1,"D",D2)) Q:'D2  S X=$G(^(D2,0)) D OUT("  "_X)
	. . D OUT("")
	. Q
	D DSP(PATCH)
	K TMP("A1AEPL",$J)
	Q
	;
BCS(DA,RN)	;Get the Before CheckSum
	N C,X
	S C="",RN=$TR(RN,$C(34)) ;Remove any Quotes
        N PD S PD=$$GET1^DIQ(11005,DA,.01)
        N STREAM S STREAM=$$GETSTRM^A1AEK2M0(PD)
        S X=$O(^A1AE(11007.1,STREAM,"RTN","B",RN,0))
        I X>0 S C=$P(^A1AE(11007.1,10001,"RTN",X,0),U,2) QUIT C
        ; Otherwise, try the routine file.
	S X=$O(^DIC(9.8,"B",RN,0)) I X>0 S C=$P($G(^DIC(9.8,X,4)),U,2)
	S:'$L(C) C="n/a"
	Q C
	;
OUT(S)	;Write or put in MSG
	I MAL D ADD^A1AEMAL(S) Q
	D N^DIO2 W S
	Q
	;
WRAP(P,S)	;Wrap S starting at length of P.
	I $L(S)+$L(P)<80 D OUT(P_S) Q
	N I,T,C,L S C=$L(P),$P(L," ",C+2)=""
	S I=$F(S,",",70-C) D OUT(P_$E(S,1,I-1)) S S=$E(S,I,999)
	F  S I=$F(S,",",70-C),I=$S(I>0:I,1:$L(S)+2) D OUT(L_$E(S,1,I-1)) S S=$E(S,I,999) Q:'$L(S)
	Q
	;
	;
DSP(PATCH)	;Display Patch List
	N PL,I
	D PTLDSP(.PL,PATCH)
	F I=1:1 Q:'$D(PL(I))  D OUT(PL(I))
	Q
	;
	;Build patch list
PTLBLD(Z,PATCH)	;Build in ^TMP the patches used
	;Z is routine second line, PATCH is patch number
	N I,J,K,P S Z=$P(Z,"**",2),K=""
	F I=1:1 S J=+$P(Z,",",I) Q:(J=0)  I (J'=PATCH) S P=$G(^TMP("A1AEPL",$J,J)),^TMP("A1AEPL",$J,J)=P_K S K=K_J_","
	Q
PTLSRT	;Sort the list
	N I,J,K,L S I=0
	M PTL=^TMP("A1AEPL",$J)
	F I=0:0 S I=$O(^TMP("A1AEPL",$J,I)) Q:I'>0  S K=^(I) D
	. F J=1:1 S L=$P(K,",",J) Q:L=""  K PTL(L)
	. Q
	Q
	;
PTLDSP(RET,PATCH)	;Display list of patches.
	;RET passed by Reference, PATCH is patch number.
	I '$G(^A1AE(11005,D0,5)) Q  ;See if want to show list.
	N PTL
	D PTLSRT
	N I,J,IX K PTL(PATCH)
	Q:$O(PTL(0))=""
	S RET(1)=" ",RET(2)="Routine list of preceding patches: "
	S (I,J)="",IX=2
	F  S I=$O(PTL(I)) Q:I=""  D
	. I $L(RET(IX))>70 S IX=IX+1,J="",RET(IX)="                           "
	. S RET(IX)=RET(IX)_J_I,J=", "
	Q
