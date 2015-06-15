A1AEPH1 ;isa/rmo,mjk,ven/toad-patch control ;2015-05-29T22:26
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ; contents:
 ;
 ; 1. Add a Patch
 ; 2. Delete a Patch
 ; 3. Edit a Patch
 ; 4. Verify a Patch
 ; 5. Copy a Patch into a New Patch => ^A1AEPH8
 ; 6. Create a Packman Message => PACK^A1AEM
 ; 7. Forward a Complete/unverified Message => FCOM^A1AEM2
 ; 8. Forward a Verified Patch Message => FVER^A1AEM2
 ;
 ; change history:
 ;
 ; 2014-03-28, ven/toad: Rick Marshall of the VISTA Expertise Network
 ; refactored 1 to make clearer if and where the .2 field of file 11005
 ; is being set.
 ;
 ; 2015-05-26/9, ven/toad: initial refactoring of subroutine 1 for readability.
 ; Refactor subroutines A1AEPH1 & 2 for readability.
 ;
 ; TO DO: comment it.
 ;
 I '$D(^DOPT("A1AEPH1",5)) D
 . S ^DOPT("A1AEPH1",0)="Entry/Edit Patch Menu Option^1N^"
 . F I=1:1 D  Q:X=""
 . . S X=$T(@I)
 . . Q:X=""
 . . S ^DOPT("A1AEPH1",I,0)=$P(X,";;",2,99)
 . . Q
 . ;
 . S DIK="^DOPT(""A1AEPH1"","
 . D IXALL^DIK
 . Q
 ;
 F  D  Q:Y<0
 . W !!
 . S DIC="^DOPT(""A1AEPH1"","
 . S DIC(0)="AEMQ"
 . D ^DIC
 . Q:Y<0
 . D @+Y
 . Q
 ;
 QUIT  ; end of A1AEPH1
 ;
 ;
1 ;;Add a Patch
 ; option add a patch [A1AE PHADD]
 ;
 S A1AEFL=11005
 S A1AETY="PH"
 S DIC("S")="I $D(^A1AE(11007,+Y,A1AETY,DUZ,0))"
 D PKG^A1AEUTL
 G Q:'$D(A1AEPK)
 ;
 S A1AE(0)="AEQL"
 D VER^A1AEUTL
 G Q:'$D(A1AEVR)
 ;
 D NUM^A1AEUTL
 G Q:'$D(A1AEPD)
 S $P(A1AEPD,"*",2)=$S($P(A1AEPD,"*",2)=999:"DBA",1:$P(A1AEPD,"*",2))
 ;
 W !!,"Patch Added: ",A1AEPD,!
 S $P(^A1AE(11005,DA,0),U,8)="u"
 S $P(^(0),U,9)=DUZ
 S $P(^(0),U,12)=DT
 S ^A1AE(11005,"AS",A1AEPKIF,A1AEVR,"u",A1AENB,DA)=""
 ;
 S DIE="^A1AE(11005,"
 I $P(A1AEPD,"*",2)="DBA" D
 . S DR="6.5///db"
 . D ^DIE
 . K DE,DQ,DR
 ;
 S (X,DINUM)=DA
 S DIC="^A1AE(11005.1,"
 S DIC("DR")="20///"_"No routines included"
 K DD,DO
 D FILE^DICN
 K DE,DQ,DR,DIC("DR")
 ;
 S DR="[A1AE ADD/EDIT PATCHES]"
 D ^DIE
 K DQ,DE,DIE
 D Q
 ;
 GOTO 1 ; end of 1
 ;
 ;
2 ;;Delete a Patch
 ; option delete a patch [A1AE PHDEL]
 ; no longer called by Menuman, which now directly calls option^A1AEPHD
 ;
 D OPTION^A1AEPHD
 ;
 quit  ; end of 2
 ;
 ;
3 ;;Edit a Patch
 ; option edit a patch [A1AE PHEDIT]
 ;
 N A1AESTOP
 S A1AESTOP=0
 F  D  D Q Q:A1AESTOP
 . N DIC,X,Y,DA,A1AEPD
 . S DIC("A")="Select PATCH: "
 . S DIC("S")="I $D(^A1AE(11007,+$P(^(0),U,2),""PH"",DUZ,0))"
 . S DIC="^A1AE(11005,",DIC(0)="AEMQ"
 . W !
 . D ^DIC I Y<0 S A1AESTOP=1 Q
 . S DA=+Y,A1AEPD=$P(Y,U,2) K DIC
 . I $P(A1AEPD,"*",2)=999 S $P(A1AEPD,"*",2)="DBA"
 . I '$D(^A1AE(11005.1,DA,0)) D
 . . N DINUM,DD,DO,DIC
 . . S (X,DINUM)=DA,DIC(0)="LE",DIC="^A1AE(11005.1,"
 . . S DIC("DR")="20///No routines included"
 . . D FILE^DICN
 . W !!,"Editing Patch: ",A1AEPD,!
 . L +^A1AE(11005,DA):5 E  D  Q
 . . W !,$C(7),"This patch is being edited by another user" H 3
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
 ;
 QUIT  ; end of 3
 ;
 ;
4 ;;Verify a Patch
 ; option release a patch (and/or edit internal comments) [A1AE PHVER]
 ;
 K A1AEPKV
 S DIC("A")="Select PATCH: ",DIC("S")="I $P(^(0),U,8)=""c"",$D(^A1AE(11007,+$P(^(0),U,2),""PB"",DUZ,0)),$P(^(0),U,2)=""V""",DIC="^A1AE(11005,",DIC(0)="AEMQZ" W ! D ^DIC K DIC G Q:Y<0 S (A1AEIFN,DA)=+Y,A1AEPD=$P(Y,U,2)
 I $L($P($G(^A1AE(11005,DA,4)),U,1)) W !,"This is a Package Release, You need to use the Package Release option." D Q G 4
 S $P(A1AEPD,"*",2)=$S($P(A1AEPD,"*",2)=999:"DBA",1:$P(A1AEPD,"*",2))
 ;
 S Y=$P(Y(0),U,17) I Y,Y>DT W !!,"Do not release until: " D DT^DIQ
 S A1AEST=$S($P(Y(0),U,7)="e":2,1:31) ;get status
 ;
 W !!,"Internal Comments to developers/releasers for: ",A1AEPD,! K Y S DIE="^A1AE(11005,",DR="16;" D ^DIE K DQ,DE,DIE,DIC,DR,D0,DA
 W ! S DIR(0)="Y",DIR("B")="No",DIR("A")="Continue and Display Patch " D ^DIR K DIR I 'Y D Q G 4
 ;check routine patches
 F AX=0:0 S AX=$O(^A1AE(11005,A1AEIFN,"P",AX)) Q:'AX  I $D(^(AX,0)) S X=^(0) D RCHK^A1AEM2
 W ! S DIR(0)="E" D ^DIR K DIR I 'Y D Q G 4
 ;
 S D0=A1AEIFN,A1AEVPR="",A1AEHD="DHCP Completed/NotReleased Patch Display"
 W ! S %ZIS="",A1AEPGE=0 D ^%ZIS G Q:POP K IOP,%ZIS U IO S ^UTILITY($J,1)="D HD^A1AEPH2",DIWF="B4X" K ^UTILITY($J,"W"),DXS D HD^A1AEPH2,^A1AEP ;SO DI*22*152
 K DN,DXS,DIWF ;;; I A1AEOUT'[U B  G Q
 K A1AEHD,A1AELNE,A1AEOUT,A1AEPGE,A1AEVPR D CLOSE^A1AEUTL1
 ;S X2=A1AEST,X1=DT D C^%DTC S Y=X D DD^%DT S A1AEST=Y
 S X=$$FMADD^XLFDT(DT,A1AEST),A1AEST=$$FMTE^XLFDT(X) ;Get Compliance date
 W !!,"Releasing Patch: ",A1AEPD,! K Y S DA=A1AEIFN,DIE="^A1AE(11005,",DR="18//^S X=A1AEST;8;S Y=$S(X=""e"":""@10"",1:"""");@10;8.5" ;;;D ^DIE K DQ,DE
 L +@(DIE_DA_")"):5
 I '$T W !,$C(7),"This patch is being released by another user" H 3
 E  D ^DIE K DQ,DE L -@(DIE_DA_")")
 D Q
 ;
 GOTO 4 ; end of 4
 ;
 ;
5 ;;Copy a patch into a new patch
 ; option copy a patch into a new patch [A1AE COPY PATCH]
 ;
 G ^A1AEPH8
 ;
 ;
6 ;;Create a packman message
 ; option create a packman message [A1AE DEV CREATE]
 ;
 G PACK^A1AEM
 ;
 ;
7 ;;Forward a Complete/unverified message
 ; option forward a completed/notreleased patch message [A1AE DEV FORWARD]
 ;
 G FCOM^A1AEM2
 ;
 ;
8 ;;Forward a Verified patch message
 ; option forward a released patch message [A1AE FORWARD]
 ;
 G FVER^A1AEM2
 ;
 ;
Q ; cleanup and quit for ^A1AEPH1 and ^A1AEUTL
 ;
 K ^UTILITY($J,"A1AECOP"),A1AEOLPD,A1AE0,A1AEPKIF,A1AEPKNM,A1AEPD,A1AEPK,A1AEVR,A1AENB,A1AEFL,A1AETY
 K DIK,A1AEHD,A1AEIFN,A1AELNE,A1AEOUT,A1AEPGE,A1AEVPR
 K AEQ,A1AESUB,A1AETX,A1AEXMZ,A1NAM,A1NAM1,AX,AXMZ,A1AEST,A1AETVR
 K JL2,SAVEX,C,D0,DA,DI,DIG,DIH,DIW,DIV,DR,XMB,XMDT,XMDUZ,XMM,XMSUB
 ;
 QUIT  ; end of Q
 ;
 ;
EOR ; end of routine A1AEPH1
