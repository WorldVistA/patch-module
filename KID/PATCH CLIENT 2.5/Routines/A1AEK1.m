A1AEK1 ;ven/lgc-check patch against site's stream ;2015-04-01T00:44
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-12-27: version 2.4 released
 ;
 ;
 ; Enter from EN1+12^XPDIL, GI+5^XPDIPM
 ;
 S ^XTMP($J,"A1AEK1 FROM TOP")=""
 Q  ; Not from top
 ;
 ;
 ; NOTE: How about patches without xxx*yyy*zzz format?
 ; NOTE: How find SEQ# on patches in multiple-patch
 ;       such as DG*5.3*860 where the SEQ# isn't anywhere
 ;       in the KIDS file or Subject Header?
 ; 
 ; VARIABLES
 ;   A1AEHDR   = Patch header (1st line) gleaned in
 ;               XPDIL or XPDIPM
 ; SITE VARS
 ;    SV("STRMPRFX") =  Active Site Patch Stream Abbreviation
 ;    SV("STRMDT")   =  Date Active Patch Stream Initiated
 ;    SV("STRMNM")   =  Active Site Patch Stream Name
 ;    SV("STRM")     =  Active Site Patch Stream IEN into 11007.1
 ;    SV("ACTPKGV")  =  Site's Active Version for Package
 ;
 ; PATCH VARS   PTCHVER,PKGPRFX,PTSA
 ;    KV("PKGPRFX")  =  KIDS Package Prefix
 ;    KV("PTCHNBR")  =  KIDS Patch Number
 ;    KV("PTCHNM")   =  KIDS Patch Name
 ;    KV("PTCHRDT")  =  KIDS Patch Release Date
 ;    KV("PTCHSQN")  =  KIDS Patch SEQ#
 ;    KV("PTCHSTRM") =  KIDS Patch Stream IEN into 11007.1
 ;    KV("PTCHVER")  =  KIDS Patch Package Version
 ;          PTCINST(STREAM,SEQ#,PKG ABB,PKGVER,PATCH NAME)=""
 ;    FI             = Array of first patch SEQ# installed
 ;                     for each Patch Stream for this package
 ;                     FI(STREAM)=SEQ#
 ;    LI             = Array of last patch SEQ# installed
 ;                     for each Patch Stream for this package
 ;                     LI(STREAM)=SEQ#
 ;    MSSEQ          = Arrays of missing sequence numbers
 ;                     of patches by each stream
 ;    XPDT(n)        = Array of Builds in this Distribution
 ;                     Provided by XPDIL, XPDIPM when patch loaded
 ;    XPDT(1)        = DA^NAME [^XTMP("XPDI",DA..]
 ;                     e.g. 8994^DG*5.3*770
 ;    XPDT("DA",8994)         =1   [DA]
 ;    XPDT("NM","DG*5.3*770") =1   [PATCH NAME]
 ;    ERRMSG         = 0 no error, 1^error message = error
 ;                   
 ;ENTER
 ;  XPDQUIT   = variable passed by reference *
 ;  XPD ARRAY = Builds in this Distribution *
 ;    * Provided by XPDIL, XPDIPM when patch loaded
 ;    e.g.
 ;       XPDT(1)="8996^DG*5.3*770"
 ;       XPDT("DA",8996)=1
 ;       XPDT("NM","DG*5.3*770")=1
 ;  A1AEHDR = Subject of Packman KIDS, first line of KIDS file
 ;    e.g.
 ;       Released DG*5.3*770 SEQ #681
 ;RETURN
 ;   ABORT
 ;     0    =  Install if desired.
 ;     1    =  Abort install signal to XPDI* rtns
EN(A1AEHDR) ; Check KIDS for correct patch stream
 N ABORT S ABORT=0
 ; Quit without any action of Patch Module not installed
 Q:'$D(^A1AE(11007.1)) ABORT
 N ERRMSG S ERRMSG=0 ; No error message
 ; Pull site's patch stream variables
 D SITEVAR(.SV)
 ; Fall out without intervention if 11007.1 not set up
 Q:'$G(SV("STRM")) ABORT
 ;
 ; Run through each build that came with this patch
 ; *Note that at this time, multiple builds, new
 ;   package installs and some other KIDS may fail
 ;   review.  Installation is passed back to KIDS
 ;   without intervention.*
 N SSEKS,SEQN,XPDTCNT S (ABORT,ERRMSG,XPDTCNT)=0
 F  S XPDTCNT=$O(XPDT(XPDTCNT)) Q:'XPDTCNT  D
 . S SEQN=0
 . I XPDT(XPDTCNT)["SEQ #" S SEQN=+$P(XPDT(XPDTCNT),"SEQ #",2)
 . I 'SEQN,A1AEHDR[$P(XPDT(XPDTCNT),"^",2),A1AEHDR["SEQ #" D
 .. S SEQN=+$P(A1AEHDR,"#",2)
 .; Note SEQN (patch SEQ #) may be zero, but we may
 .;  still do some evaluation before allowing install
 .; Pull patch variables - PKG PREFIX^VERSION^PTCHNMB
 . D KIDVAR(.KV,.XPDT,XPDTCNT)
 .;
 .; Get toggle SSEKS variable.  Site Stream=KIDS Stream
 . S SSEKS=$$SSEKS(.SV,.KV)
 .;
 . S KV("PTCHSQN")=SEQN
 .;
 .; Get the Active Version of KIDS' package at this site
 .; If this is wrong package version, abort patch install
 . S SV("ACTPKGV")=$$ACTVERS(KV("PKGPRFX"))
 . I 'SV("ACTPKGV") D  Q
 .. S ABORT=1
 .. S ERRMSG=$P($T(VRSNERR),";;",2)
 .. D ERRMSG(ERRMSG,KV("PTCHNM"))
 .;
 .; Performs the following:
 .;  1. Builds array of all pkg patches previously installed
 .;     by Patch Stream
 .;  2. Builds LI array of most recently installed patch by stream
 .;  3. Builds FI array of first installed patch by stream
 .;  4. Sets STRMCHNG indicating whether this site has ever
 .;     changed patch streams
 .;
 . D GLSTINST(KV("PKGPRFX"),KV("PTCHVER"),.PTCINST,.STRMCHNG,.LI,.FI)
 .;
 .; Get array of all missing SEQ# patches for this package by stream
 . D MISSING(KV("PKGPRFX"),KV("PTCHVER"),KV("PTCHSQN"),.MSSEQ)
 .;
 .; *** For DEBUG only
 .; D MSG^KBAPEMSG("A1AEK1_1 ")
 .;
 .; Process suitability of this patch's install
 . I SSEKS S ABORT=$$SSEKSY(.MSSEQ,.ABORT) Q
 . S ABORT=$$SSEKSN(.MSSEQ,.ABORT) Q
 Q ABORT
 ;
 ; Site/Server and KIDS ARE same Patch Stream
 ; ENTER
 ;   MSSEQ   =  Array of missing installs by Patch Stream
 ;   ABORT   =  Variable representing present Abort status
 ; RETURN
 ;   ABORT set to 1 if user should abort install
 ;         otherwise, do not change
SSEKSY(MSSEQ,ABORT) ; Process when Site/Server Stream = KIDS'
 ; All patches for this Stream installed. Allow installation.
 I '$D(MSSEQ(KV("PTCHSTRM"))) Q ABORT
 ;
 ; Some earlier SEQ# KIDS patches not installed
 ; If Site/Server has never switch Streams. Allow with warning
 ;  and ability to list missing patches if desired
 I 'STRMCHNG D  Q ABORT
 . N ERRMSG S ERRMSG=$P($T(MSNGSQN),";;",2)
 . D ERRMSG(ERRMSG,KV("PTCHNM"))
 . N Y S Y=$$ANSWQ
 . N MSA S MSA=$$SHOWMSQN(.MSSEQ,KV("PKGPRFX"),KV("PTCHSTRM"),Y,.MSA)
 ;
 ; Since Site/Server has switched Streams, and some earlier
 ;  patches have not been installed, show special warning
 ;  and set ABORT to 1.  The patch should not be installed.
 S ABORT=1
 N ERRMSG S ERRMSG=$P($T(MSNGSQN),";;",2)
 D ERRMSG(ERRMSG,KV("PTCHNM"))
 D WARN
 N Y S Y=$$ANSWQ
 N MSA S MSA=$$SHOWMSQN(.MSSEQ,KV("PKGPRFX"),KV("PTCHSTRM"),Y,.MSA)
 Q ABORT
 ;
 ; 
 ; Process when Site/Server Stream NOT SAME as KIDS'
 ; ENTER
 ;   MSSEQ   =  Array of missing installs by Patch Stream
 ;   ABORT   =  Variable representing present Abort status
 ; RETURN
 ;   ABORT set to 1 if user should abort install
 ;         otherwise, do not change
SSEKSN(MSSEQ,ABORT) ; Process when Site/Server Stream NOT SAME as KIDS'
 ;
 ; I the site has never installed a KIDS patch of
 ;   this stream for this package, then ABORT installation
 I '$D(PTCINST(KV("PTCHSTRM"),KV("PKGPRFX"))) D  Q ABORT
 . N ERRMSG S ERRMSG=$P($T(WRNGSTRM),";;",2)
 . D ERRMSG(ERRMSG,KV("PTCHNM"))
 . S ABORT=1
 ;
 ; Site/Server has previously installed KIDS's Stream Patches
 ; If the KIDS SEQ# is NOT LESS than the SEQ# for the first
 ;  installed KIDS SEQ# for the Active Patch Stream, ABORT
 I '(KV("PTCHSQN")<FI(SV("STRM"))) D  Q ABORT
 . N ERRMSG S ERRMSG=$P($T(WRNGSTRM),";;",2)
 . D ERRMSG(ERRMSG,KV("PTCHNM"))
 . S ABORT=1
 ;
 ; If the KIDS SEQ# is LESS than the SEQ# for the first
 ;  installed KIDS SEQ# for the Active Patch Stream, ALLOW INSTALL
 S ABORT=0
 N ERRMSG S ERRMSG=$P($T(MSNGSQN),";;",2)
 D ERRMSG(ERRMSG,KV("PTCHNM"))
 N Y S Y=$$ANSWQ
 N MSA S MSA=$$SHOWMSQN(.MSSEQ,KV("PKGPRFX"),KV("PTCHSTRM"),Y,.MSA)
 Q ABORT
 ;
 ;
 ; Pull array of all patches previously installed for
 ;   this package for all patch streams
 ; Use ^DIC(9.4,"A1AESEQ",PKG,VER,STRM,SEQ,PATCH)
 ;  cross reference
 ;ENTER
 ;   PKGPRFX  =  Package PREFIX or abbreviation
 ;   PKGVER   =  Active package version
 ;   PTCINST  =  Patch Stream Array by reference
 ;   STRMCHNG =  variable by reference
 ;   LI       =  Last installs Array by reference
 ;   FI       =  First install Array by reference
 ;EXIT
 ;   PTCINST(STREAM,SEQ#,PKG ABB,PKGVER,PATCH NAME)=""
 ;   STRMCHNG
 ;       0=never changed patch streams
 ;       1=has changed patch streams
 ;   LI(STREAM)=SEQ#
 ;   FI(STREAM)=SEQ#
GLSTINST(PKGPRFX,PKGVER,PTCINST,STRMCHNG,LI,FI) ; Blds array of installs
 K PTCINST,LI,FI,STRMCHNG
 S STRMCHNG=0
 S PTCINST(0)=0
 N NODE S NODE=$NA(^DIC(9.4,"A1AESEQ",PKGPRFX,PKGVER))
 N STRM,SC,SNODE S SC=0,SNODE=$P(NODE,")")
 F  S NODE=$Q(@NODE) Q:NODE'[SNODE  D
 . I ($G(STRM)'=$QS(NODE,5)) S STRM=$QS(NODE,5) D
 .. S FI($QS(NODE,5))=$QS(NODE,6)
 . S PTCINST($QS(NODE,5),$QS(NODE,6),PKGPRFX,PKGVER,$QS(NODE,7))=""
 . S LI($QS(NODE,5))=$QS(NODE,6)
 . S PTCINST(0)=$G(PTCINST(0))+1
 . S SC=$S(SC=0:SC=$QS(NODE,5),SC=$QS(NODE,5):$QS(NODE,5),1:"C")
 S STRMCHNG=$S(SC="C":1,1:0)
 Q
 ;
 ; Pull array of missing sequence numbers (patches not installed)
 ;  for each stream
 ;ENTER
 ;   PKGPRFX  = Package prefix
 ;   PKGVER   = Current version of package
 ;   PTCHSEQN = Sequence number of patch in question
 ;   MSSEQ    = Array passed by reference
 ;RETURN
 ;   MSSEQ    = Array of Sequence Numbers, Patch names
 ;              that should be installed before this patch
 ;   e.g.
 ; ^DIC(9.4,"A1AESEQ","DG",5.3,1,74,"DG*5.3*77")
 ; ^DIC(9.4,"A1AESEQ","DG",5.3,1,75,"DG*5.3*79")
 ; ^DIC(9.4,"A1AESEQ","DG",5.3,1,76,"DG*5.3*80")
 ; ^DIC(9.4,"A1AESEQ","DG",5.3,1,78,"DG*5.3*82")
 ; ^DIC(9.4,"A1AESEQ","DG",5.3,1,80,"DG*5.3*78")
 ; ^DIC(9.4,"A1AESEQ","DG",5.3,1,82,"DG*5.3*88")
 ;   Returns
 ; MSSEQ(1,77)=""
 ; MSSEQ(1,79)=""
 ; MSSEQ(1,81)=""
MISSING(PKGPRFX,PKGVER,PTCHSQN,MSSEQ) ; Return missing install SEQ#
 Q:$G(PKGPRFX)=""
 Q:'$G(PKGVER)
 Q:'$G(PTCHSQN)
 K MSSEQ
 Q:$G(PTCHSQN)=1
 N STRM,SEQN,STRMABB,PTCHNM S STRMABB=""
 F  S STRMABB=$O(^A1AE(11007.1,"C",STRMABB)) Q:STRMABB=""  D
 . S STRM=+$O(^A1AE(11007.1,"C",STRMABB,0)) Q:'STRM
 . F SEQN=1:1:PTCHSQN D
 .. I $D(^DIC(9.4,"A1AESEQ",PKGPRFX,PKGVER,STRM,SEQN)) Q
 .. S MSSEQ(STRM,SEQN)=""
 Q
 ;
 ; ENTER
 ;   MSSEQ   = array by reference with uninstalled
 ;             patches and their sequence numbers
 ;   STRM    = Site's stream number
 ;   PKGPRFX = Package prefix (e.g. "DG")
 ;   Y       = 0 = user didn't wish display, save in array
 ;           = 1 = display uninstalled patches
 ;   MSARRAY = Array of missing patches
 ; RETURN
 ;   display uninstalled patches if asked to do so
 ;   return array of missing patche
SHOWMSQN(MSSEQ,PKGPRFX,STRM,Y,MSA) ; Show/build array missing SEQ#
 S ^XTMP("A1AEK1")=PKGPRFX_"^"_STRM_"^"_Y
 M ^XTMP("A1AEK1 MSSEQ")=MSSEQ(STRM)
 K MSA S MSA(0)=0
 Q:'STRM MSA(0)
 Q:'($D(MSSEQ(STRM))) MSA(0)
 N SEQN S SEQN=0
 F  S SEQN=$O(MSSEQ(STRM,SEQN)) Q:'SEQN  D
 . I Y W !,PKGPRFX," SEQ#: ",SEQN Q
 . S MSA(0)=$G(MSA(0))+1 D
 .. S MSA(MSA(0))=PKGPRFX_" SEQ#: "_SEQN
 Q MSA(0)
 ;
 ;ENTER
 ;  nothing required
 ;RETURN
 ;  Y  set to 0 for NO, 1 for YES
ANSWQ() ; Return answer of YES/NO question
 N DIR,X,Y,DTOUT,DUOUT
 S DIR(0)="Y"
 S DIR("A")="Display listing of missing sequence numbers?"
 S DIR("B")="N"
 D ^DIR
 Q +$G(Y)
 ;
 ; 
 ;
 ; ENTER
 ;   SV   =  Array by reference of Site variables built by SITEVAR
 ;   KV   =  Array by reference of KIDS variables built by KIDSVAR
 ; RETURN
 ;   1  = Site's patch stream = KIDS patch stream
 ;   0  = Site's patch stream DOES NOT match KIDS patch stream
SSEKS(SV,KV) ; Set variable representing whether SiteStream=KIDSstream
 Q (SV("STRM")=$G(KV("PTCHSTRM")))
 ;
 ; ENTER
 ;   SV   =  array by reference
 ; RETURN
 ;   SV array with Sties patch stream variables
SITEVAR(SV) ; Build array of Site Patch stream variables
 K SV
 N STRM S STRM=$O(^A1AE(11007.1,"ASUBS",1,0))
 S:STRM SV("STRM")=STRM
 S:STRM SV("STRMNM")=$P($G(^A1AE(11007.1,STRM,0)),"^")
 S:STRM SV("STRMDT")=$O(^A1AE(11007.1,STRM,1,"B","A"),-1)
 S:STRM SV("STRMPRFX")=$$GET1^DIQ(11007.1,STRM,.05)
 Q
 ;
 ;
 ; ENTER
 ;   KV
 ;   XPDT
 ;   XPDTCNT
 ; RETURN
 ;   KV array with KIDS' patch stream variables
KIDVAR(KV,XPDT,XPDTCNT) ;
 K KV Q:'XPDTCNT
 Q:'$D(XPDT(XPDTCNT))
 N PTCHNM S PTCHNM=$P(XPDT(XPDTCNT),"^",2)
 I $L(PTCHNM),($L(PTCHNM,"*")=3) D
 . S KV("PTCHNM")=PTCHNM
 . S KV("PKGPRFX")=$P(PTCHNM,"*")
 . S KV("PTCHVER")=$P(PTCHNM,"*",2)
 . S KV("PTCHNBR")=$P(PTCHNM,"*",3)
 . N I S I=0 F  S I=$O(^A1AE(11007.1,I)) Q:'I  Q:(I>KV("PTCHNBR"))  D
 .. S KV("PTCHSTRM")=I
 . N PTCHDA S PTCHDA=+$G(XPDT(XPDTCNT)) I PTCHDA D
 .. N NODE S NODE=$NA(^XTMP("XPDI",PTCHDA)),NODE=$Q(@NODE)
 .. S KV("PTCHRDT")=$P(@NODE,"^",4)
 Q
 ;
 ;ENTER
 ;   PKGPRFX  = Package prefix or abbreviation
 ;RETURN
 ;   0 = package not supported at this site
 ;   n = active version of this package
ACTVERS(PKGPRFX) ; Return Site's Active version of this package
 N I S I=$O(^DIC(9.4,"C",PKGPRFX,0)) Q:'I 0
 Q $$GET1^DIQ(9.4,I_",",13)
 ;
 ;ENTER
 ;   ERRMSG  = Error message
 ;   PTCHNM  = Patch Name (e.g. DG*5.3*770)
 ;RETURN
 ;   Write out error message and patch name if called
 ;   Return error message and patch name if entered as extrinsic
ERRMSG(ERRMSG,PTCHNM) ; Process error message
 I '$Q W !,"** ",ERRMSG," **",!
 Q:$Q ERRMSG_"^"_PTCHNM Q
 ;
 ;
WARN(STRNG) N TXT,CNT S CNT=0
 F  S TXT=$P($T(WARNTXT+CNT),";;",2) Q:TXT["*END*"  D  Q:TXT=""
 . S CNT=CNT+1 W:'$D(STRNG) !,TXT
 S STRNG=TXT
 Q:$Q STRNG Q
 ;
WARNTXT ;;                    ***
 ;;As this Site/Server has switch Patch Streams,"
 ;;  you are required to install all Patches"
 ;;  released in support of this package for
 ;;  your Active Patch Stream."
 ;;             --- OR ---"
 ;;  Edit the following fields in the Package [#9.4]
 ;;  file to indicate your unwillingness to install 
 ;;  one or more back patches"
 ;;  PATCH APPLICATION HISTORY [#.01] enter as
 ;;     Patch Number [space] "SEQ#" [space] Patch SEQ#
 ;;  DATE APPLIED [#.02] 
 ;;  APPLIED BY [#.03]
 ;;  DESCRIPTION [#1] Reason for not installing
 ;;                     ***
 ;;*END*
 ;
 ; Error messages 
PKGVERR ;;Couln't ascertain active package version on system
VRSNERR ;;Does not represent current package version
MSNGSQN ;;Earler SEQUENCE #'d patches for package not installed
WRNGSTRM ;;KIDS install not for your package STREAM
 ;
 ;
EOR ; end of routine A1AEK1
