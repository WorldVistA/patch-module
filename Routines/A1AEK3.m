A1AEK3 ;ven/lgc-site-forum subscription messaging ;2015-07-06  6:55 PM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4, released
 ;
 ; CHANGE VEN/LGC 3/21/2015
 ;    Set G.A1AEFMSC as the FORUM mail group name that
 ;    will receive Patch Stream Change messaging
 ;
 ; CHANGE VEN/LGC 5/20/2015 
 ;    Saved copy from 11:30 to KBAPAEK3 in case
 ;    KIDS install overwrites during debugging
 ;
 S ^XTMP($J,"A1AEK3 FROM TOP")=""
 Q  ; Not from top
 ;
 ;
 ;
 ;S.A1AEFMSC receives emails coming in through G.A1AEFMSC
 ; and calls the PRCSMAIL linetag below
 ; Get first line of incoming mail
 ;  1. Incoming email from site requesting new stream
 ;           SUBJ["SUBSCRIPTION CHNG REQUEST"
 ;  2. Outgoing approval/disapproval email from FORUM
 ;           SUBJ["SUBSCRIPTION CHNG APPR" or
 ;           SUBJ["SUBSCRIPTION CHNG NOT APPR"
 ;  3. Incoming email from site to FORUM confirm change
 ;           SUBJ["SUBSCRIPTION CHNG COMPLETED" or
 ;           SUBJ["SUBSCRIPTION CHNG FAILED"
 ;  4. Outgoing confirmation to client from FORUM
 ;           SUBJ["SUBSCRIPTION CHNG CONFIRMED"
 ; ENTER
 ;   XMZ  =  IEN of mail in ^XMB(3.9
 ;   emails arriving into this mailgroup are ignored by
 ;    server if SUBJECT not identified.
 ; EXIT
 ;   * Returns TXT value ONLY if called as extrinsic
 ;       TXT="" if subj processed, "*END*" if not
 ;   Takes appropriate action on email requests,confirmations
PRCSMAIL(A1AESTR) ; Process mail concerning changing site's Patch Stream
 K ^XTMP("POO","PRCSMAIL") S ^XTMP("POO","PRCSMAIL")=$$HTFM^XLFDT($H)
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
 ; Now deal with contents of structured email line one
 ;
 ;SUBJ["SUBSCRIPTION CHNG REQUEST" 
 ;ENTER
 ;  XMZ  =  IEN of message in 3.9
 ;RETURNS
 ;  Builds a new entry in PATCH STREAM HISTORY for this DOMAIN
 ;    detailing request
 ;
 ; example expected text in subscription change request email
 ;    SERVER:::CLIENT SERVER NAME
 ;    ACTIVE SUBSCRIPTION:::1 or 10001
 ;    DATE SUBSCRIPTION ACTIVE:::DATE PRESENT SUBSCRIPTION BEGAN
 ;    REQUESTOR DUZ:::DUZ
 ;    SWITCH TO SUBSCRIPTION:::FOR NOW 1 or 10001
 ;    SWITCH REQUEST DATE:::DATE SITE INITIATED THIS PROCESS
 ; trapped by server PRCSMAIL
FCNF1 ; Process INCOMING Sendsubscription change request from CLIENT
 ;     Check domain exists in 11007.2
 K ^XTMP("POO","FCNF1") S ^XTMP("POO","FCNF1")=$$HTFM^XLFDT($H)
 D EMDATA(XMZ,.DATA) ; build email data array
 N SERV S SERV=$$FND^A1AEK3(.DATA,"SERVER")
 Q:'$L(SERV)  ; SERVER not in email so bail out
 N A1AE42I S A1AE42I=$O(^DIC(4.2,"B",SERV,0))
 Q:'A1AE42I  ; SERVER not in domain file so bail out
 ; Check domain doesn't already have request in the queue
 Q:($O(^A1AE(11007.2,"C",A1AE42I,0))=1)
 Q:($O(^A1AE(11007.2,"C",A1AE42I,0))=2)
 ;     Log info in 11007.2 setting STREAM CHANGE STATUS to
 ;       waiting for forum approval
 S DATA("SCS")=2
 N X S X=$$UPDDOMA(.DATA)
 Q
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
FCNF2 ; FORUM receives subscription change completed message
 ;   capture text of incoming message from VistA
 ; Note: This does allow updating of a client even
 ;       when the SCS is still at WAITING FORUM APPROVAL
 ;       However, there is a check run on the incoming
 ;       message to be certain the structured text 
 ;       indicates Forum approval.
 K ^XTMP("POO","FCNF2") S ^XTMP("POO","FCNF2","A")=$G(XMZ)_" "_$$HTFM^XLFDT($H)
 N UT S UT=(^XMB(3.9,XMZ,0)["A1AE:::")
 D EMDATA(XMZ,.DATA)
 M ^XTMP("POO","FCNF2","B")=DATA
 ; Check data matches entry in 11007.2 for this domain
 Q:'$$CHKMTCH(XMZ,.DATA)
 S ^XTMP("POO","FCNF2","C")="PASSED CHKMTCH"
 ; Update entry in 11007.2
 S DATA("SCS")=3
 S DATA("STRM")=DATA("NASTRM")
 S DATA("STRMD")=DATA("NSTRMD")
 M ^XTMP("POO","FCNF2","D")=DATA
 N UPD S UPD=$$UPDDOMA(.DATA)
 ; Fire off outging confirmation message to client
 N FDATA M FDATA=DATA
 K DATA
 F I=0:1:10 S DATA(I)=FDATA(I)
 S DATA(11)="SUBSCRIPTION CHANGE CONFIRMED:::"_FDATA("NSTRMD")
 S DATA(0)=11
 S XMSUBJ="SUBSCRIPTION CHNG CONFIRMED"
 S:UT XMSUBJ="A1AE:::"_XMSUBJ
 N VAP S:UT VAP="T+1"
 ; *** And this email should be sent to each FORUM
 ;     domain in 11007.1 to alert their previous
 ;     parent Domain of their switch.
 ; Add mailgroup for client
 N MGRP S MGRP="G.A1AESTRMCHG@"_$$FND(.DATA,"SERVER")
 ; If UT only wish sent to user
 I UT S MGRP=DUZ
 M ^XTMP("POO","FCNF2","E")=DATA
 N XMZ S XMZ=$$SNDMAIL(XMSUBJ,.DATA,.MGRP,.VAP)
 H 10
 ; Now update entry in 11007.2 once more to show Forum 
 ;   response email
 D EMDATA^A1AEK3(XMZ,.DATA)
 ; Note that Forum correctly responds with text being
 ;  loaded from the previous message dialog.  In this
 ;  case it would be the message from the client stating
 ;  that the update on their system was successful.
 ;  Then one more line was added:
 ;   "SUBSCRIPTION CHNG CONFIRMED:::"_new Patch Stream
 ;  and has already forwarded this to the Client.
 ; The last thing to do is to update our database with
 ;  the pointer to this most recent communication.
 ;  Since we have an update API in this routine, rather
 ;  than build a new one just to update this field,
 ;  we will use our API.  However, that means we need
 ;  to correct a few pieces of information relating to
 ;  the new patch stream already updated in our file
 ;  to prevent the API from incorrectly updating old
 ;  patch stream information.
 ; This is the ONLY time we break the rule of maintaining
 ;  the lines of the email as recieved in the initial
 ;  SUBSCRIPTION CHNG REQUEST.  This is necessary as
 ;  this outgoing SUBSCRIPTION CHNG CONFIRMED message
 ;  will be sent to other FORUM servers and used to
 ;  update their PATCH STREAM HISTORY [#11007.2] file.
 S DATA("SCS")=3
 S DATA("STRM")=$$FND^A1AEK3(.DATA,"SWITCH TO SUBSCRIPTION")
 S DATA("STRMD")=$$FND^A1AEK3(.DATA,"NEW SUBSCRIPTION DATE")
 S DATA(3)="ACTIVE SUBSCRIPTION:::"_$G(DATA("STRM"))
 S DATA(4)="DATE SUBSCRIPTION ACTIVE:::"_$G(DATA("STRMD"))
 M ^XTMP("POO","FCNF2","F")=DATA
 S UPD=$$UPDDOMA^A1AEK3(.DATA)
 Q
 ;
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
FCNF3 ; FORUM receives subscription change failed message
 ; Pull text from email into DATA array
 K ^XTMP("POO","FCNF3") S ^XTMP("POO","FCNF3")=$$HTFM^XLFDT($H)
 N UT S UT=(^XMB(3.9,XMZ,0)["A1AE:::")
 D EMDATA(XMZ,.DATA)
 ; Check data matches entry in 11007.2 for this domain
 Q:'$$CHKMTCH(XMZ,.DATA)
 ; Update entry in 11007.2.  Leave SCS=1 [in review]
 S DATA("FAEDIT")=DATA(8)
 S DATA("SCS")=3
 N UPD S UPD=$$UPDDOMA^A1AEK3(.DATA)
 ; Fire off outging failure confirmation message to client
 S DATA(9)="NEW SUBSCRIPTION DATE:::"
 S DATA(10)="NEW ACTIVE SUBSCRIPTION:::"
 S DATA(11)="SUBSCRIPTION CHANGE CONFIRMED:::FAILED"
 S XMSUBJ="SUBSCRIPTION CHNG FAILED CONFIRM"
 N VAP S:UT VAP="T+1"
 ; Add mailgroup for client
 N MGRP S MGRP="G.A1AESTRMCHG@"_$$FND(.DATA,"SERVER")
 S:UT MGRP=DUZ
 N XMZ S XMZ=$$SNDMAIL(XMSUBJ,.DATA,.MGRP,.VAP)
 ; Now update 11007.2 entry with fail confirmed by Forum
 D EMDATA(XMZ,.DATA)
 S DATA("NSTRMD")="FAILED"
 S UPD=$$UPDDOMA^A1AEK3(.DATA)
 Q
 ;
 ; ENTER
 ;    XMZ  =  IEN of confirmation message in 3.9
 ; EXIT
 ;    MSG forwarded to other Forums
FCNF4 ; Notify other Forums of SUBSCRIPTION CHANG CONFIRMED msg
 ; When site requests change Patch Stream, request
 ;  is sent to the Forum controlling Patch Stream they
 ;  desire.  When Patch Stream change is successfully
 ;  concluded, a SUBSCRIPTION CHANGE CONFIRMED message is
 ;  sent to CLIENT for human viewing.
 ; However, this leaves FORUM that was parent of
 ;  client in dark as to their NEW Stream Status.
 ; So, the SUBSCRIPTION CHANG CONFIRMED message is also
 ;  forwarded to all OTHER Forums (see FCNF2)
 ;  e.g. If the client has switch to OSEHRA, the confirmation
 ;       msg is sent from FORUM.OSEHRA.ORG to the new client
 ;       AND to other Forums such as FORUM.VA.GOV.
 ; When received at the(se) other Forum sites, their 
 ;   PATCH STREAM HISTORY [#11007.2] file needs updated 
 ;   to show they no longer support this client.  This 
 ;   could be left up to Forum personnel or performed 
 ;   automatically
 ; Note if we have gotten here, message
 ;   has been received at FORUM site and is being 
 ;   processed via G.A1AEFMSC as notification from
 ;   another FORUM of client's change subscription.
 ; NB: (Important): messsage is not sent to
 ;  originating Forum or we have infinite loop.
 ;  this message (see FCNF2)
 K ^XTMP("POO","FCNF4") S ^XTMP("POO","FCNF4")=$$HTFM^XLFDT($H)
 ; Is this message from unit testing
 N UT S UT=(^XMB(3.9,XMZ,0)["A1AE:::")
 ; Pull all the structured text out of the confirmation
 ;  message
 D EMDATA(XMZ,.DATA)
 N NASTRM S NASTRM=$$FND(.DATA,"NEW ACTIVE SUBSCRIPTION")
 ; Quit if we can't identify a new patch stream
 Q:'$G(NASTRM)
 N SFORUM S SFORUM=$$GET1^DIQ(11007.1,NASTRM_",",.07)
 ; Quit if we can't identify this patch stream's Forum
 Q:'$L($G(SFORUM))
 ; Quit if for some reason the identified server isn't a Forum
 Q:(SFORUM'["FORUM")
 N EMSERV S EMSERV=$$FND(.DATA,"SERVER")
 N SERVER S SERVER=$$GET1^DIQ(8989.3,1_",",.01)
 ; If NOT unit test, and email was
 ;   spawned by this server, quit to prevent looping
 I 'UT,(SFORUM=SERVER) Q
 ; If not unit test, then update PATCH STREAM HISTORY file
 ;   of recipient
 ; Change any necessary parts of DATA
 ; If unit test send email to DUZ
 I UT D
 . N MGRP S MGRP=DUZ
 . N VAP S VAP="T+1"
 . S XMSUBJ="A1AE:::UNIT TEST FCNF4"
 . S XMZ=$$SNDMAIL(XMSUBJ,.DATA,.MGRP,.VAP)
 Q
 ;
 ;
EMDATA(XMZ,DATA) ; Build data array from email
 K ^XTMP("POO","EMDATA") S ^XTMP("POO","EMDATA")=$$HTFM^XLFDT($H)
 ; Set I to skip over addressing nodes
 K DATA
 Q:'XMZ
 ; Pull lines in message with indicator string ":::" starting
 ;   with "SERVER:::"
 N BGN,NODE,SNODE
 S BGN=0,NODE=$NA(^XMB(3.9,XMZ,2)),SNODE=$P(NODE,")")
 F  S NODE=$Q(@NODE) Q:NODE'[SNODE  I @NODE[":::" D
 . S:@NODE["SERVER:::" BGN=1
 . I BGN S DATA(0)=$G(DATA(0))+1,DATA(DATA(0))=@NODE
 ;
 N SERV S SERV=$$FND^A1AEK3(.DATA,"SERVER")
 Q:'$L(SERV)
 N RDOMAIN S RDOMAIN=$O(^DIC(4.2,"B",SERV,0))
 Q:'RDOMAIN
 N A1AE72 S A1AE72=$O(^A1AE(11007.2,"B",RDOMAIN,0)) Q:'A1AE72
 S DATA("DOMAIN")=RDOMAIN
 S DATA("STRM")=$$FND^A1AEK3(.DATA,"ACTIVE SUBSCRIPTION")
 S DATA("STRMD")=$$FND^A1AEK3(.DATA,"DATE SUBSCRIPTION ACTIVE")
 S DATA("IR")=$$GET1^DIQ(11007.2,A1AE72,.04,"I")
 S DATA("IS")=$$GET1^DIQ(11007.2,A1AE72,.05,"I")
 S DATA("SCS")=$$GET1^DIQ(11007.2,A1AE72,.06,"I")
 S DATA("SERV")=$$FND^A1AEK3(.DATA,"SERVER")
 S DATA("ASTRM")=$$FND^A1AEK3(.DATA,"ACTIVE SUBSCRIPTION")
 S DATA("ASTRMD")=$$FND^A1AEK3(.DATA,"DATE SUBSCRIPTION ACTIVE")
 S DATA("RDUZ")=$$FND^A1AEK3(.DATA,"REQUESTOR DUZ")
 S DATA("RSTRM")=$$FND^A1AEK3(.DATA,"SWITCH TO SUBSCRIPTION")
 S DATA("RSTRMD")=$$FND^A1AEK3(.DATA,"SWITCH REQUEST DATE")
 S DATA("APPROVED")=$$FND^A1AEK3(.DATA,"APPROVED")
 S DATA("FAEDIT")=$$FND^A1AEK3(.DATA,"FORUM ACTION EDIT")
 S DATA("NSTRMD")=$$FND^A1AEK3(.DATA,"NEW SUBSCRIPTION DATE")
 S DATA("NASTRM")=$$FND^A1AEK3(.DATA,"NEW ACTIVE SUBSCRIPTION")
 S DATA("XMZ")=XMZ
 Q
 ;
 ; W $$UPDDOMA(.DATA)
 ; UPDATE ENTRY IN 11007.2
UPDDOMA(DATA) ;
 K ^XTMP("POO","UPDDOMA") S ^XTMP("POO","UPDDOMA")=$$HTFM^XLFDT($H)
 K ^XTMP("POO","DATA") M ^XTMP("POO","DATA")=DATA
 N A1AEFOAP S A1AEFOAP=1 ; Required by INPUT TRANSFORMS
 N FDA,DIERR,FDAIEN
 S FDA(3,11007.2,"?+1,",.01)=$G(DATA("DOMAIN"))
 S FDA(3,11007.2,"?+1,",.02)=$G(DATA("STRM"))
 S FDA(3,11007.2,"?+1,",.03)=$G(DATA("STRMD"))
 S FDA(3,11007.2,"?+1,",.04)=$G(DATA("IR"))
 S FDA(3,11007.2,"?+1,",.05)=$G(DATA("IS"))
 S FDA(3,11007.2,"?+1,",.06)=$G(DATA("SCS"))
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 Q:$D(DIERR) 0
 ;
 N FD2IEN S FD2IEN=+FDAIEN(1)
 K FDA
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",.01)=$G(DATA("RSTRMD"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",1)=$G(DATA("SERV"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",2)=$G(DATA("ASTRM"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",3)=$G(DATA("ASTRMD"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",4)=$G(DATA("RDUZ"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",5)=$G(DATA("RSTRM"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",6)=$G(DATA("RSTRMD"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",7)=$G(DATA("APPROVED"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",8)=$G(DATA("FAEDIT"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",9)=$G(DATA("NSTRMD"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",10)=$G(DATA("NASTRM"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",11)=$G(DATA("NSTRMD"))
 S FDA(3,11007.21,"?+1,"_FD2IEN_",",12)=$G(DATA("XMZ"))
 K DIERR D UPDATE^DIE("","FDA(3)","FD2IEN")
 Q:$D(DIERR) 0
 Q $G(FDAIEN(1))_"^"_$G(FD2IEN(1))
 ;
 ;
 ;send mail from postmaster to mailgroup
 ;ENTER
 ;  XMSUBJ  = Subject of email
 ;  DATA    = Data array for text
 ;  MGRP    = Mailgroup recipient
 ;RETURN
 ;  0^COMMENT if error, XMZ if mail sent
SNDMAIL(XMSUBJ,DATA,MGRP,VAP) ;
 K ^XTMP("POO","SNDMAIL1") S ^XTMP("POO","SNDMAIL1")="DUZ:"_$G(DUZ)_" "_$$HTFM^XLFDT($H)
 Q:'$G(DUZ) "0^MSG SEND ERROR ENTERED WITHOUT DUZ"
 Q:'$D(^VA(200,DUZ)) "0^MSG SEND ERROR DUZ NOT IN 200"
 N X,Y,DI
 ; New DUZ, set mail to come from Postmaster
 N DUZ S DUZ=0.5 D DUZ^XUP(.5)
 K ^XTMP("POO","SNDMAIL2") S ^XTMP("POO","SNDMAIL2")="DUZ:"_$G(DUZ)_"  "_$$HTFM^XLFDT($H)
 N SNDAPP,XMERR
 N XMTO S XMTO(MGRP)=""
 N XMZ S XMZ=""
 N XMDUZ S XMDUZ=DUZ
 N XMBODY S XMBODY="DATA"
 S VAP=$S($D(VAP):VAP,1:"T+100")
 N XMINSTR S XMINSTR("VAPOR")=VAP
 D SENDMSG^XMXAPI(XMDUZ,XMSUBJ,XMBODY,.XMTO,.XMINSTR,.XMZ)
 Q:$D(XMERR) "0^MSG SEND ERROR(S) ENCOUNTERED"
 K ^XTMP("POO","SNDMAIL3") S ^XTMP("POO","SNDMAIL3")="DUZ:"_$G(DUZ)_" "_$$HTFM^XLFDT($H)
 Q XMZ
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
 ; This entered after Forum personnel edit SCS field
 ;  of active stream change request for Domain
 ;  Fired off by an action cross-reference.
 ; ENTER
 ;    X1   =  Previous entry (2)
 ;    X2   =  New entry (1=approval, 3 or 4 is disapproval)
 ;    D    =  string from FM with 1st piece = DOMAIN IEN in 4.2
 ; EXIT
 ;    If approved, sends approval email to requesting domain
 ;       and updates entry in 11007.2
 ;    If disapproval, sends disapproval email to requesting
 ;       domain and updates entry in 11007.2
 ;
FRMAPPR(X1,X2,D) ;
 Q:'$L($G(X1))
 Q:'$L($G(X2))
 N UT S UT=($G(D)["A1AE:::")
 W:'UT " One moment. Sending email to Client. "
 N A1AE72I
 I UT S A1AE72I=$O(^A1AE(11007.2,"B",+D,0))
 E  S A1AE72I=DA
 N NODE S NODE=$NA(^A1AE(11007.2,A1AE72I,1,"B","A"))
 N A1AEDT S A1AEDT=$O(@NODE,-1)
 N A1AEDTI S A1AEDTI=$O(^A1AE(11007.2,A1AE72I,1,"B",A1AEDT,0))
 N IENS S IENS=A1AEDTI_","_A1AE72I_","
 N A1AEDSRZ
 S A1AEDSRZ=$$GET1^DIQ(11007.21,IENS,12,"I")
 Q:'$D(^XMB(3.9,A1AEDSRZ)) 0
 N FDATA
 D EMDATA(A1AEDSRZ,.FDATA)
 ; edit DATA("FORUM APPROVAL" to be YES or NO"
 ; build DATA array for EMAIL send
 ; Remember to set I to skip over addressing nodes in message
 N DATA,I S I=0
 F  S I=$O(FDATA(I)) Q:'I  S DATA(I)=FDATA(I),DATA(0)=I
 K FDATA
 N SUBJ,MGRP
 I X2=1 D
 . S DATA(0)=DATA(0)+1,DATA(DATA(0))="APPROVED:::YES"
 . S SUBJ="SUBSCRIPTION CHNG APPROVED"
 E  D
 . S DATA(0)=DATA(0)+1,DATA(DATA(0))="APPROVED:::NO"
 . S SUBJ="SUBSCRIPTION CHNG NOT APPROVED"
 ; Mail group should be that of the domain requesting
 ;   the stream change.  For now, I will leave at Forum
 N MGRP S MGRP="G.A1AESTRMCHG@"_$$FND(.DATA,"SERVER")
 ; Fix for Unit Testing
 I UT S MGRP=DUZ N VAP S VAP="T+1"
 S XMZ=$$SNDMAIL(SUBJ,.DATA,.MGRP,.VAP)
 ;
 I $G(UT) H 15 ; Wait for slow system
 ;
 D EMDATA^A1AEK3(XMZ,.DATA)
 S X=$$UPDDOMA^A1AEK3(.DATA)
 Q
 ;
 ;
 ;ENTER
 ;    XMZ    = IEN into 3.9 of incoming email
 ;    DATA   = Array of all variables pulled from 
 ;             the incoming email
 ;EXIT
 ;    0  = email DOES NOT match entry in 11007.2 in progress
 ;    LXMZ^IENS = email variables match entry in progress
 ;                LXMZ = IEN into 3.9 of the last email
 ;                       filed in entry in 11007.2 in progress
 ;                IENS = IENS for this entry in 11007.2
 ;                       to be used in $$GET1 calls
 ;    e.g. to pull the date the patch stream change was
 ;         requested in the most recent earlier email
 ;         $$GET1^DIQ(11007.21,IENS,12,"I")
 ;  By pulling all DATA array variables from previously
 ;  received message from this DOMAIN to Forum and comparing
 ;  array to DATA array of just received message
 ;  we assure ourselves client and forum are working
 ;  on same change patch stream request.
CHKMTCH(XMZ,DATA) ; Check incoming mail matches active Forum entry
 K ^XTMP("POO","CHKMTCH")
 S ^XTMP("POO","CHKMTCH","A")="XMZ:"_$G(XMZ)_" "_$$HTFM^XLFDT($H)
 Q:'$G(XMZ) 0
 Q:'$D(^XMB(3.9,XMZ)) 0
 Q:'$D(DATA) 0
 S ^XTMP("POO","CHKMTCH","B")="XMZ:"_$G(XMZ)_" "_$$HTFM^XLFDT($H)
 N A1AEDOM S A1AEDOM=$G(DATA("SERV")) Q:'$L(A1AEDOM) 0
 N A1AE42 S A1AE42=$O(^DIC(4.2,"B",A1AEDOM,0)) Q:'$G(A1AE42) 0
 N A1AE72 S A1AE72=$O(^A1AE(11007.2,"B",A1AE42,0))
 N NODE S NODE=$NA(^A1AE(11007.2,A1AE72,1,"B","A"))
 N A1AEDT S A1AEDT=$O(@NODE,-1)
 N A1AEDTI S A1AEDTI=$O(^A1AE(11007.2,A1AE72,1,"B",A1AEDT,0))
 N IENS S IENS=A1AEDTI_","_A1AE72_","
 N A1AEDSRZ
 S ^XTMP("POO","CHKMTCH","C")=IENS
 S A1AEDSRZ=$$GET1^DIQ(11007.21,IENS,12,"I")
 S ^XTMP("POO","CHKMTCH","E")="A1AEDSRZ:"_$G(A1AEDSRZ)
 Q:'$D(^XMB(3.9,A1AEDSRZ)) 0
 S ^XTMP("POO","CHKMTCH","D")=IENS
 N FDATA D EMDATA(A1AEDSRZ,.FDATA)
 M ^XTMP("POO","CHKMTCH","E")=DATA
 M ^XTMP("POO","CHKMTCH","F")=FDATA
 ; Now match some of DATA and FDATA
 N X
 S X=(DATA("DOMAIN")=FDATA("DOMAIN"))
 S X=(DATA("STRM")=FDATA("STRM"))_X
 S X=(DATA("STRMD")=FDATA("STRMD"))_X
 S X=(DATA("SERV")=FDATA("SERV"))_X
 S X=(DATA("RDUZ")=FDATA("RDUZ"))_X
 S X=(DATA("RSTRM")=FDATA("RSTRM"))_X
 S X=(DATA("RSTRMD")=FDATA("RSTRMD"))_X
 S ^XTMP("POO","CHKMTCH","G")="X="_$G(X)
 Q:X["0" 0 Q A1AEDSRZ_"^"_IENS
 ;
FMSUBJ ;;SUBSCRIPTION CHNG REQUEST^FCNF1
 ;;SUBSCRIPTION CHNG COMPLETED^FCNF2
 ;;SUBSCRIPTION CHNG FAILED^FCNF3
 ;;SUBSCRIPTION CHNG CONFIRMED^FCNF4
 ;;*END*
 ;
EOR ; end of routine A1AEK3
