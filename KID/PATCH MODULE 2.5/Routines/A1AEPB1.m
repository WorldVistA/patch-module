A1AEPB1 ;ise/rmo,mjk-Entry/Edit Problem Menu ;1987-11-24T11:00
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;1992-11-23: version 2.2 released
 ;
 ;
 G:$D(^DOPT("A1AEPB1",5)) A S ^DOPT("A1AEPB1",0)="Entry/Edit Problem Menu Option^1N^" F I=1:1 S X=$T(@I) Q:X=""  S ^DOPT("A1AEPB1",I,0)=$P(X,";;",2,99)
 S DIK="^DOPT(""A1AEPB1""," D IXALL^DIK
A W !! S DIC="^DOPT(""A1AEPB1"",",DIC(0)="AEQM" D ^DIC Q:Y<0  D @+Y G A
 ;
1 ;;Add a New Problem
 S A1AEFL=11006,A1AETY="PB",DIC("S")="I $D(^A1AE(11007,+Y,A1AETY,DUZ,0))" D PKG^A1AEUTL G Q:'($D(A1AEPK)&$D(A1AEVR)) D NUM^A1AEUTL G Q:'$D(A1AEPD)
 W !!,"Adding Problem: ",A1AEPD,! S $P(^A1AE(A1AEFL,DA,0),"^",8)=DUZ,$P(^(0),"^",9)=DT,$P(^(0),"^",10)="n",DIE="^A1AE(A1AEFL,",DR="[A1AE ADD/EDIT PROBLEMS]" D ^DIE
 G Q
 ;
2 ;;Delete an Existing Problem
 S A1AEFL=11006,DIC("A")="Select PROBLEM: ",DIC("S")="I $P(^(0),U,8)=DUZ,($P(^(0),U,10)=""c""!($P(^(0),U,10)=""n""))",DIC="^A1AE(A1AEFL,",DIC(0)="AEMQ" W ! D ^DIC K DIC("A"),DIC("S") G Q:Y<0 S DA=+Y,A1AEPD=$P(Y,U,2)
PMT2 W !!,"Are you sure you want to delete problem "_A1AEPD_"? N// " R X:DTIME G Q:'$T!(X="^")!("Nn"[$E(X,1)) G DEL2:"Yy"[$E(X,1) W:X'["?" *7 W !!,"Enter Y to delete the selected problem, or N to exit." G PMT2
DEL2 S DIK="^A1AE(A1AEFL," D ^DIK W !!?3,"...deletion of "_A1AEPD_" from 'Problem File completed"
 G Q
 ;
3 ;;Edit an Existing Problem
 S A1AEFL=11006,DIC("A")="Select PROBLEM: ",DIC("S")="I $P(^(0),U,8)=DUZ,($P(^(0),U,10)=""c""!($P(^(0),U,10)=""n""))",DIC="^A1AE(A1AEFL,",DIC(0)="AEQM" W ! D ^DIC K DIC("A"),DIC("S") G Q:Y<0 S DA=+Y,A1AEPD=$P(Y,U,2)
 W !!,"Editing Problem: ",A1AEPD,! S DIE="^A1AE(A1AEFL,",DR="[A1AE ADD/EDIT PROBLEMS]" D ^DIE
 G Q
 ;
4 ;;Resolve/Review an Existing Problem
 S A1AEFL=11006,DIC("A")="Select PROBLEM: ",DIC("S")="I $P(^(0),U,10)'=""n"",$D(^A1AE(11007,+$P(^(0),U,2),""PH"",DUZ,0))",DIC="^A1AE(A1AEFL,",DIC(0)="AEMQ" W ! D ^DIC K DIC("A"),DIC("S") G Q:Y<0 S A1AEIFN=+Y,A1AEPD=$P(Y,U,2)
 W ! S L=0,DIC="^A1AE(A1AEFL,",FLDS="[A1AE PROBLEM DETAILS]",BY="@.01",FR=A1AEPD,TO=A1AEPD S IOP="HOME" D EN1^DIP K FLDS,BY,L,FR,TO,IOP
 R !!,"Do you want to Change the Status of this Problem? N// ",X:DTIME G Q:'$T!(X="^")!("Nn"[$E(X,1)) S DA=A1AEIFN,DIE="^A1AE(A1AEFL,",DR="[A1AE CHANGE PROBLEM STATUS]" D ^DIE
 ;
Q K A1AEIFN,A1AEPKIF,A1AEPKNM,A1AEONE,A1AEPD,A1AEPK,A1AEVR,A1AENB,A1AEFL,A1AETY
