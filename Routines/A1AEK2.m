A1AEK2 ;ven/lgc-forum-site subscription messaging ;2015-05-28T06:45
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-12-27: version 2.4 released
 ;
 ;
 ; CHANGE VEN/LGC 2015 03 21
 ;    Set G.A1AEFMSC as the FORUM mail group name that
 ;    will receive Patch Stream Change messaging
 ;
 ; CHANGE VEN/LGC 2015 05 27
 ;    Modifications in A1AEF1 where DIERR shows failure.
 ;    DATA saved in FDATA while DIERR error is considered.
 ;
 S ^XTMP($J,"A1AEK2 FROM TOP")=""
 Q  ; Not from top
 ;
 ;
 ; Input transform for SUBSCRIPTION [#.06] field in
 ;  DHCP PATCH STREAM [#11007.1] file.
 ; With an attempt to edit the SUBSCRIPTION field to
 ;  set the site to another Patch Stream, the user
 ;  is notified that such changes must be done by
 ;  a Forum application edit.  However, the request
 ;  for the change is generated and forwarded to
 ;  Forum through the A1AESTRMCHG mail group.
 ; If the variable A1AEFOAP (Forum Approved) is defined
 ;  an edit proceeds without interference.
 ; ENTER
 ;   A1AEFOAP  = exists if editing by Forum action
 ;   STRM      = entry in DHCP PATCH STREAM desired
 ;               e.g. 1 or 10001
 ;   DUZ       = user
 ;   Y0        = user selection to SEQUENCE if called
 ;                through FM edit INPUT TEMPLATE
 ;               --- or set by Option
 ;   SLNT      = [OPTIONAL] SILENT TOGGLE 1=YES
 ; EXIT
 ;   SLNT  = if passed as 1 (true) return data array
 ;           if not passed or 0 then email delivered
 ;   Sends out email request for SEQUENCE (patch stream)
 ;    change to Forum
STRM(STRM,Y0,SLNT) ; INPUT TRANSFORM ON SUBSCRIPTION [.06] in 11007.1
 Q:$D(A1AEFOAP)
 S SLNT=$S($G(SLNT):1,1:0)
 I Y0="YES",+$G(STRM),$O(^A1AE(11007.1,"ASUBS",0,0))=STRM D
 . I $$CONFIRM!SLNT D
 .. N SERVER S SERVER=$$GET1^DIQ(8989.3,1_",",.01) ; REQST DOMAIN
 .. I $$NEWSTRM(DUZ,$$HTFM^XLFDT($H),SERVER,+$G(STRM),SLNT) D
 ... W:'SLNT !,!,"*** Forum is being notified of your request"
 ... W:'SLNT !,"to change your site's SUBSCRIPTION to "
 ... W:'SLNT !,"   ",$P(^A1AE(11007.1,STRM,0),"^"),"***",!
 ; Since updating SEQUENCE requires FORUM action, the 
 ;  input transform ALWAYS kills X
 K X
 Q
 ;
 ;
 ;ENTER
 ;  nothing required
 ;RETURN
 ;  0 for NO, 1 for YES
CONFIRM() ; Return answer to confirm No/Yes
 N DIR,X,Y,DTOUT,DUOUT
 S DIR(0)="Y"
 S DIR("A")="Confirm desire to switch PATCH SUBSCRIPTION"
 S DIR("B")="N"
 D ^DIR
 Q +$G(Y)
 ;
 ;
 ; Send formatted email out to G.A1AESTRMCHG to be sent
 ;  to local users on the mail group and through the server
 ;  on the MEMBERS REMOTE named S.A1AENEWSTRM
 ; Action fired off by an INPUT TRANSFORM on the 
 ;  SUBSCRIPTION [#.06] field in the DHCP PATCH STREAM
 ;  [#11007.1] file
 ; ENTER
 ;  DUZ     =  user
 ;  SCDT    =  date/time stream change requested
 ;  SERVER  =  name of server
 ;  STRM    =  new stream desired
 ;  SLNT    =  toggle for SILENT to FORUM
 ;             0 normal mode, msg subject toggles sending to FORUM
 ;             1 test mode, msg subject stops sending to FORUM
 ; EXIT
 ;  0^COMMENT if error, or IEN into 3.9 for message
NEWSTRM(DUZ,SCDT,SERVER,STRM,SLNT) ;
 Q:'$G(DUZ) "1^MISSING DUZ"
 Q:'$G(SCDT) "1^MISSING or BAD Stream Change Date/Time"
 Q:'$L(SERVER) "1^MISSING SERVER information"
 Q:'$G(STRM) "1^MISSING STREAM information"
 N ACTSTRM S ACTSTRM=$O(^A1AE(11007.1,"ASUBS",1,0))
 N ACTSTRMD S ACTSTRMD=$O(^A1AE(11007.1,+$G(ACTSTRM),1,"B","A"),-1)
 N XMSUBJ S XMSUBJ=SERVER_":::SUBSCRIPTION CHNG REQUEST "
 S:SLNT XMSUBJ="A1AE:::SUBSCRIPTION CHNG REQUEST "
 N VAP S:SLNT VAP="T+1"
 N DATA
 S DATA(0)=6
 S DATA(1)="SERVER:::"_SERVER
 S DATA(2)="ACTIVE SUBSCRIPTION:::"_ACTSTRM
 S DATA(3)="DATE SUBSCRIPTION ACTIVE:::"_ACTSTRMD
 S DATA(4)="REQUESTOR DUZ:::"_DUZ
 S DATA(5)="SWITCH TO SUBSCRIPTION:::"_STRM
 S DATA(6)="SWITCH REQUEST DATE:::"_SCDT
 N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 ; Returns 0^comment for error, or IEN of mail message in 3.9
 Q $$SNDMAIL(XMSUBJ,.DATA,MAILGRP,.VAP)
 ;
 ;
 ;S.A1AENEWSTRM receives emails sent to G.A1AESTRMCHG
 ; and calls the PRCSMAIL linetag below
 ; Get first line of incoming mail
 ;  e.g. Outgoing email from site requesting new stream
 ;        FORUM.OSEHRA.ORG SUBSCRIPTION CHNG REQUEST
 ;       Incoming confirmation email from FORUM
 ;        FORUM.OSEHRA.ORG SUBSCRIPTION CHNG APPR
 ;        FORUM.OSEHRA.ORG SUBSCRIPTION CHNG NOT APPR
 ;       Outgoing email from site to FORUM confirm change
 ;        FORUM.OSEHRA.ORG SUBSCRIPTION CHNG COMPLETED
 ;        FORUM.OSEHAA.ORG SUBSCRIPTION CHNG FAILED
 ; ENTER
 ;   XMZ  =  IEN of mail in ^XMB(3.9
 ;   emails arriving into this mailgroup are ignored by
 ;    server if SUBJECT not identified.
 ; EXIT
 ;   Returns TXT value if called as extrinsic
 ;       TXT="" if subj processed, "*END*" if not
 ;   Takes appropriate action on email requests,confirmations
PRCSMAIL(A1AESTR) ; Process mail concerning changing site's Patch Stream
 Q:'$G(XMZ)
 N XTBMLN1 S XTBMLN1=$G(^XMB(3.9,XMZ,0))
 N TXT,CNT S CNT=0
 F  S TXT=$P($T(FMSUBJ+CNT),";;",2) Q:TXT["*END*"  D  Q:TXT=""
 . I TXT'="",XTBMLN1[$P(TXT,"^") D @$P(TXT,"^",2) S TXT="" Q
 . S CNT=CNT+1
 S A1AESTR=TXT
 Q:$Q A1AESTR Q
 ;
 ;
 ; Now deal with contents of structured email depending
 ;  on the subject (line1) of the email.  The linetag
 ;  to call is pulled from the above loop looking at
 ;  the text at linetag FMSUBJ at the bottom of this routine.
 ;
 ;SUBSCRIPTION CHNG REQUEST
 ;ENTER
 ;  XMZ  =  IEN of message in 3.9
 ;RETURNS
 ;  sends email message
 ; example expected text
 ;    SERVER:::FORUM.OSEHRA.ORG
 ;    ACTIVE SUBSCRIPTION:::1
 ;    DATE SUBSCRIPTION ACTIVE:::3150305.004002
 ;    REQUESTOR DUZ:::799
 ;    SWITCH TO SUBSCRIPTION:::10001
 ;    SWITCH REQUEST DATE:::3150305.23481
 ;    Called as DO, Structured request email sent to FORUM
 ;    Run as extrinsic, email with subject that will NOT
 ;      be trapped by server PRCSMAIL
FCNF0 ; Process outgoing Sendsubscription change request to FORUM
 ; Simply forward the message on to FORUM
 N UT S UT=(^XMB(3.9,XMZ,0)["A1AE:::")
 N NSTRM,I S (I,NSTRM)=0
 F  S I=$O(^XMB(3.9,XMZ,2,I)) Q:'I  D
 . I ^XMB(3.9,XMZ,2,I,0)["SWITCH TO SUBSCRIPTION:::" D
 .. S NSTRM=$P(^XMB(3.9,XMZ,2,I,0),":::",2)
 Q:'NSTRM
 N FRMDMN S FRMDMN=$$GET1^DIQ(11007.1,NSTRM_",",.07)
 I 'UT N XMY S XMY("G.A1AEFMSC@"_FRMDMN)="" D ENT1^XMD Q
 ; Fall into Unit Test
 N DATA,I S I=0
 F  S I=$O(^XMB(3.9,XMZ,2,I)) Q:'I  D
 . S DATA(I)=^XMB(3.9,XMZ,2,I,0),DATA(0)=I
 S XMSUBJ="A1AE FCNF0"
 N VAP S VAP="T+1"
 N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 N X S X=$$SNDMAIL(XMSUBJ,.DATA,MAILGRP,.VAP)
 Q
 ;
 ;
 ;
 ; SUBSCRIPTION CHNG APPR
 ; expected text of message
 ;    SERVER:::FORUM.OSEHRA.ORG
 ;    ACTIVE SUBSCRIPTION:::1
 ;    DATE SUBSCRIPTION ACTIVE:::3150305.004002
 ;    REQUESTOR DUZ:::799
 ;    SWITCH TO SUBSCRIPTION:::10001
 ;    SWITCH REQUEST DATE:::3150305.23481
 ;    APPROVED:::YES
 ;
 ;  Edit 11007.1 file, send CHNG COMPLETED email
FCNF1() ; Process incoming FORUM APPROVAL to switch streams
 ; Get data from incoming email
 N DATA,I S I=0
 F  S I=$O(^XMB(3.9,XMZ,2,I)) Q:'I  D
 . S DATA(I)=^XMB(3.9,XMZ,2,I,0),DATA(0)=I
 ; Check that the incoming mail was from this site/server
 ;   and approval before proceeding
 N SERVER S SERVER=$$GET1^DIQ(8989.3,1_",",.01)
 I $$FND(.DATA,"SERVER")'=SERVER Q
 I $$FND(.DATA,"APPROVED")'="YES" Q
 ; Save Data array for later
 N POO M POO=DATA
 ; Now do edit
 N FDA,DIERR,X,Y,A1AEFOAP,STRM
 ; This variable needs to exist to pass input transform on
 ;   the SEQUENCE [#.06] field of DHCP PATCH STREAM [#11007.1] file
 S A1AEFOAP=""
 ; Pull patch stream requested from structured email
 S STRM=$$FND(.DATA,"SWITCH TO SUBSCRIPTION")
 ; Update the site's SUBSCRIPTION to the new patch stream
 S FDA(3,11007.1,STRM_",",.06)=1
 D UPDATE^DIE("","FDA(3)")
 H 1
 ;
 ; *** Send out subscription changed failure email ***
 ; This will be captured and processed at linetag FCNF4
 ; If during unit test, return failure string
 N FDATA M FDATA=DATA
 S DATA(0)=$G(DATA(0))+1
 S DATA(DATA(0))="FORUM ACTION EDIT:::FAILED"
 N XMSUBJ S XMSUBJ="SUBSCRIPTION CHNG FAILED"
 ; If run as extrinsic change email subject to one
 ;  that will not be processed by PRCSMAIL
 I $Q S XMSUBJ="SILENT SUBSCR CHNG FAILED"
 N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 I $D(DIERR) D  Q:$Q 1 Q
 . N X S X=$$SNDMAIL(XMSUBJ,.DATA,MAILGRP)
 K DATA M DATA=FDATA
 ; ***
 ;
 ; remember to set COMMENTS field to FORUM ACTION
 N IENS,NODE,STRMDT,STRMIEN K DIERR,FDA
 S STRMDT=$O(^A1AE(11007.1,STRM,1,"B","A"),-1)
 S STRMIEN=$O(^A1AE(11007.1,STRM,1,"B",STRMDT,"A"),-1)
 S IENS=STRMIEN_","_STRM_","
 N TXT S TXT(0)=1,TXT(1)="FORUM ACTION"
 D WP^DIE(11007.12,IENS,2,"KA","TXT")
 ;
 K FDATA M FDATA=DATA
 S DATA(0)=$G(DATA(0))+1
 S DATA(DATA(0))="FORUM ACTION EDIT:::FAILED"
 N XMSUBJ S XMSUBJ="SUBSCRIPTION CHNG FAILED"
 ; If run as extrinsic change email subject to one
 ;  that will not be processed by PRCSMAIL
 I $Q S XMSUBJ="SILENT FORUM ACTION WP EDIT FAILED"
 N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 I $D(DIERR) D  Q:$Q 1 Q
 . N X S X=$$SNDMAIL(XMSUBJ,.DATA,MAILGRP)
 K DATA M DATA=FDATA
 ;
 ; Now send SUBSCRIPTION CHNG COMPLETED back through
 ;  the G.A1AESTRMCHG mail group which will be processed
 ;  through FCNF3
 ; Add following text to document
 ;   "FORUM ACTION EDIT:::SUCCESSFUL"
 ;   "NEW SUBSCRIPTION DATE:::"_Date/time change of subscription
 K DATA M DATA=POO
 S DATA(0)=$G(DATA(0))+1
 S DATA(DATA(0))="FORUM ACTION EDIT:::SUCCESSFUL"
 S DATA(0)=$G(DATA(0))+1
 S DATA(DATA(0))="NEW SUBSCRIPTION DATE:::"_STRMDT
 S DATA(0)=$G(DATA(0))+1
 S DATA(DATA(0))="NEW ACTIVE SUBSCRIPTION:::"_STRM
 N XMSUBJ S XMSUBJ="SUBSCRIPTION CHNG COMPLETED"
 N VAP S VAP="T+100"
 ; If run as extrinsic change email subject to one
 ;  that will not be processed by PRCSMAIL
 I $Q S XMSUBJ="SILENT SUBSCR CHNG COMPLETED",VAP="T+1"
 N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 N X S X=$$SNDMAIL(XMSUBJ,.DATA,MAILGRP,.VAP)
 ;  mailgroup.  This will be picked up by FCNF3
 Q:$Q 0 Q
 ;
 ;
 ; SUBSCRIPTION CHNG NOT APPR 
 ;  send PERMISSION REFUSED to mailgroup only
 ; expected message example
 ;    SERVER:::FORUM.OSEHRA.ORG
 ;    ACTIVE SUBSCRIPTION:::1
 ;    DATE SUBSCRIPTION ACTIVE:::3150305.004002
 ;    REQUESTOR DUZ:::799
 ;    SWITCH TO SUBSCRIPTION:::10001
 ;    SWITCH REQUEST DATE:::3150305.23481
 ;    APPROVED:::NO
 ;    REJECTION COMMENT:::"_COMMENT HEADER
 ;     May be some text conveying reason(s) for rejection
FCNF2 ; Accept incoming FORUM rejection to switch streams
 I ^XMB(3.9,XMZ,0)'["A1AE:::" Q
 ; OK. This is from Unit test so pull text from message
 N DATA,I S I=0
 F  S I=$O(^XMB(3.9,XMZ,2,I)) Q:'I  D
 . S DATA(I)=^XMB(3.9,XMZ,2,I,0),DATA(0)=I
 S XMSUBJ="A1AE FCNF2"
 N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 N VAP S VAP="T+1"
 N X S X=$$SNDMAIL(XMSUBJ,.DATA,MAILGRP,.VAP)
 Q
 ;
 ;
 ; SUBSCRIPTION CHNG COMPLETED
 ;  forward to FORUM
 ;    SERVER:::FORUM.OSEHRA.ORG
 ;    ACTIVE SUBSCRIPTION:::1
 ;    DATE SUBSCRIPTION ACTIVE:::3150305.004002
 ;    REQUESTOR DUZ:::799
 ;    SWITCH TO SUBSCRIPTION:::10001
 ;    SWITCH REQUEST DATE:::3150305.23481
 ;    APPROVED:::YES
 ;    FORUM ACTION EDIT:::SUCCESSFUL
 ;    NEW SUBSCRIPTION DATE:::3150306.123456
 ;    NEW ACTIVE SUBSCRIPTION:::1001
 ;
FCNF3 ; Send to FORUM subscription change completed message
 ;   capture text of incoming message from VistA
 ;   and forward to FORUM
 N UT S UT=(^XMB(3.9,XMZ,0)["A1AE:::")
 N ACTSTRM S ACTSTRM=$O(^A1AE(11007.1,"ASUBS",1,0))
 N FRMDMN S FRMDMN=$$GET1^DIQ(11007.1,ACTSTRM_",",.07)
 I 'UT N XMY S XMY("G.A1AEFMSC@"_FRMDMN)="" D ENT1^XMD Q
 ; Unit Test
 ; Copy text of incoming message 
 N DATA,I S I=0
 F  S I=$O(^XMB(3.9,XMZ,2,I)) Q:'I  D
 . S DATA(I)=^XMB(3.9,XMZ,2,I,0),DATA(0)=I
 S XMSUBJ="A1AE FCNF3"
 N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 N VAP S VAP="T+1"
 N X S X=$$SNDMAIL(XMSUBJ,.DATA,MAILGRP,.VAP)
 Q
 ;
 ;
 ; SUBSCRIPTION CHNG FAILED 
 ;  forward to FORUM
 ; Copy of authorization with FAIL entry in text
 ;   DATA(0)=7
 ;   DATA(1)="SERVER:::"_SERVER
 ;   DATA(2)="ACTIVE SUBSCRIPTION:::"_ACTIVE SUBSCRIPTION
 ;   DATA(3)="DATE SUBSCRIPTION ACTIVE:::"_SUBSCRIPTION ACTIVE DATE
 ;   DATA(4)="REQUESTOR DUZ:::"_DUZ
 ;   DATA(5)="SWITCH TO SUBSCRIPTION:::"_NEW SUBSCRIPTION REQUESTED
 ;   DATA(6)="SWITCH REQUEST DATA:::"_DATE REQUESTED
 ;   DATA(7)="APPROVED:::YES"
 ;   DATA(8)="***FORUM ACTION TO SWITCH FAILED***:::"_DATE
FCNF4 ; Process to FORUM  subscription change failed message
 ; Message text should include that from FORUM approval msg
 ; Simply forward to Forum
 N UT S UT=(^XMB(3.9,XMZ,0)["A1AE:::")
 N ACTSTRM S ACTSTRM=$O(^A1AE(11007.1,"ASUBS",1,0))
 N FRMDMN S FRMDMN=$$GET1^DIQ(11007.1,ACTSTRM_",",.07)
 I 'UT N XMY S XMY("G.A1AEFMSC@"_FRMDMN)="" D ENT1^XMD Q
 ; Unit Test
 N DATA,I S I=0
 F  S I=$O(^XMB(3.9,XMZ,2,I)) Q:'I  D
 . S DATA(I)=^XMB(3.9,XMZ,2,I,0),DATA(0)=I
 S XMSUBJ="A1AE FCNF4"
 N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 N VAP S VAP="T+1"
 N X S X=$$SNDMAIL(XMSUBJ,.DATA,MAILGRP,.VAP)
 Q
 ;
 ;
 ;  from FORUM example
 ;    SERVER:::FORUM.OSEHRA.ORG
 ;    ACTIVE SUBSCRIPTION:::1
 ;    DATE SUBSCRIPTION ACTIVE:::3150305.004002
 ;    REQUESTOR DUZ:::799
 ;    SWITCH TO SUBSCRIPTION:::10001
 ;    SWITCH REQUEST DATE:::3150305.23481
 ;    APPROVED:::YES
 ;    FORUM ACTION EDIT:::SUCCESSFUL
 ;    NEW SUBSCRIPTION DATE:::3150306.123456
 ;    NEW ACTIVE SUBSCRIPTION:::1001
 ;    SUBSCRIPTION CHANGE CONFIRMED:::3150307.431245
FCNF5 ; Accept message from FORUM confirming subscription change
 ; No Action unless Subject of incoming mail contains "A1AE:::"
 ;  If so, send another message that has a subject
 ;  that will not be trapped by PRCSMAIL server
 I ^XMB(3.9,XMZ,0)'["A1AE:::" Q
 ; OK.  This is from unit test so pull text from message
 N DATA,I S I=0
 F  S I=$O(^XMB(3.9,XMZ,2,I)) Q:'I  D
 . S DATA(I)=^XMB(3.9,XMZ,2,I,0),DATA(0)=I
 S XMSUBJ="A1AE FCNF5"
 N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 N VAP S VAP="T+1"
 N X S X=$$SNDMAIL(XMSUBJ,.DATA,MAILGRP,.VAP)
 Q
 ;
 ;
 ;send mail from postmaster to mailgroup
 ;ENTER
 ;  XMSUBJ  = Subject of email
 ;  DATA    = Data array for text
 ;  MAILGRP = Mailgroup recipient
 ;RETURN
 ;  0^COMMENT if error, XMZ if mail sent
SNDMAIL(XMSUBJ,DATA,MAILGRP,VAP) ;
 N X,Y,DI
 ; Set DUZ to Postmaster
 N DUZ S DUZ=0.5 D DUZ^XUP(DUZ)
 N SNDAPP,XMERR
 N XMTO S XMTO(MAILGRP)=""
 N XMZ S XMZ=""
 N XMDUZ S XMDUZ=0.5
 N XMBODY S XMBODY="DATA"
 S VAP=$S($D(VAP):VAP,1:"T+100")
 N XMINSTR S XMINSTR("VAPOR")=VAP
 D SENDMSG^XMXAPI(XMDUZ,XMSUBJ,XMBODY,.XMTO,.XMINSTR,.XMZ)
 Q:$D(XMERR) "0^MSG SEND ERROR(S) ENCOUNTERED"
 Q XMZ
 ;
 ;
 ; ENTER
 ;    DATA   = array of email's text by reference
 ;    HDR    = structured text in email to find
 ; RETURN
 ;    Data following HDR identified in array
 ;      - or NULL if HDR not found
 ; example
 ;    DATA(3)="DATE SUBSCRIPTION ACTIVE:::"_3150401.123456
 ;    HDR ="DATE SUBSCRIPTION ACTIVE"
 ;    3150401.123456 returned to caller
FND(DATA,HDR) ;Find HDR in DATA array, return data
 N NODE,RSLT S NODE=$NA(DATA),RSLT=""
 F  S NODE=$Q(@NODE) Q:NODE'["DATA("  Q:($P(@NODE,":::")=HDR)
 I NODE["DATA(" D
 . S RSLT=$P(@NODE,":::",2)
 Q RSLT
 ;
 ;
FMSUBJ ;;SUBSCRIPTION CHNG REQUEST^FCNF0
 ;;SUBSCRIPTION CHNG APPROVED^FCNF1
 ;;SUBSCRIPTION CHNG NOT APPROVED^FCNF2
 ;;SUBSCRIPTION CHNG COMPLETED^FCNF3
 ;;SUBSCRIPTION CHNG FAILED^FCNF4
 ;;SUBSCRIPTION CHNG CONFIRMED^FCNF5
 ;;*END*
 ;
 ;
EOR ; end of routine A1AEK2
