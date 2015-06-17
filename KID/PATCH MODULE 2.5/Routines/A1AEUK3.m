A1AEUK3 ;ven/lgc,jli-unit tests for A1AEK3 ;2015-06-03T00:12
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 D EN^%ut($T(+0),1)
 Q
 ;
STARTUP ;
 S A1AEFAIL=0 ; KILLED IN SHUTDOWN
 S A1AEDUZ=DUZ ; KILLED IN SHUTDOWN
 ;
 N MAILGRP S MAILGRP=$O(^XMB(3.8,"B","A1AEFMSC",0))
 I 'MAILGRP D  Q
 . S A1AEFAIL=1
 . W !,"G.A1AEFMSC mail group is not set up on this system"
 . W !," Unable to perform testing."
 ;
 ;
 ; Enter a new DOMAIN - A1AEUK3MUNIT
 N FDA,DIERR,FDAIEN
 S FDA(3,4.2,"?+1,",.01)="A1AEUK3MUNIT"
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 I '($G(FDAIEN(1))>0) D  Q
 . S A1AEFAIL=1
 . W !,"Could not add A1AEUK3MUNIT to domain file"
 . W !," Unable to perform testing."
 ;
 ; Build new entry in 11007.2 for A1AEUK3MUNIT
 K FDA,DIERR
 S FDA(3,11007.2,"?+1,",.01)=+FDAIEN(1)
 K FDAIEN D UPDATE^DIE("","FDA(3)","FDAIEN")
 I '($G(FDAIEN(1))>0) D  Q
 . S A1AEFAIL=1
 . W !,"Could not add A1AEUK3MUNIT to PATCH STREAM HISTORY"
 . W !," Unable to perform testing."
 ;
 ; Enter a new DOMAIN - A1AEUK3MUFAIL
 K FDA,DIERR,FDAIEN
 S FDA(3,4.2,"?+1,",.01)="A1AEUK3MUFAIL"
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 I '($G(FDAIEN(1))>0) D  Q
 . S A1AEFAIL=1
 . W !,"Could not add A1AEUK3MUFAIL to domain file"
 . W !," Unable to perform testing."
 ;
 ; Build new entry in 11007.2 for A1AEUK3MUFAIL
 K FDA,DIERR
 S FDA(3,11007.2,"?+1,",.01)=+FDAIEN(1)
 K FDAIEN D UPDATE^DIE("","FDA(3)","FDAIEN")
 I '($G(FDAIEN(1))>0) D  Q
 . S A1AEFAIL=1
 . W !,"Could not add A1AEUK3MUFAIL to PATCH STREAM HISTORY"
 . W !," Unable to perform testing."
 ;
 ; If FOIA VISTA and OSEHRA VISTA don't have FORUM DOMAIN [.07]
 ;  entries, they should.  Just fix that now.
 I $$GET1^DIQ(11007.1,1_",",.07)'="FORUM.VA.GOV" D
 . S $P(^A1AE(11007.1,1,0),"^",7)="FORUM.VA.GOV"
 I $$GET1^DIQ(11007.1,10001_",",.07)'="FORUM.OSEHRA.ORG" D
 . S $P(^A1AE(11007.1,10001,0),"^",7)="FORUM.OSEHRA.ORG"
 ; Re-index DHCP PATCH STREAM file
 S DIK(1)=".07",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 D ENALL^DIK
 ;
 K ^XTMP("A1AEUK3","UNIT TEST")
 ;
 Q
 ;
SHUTDOWN ; If an entries in PATCH STREAM HISTORY exists for
 ;   A1AEUK3MUNIT and A1AEUK3MUFAIL, delete them
 N DA,DIK,A1AEI42
 S A1AEI42=$O(^DIC(4.2,"B","A1AEUK3MUNIT",0))
 I A1AEI42 S DA=$O(^A1AE(11007.2,"B",A1AEI42,0)) D
 . S DIK="^A1AE(11007.2," D ^DIK
 ; If a domain A1AEUK3MUNIT exists, delete it
 I A1AEI42 S DA=A1AEI42,DIK="^DIC(4.2," D ^DIK
 ;
 K DA,DIK,A1AEI42
 S A1AEI42=$O(^DIC(4.2,"B","A1AEUK3MUFAIL",0))
 I A1AEI42 S DA=$O(^A1AE(11007.2,"B",A1AEI42,0)) D
 . S DIK="^A1AE(11007.2," D ^DIK
 ; If a domain A1AEUK3MUFAIL exists, delete it
 I A1AEI42 S DA=A1AEI42,DIK="^DIC(4.2," D ^DIK
 ;
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 ; ZEXCEPT: A1AEDUZ - defined in STARTUP
 K A1AEDUZ
 Q
 ;
 ; Testing
 ;  ^A1AEK3          UTP100
 ;  PRCSMAIL^A1AEK3  UTP101
 ;  FCNF1^A1AEK3     UTP102
 ;  FRMAPPR^A1AEK3   UTP103
 ;  FCNF2^A1AEK3     UTP104
 ;  FCNF3^A1AEK3     UTP105
 ;  EMDATA^A1AEK3    UTP106
 ;  UPDDOMA^A1AEK3   UTP107
 ;  SNDMAIL^A1AEK3   UTP108
 ;  FND^A1AEK3       UTP109
 ;  CHKMTCH^A1AEK3   UTP110
 ;  FCNF4^A1AEK3     UTP111
 ;
 ; ^A1AEK3
UTP100 ;Testing Calling A1AEK3 from Top
 I '$G(A1AEFAIL) D
 . K ^XTMP($J,"A1AEK3 FROM TOP")
 . D ^A1AEK3
 . S X=$D(^XTMP($J,"A1AEK3 FROM TOP"))
 . D CHKEQ^%ut(1,X,"Testing calling A1AEK3 from Top FAILED!")
 . Q
 Q
 ;
 ;
 ; To check that the server S.A1AEFMSC is working
 ;  correctly, build and send an email with a subject
 ;  that is not recognized as email that requires
 ;  processing for FORUM.
 ; If called as a function $$PRCSMAIL^A1AEK3 returns
 ;  the result of the loop searching for a indicator
 ;  subject.  Not finding one, "*END*" is returned.
 ;  PRCSMAIL^A1AEK3
UTP101 ;Testing Server on Mail Group
 I '$G(A1AEFAIL) D
 .; Build email and send through "G.A1AEFMSC" mail group.
 . N DATA S DATA(0)=1,DATA(1)="UNIT TEST UTP101 LINE 1"
 . N XMSUBJ S XMSUBJ="UNIT TEST UTP101"
 . N MAILGRP S MAILGRP="G.A1AEFMSC"
 .; D DUZ^XUP(A1AEDUZ)
 . N VAP S VAP="T+1"
 . N X S X=$$SNDMAIL^A1AEK3(XMSUBJ,.DATA,MAILGRP,.VAP)
 .; I 'X then we have sendmail error, otherwise is XMZ
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Server on Mail Group FAILED!")
 . N XMZ S XMZ=X
 .; OK. Mail through group sucessful. Check Server worked
 .; Check that email (XMZ should = mail) went through
 .;  the A1AEFMSC mail group
 . S X=$O(^XMB(3.9,XMZ,6,"B","G.A1AEFMSC",0))
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Server on Mail Group FAILED!")
 .; Check that email went through the server
 . S X=$O(^XMB(3.9,XMZ,1,"C","S.A1AEFMSC",0))
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Server on Mail Group FAILED!")
 .; Now check PRCSMAIL piece?
 . S X=$$PRCSMAIL^A1AEK3
 . S X=(X="*END*")
 . D CHKEQ^%ut(1,X,"Testing Server on Mail Group FAILED!")
 Q
 ;
 ; FCNF1^A1AEUK3
UTP102 ;Testing patch stream change request
 I '$G(A1AEFAIL) D
 .; Build in incoming patch stream change request
 . N XMSUBJ,DATA
 . S XMSUBJ="A1AE:::SUBSCRIPTION CHNG REQUEST"
 . N VAP S VAP="T+1"
 . N DATA S DATA(0)=6
 . S DATA(1)="SERVER:::A1AEUK3MUNIT"
 . S DATA(2)="ACTIVE SUBSCRIPTION:::1"
 . S DATA(3)="DATE SUBSCRIPTION ACTIVE:::3010101.0101"
 . S DATA(4)="REQUESTOR DUZ:::46"
 . S DATA(5)="SWITCH TO SUBSCRIPTION:::10001"
 . S DATA(6)="SWITCH REQUEST DATE:::3150504.1345"
 .; D DUZ^XUP(A1AEDUZ)
 . N MAILGRP S MAILGRP=DUZ
 .; Send message to DUZ
 . S X=$$SNDMAIL^A1AEK3(XMSUBJ,.DATA,MAILGRP,VAP)
 . N XMZ S XMZ=X
 . S X=($G(X)>0)
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing patch stream change request FAILED!")
 .; Check for entry in 11007.2 with SCS set to 2
 . H 10 ; hang for slow email delivery
 . D FCNF1^A1AEK3
 . H 10 ; hang for slow email delivery
 . S X=0
 . N A1AE42I,A1AE72I
 . S A1AE42I=$O(^DIC(4.2,"B","A1AEUK3MUNIT",0))
 . I A1AE42I S A1AE72I=$O(^A1AE(11007.2,"B",A1AE42I,0))
 . I A1AE72I S X=$$GET1^DIQ(11007.2,A1AE72I,.06,"I")
 . I A1AE72I S X=($G(X)=2)
 . D CHKEQ^%ut(1,X,"Testing patch stream change request FAILED!")
 Q
 ;
 ; FRMAPPR^A1AEK3
UTP103 ;Testing Forum Approving Change Request
 I '$G(A1AEFAIL) D
 .; D DUZ^XUP(A1AEDUZ)
 .; Set up X1 and X2 to emulate Forum Edit
 . N X1,X2 S X1=2,X2=1
 . N A1AE42I S A1AE42I=$O(^DIC(4.2,"B","A1AEUK3MUNIT",0))
 . N A1AE72I S A1AE72I=$O(^A1AE(11007.2,"B",A1AE42I,0))
 .; Global set Stream Change Status to 1, fix C cross
 . S $P(^A1AE(11007.2,A1AE72I,0),"^",6)=1
 . K ^A1AE(11007.2,"C",A1AE42I)
 . S ^A1AE(11007.2,"C",A1AE42I,1,A1AE72I)=""
 .; Add unit test trigger to second piece of D
 . N D S D=A1AE42I_"^"_"A1AE:::"
 . D FRMAPPR^A1AEK3(X1,X2,D)
 . H 30 ; Wait for email
 . N NODE S NODE=$NA(^A1AE(11007.2,A1AE72I,1,"B","A"))
 . N A1AEDT S A1AEDT=$O(@NODE,-1)
 . N A1AEDTI S A1AEDTI=$O(^A1AE(11007.2,A1AE72I,1,"B",A1AEDT,0))
 . N IENS S IENS=A1AEDTI_","_A1AE72I_","
 . N A1AEDAP
 . S A1AEDAP=$$GET1^DIQ(11007.21,IENS,7)
 . S X=(A1AEDAP["YES")
 . D CHKEQ^%ut(1,X,"Testing Forum Approving Change Request FAILED!")
 Q
 ;
 ; FCNF2^A1AEK3
UTP104 ;Testing Patch Stream Change Completed
 I '$G(A1AEFAIL) D
 .; Build in incoming patch stream change successful message
 . N XMSUBJ
 . S XMSUBJ="A1AE:::SUBSCRIPTION CHNG COMPLETED"
 . N VAP S VAP="T+1"
 . N DATA S DATA(0)=6
 . S DATA(1)="SERVER:::A1AEUK3MUNIT"
 . S DATA(2)="ACTIVE SUBSCRIPTION:::1"
 . S DATA(3)="DATE SUBSCRIPTION ACTIVE:::3010101.0101"
 . S DATA(4)="REQUESTOR DUZ:::46"
 . S DATA(5)="SWITCH TO SUBSCRIPTION:::10001"
 . S DATA(6)="SWITCH REQUEST DATE:::3150504.1345"
 . S DATA(7)="APPROVED:::YES"
 . S DATA(8)="FORUM ACTION EDIT:::SUCCESSFUL"
 . S DATA(9)="NEW SUBSCRIPTION DATE:::3150506.1623"
 . S DATA(10)="NEW ACTIVE SUBSCRIPTION:::10001"
 .; D DUZ^XUP(A1AEDUZ)
 .; Send message to DUZ
 . N MAILGRP S MAILGRP=DUZ
 . S X=$$SNDMAIL^A1AEK3(XMSUBJ,.DATA,MAILGRP,VAP)
 . N XMZ S XMZ=X
 . S X=($G(X)>0)
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing Patch Stream Change Completed FAILED!")
 .; Check for entry in 11007.2 with SCS set to 3
 . H 10 ; hang for slow email delivery
 . D FCNF2^A1AEK3
 . H 10 ; hang for slow email delivery
 . S X=0
 . N A1AE42I,A1AE72I
 . S A1AE42I=$O(^DIC(4.2,"B","A1AEUK3MUNIT",0))
 . I A1AE42I S A1AE72I=$O(^A1AE(11007.2,"B",A1AE42I,0))
 . I A1AE72I S X=$$GET1^DIQ(11007.2,A1AE72I,.06,"I")
 . I A1AE72I S X=($G(X)=3)
 . D CHKEQ^%ut(1,X,"Testing Patch Stream Change Completed FAILED!")
 Q
 ;
 ;FCNF3^A1AEK3
UTP105 ;Testing client side change failure
 I '$G(A1AEFAIL) D
 .; Build in incoming patch stream change request
 . N XMSUBJ,DATA
 . S XMSUBJ="A1AE:::SUBSCRIPTION CHNG REQUEST"
 . N VAP S VAP="T+1"
 . N DATA S DATA(0)=6
 . S DATA(1)="SERVER:::A1AEUK3MUFAIL"
 . S DATA(2)="ACTIVE SUBSCRIPTION:::1"
 . S DATA(3)="DATE SUBSCRIPTION ACTIVE:::3010101.0101"
 . S DATA(4)="REQUESTOR DUZ:::46"
 . S DATA(5)="SWITCH TO SUBSCRIPTION:::10001"
 . S DATA(6)="SWITCH REQUEST DATE:::3150504.1345"
 .; D DUZ^XUP(A1AEDUZ)
 . N MAILGRP S MAILGRP=DUZ
 .; Send message through DUZ
 . S X=$$SNDMAIL^A1AEK3(XMSUBJ,.DATA,MAILGRP,VAP)
 . N XMZ S XMZ=X
 . S X=($G(X)>0)
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing client side change failure FAILED!")
 .; Check for entry in 11007.2 with SCS set to 2
 . H 10 ; hang for slow email delivery
 . D FCNF1^A1AEK3
 . H 10 ; hang for slow email delivery
 . S X=0
 . N A1AE42I,A1AE72I
 . S A1AE42I=$O(^DIC(4.2,"B","A1AEUK3MUFAIL",0))
 . I A1AE42I S A1AE72I=$O(^A1AE(11007.2,"B",A1AE42I,0))
 . I A1AE72I S X=$$GET1^DIQ(11007.2,A1AE72I,.06,"I")
 . I A1AE72I S X=($G(X)=2)
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing1 client side change failure FAILED!")
 .; Now edit the request to approval YES by Forum
 .; D DUZ^XUP(A1AEDUZ)
 .; Set up X1 and X2 to emulate Forum Edit
 . N X1,X2 S X1=2,X2=1
 . N A1AE42I S A1AE42I=$O(^DIC(4.2,"B","A1AEUK3MUFAIL",0))
 . N A1AE72I S A1AE72I=$O(^A1AE(11007.2,"B",A1AE42I,0))
 .; Global set Stream Change Status to 1, fix C cross
 . S $P(^A1AE(11007.2,A1AE72I,0),"^",6)=1
 . K ^A1AE(11007.2,"C",A1AE42I)
 . S ^A1AE(11007.2,"C",A1AE42I,1,A1AE72I)=""
 .; Add unit test trigger to second piece of D
 . N D S D=A1AE42I_"^"_"A1AE:::"
 . D FRMAPPR^A1AEK3(X1,X2,D)
 . H 30 ; Wait for email
 . N NODE S NODE=$NA(^A1AE(11007.2,A1AE72I,1,"B","A"))
 . N A1AEDT S A1AEDT=$O(@NODE,-1)
 . N A1AEDTI S A1AEDTI=$O(^A1AE(11007.2,A1AE72I,1,"B",A1AEDT,0))
 . N IENS S IENS=A1AEDTI_","_A1AE72I_","
 . N A1AEDAP
 . S A1AEDAP=$$GET1^DIQ(11007.21,IENS,7)
 . S X=(A1AEDAP["YES")
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing2 client side change failure FAILED!")
 .; Build in incoming patch stream change successful message
 . N XMSUBJ
 . S XMSUBJ="A1AE:::SUBSCRIPTION CHNG FAILED"
 . N VAP S VAP="T+1"
 . N DATA S DATA(0)=6
 . S DATA(1)="SERVER:::A1AEUK3MUFAIL"
 . S DATA(2)="ACTIVE SUBSCRIPTION:::1"
 . S DATA(3)="DATE SUBSCRIPTION ACTIVE:::3010101.0101"
 . S DATA(4)="REQUESTOR DUZ:::46"
 . S DATA(5)="SWITCH TO SUBSCRIPTION:::10001"
 . S DATA(6)="SWITCH REQUEST DATE:::3150504.1345"
 . S DATA(7)="APPROVED:::YES"
 . S DATA(8)="FORUM ACTION EDIT:::FAILED"
 .; D DUZ^XUP(A1AEDUZ)
 . N MAILGRP S MAILGRP=DUZ
 .; Send message through DUZ
 . S X=$$SNDMAIL^A1AEK3(XMSUBJ,.DATA,MAILGRP,VAP)
 . N XMZ S XMZ=X
 . S X=($G(X)>0)
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Testing3 client side change failure FAILED!")
 .; Check for entry in 11007.2 with SCS set to 3
 . H 10 ; hang for slow email delivery
 . D FCNF3^A1AEK3
 . H 10 ; hang for slow email delivery
 . S X=0
 . N A1AE42I,A1AE72I
 . S A1AE42I=$O(^DIC(4.2,"B","A1AEUK3MUFAIL",0))
 . I A1AE42I S A1AE72I=$O(^A1AE(11007.2,"B",A1AE42I,0))
 . I A1AE72I S X=$$GET1^DIQ(11007.2,A1AE72I,.06,"I")
 . I A1AE72I S X=($G(X)=3)
 . D CHKEQ^%ut(1,X,"Testing3 client side change failure FAILED!")
 Q
 ;
 ;
 ;EMDATA^A1AEK3
UTP106 ;Testing pulling text from email
 I '$G(A1AEFAIL) D
 .; Look up email,save XMZ
 . N XMSUBJ,X
 . S XMSUBJ="A1AE:::SUBSCRIPTION CHNG COMPL"
 . N XMZ S XMZ=$O(^XMB(3.9,"B",XMSUBJ,"A"),-1)
 . N XMBD M XMBD=^XMB(3.9,XMZ,2)
 .; Pull structured array from 3.9, save in FDATA
 . N DATA D EMDATA^A1AEK3(XMZ,.DATA)
 .; Compare XMBD with DATA
 . N NODEX,NODED
 . S NODEX=$NA(XMBD(0)),NODED=$NA(DATA(0))
 . S X=""
 . F  S NODEX=$Q(@NODEX) Q:NODEX'["XMBD"  S NODED=$Q(@NODED) D
 .. S X=$G(X)_(@NODEX=@NODED)
 . S X=(X'["0")
 . D CHKEQ^%ut(1,X,"Testing pulling text from email FAILED!")
 Q
 ;
 ;
 ;UPDDOMA^A1AEK3
UTP107 ;Testing updating PATCH STREAM HISTORY file
 I '$G(A1AEFAIL) D
 .; Get email ien listed in our test entry
 . N A1AE42I S A1AE42I=$O(^DIC(4.2,"B","A1AEUK3MUNIT",0))
 . N A1AE72I S A1AE72I=$O(^A1AE(11007.2,"B",A1AE42I,0))
 . N NODE S NODE=$NA(^A1AE(11007.2,A1AE72I,1,"B","A"))
 . N A1AEDT S A1AEDT=$O(@NODE,-1)
 . N A1AEDTI S A1AEDTI=$O(^A1AE(11007.2,A1AE72I,1,"B",A1AEDT,0))
 . N IENS S IENS=A1AEDTI_","_A1AE72I_","
 . N XMZ
 . S XMZ=$$GET1^DIQ(11007.21,IENS,12,"I")
 .; Pull DATA array from message
 . D EMDATA^A1AEK3(XMZ,.DATA)
 .; Change DUZ DATA(4)="REQUESTOR DUZ:::46"
 . S DATA("RDUZ")=1234567
 .; Update entry
 . N X S X=$$UPDDOMA^A1AEK3(.DATA)
 . H 10
 .; Look for change in entry in 11007.2
 . N RDUZ S RDUZ=$$GET1^DIQ(11007.21,IENS,4)
 . S X=(RDUZ="1234567")
 . D CHKEQ^%ut(1,X,"Testing updating PATCH STREAM HISTORY file FAILED!")
 Q
 ;
 ;  SNDMAIL^A1AEK3
UTP108 ;Testing Sending mail
 I '$G(A1AEFAIL) D
 . S XMSUBJ="A1AE:::UNIT TESTING SNDMAIL FUNCTION"
 . N MAILGRP S MAILGRP="G.A1AEFMSC"
 . N DATA S DATA(0)=1,DATA(1)="UTP107 UNIT TEST"
 . N VAP S VAP="T+1"
 .; D DUZ^XUP(DUZ)
 . N X S X=$$SNDMAIL^A1AEK3(XMSUBJ,.DATA,MAILGRP,.VAP)
 .; X=XMZ (IEN of message in ^XMB(3.9 if worked
 . S X=$S(X>0:1,1:0)
 . D CHKEQ^%ut(1,X,"Testing Sending mail FAILED!")
 Q
 ;
 ;  FND^A1AEK3
UTP109 ;Testing Finding data in structured email
 I '$G(A1AEFAIL) D
 . N DATA
 . S DATA(0)=6
 . S DATA(1)="SERVER:::ABCDEFGH"
 . S DATA(2)="ACTIVE SUBSCRIPTION:::1"
 . S DATA(3)="DATE SUBSCRIPTION ACTIVE:::3110101.1234"
 . S DATA(4)="REQUESTOR DUZ:::799"
 . S DATA(5)="SWITCH TO SUBSCRIPTION:::10001"
 . S DATA(6)="SWITCH REQUEST DATE:::3150401.1234"
 . N X S X=($$FND^A1AEK3(.DATA,"SERVER")="ABCDEFGH")
 . D CHKEQ^%ut(1,X,"Testing Finding data in structured email FAILED!")
 Q
 ;
 ;
 ;CHKMTCH^A1AEK3
UTP110 ;Testing matching DATA array to active entry
 I '$G(A1AEFAIL) D
 .; Get email ien listed in our test entry
 . N A1AE42I S A1AE42I=$O(^DIC(4.2,"B","A1AEUK3MUNIT",0))
 . N A1AE72I S A1AE72I=$O(^A1AE(11007.2,"B",A1AE42I,0))
 . N NODE S NODE=$NA(^A1AE(11007.2,A1AE72I,1,"B","A"))
 . N A1AEDT S A1AEDT=$O(@NODE,-1)
 . N A1AEDTI S A1AEDTI=$O(^A1AE(11007.2,A1AE72I,1,"B",A1AEDT,0))
 . N IENS S IENS=A1AEDTI_","_A1AE72I_","
 . N XMZ
 . S XMZ=$$GET1^DIQ(11007.21,IENS,12,"I")
 .; Pull DATA array from message
 . D EMDATA^A1AEK3(XMZ,.DATA)
 .; Now compare DATA array to message
 . N X S X=$$CHKMTCH^A1AEK3(XMZ,.DATA)
 . S X=(X>0)
 . D CHKEQ^%ut(1,X,"Testing matching DATA array to active entry FAILED!")
 Q
 ;
 ;
 ;FCFN4^A1AEK3
UTP111 ;Testing Other Forums receiving confirmation
 ;Build and send an email to user DUZ
 I '$G(A1AEFAIL) D
 . N LASTMAIL S LASTMAIL=$O(^XMB(3.9,"A"),-1)
 . N DATA
 . S DATA(0)=10
 . S DATA(1)="SERVER:::ABCDEFGH"
 . S DATA(2)="ACTIVE SUBSCRIPTION:::1"
 . S DATA(3)="DATE SUBSCRIPTION ACTIVE:::3110101.1234"
 . S DATA(4)="REQUESTOR DUZ:::799"
 . S DATA(5)="SWITCH TO SUBSCRIPTION:::10001"
 . S DATA(6)="SWITCH REQUEST DATE:::3150401.1234"
 . S DATA(7)="APPROVED:::YES"
 . S DATA(8)="FORUM ACTION EDIT:::SUCCESSFUL"
 . S DATA(9)="NEW SUBSCRIPTION DATE:::3150506.1623"
 . S DATA(10)="NEW ACTIVE SUBSCRIPTION:::10001"
 . S XMSUBJ="A1AE:::SUBSCRIPTION CHNG CONFIRMED"
 . N MAILGRP S MAILGRP=DUZ
 . N VAP S VAP="T+1"
 . N XMZ S XMZ=$$SNDMAIL^A1AEK3(XMSUBJ,.DATA,MAILGRP,.VAP)
 . H 10
 . D FCNF4^A1AEK3
 . H 20
 .;Look for email with subject "A1AE:::UNIT TEST FCNF4"
 . S XMZ=$O(^XMB(3.9,"B","A1AE:::UNIT TEST FCNF4","A"),-1)
 . S X=(XMZ>LASTMAIL)
 . D CHKEQ^%ut(1,X,"Testing Other Forums receiving confirmation FAILED!")
 Q
 ;
 ;;
XTENT ;
 ;;UTP100;Testing Calling A1AEK3 from Top
 ;;UTP101;Testing Server on Mail Group
 ;;UTP102;Testing client patch stream change request
 ;;UTP103;Testing Forum Approving Change Request
 ;;UTP104;Testing Patch Stream Change Completed
 ;;UTP105;Testing client side change failure
 ;;UTP106;Testing pulling text from email
 ;;UTP107;Testing updating PATCH STREAM HISTORY file
 ;;UTP108;Testing Sending mail
 ;;UTP109;Testing Finding data in structured email
 ;;UTP110;Testing matching DATA array to active entry
 ;;UTP111;Testing Other Forums receiving confirmation
 Q
 ;
 Q
 ;
 ;
EOR ; end of routine A1AEUK3
