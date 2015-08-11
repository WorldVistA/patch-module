XPDIPM ;SFISC/RSD - Load a Packman Message ;2015-06-13  9:20 PM
 ;;8.0;KERNEL;**21,28,68,108,PM2.5**;Jul 05, 1995
 ;
 ; CHANGE: (VEN/LGC) 4/9/2015
 ;   Routine modified to filter install through A1AEK1
 ;    before allowing installation.  The filter checks
 ;    that the site attempting to install the KIDS has
 ;    the correct PATCH STREAM and has previously installed
 ;    all earlier SEQ# patches for this package, if 
 ;    they have switch PATCH STREAMS in the past.
 ;
 ; CHANGE: (VEN/LGC) 6/2/2105
 ;   Modified code at GI +5 to set XPDQUIT and QUIT rather than
 ;    handle the abort myself
 ;    
 ;
 Q:'$D(^XMB(3.9,+$G(XMZ),0))
 ;
 N X,XPD,Y S XPD=0
 F  S XPD=$O(^XMB(3.9,XMZ,2,XPD)) Q:+XPD'=XPD  S X=^(XPD,0) I $E(X,1,11)="$TXT $KIDS " Q
 S Y=$P(X,"$KIDS ",2)
EN I 'XPD!'$L(Y) W !!,"Couldn't find a KIDS package!!",*7 Q
 N DIR,DIRUT,GR,XPDA,XPDST,XPDIT,XPDT,XPDNM,XPDQUIT,XPDREQAB
 S XPDST("H1")=$P(^XMB(3.9,XMZ,0),U),XPDST=0,XPDIT=1
 S XPDA=$$INST^XPDIL1(Y) G:'XPDA NONE^XPDIL
 W !
 S DIR(0)="Y",DIR("A")="Want to Continue with Load",DIR("B")="YES"
 D ^DIR I 'Y!$D(DIRUT) D ABRTALL^XPDI(1) G NONE^XPDIL
 W !,"Loading Distribution...",!
 S ^XTMP("XPDI",0)=$$FMADD^XLFDT(DT,7)_U_DT
 D GI I $G(XPDQUIT) D ABRTALL^XPDI(1) G NONE^XPDIL
 D PKG^XPDIL1(XPDA)
 Q
GI D NXT Q:$G(XPDQUIT)
 I X'="**INSTALL NAME**"!'$D(XPDT("NM",Y)) S XPDQUIT=1 Q
 S GR="^XTMP(""XPDI"","_XPDA_","
 F  D NXT Q:X=""!$D(XPDQUIT)  D
 .S @(GR_X)=Y
 ;
 ;CHANGE: (VEN/LGC) 4/9/2015
 ;CHANGE: (VEN/LGC) 6/2/2015
 N A1AEHDR S A1AEHDR=$G(^XMB(3.9,+$G(XMZ),0))
 ;new code
 I $L($T(^A1AEK1)),$$EN^A1AEK1(A1AEHDR) S XPDQUIT=1 Q
 ;old code
 ;I $L($T(^A1AEK1)),$$EN^A1AEK1(A1AEHDR) D ABRTALL^XPDI(1) G NONE^XPDIL
 Q
NXT S (X,Y)="",XPD=$O(^XMB(3.9,XMZ,2,XPD)) G:+XPD'=XPD ERR S X=^(XPD,0)
 I $E(X,1,5)="$END " S X="" Q
 S XPD=$O(^XMB(3.9,XMZ,2,XPD)) G:+XPD'=XPD ERR
 S Y=^XMB(3.9,XMZ,2,XPD,0)
 Q
XMP2 ;called from XMP2
 N X,XPD,Y
 S XPD=XCN,X=$G(^XMB(3.9,XMZ,2,XPD,0)),Y=$P(X,"$KID ",2)
 D EN
 S XMOUT=1
 Q
ERR W !!,"Error in Packman Message, ABORTING load!!"
 S (X,Y)="",XPDQUIT=1
 Q
