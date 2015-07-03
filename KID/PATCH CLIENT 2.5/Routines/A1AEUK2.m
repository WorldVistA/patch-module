A1AEUK2 ;ven/lgc,jli-unit tests for A1AEK2 ; 6/4/15 12:55am
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ; CHANGE VEN/LGC 2015 05 27
 ;   UTP84 modified to add complete message DATA array
 ;
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 D EN^%ut($T(+0),1)
 Q
 ;
STARTUP ;
 S A1AEFAIL=0 ; KILLED IN SHUTDOWN
 L +^A1AE(11007.1):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on DHCP PATCH STREAM  [#11007.1] file"
 . W !," Unable to perform testing."
 ;
 ;
 N MAILGRP S MAILGRP=$O(^XMB(3.8,"B","A1AESTRMCHG",0))
 I 'MAILGRP D  Q
 . S A1AEFAIL=1
 . W !,"G.A1AESTRMCHG mail group is not set up on this system"
 . W !," Unable to perform testing."
 ;
 K ^XTMP("A1AEUK2","UNIT TEST")
 M ^XTMP("A1AEUK2","UNIT TEST",11007.1)=^A1AE(11007.1)
 ;
 Q
 ;
SHUTDOWN I '$G(A1AEFAIL) D
 .; Reverse change in 11007.1
 . D FIXDPS
 L -^XPD(11007.1):1
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ; Testing
 ;  STRM^A1AEK2      UTP80
 ;  CONFIRM^A1AEK2   UTP81
 ;  NEWSTRM^A1AEK2   UTP82
 ;  PRCSMAIL^A1AEK2  UTP83
 ;  FCNF0^A1AEK2     UTP84
 ;  FCNF1^A1AEK2     UTP85
 ;  FCNF2^A1AEK2     UTP86
 ;  FCNF3^A1AEK2     UTP87
 ;  FCNF4^A1AEK2     UTP88
 ;  FCNF5^A1AEK2     UTP89
 ;  SNDMAIL^A1AEK2   UTP90
 ;  FND^A1AEK2       UTP91
 ;
 ;
 ; Normally STRM^A1AEK2 is called through an INPUT TRANSFORM
 ;  or an Option when the site's user requests changing
 ;  their Patch Stream.  In this case, an email with a
 ;  special subject "SUBSCRIPTION CHNG REQUEST" is sent
 ;  to the PRCSMAIL linetag in A1AEK2 which forwards it
 ;  to Forum.
 ; To assist in unit testing, the input transform code
 ;  will run as normally EXCEPT setting the SLNT variable
 ;  to 1, for silent to FORUM, will generate a similar
 ;  email message except the subject is prefixed with
 ;  A1AE:::.  This is processed through PRCSMAIL as
 ;  before, however since the subject is prefixed with
 ;  A1AE::: the mail is not forwarded to FORM, but rather
 ;  an indicating email with the subject A1AE FCFN0 is
 ;  generated and again sent to the A1AESTRMCHG mail
 ;  group.  This second email does not contain a trapping
 ;  string and spawns no further activity.
 ; Thus, we are able to check the entire input transform
 ;  path without bothering FORUM.
 ;
 ;  STRM^A1AEK2
 ;Testing Input Transform on SEQUENCE change
UTP80 I '$G(A1AEFAIL) D
 . N X,MYDT S MYDT=DTIME,DTIME=1
 . N LASTXMZ S LASTXMZ=$O(^XMB(3.9,"A"),-1)
 . N ACTSTRM S ACTSTRM=$O(^A1AE(11007.1,"ASUBS",1,0))
 . N NSTRM S NSTRM=$O(^A1AE(11007.1,"ASUBS",0,0))
 . N SLNT S SLNT=1
 . D STRM^A1AEK2(NSTRM,"YES",.SLNT)
 .; This should produce two emails. The 1st generates the 2nd
 .;   subj A1AE:::SUBSCRIPTION CHNG REQUEST
 .;   subj A1AE FCNF0
 . H 20 ; Wait for slow email
 . N SUBJ S SUBJ=$E("A1AE:::SUBSCRIPTION CHNG REQUEST",1,30)
 . N NODE S NODE=$NA(^XMB(3.9,"B",SUBJ,"A"))
 . N XMZ1 S XMZ1=$O(@NODE,-1)
 . S X=(XMZ1>LASTXMZ)
 . I 'X S DTIME=MYDT D  Q
 .. D CHKEQ^%ut(1,X,"Testing1 SEQUENCE Input Transform FAILED!")
 . S X=XMZ1
 . S:X X=$O(^XMB(3.9,XMZ1,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ1,6,1,0)="G.A1AESTRMCHG")
 . I 'X S DTIME=MYDT D  Q
 .. D CHKEQ^%ut(1,X,"Testing2 SEQUENCE Input Transform FAILED!")
 . S SUBJ="A1AE FCNF0"
 . S NODE=$NA(^XMB(3.9,"B",SUBJ,"A"))
 .; Wait up to 10 seconds for second email to hit
 . N CNT F CNT=1:1:10 H 1 Q:$O(@NODE,-1)>XMZ1
 . I CNT>9 D  Q
 .. D CHKEQ^%ut(1,X,"Testing3 failed due to slow email!")
 . N XMZ2 S XMZ2=$O(@NODE,-1)
 .; Ensure the second message IEN is after the generating one
 . S X=XMZ2
 . S:X X=(XMZ1<XMZ2)
 . S:X X=$O(^XMB(3.9,XMZ2,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ2,6,1,0)="G.A1AESTRMCHG")
 . S DTIME=MYDT
 . D CHKEQ^%ut(1,X,"Testing4 SEQUENCE Input Transform FAILED!")
 Q
 ;
 ;  CONFIRM^A1AEK2
 ;Testing CONFIRM query
UTP81 I '$G(A1AEFAIL) D
 . N X,MYDT S MYDT=DTIME
 . S DTIME=1,X=$$CONFIRM^A1AEK2,DTIME=MYDT
 . D CHKEQ^%ut(0,X,"Testing CONFIRM query FAILED!")
 Q
 ;
 ;
 ; See notes for UTP70.  This tests the same message
 ;  generating procedures, however, tests the extrinsic
 ;  function, $$NEWSTRM^A1AEK2, specifically
 ;  NEWSTRM^A1AEK2
 ;Testing building formatted stream change email
UTP82 I '$G(A1AEFAIL) D
 . N X,MYDT S MYDT=DTIME
 . N NSTRM S NSTRM=$O(^A1AE(11007.1,"ASUBS",0,0))
 . N ACTSTRM S ACTSTRM=$O(^A1AE(11007.1,"ASUBS",1,0))
 . N ACTSTRMD S ACTSTRMD=$O(^A1AE(11007.1,+$G(ACTSTRM),1,"B","A"),-1)
 . N SERVER S SERVER=$$GET1^DIQ(8989.3,1_",",.01)
 . N SLNT S SLNT=1
 . N REQDT S REQDT=$$HTFM^XLFDT($H)
 . S X=$$NEWSTRM^A1AEK2(DUZ,REQDT,SERVER,NSTRM,.SLNT)
 .; This should produce two emails. The 1st generates the 2nd
 .;   subj A1AE:::SUBSCRIPTION CHNG REQUEST
 .;   subj A1AE FCNF0
 . N SUBJ S SUBJ=$E("A1AE:::SUBSCRIPTION CHNG REQUEST",1,30)
 . N NODE S NODE=$NA(^XMB(3.9,"B",SUBJ,"A"))
 . N XMZ1 S XMZ1=$O(@NODE,-1)
 . S X=XMZ1
 . S:X X=$O(^XMB(3.9,XMZ1,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ1,6,1,0)="G.A1AESTRMCHG")
 . I 'X S DTIME=MYDT D  Q
 .. D CHKEQ^%ut(1,X,"Testing SEQUENCE Input Transform FAILED!")
 . S SUBJ="A1AE FCNF0"
 . S NODE=$NA(^XMB(3.9,"B",SUBJ,"A"))
 .; Wait up to 10 seconds for second email to hit
 . N CNT F CNT=1:1:10 H 1 Q:$O(@NODE,-1)>XMZ1
 . I CNT>9 D  Q
 .. D CHKEQ^%ut(1,X,"Testing failed due to slow email!")
 . N XMZ2 S XMZ2=$O(@NODE,-1)
 .; Ensure the second message IEN is after the generating one
 . S X=XMZ2
 . S:X X=(XMZ1<XMZ2)
 . S:X X=$O(^XMB(3.9,XMZ2,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ2,6,1,0)="G.A1AESTRMCHG")
 . S DTIME=MYDT
 . D CHKEQ^%ut(1,X,"Testing SEQUENCE Input Transform FAILED!")
 Q
 ;
 ; To check that the server S.A1AENEWSTRM is working
 ;  correctly, build and send an email with a subject
 ;  that is not recognized as email that requires
 ;  processing for FORUM.
 ; If called as a function $$PRCSMAIL^A1AEK2 returns
 ;  the result of the loop searching for a indicator
 ;  subject.  Not finding one, "*END*" is returned.
 ; Note that UTP70 and UTP71 run a similar test,
 ;  however these do trap an indicator subject line.
 ;  PRCSMAIL^A1AEK2
 ;Testing Server on Mailgroup
UTP83 I '$G(A1AEFAIL) D
 .; Build email and send through "G.A1AESTRMCHG" mail group.
 . N DATA S DATA(0)=1,DATA(1)="UNIT TEST UTP73 LINE 1"
 . N XMSUBJ S XMSUBJ="UNIT TEST UTP73"
 . N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 . N VAP S VAP="T+1"
 . N X S X=$$SNDMAIL^A1AEK2(XMSUBJ,.DATA,MAILGRP,.VAP)
 .; I 'X then we have sendmail error, otherwise is XMZ
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Mail Server S.A1AENEWSTRM FAILED!")
 . N XMZ S XMZ=X
 .; OK. Mail through group sucessful. Check Server worked
 .; Check that email (XMZ should = mail) went through
 .;  the A1AESTRMCHG mail group
 . S X=$O(^XMB(3.9,XMZ,6,"B","G.A1AESTRMCHG",0))
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Mail Server S.A1AENEWSTRM FAILED!")
 .; Check that email went through the server
 . S X=$O(^XMB(3.9,XMZ,1,"C","S.A1AENEWSTRM",0))
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Mail Server S.A1AENEWSTRM FAILED!")
 .; Now check PRCSMAIL piece?
 . S X=$$PRCSMAIL^A1AEK2
 . S X=(X="*END*")
 . D CHKEQ^%ut(1,X,"Testing Mail Server S.A1AENEWSTRM FAILED!")
 Q
 ;
 ; Build and send email to mail group with subject of
 ;  A1AE:::TESTING UTP74 and simple DATA array
 ;  D FCNF0^A1AEK2 generates another email
 ;  with a subject of A1AE FCNF0 SBSCRPT CHNG REQUEST
 ;  proving that the original email was shuttled to the
 ;  correct linetag in A1AEK2
 ;  FCNF0^A1AEK2
 ;Testing Outgoing subscription change request
UTP84 I '$G(A1AEFAIL) D  Q
 . S XMSUBJ="A1AE:::TESTING UTP74"
 . N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 . N VAP S VAP="T+1"
 . N DATA S DATA(0)=5
 . S DATA(1)="SERVER:::"_$$GET1^DIQ(8989.3,1_",",.01)
 . S DATA(2)="DATE SUBSCRIPTION ACTIVE:::3110101.1234"
 . S DATA(3)="REQUESTOR DUZ:::1"
 . S DATA(4)="SWITCH TO SUBSCRIPTION:::10001"
 . S DATA(5)="SWITCH REQUEST DATE:::3110202.1234"
 . N X,XMZ S (X,XMZ)=$$SNDMAIL^A1AEK2(XMSUBJ,.DATA,MAILGRP,.VAP)
 . S:X X=$O(^XMB(3.9,XMZ,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ,6,1,0)="G.A1AESTRMCHG")
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Outgoing Subscription CHNG FAILED!")
 . D FCNF0^A1AEK2
 . S SUBJ="A1AE FCNF0"
 . S NODE=$NA(^XMB(3.9,"B",SUBJ,"A"))
 .; Wait up to 10 seconds for second email to hit
 . N CNT F CNT=1:1:10 H 1 Q:$O(@NODE,-1)>XMZ
 . I CNT>9 D  Q
 .. D CHKEQ^%ut(1,X,"Testing failed due to slow email!")
 . N XMZ2 S XMZ2=$O(@NODE,-1)
 .; Ensure the second message IEN is after the generating one
 . S X=XMZ2
 . S:X X=(XMZ<XMZ2)
 . S:X X=$O(^XMB(3.9,XMZ2,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ2,6,1,0)="G.A1AESTRMCHG")
 . D CHKEQ^%ut(1,X,"Testing Outgoing Subscription CHNG FAILED!")
 Q
 ;
 ;  FCNF1^A1AEK2
 ;Testing Incoming Forum approval
UTP85 I '$G(A1AEFAIL) D  Q
 .; Build and send FORUM APPROVAL email
 . N NSTRM S NSTRM=$O(^A1AE(11007.1,"ASUBS",0,0))
 . N ACTSTRM S ACTSTRM=$O(^A1AE(11007.1,"ASUBS",1,0))
 . N ACTSTRMD S ACTSTRMD=$O(^A1AE(11007.1,+$G(ACTSTRM),1,"B","A"),-1)
 . N SERVER S SERVER=$$GET1^DIQ(8989.3,1_",",.01)
 . N SLNT S SLNT=1
 . N REQDT S REQDT=$$HTFM^XLFDT($H)
 . N DATA S DATA(0)=7
 . S DATA(1)="SERVER:::"_SERVER
 . S DATA(2)="ACTIVE SUBSCRIPTION:::"_ACTSTRM
 . S DATA(3)="DATE SUBSCRIPTION ACTIVE:::"_ACTSTRMD
 . S DATA(4)="REQUESTOR DUZ:::"_DUZ
 . S DATA(5)="SWITCH TO SUBSCRIPTION:::"_NSTRM
 . S DATA(6)="SWITCH REQUEST DATE:::"_REQDT
 . S DATA(7)="APPROVED:::YES"
 .; Set subject fail server processing
 . N XMSUBJ S XMSUBJ="FCNF1 A1AEK2"
 . N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 . N VAP S VAP="T+1"
 .; Get IEN into 3.9 for outgoing message
 . N XMZ,X S (X,XMZ)=$$SNDMAIL^A1AEK2(XMSUBJ,.DATA,MAILGRP,.VAP)
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Incoming Forum Approval FAILED!")
 .; Run FCNF1 as extrinsic to signal unit testing
 . S X=$$FCNF1^A1AEK2
 . D CHKEQ^%ut(0,X,"Testing Incoming Forum Approval FAILED!")
 .; I X=0 put 11007.1 back as it was before
 . Q
 ;
 ;  FCNF2^A1AEK2
 ;Testing Incoming Forum rejection
UTP86 I '$G(A1AEFAIL) D  Q
 . S XMSUBJ="A1AE:::TESTING UTP76"
 . N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 . N DATA S DATA(0)=1,DATA(1)="UTP76 UNIT TEST"
 . N VAP S VAP="T+1"
 . N X,XMZ S (X,XMZ)=$$SNDMAIL^A1AEK2(XMSUBJ,.DATA,MAILGRP,.VAP)
 . S:X X=$O(^XMB(3.9,XMZ,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ,6,1,0)="G.A1AESTRMCHG")
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Incoming Forum Rejection FAILED!")
 . D FCNF2^A1AEK2
 . S SUBJ="A1AE FCNF2"
 . S NODE=$NA(^XMB(3.9,"B",SUBJ,"A"))
 .; Wait up to 10 seconds for second email to hit
 . N CNT F CNT=1:1:10 H 1 Q:$O(@NODE,-1)>XMZ
 . I CNT>9 D  Q
 .. D CHKEQ^%ut(1,X,"Testing failed due to slow email!")
 . N XMZ2 S XMZ2=$O(@NODE,-1)
 .; Ensure the second message IEN is after the generating one
 . S X=XMZ2
 . S:X X=(XMZ<XMZ2)
 . S:X X=$O(^XMB(3.9,XMZ2,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ2,6,1,0)="G.A1AESTRMCHG")
 . D CHKEQ^%ut(1,X,"Testing Incoming Forum Rejection FAILED!")
 Q
 ;
 ;  FCNF3^A1AEK2
 ;Testing Sending subscription change confirmation
UTP87 I '$G(A1AEFAIL) D  Q
 . S XMSUBJ="A1AE:::TESTING UTP77"
 . N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 . N VAP S VAP="T+1"
 . N DATA S DATA(0)=1,DATA(1)="UTP77 UNIT TEST"
 . N X,XMZ S (X,XMZ)=$$SNDMAIL^A1AEK2(XMSUBJ,.DATA,MAILGRP,.VAP)
 . S:X X=$O(^XMB(3.9,XMZ,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ,6,1,0)="G.A1AESTRMCHG")
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Subscript change confirmed msg FAILED!")
 . D FCNF3^A1AEK2
 . S SUBJ="A1AE FCNF3"
 . S NODE=$NA(^XMB(3.9,"B",SUBJ,"A"))
 .; Wait up to 10 seconds for second email to hit
 . N CNT F CNT=1:1:10 H 1 Q:$O(@NODE,-1)>XMZ
 . I CNT>9 D  Q
 .. D CHKEQ^%ut(1,X,"Testing failed due to slow email!")
 . N XMZ2 S XMZ2=$O(@NODE,-1)
 .; Ensure the second message IEN is after the generating one
 . S X=XMZ2
 . S:X X=(XMZ<XMZ2)
 . S:X X=$O(^XMB(3.9,XMZ2,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ2,6,1,0)="G.A1AESTRMCHG")
 . D CHKEQ^%ut(1,X,"Testing Subscript change confirmed msg FAILED!")
 Q
 ;
 ;  FCNF4^A1AEK2
 ;Testing Sending subscription change failed msg
UTP88 I '$G(A1AEFAIL) D  Q
 . S XMSUBJ="A1AE:::TESTING UTP78"
 . N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 . N DATA S DATA(0)=1,DATA(1)="UTP78 UNIT TEST"
 . N VAP S VAP="T+1"
 . N X,XMZ S (X,XMZ)=$$SNDMAIL^A1AEK2(XMSUBJ,.DATA,MAILGRP,.VAP)
 . S:X X=$O(^XMB(3.9,XMZ,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ,6,1,0)="G.A1AESTRMCHG")
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Subscript change failed msg FAILED!")
 . D FCNF4^A1AEK2
 . S SUBJ="A1AE FCNF4"
 . S NODE=$NA(^XMB(3.9,"B",SUBJ,"A"))
 .; Wait up to 10 seconds for second email to hit
 . N CNT F CNT=1:1:10 H 1 Q:$O(@NODE,-1)>XMZ
 . I CNT>9 D  Q
 .. D CHKEQ^%ut(1,X,"Testing failed due to slow email!")
 . N XMZ2 S XMZ2=$O(@NODE,-1)
 .; Ensure the second message IEN is after the generating one
 . S X=XMZ2
 . S:X X=(XMZ<XMZ2)
 . S:X X=$O(^XMB(3.9,XMZ2,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ2,6,1,0)="G.A1AESTRMCHG")
 . D CHKEQ^%ut(1,X,"Testing Subscript change failed msg FAILED!")
 Q
 ;
 ;  FCNF5^A1AEK2
 ;Testing Forum confirmation of subscription change
UTP89 I '$G(A1AEFAIL) D  Q
 . S XMSUBJ="A1AE:::TESTING UTP79"
 . N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 . N VAP S VAP="T+1"
 . N DATA S DATA(0)=1,DATA(1)="UTP79 UNIT TEST"
 . N X,XMZ S (X,XMZ)=$$SNDMAIL^A1AEK2(XMSUBJ,.DATA,MAILGRP,.VAP)
 . S:X X=$O(^XMB(3.9,XMZ,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ,6,1,0)="G.A1AESTRMCHG")
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Forum Confirms New Subscription FAILED!")
 . D FCNF5^A1AEK2
 . S SUBJ="A1AE FCNF5"
 . S NODE=$NA(^XMB(3.9,"B",SUBJ,"A"))
 .; Wait up to 10 seconds for second email to hit
 . N CNT F CNT=1:1:10 H 1 Q:$O(@NODE,-1)>XMZ
 . I CNT>9 D  Q
 .. D CHKEQ^%ut(1,X,"Testing failed due to slow email!")
 . N XMZ2 S XMZ2=$O(@NODE,-1)
 .; Ensure the second message IEN is after the generating one
 . S X=XMZ2
 . S:X X=(XMZ<XMZ2)
 . S:X X=$O(^XMB(3.9,XMZ2,1,"C","S.A1AENEWSTRM",0))
 . S:X X=(^XMB(3.9,XMZ2,6,1,0)="G.A1AESTRMCHG")
 . D CHKEQ^%ut(1,X,"Testing Forum Confirms New Subscription FAILED!")
 Q
 ;
 ;  SNDMAIL^A1AEK2
 ;Testing Sending mail
UTP90 I '$G(A1AEFAIL) D  Q
 . S XMSUBJ="A1AE:::TESTING SNDMAIL FUNCTION"
 . N MAILGRP S MAILGRP="G.A1AESTRMCHG"
 . N DATA S DATA(0)=1,DATA(1)="UTP80 UNIT TEST"
 . N VAP S VAP="T+1"
 . N X S X=$$SNDMAIL^A1AEK2(XMSUBJ,.DATA,MAILGRP,.VAP)
 .; X=XMZ (IEN of message in ^XMB(3.9 if worked
 . S X=$S(X>0:1,1:0)
 . D CHKEQ^%ut(1,X,"Testing Sending Mail FAILED!")
 Q
 ;
 ;  FND^A1AEK2
 ;Testing Finding data in structured email
UTP91 I '$G(A1AEFAIL) D  Q
 . N ACTSTRM S ACTSTRM=$O(^A1AE(11007.1,"ASUBS",1,0))
 . N ACTSTRMD S ACTSTRMD=$O(^A1AE(11007.1,+$G(ACTSTRM),1,"B","A"),-1)
 . N SERVER S SERVER=$$GET1^DIQ(8989.3,1_",",.01)
 . N UTP81DT S UTP81DT=$$HTFM^XLFDT($H)
 . N DATA
 . S DATA(0)=6
 . S DATA(1)="SERVER:::"_SERVER
 . S DATA(2)="ACTIVE SUBSCRIPTION:::"_ACTSTRM
 . S DATA(3)="DATE SUBSCRIPTION ACTIVE:::"_ACTSTRMD
 . S DATA(4)="REQUESTOR DUZ:::"_DUZ
 . S DATA(5)="SWITCH TO SUBSCRIPTION:::"_1
 . S DATA(6)="SWITCH REQUEST DATE:::"_UTP81DT
 . N X S X=($$FND^A1AEK2(.DATA,"ACTIVE SUBSCRIPTION")=ACTSTRM)
 . D CHKEQ^%ut(1,X,"Testing Finding data in structured email FAILED!")
 . Q
 ;
 ;
UTP92 I '$G(A1AEFAIL) D  Q
 . K ^XTMP($J,"A1AEK2 FROM TOP")
 . D ^A1AEK2
 . S X=$D(^XTMP($J,"A1AEK2 FROM TOP"))
 . D CHKEQ^%ut(1,X,"Testing calling A1AEK2 from Top FAILED!")
 . Q
 ;
FMTMSG ;;FORMATTED MESSAGE LINES 1-6
 ;;SERVER:::^SERVER
 ;;ACTIVE SUBSCRIPTION:::^ACTSTRM
 ;;DATE SUBSCRIPTION ACTIVE:::^ACTSTRMD
 ;;REQUESTOR DUZ:::^DUZ
 ;;SWITCH TO SUBSCRIPTION:::^NSTRM
 ;;SWITCH REQUEST DATE:::^REQDT
 ;;**END**
 ;
 ; Subroutine to put DHCP PATCH STREAM [#11007.1] file
 ;  back to exactly what is was before testing
FIXDPS ;Return DHCP PATCH STREAM file to original structure
 N NODE S NODE=$NA(^A1AE(11007.1))
 F  S NODE=$Q(@NODE) Q:NODE'["^A1AE(11007.1"  D
 .; Build NODX = similar node in ^XTMP
 . S TXT="^XTMP(""A1AEUK2"",""UNIT TEST"","_$P($P(NODE,"(",2),")")_")"
 . S NODX=$NA(@TXT)
 .; If similar node not in ^XTMP, kill the node in 11007.1
 . I '$D(@NODX) K @NODE Q
 .; If similar node in ^XTMP identical, nothing has
 .;  changed since unit test was run.  Keep looking.
 . I (@NODE=@NODX) Q
 .; If simlar node in ^XTMP differs in content
 .;  swap the contents for that in existence befor
 .;  running unit test
 . S (@NODE)=(@NODX)
 ; To be sure all is well, re-index entire file
 N DA,DIK
 S DIK="^A1AE(11007.1,"
 D IXALL2^DIK
 D IXALL^DIK
 Q
 ;;
XTENT ;
 ;;UTP80;Testing Input Transform on SEQUENCE change
 ;;UTP81;Testing CONFIRM query
 ;;UTP82;Testing building formatted stream change email
 ;;UTP83;Testing Server on Mailgroup
 ;;UTP84;Testing Outgoing subscription change request
 ;;UTP85;Testing Incoming Forum approval
 ;;UTP86;Testing Incoming Forum rejection
 ;;UTP87;Testing Sending subscription change confirmation
 ;;UTP88;Testing Sending subscription change failed msg
 ;;UTP89;Testing Forum confirmation of subscription change
 ;;UTP90;Testing Sending mail
 ;;UTP91;Testing Finding data in structured email
 ;;UTP92;Testing Entering A1AEK2 at Top of routine
 Q
 ;
 ;
EOR ; end of routine A1AEUK2
