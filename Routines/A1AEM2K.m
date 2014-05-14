A1AEM2K	; VEN/SMH - Save patches to HFS files ;2014-04-17  6:30 PM
	;;2.4;PATCH MODULE;;Mar 28, 2014
	; Original by Dr. Cameron Schleheuber
	;
	; Get User
	I '$D(DUZ) D ^XUP
	;
	; TODO: Move the DIC("S") in a central location in A1AEPH6
	; Ask the user to the pats to export and stores in LV PATCHES
	D EN^DDIOL("Select the patches to export.")
	D EN^DDIOL("PLEASE NOTE: Multiple patches will be concatenated together into a Multibuild")
	N PATCHES S PATCHES=0
	N Y ; DIC Output
	F  D  Q:Y<0
	. N DIC
	. ; Verified      !ent.in err!retired    &
	. ; ( not no 11007 record for package ! user selection permitted ! ("test site only"& user is [self]"selected" for package )
	. S DIC("S")="I ($P(^(0),U,8)=""v""!($P(^(0),U,8)=""e"")!($P(^(0),U,8)=""r""))&($S('$D(^A1AE(11007,+$P(^(0),U,2),0)):0,$P(^(0),U,2)=""Y"":1,$P(^(0),U,4)=""y""&($D(^A1AE(11007,""AU"",DUZ,+$P(^A1AE(11005,+Y,0),U,2)))):1,1:0))"
	. S DIC("S")=DIC("S")_"!$D(^A1AE(11007,""AD"",DUZ,+$P(^A1AE(11005,+Y,0),U,2)))"
	. S DIC="^A1AE(11005,",DIC(0)="AEMQZ",DIC("A")="Select Patch/Package: "
        . I $G(A1AEUT1IEN) S Y=A1AEUT1IEN  ; Unit testing
        . E  D ^DIC
	. I Y<0 QUIT
	. S PATCHES(+Y)="",PATCHES=PATCHES+1
        . I $G(A1AEUT1IEN) S Y=-1  ; Unit testing
	I 'PATCHES QUIT  ; Done. No patches selected.
	;
	;
	; Ask where to export these patches
	N DIR,Y
	N ROOT ; Where we export these
	D EN^DDIOL("Enter where I should export these patches.")
	S DIR("B")=$$DEFDIR^%ZISH()
	S DIR(0)="F^2:255",DIR("A")="Full path, up to but not including patch names"
        I '$G(A1AEUT1IEN) D ^DIR QUIT:Y="^"  S ROOT=Y I 1  ; For Unit Testing again
        E  S ROOT=DIR("B")
	;
	; Entire stanza below to get Filename. Abstractable.
	N DIR
	N FN ; File name
	I PATCHES>1 D  QUIT:Y="^"  S FN=Y
	. D EN^DDIOL("Because you are exporting more than one patch, you have to pick a name for your file. Don't include the extension as we will append .TXT or .KID to the name you give us.")
	. S DIR(0)="F^2:255",DIR("A")="File name for Multibuild" D ^DIR
	E  D
	. N PATCH S PATCH=$O(PATCHES(""))
	. N DESIGNATION S DESIGNATION=$$GET1^DIQ(11005,PATCH,.01) ; Designation
	. N PKABBR S PKABBR=$P(DESIGNATION,"*")                   ; Get package abbreviation
	. Q:'$O(^DIC(9.4,"C",PKABBR,""))                          ; Quit if it isn't a valid package
	. N VER S VER=$P(DESIGNATION,"*",2)                       ; Version number
	. N NUM S NUM=$P(DESIGNATION,"*",3)                       ; Patch Number
	. N SEQ S SEQ=$$GET1^DIQ(11005,PATCH,"SEQUENTIAL RELEASE NUMBER")
	. I SEQ="",NUM'=0 S SEQ="NOSEQ"                           ; If not package release and no SEQ, say so.
	. S FN=PKABBR_"-"_$TR(VER,".","P")_"_SEQ-"_SEQ_"_PAT-"_NUM
	;
	; Stanza to open File.
	N POP
	D EN^DDIOL("Writing: "_$$DEFDIR^%ZISH(ROOT)_FN_".TXT")
	D OPEN^%ZISH("TXTFIL",ROOT,FN_".TXT","W")
	I POP D EN^DDIOL("Can't open file "_FN_" in path "_ROOT) QUIT
	U IO
	;
	; Stanza to write text file. Reuses code in A1AEPH6
	N PATCH F PATCH=0:0 S PATCH=$O(PATCHES(PATCH)) Q:'PATCH  D
	. N A1AEIFN,D0 S (A1AEIFN,D0)=PATCH
	. N A1AEPD S A1AEPD=$$GET1^DIQ(11005,PATCH,.01)
	. N A1AEVPR S A1AEVPR=""
	. N A1AEHD S A1AEHD="DHCP Patch Export"
	. S $P(A1AEPD,"*",2)=$S($P(A1AEPD,"*",2)=999:"DBA",1:$P(A1AEPD,"*",2))
	. I $P(^A1AE(11005,A1AEIFN,0),"^",8)="e"!($P(^(0),"^",8)="r") D
	. . N DHD S DHD="@"
	. . N L S L=0
	. . N DIC S DIC="^A1AE(11005,"
	. . D SETFLDS^A1AEPH6
	. . N BY,FR,TO S BY="",(FR,TO)=A1AEIFN
	. . D EN1^DIP
	. I $P(^A1AE(11005,A1AEIFN,0),"^",8)="v"!$D(^A1AE(11007,"AD",DUZ,+$P(^A1AE(11005,+A1AEIFN,0),U,2))) D
	. . N A1AEPGE S A1AEPGE=0
	. . ; S ^UTILITY($J,1)="D HD^A1AEPH2" ; Don't print headers at the end of IOSL.
	. . N DIWF S DIWF="B4X"
	. . N DN,DXS
	. . K ^UTILITY($J,"W")
	. . D HD^A1AEPH2,^A1AEP
	D CLOSE^%ZISH()
	D Q^A1AEPH6 ; Kill variables, and Reset to Home Device
	;
	;
	;
	; Now export the KIDS file
	;
	; Block to open File.
	N POP
	D EN^DDIOL("Writing: "_$$DEFDIR^%ZISH(ROOT)_FN_".KID")
	D OPEN^%ZISH("KIDFIL",ROOT,FN_".KID","W")
	I POP D EN^DDIOL("Can't open file "_FN_" in path "_ROOT) QUIT
	U IO
	; 
	; Header (2 lines)
	W "KIDS Distributions saved on "_$$FMTE^XLFDT($$NOW^XLFDT())_" by the Patch Module on "_^XMB("NETNAME"),!
	W "Patches/Packages: "
	N PATCH F PATCH=0:0 S PATCH=$O(PATCHES(PATCH)) Q:'PATCH  D
	. N PN S PN=$$PM2KD($$GET1^DIQ(11005,PATCH,.01))
	. N KIDGLO S KIDGLO=$NA(^TMP($J,"KID",PATCH))
	. D KIDGLO(KIDGLO,PATCH)
	. I '$D(KIDGLO) U IO(0) D EN^DDIOL("No global for "_PN) U IO K PATCHES(PATCH) QUIT
	. N SEQ S SEQ=$$GET1^DIQ(11005,PATCH,"SEQUENTIAL RELEASE NUMBER")
	. W PN_" SEQ# "_SEQ
	. W:$O(PATCHES(PATCH)) ", " ; If more, write a comma
	W !
	;
	; **KIDS** line and blank line.
	W "**KIDS**:"
	N PATCH F PATCH=0:0 S PATCH=$O(PATCHES(PATCH)) Q:'PATCH  D
	. W $$PM2KD($$GET1^DIQ(11005,PATCH,.01))_"^"
	W !!
	;
	; Write the contents of each KIDS build in sequence
	N PATCH F PATCH=0:0 S PATCH=$O(PATCHES(PATCH)) Q:'PATCH  D
	. N I F I=0:0 S I=$O(^TMP($J,"KID",PATCH,I)) Q:'I  W ^(I),!
	;
	; KIDS trailer
	W "**END**",!,"**END**",!
	D CLOSE^%ZISH()
	W !,"Done..."
	K ^TMP($J,"KID")
	QUIT
	;
PM2KD(X)	; $$ Private PM to KIDS designation
	N PKABBR,VER,NUM
	S PKABBR=$P(X,"*",1)
	S VER=$P(X,"*",2)
	S NUM=$P(X,"*",3)
	I VER[".",VER<1 S VER=0_VER ; .1 => 0.1
	I VER'["." S VER=VER_".0" ; 2 => 2.0
	I NUM'=0 Q PKABBR_"*"_VER_"*"_NUM
	I NUM=0 N PN D  Q PN
	. N PK S PK=$O(^DIC(9.4,"C",PKABBR,""))
	. N PKNM S PKNM=$P(^DIC(9.4,PK,0),U)
	. S PN=PKNM_" "_VER
	QUIT
	;
KIDGLO(OUTGLO,IEN)	; Private; Load KID contents from 11005.1 to OUTGLO
	; OUTGLO - Global Name
	; IEN - IEN in 11005/11005.1
	K @OUTGLO
	I '$D(^A1AE(11005.1,IEN,2)) QUIT
	N LINE S LINE=0
	N TEXT
	F  S LINE=$O(^A1AE(11005.1,IEN,2,LINE)) Q:'LINE  S TEXT=^(LINE,0) Q:TEXT["$END TXT"  ; spin to $END TXT
	I 'LINE QUIT  ; This line isn't needed but is here for clarity
	S LINE=$O(^A1AE(11005.1,IEN,2,LINE)),TEXT=^(LINE,0)        ; Get next line
	I $E(TEXT,1,4)'="$KID" QUIT  ; Must be $KID line
	F  S LINE=$O(^A1AE(11005.1,IEN,2,LINE)) Q:'LINE  S TEXT=^(LINE,0) Q:TEXT["$END KID"  S @OUTGLO@(LINE)=TEXT  ; load all until $END KID
	QUIT
	;
TEST	D EN^XTMUNIT($T(+0),1) QUIT
PM2KDT	; @TEST PM to KIDS designation works properly
	D CHKEQ^XTMUNIT($$PM2KD("LR*.1*3"),"LR*0.1*3")
	D CHKEQ^XTMUNIT($$PM2KD("LR*1.5*3"),"LR*1.5*3")
	D CHKEQ^XTMUNIT($$PM2KD("LR*3*3"),"LR*3.0*3")
	D CHKEQ^XTMUNIT($$PM2KD("LR*3*0"),"LAB SERVICE 3.0")
	QUIT
