A1AEF2 ;ven/lgc-functions minimum set ;2015-05-24T00:25
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-09-17: version 2.4 released
 ;
 ;
 ; CHANGE 9/18/2014 BUILD=" " rather than BUILD=""
 ;   to account for modification of REQB to double array
 ;
 ; Bring in array of builds and delete those that
 ;   have more recent duplicates of all their
 ;   contained components
 ;
 ;
 ;ENTER
 ;   BARR    = Array of BUILDS
 ;EXIT
 ;   MINSET  = Array of BUILDS representing a
 ;             minimum set from BARR
 ;NOTE: Assume we will keep all BUILDS with
 ;          New or modified files
 ;          Unique Components
 ;          Most recently installed of duplicates
 ;NOTE: Removing 
 ;          BUILDS not belonging to the user's site's stream
 ;            determined by checking corresponding PATCHES[#11005]
 ;          BUILDS not representing current package versions
 ;   
 ;^XPD(9.6,BIEN,4,FILE#)=FILE#           FILES
 ;^XPD(9.6,BIEN,"KRN","B",.4,CI) =       PRINT TEMPLATES
 ;^XPD(9.6,BIEN,"KRN","B",.401,CI) =     SORT TEMPLATES
 ;^XPD(9.6,BIEN,"KRN","B",.402,CI) =     INPUT TEMPLATES
 ;^XPD(9.6,BIEN,"KRN","B",.403,CI) =     FORMS
 ;^XPD(9.6,BIEN,"KRN","B",.5,CI) =       FUNCTIONS
 ;^XPD(9.6,BIEN,"KRN","B",.84,CI) =      DIALOG
 ;^XPD(9.6,BIEN,"KRN","B",3.6,CI) =      BULLETINS
 ;^XPD(9.6,BIEN,"KRN","B",9.2,CI) =      HELP FRAME
 ;^XPD(9.6,BIEN,"KRN","B",9.8,CI) =      ROUTINES
 ;^XPD(9.6,BIEN,"KRN","B",19,CI) =       OPTIONS
 ;^XPD(9.6,BIEN,"KRN","B",19.1,CI) =     SECURITY KEYS
 ;^XPD(9.6,BIEN,"KRN","B",101,CI) =      PROTOCOL
 ;^XPD(9.6,BIEN,"KRN","B",409.61,CI) =   LIST TEMPLATE
 ;^XPD(9.6,BIEN,"KRN","B",8994,CI) =     REMOTE PROCEDURE
 ;
MINSET(BARR) ; Reduce array of builds to minimum set
 ; Build ^XTMP(COMPONENT,DTINSTALLED,BUILD)
 K ^XTMP($J)
 N BUILD,BIEN,DTINS
 ; CHANGE 9/18/2014 BUILD=" " rather than BUILD=""
 ;   to account for modification of REQB to double array
 S BUILD=" "
 F  S BUILD=$O(BARR(BUILD)) Q:BUILD=""  D
 . S BIEN=$O(^XPD(9.6,"B",BUILD,0)) Q:'BIEN
 . S DTINS=$$DTINS(BUILD) ; Get Install DT Inverse
 . D LOADXTMP(BUILD,BIEN,DTINS) ; Load ^XTMP($J
 ;
 ; Now build the minimum set with ^XTMP entries
 D BLDMS ; Builds new MINSET array
 ;
 ; Display array size reduction
 N BLD,CNT S CNT=0,BUILD=" "
 F  S BUILD=$O(BARR(BUILD)) Q:BUILD=""  S CNT=CNT+1
 W:$G(CNT) !,"Original REQB array CNT=",CNT
 S CNT=0,BLD=" "
 F  S BLD=$O(MINSET(BLD)) Q:BLD=""  S CNT=CNT+1
 W:$G(CNT) !,"Minimum Set of necessary BUILDS=",CNT,!
 ;K ^XTMP($J)
 Q
 ;
 ; Load ^XTMP($J nodes with all components found 
 ;   in this build
 ; ENTER
 ;    BUILD   =  BUILD name (used to identify ^XTMP node)
 ;    BIEN    =  BUILD IEN into 9.6
 ;    DTINS   =  Inverse Date build install completed
 ; RETURN
 ;    ^XTMP($J with all components/files in BUILD
LOADXTMP(BUILD,BIEN,DTINS) ; Load ^XTMP with all build components
 ;W !,"BUILD=",$G(BUILD)," BIEN=",$G(BIEN)," DTINS=",$G(DTINS)
 N NODE,STOPNODE
 S NODE=$NA(^XPD(9.6,BIEN)),STOPNODE=$P(NODE,")")
 F  S NODE=$Q(@NODE) Q:NODE'[STOPNODE  D
 .; If a file
 . I $QS(NODE,3)=4,$QS(NODE,4)>0,$QS(NODE,4)=+@NODE D  Q
 .. S ^XTMP($J,$QS(NODE,3),$QS(NODE,4),DTINS,BUILD,BIEN)=""
 .; If not a file, but another component
 . I $QS(NODE,3)="KRN",$QS(NODE,5)="NM",$QS(NODE,6)="B" D
 .. S ^XTMP($J,$QS(NODE,4),$QS(NODE,7),DTINS,BUILD,BIEN)=""
 Q
 ;
 ; Returns INVERSE Date/Time the build last installed
 ;   remembering there may be multiple installs
 ; ENTER
 ;    BUILD  =  BUILD name
 ; RETURNS
 ;    INVERSE Date/Time of most recent install
DTINS(BUILD) ; Return inverse date/time of build's most recent install
 N NODE,IIEN
 S IIEN=$O(^XPD(9.7,"B",BUILD,0)) Q:'IIEN 0 D
 . S NODE=$NA(^XPD(9.7,"B",BUILD))
 N DTINS S DTINS=0
 F  S NODE=$Q(@NODE) Q:($QS(NODE,3)'=BUILD)  D
 . I $$GET1^DIQ(9.7,$QS(NODE,4)_",",17,"I")>DTINS D
 .. S DTINS=$$GET1^DIQ(9.7,$QS(NODE,4)_",",17,"I")
 Q 9999999.999999-DTINS
 ;
 ; BUILD MINIMAL SET
 ; Logic - run down ^XTMP array and with each unique
 ;         entry idenfied by next entry not match
 ;         through subscript 3 save BUILD.  The 4th
 ;         subscript of install date/time removes
 ;         duplicates
 ; NOTE: In each ^XTMP($J node
 ;      Subscript     Contains
 ;       1            $J
 ;       2            type of component (CMP)
 ;       3            component identifier (CID)
 ;       4            INVERSE install date/time
 ;       5            BUILD
 ;       6            BUILD IEN in file 9.6
 ; Could right out file 
 ; Type of Component ,Component ID, ISTALL DATE, BUILD
 ; ENTER
 ;   ^XTMP($J nodes set
 ; RETURNS
 ;   MINSET array 
BLDMS ; Reduce component array in ^XTMP to minimal set
 K MINSET
 N NODE S NODE=$NA(^XTMP($J))
 N CMP,CID S (CMP,CID)=""
 F  S NODE=$Q(@NODE) Q:NODE=""  Q:($QS(NODE,1)'[$J)  D
 .; Keep every build with file components
 . I $QS(NODE,2)=4 S MINSET($QS(NODE,5))="" Q
 .; Quit if this is the same component and 
 .;   component description we have seen before
 .;   INVERSE DT (like lab) puts recent on top
 . I $QS(NODE,2)=CMP,$QS(NODE,3)=CID Q
 . S CMP=$QS(NODE,2),CID=$QS(NODE,3)
 . S MINSET($QS(NODE,5))=""
 ;W !,"$J = ",$J,!
 Q
 ;  
 ;
 ; Example entry
 ;^XPD(9.6,42,"KRN",0) = ^9.67PA^8994^14
 ;^XPD(9.6,42,"KRN",.4,0) = .4
 ;^XPD(9.6,42,"KRN",.401,0) = .401
 ;^XPD(9.6,42,"KRN",.402,0) = .402
 ;^XPD(9.6,42,"KRN",.402,"NM",0) = ^9.68A^1^1
 ;^XPD(9.6,42,"KRN",.402,"NM",1,0) = PRCHSITE    FILE #411^411^0
 ;^XPD(9.6,42,"KRN",.402,"NM","B","PRCHSITE    FILE #411",1) =
 ;^XPD(9.6,42,"KRN",.403,0) = .403
 ;^XPD(9.6,42,"KRN",.5,0) = .5
 ;^XPD(9.6,42,"KRN",.84,0) = .84
 ;^XPD(9.6,42,"KRN",3.6,0) = 3.6
 ;^XPD(9.6,42,"KRN",3.6,"NM",0) = ^9.68A^^
 ;^XPD(9.6,42,"KRN",9.2,0) = 9.2
 ;^XPD(9.6,42,"KRN",9.8,0) = 9.8
 ;^XPD(9.6,42,"KRN",9.8,"NM",0) = ^9.68A^10^10
 ;
 ;^XPD(9.6,42,"KRN",9.8,"NM",1,0) = PRCFQ1^^0^B6725362
 ;^XPD(9.6,42,"KRN",9.8,"NM",2,0) = PRCHE1^^0^B7002603
 ;^XPD(9.6,42,"KRN",9.8,"NM",3,0) = PRCHE1A^^0^B1284140
 ;^XPD(9.6,42,"KRN",9.8,"NM",4,0) = PRCHNPO^^0^B26343386
 ;^XPD(9.6,42,"KRN",9.8,"NM",5,0) = PRCORV^^0^B28872321
 ;^XPD(9.6,42,"KRN",9.8,"NM",6,0) = PRCORV1^^0^B19406806
 ;^XPD(9.6,42,"KRN",9.8,"NM",7,0) = PRCOVRQ^^0^B18290984
 ;^XPD(9.6,42,"KRN",9.8,"NM",8,0) = PRCOVRQ1^^0^B15086643
 ;^XPD(9.6,42,"KRN",9.8,"NM",9,0) = PRCFAC3^^0^B18041749
 ;^XPD(9.6,42,"KRN",9.8,"NM",10,0) = PRCOVTST^^0^B6119184
 ;^XPD(9.6,42,"KRN",9.8,"NM","B","PRCFAC3",9) =
 ;^XPD(9.6,42,"KRN",9.8,"NM","B","PRCFQ1",1) =
 ;^XPD(9.6,42,"KRN",9.8,"NM","B","PRCHE1",2) =
 ;^XPD(9.6,42,"KRN",9.8,"NM","B","PRCHE1A",3) =
 ;^XPD(9.6,42,"KRN",9.8,"NM","B","PRCHNPO",4) =
 ;^XPD(9.6,42,"KRN",9.8,"NM","B","PRCORV",5) =
 ;^XPD(9.6,42,"KRN",9.8,"NM","B","PRCORV1",6) =
 ;^XPD(9.6,42,"KRN",9.8,"NM","B","PRCOVRQ",7) =
 ;^XPD(9.6,42,"KRN",9.8,"NM","B","PRCOVRQ1",8) =
 ;^XPD(9.6,42,"KRN",9.8,"NM","B","PRCOVTST",10) =
 ;^XPD(9.6,42,"KRN",19,0) = 19
 ;^XPD(9.6,42,"KRN",19,"NM",0) = ^9.68A^8^8
 ;^XPD(9.6,42,"KRN",19,"NM",1,0) = PRCF MASTER^^3
 ;^XPD(9.6,42,"KRN",19,"NM",2,0) = PRCFA ACCTG TECH^^3
 ;^XPD(9.6,42,"KRN",19,"NM",3,0) = PRCFA UTILITY^^3
 ;^XPD(9.6,42,"KRN",19,"NM",4,0) = PRCO VRQ REVIEW^^0
 ;^XPD(9.6,42,"KRN",19,"NM",5,0) = PRCB MASTER^^3
 ;^XPD(9.6,42,"KRN",19,"NM",6,0) = PRCFD ACCTG PAYMENT MENU^^3
 ;^XPD(9.6,42,"KRN",19,"NM",7,0) = PRCFA DOCUMENT PROCESSING^^3
 ;^XPD(9.6,42,"KRN",19,"NM",8,0) = PRCFD PAYMENTS MENU^^3
 ;^XPD(9.6,42,"KRN",19,"NM","B","PRCB MASTER",5) =
 ;^XPD(9.6,42,"KRN",19,"NM","B","PRCF MASTER",1) =
 ;^XPD(9.6,42,"KRN",19,"NM","B","PRCFA ACCTG TECH",2) =
 ;^XPD(9.6,42,"KRN",19,"NM","B","PRCFA DOCUMENT PROCESSING",7) =
 ;^XPD(9.6,42,"KRN",19,"NM","B","PRCFA UTILITY",3) =
 ;^XPD(9.6,42,"KRN",19,"NM","B","PRCFD ACCTG PAYMENT MENU",6) =
 ;^XPD(9.6,42,"KRN",19,"NM","B","PRCFD PAYMENTS MENU",8) =
 ;^XPD(9.6,42,"KRN",19,"NM","B","PRCO VRQ REVIEW",4) =
 ;^XPD(9.6,42,"KRN",19.1,0) = 19.1
 ;^XPD(9.6,42,"KRN",101,0) = 101
 ;^XPD(9.6,42,"KRN",101,"NM",0) = ^9.68A^6^6
 ;^XPD(9.6,42,"KRN",101,"NM",1,0) = PRCO DELETE VRQ^^0
 ;^XPD(9.6,42,"KRN",101,"NM",2,0) = PRCO EDIT VENDOR ENTRY^^0
 ;^XPD(9.6,42,"KRN",101,"NM",3,0) = PRCO REVIEW ENTRY^^0
 ;^XPD(9.6,42,"KRN",101,"NM",4,0) = PRCO SEND VRQ^^0
 ;^XPD(9.6,42,"KRN",101,"NM",5,0) = PRCO VENDOR REVIEW^^0
 ;^XPD(9.6,42,"KRN",101,"NM",6,0) = PRCO PRINT ENTRY^^0
 ;^XPD(9.6,42,"KRN",101,"NM","B","PRCO DELETE VRQ",1) =
 ;^XPD(9.6,42,"KRN",101,"NM","B","PRCO EDIT VENDOR ENTRY",2) =
 ;^XPD(9.6,42,"KRN",101,"NM","B","PRCO PRINT ENTRY",6) =
 ;^XPD(9.6,42,"KRN",101,"NM","B","PRCO REVIEW ENTRY",3) =
 ;^XPD(9.6,42,"KRN",101,"NM","B","PRCO SEND VRQ",4) =
 ;^XPD(9.6,42,"KRN",101,"NM","B","PRCO VENDOR REVIEW",5) =
 ;^XPD(9.6,42,"KRN",409.61,0) = 409.61
 ;^XPD(9.6,42,"KRN",409.61,"NM",0) = ^9.68A^1^1
 ;^XPD(9.6,42,"KRN",409.61,"NM",1,0) = PRCO VENDOR REVIEW^^0
 ;^XPD(9.6,42,"KRN",409.61,"NM","B","PRCO VENDOR REVIEW",1) =
 ;^XPD(9.6,42,"KRN",8994,0) = 8994
 ;^XPD(9.6,42,"KRN",8994,"NM",0) = ^9.68A^^
 ;
 ;
EOR ; end of routine A1AEF2
