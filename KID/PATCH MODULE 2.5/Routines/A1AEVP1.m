A1AEVP1 ;isa/rmo,pke-update as printed ;2014-03-28T17:39
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;1992-12-02: version 2.2 released
 ;
 S A1AEUSR=DUZ,A1AEUSNM=$P(^VA(200,DUZ,0),U)
 W !?2,"Are you sure you want to update the print status"
 S A1AERD("A")="     for ALL your selected packages ? "
 ;S A1AERD("A")="Are you sure you want to update the print status for ALL your selected packages ? "
 S A1AERD(1)="Yes^update your print status of released patches"
 S A1AERD(2)="No^do not update your print status"
 S A1AERD(0)="S",A1AERD("B")=2 D SET^A1AERD K A1AERD D UPDATE:"Y"[$E(X,1)
 ;
Q K A1AEUSNM,A1AEDTV,A1AEIFN,A1AEPKIF,A1AEUSR
 Q
 ;
UPDATE W !!,"Overriding patch print status for ",A1AEUSNM,"'s selected packages.",! S %DT="",X="T" D ^%DT S DT=Y
 F A1AEPKIF=0:0 S A1AEPKIF=$O(^A1AE(11007,"AU",A1AEUSR,A1AEPKIF)) Q:'A1AEPKIF  I $D(^A1AE(11007,A1AEPKIF,0)),$P(^(0),"^",2)="Y",$D(^DIC(9.4,A1AEPKIF,0)) W !?3,"Updating print status for ",$P(^(0),"^",2)," patches..." D CHKDTV
 Q
 ;
CHKDTV F A1AEDTV=0:0 S A1AEDTV=+$O(^A1AE(11005,"AV",A1AEPKIF,A1AEDTV)) Q:'A1AEDTV  F A1AEIFN=0:0 S A1AEIFN=+$O(^A1AE(11005,"AV",A1AEPKIF,A1AEDTV,A1AEIFN)) Q:'A1AEIFN  I '$D(^A1AE(11005,A1AEIFN,2,A1AEUSR)) D SETPRT
 Q
 ;
SETPRT W !?6,$P(^A1AE(11005,A1AEIFN,0),"^")
 L +^A1AE(11005,A1AEIFN,2):0 E  W $C(7),"Couldn't obtain lock at SETPRT. Try again later." QUIT
 S:'$D(^A1AE(11005,A1AEIFN,2,0)) ^(0)="^11005.02P^^"
 S:'$D(^A1AE(11005,A1AEIFN,2,A1AEUSR,0)) $P(^(0),"^",1,2)=A1AEUSR_"^"_DT,$P(^(0),"^",4)=$P(^A1AE(11005,A1AEIFN,2,0),"^",4)+1
 S $P(^A1AE(11005,A1AEIFN,2,A1AEUSR,0),"^",3)=DT
 S $P(^A1AE(11005,A1AEIFN,2,0),"^",3)=A1AEUSR
 S ^A1AE(11005,"AU",A1AEUSR,+$P(^A1AE(11005,A1AEIFN,0),"^",2),(9999999-DT))=""
 L -^A1AE(11005,A1AEIFN,2)
 Q
