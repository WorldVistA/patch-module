A1AEPK ;isf/rwf-package module ;2015-05-26T22:53
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ; CHANGE 2015 05 26: (VEN/LGC)
 ;  linetag DEL2+3
 ;  Change at linetag to account for sequence number
 ;  and patch numbers now being tracked by PATCH SEQUENCE
 ;
 G:$D(^DOPT("A1AEPK",5)) A S ^DOPT("A1AEPK",0)="Entry/Edit Package Menu Option^1N^" F I=1:1 S X=$T(@I) Q:X=""  S ^DOPT("A1AEPK",I,0)=$P(X,";;",2,99)
 S DIK="^DOPT(""A1AEPK""," D IXALL^DIK
A W !! S DIC="^DOPT(""A1AEPK"",",DIC(0)="AEMQ" D ^DIC Q:Y<0  D @+Y G A
 ;
1 ;;Add a Package
 N A1AEFL,A1AETY,A1AEPKIF,A1AEPK,A1AEVR
 S A1AEFL=11005,A1AETY="PK",DIC("S")="I $D(^A1AE(11007,+Y,""PH"",DUZ,0))" D PKG^A1AEUTL G Q:'$D(A1AEPK)
 D VER G Q:'$D(A1AEVR)
 S A1AENB=0,X=A1AEPK_"*"_A1AEVR_"*0",DIC="^A1AE(11005,",DIC(0)="LE" D ^DIC Q:Y<1
 S DA=+Y,A1AEPD=$P(Y,U,2),A1AEPD2=$TR($P(A1AEPD,"*",1,2),"*"," "),$P(^A1AE(11005,DA,0),U,2,4)=A1AEPKIF_U_A1AEVR_U_"0"
 W !!,"Package Added: ",A1AEPD2,!
 S $P(^A1AE(11005,DA,0),"^",8)="u",$P(^(0),"^",9)=DUZ,$P(^(0),"^",12)=DT,^A1AE(11005,"AS",A1AEPKIF,A1AEVR,"u",A1AENB,DA)=""
 S DIE="^A1AE(11005,",DR="40///"_A1AEPD2 D ^DIE ;New Package Name
 ;
 S (X,DINUM)=DA,DIC="^A1AE(11005.1,",DIC("DR")="20///"_"No routines included" K DD,DO D FILE^DICN K DE,DQ,DR,DIC("DR")
 S (X,DINUM)=DA,DIC="^A1AE(11005.5," K DD,D0 D FILE^DICN K DE,DQ,DR
 ;
 S DR="[A1AE ADD/EDIT PATCHES]" D ^DIE K DQ,DE,DIE
 D Q G 1
 ;
2 ;;Delete an Unverified Package
 N DIC,A1AEPD,A1AEPD2
 S DIC("A")="Select Package: ",DIC("S")="I ($P(^(0),U,8)=""u""!($P(^(0),U,8)=""c"")),$D(^A1AE(11007,+$P(^(0),U,2),""PH"",DUZ,0))",DIC="^A1AE(11005,",DIC(0)="AEMQZ" W ! D ^DIC K DIC("A"),DIC("S") G Q:Y<0 S DA=+Y,A1AEPD=$P(Y,U,2),A1AE0=Y(0)
 S $P(A1AEPD,"*",2)=$S($P(A1AEPD,"*",2)=999:"DBA",1:$P(A1AEPD,"*",2))
 S A1AEPD2=$P($G(^A1AE(11005,DA,4)),U,1)
PMT2 W !!,"Are you sure you want to delete package "_A1AEPD2_"? N// " R X:DTIME G Q:'$T!(X="^")!("Nn"[$E(X,1)) G DEL2:"Yy"[$E(X,1) W:X'["?" *7 W !!,"Enter Y to delete the selected patch, or N to exit." G PMT2
DEL2 S DIK="^A1AE(11005," D ^DIK W !!?3,"...deletion of "_A1AEPD_" from 'DHCP Patch File' completed"
 ;
 ; CHANGE 2015 05 26: (VEN/LGC)
 ;  Necessary as NEXT PATCH NUMBER and NEXT SEQUENCE NUMBER
 ;   are now dependent on the user's PATCH STREAM
 ;     A1AE0 = zero node of entry into 11005
 ;     PATCH NUMBER [#4 field] = $P(A1AE0,"^",4)
 ;     S STRM=$P(A1AE(0),U,20)  [PATCH STREAM (e.g. 10001)]
 ; ^A1AE(11007,$P(A1AE0,"^",2),"V",$P(A1AE0,"^",3),1,STRM,"PH")
 ; new code
 N STRM S STRM=$P(A1AE(0),U,20)
 L +^A1AE(11007,$P(A1AE0,"^",2),"V",$P(A1AE0,"^",3),1,STRM,"PH"):0 E  W $C(7),"Couldn't obtain lock at "_$ST($ST,"PLACE"),! QUIT
 I $D(^A1AE(11007,$P(A1AE0,"^",2),"V",$P(A1AE0,"^",3),1,STRM,"PH")) S:$P(A1AE0,"^",4)<^("PH") ^("PH")=$P(A1AE0,"^",4)
 L -^A1AE(11007,$P(A1AE0,"^",2),"V",$P(A1AE0,"^",3),1,STRM,"PH")
 ; original code
 ;L +^A1AE(11007,$P(A1AE0,"^",2),"V",$P(A1AE0,"^",3),"PH"):0 E  W $C(7),"Couldn't obtain lock at "_$ST($ST,"PLACE"),! QUIT
 ;       I $D(^A1AE(11007,$P(A1AE0,"^",2),"V",$P(A1AE0,"^",3),"PH")) S:$P(A1AE0,"^",4)<^("PH") ^("PH")=$P(A1AE0,"^",4)
 ;       L -^A1AE(11007,$P(A1AE0,"^",2),"V",$P(A1AE0,"^",3),"PH")
 ;delete message entry
 S DIK="^A1AE(11005.1," D ^DIK
 G Q
 ;
3 ;;Edit a Package
 N A1AESTOP
 S A1AESTOP=0
 F  D  D Q Q:A1AESTOP
 . N DIC,X,Y,DA,A1AEPD
 . S DIC("A")="Select Package: "
 . S DIC("S")="I $D(^A1AE(11007,+$P(^(0),U,2),""PH"",DUZ,0))"
 . S DIC="^A1AE(11005,",DIC(0)="AEMQ"
 . W !
 . D ^DIC I Y<0 S A1AESTOP=1 Q
 . S DA=+Y,A1AEPD=$P(Y,U,2),A1AEPD2=$P($G(^A1AE(11005,DA,4)),U) K DIC Q:A1AEPD2=""
 . L +^A1AE(11005,DA):5 E  D  Q
 . . W !,$C(7),"This package is being edited by another user" H 3
 . ;I $P(A1AEPD,"*",2)=999 S $P(A1AEPD,"*",2)="DBA"
 . I '$D(^A1AE(11005.1,DA,0)) D
 . . N DINUM,DD,DO,DIC
 . . S (X,DINUM)=DA,DIC(0)="LE",DIC="^A1AE(11005.1,"
 . . S DIC("DR")="20///No routines included"
 . . D FILE^DICN
 . W !!,"Editing Package: ",A1AEPD2,!
 . N A1AEOLD
 . S A1AEOLD=$P($G(^A1AE(11005,DA,0)),U,8)
 . D
 . . N A1AEOLD,DIE,DR ; Preserve A1AEOLD.  It's killed in Q^A1AEPHS
 . . S DIE="^A1AE(11005,",DR="[A1AE ADD/EDIT PATCHES]"
 . . D ^DIE
 . N A1AE0,A1AENEW
 . S A1AE0=$G(^A1AE(11005,DA,0))
 . L -^A1AE(11005,DA)
 . S A1AENEW=$P(A1AE0,U,8)
 . I A1AEOLD'="v"!(A1AENEW'="e") Q
 . ; Send the 'Entered in Error' bulletin
 . N A1AETX,X,A1AEOPT
 . S A1AEOPT="'Entered in Error'"
 . S X=$$GET1^DIQ(11005,DA_",",8.5,"Z","A1AETX")
 . S A1AETX(.1,0)=""
 . S A1AETX(.2,0)="Entered in Error Description:"
 . D BOTH^A1AEPHS
 Q
 ;
4 ;;Verify a Package
 N A1AEPKV
 S A1AEPKV=1
 S DIC("A")="Select Package: ",DIC("S")="I $P(^(0),U,8)=""c"",$D(^A1AE(11007,+$P(^(0),U,2),""PB"",DUZ,0)),$P(^(0),U,2)=""V""",DIC="^A1AE(11005,",DIC(0)="AEMQZ"
 W ! D ^DIC K DIC G Q:Y<0 S (A1AEIFN,DA)=+Y,A1AEPD=$P(Y,U,2),A1AEPD2=$P($G(^A1AE(11005,DA,4)),U)
 I A1AEPD2="" W !,"This is not a Package Entry." Q
 ;S $P(A1AEPD,"*",2)=$S($P(A1AEPD,"*",2)=999:"DBA",1:$P(A1AEPD,"*",2))
 ;
 S Y=$P(Y(0),"^",17) I Y,Y>DT W !!,"Do not release until: ",$$FMTE^XLFDT(Y)
 S A1AEST=$S($P(Y(0),U,7)="e":2,1:61) ;Package complience is 60 days.
 ;
 W !!,"Internal Comments to developers/releasers for: ",A1AEPD2,! K Y S DIE="^A1AE(11005,",DR="16;" D ^DIE K DQ,DE,DIE,DIC,DR,D0,DA
 W ! S DIR(0)="Y",DIR("B")="No",DIR("A")="Continue and Display Patch " D ^DIR K DIR I 'Y D Q G 4
 ;check routine patches
 F AX=0:0 S AX=$O(^A1AE(11005,A1AEIFN,"P",AX)) Q:'AX  I $D(^(AX,0)) S X=^(0) D RCHK^A1AEM2
 W ! S DIR(0)="E" D ^DIR K DIR I 'Y D Q G 4
 ;
 S D0=A1AEIFN,A1AEVPR="",A1AEHD="DHCP Completed/NotReleased Patch Display"
 W ! S %ZIS="",A1AEPGE=0 D ^%ZIS G Q:POP K IOP,%ZIS U IO S ^UTILITY($J,1)="D HD^A1AEPH2",DIWF="B4|" K ^UTILITY($J,"W"),DXS D HD^A1AEPH2,^A1AEP
 K DN,DXS,DIWF
 K A1AEHD,A1AELNE,A1AEOUT,A1AEPGE,A1AEVPR D CLOSE^A1AEUTL1
 S A1AEST=$$FMADD^XLFDT(DT,A1AEST)
 W !!,"Releasing Package: ",A1AEPD2,! K Y
 S DA=A1AEIFN,DIE="^A1AE(11005,",DR="18//^S X=A1AEST;8;S Y=$S(X=""e"":""@10"",1:"""");@10;8.5"
 L +@(DIE_DA_")"):5
 I '$T W !,$C(7),"This package is being released by another user" H 3
 E  D ^DIE,UPVER K DQ,DE L -@(DIE_DA_")")
 D Q G 4
 ;
6 ;;Create a packman message
 G PACK^A1AEM
 ;
7 ;;Forward a Complete/unverified message
 G FCOM^A1AEM2
 ;
8 ;;Forward a Verified patch message
 G FVER^A1AEM2
 ;
Q K ^UTILITY($J,"A1AECOP"),A1AEOLPD,A1AE0,A1AEPKIF,A1AEPKNM,A1AEPD,A1AEPD2,A1AEPK,A1AEVR,A1AENB,A1AEFL,A1AETY
 K DIK,A1AEHD,A1AEIFN,A1AELNE,A1AEOUT,A1AEPGE,A1AEVPR
 K AEQ,A1AESUB,A1AETX,A1AEXMZ,A1NAM,A1NAM1,AX,AXMZ,A1AEST,A1AETVR
 K JL2,SAVEX,C,D0,DA,DI,DIG,DIH,DIW,DIV,DR,XMB,XMDT,XMDUZ,XMM,XMSUB Q
 ;
VER ;Get a NEW Version #.
 N VR,CV K A1AEVR
 ;Start at 999 so se don't get the DBA version.
 S CV=$O(^A1AE(11007,A1AEPKIF,"V",999),-1) I CV>0 S CV=$G(^A1AE(11007,A1AEPKIF,"V",CV,0))
 I CV W !,"The current version number is ",+CV,"  Verified on ",$$FMTE^XLFDT($P(CV,U,2))
 S CV=+CV
 R !,"New Version Number: ",VR:DTIME Q:'VR
 I VR'>CV W !,"The New Package Version must be greater than the current version of ",CV G VER
 S A1AEVR=VR
 Q
 ;
UPVER ;Update files 11007 and 120102.
 N FDA,VR,IEN,X
 S VR=$P(^A1AE(11005,A1AEIFN,4),U),VR=$P(VR," ",$L(VR," "))
 S IEN=$P(^A1AE(11005,A1AEIFN,0),U,2)
 S ^A1AE(11007,IEN,"V",VR,0)=VR_U_$$DT^XLFDT() ;DINUM entry
 ; VEN/JLI 150529 - commented out next line, added following to handle streams
 ;S ^A1AE(11007,IEN,"V",VR,"PB")=0,^("PH")=0,^("PR")=0 ; JLI 150529
 N A1AESTRM S A1AESTRM=$$PRIMSTRM^A1AEUTL()
 S ^A1AE(11007,IEN,"V",VR,1,A1AESTRM,"PB")=0,^("PH")=A1AESTRM,^("PR")=0
 ; VEN/JLI 150529 - end of modification
 ;Now for file DHCP APPLICATION (#120102)
 K FDA,IEN
 S X=$P(^A1AE(11005,A1AEIFN,0),U),X=$P(X,"*")
 S IEN=$$FIND1^DIC(120102,,"MX",X) Q:IEN'>0
 S FDA(120102,IEN_",",1)=VR D FILE^DIE("K","FDA")
 Q
