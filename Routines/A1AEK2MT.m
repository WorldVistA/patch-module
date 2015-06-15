A1AEK2MT ;ven/smh-kids hfs files to Patch Module testing code;2015-06-14  2:02 AM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
TEST D EN^%ut($T(+0),1,1) QUIT  ; 1/1 means be verbose and break upon errors.
STARTUP ; M-Unit Start-up
 ; ZEXCEPT: OLDPWD,A1AEK2MTIEN
 I $D(DUZ)[0 D ^XUP ; X-New. Protect our variables from XUP's global kill.
 ; Make the user a surrogate to postmaster
 N FDA
 S FDA(3.703,"?+1,.5,",.01)="`"_DUZ
 S FDA(3.703,"?+1,.5,",1)="y" ; Read Priv
 S FDA(3.703,"?+1,.5,",2)="y" ; Send Priv
 D UPDATE^DIE("E",$NA(FDA),$NA(A1AEK2MTIEN))
 ;
 ; --- CAREFUL ---
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
 . . S DA="" F  S DA=$O(^A1AE(11005,"D",PKG,DA)) Q:'DA  F DIK="^A1AE(11005,","^A1AE(11005.1,","^A1AE(11005.5," D ^DIK
 . . N DA,DIK S DIK="^A1AE(11007,"
 . . I $D(^A1AE(11007,"B",PKG)) S DA=PKG D ^DIK
 . S $P(^A1AE(11005,0),U,3,4)=0_U_0 ; Zero out the header node so we start counting at zero
 ;
 I +$SY'=47 QUIT  ; Test Works only on GT.M/Unix
 S OLDPWD=$$PWD^A1AEOS()
 D EN^DDIOL("Cloning the OSEHRA repository. This will take some time.")
 N % S %=$$MKDIR^A1AEOS("osehra-repo")
 I % S $EC=",U-MKDIR-FAILED,"
 N D S D=$$D^A1AEOS()
 N % S %=$$CD^A1AEOS(OLDPWD_D_"osehra-repo")
 I %'["osehra" S $EC=",U-CD-FAILED,"
 N % S %=$$RDPIPE^A1AEOS(,"git clone --depth=0 https://github.com/OSEHRA/VistA")
 QUIT
 ;
SHUTDOWN ; M-Unit Shutdown
 ; Delete surrogate for postmaster
 ; ZEXCEPT: OLDPWD,A1AEK2MTIEN ; Created in STARTUP
 N C S C=","
 N FDA S FDA(3.703,A1AEK2MTIEN(1)_C_.5_C,.01)="@" D FILE^DIE("E",$NA(FDA))
 ;
 N P S P="cmdpipe"
 N % S %=$$CD^A1AEOS(OLDPWD)
 K OLDPWD,A1AEK2MTIEN
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
 D CHKEQ^%ut($$GETSTRM^A1AEK2M0("AAA*2.0*55"),1)
 D CHKEQ^%ut($$GETSTRM^A1AEK2M0("AAA*2.0*0"),1)
 D CHKEQ^%ut($$GETSTRM^A1AEK2M0("AAA*2.0*10035"),10001)
 QUIT
 ;
SELFILT ; ##TEST Test file selector - Can't use M-Unit... this is interactive.
 N ROOT S ROOT="/home/forum/testkids/"
 N ARRAY S ARRAY("*")=""
 N FILE
 N % S %=$$LIST^%ZISH(ROOT,"ARRAY","FILE")
 I '% S $EC=",U-WRONG-DIRECTORY,"
 N % S %=$$SELFIL^A1AEK2M3(.FILE)
 W !,%
 N % S %=$$SELFIL^A1AEK2M3(.FILE,".TXT")
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
 . D CLEANHF^A1AEK2M0($NA(^TMP($J,"TXT")))
 . N RTN
 . D ANALYZE^A1AEK2M2(.RTN,$NA(^TMP($J,"TXT")),"")
 . D ASSERT($L(RTN("SEQ")))
 . D ASSERT($L(RTN("SUBJECT")))
 QUIT
 ;
ANALYZE2 ; @TEST Analyze on ALL patches on OSEHRA FOIA repo
 N FILES N % S %=$$RDPIPE^A1AEOS(.FILES,"find . -name '*.TXT'")
 N I F I=0:0 S I=$O(FILES(I)) Q:'I  D 
 . K ^TMP($J,"TXT")
 . N Y S Y=$$FTG^%ZISH($$PWD^A1AEOS(),FILES(I),$NA(^TMP($J,"TXT",2,0)),3) I 'Y S $ECODE=",U-CANNOT-READ-FILE,"
 . D CLEANHF^A1AEK2M0($NA(^TMP($J,"TXT"))) ; Clean header and footer.
 . N RTN
 . N $ET,$ES ; We do a try catch with ANALYZE^A1AEK2M2
 . S $ET="D ANATRAP^A1AEK2M2(FILES(I))"
 . D ANALYZE^A1AEK2M2(.RTN,$NA(^TMP($J,"TXT")),"")
 . D ASSERT($L(RTN("SEQ")))
 . D ASSERT($L(RTN("SUBJECT")))
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
 I '% D FAIL^%ut("Can't open file") QUIT
 ;
 D ANALYZE^A1AEK2M1($NA(^TMP($J,"ANKID")),$NA(^TMP($J,"KID")))
 D CHKTF^%ut($D(^TMP($J,"ANKID","TIU*1.0*239")),"KIDS file not loaded")
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
 I '% D FAIL^%ut("Can't open file") QUIT
 ;
 D ANALYZE^A1AEK2M1($NA(^TMP($J,"ANKID")),$NA(^TMP($J,"KID")))
 D CHKTF^%ut($D(^TMP($J,"ANKID","OR*3.0*357")))
 D CHKTF^%ut($D(^TMP($J,"ANKID","PXRM*2.0*22")))
 D CHKTF^%ut($D(^TMP($J,"ANKID","TERATOGENIC MEDICATIONS ORDER CHECKS 1.0")))
 QUIT
 ;
LOADALL ; @TEST Load all patches on the OSEHRA repo into the patch module
 N ROOT
 N P S P="cmdpipe"
 N A S A("VistA/Packages/*")=""
 N PACKAGES
 N % S %=$$LIST^%ZISH($$PWD^A1AEOS(),$NA(A),$NA(PACKAGES))
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
 . N % S %=$$LIST^%ZISH($$PWD^A1AEOS(),$NA(A),$NA(PATCHES))
 . I '% S $EC=",U-LISTER-FAILED,"
 . N PATCH S PATCH=""
 . F  S PATCH=$O(PATCHES(PATCH)) Q:PATCH=""  D
 . . I PATCH="README.rst" QUIT
 . . S ROOT("SB")="VistA/Packages/"_PACKAGE_"/Patches/"_PATCH_"/"
 . . D SILENT^A1AEK2M(.ROOT)
 QUIT
 ;
LOADDUP ; @TEST - Try to duplicate the loaded patches
 N ROOT
 S ROOT("SB")="/home/forum/testkids/"
 S ROOT("MB")="/home/sam/VistA/Packages/MultiBuilds/"
 D SILENT^A1AEK2M(.ROOT)
 N %1,%2
 S %1=$O(^A1AE(11005,"ADERIVED","TIU*1*272",""))
 D ASSERT(%1,"Entry must exist")
 S %2=$O(^A1AE(11005,"ADERIVED","TIU*1*272",%1))
 D ASSERT(%2="","There should not be a duplicated entry")
 QUIT
 ;
 ; Convenience methods for M-Unit.
ASSERT(A,B) D CHKTF^%ut(A,$G(B)) QUIT
CHKEQ(A,B,C) D CHKEQ^%ut(A,B,$G(C)) QUIT
