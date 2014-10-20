A1AEUPS1 ;VEN-LGC/JLI - UNIT TESTS FOR THE PATCH MODULE;2014-10-17  10:21 PM; 8/20/14 11:07pm ; 10/20/14 5:52am
 ;;2.4;PATCH MODULE;;AUG 20, 2014
 ;
 ; CHANGE: (VEN/LGC) Corrected calls to Post Install
 ;        The Post install was moved out of the A1AEUTL
 ;        routine and placed in the A1AE2POS routine
 ;        now designated as the post install repository
 ; CHANGE: (VEN/LGC) 9/29/2014
 ;        Added code at UTS0+7 to save entry temporarily
 ;        stream set to subscription, to assure after
 ;        testing this was returned to 0
 ; CHANGE: (VEN/LGC) 10/16/2014
 ;        Added code to check for exsitence and DD
 ;        of files before continuing with testing
 ;        Added A1AEFAIL to indicate when testing
 ;        should not continue.
 ;
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 ; N A1AEFAIL S A1AEFAIL=0 ; JLI 141017 moved to STARTUP
 D EN^%ut($T(+0),1)
 Q
 ;
STARTUP ;
 S A1AEFAIL=0 ; KILLED IN SHUTDOWN ; JLI 141017
 I '$D(^A1AE(11007.1)) D  Q
 . S A1AEFAIL=1
 . W !,"DHCP PATCH STREAM [#11007.1] file missing"
 . W !,"Unable to continue testing.  Try again later"
 .;
 L +^A1AE(11007.1):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on DHCP PATCH STREAM [#11007.1] file"
 . W !,"Unable to continue testing.  Try again later"
 ;
 ; Check structure of 11007.1 correct
 I $$GET1^DIQ(11007.1,1,.01)'="FOIA VISTA" D  Q
 . S A1AEFAIL=1
 . W !,"DHCP PATCH STREAM [#11007.1] missing FOIA VISTA"
 . W !,"Unable to continue testing.  Try again later"
 ;
 I $$GET1^DIQ(11007.1,10001,.01)'="OSEHRA VISTA" D  Q
 . S A1AEFAIL=1
 . W !,"DHCP PATCH STREAM [#11007.1] missing OSEHRA VISTA"
 . W !,"Unable to continue testing.  Try again later"
 ;
 I $$GET1^DIQ(11007.1,1,.001)'=1 D  Q
 . S A1AEFAIL=1
 . W !,"File #11007.1 FOIA VISTA .001 field corrupt. "
 . W !,"Unable to continue testing.  Try again later"
 ;
 I $$GET1^DIQ(11007.1,10001,.001)'=10001 D  Q
 . S A1AEFAIL=1
 . W !,"File #11007.1] OSEHRA .001 field corrupt"
 . W !,"Unable to continue testing.  Try again later"
 Q
 ;
SHUTDOWN L -^A1AE(11007.1)
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ; Unit Test setting all PRIMARY to 0
 ;   1. Save the IEN of entry now set as PRIMARY
 ;   2. Run A1AEP0
 ;   3. Find IEN set to 1 (shouldn't be any)
 ;   4. Return original PRIMARY setting
 ;   5. Run Unit Test
 ;
 ;
UTP1 ;
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP, killed in SHUTDOWN
 I A1AEFAIL=1 D  Q
 . ;D FAIL^%ut("Unable to perform testing") ;commented out JLI 141017
 ;
 N A1AEI,UTOIEN,UTPOST
 ; Save IEN of entry now set as PRIMARY?
 S UTOIEN=$$UTPRIEN
 ; If no Stream was set to PRIMARY, we must set one 
 ;  or we are unable to check that clearing all PRIMARY works
 S:'UTOIEN $P(^A1AE(11007.1,1,0),U,2)=1
 ; Call should set all PRIMARY to 0
 D A1AEP1A^A1AE2POS
 ; See if all PRIMARY are 0
 S UTPOST=$$UTPRIEN
 ;
 ; Return PRIMARY to original value
 S:UTOIEN $P(^A1AE(11007.1,UTOIEN,0),U,2)=1
 D CHKEQ^%ut(0,UTPOST,"Set all PRIMARY to 0 FAILED")
 ;
 ; Now that we have returned PRIMARY to original setting
 ;   clean up everything by rebuilding all cross-references
 N DIK,DA
 S DIK(1)=".02",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 D ENALL^DIK
 Q
 ;
 ;
 ; Note in Unit Testing of setting PRIMARY? to match that
 ;   assigned for specific FORUM Domains, that a non-FORUM
 ;   site will test only that an incorrect PRIMARY? will
 ;   not be set.
 ;   The test in a FORUM Domain site will test whether
 ;   the PRIMARY? is set, AND set correctly
 ; Logic for Post Install setting or PRIMARY worked correctly
 ;   UTDOM = MAIL PARAMETERS not have FORUM domain = NO PRIMARY
 ;   UTDOM = NOT A FORUM domain = NO PRIMARY
 ;   UTDOM = FORUM.XXX.YYY
 ;       A FORUM DOMAIN entry = MAIL PARAMETER DOMAIN = is PRIMARY
 ;       No FORUM DOMAIN entry = MAIL PARAMETER DOMAIN = NO PRIMARY
 ;
UTP2 ;
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP, killed in SHUTDONW
 I A1AEFAIL=1 D  Q
 . ;D FAIL^%ut("Unable to perform testing") ; JLI 141017 COMMENTED OUT
 ;
 N A1AEI,UTDOM,UTOIEN,UTPOST,X
 S UTDOM=$$GET1^DIQ(4.3,"1,",.01)
 ; Save present PRIMARY patch stream IEN - if one set
 S UTOIEN=$$UTPRIEN
 ; If a Patch Stream PRIMARY? is set to YES, set to NO
 S:UTOIEN $P(^A1AE(11007.1,UTOIEN,0),U,2)=0
 ; Run code to set PRIMARY? according to FORUM DOMAIN entry
 D A1AEP1B^A1AE2POS
 ; Get the IEN of the entry having PRIMARY? set to yes now
 ; Note that if no FORUM DOMAIN entry is filled into
 ;   an entry in DHCP PATCH STREAM then all entries
 ;   remain CORRECTLY at PRIMARY=0
 S UTPOST=$$UTPRIEN
 S X=1
 ; If all PRIMARY are 0, and
 ;    a) and MAIL DOMAIN not contain "FORUM" --- correct 
 ;    b) and no FORUM DOMAIN fields set in 11007.1 --- correct
 ; If there is a PRIMARY set then correct if,
 ;    a) the mail domain (UTDOM) contains "FORUM"
 ;    b) and, the FORUM DOMAIN for this entry set to PRIMARY
 ;            matches the mail domain
 I 'UTPOST,$P($G(UTDOM),".")'["FORUM" S X=0
 I 'UTPOST,'$D(^A1AE(11007.1,"AFORUM")) S X=0
 I $P(UTDOM,".")["FORUM",UTDOM=$$GET1^DIQ(11007.1,UTPOST_",",.07) D
 . S X=0
 D CHKEQ^%ut(0,X,"Set FORUM SITE PRIMARY to 1 FAILED")
 ; Put settings back as they were, even if incorrect
 I UTOIEN'=UTPOST D
 .  S $P(^A1AE(11007.1,UTPOST,0),U,2)=0
 .  S $P(^A1AE(11007.1,UTOIEN,0),U,2)=1
 N DIK,DA
 S DIK(1)=".02",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 D ENALL^DIK
 Q
 ;
 ;
 ; Unit Testing for subroutine that sets all SUBSCRIPTION [#.06]
 ;   to 0 [NO], then sets SUBSCRIPTION to YES for the FOIA VISTA
 ;   Stream.
 ; Rather than correct a site's entries if they are set wrong
 ;   we will first save off their present SUBSCRIPTION entry
 ;   in the DHCP PATCH STREAM [#11007.1] file so we might 
 ;   set it back after our test.
 ; Logic for test
 ;   1. Save off IEN for entry in DHCP PATCH STREAM [#11007.1]
 ;       SUBSCRIPTION presently set to 1 [YES]
 ;   2. Run A1AEP1C^A1AE2POS in the Post Install routine
 ;      which should set SUBSCRIPTION to 0, then set
 ;      the FOIA VISTA site to SUBSCRIPTION
 ;   3. Set the IEN for Stream SUBSCRIPTION back to original
 ;   4. Run Unit Test code 
 ;
UTP3 ;
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP, killed in SHUTDOWN
 I A1AEFAIL=1 D  Q
 . ;D FAIL^%ut("Unable to perform testing") ; JLI 141017 commented out
 ;
 N A1AEI,UTOIEN,UTPOST,UTMPOST
 ; Save off stream now set to SUBSCRIPTION
 S UTOIEN=$$UTSUBS
 ; If no Stream was set to SUBSCRIPTION, we must set one
 ;  or we are unable to check that clearing all SUBSCRIPTION works
 I 'UTOIEN S A1AEI=$O(^A1AE(11007.1,"A"),-1) D
 .  S $P(^A1AE(11007.1,A1AEI,0),U,6)=1
 .  S UTMPOST=A1AEI ; Temporariy set
 ; Call subroutine in Post Install routine that sets
 ;   SUBSCRIPTION to the FOIA VISTA entry
 D A1AEP1C^A1AE2POS
 ; See what entry in 11007.1 file is now set to SUBSCRIPTION
 S UTPOST=$$UTSUBS
 ; Return SUBSCRIPTION to original value
 I 'UTOIEN,$G(UTMPOST) S $P(^A1AE(11007.1,UTMPOST,0),U,6)=0
 I UTOIEN,UTOIEN'=UTPOST D
 . S $P(^A1AE(11007.1,UTPOST,0),U,6)=0
 . S $P(^A1AE(11007.1,UTOIEN,0),U,6)=1
 S X=1
 I UTPOST,$P(^A1AE(11007.1,UTPOST,0),U)="FOIA VISTA" S X=0
 D CHKEQ^%ut(0,X,"Set SEQUENCE appropriate for FORUM DOMAIN FAILED")
 N DIK,DA
 S DIK(1)=".06",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 D ENALL^DIK
 Q
 ;
 ;
 ;
 ; Function to return IEN in DHCP PATCH STREAM [#11007.1]
 ;   entry having PRIMARY? [#.02] field set
UTPRIEN() N A1AEI,UTPRIM S (A1AEI,UTPRIM)=0
 F  S A1AEI=$O(^A1AE(11007.1,A1AEI)) Q:'A1AEI  D
 .  I $P(^A1AE(11007.1,A1AEI,0),U,2) S UTPRIM=A1AEI
 Q UTPRIM
 ;
 ; Function to return IEN in DHCP PATCH STREAM [#11007.1]
 ;   entry having SUBSCRIPTION [#.03] field set
UTSUBS() N UTSUBS S (A1AEI,UTSUBS)=0
 F  S A1AEI=$O(^A1AE(11007.1,A1AEI)) Q:'A1AEI  D
 .  I $P(^A1AE(11007.1,A1AEI,0),U,6) S UTSUBS=A1AEI
 Q UTSUBS
 ;
CHKPLUS  ; @TEST check setting of Pre-LookUp Transforms
 ; remove existing nodes that will be set
 K ^DD(9.49,.01,7.5),^DD(9.6,.01,7.5),^DD(9.7,.01,7.5)
 ; now run code to set them
 D SETPLUS^A1AE2POS
 ; and check that they are set
 D CHKTF^%ut($D(^DD(9.49,.01,7.5)),"Failed to set Pre-Lookup Transform (node 7.5) for subfile 9.49")
 D CHKTF^%ut($D(^DD(9.6,.01,7.5)),"Failed to set Pre-Lookup Transform (node 7.5) for file 9.6")
 D CHKTF^%ut($D(^DD(9.7,.01,7.5)),"Failed to set Pre-Lookup Transform (node 7.5) for file 9.7")
 Q
 ;
XTENT ;
 ;;UTP1;Testing setting of all PRIMARY? to NO in 11007.1
 ;;UTP2;Testing setting PRIMARY? to yes if FORUM site
 ;;UTP3;Testing setting of SUBSCRIPTION to FOIA VISTA
 Q
 ;
 ;
EOR ; end of routine A1AEUPS1
