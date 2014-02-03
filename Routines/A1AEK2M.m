A1AEK2M ; VEN/SMH - Load an HFS KIDS file into the Patch Module;2014-02-03  5:11 PM
 ;;2.4;PATCH MODULE;
 ;
 ; Based on code written by Dr. Cameron Schlehuber.
 ;
 ; Notes on the KIDS format and conversion procedure.
 ;
 ; Conversion procedure from a VA PM HFS-extracted KIDS (complete):
 ;^TMP(28177,1,0)="Released TIU*1*241 SEQ #237" <-- $TXT prepended
 ;^TMP(28177,2,0)="Extracted from mail message" <-- this becomes the txt
 ;^TMP(28177,3,0)="**KIDS**:TIU*1.0*241^"       <-- $END TXT replaced
 ;^TMP(28177,4,0)="" --> becomes $KID append whatever is in 6
 ;^TMP(28177,5,0)="**INSTALL NAME**"
 ;^TMP(28177,6,0)="TIU*1.0*241"
 ;---
 ;^TMP(28177,1189,0)="**END**" --> becomes $END KID whatever is in 6
 ;^TMP(28177,1190,0)="**END**" --> DELETED
 ;
 ; A few random notes on various KIDS issues
 ; If the original is a mail message, it will looks like this
 ; 
 ; >> Released GMRA*4*44 SEQ #41
 ; >> Extracted from mail message
 ; >> **KIDS**:GMRA*4.0*44^
 ; >> 
 ; >> **INSTALL NAME** etc..
 ; >> kids contents
 ; >> **END**
 ; >> **END**
 ;
 ; If the original isn't a PM HFS-extracted KIDS build, but a Straight from 
 ; KIDS KIDS-build, then the KIDS first line looks like this:
 ;
 ; >> KIDS Distribution saved on Apr 30, 2013@05:31:47
 ; >> OR*371
 ; >> **KIDS**:OR*3.0*371^
 ; >> <blank line>
 ; >> **INSTALL NAME**
 ;
 ; Multibuilds look like this:
 ; 
 ; >> KIDS Distribution saved on Sep 23, 2011@17:42:57
 ; >> IB/PRCA Remedy Ticket Fixes
 ; >> **KIDS**:IB*2.0*459^PRCA*4.5*280^
 ; >> <blank line>
 ; >> **INSTALL NAME**
 ; >> text of first KIDS build
 ; >> **INSTALL NAME**
 ; >> text of second KIDS build
 ; >> **END**
 ; >> **END**
 ;
 ; A KIDS sent from another system via KIDS/MM has the following contents.
 ;$TXT Created by TESTMASTER,USER at VEN.SMH101.COM  (KIDS) on Thursday, 01/07/14 at 15:55
 ; <contents>
 ;$END TXT
 ;$KID ZZZ*1.0*1
 ;**INSTALL NAME**
 ; <contents>
 ;$END KID ZZZ*1.0*1
 ;
 ; TODO: Develop a good way to get the sequence number - get from analyzing the patch.
 ; TODO: File package entry into our system if it can't be found
 ;       - Hint: Finds KIDS EP that does the PKG subs
 ; TODO: Remove text for KIDS build if it exists.
 ; TODO: Make sure we get the subjects right even if it is an original HFS file.
 ;
DBAKID2M ; Restore patches from HFS files to MailMan ;9/28/02  12:53
 ; Get path to HFS patches
 ; Order through all messages
 N DUZ S DUZ=.5,DUZ(0)="" ; Save DUZ from previous caller.
 N DIR,X,Y,DIROUT,DIRUT,DTOUT,DUOUT,DIROUT ; fur DIR
 S DIR(0)="F^2:60",DIR("A")="Full path, up to but not including patch names" D ^DIR
 QUIT:Y="^"
 N ROOT S ROOT=Y  ; where we load files from...
 ;
SILENT ; Don't talk. Pass ROOT in Symbol Table
 ; Boo -- now it talks.
 N FILE ; retrun array -- needs to be renamed to plural.
 ;
 ; Load text files first
 N ARRAY
 S ARRAY("*.TXT")=""
 S ARRAY("*.txt")=""
 N Y S Y=$$LIST^%ZISH(ROOT,"ARRAY","FILE") I 'Y W !,"Error getting directory list" QUIT
 ;
 ; Loop through each text patches.
 N ERROR
 N PATCH S PATCH=""
 F  S PATCH=$O(FILE(PATCH)) Q:PATCH=""  D LOAD(ROOT,PATCH,.ERROR) Q:$D(ERROR)
 QUIT
 ;
LOAD(ROOT,PATCH,ERROR) ; Load TXT message, find KIDS, then load KIDS and mail.
 ;
 ; NB: I start from 2 just in case there is something I need to put in 1 (like $TXT)
 K ^TMP($J,"TXT")
 N Y S Y=$$FTG^%ZISH(ROOT,PATCH,$NA(^TMP($J,"TXT",2,0)),3) I 'Y W !,"Error copying TXT to global" S ERROR=1 Q
 ;
 ; TODO: If the original text patch doesn't come with $TXT and $END TXT, need to add them just after this.
 K ^TMP($J,"MSG") ; Message array eventually to be mailed.
 M ^TMP($J,"MSG")=^TMP($J,"TXT") ; Load the text document associated with the patch.
 ;
 N LASTSUB S LASTSUB=$O(^TMP($J,"TXT"," "),-1)
 ;
 ; Load KIDS message starting into the last subscript + 1 from the text node
 ; TODO: Only ask if the TXT indicates that there is a KIDS file. Patch could be informational.
 N KIDFIL S KIDFIL=$$KIDFIL(ROOT,PATCH)
 I KIDFIL="" D
 . N ARRAY S ARRAY("*.KI*")="",ARRAY("*.ki*")=""
 . N FILE
 . N Y S Y=$$LIST^%ZISH(ROOT,$NA(ARRAY),$NA(FILE))
 . I 'Y  ; TODO!!! -- probably ask the user to try again since directory has no KIDS files.
 . S KIDFIL=$$SELFIL(.FILE,,"Select a KIDS build to match to "_PATCH)
 ;
 K ^TMP($J,"KID")
 I $L(KIDFIL) D  Q:$D(ERROR)
 . N Y S Y=$$FTG^%ZISH(ROOT,KIDFIL,$NA(^TMP($J,"KID",LASTSUB+1,0)),3) I 'Y W !,"Error copying KIDS to global" S ERROR=1 Q
 . M ^TMP($J,"MSG")=^TMP($J,"KID") ; Load the KIDS build
 . ;
 . K ^TMP($J,"MSG",LASTSUB+1),^(LASTSUB+2),^(LASTSUB+3) ; Remove description lines from KIDS build.
 . S ^TMP($J,"MSG",LASTSUB+4,0)="$KID "_^TMP($J,"MSG",LASTSUB+6,0) ; KIDS name after **INSTALL NAME**
 . N Y S Y=$O(^TMP($J,"MSG",""),-1) K ^TMP($J,"MSG",Y) ; remove 2nd **END**
 . S ^TMP($J,"MSG",Y-1,0)="$END KID "_^TMP($J,"MSG",LASTSUB+6,0) ; replace 1st **END** with $END KID KIDS Name
 ; 
 ; Mail Subject - TODO: obtain from the patch message
 N XMSUBJ S XMSUBJ=""
 I $D(^TMP($J,"KID")) D
 . S XMSUBJ=$P(^TMP($J,"KID",LASTSUB+1,0),"Released ",2,99)
 . I '$L(XMSUBJ) S XMSUBJ=^TMP($J,"KID",LASTSUB+6,0) ; NB: Doesn't handle multibuilds
 I '$L(XMSUBJ) S XMSUBJ="Sam read this"
 ;
 ; Deliver the message
 N XMERR,XMZ
 D SENDMSG^XMXAPI(.5,XMSUBJ,$NA(^TMP($J,"MSG")),"XXX@Q-PATCH.OSEHRA.ORG",,.XMZ) ; after
 I $D(XMERR) W !,"MailMan error, see ^TMP(""XMERR"",$J)" S ERROR=1 Q
 ; Set MESSAGE TYPE to KIDS build
 S $P(^XMB(3.9,XMZ,0),"^",7)="K"
 ;
 ; Kill temp globals
 K ^TMP($J,"KID"),^("TXT"),^("MSG")
 ;
 QUIT
 ;
TXTFIL(ROOT,PATCH) ; Private; Find the text file that corresponds to a patch designation
 N NOEXT S NOEXT=$P(PATCH,".",1,$L(PATCH,".")-1) ; no extension name
 N TXTFIL0 ; Trial iteration variable
 N DONE
 N % F %="TXT","txt" D  Q:$G(DONE)
 . S TXTFIL0=NOEXT_"."_%
 . N POP
 . D OPEN^%ZISH("TXT0",ROOT,TXTFIL0,"R")
 . I POP S TXTFIL0="" QUIT
 . S DONE=1
 . D CLOSE^%ZISH("TXT0")
 QUIT $G(TXTFIL0)
 ;
KIDFIL(ROOT,PATCH) ; Private; Find the KIDS file that corresponds to a patch designation
 ; Idea: Maybe read a few lines to id the file.
 N NOEXT S NOEXT=$P(PATCH,".",1,$L(PATCH,".")-1) ; no extension name
 N KIDFIL0 ; Trial iteration variable
 N DONE
 N % F %="KID","kid","KIDS","kids","KIDs","kidS" D  Q:$G(DONE)
 . S KIDFIL0=NOEXT_"."_%
 . N POP
 . D OPEN^%ZISH("KID0",ROOT,KIDFIL0,"R")
 . I POP S KIDFIL0="" QUIT
 . S DONE=1
 . D CLOSE^%ZISH("KID0")
 QUIT $G(KIDFIL0)
 ;
SELFIL(FILES,EXTFILTER,DIRA) ; Public; INTERACTIVE ; Select a file from a list
 ; FILES = Ref List of files from LIST^%ZISH
 ; EXTFILTER = Val .TXT or so
 ; DIRA = Val What to ask the user for
 ; Uses fileman calls to ease the pain of selecting stuff.
 ;
 N I S I=""
 ; Filter away using the extension
 I $L($G(EXTFILTER)) F  S I=$O(FILES(I)) Q:I=""  D
 . I $E($RE(I),1,$L(EXTFILTER))'=$RE(EXTFILTER) K FILES(I)
 ;
 ; If no files left, quit with an empty string
 Q:'$L($O(FILES(""))) ""
 ;
 ; Create a global for DIR/DIC
 K ^TMP($J,"FILES")
 S ^TMP($J,"FILES",0)="File List"
 N CNT S CNT=1
 F  S I=$O(FILES(I)) Q:I=""  S ^TMP($J,"FILES",CNT,0)=I,CNT=CNT+1
 ;
 ; Index
 N DIK,DA S DIK="^TMP($J,""FILES""," D IXALL^DIK
 ; Select
 N DIR,X,Y,DIROUT,DIRUT,DTOUT,DUOUT,DIROUT
 S DIR(0)="P^TMP($J,""FILES"",",DIR("A")=$G(DIRA,"Select a file from the list") D ^DIR
 ; Bye
 K ^TMP($J,"FILES")
 ;
 I $L(Y,U)=2 Q $P(Y,U,2)
 E  QUIT ""
 ;
ANAMESS(RTN,MESSAGE) ; Analyze patch message 
 ;
TEST D EN^XTMUNIT($T(+0),1,1) QUIT  ; 1/1 means be verbose and break upon errors.
CLEANQP ; @TEST Clean Q-Patch Queue (Temporary until we make the code file into 11005/11005.1 directly)
 N XMDUZ,XMK,XMZ
 S XMDUZ=.5
 N % S %=$O(^XMB(3.7,.5,2,"B","Q-PATCH"))
 S XMK=$O(^XMB(3.7,.5,2,"B",%,0))
 S XMZ=0 F  S XMZ=$O(^XMB(3.7,.5,2,XMK,1,XMZ)) Q:'XMZ  D KL^XMA1B
 D ASSERT($O(^XMB(3.7,.5,2,XMK,1,0))="")
 QUIT
 ;
MAILQP ; @TEST Read Patches and Send emails to Q-PATCH (temp ditto)
 ; ZEXCEPT: ROOT,SAVEDUZ - killed in EXIT.
 S (SAVEDUZ,DUZ)=.5
 S ROOT="/home/forum/testkids/"
 D SILENT
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
TXTFILT ; @TEST Test that the logic for text file location works
 N ROOT S ROOT="/home/forum/testkids/"
 N PATCH S PATCH="TIU-1_SEQ-252_PAT-256.KIDS"
 N % S %=$$TXTFIL(ROOT,PATCH)
 D CHKEQ(%,"TIU-1_SEQ-252_PAT-256.TXT")
 QUIT
 ;
SELFILT ; ##TEST Test file selector - Can't use M-Unit... this is interactive.
 N ROOT S ROOT="/home/forum/testkids/"
 N ARRAY S ARRAY("*")=""
 N FILE
 N % S %=$$LIST^%ZISH(ROOT,"ARRAY","FILE")
 I '% S $EC=",U-WRONG-DIRECTORY,"
 N % S %=$$SELFIL(.FILE)
 W !,%
 N % S %=$$SELFIL(.FILE,".TXT")
 W !,%
 QUIT
 ;
ANALYZET ; @TEST Test Analyze
 N ROOT S ROOT="/home/forum/testkids/"
 N A S A("*.TXT")=""
 N FILE
 N % S %=$$LIST^%ZISH(ROOT,$NA(A),$NA(FILE))
 N J S J=""
 F  S J=$O(FILE(J)) Q:J=""  D
 . K ^TMP($J,"TXT")
 . N Y S Y=$$FTG^%ZISH(ROOT,J,$NA(^TMP($J,"TXT",2,0)),3) I 'Y S $ECODE=",U-CANNOT-READ-FILE,"
 . I ^TMP($J,"TXT",2,0)'["$TXT Created by " D  ; ENELOW,JASON at MNTVBB.FO-ALBANY.DOMAIN.EXT  (KIDS)
 . . S ^(0)="$TXT Created by UNKNOWN,UNKNOWN at DOWNLOADS.VA.GOV"
 . . S ^($O(^TMP($J,"TXT"," "),-1)+1,0)="$END TXT"
 . N RTN
 . D ANALYZE^A1AEK2M2(.RTN,$NA(^TMP($J,"TXT")),"")
 . ZWRITE RTN
 . WRITE !!!
 QUIT
 ; Convenience methods for M-Unit.
ASSERT(A,B) D CHKTF^XTMUNIT(A,$G(B)) QUIT
CHKEQ(A,B,C) D CHKEQ^XTMUNIT(A,B,$G(C)) QUIT
