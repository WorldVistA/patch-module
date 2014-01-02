A1AEP ; GENERATED FROM 'A1AE STANDARD PRINT' PRINT TEMPLATE (#1533) ; 12/31/13 ; (FILE 11005, MARGIN=80)
 G BEGIN
N W !
T W:$X ! I '$D(DIOT(2)),DN,$D(IOSL),$S('$D(DIWF):1,$P(DIWF,"B",2):$P(DIWF,"B",2),1:1)+$Y'<IOSL,$D(^UTILITY($J,1))#2,^(1)?1U1P1E.E X ^(1)
 S DISTP=DISTP+1,DILCT=DILCT+1 D:'(DISTP#100) CSTP^DIO2
 Q
DT I $G(DUZ("LANG"))>1,Y W $$OUT^DIALOGU(Y,"DD") Q
 X ^DD("DD")
 W Y Q
M D @DIXX
 Q
BEGIN ;
 S:'$D(DN) DN=1 S DISTP=$G(DISTP),DILCT=$G(DILCT)
 I $D(DXS)<9 M DXS=^DIPT(1533,"DXS")
 S I(0)="^A1AE(11005,",J(0)=11005
 W ?0 X DXS(1,9) K DIP K:DN Y
 D T Q:'DN  D N D N:$X>0 Q:'DN  W ?0 W "Subject:"
 S X=$G(^A1AE(11005,D0,0)) W ?10,$E($P(X,U,5),1,70)
 D T Q:'DN  D N D N:$X>0 Q:'DN  W ?0 W "Category:"
 S I(1)="""C""",J(1)=11005.05 F D1=0:0 Q:$O(^A1AE(11005,D0,"C",D1))'>0  X $G(DSC(11005.05))  S D1=$O(^(D1)) Q:D1'>0   D:$X>11 T Q:'DN  D A1
 G A1R
A1 ;
 S X=$G(^A1AE(11005,D0,"C",D1,0)) W ?11 S Y=$P(X,U,1) W:Y]"" $E($$SET^DIQ(11005.05,.01,Y),1,17)
 Q
A1R ;
 D T Q:'DN  D N D N:$X>0 Q:'DN  W ?0 W "Description:"
 D N:$X>0 Q:'DN  W ?0 W "==========="
 D N:$X>0 Q:'DN  W ?0 W " "
  D N:$X>0 Q:'DN  W ?0 S:'$D(DIWF) DIWF="" S:DIWF'["N" DIWF=DIWF_"N" S X="" S I(1)="""D""",J(1)=11005.01 F D1=0:0 Q:$O(^A1AE(11005,D0,"D",D1))'>0  S D1=$O(^(D1)) D:$X>3 T Q:'DN  D B1
 G B1R
B1 ;
 S X=$G(^A1AE(11005,D0,"D",D1,0)) S DIWL=1,DIWR=78 D ^DIWP
 Q
B1R ;
 D 0^DIWW
 D ^DIWW
 D T Q:'DN  D N D N D N:$X>0 Q:'DN  W ?0 W "Routine Information:"
 D N:$X>0 Q:'DN  W ?0 W "===================="
 D T Q:'DN  D N D N:$X>0 Q:'DN  W ?0 D RTNINFO^A1AEUTL2() K DIP K:DN Y
 D T Q:'DN  D N D N D N:$X>0 Q:'DN  W ?0 W "============================================================================="
 D N:$X>0 Q:'DN  W ?0 W "User Information:"
 W ?19 S Y=$P(^A1AE(11005,D0,0),"^",17) I Y X ^DD("DD") W ?40,"   Hold Date :   "_Y K DIP K:DN Y
 D N:$X>2 Q:'DN  W ?2 W "Entered By  : "
 S X=$G(^A1AE(11005,D0,0)) W ?18 S Y=$P(X,U,9) S Y=$S(Y="":Y,$D(^VA(200,Y,0))#2:$P(^(0),U),1:Y) W $E(Y,1,20)
 D N:$X>39 Q:'DN  W ?39 W "Date Entered  : "
 W ?57 S Y=$P(X,U,12) D DT
 D N:$X>2 Q:'DN  W ?2 W "Completed By: "
 W ?18 S Y=$P(X,U,13) S Y=$S(Y="":Y,$D(^VA(200,Y,0))#2:$P(^(0),U),1:Y) W $E(Y,1,20)
 D N:$X>39 Q:'DN  W ?39 W "Date Completed: "
 W ?57 S Y=$P(X,U,10) D DT
 D N:$X>2 Q:'DN  W ?2 W "Released By : "
 W ?18 S Y=$P(X,U,14) S Y=$S(Y="":Y,$D(^VA(200,Y,0))#2:$P(^(0),U),1:Y) W $E(Y,1,20)
 D N:$X>39 Q:'DN  W ?39 W "Date Released : "
 W ?57 S Y=$P(X,U,11) D DT
 D N:$X>0 Q:'DN  W ?0 W "============================================================================="
 S:'$D(A1AEHD) A1AEHD="Patch Details" D PRT^A1AEUTL:A1AEHD'["Display"&(A1AEOUT'["^") K DIP K:DN Y
 K Y K DIWF
 Q
HEAD ;
 W !,"--------------------------------------------------------------------------------",!!
