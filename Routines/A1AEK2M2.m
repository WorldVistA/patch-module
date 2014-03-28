A1AEK2M2	; VEN/SMH - Analyze text message and extract information;2014-03-05  8:17 PM
	;;2.4;PATCH MODULE;;Mar 28, 2014
	; Inspired by the VISTA XML Parser, a State Machine
	;
ANALYZE(RTN,MSGGREF,OPT)	; Public Proc ; Analyze a message in global MSGGREF. Return in RTN.
	; RTN - Ref - Return variable.
	;    ("DESIGNATION") - Patch ID (x*2.0*1)
	;    ("$TXT") - $TXT line from original patch
	;    TODO: Fill in the rest later.
	; MSGREG - Global passed by name containing message. Use Sub Ind to get data.
	; OPT - Value - Options. Only supported one is "D" - debug. Prints out lines as they are read.
	;
	N CREF ; Current global reference
	N START,STATE,LINE
	S STATE="BEGIN"
	N EOD S EOD=0 ; End of Document
	S CREF=MSGGREF ; Current reference for $Q
	N QL S QL=$QL(MSGGREF) ; QL of original global for quit next line.
	F  QUIT:EOD  D SEEK() QUIT:EOD  D @STATE  ; CENTRAL READING LOOP
	QUIT
	;
	; === REST OF EP'S ARE PRIVATE ===
	;
SEEK(NOTRIM)	; Get next line
	; ZEXCEPT: CREF,EOD,LINE,QL - Newd above
	; ZEXCEPT: MSGGREF,OPT - Params
	S CREF=$QUERY(@CREF)
	I CREF="" S EOD=1 QUIT
	I $NA(@CREF,QL)'=$NA(@MSGGREF,QL) S EOD=1 QUIT
	S LINE=@CREF
	I '$G(NOTRIM) S LINE=$$TRIM^XLFSTR(LINE,"R") ; Remove the spaces from the right
	I $G(OPT)["D" WRITE LINE,! ; Debug mode
	QUIT
	;
BEGIN	; Beginning of document
	; ZEXCEPT: START,EOD - Global vars
	; ZEXCEPT:LINE,STATE,RTN - Newed or Paramters elsewhere.
	I $E(LINE,1,4)="$TXT" D  QUIT
	. S START=1,STATE="HEADER"
	. S RTN("$TXT")=$$TRIM^XLFSTR(LINE)
	I 'START S $EC=",U-NOT-IN-TXT,"
	QUIT
	;
HEADER	; Process Header
	; ZEXCEPT:LINE,STATE,RTN - Newed or Paramters elsewhere.
	I LINE'["========================" S $EC=",U-NOT-MESSAGE,"
	D ASSERT(LINE["====")
	;
	; 1st line
	D SEEK(),ASSERT($E(LINE,1,$L("Run Date:"))="Run Date:")
	S RTN("DESIGNATION")=$P(LINE,"Designation: ",2)
	S RTN("DESIGNATION")=$$TRIM^XLFSTR(RTN("DESIGNATION"))
	;
	; 2nd line
	D SEEK(),ASSERT($E(LINE,1,$L("Package :"))="Package :")
	S RTN("PRIORITY")=$P(LINE,"Priority: ",2)
	S RTN("PRIORITY")=$$TRIM^XLFSTR(RTN("PRIORITY"))
	;
	; 3rd line
	D SEEK(),ASSERT($E(LINE,1,$L("Version :"))="Version :")
	S RTN("SEQ")=$P(LINE,"SEQ #",2)
	S RTN("SEQ")=+RTN("SEQ") ; remove trailing spaces etc
	;
	; 4rd line (optional) compliance date; Discard. Read until ====
	F  D SEEK() QUIT:(LINE["======")
	;
	S STATE="PREREQ"
	;
	QUIT
	;
PREREQ	; Pre-requisite patches
	; ZEXCEPT:LINE,STATE,RTN - Newed or Paramters elsewhere.
	; Associated patches: (v)PSJ*5*111   <<= must be installed BEFORE `PSJ*5*216'
	;                     (v)PSJ*5*179   <<= must be installed BEFORE `PSJ*5*216'
	; -- OR --
	; Associated patches: (v)TIU*1*227       install with patch       `TIU*1*274'
	;                     (c)TIU*1*261       install with patch       `TIU*1*274'
	;
	I LINE="" D SEEK()  ; Get next line if it's empty
	I LINE'["Associated patches:" S STATE="SUBJECT" QUIT
	;
	; Very trickisy line!!! Do, and loop and do
	D  F  D SEEK() Q:LINE=""  D
	. N I S I=$O(RTN("PREREQ",""),-1)+1
	. N D F D="(v)","(c)","(u)" Q:LINE[D  ; Delimiter. Verified, completed, under development. Cycle logic.
	. S RTN("PREREQ",I)=$P(LINE,D,2) ; get patch number
	. I RTN("PREREQ",I)["<<=" S RTN("PREREQ",I)=$P(RTN("PREREQ",I),"<<=") ; remove the <<=
	. I RTN("PREREQ",I)["install with patch" S RTN("PREREQ",I)=$P(RTN("PREREQ",I),"install")
	. S RTN("PREREQ",I)=$$TRIM^XLFSTR(RTN("PREREQ",I)) ; remove spaces
	;
	S STATE="SUBJECT"
	;
	QUIT
	;
SUBJECT	; Subject
	; ZEXCEPT:LINE,STATE,RTN - Newed or Paramters elsewhere.
	D ASSERT($E(LINE,1,$L("Subject: "))="Subject: ")
	S RTN("SUBJECT")=$P(LINE,"Subject: ",2)
	S RTN("SUBJECT")=$$TRIM^XLFSTR(RTN("SUBJECT"))
	;
	D SEEK() ; Read empty line and discard
	D ASSERT(LINE="")
	S STATE="CAT"
	;
	QUIT
	;
CAT	; Category
	; ZEXCEPT:LINE,STATE,RTN - Newed or Paramters elsewhere.
	D ASSERT($E(LINE,1,$L("Category:"))="Category:")
	F  D SEEK() Q:LINE=""  D
	. N I S I=$O(RTN("CAT",""),-1)+1
	. S RTN("CAT",I)=$P(LINE,"- ",2)
	S STATE="DESC"
	QUIT
	;
DESC	; Description
	; ZEXCEPT:LINE,STATE,RTN - Newed or Paramters elsewhere.
	D ASSERT($E(LINE,1,$L("Description:"))="Description:")
	D SEEK()
	D ASSERT(LINE["====")
	F  D SEEK(0) Q:$L(LINE)  ; Eat up empty lines
	D  F  D SEEK(1) Q:($E(LINE)'=" ")  D
	. N I S I=$O(RTN("DESC",""),-1)+1
	. S RTN("DESC",I)=$P(LINE," ",2,999) ; Read the rest of the line removing the space.
	S STATE="USERS"
	QUIT
	;
USERS	; Users
	; ZEXCEPT:LINE,STATE,RTN - Newed or Paramters elsewhere.
	; Entered By  : ROWLANDS,ELMER                Date Entered  : JUN 23, 2010
	; Completed By: SHERMAN,BILL                  Date Completed: AUG 23, 2013
	; Released By : PIERSON,YVONNE E              Date Released : SEP 04, 2013
	F  D SEEK() Q:LINE["===================================="  ; Loop to this line
	D SEEK(),ASSERT(LINE["User Information")
	;
	N STR S STR="Entered By  : "
	D SEEK(),ASSERT($E(LINE,1,$L(STR))=STR)
	S RTN("DEV")=$P(LINE,STR,2,99)
	S RTN("DEV")=$P(RTN("DEV"),"Date ")
	S RTN("DEV")=$$TRIM^XLFSTR(RTN("DEV"))
	S RTN("DEV","DATE")=$P(LINE,"Date Entered  : ",2)
	;
	N STR S STR="Completed By: "
	D SEEK(),ASSERT($E(LINE,1,$L(STR))=STR)
	S RTN("COM")=$P(LINE,STR,2,99)
	S RTN("COM")=$P(RTN("COM"),"Date ")
	S RTN("COM")=$$TRIM^XLFSTR(RTN("COM"))
	S RTN("COM","DATE")=$P(LINE,"Date Completed: ",2)
	;
	N STR S STR="Released By : "
	D SEEK(),ASSERT($E(LINE,1,$L(STR))=STR)
	S RTN("VER")=$P(LINE,STR,2,99)
	S RTN("VER")=$P(RTN("VER"),"Date ")
	S RTN("VER")=$$TRIM^XLFSTR(RTN("VER"))
	S RTN("VER","DATE")=$P(LINE,"Date Released : ",2)
	F  D SEEK() Q:LINE["===================================="  ; Loop to this line
	;
	S STATE="FOOTER"
	QUIT
FOOTER	; Footer
	; ZEXCEPT: LINE,EOD,START
	; 
	; 
	; Packman Mail Message:
	; =====================
	; 
	; $END TXT
	;
	F  D SEEK() Q:LINE="$END TXT"
	S EOD=1,START=0
	QUIT
	;
NOP	; No-Op. Use this in debugging.
	; ZEXCEPT:LINE,STATE,RTN - Newed or Paramters elsewhere.
	W LINE,!
	QUIT
ASSERT(X,Y)	; Assertion engine
	I 'X D EN^DDIOL($G(Y)) S $EC=",U-ASSERTION-ERROR,"
	QUIT
	;
ANATRAP(PATCH)	; Analysis Trap -- use this to capture errors from ANALYZE^A1AEK2M2.
	; YOU MUST NEW $ET AND $ES AND SET $ET="DO ANATRAP^A1AEK2M2(PATCH)"
	; I $EC[",U-NOT-MESSAGE," DO EN^DDIOL(PATCH_" IS NOT A PATCH MESSAGE") S $ET="G UNWIND^ZU",$EC=",UQUIT," QUIT
	I $EC[",U-NOT-MESSAGE," DO EN^DDIOL(PATCH_" IS NOT A PATCH MESSAGE") G UNWIND
	QUIT
	;
UNWIND	; Trap unwinder
	S $ET="Q:($ES&$Q) -9  Q:$ES  S $EC="""""
	S $EC=",UQUIT,"
	QUIT  ; This is not hit
