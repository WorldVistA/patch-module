A1AE2POS ;VEN/LGC - POST INSTALLS FOR A1AE PKG ; 10/16/14 5:54pm
 ;;2.4;PATCH MODULE;;AUG 26, 2014
 ;
 ; CHANGE: (VEN/LGC) 8/27/2014
 ;        Brought Post Install A1AEPST for DHCP PATCH STREAM
 ;        [#11007.1] to build the PAT multiple in the 
 ;        BUILD [#9.6] and INSTALL [#9.7] over from 
 ;        A1AEUTL with decision to keep post installs
 ;        in the A1AE2POS routine
 ;
 ; CHANGE: (VEN/LGC) 10/14/2014
 ;        Additional code to check for existence
 ;        of DHCP PATCH STREAM [#11007.1] file
 ;        and expected entries.
 ;
 ; CHANGE: (VEN/LGC) 10/15/2014  A1AEP0
 ;        Additional code to kill all entries in
 ;        file 11007.1 and re-build with correct
 ;        FOIA VISTA and OSEHRA VISTA entries
 ;
 ; POST INSTALL entry A1AEP0
 ;                Delete any entries in DHCP PATCH STREAM
 ;                [#11007.1] file and rebuild with correctlyFOIA VISTA
 ;                entered FOIA VISTA and OSEHRA VISTA.
 ;
 ;
 ; POST INSTALL entry A1AEP1
 ;                Following DHCP PATCH STREAM [#11007.1] KIDS
 ;                install, Set all PRIMARY? to NO, then
 ;                correct one to yes if FORUM site.  Set
 ;                all SUBSCRIPTION to No, then set FOIA VISTA
 ;                to YES.  Then ask installer whether they
 ;                wish to change their site's SUBSCRIPTION.
 ;
 ; POST INSTALL entry A1AEP2
 ;                Following update/install of [#11005]
 ;                DHCP PATCHES file this updates the
 ;                PAT multiples in BUILD [#9.6] and
 ;                INSTALL [#9.7] files
 ;
 ;
 ;
 ; POST INSTALL - Following DHCP PATCH STREAM [#11007.1] KIDS
 ;                install, Set all PRIMARY? to NO, then
 ;                correct one to yes if FORUM site.  Set
 ;                all SUBSCRIPTION to No, then set FOIA VISTA
 ;                to YES.  Then ask installer whether they
 ;                wish to change their site's SUBSCRIPTION.
 ;
A1AEP1 ;
 I '$D(^A1AE(11007.1)) D  Q
 . D BMES^XPDUTL(2)
 . D MES^XPDUTL("DHCP PATCH STREAM [#11007.1] not installed")
 . D MES^XPDUTL(" Post Install cannot continue.")
 ;
 ; Kill any existing entries and rebuild
 ;
 I '$$CLRFILE D  Q
 . D BMES^XPDUTL(2)
 . D MES^XPDUTL("Unable to clear DHCP PATCH STREAM [#11007.1]")
 . D MES^XPDUTL(" Post Install cannot continue.")
 ;
 I '$$LOADFILE D  Q
 . D BMES^XPDUTL(2)
 . D MES^XPDUTL("Unable to build DHCP PATCH STREAM [#11007.1]")
 . D MES^XPDUTL(" with FOIA VISTA and OSEHRA VISTA entries.")
 . D MES^XPDUTL(" Post Install cannot continue.")
 ;
A1AEP1R ;
 I $$GET1^DIQ(11007.1,1,.01)'="FOIA VISTA" D  Q
 . D BMES^XPDUTL(2)
 . D MES^XPDUTL("DHCP PATCH STREAM [#11007.1] is incomplete")
 . D MES^XPDUTL(" Missing FOIA VISTA entry.")
 . D MES^XPDUTL(" Post Install cannot continue.")
 ;
 I $$GET1^DIQ(11007.1,10001,.01)'="OSEHRA VISTA" D  Q
 . D BMES^XPDUTL(2)
 . D MES^XPDUTL("DHCP PATCH STREAM [#11007.1] is incomplete")
 . D MES^XPDUTL(" Missing OSEHRA VISTA entry.")
 . D MES^XPDUTL(" Post Install cannot continue.")
 ;
 I $$GET1^DIQ(11007.1,1,.001)'=1 D  Q
 . D BMES^XPDUTL(2)
 . D MES^XPDUTL("DHCP PATCH STREAM [#11007.1] is CORRUPTED")
 . D MES^XPDUTL(" FOIA VISTA entry .001 not 1.")
 . D MES^XPDUTL(" Post Install cannot continue.")
 ;
 I $$GET1^DIQ(11007.1,10001,.001)'=10001 D  Q
 . D BMES^XPDUTL(2)
 . D MES^XPDUTL("DHCP PATCH STREAM [#11007.1] is CORRUPTED")
 . D MES^XPDUTL(" OSEHRA VISTA entry .001 not 10001")
 . D MES^XPDUTL(" Post Install cannot continue.")
 ;
 If $G(^DD(9.6,19,0))'["PATCH^9.619PA^^PAT;0" D  Q
 . D BMES^XPDUTL(2)
 . D MES^XPDUTL("PATCH multiple [#19] not found in BUILD file")
 . D MES^XPDUTL(" Post Install cannot continue.")
 ;
 I $G(^DD(9.7,19,0))'["PATCH^9.719PA^^PAT;0" D  Q
 . D BMES^XPDUTL(2)
 . D MES^XPDUTL("PATCH multiple [#19] not found in INSTALL file")
 . D MES^XPDUTL(" Post Install cannot continue.")
 ;
 ; Set all PRIMARY? [#.02] in 11007.1 to 0 [NO]
 D A1AEP1A
 ;
 ; Set PRIMARY? to YES if the FORUM DOMAIN [#.07] entry
 ;    for this DHCP PATCH STREAM entry matches the 
 ;    NAME of the first entry in the MAILMAN PARAMTERS
 ;    [#4.3] file.
 D A1AEP1B
 ;
 ; Set SUBSCRIPTION [#.06] in 11007.1 to 0 for
 ;    every site. Then set FOIA VISTA SUBSCRIPTION to 1
 D A1AEP1C
 ;
 ; Finally display SUBSCRIPTION to installer and ask if they
 ;    wish to switch to another PATCH SEQUENCE.
 D A1AEP1D
A1AEP1E Q
 ;
 ; Set all PRIMARY? [#.02] in 11007.1 to 0 [NO]
 ; WAS A1AEP0
A1AEP1A N DIK,DA
 S DIK(1)=".02",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 N A1AEI
 F A1AEI=0:0 S A1AEI=$O(^A1AE(11007.1,A1AEI)) Q:'A1AEI  D
 . S $P(^A1AE(11007.1,A1AEI,0),U,2)=0
 D ENALL^DIK
 Q
 ;
 ;
 ; Now Set PRIMARY? to YES if the FORUM DOMAIN [#.07] entry
 ;    for this DHCP PATCH STREAM entry matches the 
 ;    NAME of the first entry in the MAILMAN PARAMTERS
 ;    [#4.3] file.
 ; WAS A1AESP
A1AEP1B F A1AEI=0:0 S A1AEI=$O(^A1AE(11007.1,A1AEI)) Q:'A1AEI  D
 .  I $O(^A1AE(11007.1,"AFORUM",""))=$$GET1^DIQ(4.3,"1,",.01) D
 .. N A1AEFDA,DIERR
 .. S A1AEFDA(3,11007.1,A1AEI_",",.02)=1
 .. D UPDATE^DIE("","A1AEFDA(3)")
 Q
 ;
 ;
 ; Set SUBSCRIPTION [#.06] in 11007.1 to 0 for
 ;    every site. Then set FOIA VISTA SUBSCRIPTION to 1
 ; WAS A1AES0    
A1AEP1C N DIK,DA
 S DIK(1)=".06",DIK="^A1AE(11007.1,"
 D ENALL2^DIK
 N A1AEI
 F A1AEI=0:0 S A1AEI=$O(^A1AE(11007.1,A1AEI)) Q:'A1AEI  D
 . S $P(^A1AE(11007.1,A1AEI,0),U,6)=0
 S A1AEI=$O(^A1AE(11007.1,"B","FOIA VISTA",0))
 S:A1AEI $P(^A1AE(11007.1,A1AEI,0),U,6)=1
 D ENALL^DIK
 Q
 ;
 ; Now display SUBSCRIPTION to installer and ask if they
 ;    wish to switch to another PATCH SEQUENCE.
A1AEP1D ; WAS A1AEASK
 D BMES^XPDUTL(2)
 D MES^XPDUTL("Your Patch Stream SUBSCRIPTION is currently")
 D MES^XPDUTL(" set to FOIA VISTA.")
 D BMES^XPDUTL(1)
 D MES^XPDUTL("There is an option A1AE CHANGE SITE SUBSCRIPTION")
 D MES^XPDUTL(" which will let you move your Site to")
 D MES^XPDUTL(" another SUBSCRIPTION in the future")
 D MES^XPDUTL("HOWEVER you may change your SUBSCRIPTION now.")
 D BMES^XPDUTL(1)
 D MES^XPDUTL("Would you like to change your SUBSCRIPTION now?")
 N DIR,Y
 S DIR("A")="    ? ",DIR(0)="Y",DIR("B")="NO"
 D ^DIR
 I 'Y D  G A1AEEXPS
 .  D MES^XPDUTL("OK.  Will not change SUBSCRIPTION now") Q
 ;
 D MES^XPDUTL("YES.  Change SUBSCRIPTION now.")
 ;
 ; Give list of choices (1 and 10001 are only choices now)
 ; Drop them into EDIT of that entry.  Force SUBSCRIPTION
 ;  to 1?  This fills in SUBSCRIPTION DATE and OFFICAL
 ;  then hand them off to fill in comments
 K DIR S DIR(0)="P^11007.1" D ^DIR
 I 'Y D  G A1AEEXPS
 . D BMES^XPDUTL(1)
 . D MES^XPDUTL("No SUBSCRIPTION selected")
 . D MES^XPDUTL("  The SUBSCRIPTION may be changed at any time using")
 . D MES^XPDUTL("  the Option A1AE CHANGE SITE SUBSCRIPTION.")
 ;
 ; OK Y=DA for entry allow them to edit.  How to use DIE
 ;   call and A1AE CHANGE SITE SUBSCRIPTION?
 N DIE,DR
 S DA=+Y
 S DIE="^A1AE(11007.1,",DR="[A1AE CHANGE SITE SUBSCRIPTION]"
 D ^DIE
 ;
A1AEEXPS Q
 ;
 ;
 ;
 ; POST INSTALL - Following update/install of [#11005]
 ;                DHCP PATCHES file this updates the
 ;                PAT multiples in BUILD [#9.6] and
 ;                INSTALL [#9.7] files
 ; LOGIC
 ; Run down the BUILD [#9.6] file 
 ;   Save the PATCH DESIGNATION in the PMARR array
 ;     If there is an entry in the DHCP PATCHES [#11005]
 ;     file, add this pointer to the PAT multiple
 ;     in the BUILD entry and the corresponding INSTALL entry
 ;   Check for MULTIPLE BUILD entries in the BUILD 
 ;   Check recursively for MULTIPLE BUILDs in these
 ;   Update the BUILD PAT multiple with any DHCP PATCHES
 ;     entries found matching
 ;  
A1AEP2 N BN,KIEN,MIEN,PM S KIEN=0
 K BMARR
 F  S KIEN=$O(^XPD(9.6,KIEN)) Q:'KIEN  D
 .  S BN=$P($G(^XPD(9.6,KIEN,0)),"^")
 .  K BMARR D A1AEP2A(BN,.BMARR,KIEN)
 Q
 ; BMARR array contains BUILD NAME (NAME [#.01])
 ;  of this entry in 9.6 AND of any MULTIPLE BUILD
 ;  descendants
 ; As each descendant is identified, check to see if
 ;  there is a matching name in DHCP PATCHES 
 ;  If so, add to PAT multiple for parent (KIEN)
A1AEP2A(BUILD,BMARR,KIEN) ;
 N BIEN S BIEN=$O(^XPD(9.6,"B",BUILD,0)) ; do we have an IEN?
 Q:'BIEN  ; skip if no record
 S BMARR(BUILD)="" ; add to requiremenents
 D A1AEP2B(BUILD,KIEN) ; add to PAT multipe of primary entry
 N BLDNM S BLDNM=""
 F  S BLDNM=$O(^XPD(9.6,BIEN,10,"B",BLDNM)) Q:BLDNM=""  D
 . Q:$D(BMARR(BLDNM))  ; no need to continue if already have
 . D A1AEP2A(BLDNM,.BMARR,KIEN) ; add all its required patches
 Q
 ;
 ; Load PAT multiples
 ; Looks in DHCP PATCHES [#11005] for Patch Designation
 ;   matching the BUILD name (PD)
 ;   If found, the patch is entered in the primary BUILD
 ;     PAT multiple, and in PAT of all matching INSTALLS
 ; Enter
 ;   PD    =  Patch Designation to lookup in 11005
 ;              (same name as build now under review)
 ;   KIEN  =  IEN of primary Build in which PAT is being built
 ; Variables
 ;   A1AEPI  =  IEN of Patch matching name of PD
 ;   IIEN    =  IEN of INSTALLS(s) matching KIEN entry
A1AEP2B(PD,KIEN) ;
 S A1AEPI=$O(^A1AE(11005,"B",PD,0))
 ; If no match, try dropping the ".0"
 I 'A1AEPI,$P(PD,"*",2)?.NP1"0" D
 .  N PD0 S PD0=$P(PD,"*")_"*"_$P($P(PD,"*",2),".")_"*"_$P(PD,"*",3)
 .  S A1AEPI=$O(^A1AE(11005,"B",PD0,0))
 Q:'A1AEPI
 ; Update BUILD and entry PAT multiple
 D A1AEP2C(KIEN,A1AEPI,9.619)
 ; Update this and all similar named INSTALL entries PAT multiple
 N IIEN S IIEN=$O(^XPD(9.7,"B",$P(^XPD(9.6,KIEN,0),"^"),0))
 I IIEN D
 . N PMI S PMI=$P(^XPD(9.7,IIEN,0),"^")
 . N INODE S INODE=$NA(^XPD(9.7,"B",PMI))
 . F  S INODE=$Q(@INODE) Q:$QS(INODE,3)'[PMI  D
 .. S IIEN=$QS(INODE,4) D A1AEP2C(IIEN,A1AEPI,9.719)
 Q
 ; Update PAT multiple in BUILD/INSTALL entry
A1AEP2C(A1AEKI,A1AEPI,KFILE) ;
 N FDA,DIERR
 S FDA(3,KFILE,"?+1,"_A1AEKI_",",.01)=A1AEPI
 N NODE S NODE=$NA(FDA),NODE=$Q(@NODE) ;W !,NODE,"=",@NODE
 D UPDATE^DIE("","FDA(3)","")
 Q
 ;
SETPLUS  ; sets up pre-lookup transforms for existing files that need it
 S ^DD(9.49,.01,7.5)="D PLU949^A1AEDD1"
 S ^DD(9.6,.01,7.5)="D PLU96^A1AEDD1"
 S ^DD(9.7,.01,7.5)="D PLU97^A1AEDD1"
 Q
 ;
 ;
CLRFILE() N STRM,DA,DIERR,DIK S STRM=""
 F  S STRM=$O(^A1AE(11007.1,"B",STRM)) Q:STRM=""  D  Q:$D(DIERR)
 . S DA=$O(^A1AE(11007.1,"B",STRM,0)) Q:'DA
 . S DIK="^A1AE(11007.1," D ^DIK
 Q '$D(DIERR)
 ;
 ;
LOADFILE() N DIERR,FDA,FDAIEN
 S FDA(3,11007.1,"?+1,",.001)=1
 S FDA(3,11007.1,"?+1,",.01)="FOIA VISTA"
 S FDA(3,11007.1,"?+1,",.05)="FV"
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 K FDAIEN
 Q:$D(DIERR) 0
 K FDA,DIERR
 S FDA(3,11007.1,"?+1,",.001)=10001
 S FDA(3,11007.1,"?+1,",.01)="OSEHRA VISTA"
 S FDA(3,11007.1,"?+1,",.05)="OV"
 D UPDATE^DIE("","FDA(3)","FDAIEN")
 Q:$D(DIERR) 0
 Q 1
 ;
EOR ; end of routine A1AE2POS
