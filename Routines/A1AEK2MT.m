A1AEK2MT ; VEN/SMH - KIDS HFS files to Patch Module testing code;2014-02-27  5:26 PM
 ;;2.4;DHCP PATCH MODULE;
 ;
TEST D EN^XTMUNIT($T(+0),1,1) QUIT  ; 1/1 means be verbose and break upon errors.
STARTUP ; M-Unit Start-up
 I $D(DUZ)[0 D ^XUP
 ; Make the user a surrogate to postmaster
 N FDA 
 S FDA(3.703,"?+1,.5,",.01)="`"_DUZ
 S FDA(3.703,"?+1,.5,",1)="y" ; Read Priv
 S FDA(3.703,"?+1,.5,",2)="y" ; Send Priv
 D UPDATE^DIE("E",$NA(FDA),$NA(A1AEK2MTIEN))
 ; Delete all the old data, ONLY IF WE ARE ON TEST
 I '$$PROD^XUPROD() D
 . D EN^DDIOL("Deleting all imported users.")
 . N USR S USR=48
 . N DA,DIK S DIK="^VA(200,"
 . F  S USR=$O(^VA(200,USR)) Q:'USR  D
 . . I $L($P(^VA(200,USR,0),U,3)) QUIT  ; Has access code... don't delete.
 . . S DA=USR D ^DIK
 . ;
 . ; Now loop through the package file, and delete the A1AE Packages from our file
 . D EN^DDIOL("Deleting imported package set-ups and imported patches")
 . N PKG S PKG=0 F  S PKG=$O(^DIC(9.4,PKG)) Q:'PKG  D
 . . N DA,DIK S DIK="^A1AE(11005,"
 . . S DA="" F  S DA=$O(^A1AE(11005,"D",PKG,DA)) Q:'DA  D ^DIK
 . . N DA,DIK S DIK="^A1AE(11007,"
 . . I $D(^A1AE(11007,"B",PKG)) S DA=PKG D ^DIK
 ;
 I +$SY'=47 QUIT  ; Test Works only on GT.M/Unix
 S OLDPWD=$ZDIRECTORY
 D EN^DDIOL("Cloning the OSEHRA repository. This will take some time.")
 N P S P="cmdpipe"
 O P:(shell="/bin/sh":command="mkdir osehra-repo")::"pipe"
 U P C P
 S $ZDIRECTORY=OLDPWD_"/"_"osehra-repo"
 O P:(shell="/bin/sh":command="git clone --depth=0 https://github.com/OSEHRA/VistA":READONLY:PARSE)::"pipe"
 U P
 N X F  R X:1 Q:$ZEOF  ; just loop around until we are done.
 C P
 QUIT
 ;
SHUTDOWN ; M-Unit Shutdown
 ; Delete surrogate for postmaster
 N C S C=","
 N FDA S FDA(3.703,A1AEK2MTIEN(1)_C_.5_C,.01)="@" D FILE^DIE("E",$NA(FDA))
 ;
 I +$SY'=47 QUIT  ; Test Works only on GT.M/Unix
 N P S P="cmdpipe"
 S $ZDIRECTORY=OLDPWD
 K OLDPWD
 ; Don't delete. Takes forever to clone again.
 ; O P:(shell="/bin/sh":command="rm -rf osehra-repo")::"pipe"
 ; U P C P
 QUIT
 ;
CLEANQP ; @TEST Clean Q-Patch Queue (Temporary until we make the code file into 11005/11005.1 directly)
 N XMDUZ,XMK,XMZ
 S XMDUZ=.5
 N % S %=$O(^XMB(3.7,.5,2,"B","Q-PATCH"))
 S XMK=$O(^XMB(3.7,.5,2,"B",%,0))
 S XMZ=0 F  S XMZ=$O(^XMB(3.7,.5,2,XMK,1,XMZ)) Q:'XMZ  D KL^XMA1B
 D ASSERT($O(^XMB(3.7,.5,2,XMK,1,0))="")
 ;
 ; Remove unreferenced messages from Mailman
 N XMPARM
 S (XMPARM("TYPE"),XMPARM("START"))=0
 S (XMPARM("END"),XMPARM("PDATE"))=$$FMADD^XLFDT($$DT^XLFDT(),1)
 D PURGEIT^XMA3(.XMPARM)
 QUIT
 ;
GETSTRM ; @TEST Test GETSTRM^A1AEK2M
 D CHKEQ^XTMUNIT($$GETSTRM^A1AEK2M("AAA*2.0*55"),1)
 D CHKEQ^XTMUNIT($$GETSTRM^A1AEK2M("AAA*2.0*0"),1)
 D CHKEQ^XTMUNIT($$GETSTRM^A1AEK2M("AAA*2.0*10035"),10001)
 QUIT
 ;
MAILQP ; @TEST Read Patches and Send emails to Q-PATCH (temp ditto)
 ; ZEXCEPT: ROOT,SAVEDUZ - killed in EXIT.
 ; N DUZ S DUZ=.5
 S ROOT("SB")="/home/forum/testkids/"
 S ROOT("MB")="/home/osehra/VistA/Packages/MultiBuilds/"
 D SILENT^A1AEK2M
 ;
 ; Get Q-PATCH basket
 N % S %=$O(^XMB(3.7,.5,2,"B","Q-PATCH"))
 N XMK S XMK=$O(^XMB(3.7,.5,2,"B",%,0))
 ;
 ; Assert that it has messages
 D ASSERT($O(^XMB(3.7,.5,2,XMK,1,0))>0)
 N I S I=0 F  S I=$O(^XMB(3.7,.5,2,XMK,1,I)) Q:'I  D
 . N SUB S SUB=$P(^XMB(3.9,I,0),"^")
 . N PN S PN=$P(SUB,"*")
 . D ASSERT($L(PN)>1,"Subject incorrect")
 . D ASSERT($E(^XMB(3.9,I,2,1,0),1,4)="$TXT","Message "_I_" doesn't have TXT nodes")
 QUIT
 ;
SELFILT ; ##TEST Test file selector - Can't use M-Unit... this is interactive.
 N ROOT S ROOT="/home/forum/testkids/"
 N ARRAY S ARRAY("*")=""
 N FILE
 N % S %=$$LIST^%ZISH(ROOT,"ARRAY","FILE")
 I '% S $EC=",U-WRONG-DIRECTORY,"
 N % S %=$$SELFIL^A1AEK2M(.FILE)
 W !,%
 N % S %=$$SELFIL^A1AEK2M(.FILE,".TXT")
 W !,%
 QUIT
 ;
ANALYZE1 ; @TEST Test Analyze on just the TIU patches
 N ROOT S ROOT="/home/forum/testkids/"
 N A S A("*.TXT")=""
 N FILE
 N % S %=$$LIST^%ZISH(ROOT,$NA(A),$NA(FILE))
 N J S J=""
 F  S J=$O(FILE(J)) Q:J=""  D
 . K ^TMP($J,"TXT")
 . N Y S Y=$$FTG^%ZISH(ROOT,J,$NA(^TMP($J,"TXT",2,0)),3) I 'Y S $ECODE=",U-CANNOT-READ-FILE,"
 . D CLEANHF^A1AEK2M($NA(^TMP($J,"TXT")))
 . N RTN
 . D ANALYZE^A1AEK2M2(.RTN,$NA(^TMP($J,"TXT")),"")
 . D ASSERT($L(RTN("SEQ")))
 . D ASSERT($L(RTN("SUBJECT")))
 QUIT
 ;
ANALYZE2 ; @TEST Analyze on ALL patches on OSEHRA FOIA repo
 ; REALLY REALLY NOT SAC COMPLIANT.
 I +$SY'=47 QUIT  ; Test Works only on GT.M/Unix
 N P S P="cmdpipe"
 O P:(shell="/bin/sh":command="find . -name '*.TXT'")::"pipe"
 U P
 N X F  U P R X:1 Q:$ZEOF  U $P D
 . K ^TMP($J,"TXT")
 . N Y S Y=$$FTG^%ZISH($ZD,X,$NA(^TMP($J,"TXT",2,0)),3) I 'Y S $ECODE=",U-CANNOT-READ-FILE,"
 . D CLEANHF^A1AEK2M($NA(^TMP($J,"TXT"))) ; Clean header and footer.
 . N RTN
 . N $ET,$ES ; We do a try catch with ANALYZE^A1AEK2M2
 . S $ET="D ANATRAP^A1AEK2M(X)"
 . D ANALYZE^A1AEK2M2(.RTN,$NA(^TMP($J,"TXT")),"")
 . D ASSERT($L(RTN("SEQ")))
 . D ASSERT($L(RTN("SUBJECT")))
 C P
 QUIT  ; /END ANALYZE2
 ;
SB ; @TEST Analyze Single build KIDS file
 N F S F="/home/osehra/VistA/Packages/Text Integration Utility/Patches/TIU_1.0_239/TIU-1_SEQ-239_PAT-239.KID"
 N PATH S PATH=$P(F,"/",1,$L(F,"/")-1)
 N FILE S FILE=$P(F,"/",$L(F,"/"))
 ;
 K ^TMP($J,"KID"),^("ANKID")
 ;
 N % S %=$$FTG^%ZISH(PATH,FILE,$NA(^TMP($J,"KID",1,0)),3)
 I '% D FAIL^XTMUNIT("Can't open file") QUIT
 ;
 D ANALYZE^A1AEK2M1($NA(^TMP($J,"ANKID")),$NA(^TMP($J,"KID")))
 D CHKTF^XTMUNIT($D(^TMP($J,"ANKID","TIU*1.0*239")),"KIDS file not loaded")
 QUIT
 ;
MB ; @TEST Analyze Multibuild KIDS file
 N F S F="/home/osehra/VistA/Packages/MultiBuilds/TERATOGENIC_MEDICATIONS_ORDER_CHECKS.KID"
 N PATH S PATH=$P(F,"/",1,$L(F,"/")-1)
 N FILE S FILE=$P(F,"/",$L(F,"/"))
 ;
 K ^TMP($J,"KID"),^("ANKID")
 ;
 N % S %=$$FTG^%ZISH(PATH,FILE,$NA(^TMP($J,"KID",1,0)),3)
 I '% D FAIL^XTMUNIT("Can't open file") QUIT
 ;
 D ANALYZE^A1AEK2M1($NA(^TMP($J,"ANKID")),$NA(^TMP($J,"KID")))
 D CHKTF^XTMUNIT($D(^TMP($J,"ANKID","OR*3.0*357")))
 D CHKTF^XTMUNIT($D(^TMP($J,"ANKID","PXRM*2.0*22")))
 D CHKTF^XTMUNIT($D(^TMP($J,"ANKID","TERATOGENIC MEDICATIONS ORDER CHECKS 1.0")))
 QUIT
 ;
LOADALL ; @TEST Load all patches on the OSEHRA repo into the patch module
 N ROOT
 N P S P="cmdpipe"
 N A S A("VistA/Packages/*")=""
 N PACKAGES
 N % S %=$$LIST^%ZISH($ZD,$NA(A),$NA(PACKAGES))
 I '% S $EC=",U-LISTER-FAILED,"
 ;
 ; Get MB directory
 N PACKAGE S PACKAGE=""
 F  S PACKAGE=$O(PACKAGES(PACKAGE)) Q:PACKAGE=""  D
 . I $E(PACKAGE)="." QUIT  ; .gitignore
 . I PACKAGE="MultiBuilds" S ROOT("MB")=$P($O(A("")),"*")_PACKAGE QUIT
 . I PACKAGE="Uncategorized" QUIT
 ;
 ; Load each patch
 F  S PACKAGE=$O(PACKAGES(PACKAGE)) Q:PACKAGE=""  D
 . I $E(PACKAGE)="." QUIT  ; .gitignore
 . I PACKAGE="MultiBuilds" QUIT
 . I PACKAGE="Uncategorized" QUIT
 . N A S A("VistA/Packages/"_PACKAGE_"/Patches/*")=""
 . N PATCHES
 . N % S %=$$LIST^%ZISH($ZD,$NA(A),$NA(PATCHES))
 . I '% S $EC=",U-LISTER-FAILED,"
 . N PATCH S PATCH=""
 . F  S PATCH=$O(PATCHES(PATCH)) Q:PATCH=""  D
 . . I PATCH="README.rst" QUIT
 . . S ROOT("SB")="VistA/Packages/"_PACKAGE_"/Patches/"_PATCH_"/"
 . . D SILENT^A1AEK2M
 QUIT
 ; Convenience methods for M-Unit.
ASSERT(A,B) D CHKTF^XTMUNIT(A,$G(B)) QUIT
CHKEQ(A,B,C) D CHKEQ^XTMUNIT(A,B,$G(C)) QUIT
