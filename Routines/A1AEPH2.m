A1AEPH2	;  REW/WCIOFO,RMO,MJK/ALBANY ;2/23/06  13:55
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;11/23/92
	;
	G:$D(^DOPT("A1AEPH2",11)) A S ^DOPT("A1AEPH2",0)="Print Patch Menu Option^1N^" F I=1:1 S X=$T(@I) Q:X=""  S ^DOPT("A1AEPH2",I,0)=$P(X,";",2,99)
	S DIK="^DOPT(""A1AEPH2""," D IXALL^DIK
A	W !! S DIC="^DOPT(""A1AEPH2"",",DIC(0)="AEMQ" D ^DIC Q:Y<0  D @+Y G A
	;
1	;Completed/unverified Patch Report
	S DIS(0)="I $P(^A1AE(11005,D0,0),U,8)=""c""",A1AEHD="Completed/NotReleased DHCP Patches Report",A1AES=""
	S DIC("S")="I $S($D(^A1AE(11007,+Y,""PH"",DUZ,0)):1,'$D(^A1AE(11007,+Y,""PB"",DUZ,0)):0,$P(^(0),U,2)=""V"":1,1:0)" G DIP^A1AEPH3
	;
2	;New Patch Report
	G PRTNEW^A1AEVP
	;
3	;Under Development Patch Report
	S DIS(0)="I $P(^A1AE(11005,D0,0),U,8)=""u""",A1AEHD="Under Development DHCP Patches Report",A1AES=""
	S DIC("S")="I $D(^A1AE(11007,+Y,""PH"",DUZ,0))" G DIP^A1AEPH3
	;
4	;Display a Completed/NotReleased Patch
	G COMDIS^A1AEPH6
	;
5	;Summary Report for a Package
	;replace .01 sort with 3 in template
	N A1AEPK,A1AEPKIF,A1AEPKNM,A1AEVR,A1AEREV,X,Y,DIR,ZTSK,%ZIS,A1AEDEV
	D PKG^A1AEUTL G Q:'$D(A1AEPK) D VER^A1AEUTL G Q:'$D(A1AEVR)
	S DIR(0)="Y",DIR("B")="No",DIR("A")="Sort by reverse SEQ # "
	D ^DIR Q:$D(DIRUT)
	S A1AEREV=Y
	S %ZIS="QN"
	D ^%ZIS Q:POP
	S A1AEDEV=ION_";"_IOM_";"_IOSL
	I '$D(IO("Q")) D
	. D 5GO
	E  D
	. N ZTRTN,ZTSAVE,ZTDESC,ZTSK,ZTDTH,ZTIO,I
	. S ZTDESC="A1AE Patch Summary"
	. S ZTRTN="5GO^A1AEPH2"
	. F I="A1AEPK","A1AEPKIF","A1AEPKNM","A1AEVR","A1AEREV","A1AEDEV" S ZTSAVE(I)=""
	. S ZTIO=""
	. D ^%ZTLOAD
	. K IO("Q")
	. I $D(ZTSK) W !,"Request queued.  Task number: ",ZTSK
	D HOME^%ZIS
	Q
5GO	;
	N L,DIC,FLDS,BY,TO,FR,TREV,FREV,TMP,A1AEDJDH
	S L=0,DIC="^A1AE(11005,"
	S FLDS="[A1AE VERIFIED PATCH SUMMARY]"
	I '$D(DIS(0)) S DIC("S")="I $P(^(0),U,2)=""Y""!($P(^(0),U,4)=""y""&($D(^A1AE(11007,""AU"",DUZ,+Y))))"
	;fix for fileman BY restriction -- can't use format BY with BY(0)
	S BY=$S(A1AEREV:"@INTERNAL(#3),-6",1:"@INTERNAL(#3),6")
	S FR="0,@",TO="99999,99999"
	;use entry# of print driver for namespace
	S A1AEDJDH=$J_"."_$P($H,",",2) K ^TMP("A1AE5",A1AEDJDH) S TMP="" ; REW added seconds in case user tries to run a second listing before the first finishes
	;
	;setup the version and dba except for xm
	S TREV=A1AEPK_"*"_A1AEVR_"*" DO  S TREV=A1AEPK_"*999*" DO:A1AEPK'="XM"
	.S FREV=TREV_"  0"
	.S TREV=TREV_"999"
	.F  S FREV=$O(^A1AE(11005,"AB",FREV)) Q:FREV]]TREV  Q:FREV'[A1AEPK  DO
	..Q:'$L(FREV)
	..Q:'+$O(^(FREV,0))
	..DO:$S<6000  Q:'$D(TMP)
	...S ^TMP("A1AE5",A1AEDJDH,$O(^(0)))=""
	...I D(TMP) MERGE ^TMP=TMP K TMP
	..Q:'$D(TMP)
	..S TMP("A1AE5",A1AEDJDH,$O(^(0)))=""
DIP5	;
	I $D(TMP)>1 MERGE ^TMP=TMP K TMP
	;I '$D(^TMP("A1AE5",A1AEDJDH)) W !?10,"No summary available" Q
	K FREV,TREV S BY(0)="^TMP(""A1AE5"","_A1AEDJDH_",",L(0)=1 
	S IOP=A1AEDEV
	D EN1^DIP
	K ^TMP("A1AE5",A1AEDJDH),DIS
	Q
	;
6	;Display a Patch
	G PATDIS^A1AEPH6
	;
7	;All Verified Patches for a Package
	S DIS(0)="I $P(^(0),U,8)=""v""",A1AEHD="Released DHCP Patches",DIC("S")="I $P(^(0),U,2)=""Y""!($P(^(0),U,4)=""y""&($D(^A1AE(11007,""AU"",DUZ,+Y))))" G DIP^A1AEPH3
	;
8	;Extended Display of a Patch
	G EXTDIS^A1AEPH6
	;
9	;Verified Patch Summary Report by Date
	G ^A1AEPH4
	;
10	;Detailed Report of Verified Patches by Date
	G ^A1AEPH5
	;
11	;Display Number of New Patches
	G DSPNEW^A1AEVP
	;
12	;Update patches as printed for a User's packages
	G ^A1AEVP1
	;
13	;Complete/unverified Summary Report for Assigned Packages
	W ! D ^%ZIS S AIOP=IO G PKG
	;
14	;Summary Report (OLD 5)
	;
PKG	K AN S PKG=0
	F  S PKG=$O(^A1AE(11007,"AV",DUZ,PKG)) Q:'PKG  DO
	.I $D(^DIC(9.4,PKG,0)) S (AN(PKG),A1AEPK)=$P(^(0),"^",2) DO
	..S A1AEVR=0
	..F  S A1AEVR=$O(^A1AE(11007,PKG,"V",A1AEVR)) Q:'A1AEVR  DO 
	...S AN(PKG,A1AEVR)=""
	S PKG=0
	F  S PKG=$O(AN(PKG)) Q:'PKG  S A1AEPK=AN(PKG) DO
	.S A1AEVR=0
	.F  S A1AEVR=$O(AN(PKG,A1AEVR)) Q:'A1AEVR  DO
	..I '$D(^A1AE(11005,"AS",PKG,A1AEVR,"c")) K AN(PKG,A1AEVR) Q
	..D PRT
	K AN G Q
PRT	S DHD="DHCP Patch Summary Report for "_A1AEPK_"*"_A1AEVR_" Complete/NotReleased Patches",FLDS="[A1AE VERIFIED PATCH SUMMARY]",L=0,DIC="^A1AE(11005,",BY="[A1AE SUMMARY SORT]",A1AEPGE=1
	S DIS(0)="I $P(^A1AE(11005,D0,0),""^"",3)=A1AEVR!($P(^(0),""^"",3)=999)&($P(^A1AE(11005,D0,0),""^"",8)=""c"")",TO=A1AEPK_"*"_A1AEVR_"*",FR=TO_"  1",TO=$P(TO,"*")_"*"_999_"*"_999 S IOP=AIOP,AY=$Y D EN1^DIP S A1AEPGE=A1AEPGE+1
	I A1AEPGE,$E(IOST,1)="C",AY'=$Y W *7 R A1AEOUT:DTIME I A1AEOUT["^" K AN Q
	S AY=$Y
	Q
	;
HD	S:'$D(A1AEPGE) A1AEPGE=0 S:'$D(A1AEOUT) A1AEOUT="" D CRCHK Q:A1AEOUT["^"  W @IOF,$S($D(A1AEHD):A1AEHD,1:"Patch Details") K A1AELNE S $P(A1AELNE,"=",78)="",A1AEPGE=A1AEPGE+1 W:$X>68 ! W ?70,"Page: ",A1AEPGE,!,A1AELNE
	Q:'$D(D0)  S A1AE0=$S($D(^A1AE(11005,D0,0)):^(0),1:""),A1AED1=$P(A1AE0,"^") W !,"Run Date: " S Y=DT D DT^DIQ W ?44,"Designation: ",$P(A1AED1,"*")_"*"_$S($P(A1AED1,"*",2)=999:"DBA",1:$P(A1AED1,"*",2))_"*"_$P(A1AED1,"*",3)
	S NOTE=$P(A1AE0,"^",8)
	W:NOTE="u" "  TEST v"_$P($G(^A1AE(11005.1,D0,0)),U,12)
	S P=$P(A1AE0,"^",2) W !,"Package : ",$P($G(^DIC(9.4,+P,0)),"^"),?44,"Priority   : ",$P($P(^DD(11005,7,0),$P(^A1AE(11005,D0,0),"^",7)_":",2),";",1)
	;
	;This uses the DD status
	;W !,"Version : ",$S($P(A1AE0,"^",3)=999:"DBA",1:$P(A1AE0,"^",3))," ",$S($P(A1AE0,"^",6):"SEQ #"_$P(A1AE0,"^",6),1:""),?44,"Status     : ",$P($P(^DD(11005,8,0),$P(^A1AE(11005,D0,0),"^",8)_":",2),";",1),!,A1AELNE,! K A1AE0,A1AED1,SEQT
	W !,"Version : ",$S($P(A1AE0,"^",3)=999:"DBA",1:$P(A1AE0,"^",3))," ",$S($P(A1AE0,"^",6):"SEQ #"_$P(A1AE0,"^",6),1:""),?44,"Status     : "
	;S NOTE=$P(A1AE0,"^",8)
	W $S(NOTE="v":"RELEASED",NOTE="c":"COMPLETE/NOT RELEASED",NOTE="u":"UNDER DEVELOPMENT",NOTE="e":"ENTERED IN ERROR",NOTE="r":"RETIRED",1:"")
	S Y=$P(A1AE0,"^",18) I +Y>0 W !,?25,"Compliance Date: " D DT^DIQ
	W !,A1AELNE,! K A1AE0,A1AED1,SEQT,NOTE
	Q
	;
CRCHK	I A1AEPGE,$E(IOST,1)="C" W !!,*7,"Press RETURN to continue or '^' to stop " R A1AEOUT:DTIME I A1AEOUT["^" S DN=0 K ^UTILITY($J,"W")
	Q
	;
Q	W ! K AZ,A7,A1AEVR,AIOP,DUOUT,DTOUT,^UTILITY($J),PKG,DN,D0,DXS,DIS(0),A1AES,A1AE0,A1AED1,A1AEIX,A1AEJ,A1AEOUT,A1AEN,A1AEI,A1AEAB,A1AED,A1AEHD,A1AELNE,IOP,FLDS,BY,L,FR,TO,DIS,A1AEPD
	K A1AEIFN,A1AESCN,A1AEVPR,A1AEPKIF,A1AEPKNM,A1AEPK,A1AETY,A1AEVPR,POP,PGM,VAR,A1AEPGE D CLOSE^A1AEUTL1 Q
	;
UD	;UNDEVELOPMENT EP
	S DIS(0)="I $P(^A1AE(11005,D0,0),U,8)=""u""" G 5 ;Under development only
CNR	;COMPLETED/NOT RELEASED EP
	S DIS(0)="I $P(^A1AE(11005,D0,0),U,8)=""c""" G 5 ;Completed/Not Released only
