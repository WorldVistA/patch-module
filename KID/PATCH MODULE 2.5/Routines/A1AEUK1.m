A1AEUK1 ;ven/lgc,jli-unit tests for A1AEK1 ; 6/4/15 7:35pm
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
 L +^XPD(9.6):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on BUILD [#9.6] file"
 . W !," Unable to perform testing."
 ;
 L +^A1AE(11005):1 I '$T D  Q
 . S A1AEFAIL=1
 . W !,"Unable to obtain lock on PATCHES [#11005] file"
 . W !," Unable to perform testing."
 Q
 ;
SHUTDOWN L -^XPD(9.6):1
 L -^A1AE(11005):1
 ; ZEXCEPT: A1AEFAIL - defined in STARTUP
 K A1AEFAIL
 Q
 ;
 ; Testing
 ;  A1AEK1             UTP60
 ;  EN^A1AEK1          UTP61
 ;  SSEKSY^A1AEK1      UTP62
 ;  SSEKSN^A1AEK1      UTP63
 ;  GLSTINST^A1AEK1    UTP64
 ;  MISSING^A1AEK1     UTP65
 ;  SHOWMSQN^A1AEK1    UTP66
 ;  ANSWQ^A1AEK1       UTP67
 ;  SSEKS^A1AEK1       UTP68
 ;  SITEVAR^A1AEK1     UTP69
 ;  KIDVAR^A1AEK1      UTP70
 ;  ACTVERS^A1AEK1     UTP71
 ;  ERRMSG^A1AEK1      UTP72
 ;  WARN^A1AEK1        UTP73
 ;
 ;A1AEK1
UTP60 ; Test entering routine at top
 I '$G(A1AEFAIL) D  Q
 . K ^XTMP($J,"A1AEK1 FROM TOP")
 . D ^A1AEK1
 . S X=$D(^XTMP($J,"A1AEK1 FROM TOP"))
 . D CHKEQ^%ut(1,X,"Testing calling A1AEK1 from Top FAILED!")
 . Q
 ;
 ;EN^A1AEK1
UTP61 ; Test suitability of patch for install
 I '$G(A1AEFAIL) D  Q
 . N X
 . N SV D SITEVAR^A1AEK1(.SV)
 . S SV("ACTPKGV")=$$ACTVERS^A1AEK1("DG")
 . N NODE S NODE=$NA(^DIC(9.4,"A1AESEQ","DG",SV("ACTPKGV")))
 . S NODE=$Q(@NODE)
 . N XPDT S XPDT(1)="1234^"_$QS(NODE,7)
 . S ^XTMP("XPDI",1234,"A1AEUK1",4321,0)=$QS(NODE,7)_"^DG^0^3080108^y"
 . N KV D KIDVAR^A1AEK1(.KV,.XPDT,1)
 . N A1AEHDR S A1AEHDR="Released "_KV("PTCHNM")_"SEQ #681"
 . S X=999
 . N MYDT S MYDT=DTIME,DTIME=1
 . S X=$$EN^A1AEK1(A1AEHDR)
 . S DTIME=MYDT
 . S X=($G(X)<2)
 . D CHKEQ^%ut(1,X,"Testing suitability of patch for install FAILED!")
 . Q
 ;
 ;SSEKSY^A1AEK1
UTP62 ; Test procedures when Patch and Site Stream match
 I '$G(A1AEFAIL) D  Q
 . N X
 . N SV D SITEVAR^A1AEK1(.SV)
 . S SV("ACTPKGV")=$$ACTVERS^A1AEK1("DG")
 . N NODE S NODE=$NA(^DIC(9.4,"A1AESEQ","DG",SV("ACTPKGV")))
 . S NODE=$Q(@NODE)
 . N XPDT S XPDT(1)="1234^"_$QS(NODE,7)
 . S ^XTMP("XPDI",1234,"A1AEUK1",4321,0)=$QS(NODE,7)_"^DG^0^3080108^y"
 . N KV D KIDVAR^A1AEK1(.KV,.XPDT,1)
 . K ^XTMP("XPDI",1234,"A1AEUK1",4321,0)
 . N SSEKS S SSEKS=$$SSEKS^A1AEK1(.SV,.KV)
 . N ABORT,MSSEQ S (ABORT,MSSEQ(0))=0
 . S (X,ABORT)=$$SSEKSY^A1AEK1(.MSSEQ,.ABORT)
 .; ABORT should return unchanged. No missing back patches
 . I ABORT D  Q
 .. D CHKEQ^%ut(0,X,"Testing KIDS/Site Stream Match FAILED!")
 .; Missing back patches, site hasn't changed Streams
 . N STRMCHNG S STRMCHNG=0
 . S MSSEQ(KV("PTCHSTRM"),1)=""
 . N MYDT S MYDT=DTIME,DTIME=1
 . S (X,ABORT)=$$SSEKSY^A1AEK1(.MSSEQ,.ABORT)
 . S DTIME=MYDT
 . I ABORT D  Q
 .. D CHKEQ^%ut(0,X,"Testing KIDS/Site Stream Match FAILED!")
 .; Missing back patches, site has changed streams
 . S STRMCHNG=1
 . S MYDT=DTIME,DTIME=1
 . S (X,ABORT)=$$SSEKSY^A1AEK1(.MSSEQ,.ABORT)
 . S DTIME=MYDT
 . D CHKEQ^%ut(1,X,"Testing KIDS/Site Stream Match FAILED!")
 . Q
 ;
 ;SSEKSN^A1AEK1
UTP63 ; Test procedures when Patch and Site Stream DO NOT match
 I '$G(A1AEFAIL) D  Q
 . N X
 . N SV D SITEVAR^A1AEK1(.SV)
 . S SV("ACTPKGV")=$$ACTVERS^A1AEK1("DG")
 . N NODE S NODE=$NA(^DIC(9.4,"A1AESEQ","DG",SV("ACTPKGV")))
 . S NODE=$Q(@NODE)
 . N XPDT S XPDT(1)="1234^"_$QS(NODE,7)
 . S ^XTMP("XPDI",1234,"A1AEUK1",4321,0)=$QS(NODE,7)_"^DG^0^3080108^y"
 . N KV D KIDVAR^A1AEK1(.KV,.XPDT,1)
 . K ^XTMP("XPDI",1234,"A1AEUK1",4321,0)
 . N SSEKS S SSEKS=0
 . N ABORT,MSSEQ S (ABORT,MSSEQ(0))=0
 . S KV("PTCHSTRM")=9 ; No such patch stream exists
 . N MYDT S MYDT=DTIME,DTIME=1
 . S (X,ABORT)=$$SSEKSN^A1AEK1(.MSSEQ,.ABORT)
 . S DTIME=MYDT
 . I 'ABORT D  Q
 .. D CHKEQ^%ut(1,X,"Testing KIDS/Site Stream NOT Match FAILED!")
 . N PTCINST S PTCINST(KV("PTCHSTRM"),KV("PKGPRFX"))=""
 . S KV("PTCHSQN")=99
 . N FI S FI(SV("STRM"))=9
 . S DTIME=1
 . S (X,ABORT)=$$SSEKSN^A1AEK1(.MSSEQ,.ABORT)
 . S DTIME=MYDT
 . I 'ABORT D  Q
 .. D CHKEQ^%ut(1,X,"Testing KIDS/Site Stream NOT Match FAILED!")
 . S KV("PTCHSQN")=9
 . S FI(SV("STRM"))=99
 . S DTIME=1
 . S (X,ABORT)=$$SSEKSN^A1AEK1(.MSSEQ,.ABORT)
 . S DTIME=MYDT
 . D CHKEQ^%ut(0,X,"Testing KIDS/Site Stream NOT Match FAILED!")
 . Q
 ;
 ;
 ;GLSTINST^A1AEK1
UTP64 ; Test building array of installed patches for this package
 I '$G(A1AEFAIL) D
 . N PKGPRFX,PKGVER,X S X=1
 . S PKGPRFX="DG"
 . S PKGVER=$$ACTVERS^A1AEK1(PKGPRFX)
 .; Run API with POO variables
 . N POO,POOSTCH,LIPOO,FIPOO
 . D GLSTINST^A1AEK1(PKGPRFX,PKGVER,.POO,.POOSTCH,.LIPOO,.FIPOO)
 .; Now build new set of variables
 . N PTCINST,STRMCHNG,LI,FI
 . S STRMCHNG=0
 . S PTCINST(0)=0
 . N NODE S NODE=$NA(^DIC(9.4,"A1AESEQ",PKGPRFX,PKGVER))
 . N STRM,SC,SNODE S SC=0,SNODE=$P(NODE,")")
 . F  S NODE=$Q(@NODE) Q:NODE'[SNODE  D
 .. I ($G(STRM)'=$QS(NODE,5)) S STRM=$QS(NODE,5) D
 ... S FI($QS(NODE,5))=$QS(NODE,6)
 .. S PTCINST($QS(NODE,5),$QS(NODE,6),PKGPRFX,PKGVER,$QS(NODE,7))=""
 .. S LI($QS(NODE,5))=$QS(NODE,6)
 .. S PTCINST(0)=$G(PTCINST(0))+1
 .. S SC=$S(SC=0:SC=$QS(NODE,5),SC=$QS(NODE,5):$QS(NODE,5),1:"C")
 . S STRMCHNG=$S(SC="C":1,1:0)
 .; Now check arrays
 . N NA,NB S NA=$NA(POO),NB=$NA(PTCINST)
 . S X=1
 . F  S NA=$Q(@NA),NB=$Q(@NB) Q:NA'["POO"  Q:NB'["PTSA"  D  Q:'X
 .. I $QS(NA,1)'=$QS(NB,1) S X=0
 .. I $QS(NA,2)'=$QS(NB,2) S X=0
 .. I @NA'=@NB S X=0
 .; X=1 shows full match
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Test array of installed patches FAILED!")
 . S NA=$NA(FIPOO),NB=$NA(FI)
 . F  S NA=$Q(@NA),NB=$Q(@NB) Q:NA'["POO"  Q:NB'["PTSA"  D  Q:'X
 .. I $QS(NA,1)'=$QS(NB,1) S X=0
 .. I $QS(NA,2)'=$QS(NB,2) S X=0
 .. I @NA'=@NB S X=0
 .; X=1 shows full match
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Test array of installed patches FAILED!")
 . S NA=$NA(LIPOO),NB=$NA(LI)
 . F  S NA=$Q(@NA),NB=$Q(@NB) Q:NA'["POO"  Q:NB'["PTSA"  D  Q:'X
 .. I $QS(NA,1)'=$QS(NB,1) S X=0
 .. I $QS(NA,2)'=$QS(NB,2) S X=0
 .. I @NA'=@NB S X=0
 .; X=1 shows full match
 . I 'X D  Q
 .. D CHKEQ^%ut(1,X,"Test array of installed patches FAILED!")
 .;
 . S:X X=(POOSTCH=STRMCHNG)
 . D CHKEQ^%ut(1,X,"Test array of installed patches FAILED!")
 Q
 ;
 ;MISSING^A1AEK1
UTP65 ; Test building missing patches array
 I '$G(A1AEFAIL) D
 . N PKGPRFX,PKGVER,PTCHSQN,MSSEQ,POO
 . S PKGPRFX="DG",PKGVER=5.3,PTCHSQN=100
 . D MISSING^A1AEK1(PKGPRFX,PKGVER,PTCHSQN,.MSSEQ)
 . M POO=MSSEQ K MSSEQ
 . N STRM,SEQN,STRMABB,PTCHNM S STRMABB=""
 . F  S STRMABB=$O(^A1AE(11007.1,"C",STRMABB)) Q:STRMABB=""  D
 .. S STRM=+$O(^A1AE(11007.1,"C",STRMABB,0)) Q:'STRM
 .. F SEQN=1:1:PTCHSQN D
 ... I $D(^DIC(9.4,"A1AESEQ",PKGPRFX,PKGVER,STRM,SEQN)) Q
 ... S MSSEQ(STRM,SEQN)=""
 .; Now compare MSSEQ and POO
 . N NODE,X S NODE=$NA(MSSEQ),X=1
 . F  S NODE=$Q(@NODE) Q:NODE'["MSSEQ"  D  Q:'X
 .. I '$D(POO($QS(NODE,1),$QS(NODE,2))) S X=0 Q
 .. K POO($QS(NODE,1),$QS(NODE,2))
 . I $D(POO) S X=0
 . D CHKEQ^%ut(1,X,"Testing Creating Missing SEQ # array FAILED!")
 Q
 ;
 ;SHOWMSQN^A1AEK1
UTP66 ; Test showing missing patches
 I '$G(A1AEFAIL) D
 . N MSA S MSA(0)=0
 . N STRM S STRM=99
 . N MSSEQ S MSSEQ(0)=1,MSSEQ(99,33)=""
 . S MSA=$$SHOWMSQN^A1AEK1(.MSSEQ,"DG",STRM,0,.MSA)
 . S X=($D(MSA)>1)
 . D CHKEQ^%ut(1,X,"Testing Listing Missing SEQ # FAILED!")
 Q
 ;
 ;ANSWQ^A1AEK1
UTP67 ; Test No/Yes query
 I '$G(A1AEFAIL) D
 . N X,MYDT S MYDT=DTIME S DTIME=1
 . S X=$$ANSWQ^A1AEK1
 . S DTIME=MYDT
 . D CHKEQ^%ut(0,X,"Testing No/Yes query FAILED!")
 Q
 ;
 ;SSEKS^A1AEK1
UTP68 ; Test variable for Site = KIDS Stream
 I '$G(A1AEFAIL) D  Q
 . N KV,SV S KV("PTCHSTRM")=1,SV("STRM")=1
 . S X=$$SSEKS^A1AEK1(.SV,.KV)
 . S:X KV("PTCHSTRM")=1,SV("STRM")=10001
 . S:X X='$$SSEKS^A1AEK1(.SV,.KV)
 . D CHKEQ^%ut(1,X,"Test variable for Site = KIDS Stream FAILED!")
 . Q
 ;
 ;SITEVAR^A1AEK1
UTP69 ; Test building relavent Site Variables
 I '$G(A1AEFAIL) D  Q
 . N SV D SITEVAR^A1AEK1(.SV)
 . N STRM S STRM=$O(^A1AE(11007.1,"ASUBS",1,0))
 . I STRM S X=(SV("STRM")=STRM)
 . I X S X=(SV("STRMNM")=$P($G(^A1AE(11007.1,STRM,0)),"^"))
 . I X S X=(SV("STRMDT")=$O(^A1AE(11007.1,STRM,1,"B","A"),-1))
 . I X S X=(SV("STRMPRFX")=$$GET1^DIQ(11007.1,STRM,.05))
 . D CHKEQ^%ut(1,X,"Test building relavent Site Variables FAILED!")
 . Q
 ;
 ;KIDVAR^A1AEK1
UTP70 ; Test building relavent KIDS Variables
 I '$G(A1AEFAIL) D  Q
 . N X
 . N SV D SITEVAR^A1AEK1(.SV)
 . S SV("ACTPKGV")=$$ACTVERS^A1AEK1("DG")
 . N NODE S NODE=$NA(^DIC(9.4,"A1AESEQ","DG",SV("ACTPKGV")))
 . S NODE=$Q(@NODE)
 . N XPDT S XPDT(1)="1234^"_$QS(NODE,7)
 . S ^XTMP("XPDI",1234,"A1AEUK1",4321,0)=$QS(NODE,7)_"^DG^0^3080108^y"
 . N KV D KIDVAR^A1AEK1(.KV,.XPDT,1)
 . K ^XTMP("XPDI",1234,"A1AEUK1",4321,0)
 . N PTCHNM S PTCHNM=$P(XPDT(1),"^",2)
 . S X=(PTCHNM=KV("PTCHNM"))
 . S:X X=(KV("PKGPRFX")=$P(PTCHNM,"*"))
 . S:X X=(KV("PTCHVER")=$P(PTCHNM,"*",2))
 . S:X X=(KV("PTCHNBR")=$P(PTCHNM,"*",3))
 . N I,KVPTCS S I=0
 . F  S I=$O(^A1AE(11007.1,I)) Q:'I  Q:(I>KV("PTCHNBR"))  D
 .. S KVPTCS=I
 . S:X X=(KV("PTCHSTRM")=KVPTCS)
 . S:X X=(KV("PTCHRDT")=3080108)
 . D CHKEQ^%ut(1,X,"Test building relavent KIDS Variables FAILED!")
 . Q
 ;
 ;
 ;ACTVERS^A1AEK1
UTP71 ; Test returning Site's Active Version of a package
 I '$G(A1AEFAIL) D  Q
 . N PKGPRFX S PKGPRFX="DG"
 . N I S I=$O(^DIC(9.4,"C",PKGPRFX,0))
 . N X S X=($G(I)>0)
 . N DGVER
 . S:X DGVER=$$GET1^DIQ(9.4,I_",",13)
 . S:X X=($G(DGVER)>0)
 . S:X X=(DGVER=$$ACTVERS^A1AEK1("DG"))
 . D CHKEQ^%ut(1,X,"Test finding Site's Active PKG version  FAILED!")
 . Q
 ;
 ;ERRMSG^A1AEK1
UTP72 ; Test building appropriate error message
 I '$G(A1AEFAIL) D  Q
 . N MSG,STRNG,X
 . S MSG(1)="Couln't ascertain active package version on system^93"
 . S MSG(2)="Does not represent current package version^93"
 . S MSG(3)="Earler SEQUENCE #'d patches for package not installed^93"
 . S MSG(4)="KIDS install not for your package STREAM^93"
 .; Test finding active package version
 . S MSG=$P($T(PKGVERR^A1AEK1),";;",2)
 . S STRNG=$$ERRMSG^A1AEK1(MSG,93)
 . S X=(STRNG=MSG(1))
 .; Test site not have KIDS package version 
 . S:X MSG=$P($T(VRSNERR^A1AEK1),";;",2)
 . S:X STRNG=$$ERRMSG^A1AEK1(MSG,93)
 . S:X X=(STRNG=MSG(2))
 .; Test earlier SEQ# patch installation
 . S:X MSG=$P($T(MSNGSQN^A1AEK1),";;",2)
 . S:X STRNG=$$ERRMSG^A1AEK1(MSG,93)
 . S:X X=(STRNG=MSG(3))
 .; Test not for your  package stream
 . S:X MSG=$P($T(WRNGSTRM^A1AEK1),";;",2)
 . S:X STRNG=$$ERRMSG^A1AEK1(MSG,93)
 . S:X X=(STRNG=MSG(4))
 .;
 .D CHKEQ^%ut(1,X,"Test building appropriate error message FAILED!")
 . Q
 ;
 ;WARN^A1AEK1
UTP73 ; Test building Warning message
 I '$G(A1AEFAIL) D  Q
 . N STRNG S STRNG=$$WARN^A1AEK1(1)
 . S X=(STRNG="*END*")
 . D CHKEQ^%ut(1,X,"Test building warning message FAILED!")
 . Q
 ;
 ;
XTENT ;
 ;;UTP60;Test entering routine at top
 ;;UTP61;Test suitability of patch for install
 ;;UTP62;Test procedures when Patch and Site Stream match
 ;;UTP63;Test procedures when Patch and Site Stream DO NOT match
 ;;UTP64;Test building array of installed patches
 ;;UTP65;Test building missing patches array
 ;;UTP66;Test showing missing patches
 ;;UTP67;Test No/Yes query
 ;;UTP68;Test Test variable for Site = KIDS Stream
 ;;UTP69;Test building relavent Site Variables
 ;;UTP71;Test returning Site's Active Version of a package
 ;;UTP72;Test building appropriate error message
 ;;UTP72;Test building appropriate error message
 ;;UTP73;Test building appropriate error message
 Q
 ;;UTP60;Test entering routine at top
 ;;UTP61;Test suitability of patch for install
 ;;UTP62;Test procedures when Patch and Site Stream match
 ;;UTP63;Test procedures when Patch and Site Stream DO NOT match
 ;;UTP64;Test building array of installed patches
 ;;UTP65;Test building missing patches array
 ;;UTP66;Test showing missing patches
 ;;UTP67;Test No/Yes query
 ;;UTP68;Test variable for Site Stream = KIDS Stream
 ;;UTP69;Test building relavent Site Variables
 ;;UTP70;Test building relavent KIDS Variables
 ;;UTP71;Test returning Site's Active Version of a package
 ;;UTP72;Test building appropriate error message
 ;;UTP73;Test building appropriate error message
 Q
 ;
 ;
EOR ; end of routine A1AEUK1
