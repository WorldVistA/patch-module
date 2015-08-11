A1AEPHS ;isa/rmo,mjk-logic from DD, U triggers test message ;2015-06-14  3:28 AM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ; Input Transform of field Status (8) of file DHCP Patches (11005)
 ;
 ; Initialization:
 ;
 Q:'$D(X)  ; if no user input
 I $D(DUZ)[0 D  Q  ; if no user
 . W !?3,"Your user code (DUZ) must be defined to change the status of a patch."
 . K X
 I $D(U)[0 S U="^" ; if called from direct mode without U
 N DIERR ; VEN/SMH - Don't allow DIERR to leak back to DBS Fileman calls
 N A1AEDA S A1AEDA=DA ; Patch IEN
 N A1AE0 S A1AE0=$G(^A1AE(11005,A1AEDA,0)) ; Patch record header
 S A1AEPKIF=$P(A1AE0,U,2) ; field Package (2)
 ;
 ; Prepare new value for processing:
 ;
 N A1AEX S A1AEX=X ; save user input
 N A1AENEWD D  ; lookup user input in file DHCP Patch Status (11005.2)
 . N X ; protect user input from lookup
 . S A1AENEWD=$$FIND1^DIC(11005.2,,"MO",A1AEX)
 . I 'A1AENEWD S A1AENEWD=0 ; failed lookup
 N A1AENEWS S A1AENEWS=$G(^A1AE(11005.2,A1AENEWD,0)) ; new status hdr
 N A1AENEW S A1AENEW=$P(A1AENEWS,U) ; field Code (.01)
 I 'A1AENEWD S A1AENEW=0 ; failed lookup is coded as 0
 N A1AENEWC S A1AENEWC=U_A1AENEW_U ; to test if lists contain new code
 N A1AEOPT S A1AEOPT=$P(A1AENEWS,U,3) ; field Display (.03)
 N A1AEBULL S A1AEBULL=$P(A1AENEWS,U,4) ; field Bulletin Name (.04)
 N A1AESENT S A1AESENT=$P(A1AENEWS,U,5) ; field Sent To (.05)
 N A1AESAME S A1AESAME=$P(A1AENEWS,U,8)
 ; field Same Status to Generate Test Msg (.08)
 ;
 ; Prepare old value for processing:
 ;
 N A1AEOLD S A1AEOLD=$P(A1AE0,U,8) ; field Status (8)
 I A1AEOLD="" S A1AEOLD=0 ; no old status is coded as 0
 N A1AEOLDD D  ; lookup old status in file DHCP Patch Status
 . N X ; protect user input from lookup
 . S A1AEOLDD=$$FIND1^DIC(11005.2,,"X",A1AEOLD,"B")
 . I 'A1AEOLDD S A1AEOLDD=0 ; failed lookup (e.g., new patch)
 N A1AEOLDS S A1AEOLDS=$G(^A1AE(11005.2,A1AEOLDD,0)) ; old status hdr
 N TESTMES S TESTMES=A1AEOLD=A1AENEW&A1AESAME ; generate tst msg?
 ; for three statuses, assigning that same status to the patch causes
 ; it to generate a test message; this feature works for patches in
 ; review or either kind of development
 I TESTMES D  ; if same status entered to generate test message
 . S X=A1AENEW ; reduce user input to the status code
 E  I A1AEOLD=A1AENEW Q  ; don't proceed if it is the same status.
 S A1AEOLD=$$UP^XLFSTR(A1AEOLD)
 N A1AEOLDC S A1AEOLDC=U_A1AEOLD_U ; to test if lists contain old code
 ;
 ; Branch to processing subroutine based on old value:
 ;
 N A1AELIST S A1AELIST="^U^C^V^E^R^I2^D2^S2^R2^N2^" ; main statuses
 N A1AESEC S A1AESEC="^I2^D2^S2^R2^N2^" ; secondary statuses
 ;
 I A1AELIST[A1AEOLDC D
 . D @A1AEOLD ; process main-status patches
 E  D
 . D NEW ; process new patch (& unfortunately x = cancel)
 ;
 S X=A1AEX ; restore user input
 ;
 QUIT  ; end of A1AEPHS
 ;
 ;
NEW ; new patch
 ;
 I A1AENEW'="u" D  Q
 . W !?3,"The status of a new patch may only be entered as Under Development (u)!"
 . K X
 ;
 I '$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0)) D
 . W !?3,"You are not an authorized developer of this package."
 . K X
 ;
 QUIT  ; end of NEW
 ;
 ;
U ; u = UNDER DEVELOPMENT
 ;
 I 'TESTMES,"^c^x^"'[A1AENEWC D  Q
 . W !?3,"The status may only be changed to Completed/Unreleased (c)"
 . W " or Canceled (x)!"
 . K X
 I '$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0)) D  Q
 . W !?3,"You are not an authorized developer of this package."
 . K X
 I 'TESTMES,A1AENEW="c",$P(^A1AE(11005,DA,0),U,9)=DUZ D  Q
 . W !?3,"Please have another developer of the package review the patch and change"
 . W !?3,"the status to Completed/Unreleased (c)."
 . K X
 ;
 N SAVX,SEQ,TVER,TXVER,XMY
 ;
 I 'TESTMES D  Q:X'=A1AEX
 . D ASKCHG
 I TESTMES D  Q:$D(DUOUT)!($D(DTOUT))!('Y)
 . D ASKTST
 S SEQ=""
 D GET^A1AEMAL
 I '$D(XMZ) D  Q
 . K X
 D MES^A1AEMAL
 I TESTMES D  Q
 . S X="u"
 Q:A1AENEW="x"  ; Canceled exit here
 ;
 K XMY
 F I=0:0 S I=$O(^A1AE(11007,A1AEPKIF,"PB",I)) Q:'I  D
 . I $D(^(I,0)),$P(^(0),U,2)="V" S XMY(I)=""
 S XMY(DUZ)=""
 D BUL
 ;
 QUIT  ; end of U
 ;
 ;
C ; c = COMPLETED/UNVERIFIED
 ;
 I A1AENEW="u" D  Q
 . D NEW
 ;
 I A1AENEW'="v" D  Q
 . W !?3,"The status may only be changed to Released (v)!"
 . K X
 ;
 D  Q:'$D(X)
 . I $D(^A1AE(11007,A1AEPKIF,"PB",DUZ,0)),$P(^(0),U,2)="V" Q
 . W !?3,"You are not authorized to release patches of this package."
 . K X
 ;
 D  Q:'$D(X)
 . N A1AEUENT S A1AEUENT=$P(A1AE0,U,9) ; field User Entering (9)
 . N A1AEUCOM S A1AEUCOM=$P(A1AE0,U,13) ; field User Completion (13)
 . I A1AEUENT'=DUZ,A1AEUCOM'=DUZ Q  ; if different user, we're good
 . W !?3,"Please have an authorized releaser, other than the developer"
 . W !?3,"who entered the patch or completed the patch, release the"
 . W !?3,"patch."
 . K X
 ;
 N A1AEVR S A1AEVR=$P(A1AE0,U,3) ; field Version (3)
 N A1AEHOLD S A1AEHOLD=$P(A1AE0,U,17) ; field Holding Date (17)
 I A1AEHOLD>DT D
 . W !?3,"This patch cannot be Verified/Released (v) until: "
 . W $$FMTE^XLFDT(A1AEHOLD)
 . K X
 ;
 ;naked ref to same entry above
 I $D(^("Q","B")) D
 . N CHECK S CHECK=""
 . N AZ ; return array from PCHK
 . D PCHK^A1AEUTL1
 . Q:'$D(AZ("STOP"))
 . W !?3,"This patch cannot be Verified/released (v) before patch(s):"
 . S AZ=0
 . F  S AZ=$O(AZ("STOP",AZ)) Q:'AZ  D
 . . W:$X>60 !,?62
 . . W ?62,$P(AZ("STOP",AZ),U)
 . K X
 I '$D(X) D  Q
 . W $C(7)
 ;
 ;check for Patch message sent/but disconnect blew away 'v'status
 I $P($G(^A1AE(11005.1,DA,0)),U,6),$P($G(^(0)),U,7),A1AENEW="v" D  Q
 . D NOMESS^A1AEMAL1
 ;
 D ASKCHG
 Q:X'=A1AEX
 ;
 I '$D(A1AEPKV) D
 . D SEQ^A1AEUTL
 ;
 ;See if we can get a Mail Message
 K XMZ
 D GET^A1AEMAL
 I '$D(XMZ) D
 . D DELSEQ^A1AEUTL
 . K X
 Q:'$D(X)
 ;
 ; VEN/JLI 150413 - add info from DHCP PATCHES file to message data in DHCP PATCH MESSAGE file entry
 D BUILDIT^A1AEBLD(DA)
 ; VEN/JLI - end of insertion
 ;Build Mail Message
 D MES^A1AEMAL
 ;
 ;After building message, update version #
 D NEWVER^A1AEUTL(A1AEPKIF,DA)
 D BOTH
 ;
 QUIT  ; end of C
 ;
 ;
BOTH ;Send Bulletin, Called from C and V. Setup address list
 K A1AEVR,SEQ,XMY
 N A1AETO,XMBTMP
 D INIT^XMXADDR
 S A1AETO=0
 I '$D(A1AEPKV) D
 . F  S A1AETO=$O(^A1AE(11007,A1AEPKIF,1,A1AETO)) Q:'A1AETO  D
 . . D ADDRESS^XMXADDR(DUZ,A1AETO)
 I $D(A1AEPKV) D
 . D ADDRESS^XMXADDR(DUZ,"G.A1AE PACKAGE RELEASE")
 S XMBTMP=1
 S XMY(DUZ)=""
 D BUL
 ;
 QUIT  ; end of BOTH
 ;
 ;
V ; v = VERIFIED
 ;
 I A1AENEW'="e",A1AENEW'="r"!($P(A1AE0,U,3)'=999) D  Q
 . W !?3,"The status may only be changed to Entered in Error (E),"
 . W !?3,"or if it is a DBA type patch it can be Retired (r)!"
 . K X
 I '$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0)) D  Q
 . W !?3,"You are not an authorized developer of this package."
 . K X
 D ASKCHG
 Q:X'=A1AEX
 I A1AENEW'="e" D  Q
 . D BOTH
 N X
 ; The bulletin for "entered in error" will be sent in 3^A1AEPH1,
 ; after the developer has entered the error description.
 W !!,"Next, you will be asked for the 'Entered in Error Description'."
 W !,"Whatever you write will be included in the bulletin which will be sent"
 W !,"to all patch recipients, so make sure your description is complete.",!
 D WAIT^XMXUTIL
 ;
 QUIT  ; end of V
 ;
 ;
I2 ; i2 = IN REVIEW
 ;
 ; ensure this is a legal code change
 I 'TESTMES,"^d2^s2^n2^"'[A1AENEWC D  Q
 . W !?3,"The status may only be changed to Secondary Development (d2),"
 . W "Secondary Completion (s2), or Not for Secondary Release (n2)!"
 . K X
 ;
 ; ensure this is a legal user
 I '$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0)) D  Q
 . W !?3,"You are not an authorized developer of this package."
 . K X
 ; (the reviewer can also play another role, so no restriction here)
 ;
 N SAVX,TVER,TXVER,XMY ; scope variables used in A1AEMAL*
 I 'TESTMES D  Q:X'=A1AEX  ; if no test msg, confirm code change
 . D ASKCHG
 I TESTMES D  Q:$D(DUOUT)!$D(DTOUT)!'Y  ; if test msg, get details
 . D ASKTST
 N SEQ S SEQ=""
 D GET^A1AEMAL ; get msg #
 I '$D(XMZ) D  Q  ; if fail to get msg #, change to Status fails
 . K X
 D MES^A1AEMAL ; build msg
 ;
 I TESTMES D  Q  ; if it was a test msg, change input to i2 & done
 . S X="i2"
 ;
 ; notify package verifiers of change in status:
 ;
 K XMY ; clear recipient list
 F I=0:0 S I=$O(^A1AE(11007,A1AEPKIF,"PB",I)) Q:'I  D
 . I $D(^(I,0)),$P(^(0),U,2)="V" S XMY(I)="" ; add verifiers
 S XMY(DUZ)="" ; add current user
 D BUL ; send bulletin
 ;
 QUIT  ; end of I2
 ;
 ;
RENEW ; renew patch
 ;
 I A1AENEW'="d2" D  Q
 . W !?3,"The status of a renewed patch may only be entered as Secondary Development (d2)!"
 . K X
 ;
 I '$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0)) D
 . W !?3,"You are not an authorized developer of this package."
 . K X
 ;
 QUIT  ; end of RENEW
 ;
 ;
D2 ; d2 = SEC DEVELOPMENT
 ;
 I 'TESTMES,"^s2^i2^n2^"'[A1AENEWC D  Q
 . W !?3,"The status may only be changed to Secondary Completion (s2),"
 . W " In Review (I2),"
 . W !?3," or Not for Secondary Release (n2)!"
 . K X
 I '$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0)) D  Q
 . W !?3,"You are not an authorized developer of this package."
 . K X
 I 'TESTMES,A1AENEW="c",$P(^A1AE(11005,DA,0),U,9)=DUZ D  Q
 . W !?3,"Please have another developer of the package review the patch and change"
 . W !?3,"the status to 'C'ompleted/not released."
 . K X
 I 'TESTMES D  Q:X'=A1AEX
 . D ASKCHG
 I TESTMES D  Q:$D(DUOUT)!($D(DTOUT))!('Y)
 . D ASKTST
 N SEQ S SEQ=""
 N SAVX,SEQ,TVER,TXVER,XMY
 D GET^A1AEMAL
 I '$D(XMZ) D  Q
 . K X
 D MES^A1AEMAL
 ;
 I TESTMES D  Q
 . S X="d2"
 ;
 K XMY
 F I=0:0 S I=$O(^A1AE(11007,A1AEPKIF,"PB",I)) Q:'I  D
 . I $D(^(I,0)),$P(^(0),U,2)="V" D
 . . S XMY(I)=""
 S XMY(DUZ)=""
 D BUL
 ;
 QUIT  ; end of D2
 ;
 ;
S2 ; s2 = SEC COMPLETION
 ;
 I A1AENEW="d2" D  Q
 . D RENEW
 I "^r2^i2^n2^"'[A1AENEWC D  Q
 . W !?3,"The status may only be changed to Secondary Release (r2),"
 . W !?3," In Review (i2), or Not for Secondary Release (n2)!"
 . K X
 ;
 N A1AES2R2 S A1AES2R2=A1AENEW="r2" ; are we sec releasing this patch?
 N A1AEQUIT S A1AEQUIT=0 ; should we bail out?
 I A1AES2R2 D  Q  ; if we're changing to sec release
 . D S2R2 ; try to sec release it
 ;
 ; for the other changes from sec completion . . .
 D ASKCHG ; confirm change
 Q:X'=A1AEX  ; bail out if not confirmed
 ;
 K XMZ
 D GET^A1AEMAL ; See if we can get a Mail Message
 I '$D(XMZ) D  Q  ; bail out if not
 . K X
 ;
 D MES^A1AEMAL ; Build Mail Message
 D BOTH
 ;
 QUIT  ; end of S2
 ;
 ;
S2R2 ; s2 = SEC COMPLETION ==> r2 = SEC RELEASE
 ;
 D  Q:'$D(X)
 . I $D(^A1AE(11007,A1AEPKIF,"PB",DUZ,0)),$P(^(0),U,2)="V" Q
 . W !?3,"You are not authorized to release patches of this package."
 . K X
 ;
 D  Q:'$D(X)
 . N A1AEUENT S A1AEUENT=$P(A1AE0,U,9) ; field User Entering (9)
 . N A1AEUCOM S A1AEUCOM=$P(A1AE0,U,13) ; field User Completion (13)
 . I A1AEUENT'=DUZ,A1AEUCOM'=DUZ Q  ; if different user, we're good
 . W !?3,"Please have an authorized releaser, other than the developer"
 . W !?3,"who entered the patch or completed the patch, release the"
 . W !?3,"patch."
 . K X
 ;
 N A1AEVR S A1AEVR=$P(A1AE0,U,3) ; field Version (3)
 N A1AEHOLD S A1AEHOLD=$P(A1AE0,U,17) ; field Holding Date (17)
 I A1AEHOLD>DT D
 . W !?3,"This patch cannot be Verified/Released (r2) until: "
 . W $$FMTE^XLFDT(A1AEHOLD)
 . K X
 ;
 I $D(^("Q","B")) D
 . N CHECK S CHECK=""
 . N AZ ; return array from PCHK
 . D PCHK^A1AEUTL1
 . Q:'$D(AZ("STOP"))
 . W !?3,"This patch cannot be Sec Released (r2) before patch(s):"
 . S AZ=0
 . F  S AZ=$O(AZ("STOP",AZ)) Q:'AZ  D
 . . W:$X>60 !,?62
 . . W ?62,$P(AZ("STOP",AZ),U)
 . K X
 I '$D(X) D  Q
 . W $C(7)
 ;
 ;check for Patch message sent/but disconnect blew away 'r2'status
 I $P($G(^A1AE(11005.1,DA,0)),U,6),$P($G(^(0)),U,7),A1AENEW="r2" D  Q
 . D NOMESS^A1AEMAL1
 ;
 D ASKCHG ; confirm status change
 Q:X'=A1AEX  ; bail out if no confirmation
 ;
 I '$D(A1AEPKV) D
 . D SEQ^A1AEUTL
 ;See if we can get a Mail Message
 K XMZ
 D GET^A1AEMAL
 I '$D(XMZ) D
 . D DELSEQ^A1AEUTL
 . K X
 Q:'$D(X)
 ;
 ;Build Mail Message
 D MES^A1AEMAL
 ;
 ;After building message, update version #
 D NEWVER^A1AEUTL(A1AEPKIF,DA)
 D BOTH
 ;
 QUIT  ; end of S2R2
 ;
 ;
R2 ; r2 = SEC RELEASE
 ;
 W !,"Secondary released patches cannot be edited after release."
 K X
 ;
 QUIT  ; end of R2
 ;
 ;
N2 ; n2 = NOT FOR SEC RELEASE
 ;
 I A1AENEW'="i2" D  Q
 . W !?3,"The status may only be changed to In Review (i2)!"
 . K X
 D
 . Q:$D(^A1AE(11007,A1AEPKIF,"PB",DUZ,0))
 . Q:$D(^A1AE(11007,A1AEPKIF,"PH",DUZ,0))
 . W !?3,"You are not authorized to release patches of this package."
 . K X
 ;
 D ASKCHG
 Q:X'=A1AEX
 ;
 ;See if we can get a Mail Message
 K XMZ
 D GET^A1AEMAL
 Q:'$D(X)
 ;
 ;Build Mail Message
 D MES^A1AEMAL
 D BOTH
 ;
 QUIT  ; end of N2
 ;
 ;
E ; e = ENTERED IN ERROR
R ; r = RETIRED
 ;
 W !?3,"Once the status has been set to Entered in Error (e)"
 W " or Retired (r) it cannot be changed!"
 K X
 ;
 QUIT  ; end of E/R
 ;
 ;
ASKCHG ; confirm status change
 ;
 S A1AEX=X
 Q:$D(DIFM)  ; If we are inside the DBS, don't ask
 S A1AERD("A")="Are you sure you want to change status to "_A1AEOPT_"? "
 S A1AERD(0)="S"
 S A1AERD(1)="Yes^change status and send a message to users"
 S A1AERD(2)="No^leave the status the same"
 S A1AERD("B")=2
 D SET^A1AERD
 K A1AERD
 S X=$S("Y"[$E(X,1):A1AEX,1:$$LOW^XLFSTR(A1AEOLD))
 W !?3,"...status ",$S(A1AEX=X:"",1:"'not' "),"changed to ",A1AEOPT
 ;
 QUIT  ; end of ASKCHG
 ;
 ;
BUL ; send bulletin
 ;
 N X ; protect user input variable from Mailman
 N XMTEXT S XMTEXT="A1AETX("
 N XMB S XMB=A1AEBULL ; name of bulletin to send for this status
 N A1AEX S A1AEX=$P($G(^A1AE(11005,DA,4)),U)
 I $L(A1AEX)>2 D
 . S XMB=$P(XMB,"PATCH")_"PACKAGE" ;rwf
 S XMB(1)=$P(^DIC(9.4,+$P(A1AE0,U,2),0),U,1)
 S XMB(2)=$P(A1AE0,U,1)
 S XMB(3)=$P(A1AE0,U,5)
 ;
 I "^c^v^d2^s2^r2^n2^"[A1AENEWC D
 . S XMB(4)=$P($P(^DD(11005,7,0),$P(A1AE0,U,7)_":",2),";",1)
 ;
 I "^v^r2^"'=A1AENEWC D
 . S:$D(A1AEXMZ) XMB(5)=A1AEXMZ
 . S:$D(A1AESUB) XMB(6)=A1AESUB
 ;
 S $P(XMB(2),"*",2)=$S($P(XMB(2),"*",2)=999:"DBA",1:$P(XMB(2),"*",2))
 ;
 S XMB(7)=""
 I $D(^A1AE(11005,"AC",+$P(A1AE0,U,2),+$P(A1AE0,U,3),"pp",+$P(A1AE0,U,4))) D
 . S XMB(7)=" Category of Patch: PATCH FOR A PATCH"
 ;
 S (XMB(8),XMB(9))=""
 I "v"=A1AENEW D
 . S Y=$O(^A1AE(11005,"B",$P(A1AE0,U,1),0))
 . S Y=$P(^A1AE(11005,Y,0),U,18)
 . D DD^%DT
 . S XMB(8)="Unless otherwise indicated in the patch description, this patch should"
 . S XMB(9)="be installed by "_Y
 . I $G(DUZ("AG"))="V" S XMB(9)=XMB(9)_" in compliance with Directive 2001-23."
 . E  S XMB(9)=XMB(9)_"." ; for everyone else
 ;
 I $L(A1AEX)>2 D
 . S XMB(2)=$P(A1AEX,U) ;rwf
 ;
 D M^A1AEUTL1
 W !!,"NOTE: A bulletin has been sent to ",A1AESENT
 I "^c^v^i2^d2^s2^r2^"[A1AENEWC D
 . W " for this package"
 W !?6,"informing them of this ",A1AEOPT," patch.",!
 ;
 I "^e^v^r2^n2^"[A1AENEWC D
 . D ESSMSG
 ;
 QUIT  ; end of BUL
 ;
 ;
ESSMSG ; Send message to Remedy to let it know that a patch has been
 G ESSMSG^A1AEPHS1
 ;
ASKTST Q:'$D(^A1AE(11005.1,DA,0))
 W !!,?3,"Option to create a Patch message to send to test sites."
 S INXMZ=$P(^(0),U,2)
 ;S XMZ=$P(^(0),U,8)
 S TVER=$P(^(0),U,12)+1
 ;
 ;I XMZ DO  I $D(DUOUT)!($D(DTOUT))!('Y) Q
 ;.W ! S DIR(0)="Y",DIR("B")="No"
 ;.S DIR("A")="Add additional recipients "
 ;.D ^DIR K DIR
 ;
 ;develop/test
 I 'INXMZ DO  I $D(DUOUT)!($D(DTOUT))!('Y) Q
 .W ! S DIR(0)="Y",DIR("B")="No"
 .S DIR("A")="This Patch has no routines, do you wish to continue "
 .D ^DIR K DIR
 ;
 ;save ADTM for the timestamp in 11005.1
 D NOW^%DTC S (ADTM,Y)=% D TM^A1AEUTL1
 S TXVER="TEST v"_TVER
 W !?3,TXVER
 W ?$X+3,"will be added to the Patch message subject."
 S DIR(0)="NO^1:99"
 S DIR("B")=TVER
 S DIR("A")="You may change the TEST v[#] if necessary."
 W ! D ^DIR K DIR
 I $D(DUOUT)!($D(DTOUT))!('Y) Q
 ;
 I Y'=TVER DO  I $D(DUOUT)!($D(DTOUT))!('Y) Q
 .;only if they change it if not sure start over
 .S TVER=Y,TXVER="TEST v"_TVER_$P(TXVER," ",3)
 .S DIR(0)="Y",DIR("B")="NO"
 .S DIR("A")="Are you sure you want to change Test version to 'TEST V"_TVER_"' "
 .D ^DIR K DIR
 ;
 QUIT  ; end of ASKTST
 ;
 ;
XM I '$D(XMDUZ) D
 . S XMDUZ=DUZ
 S XMDUN=$P(^VA(200,XMDUZ,0),U)
 S (XMKN,XMLOCK)=""
 S XMK=0
 ;
 QUIT  ; end of XM
 ;
 ;
EOR ; end of routine A1AEPHS
