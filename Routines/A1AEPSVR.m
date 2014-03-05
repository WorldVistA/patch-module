A1AEPSVR ; VEN/SMH - Mailman Patch Server;2014-03-04  7:57 PM
 ;;2.4;PATCH MODULE;;
 ; This routine reads patches coming via email from VA Forum
 ; and files them into this forum
 ;
EN ; Main entry point
 ; Mailman Server Variables
 ; ZEXCEPT: XMER - Execution Status
 ; ZEXCEPT: XMRG - Current line contents
 ; ZEXCEPT: XMPOS - Current position (line number?)
 ; ZEXCEPT: XMREC - M code to get next line. Execute this.
 ;
 ; Initial variables
 N CNT S CNT=1                      ; Internal counter
 S XMER=0                           ; See above
 K ^TMP($J,"TXT"),^("KID"),^("MSG") ; Globals where we load our messages
 N STATE S STATE="START"            ; State machine variable
 ;
 F  X XMREC Q:XMER  D @STATE        ; Main reading loop. Constructs ^TMP($J,"TXT"),^("KID")
 ;
 ; Next few lines to construct ^("MSG"). It's the ^("TXT") then the ^("KID")
 M ^TMP($J,"MSG")=^TMP($J,"TXT")
 N LS S LS=$O(^TMP($J,"MSG"," "),-1)
 N NS S NS=LS+1
 I $D(^TMP($J,"KID")) N I F I=1:1 Q:'$D(^TMP($J,"KID",I))  S ^TMP($J,"MSG",NS,0)=^TMP($J,"KID",I,0),NS=NS+1
 QUIT
 ;
START ; Message start state
 ; ZEXCEPT: XMRG,STATE,CNT
 I XMRG'["$TXT" QUIT
 S STATE="TXT"
 S ^TMP($J,"TXT",CNT,0)=XMRG,CNT=CNT+1
 QUIT
 ;
TXT ; $TXT (already found) to $END TXT
 ; ZEXCEPT: XMRG,STATE,CNT
 S ^TMP($J,"TXT",CNT,0)=XMRG,CNT=CNT+1
 I XMRG["$END TXT" S STATE="SKID",CNT=1
 QUIT
 ;
SKID ; Start $KID (if found)
 ; ZEXCEPT: XMRG,STATE,CNT
 I XMRG'["$KID" S STATE="END" QUIT
 E  S ^TMP($J,"KID",CNT,0)=XMRG,CNT=CNT+1,STATE="KID"
 QUIT
 ;
KID ; $KID (already found) to $END KID
 ; ZEXCEPT: XMRG,STATE,CNT
 S ^TMP($J,"KID",CNT,0)=XMRG,CNT=CNT+1
 I XMRG["$END KID" S STATE="END"
 QUIT
 ;
END ; Read in a infinite loop
 ; ZEXCEPT: XMRG,STATE,CNT
 QUIT
 ;
TEST ; Testing entry point by Wally
 ; ZEXCEPT: DTIME
 N XMRG,XMER,XMREC,XMZ
 W !,"Message number: " R XMZ:$G(DTIME,300) Q:'XMZ
 S XMREC="D REC^XMS3"
 D EN
 Q
