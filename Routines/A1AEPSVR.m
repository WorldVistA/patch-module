A1AEPSVR ; VEN/SMH - Mailman Patch Server;2014-03-05  9:19 PM
 ;;2.4;PATCH MODULE;;
 ; This routine reads patches coming via email from VA Forum
 ; and files them into this forum
 ;
 ; NOTE: POSTMASTER MUST HAVE A1AE MGR/ (OR IMPORT ONCE I CREATE THAT) KEY
 ;       FOR THIS TO WORK.
 ;
EN ; Main entry point
 ; Mailman Server Variables
 ; ZEXCEPT: XMER - Execution Status
 ; ZEXCEPT: XMRG - Current line contents
 ; ZEXCEPT: XMPOS - Current position (line number?)
 ; ZEXCEPT: XMREC - M code to get next line. Execute this.
 ; ZEXCEPT: XMZ - Message IEN in 3.9
 I '$D(^XMB(3.9,XMZ)) QUIT  ; Just a failsafe... shouldn't happen in real life.
 ;
 ; TODO: Add key to post master.
 ;
 ; Initial variables
 N CNT S CNT=1                      ; Internal counter
 S XMER=0                           ; See above
 K ^TMP($J,"TXT"),^("KID"),^("MSG") ; Globals where we load our messages
 N STATE S STATE="START"            ; State machine variable
 ;
 F  X XMREC Q:XMER  D @STATE        ; Main reading loop. Constructs ^TMP($J,"TXT"),^("KID")
 ;
 I '$D(^TMP($J,"TXT")) D EN^DDIOL("Message "_XMZ_" ("_$P(^XMB(3.9,XMZ,0),U)_")"_" is Not a Patch Message") QUIT
 ;
 ; Next few lines to construct ^("MSG"). It's the ^("TXT") then the ^("KID")
 M ^TMP($J,"MSG")=^TMP($J,"TXT")
 N LS S LS=$O(^TMP($J,"MSG"," "),-1)
 N NS S NS=LS+1
 I $D(^TMP($J,"KID")) N I F I=1:1 Q:'$D(^TMP($J,"KID",I))  S ^TMP($J,"MSG",NS,0)=^TMP($J,"KID",I,0),NS=NS+1
 ;
 ; Now that we have the entire message, now process it.
 D CLEANHF^A1AEK2M0($NA(^TMP($J,"TXT"))) ; add $TXT/$END TXT if necessary
 N TXTINFO
 N OLDTRAP S OLDTRAP=$ET
 N $ET,$ES S $ET="D ANATRAP^A1AEK2M2("""_XMZ_" - "_$P(^XMB(3.9,XMZ,0),U)_""")"
 D ANALYZE^A1AEK2M2(.TXTINFO,$NA(^TMP($J,"TXT")))
 S $ET=OLDTRAP
 N INFOONLY S INFOONLY=$$INFOONLY^A1AEK2M(.TXTINFO) ; Info Only patch?
 ;
 ; Populate the result variable for the mail message
 ; TODO: Result variable populatation needs to be abstracted.
 ; TODO: Mail message that something has been loaded.
 N RESULT
 N CANTLOAD S CANTLOAD=0
 S RESULT(TXTINFO("DESIGNATION"),"TXT")="Mailed Patch"
 I INFOONLY S RESULT(TXTINFO("DESINGATION"),"KID")="Info Only Patch"
 E  D
 . I $D(^TMP($J,"KID")) S RESULT(TXTINFO("DESIGNATION"),"KID")="KID patch loaded inline"
 . E  D
 . . S RESULT(TXTINFO("DESIGNATION"),"KID")=""
 . . S RESULT(TXTINFO("DESIGNATION"),"CANTLOAD")="Mail Message"
 . . S CANTLOAD=1
 ;
 ; Add dependencies in description (temporary or permanent... I don't know now).
 D PREREQAD^A1AEK2M(.TXTINFO)
 ;
 ; Load whole thing and split
 D ADD0^A1AEK2M(.TXTINFO,$NA(^TMP($J,"MSG")),CANTLOAD,INFOONLY,.RESULT)
 ;
 K ^TMP($J,"KID"),^("TXT"),^("MSG")
 N XMSER S XMSER="S.A1AE LOAD RELEASED PATCH"
 D REMSBMSG^XMA1C
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
 QUIT
 ;
UNITTEST D EN^XTMUNIT($T(+0),1) QUIT
UT1 ; @TEST
 ; TODO: Create the ZZZ package in 9.4
 N DIK,DA ; fur Fileman
 S DUZ=.5 ; Must be defined for auditing.
 N PKGAB S PKGAB="ZZZ"
 ; Get entry from package file if it exists.
 N PKIEN S PKIEN=$O(^DIC(9.4,"C",PKGAB,0))
 ; If package is there, delete everything that belongs to it
 I PKIEN D 
 . S DA="" F  S DA=$O(^A1AE(11005,"D",PKIEN,DA)) Q:'DA  D
 . . F DIK="^A1AE(11005,","^A1AE(11005.1," D ^DIK  ; PM Patch and Message files
 . S DIK="^A1AE(11007,",DA=PKIEN D ^DIK  ; PM Package File
 ;
 D CHKTF^XTMUNIT('$D(^A1AE(11005,"D",PKIEN)))
 N MESS,LN0,LN
 N I F I=1:1 S LN0=$T(MESSAGE+I),LN=$P(LN0,";;",2,99) S MESS(I,0)=LN Q:LN["$END KID"
 N FLAGS S FLAGS("TYPE")="K" ; KIDS
 S DUZ=.5
 N PD S PD="ZZZ*2.0*1"
 D SENDMSG^XMXAPI(DUZ,PD,$NA(MESS),"S.A1AE LOAD RELEASED PATCH",.FLAGS,.MESSAGEIEN)
 D EN^DDIOL("Waiting 10 seconds for taskman to finish...")
 HANG 10
 D CHKTF^XTMUNIT($D(^A1AE(11005,"D",PKIEN)))
 QUIT
 ;
MESSAGE ;;
 ;;$TXT Created by TESTMASTER,USER at VEN.SMH101.COM  (KIDS) on Thursday, 01/07/14 at 15:55
 ;;=============================================================================
 ;;Run Date: JAN 22, 2014                     Designation: ZZZ*2*1
 ;;Package : ZZZ - TEST PACKAGE                  Priority: EMERGENCY
 ;;Version : 2         SEQ #1                      Status: Released
 ;;=============================================================================
 ;;
 ;;
 ;;Subject: TEST IMPORT INTO PATCH MODULE VIA S.A1AE LOAD RELEASED PATCH
 ;;
 ;;Category: 
 ;;  - Data Dictionary
 ;;  - Input Template
 ;;  - Print Template
 ;;  - Routine
 ;;
 ;;Description:
 ;;============
 ;;
 ;; 
 ;;  This patch is the result of the Unit Test routine.
 ;;  Please ignore it.
 ;;  
 ;;  Patch ID: ZZZ*2.0*1
 ;;  
 ;;
 ;;Routine Information:
 ;;====================
 ;;The second line of each of these routines now looks like:
 ;; ;;8.0;KERNEL;**[Patch List]**;Jul 10, 1995;Build 2
 ;;
 ;;The checksums below are new checksums, and
 ;; can be checked with CHECK1^XTSUMBLD.
 ;;
 ;;Routine Name: ZOSV2GTM
 ;;    Before:  B7008460   After:  B7008460  **275,425**
 ;; 
 ;;Routine list of preceding patches: 425
 ;;
 ;;=============================================================================
 ;;User Information:
 ;;Entered By  : PATCHMODULE,DEVELOPER         Date Entered  : JAN 22, 2014
 ;;Completed By: PATCHMODULE,COMPLETER         Date Completed: JAN 22, 2014
 ;;Released By : PATCHMODULE,VERIFER           Date Released : JAN 22, 2014
 ;;=============================================================================
 ;;
 ;;
 ;;Packman Mail Message:
 ;;=====================
 ;;
 ;;$END TXT
 ;;$KID ZZZ*1.0*1
 ;;**INSTALL NAME**
 ;;ZZZ*1.0*1
 ;;"BLD",9277,0)
 ;;ZZZ*1.0*1^TEST PACKAGE^0^3140102^y
 ;;"BLD",9277,1,0)
 ;;^^1^1^3140102^
 ;;"BLD",9277,1,1,0)
 ;;TEST TEST
 ;;"BLD",9277,4,0)
 ;;^9.64PA^^
 ;;"BLD",9277,6.3)
 ;;2
 ;;"BLD",9277,"KRN",0)
 ;;^9.67PA^779.2^20
 ;;"BLD",9277,"KRN",.4,0)
 ;;.4
 ;;"BLD",9277,"KRN",.401,0)
 ;;.401
 ;;"BLD",9277,"KRN",.402,0)
 ;;.402
 ;;"BLD",9277,"KRN",.403,0)
 ;;.403
 ;;"BLD",9277,"KRN",.5,0)
 ;;.5
 ;;"BLD",9277,"KRN",.84,0)
 ;;.84
 ;;"BLD",9277,"KRN",3.6,0)
 ;;3.6
 ;;"BLD",9277,"KRN",3.8,0)
 ;;3.8
 ;;"BLD",9277,"KRN",9.2,0)
 ;;9.2
 ;;"BLD",9277,"KRN",9.8,0)
 ;;9.8
 ;;"BLD",9277,"KRN",9.8,"NM",0)
 ;;^9.68A^1^1
 ;;"BLD",9277,"KRN",9.8,"NM",1,0)
 ;;ZOSV2GTM^^0^B7008460
 ;;"BLD",9277,"KRN",9.8,"NM","B","ZOSV2GTM",1)
 ;;
 ;;"BLD",9277,"KRN",19,0)
 ;;19
 ;;"BLD",9277,"KRN",19.1,0)
 ;;19.1
 ;;"BLD",9277,"KRN",101,0)
 ;;101
 ;;"BLD",9277,"KRN",409.61,0)
 ;;409.61
 ;;"BLD",9277,"KRN",771,0)
 ;;771
 ;;"BLD",9277,"KRN",779.2,0)
 ;;779.2
 ;;"BLD",9277,"KRN",870,0)
 ;;870
 ;;"BLD",9277,"KRN",8989.51,0)
 ;;8989.51
 ;;"BLD",9277,"KRN",8989.52,0)
 ;;8989.52
 ;;"BLD",9277,"KRN",8994,0)
 ;;8994
 ;;"BLD",9277,"KRN","B",.4,.4)
 ;;
 ;;"BLD",9277,"KRN","B",.401,.401)
 ;;
 ;;"BLD",9277,"KRN","B",.402,.402)
 ;;
 ;;"BLD",9277,"KRN","B",.403,.403)
 ;;
 ;;"BLD",9277,"KRN","B",.5,.5)
 ;;
 ;;"BLD",9277,"KRN","B",.84,.84)
 ;;
 ;;"BLD",9277,"KRN","B",3.6,3.6)
 ;;
 ;;"BLD",9277,"KRN","B",3.8,3.8)
 ;;
 ;;"BLD",9277,"KRN","B",9.2,9.2)
 ;;
 ;;"BLD",9277,"KRN","B",9.8,9.8)
 ;;
 ;;"BLD",9277,"KRN","B",19,19)
 ;;
 ;;"BLD",9277,"KRN","B",19.1,19.1)
 ;;
 ;;"BLD",9277,"KRN","B",101,101)
 ;;
 ;;"BLD",9277,"KRN","B",409.61,409.61)
 ;;
 ;;"BLD",9277,"KRN","B",771,771)
 ;;
 ;;"BLD",9277,"KRN","B",779.2,779.2)
 ;;
 ;;"BLD",9277,"KRN","B",870,870)
 ;;
 ;;"BLD",9277,"KRN","B",8989.51,8989.51)
 ;;
 ;;"BLD",9277,"KRN","B",8989.52,8989.52)
 ;;
 ;;"BLD",9277,"KRN","B",8994,8994)
 ;;
 ;;"BLD",9277,"QUES",0)
 ;;^9.62^^
 ;;"MBREQ")
 ;;0
 ;;"PKG",223,-1)
 ;;1^1
 ;;"PKG",223,0)
 ;;TEST PACKAGE^ZZZ^FOR FORUM
 ;;"PKG",223,22,0)
 ;;^9.49I^1^1
 ;;"PKG",223,22,1,0)
 ;;1.0
 ;;"PKG",223,22,1,"PAH",1,0)
 ;;1^3140102
 ;;"PKG",223,22,1,"PAH",1,1,0)
 ;;^^1^1^3140102
 ;;"PKG",223,22,1,"PAH",1,1,1,0)
 ;;TEST TEST
 ;;"QUES","XPF1",0)
 ;;Y
 ;;"QUES","XPF1","??")
 ;;^D REP^XPDH
 ;;"QUES","XPF1","A")
 ;;Shall I write over your |FLAG| File
 ;;"QUES","XPF1","B")
 ;;YES
 ;;"QUES","XPF1","M")
 ;;D XPF1^XPDIQ
 ;;"QUES","XPF2",0)
 ;;Y
 ;;"QUES","XPF2","??")
 ;;^D DTA^XPDH
 ;;"QUES","XPF2","A")
 ;;Want my data |FLAG| yours
 ;;"QUES","XPF2","B")
 ;;YES
 ;;"QUES","XPF2","M")
 ;;D XPF2^XPDIQ
 ;;"QUES","XPI1",0)
 ;;YO
 ;;"QUES","XPI1","??")
 ;;^D INHIBIT^XPDH
 ;;"QUES","XPI1","A")
 ;;Want KIDS to INHIBIT LOGONs during the install
 ;;"QUES","XPI1","B")
 ;;NO
 ;;"QUES","XPI1","M")
 ;;D XPI1^XPDIQ
 ;;"QUES","XPM1",0)
 ;;PO^VA(200,:EM
 ;;"QUES","XPM1","??")
 ;;^D MG^XPDH
 ;;"QUES","XPM1","A")
 ;;Enter the Coordinator for Mail Group '|FLAG|'
 ;;"QUES","XPM1","B")
 ;;
 ;;"QUES","XPM1","M")
 ;;D XPM1^XPDIQ
 ;;"QUES","XPO1",0)
 ;;Y
 ;;"QUES","XPO1","??")
 ;;^D MENU^XPDH
 ;;"QUES","XPO1","A")
 ;;Want KIDS to Rebuild Menu Trees Upon Completion of Install
 ;;"QUES","XPO1","B")
 ;;NO
 ;;"QUES","XPO1","M")
 ;;D XPO1^XPDIQ
 ;;"QUES","XPZ1",0)
 ;;Y
 ;;"QUES","XPZ1","??")
 ;;^D OPT^XPDH
 ;;"QUES","XPZ1","A")
 ;;Want to DISABLE Scheduled Options, Menu Options, and Protocols
 ;;"QUES","XPZ1","B")
 ;;NO
 ;;"QUES","XPZ1","M")
 ;;D XPZ1^XPDIQ
 ;;"QUES","XPZ2",0)
 ;;Y
 ;;"QUES","XPZ2","??")
 ;;^D RTN^XPDH
 ;;"QUES","XPZ2","A")
 ;;Want to MOVE routines to other CPUs
 ;;"QUES","XPZ2","B")
 ;;NO
 ;;"QUES","XPZ2","M")
 ;;D XPZ2^XPDIQ
 ;;"RTN")
 ;;1
 ;;"RTN","ZOSV2GTM")
 ;;0^1^B7008460^B7008460
 ;;"RTN","ZOSV2GTM",1,0)
 ;;%ZOSV2 ;ISF/RWF - More GT.M support routines ;10/18/06  14:29
 ;;"RTN","ZOSV2GTM",2,0)
 ;; ;;8.0;KERNEL;**275,425**;Jul 10, 1995;Build 2
 ;;"RTN","ZOSV2GTM",3,0)
 ;; Q
 ;;"RTN","ZOSV2GTM",4,0)
 ;; ;SAVE: DIE open array reference.
 ;;"RTN","ZOSV2GTM",5,0)
 ;; ;      XCN is the starting value to $O from.
 ;;"RTN","ZOSV2GTM",6,0)
 ;;SAVE(RN) ;Save a routine
 ;;"RTN","ZOSV2GTM",7,0)
 ;; N %,%F,%I,%N,SP,$ETRAP
 ;;"RTN","ZOSV2GTM",8,0)
 ;; S $ETRAP="S $ECODE="""" Q"
 ;;"RTN","ZOSV2GTM",9,0)
 ;; S %I=$I,SP=" ",%F=$$RTNDIR^%ZOSV()_$TR(RN,"%","_")_".m"
 ;;"RTN","ZOSV2GTM",10,0)
 ;; O %F:(newversion:noreadonly:blocksize=2048:recordsize=2044) U %F
 ;;"RTN","ZOSV2GTM",11,0)
 ;; F  S XCN=$O(@(DIE_XCN_")")) Q:XCN'>0  S %=@(DIE_XCN_",0)") Q:$E(%,1)="$"  I $E(
 ;;%)'=";" W $P(%,SP)_$C(9)_$P(%,SP,2,99999),!
 ;;"RTN","ZOSV2GTM",12,0)
 ;; C %F ;S %N=$$NULL
 ;;"RTN","ZOSV2GTM",13,0)
 ;; ZLINK RN
 ;;"RTN","ZOSV2GTM",14,0)
 ;; ;C %N
 ;;"RTN","ZOSV2GTM",15,0)
 ;; U %I
 ;;"RTN","ZOSV2GTM",16,0)
 ;; Q
 ;;"RTN","ZOSV2GTM",17,0)
 ;;NULL() ;Open and use null to hide talking.  Return open name
 ;;"RTN","ZOSV2GTM",18,0)
 ;; ;Doesn't work for compile errors
 ;;"RTN","ZOSV2GTM",19,0)
 ;; N %N S %N=$S($ZV["VMS":"NLA0:",1:"/dev/nul")
 ;;"RTN","ZOSV2GTM",20,0)
 ;; O %N U %N
 ;;"RTN","ZOSV2GTM",21,0)
 ;; Q %N
 ;;"RTN","ZOSV2GTM",22,0)
 ;; ;
 ;;"RTN","ZOSV2GTM",23,0)
 ;;DEL(RN) ;Delete a routine file, both source and object.
 ;;"RTN","ZOSV2GTM",24,0)
 ;; N %N,%DIR,%I,$ETRAP
 ;;"RTN","ZOSV2GTM",25,0)
 ;; S $ETRAP="S $ECODE="""" Q"
 ;;"RTN","ZOSV2GTM",26,0)
 ;; S %I=$I,%DIR=$$RTNDIR^%ZOSV,RN=$TR(RN,"%","_")
 ;;"RTN","ZOSV2GTM",27,0)
 ;; I $L($ZSEARCH(%DIR_RN_".m",244)) ZSYSTEM "DEL "_%DIR_X_".m;*"
 ;;"RTN","ZOSV2GTM",28,0)
 ;; I $L($ZSEARCH(%DIR_RN_".obj",244)) ZSYSTEM "DEL "_%DIR_X_".obj;*"
 ;;"RTN","ZOSV2GTM",29,0)
 ;; I $L($ZSEARCH(%DIR_RN_".o",244)) ZSYSTEM "rm -f "_%DIR_X_".o"
 ;;"RTN","ZOSV2GTM",30,0)
 ;; Q
 ;;"RTN","ZOSV2GTM",31,0)
 ;; ;LOAD: DIF open array to receive the routine lines.
 ;;"RTN","ZOSV2GTM",32,0)
 ;; ;      XCNP The starting index -1.
 ;;"RTN","ZOSV2GTM",33,0)
 ;;LOAD(RN) ;Load a routine
 ;;"RTN","ZOSV2GTM",34,0)
 ;; N %
 ;;"RTN","ZOSV2GTM",35,0)
 ;; S %N=0 F XCNP=XCNP+1:1 S %N=%N+1,%=$T(+%N^@RN) Q:$L(%)=0  S @(DIF_XCNP_",0)")=%
 ;;"RTN","ZOSV2GTM",36,0)
 ;; Q
 ;;"RTN","ZOSV2GTM",37,0)
 ;; ;
 ;;"RTN","ZOSV2GTM",38,0)
 ;;LOAD2(RN) ;Load a routine
 ;;"RTN","ZOSV2GTM",39,0)
 ;; N %,%1,%F,%N,$ETRAP
 ;;"RTN","ZOSV2GTM",40,0)
 ;; S %I=$I,%F=$$RTNDIR^%ZOSV()_$TR(RN,"%","_")_".m"
 ;;"RTN","ZOSV2GTM",41,0)
 ;; O %F:(readonly):1 Q:'$T  U %F
 ;;"RTN","ZOSV2GTM",42,0)
 ;; F XCNP=XCNP+1:1 R %1:1 Q:'$T!$ZEOF  S @(DIF_XCNP_",0)")=$TR(%1,$C(9)," ")
 ;;"RTN","ZOSV2GTM",43,0)
 ;; C %F I $L(%I) U %I
 ;;"RTN","ZOSV2GTM",44,0)
 ;; Q
 ;;"RTN","ZOSV2GTM",45,0)
 ;; ;
 ;;"RTN","ZOSV2GTM",46,0)
 ;;RSUM(RN) ;Calculate a RSUM value
 ;;"RTN","ZOSV2GTM",47,0)
 ;; N %,DIF,XCNP,%N,Y,$ETRAP K ^TMP("RSUM",$J)
 ;;"RTN","ZOSV2GTM",48,0)
 ;; S $ETRAP="S $ECODE="""" Q"
 ;;"RTN","ZOSV2GTM",49,0)
 ;; S Y=0,DIF="^TMP(""RSUM"",$J,",XCNP=0 D LOAD2(RN)
 ;;"RTN","ZOSV2GTM",50,0)
 ;; F %=1,3:1 S %1=$G(^TMP("RSUM",$J,%,0)),%3=$F(%1," ") Q:'%3  S %3=$S($E(%1,%3)'=
 ;;";":$L(%1),$E(%1,%3+1)=";":$L(%1),1:%3-2) F %2=1:1:%3 S Y=$A(%1,%2)*%2+Y
 ;;"RTN","ZOSV2GTM",51,0)
 ;; K ^TMP("RSUM",$J)
 ;;"RTN","ZOSV2GTM",52,0)
 ;; Q Y
 ;;"RTN","ZOSV2GTM",53,0)
 ;; ;
 ;;"RTN","ZOSV2GTM",54,0)
 ;;RSUM2(RN) ;Calculate a RSUM2 value
 ;;"RTN","ZOSV2GTM",55,0)
 ;; N %,DIF,XCNP,%N,Y,$ETRAP K ^TMP("RSUM",$J)
 ;;"RTN","ZOSV2GTM",56,0)
 ;; S $ETRAP="S $ECODE="""" Q"
 ;;"RTN","ZOSV2GTM",57,0)
 ;; S Y=0,DIF="^TMP(""RSUM"",$J,",XCNP=0 D LOAD2(RN)
 ;;"RTN","ZOSV2GTM",58,0)
 ;; F %=1,3:1 S %1=$G(^TMP("RSUM",$J,%,0)),%3=$F(%1," ") Q:'%3  S %3=$S($E(%1,%3)'=
 ;;";":$L(%1),$E(%1,%3+1)=";":$L(%1),1:%3-2) F %2=1:1:%3 S Y=$A(%1,%2)*(%2+%)+Y
 ;;"RTN","ZOSV2GTM",59,0)
 ;; K ^TMP("RSUM",$J)
 ;;"RTN","ZOSV2GTM",60,0)
 ;; Q Y
 ;;"RTN","ZOSV2GTM",61,0)
 ;; ;
 ;;"RTN","ZOSV2GTM",62,0)
 ;;TEST(RN) ;Special GT.M Test to see if routine is here.
 ;;"RTN","ZOSV2GTM",63,0)
 ;; N %F,%X
 ;;"RTN","ZOSV2GTM",64,0)
 ;; S %F=$$RTNDIR^%ZOSV()_$TR(RN,"%","_")_".m"
 ;;"RTN","ZOSV2GTM",65,0)
 ;; S %X=$ZSEARCH("X.X",245),%X=$ZSEARCH(%F,245)
 ;;"RTN","ZOSV2GTM",66,0)
 ;; Q %X
 ;;"VER")
 ;;8.0^22.0
 ;;"BLD",9277,6)
 ;;^1
 ;;$END KID ZZZ*1.0*1
