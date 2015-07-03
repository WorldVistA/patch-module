A1AEMAL1 ;isa/jlu-creates the patch mail message ;2014-03-08T15:35
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ;
 I $G(A1AERCR8) D
 . S $P(^XMB(3.9,XMZ,0),"^",7)=$S($P(^A1AE(11005.1,DA,0),U,11)="K":"K",1:"X")
 E  D
 . ;Address Message
 . S AN=$P(A1AEJH,U,2),TEST=$P(^A1AE(11007,AN,0),U,4)
 . I AN D VER^A1AEM:SAVX="v" D:TEST'="y" COM^A1AEM:SAVX="c" D:TEST="y" TST^A1AEM:SAVX="c"
 . I $G(TESTMES) K XMY
 . I '$G(TESTMES) S XMY(DUZ)="" ;'? to hid xmy(n)
 . I '$G(TESTMES) S JL2="" F JL=1:0 S JL2=$O(XMY(JL2)) Q:JL2=""  S A1AETX(JL)="                     "_JL2 S:JL=1 A1AETX(1)="     Recipient     : "_JL2 I JL2'?1N.N S JL=JL+1
 I '$D(ZTQUEUED) W " ." R ZZ:0
 ;Load the KIDS Message Text
 I $D(^A1AE(11005.1,DA,0)) D RO
 S ^XMB(3.9,XMZ,2,0)="^3.92A^"_E_"^"_E_"^"_DT
 ;kids patches always difrom
 I SAVX="v",$D(^DIC(19,"B","A1AE SERVER VERIFIED")) S XMY("S.A1AE SERVER VERIFIED")=""
 I $P(^XMB(3.9,XMZ,0),"^",2)="National Patch Module",SAVX="c" S $P(^(0),"^",2)="NPM   [#"_XMZ_"]"
 I $P(^XMB(3.9,XMZ,0),"^",2)="National Patch Module",$G(TESTMES) S $P(^(0),"^",2)="NPM   [#"_XMZ_"]"
 ;Send Msg
 I '$G(TESTMES) N XMDF S XMDF=1 S ZTQUEUED="" D ENT1^XMD K ZTQUEUED,XMDF
 I $G(TESTMES) DO
 . S (XMDUN,XMDUZ)=$P(^VA(200,DUZ,0),"^"),XMY(DUZ)=""
 . W !!,"Please add recipients for `",$P(A1AE0,"^"),"' test message"
 . D ENT2^XMD K XMDUN,XMDUZ
 . W !,"message number [#",XMZ,"]"
 . S $P(^A1AE(11005.1,DA,0),"^",12)=TVER
 ;record message, dt
 I $G(A1AERCR8) S $P(^A1AE(11005.1,DA,0),U,6)=XMZ Q
 S A1AESUB=XMSUB
 S (AXMZ,A1AEXMZ)=XMZ
 D VREC^A1AEM:SAVX="v",CREC^A1AEM:SAVX="c" K AXMZ
 ;
 ;remove input message from que ;do this on Completed ??/release
 I SAVX="c",$D(^A1AE(11005.1,DA,0)) S AXMZ=$P(^(0),U,2) I AXMZ D TRASH^A1AEM
 ;test the new kids import logic
 I $P($G(^A1AE(11005.1,DA,0)),"^",11)="K" D  Q
 . S $P(^XMB(3.9,A1AEXMZ,0),"^",7)="K"
 I $P($G(^A1AE(11005.1,DA,0)),"^",11)="X" D  Q
 . S $P(^XMB(3.9,A1AEXMZ,0),"^",7)="X"
 Q
 ;
 ;Removed code testing for current patches
ADD(T) ;Inc E, Add text to Message.
 S E=E+1,^XMB(3.9,XMZ,2,E,0)=T
 Q
 ;
RO ;Add KIDS message
 ;1st line $txt
 ;fix for <undef> when 11005.1 stub not getting set
 S ^XMB(3.9,XMZ,2,1,0)=$G(^A1AE(11005.1,DA,2,1,0)) ; VEN/SMH - THIS IS THE LINE THAT PUTS '$TXT Created By' etc...
 D ADD(""),ADD("")
 D ADD("Packman Mail Message:")
 D ADD("=====================")
 D ADD("")
 I $G(^A1AE(11005.1,DA,2,1,0))["No routines included" D  Q
 . D ADD(^(0)) ; naked ref to $G above.
 . S ^XMB(3.9,XMZ,2,1,0)=""
 I '$D(^A1AE(11005.1,DA,2,1)),'$D(^(2)),'$D(^(3)),'$D(^(4)),'$D(^(5)) D  Q
 . D ADD("No routines included")
 ;
 N ZA,ZB,ZC,RN,BCS
 S Z=0,ZA=0,ZB=0,RN="",BCS=""
 ;skip any txt loaded in with message
 F  S Z=$O(^A1AE(11005.1,DA,2,Z)) Q:'Z  I $E(^(Z,0),1,8)="$END TXT",^(0)'["KIDS" Q
 ;
 I Z D
 . S Z=$O(^A1AE(11005.1,DA,2,Z),-1) ;backup 1 to get $end txt
 . ;Find the build number for later
 . S ZA=Z F  S ZA=$O(^A1AE(11005.1,DA,2,ZA)) Q:'ZA  I $E(^(ZA,0),1,5)="""BLD""" Q
 . ;Move Message Text into Message Stop at $END KID
        . ;VEN/SMH - Old checksum gets put here.
 . F  S Z=$O(^A1AE(11005.1,DA,2,Z)) Q:'Z  S ZB=^(Z,0) DO  Q:$E(ZB,1,8)="$END KID"
 . . I $E(ZB,1,5)="""RTN""",RN'=$P(ZB,$C(34),4) S RN=$P(ZB,$C(34),4),BCS=$$BCS^A1AEUTL2(DA,RN)
 . . D ADD(ZB) ;node
 . . S Z=$O(^A1AE(11005.1,DA,2,Z)) Q:'Z  S ZC=^(Z,0)
 . . I $L(BCS),'$L($P(ZC,U,4)) S $P(ZC,U,4)=BCS ; VEN/SMH - Don't update the old checksum if we have one
        . . S BCS="" ; empty for the next time in the loop.
 . . D ADD(ZC) ;value
 . . I Z#66=0,'$D(ZTQUEUED) W "." R ZZ:0
 . Q
 ;Add Test and SEQ to BLD section
 I '$D(A1AEPKV),ZA D
 . N ZAA
 . S ZAA=^A1AE(11005.1,DA,2,ZA,0),ZA(1)=$P(ZAA,",",1),ZA(2)=$P(ZAA,",",2)
 . S ZZA(1)=ZA(1)_","_ZA(2)_",6)"
 . S ZZA(9)=^XMB(3.9,XMZ,2,E,0),E=E-1 ;Backup one
 . D ADD(ZZA(1)) ;Replaces last line
 . D ADD($G(TVER)_"^"_$P($G(SEQ),"#",2))
 . D ADD(ZZA(9))
 Q
 ;
PCHK ;Called from A1AEMAL
 S AN=0
 S AZ=0 F  S AZ=$O(AZ(AZ)) Q:'AZ  I AZ(AZ)'["<<" DO PSET
 S AZ=0 F  S AZ=$O(AZ(AZ)) Q:'AZ  I AZ(AZ)["<<" DO PSET
 Q
 ;
PSET ;
 I $D(AZ("TX",1)) D ADD(AZ("TX",1)_AZ(AZ)) K AZ("TX",1) Q
 E  D ADD("                    "_AZ(AZ))
 Q
 ;
NOMESS ;from a1aephs write warning that released message already sent
 W !!?3,"A Released Patch message `",$P(A1AE0,"^"),"' #"
 W $P(^A1AE(11005.1,DA,0),"^",6),"  " S Y=$P(^(0),"^",7) D DT^DIQ
 W !?3,"has already been sent."
 W !!?3,"NO additional message or bulletin will be generated."
 W !?3,"It is assummed that the previous release was interrupted"
 W !?3,"by a system disconnect.  PLEASE CHECK this message for "
 W !?3,"correct SEQ# and content."
 W !!?3,"If this message does NOT exist the Patch status will have"
 W !?3,"to be reset manually,  please notify Patch Developers."
 W !!?3,"The Patch status of `",$P(A1AE0,"^"),"' will now be reset to Released."
 W !,$C(7) H 3
 Q
