A1AEP ; VEN/LGC - GENERATED FROM 'A1AE STANDARD PRINT' PRINT TEMPLATE and subsequently modified ;2015-06-14  12:48 AM
 ;;2.5;PATCH MODULE;;Jun 05, 2015
 ;
 ; CHANGE VEN/LGC 2015 06 15
 ;  Modified to print properly formated export
 ;
 G BEGIN
 ; Write new line
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
 ; new code
 ; Do not print the three below for now/lgc
 ; old code
 ;W ?0 X DXS(1,9) K DIP K:DN Y
 ;W ?11 X DXS(2,9) K DIP K:DN Y
 ;W ?22 X DXS(3,9) K DIP K:DN Y
 ; new code
 ; added "Associated patches", which are found in the 
 ; "Q" nodes of the D0 entry
 N D1,ASPIEN,ASPNM,REQ4VER,ASPSTAT,SPC,EXPTCH S D1=0
 F  S D1=$O(^A1AE(11005,D0,"Q",D1)) Q:'D1  D
 . S ASPIEN=$P(^A1AE(11005,D0,"Q",D1,0),"^") ; Associated Patch
 . S ASPNM=$P(^A1AE(11005,ASPIEN,0),"^")
 . S REQ4VER=$P(^A1AE(11005,D0,"Q",D1,0),"^",2) ; Reqd for verific
 . S REQ4VER=$S(REQ4VER["y":"<<= must be installed BEFORE",1:"install with patch")
 . S SPC=$S($L(REQ4VER)<20:39,1:35)
 . S ASPSTAT=$$GET1^DIQ(11005,ASPIEN,8,"I") ; Status of patch
 . S EXPTCH=$P(^A1AE(11005,D0,0),"^")
 . I D1=1 W !,?0,"Associated patches:",?20,"(",ASPSTAT,")",ASPNM,?SPC,REQ4VER,?64,"`",EXPTCH,"'" Q
 . W !,?20,"(",ASPSTAT,")",ASPNM,?SPC,REQ4VER,?64,"`",EXPTCH,"'" Q
 ;
 ; Print "Subject" and "Category"
 D T Q:'DN  D N D N:$X>0 Q:'DN  W ?0 W "Subject:"
 S X=$G(^A1AE(11005,D0,0)) W ?10,$E($P(X,U,5),1,70)
 D T Q:'DN  D N D N:$X>0 Q:'DN  W ?0 W "Category:"
 ; new code
 W !
 ; 
 S I(1)="""C""",J(1)=11005.05 F D1=0:0 Q:$O(^A1AE(11005,D0,"C",D1))'>0  X $G(DSC(11005.05))  S D1=$O(^(D1)) Q:D1'>0   D:$X>11 T Q:'DN  D A1
 G A1R
 ;
A1 ;Prints Category(ies)
 ; new code
 S X=$G(^A1AE(11005,D0,"C",D1,0)),Y=$P(X,U,1)
 W ?2 W:Y]"" "- ",$$TITLE^XLFSTR($E($$SET^DIQ(11005.05,.01,Y),1,17))
 ; old code
 ;S X=$G(^A1AE(11005,D0,"C",D1,0)) W ?11 S Y=$P(X,U,1) W:Y]"" $E($$SET^DIQ(11005.05,.01,Y),1,17)
 Q
 ; Prints Patch Description
A1R ;
 D T Q:'DN  D N D N:$X>0 Q:'DN  W ?0 W "Description:"
 D N:$X>0 Q:'DN  W ?0 W "==========="
 D N:$X>0 Q:'DN  W ?0 W " "
 ; new code
 N A1AESTOP S A1AESTOP=0
 D N:$X>0 Q:'DN  W ?0 S:'$D(DIWF) DIWF="" S:DIWF'["N" DIWF=DIWF_"N"
 S X="" S I(1)="""D""",J(1)=11005.01
 F D1=0:0 Q:$O(^A1AE(11005,D0,"D",D1))'>0  D
 . S D1=$O(^(D1)) D:$X>3 T Q:'DN  D:'A1AESTOP B1
 ; old code
 ;D N:$X>0 Q:'DN  W ?0 S:'$D(DIWF) DIWF="" S:DIWF'["N" DIWF=DIWF_"N" S X="" S I(1)="""D""",J(1)=11005.01 F D1=0:0 Q:$O(^A1AE(11005,D0,"D",D1))'>0  S D1=$O(^(D1)) D:$X>3 T Q:'DN  D B1
 ;
 G B1R
B1 ;
 ; new code
 S X=" "_$G(^A1AE(11005,D0,"D",D1,0))
 S:X["Associated patches:" A1AESTOP=1
 I 'A1AESTOP S DIWL=1,DIWR=78 D ^DIWP
 ; old code
 ;S X=$G(^A1AE(11005,D0,"D",D1,0)) S DIWL=1,DIWR=78 D ^DIWP
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
 ; new code - do not indent
 D N:$X>2 Q:'DN  W ?0 W "Entered By  : "
 ; old code
 ;D N:$X>2 Q:'DN  W ?2 W "Entered By  : "
 ;
 S X=$G(^A1AE(11005,D0,0)) W ?14 S Y=$P(X,U,9) S Y=$S(Y="":Y,$D(^VA(200,Y,0))#2:$P(^(0),U),1:Y) W $E(Y,1,20)
 D N:$X>39 Q:'DN  W ?45 W "Date Entered : "
 ; new code (Date First Entered field may be -1 or blank in 11005)
 ;  if Y is not a date, leave blank
 W ?60 S Y=$P(X,U,12) D:(Y>0) DT
 ; old code
 ;W ?57 S Y=$P(X,U,12) D DT
 ;
 ; new code - do not indent
 D N:$X>2 Q:'DN  W "Completed By: "
 ; old code
 ;D N:$X>2 Q:'DN  W ?2 W "Completed By: "
 ;
 W ?14 S Y=$P(X,U,13) S Y=$S(Y="":Y,$D(^VA(200,Y,0))#2:$P(^(0),U),1:Y) W $E(Y,1,20)
 D N:$X>39 Q:'DN  W ?44 W "Date Completed: "
 W ?60 S Y=$P(X,U,10) D DT
 ; new code - do not indent
 D N:$X>2 Q:'DN  W "Released By : "
 ; old code
 ;D N:$X>2 Q:'DN  W ?2 W "Released By : "
 ;
 W ?14 S Y=$P(X,U,14) S Y=$S(Y="":Y,$D(^VA(200,Y,0))#2:$P(^(0),U),1:Y) W $E(Y,1,20)
 D N:$X>39 Q:'DN  W ?44 W "Date Released : "
 W ?60 S Y=$P(X,U,11) D DT
 D T Q:'DN  D N D N:$X>0 Q:'DN  W ?0 N A1AEPRNT S A1AEPRNT=1 D USERS^A1AEMAL(D0) K DIP K:DN Y
 D N:$X>0 Q:'DN  W ?0 W "============================================================================="
 S:'$D(A1AEHD) A1AEHD="Patch Details" D PRT^A1AEUTL:A1AEHD'["Display"&(A1AEOUT'["^") K DIP K:DN Y
 K Y K DIWF
 Q
HEAD ;
 W !,"--------------------------------------------------------------------------------",!!
