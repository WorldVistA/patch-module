A1AEUSPL ;VEN/JLI - Unit tests for A1AESPLT routine ;2015-06-13  8:39 PM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 I $T(EN^%ut)'="" D EN^%ut("A1AEUSPL")
 Q
 ;
SPLIT ; @TEST - setting up a initial patch in a new stream and releasing it
 N A1AEDA,DA,DAIEN,DIK,PKGIEN,SEQ,STREAM,VERIEN,XMDA,XMIEN,XMTITLE
 L +^A1AE(11005):1 I '$T W !,"SKIPPING TEST OF SETPACKG^A1AESPLT - can't get lock" Q
 S PKGIEN=$P(^DIC(9.4,0),U,3)+200 ;
 S VERIEN=1 S ^DIC(9.4,PKGIEN,0)="ZZJJ TEST PACKAGE^ZZJJ^ZZDESCRIPTION^"
 S ^DIC(9.4,PKGIEN,22,0)="^9.49I^2^2"
 S ^DIC(9.4,PKGIEN,22,1,0)="1.0^3150326^3150326^799"
 S ^DIC(9.4,PKGIEN,8,22,1,"PAH",0)="^9.4901^^"
 S ^A1AE(11007.1,4001,0)="TEST STREAM^0^^^TS^O^TEST.STREAM.ORG"
 S ^A1AE(11007,PKGIEN,0)=PKGIEN_"^Y^n^n^y"
 S STREAM=4001
 ;
 ;SETPACKG ; set up for releasing a patch in a new stream
 D SETPACKG^A1AESPLT(PKGIEN,VERIEN,STREAM)
 ;
 S DA=$O(^A1AE(11005,"B","ZZJJ*1*4001",""))
 D CHKTF(DA>0,"No entry created in 11005 for ZZJJ*1*4001")
 ;
 D CHKTF($D(^A1AE(11007,PKGIEN,"V",VERIEN,1,4001,"PB")),"No ""PB"" entry under DHCP PATCH/PROBLEM PACKAGE")
 D CHKEQ($G(^A1AE(11007,PKGIEN,"V",VERIEN,1,4001,"PB")),4001,"Bad entry value for ""PB"" in 11007")
 D CHKEQ($G(^A1AE(11005.1,+DA,2,3,0)),"This patch marks the release of the TEST STREAM stream for ","Missing expected entry in file 1105.1")
 D CHKEQ($G(^A1AE(11005.1,A1AEIEN,2,194,0)),"$END KID ZZJJ*1.0*4001","Last enry in file 11005.1 message not as expected.")
 ;
 ;RELSSTRM - release the stream data
 S SEQ=20
 S A1AEDA=DA
 D RELSSTRM^A1AESPLT(DA,PKGIEN,VERIEN,SEQ)
 S XMIEN=$O(^XMB(3.9,"Released ZZJJ*1*4001 SEQ #20","")),XMDA=XMIEN
 I XMIEN'>0 S XMIEN=$P(^XMB(3.9,0),U,3),XMTITLE=$P(^XMB(3.9,XMIEN,0),U)
 D CHKEQ(XMTITLE,"Released ZZJJ*1*4001 SEQ #20","Incorrect title for release message")
 D CHKEQ($G(^A1AE(11007,PKGIEN,"V",VERIEN,1,4001,"PH")),4001,"Bad entry value for ""PH"" in 11007")
 ; W !,"XMDA=",+XMDA,"  DA=",DA
 ; W !!!! ZWR ^A1AE(11005,A1AEDA,*)
 ; W !!!! ZWR ^A1AE(11007,PKGIEN,*)
 ; W !!!! ZWR ^A1AE(11007.1,4001,*)
 ; W !!!! ZWR ^A1AE(11005.1,A1AEDA,*)
 ; I XMDA>0 W !!!! ZWR ^XMB(3.9,XMDA,*)
 ; and clean up
 I XMDA>0 S DA=XMDA,DIK="^XMB(3.9," D ^DIK
 S DA=STREAM,DIK="^A1AE(11007.1," D ^DIK
 S DA=$P(^A1AE(11005,0),U,3) I $P(^A1AE(11005,DA,0),U)="ZZJJ*1*4001" D
 . S DAIEN=DA,DIK="^A1AE(11005.1," D ^DIK
 . S DA=DAIEN,DIK="^A1AE(11005," D ^DIK
 K ^DIC(9.4,VERIEN)
 L -^A1AE(11005)
 Q
 ;
CHKEQ(ARG1,ARG2,MESSG) ;
 D CHKEQ^%ut(ARG1,ARG2,MESSG)
 Q
 ;
CHKTF(COND,MESSG) ;
 D CHKTF^%ut(COND,MESSG)
 Q
 ;
EOR ;
