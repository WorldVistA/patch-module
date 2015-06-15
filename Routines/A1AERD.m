A1AERD ;isa/rmo,mjk-read processor ;1987-11-24T11:00
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;1992-12-02: version 2.2 released
 ;
 ;
SET S:'$D(A1AERD(0)) A1AERD(0)="" W:A1AERD(0)'["S" !?2,"Choose one of the following:"
 F I=0:0 S I=$O(A1AERD(I)) Q:'I  W:A1AERD(0)'["S" !?10,$P(A1AERD(I),"^",1) S V=$P(A1AERD(I),"^",1) D UPPER S $P(A1AERD(I),"^",3)=S
READ K S,I,J,T,L,I W !!,$S($D(A1AERD("A")):A1AERD("A"),1:"Enter Response: ")
 I $D(A1AERD("B")),$D(A1AERD(A1AERD("B"))) W $P(A1AERD(A1AERD("B")),"^",1),"// "
 R X:$S($D(A1AERD("DTIME")):+A1AERD("DTIME"),1:DTIME) S X1=X G HELP:X="?" S T=$T,DTOUT='T,L=$L(X) I X["^" S X="^" G Q
 I 'T,'$D(A1AERD("DTOUT")) S X="^" G Q
 I 'T,$D(A1AERD("DTOUT")),'$D(A1AERD(+A1AERD("DTOUT"))) S X="^" G Q
 I 'T S X=$P(A1AERD(+A1AERD("DTOUT")),"^",1) G Q
 I 'L,'$D(A1AERD("B")) S X="" G Q
 I 'L,'$D(A1AERD(+A1AERD("B"))) S X="" G Q
 I 'L S X=$P(A1AERD(+A1AERD("B")),"^",1) G Q
 S V=X D UPPER
 F I=0:0 S I=$O(A1AERD(I)) Q:'I  I S=$E($P(A1AERD(I),"^",3),1,L) S X=$P(A1AERD(I),"^",1) W $E(X,L+1,99) G Q
 W *7
HELP ;
 I $D(A1AERD("XQH")) S XQH=A1AERD("XQH") D EN^XQH W ! G SET
 W !!?2,"Enter one of the following:"
 F I=0:0 S I=$O(A1AERD(I)) Q:'I  W !?5,"'",$P(A1AERD(I),"^",1),"'",?25,"to ",$E($P(A1AERD(I),"^",2),1,79-$X)
 W !?5,"^",?25,"to stop." G READ
 ;
Q K DTOUT,S,C,I,L Q
 ;
UPPER ;
 S S="" F J=1:1 S C=$E($P(V,"^",1),J) Q:C=""  S:$A(C)>96&($A(C)<123) C=$C($A(C)-32) S S=S_C
 K C,V Q
