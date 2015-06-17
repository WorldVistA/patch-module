A1AEUBL1 ;ven/jli-utility support for unit tests for updating packman message and kids build ;2015-05-20T19:25
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ; This is a unit test for Forum Server systems
        I '$D(^DIC(9.4,"B","PATCH MODULE")) Q  ;
        ; this is a utility module, run the main unit test
 D EN^%ut("A1AEUBLD")
 Q
 ;
VERBOSE ;
 ; This is a unit test for Forum Server systems
        I '$D(^DIC(9.4,"B","PATCH MODULE")) Q  ;
        D EN^%ut("A1AEUBLD",1)
 Q
 ;
TESTIT ; Entry point to run the entire process, i.e., import a build, modify it, set it as an PackMan message, and install it
 ; To demo its effects, set A1AEVIEW to a value,
 ; then after the examination run DOITNOW^A1AEUBL1 to cleanup
 ;
 I '$$ISUTEST^%ut D STARTUP
 N A1AEUPAT,A1AEUXMB,I,X,XMB
 S A1AEUXMB=^TMP("A1AEUBL1",$J,"A1AEUXMB")
 S A1AEUPAT=^TMP("A1AEUBL1",$J,"A1AEUPAT")
 ; set up basic packman message in PATCH MESSAGE
 M ^A1AE(11005.1,A1AEUPAT,2)=^XMB(3.9,A1AEUXMB,2)
 ; add data from DHCP PATCHES file
 D BUILDIT^A1AEBLD(A1AEUPAT)
 ; move the updated text back to the mail message
 M ^XMB(3.9,A1AEUXMB,2)=^A1AE(11005.1,A1AEUPAT,2)
 ; change patch number from current
 F I=0:0 S I=$O(^XMB(3.9,A1AEUXMB,2,I)) Q:I'>0  S X=^(I,0) I X["*912" S X=$P(X,"*912")_"*913"_$P(X,"*912",2,99) S ^(0)=X
 ; build XTMP("XPDI" entry
 N XMZ S XMZ=A1AEUXMB
 N XMR S XMR=^XMB(3.9,XMZ,0)
 W !!,"Respond Y (YES) to any prompts!",!
 ; load patch
 D XI^XMP2
 ; and install - would be called from IN^XPDJI1 in a normal install
 D INSTALL^A1AEBLD(^TMP("A1AEUBL1",$J,"A1AEPTID"))
 ; if not being run as part of a unit test, remove any data added
 I '$$ISUTEST^%ut D SHUTDOWN
 Q
 ;
STARTUP ;
 ; Build a basic packman message with some parts
 N YARR,I,XMB,A1AEUXMB,A1AEUBLD,A1AEUPAT
 ; Global Listing for ^XMB(3.9,3124
 N A1AEVAL S A1AEVAL=$P(^DIC(4.2,+^XTV(8989.3,1,0),0),U)
 S A1AEUPAT=$P(^A1AE(11005,0),U,3)+100
 S A1AEUBLD=$P(^XPD(9.6,0),U,3)+100
 S ^TMP("A1AEUBL1",$J,"A1AEUPAT")=A1AEUPAT
 S ^TMP("A1AEUBL1",$J,"A1AEUBLD")=A1AEUBLD
 ; save location for later
 S A1AEUXMB=$P(^XMB(3.9,0),U,3)+2000
 S ^TMP("A1AEUBL1",$J,"A1AEUXMB")=A1AEUXMB
 ;
 N A1AENOW S A1AENOW=$E($$NOW^XLFDT_"0000",1,12)
 N A1AEDATE S A1AEDATE=$$DOW^XLFDT(A1AENOW)_", "_$$FMTE^XLFDT($P(A1AENOW,".",1),"2Z")_" at "_$E(A1AENOW,9,10)_":"_$E(A1AENOW,11,12)
 N A1AENOW1 S A1AENOW1=$P(A1AENOW,".")
 ;S ^XPD(9.6,A1AEUBLD,0)=A1AENMSP_"*"_A1AEVERS_"*912"
 N A1AEPACK S A1AEPACK=$O(^DIC(9.4,"B","PATCH MODULE",0)) I A1AEPACK'>0 S A1AEPACK=$O(^DIC(9.4,"B","VA FILEMAN",0)) I A1AEPACK'>0 S A1AEPACK=$O(^DIC(9.4,"B","KERNEL",0))
 N A1AENMSP S A1AENMSP=$P(^DIC(9.4,A1AEPACK,0),U,2)
 N A1AEVERS S A1AEVERS=$G(^DIC(9.4,A1AEPACK,"VERSION"))
 S YARR(1,0)="$TXT Created by "_$P(^VA(200,DUZ,0),U)_" at "_A1AEVAL_"  (KIDS) on "_A1AEDATE
 S YARR(2,0)=" "
 S YARR(3,0)="Test Patch for A1AE code."
 S YARR(4,0)=" "
 S YARR(5,0)="$END TXT"
 S YARR(6,0)="$KID "_A1AENMSP_"*"_A1AEVERS_"*912"
 S YARR(7,0)="**INSTALL NAME**"
 S YARR(8,0)=A1AENMSP_"*"_A1AEVERS_"*912"
 S ^TMP("A1AEUBL1",$J,"A1AEPTID")=A1AENMSP_"*"_A1AEVERS_"*913"
 S YARR(9,0)="""BLD"",5528,0)"
 S YARR(10,0)=A1AENMSP_"*"_A1AEVERS_"*912^PATCH MODULE^0^"_A1AENOW1_"^n"
 S YARR(11,0)="""BLD"",5528,1,0)"
 S YARR(12,0)="^^1^1^"_A1AENOW1_"^"
 S YARR(13,0)="""BLD"",5528,1,1,0)"
 S YARR(14,0)="TEST ROUTINE FOR UNIT TESTING A1AE CODE"
 S YARR(15,0)="""BLD"",5528,4,0)"
 S YARR(16,0)="^9.64PA^^"
 S YARR(17,0)="""BLD"",5528,""KRN"",0)"
 S YARR(18,0)="^9.67PA^8989.52^19"
 S YARR(19,0)="""BLD"",5528,""KRN"",.4,0)"
 S YARR(20,0)=".4"
 S YARR(21,0)="""BLD"",5528,""KRN"",.401,0)"
 S YARR(22,0)=".401"
 S YARR(23,0)="""BLD"",5528,""KRN"",.402,0)"
 S YARR(24,0)=".402"
 S YARR(25,0)="""BLD"",5528,""KRN"",.403,0)"
 S YARR(26,0)=".403"
 S YARR(27,0)="""BLD"",5528,""KRN"",.5,0)"
 S YARR(28,0)=".5"
 S YARR(29,0)="""BLD"",5528,""KRN"",.84,0)"
 S YARR(30,0)=".84"
 S YARR(31,0)="""BLD"",5528,""KRN"",3.6,0)"
 S YARR(32,0)="3.6"
 S YARR(33,0)="""BLD"",5528,""KRN"",3.8,0)"
 S YARR(34,0)="3.8"
 S YARR(35,0)="""BLD"",5528,""KRN"",9.2,0)"
 S YARR(36,0)="9.2"
 S YARR(37,0)="""BLD"",5528,""KRN"",9.8,0)"
 S YARR(38,0)="9.8"
 S YARR(39,0)="""BLD"",5528,""KRN"",9.8,""NM"",0)"
 S YARR(40,0)="^9.68A^1^1"
 S YARR(41,0)="""BLD"",5528,""KRN"",9.8,""NM"",1,0)"
 S YARR(42,0)="A1AEUJLI^^0^B52719"
 S YARR(43,0)="""BLD"",5528,""KRN"",9.8,""NM"",""B"",""A1AEUJLI"",1)"
 S YARR(44,0)=""
 S YARR(45,0)="""BLD"",5528,""KRN"",19,0)"
 S YARR(46,0)="19"
 S YARR(47,0)="""BLD"",5528,""KRN"",19.1,0)"
 S YARR(48,0)="19.1"
 S YARR(49,0)="""BLD"",5528,""KRN"",101,0)"
 S YARR(50,0)="101"
 S YARR(51,0)="""BLD"",5528,""KRN"",409.61,0)"
 S YARR(52,0)="409.61"
 S YARR(53,0)="""BLD"",5528,""KRN"",771,0)"
 S YARR(54,0)="771"
 S YARR(55,0)="""BLD"",5528,""KRN"",870,0)"
 S YARR(56,0)="870"
 S YARR(57,0)="""BLD"",5528,""KRN"",8989.51,0)"
 S YARR(58,0)="8989.51"
 S YARR(59,0)="""BLD"",5528,""KRN"",8989.52,0)"
 S YARR(60,0)="8989.52"
 S YARR(61,0)="""BLD"",5528,""KRN"",8994,0)"
 S YARR(62,0)="8994"
 S YARR(63,0)="""BLD"",5528,""KRN"",""B"",.4,.4)"
 S YARR(64,0)=""
 S YARR(65,0)="""BLD"",5528,""KRN"",""B"",.401,.401)"
 S YARR(66,0)=""
 S YARR(67,0)="""BLD"",5528,""KRN"",""B"",.402,.402)"
 S YARR(68,0)=""
 S YARR(69,0)="""BLD"",5528,""KRN"",""B"",.403,.403)"
 S YARR(70,0)=""
 S YARR(71,0)="""BLD"",5528,""KRN"",""B"",.5,.5)"
 S YARR(72,0)=""
 S YARR(73,0)="""BLD"",5528,""KRN"",""B"",.84,.84)"
 S YARR(74,0)=""
 S YARR(75,0)="""BLD"",5528,""KRN"",""B"",3.6,3.6)"
 S YARR(76,0)=""
 S YARR(77,0)="""BLD"",5528,""KRN"",""B"",3.8,3.8)"
 S YARR(78,0)=""
 S YARR(79,0)="""BLD"",5528,""KRN"",""B"",9.2,9.2)"
 S YARR(80,0)=""
 S YARR(81,0)="""BLD"",5528,""KRN"",""B"",9.8,9.8)"
 S YARR(82,0)=""
 S YARR(83,0)="""BLD"",5528,""KRN"",""B"",19,19)"
 S YARR(84,0)=""
 S YARR(85,0)="""BLD"",5528,""KRN"",""B"",19.1,19.1)"
 S YARR(86,0)=""
 S YARR(87,0)="""BLD"",5528,""KRN"",""B"",101,101)"
 S YARR(88,0)=""
 S YARR(89,0)="""BLD"",5528,""KRN"",""B"",409.61,409.61)"
 S YARR(90,0)=""
 S YARR(91,0)="""BLD"",5528,""KRN"",""B"",771,771)"
 S YARR(92,0)=""
 S YARR(93,0)="""BLD"",5528,""KRN"",""B"",870,870)"
 S YARR(94,0)=""
 S YARR(95,0)="""BLD"",5528,""KRN"",""B"",8989.51,8989.51)"
 S YARR(96,0)=""
 S YARR(97,0)="""BLD"",5528,""KRN"",""B"",8989.52,8989.52)"
 S YARR(98,0)=""
 S YARR(99,0)="""BLD"",5528,""KRN"",""B"",8994,8994)"
 S YARR(100,0)=""
 S YARR(101,0)="""BLD"",5528,""QUES"",0)"
 S YARR(102,0)="^9.62^^"
 S YARR(103,0)="""MBREQ"")"
 S YARR(104,0)="0"
 S YARR(105,0)="""PKG"",201,-1)"
 S YARR(106,0)="1^1"
 S YARR(107,0)="""PKG"",201,0)"
 S YARR(108,0)=$P(^DIC(9.4,A1AEPACK,0),U,1,3)
 S YARR(109,0)="""PKG"",201,22,0)"
 S YARR(110,0)="^9.49I^1^1"
 S YARR(111,0)="""PKG"",201,22,1,0)"
 S YARR(112,0)=A1AEVERS
 S YARR(113,0)="""PKG"",201,22,1,""PAH"",1,0)"
 S YARR(114,0)="12^3141110"
 S YARR(115,0)="""PKG"",201,22,1,""PAH"",1,1,0)"
 S YARR(116,0)="^^1^1^3141110"
 S YARR(117,0)="""PKG"",201,22,1,""PAH"",1,1,1,0)"
 S YARR(118,0)="TEST ROUTINE FOR UNIT TESTING A1AE CODE"
 S YARR(119,0)="""QUES"",""XPF1"",0)"
 S YARR(120,0)="Y"
 S YARR(121,0)="""QUES"",""XPF1"",""??"")"
 S YARR(122,0)="^D REP^XPDH"
 S YARR(123,0)="""QUES"",""XPF1"",""A"")"
 S YARR(124,0)="Shall I write over your |FLAG| File"
 S YARR(125,0)="""QUES"",""XPF1"",""B"")"
 S YARR(126,0)="YES"
 S YARR(127,0)="""QUES"",""XPF1"",""M"")"
 S YARR(128,0)="D XPF1^XPDIQ"
 S YARR(129,0)="""QUES"",""XPF2"",0)"
 S YARR(130,0)="Y"
 S YARR(131,0)="""QUES"",""XPF2"",""??"")"
 S YARR(132,0)="^D DTA^XPDH"
 S YARR(133,0)="""QUES"",""XPF2"",""A"")"
 S YARR(134,0)="Want my data |FLAG| yours"
 S YARR(135,0)="""QUES"",""XPF2"",""B"")"
 S YARR(136,0)="YES"
 S YARR(137,0)="""QUES"",""XPF2"",""M"")"
 S YARR(138,0)="D XPF2^XPDIQ"
 S YARR(139,0)="""QUES"",""XPI1"",0)"
 S YARR(140,0)="YO"
 S YARR(141,0)="""QUES"",""XPI1"",""??"")"
 S YARR(142,0)="^D INHIBIT^XPDH"
 S YARR(143,0)="""QUES"",""XPI1"",""A"")"
 S YARR(144,0)="Want KIDS to INHIBIT LOGONs during the install"
 S YARR(145,0)="""QUES"",""XPI1"",""B"")"
 S YARR(146,0)="YES"
 S YARR(147,0)="""QUES"",""XPI1"",""M"")"
 S YARR(148,0)="D XPI1^XPDIQ"
 S YARR(149,0)="""QUES"",""XPM1"",0)"
 S YARR(150,0)="PO^VA(200,:EM"
 S YARR(151,0)="""QUES"",""XPM1"",""??"")"
 S YARR(152,0)="^D MG^XPDH"
 S YARR(153,0)="""QUES"",""XPM1"",""A"")"
 S YARR(154,0)="Enter the Coordinator for Mail Group '|FLAG|'"
 S YARR(155,0)="""QUES"",""XPM1"",""B"")"
 S YARR(156,0)=""
 S YARR(157,0)="""QUES"",""XPM1"",""M"")"
 S YARR(158,0)="D XPM1^XPDIQ"
 S YARR(159,0)="""QUES"",""XPO1"",0)"
 S YARR(160,0)="Y"
 S YARR(161,0)="""QUES"",""XPO1"",""??"")"
 S YARR(162,0)="^D MENU^XPDH"
 S YARR(163,0)="""QUES"",""XPO1"",""A"")"
 S YARR(164,0)="Want KIDS to Rebuild Menu Trees Upon Completion of Install"
 S YARR(165,0)="""QUES"",""XPO1"",""B"")"
 S YARR(166,0)="YES"
 S YARR(167,0)="""QUES"",""XPO1"",""M"")"
 S YARR(168,0)="D XPO1^XPDIQ"
 S YARR(169,0)="""QUES"",""XPZ1"",0)"
 S YARR(170,0)="Y"
 S YARR(171,0)="""QUES"",""XPZ1"",""??"")"
 S YARR(172,0)="^D OPT^XPDH"
 S YARR(173,0)="""QUES"",""XPZ1"",""A"")"
 S YARR(174,0)="Want to DISABLE Scheduled Options, Menu Options, and Protocols"
 S YARR(175,0)="""QUES"",""XPZ1"",""B"")"
 S YARR(176,0)="YES"
 S YARR(177,0)="""QUES"",""XPZ1"",""M"")"
 S YARR(178,0)="D XPZ1^XPDIQ"
 S YARR(179,0)="""QUES"",""XPZ2"",0)"
 S YARR(180,0)="Y"
 S YARR(181,0)="""QUES"",""XPZ2"",""??"")"
 S YARR(182,0)="^D RTN^XPDH"
 S YARR(183,0)="""QUES"",""XPZ2"",""A"")"
 S YARR(184,0)="Want to MOVE routines to other CPUs"
 S YARR(185,0)="""QUES"",""XPZ2"",""B"")"
 S YARR(186,0)="NO"
 S YARR(187,0)="""QUES"",""XPZ2"",""M"")"
 S YARR(188,0)="D XPZ2^XPDIQ"
 S YARR(189,0)="""RTN"")"
 S YARR(190,0)="1"
 S YARR(191,0)="""RTN"",""A1AEUJLI"")"
 S YARR(192,0)="0^1^B52719"
 S YARR(193,0)="""RTN"",""A1AEUJLI"",1,0)"
 S YARR(194,0)="A1AEUJLI ;JLI/VEN - routine for testing A1AE DHCP PATCHES related code ;11/10/14  20:09"
 S YARR(195,0)="""RTN"",""A1AEUJLI"",2,0)"
 S YARR(196,0)=" ;;0.0;PATCH MODULE;"
 S YARR(197,0)="""RTN"",""A1AEUJLI"",3,0)"
 S YARR(198,0)=" ; simply return a value in X for testing."
 S YARR(199,0)="""RTN"",""A1AEUJLI"",4,0)"
 S YARR(200,0)=" S X=""Hello PATCH MODULE World!"""
 S YARR(201,0)="""RTN"",""A1AEUJLI"",5,0)"
 S YARR(202,0)=" Q"
 S YARR(203,0)="""VER"")"
 S YARR(204,0)="8.0^22.0"
 S YARR(205,0)="$END KID "_A1AENMSP_"*"_A1AEVERS_"*912"
 ;  create a mail message far above others in file numbers
 S ^XMB(3.9,A1AEUXMB,0)=A1AENMSP_"*"_A1AEVERS_"*912 MESSAGE^"_DUZ_U_$$NOW^XLFDT()_"^^^^K"
 S ^XMB(3.9,A1AEUXMB,.6)=$P($$NOW^XLFDT(),".")
 S ^XMB(3.9,A1AEUXMB,1)="^3.91A^1^1"
 S ^XMB(3.9,A1AEUXMB,1,1,0)=DUZ_"^0^"_$$NOW^XLFDT()
 S ^XMB(3.9,A1AEUXMB,1,"C",2802,1)=""
 S ^XMB(3.9,A1AEUXMB,2,0)="^3.92A^82^82^"_$P($$NOW^XLFDT(),".")
 M ^XMB(3.9,A1AEUXMB,2)=YARR
 S ^XMB(3.9,A1AEUXMB,6)="^3.911A^1^1"
 S ^XMB(3.9,A1AEUXMB,6,1,0)=$P(^VA(200,DUZ,0),U)
 S ^XMB(3.9,A1AEUXMB,6,"B",$P(^VA(200,DUZ,0),U),1)=""
 S ^A1AE(11005.1,A1AEUPAT,0)=A1AEUPAT
 S ^A1AE(11005,A1AEUPAT,0)=A1AENMSP_"*"_A1AEVERS_"*912^"_A1AEPACK_U_A1AEVERS_"^1^Unit Tests: Testing this one^12^m^v^51^^^3140730^^^^^^"_$P($$FMADD^XLFDT($$NOW^XLFDT(),30),".")_"^^1"
 S ^A1AE(11005,"B",A1AENMSP_"*"_A1AEVERS_"*912",A1AEUPAT)=""
 S ^A1AE(11005,A1AEUPAT,3,0)="^11005.019^1^1"
 S ^A1AE(11005,A1AEUPAT,3,1,0)="TEXT FOR COMPLIANCE DATE COMMENT"
 S ^A1AE(11005,A1AEUPAT,4)="PACKAGETEXT 1"
 ; make an entry for update from package - use first entry that exists
 N A1AEUPDT S A1AEUPDT=$O(^A1AE(11005,0))
 S ^A1AE(11005,A1AEUPAT,5)="1^^^^^^"_A1AEUPDT
 S ^A1AE(11005,A1AEUPAT,"P2")=";;8.0;KERNEL;**71,120,166,168,179,280**;Jul 10, 1995"
 S ^A1AE(11005,A1AEUPAT,"C",0)="^11005.05SA^1^1"
 S ^A1AE(11005,A1AEUPAT,"C",1,0)="r"
 S ^A1AE(11005,A1AEUPAT,"D",0)="^11005.01^2^2^3140918^^^^"
 S ^A1AE(11005,A1AEUPAT,"D",1,0)="Description text line 1 "
 S ^A1AE(11005,A1AEUPAT,"D",2,0)="Description text line 2 "
 S ^A1AE(11005,A1AEUPAT,"P",0)="^11005.03A^2^2"
 S ^A1AE(11005,A1AEUPAT,"P",1,0)="A1AEROU1"
 S ^A1AE(11005,A1AEUPAT,"P",2,0)="A1AEROU2"
 S ^A1AE(11005,A1AEUPAT,"P","B","A1AEROU1",1)=""
 S ^A1AE(11005,A1AEUPAT,"P","B","A1AEROU2",2)=""
 Q
 ;
SHUTDOWN ;
 ; ZEXCEPT: A1AEVIEW - defined outside to save data for examination
 I $D(A1AEVIEW) Q  ; temporary to allow examination of data
 ;
DOITNOW ;  temporary entry to remove data after examination
 N A1AEUXMB,A1AEUPAT,A1AEUBLD,A1AEIEN,A1AEPTID
 S A1AEUXMB=$G(^TMP("A1AEUBL1",$J,"A1AEUXMB"))
 S A1AEUPAT=$G(^TMP("A1AEUBL1",$J,"A1AEUPAT"))
 S A1AEUBLD=$G(^TMP("A1AEUBL1",$J,"A1AEUBLD"))
 S A1AEPTID=$G(^TMP("A1AEUBL1",$J,"A1AEPTID"))
 I A1AEUXMB'>0 Q
 ; remove data created in STARTUP
 K ^XMB(3.9,A1AEUXMB)
 K ^XPD(9.6,A1AEUBLD)
 N A1AENAME S A1AENAME=$P(^A1AE(11005,A1AEUPAT,0),U)
 K ^A1AE(11005,A1AEUPAT)
 K ^A1AE(11005,"B",A1AENAME,A1AEUPAT)
 K ^A1AE(11005.1,A1AEUPAT)
 ; remove data added to the DHCP PATCHES file (#11005)
 S A1AEIEN=$O(^A1AE(11005,"B",A1AEPTID,"")) I A1AEIEN>0 D
 . ; if it still is last entry try to get a lock, if we can, then decrement top numbers for file
 . I A1AEIEN=$P(^A1AE(11005,0),U,3) L +^A1AE(11005,0):0 I $T S $P(^A1AE(11005,0),U,3,4)=($P(^(0),U,3)-1)_U_($P(^(0),U,4)-1)
 . K ^A1AE(11005,"B",A1AEPTID),^A1AE(11005,A1AEIEN)
 . L -^A1AE(11005,0)
 . Q
 ; remove data added to the INSTALL file during installation
 S A1AEIEN=$O(^XPD(9.7,"B",A1AEPTID,"")) I A1AEIEN>0 D
 . I A1AEIEN=$P(^XPD(9.7,0),U,3) L +^XPD(9.7,0):0 I $T S $P(^XPD(9.7,0),U,3,4)=($P(^(0),U,3)-1)_U_($P(^(0),U,4)-1)
 . K ^XPD(9.7,"B",A1AEPTID),^XPD(9.7,A1AEIEN)
 . L -^XPD(9.7,0)
 . ; remove installation data added to ^XTMP
 . K ^XTMP("XPDI",A1AEIEN)
 . Q
 K ^TMP("A1AEUBL1",$J)
 Q
 ;
