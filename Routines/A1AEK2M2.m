A1AEK2M2 ; VEN/SMH - Analyze text message and extract information;2014-01-31  9:36 PM
 ;
 ; Inspired by the VISTA XML Parser, a State Machine
 ;
ANALYZE(RTN,MSGGREF,OPT) ; Public Proc ; Analyze a message in global MSGGREF. Return in RTN.
 ; RTN - Ref - Return variable.
 ;     - format TBD
 ; MSGREG - Global passed by name containing message. Use Sub Ind to get data.
 ; OPT - Value - Options
 ;
 N CREF ; Current global reference
 N START,STATE
 S STATE="BEGIN"
 N EOD S EOD=0 ; End of Document
 S CREF=MSGGREF ; Current reference for $Q
 N QL S QL=$QL(MSGGREF) ; QL of original global for quit next line.
 F  QUIT:EOD  D SEEK QUIT:EOD  D @STATE  ; CENTRAL READING LOOP
 QUIT
 ;
SEEK ; Get next line
 S CREF=$QUERY(@CREF)
 I CREF="" S EOD=1 QUIT
 I $NA(@CREF,QL)'=$NA(@MSGGREF,QL) S EOD=1 QUIT
 S LINE=@CREF
 I $G(OPT)["D" WRITE LINE,! ; Debug mode
 QUIT
 ;
BEGIN ; Beginning of document
 ; ZEXCEPT: START,EOD - Global vars
 I $E(LINE,1,4)="$TXT" S START=1,STATE="HEADER" QUIT
 I 'START S $EC=",U-NOT-IN-TXT,"
 QUIT
 ;
HEADER ; Process Header
 D ASSERT(LINE["====")
 ;
 ; 1st line
 D SEEK,ASSERT($E(LINE,1,$L("Run Date:"))="Run Date:")
 S RTN("DESIGNATION")=$P(LINE,"Designation: ",2)
 S RTN("DESIGNATION")=$$TRIM^XLFSTR(RTN("DESIGNATION"))
 ;
 ; 2nd line
 D SEEK,ASSERT($E(LINE,1,$L("Package :"))="Package :")
 S RTN("PRIORITY")=$P(LINE,"Priority: ",2)
 S RTN("PRIORITY")=$$TRIM^XLFSTR(RTN("PRIORITY"))
 ;
 ; 3rd line
 D SEEK,ASSERT($E(LINE,1,$L("Version :"))="Version :")
 S RTN("SEQ")=$P(LINE,"SEQ #",2)
 S RTN("SEQ")=+RTN("SEQ") ; remove trailing spaces etc
 ;
 ; 4rd line (optional) compliance date; Discard. Read until ====
 F  D SEEK QUIT:(LINE["======")
 ;
 S STATE="NOP"
 ;
 QUIT
 ;
NOP ; No-Op.
 W LINE,!
 QUIT
ASSERT(X,Y) ; Assertion engine
 I 'X D EN^DDIOL($G(Y)) S $EC=",U-ASSERTION-ERROR,"
 QUIT
