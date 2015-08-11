A1AEUBLD ;ven/jli-unit tests related to transport of entries in builds  ;2015-06-02T22:51
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ; This is a unit test for Forum Server systems
        I '$D(^DIC(9.4,"B","PATCH MODULE")) Q  ;
        D EN^%ut($T(+0))
 Q
 ;
VERBOSE ;
 ; This is a unit test for Forum Server systems
        I '$D(^DIC(9.4,"B","PATCH MODULE")) Q  ;
        D EN^%ut($T(+0),1)
 Q
 ;
STARTUP ; this will build data set to work from
 D STARTUP^A1AEUBL1
 Q
 ;
SHUTDOWN ; this will remove data added in STARTUP
 D SHUTDOWN^A1AEUBL1
 Q
 ;
BUILDGLO ;@TEST test global build structure
 N BUILDIEN,PATCHIEN,GLOBLOC,NAME,PKG,DDATA,TRANDATA,TRANNAME,TRANPKG
 S BUILDIEN=^TMP("A1AEUBL1",$J,"A1AEUBLD")
 S PATCHIEN=^TMP("A1AEUBL1",$J,"A1AEUPAT")
 S GLOBLOC=$NA(^XTMP("A1AEBLD",$J,PATCHIEN,"PATCHES"))
 ;
 K @GLOBLOC
 D BUILDGLO^A1AEBLD(PATCHIEN,GLOBLOC)
 ;
 S NAME=$P(^A1AE(11005,PATCHIEN,0),U)
 S TRANNAME=$G(@GLOBLOC@("FLDS",.01))
 D CHKEQ(NAME,TRANNAME,"Incorrect first piece of zero node (NAME)")
 ;
 S PKG=$P(^A1AE(11005,PATCHIEN,0),U,2),PKG=$P($G(^DIC(9.4,+PKG,0)),U)
 S TRANPKG=$G(@GLOBLOC@("FLDS",2))
 D CHKEQ(PKG,TRANPKG,"Incorrect value for external value for pointer")
 ;
 S DDATA=$G(^A1AE(11005,PATCHIEN,"P",1,0))
 S TRANDATA=$G(@GLOBLOC@("MULT","P",1,0))
 D CHKEQ(DDATA,TRANDATA,"Incorrect data string from node ""P""")
 ;
 ;K ^XTMP(GLOBLOC,BUILDIEN)
 Q
 ;
GETIEN ; @TEST get IEN for specified NAME (.01 field value) in file FILE
 N IENVAL,NAME,IEN
 ; just pick an entry and make sure we get back the correct ien for name field
 S IENVAL=$O(^VA(200,1)) Q:IENVAL'>0  S NAME=$P(^VA(200,IENVAL,0),U) D
 . S IEN=$$GETIEN^A1AEBLD(200,NAME)
 . D CHKEQ(IENVAL,IEN,"DID NOT FIND IEN FOR SPECIFIED USER NAME")
 . Q
 Q
 ;
NOTEXIST ; @TEST value for GETIEN for nonexistent patch name
 N NONNAME,IEN
 S NONNAME="XXX?YY?ZZ"
 F  Q:'$D(^A1AE(11005,"B",NONNAME))  S NONNAME=NONNAME_"B"
 S IEN=$$GETIEN^A1AEBLD(11005,NONNAME)
 I +IEN'=0 D FAIL("GETIEN returned an IEN for a non-existent name")
 Q
 ;
GETNODES ; @TEST get list of nodes to be transferred
 N NODES
 D GETNODES^A1AEBLD(.NODES)
 D CHKTF(NODES(0)[";102","Returned zero node didn't contain ;102 but was "_$G(NODES(0)))
 D CHKEQ(".01;.2;2;3;4;5;6;7;18;40;5.7;102",NODES(0),"Incorrect value for node 0 returned: "_NODES(0))
 D CHKTF('$D(NODES(2)),"Should not have returned a value for NODE 2")
 D CHKTF($D(NODES(3)),"Failed to return a value for node 3")
 Q
 ;
CHKDATA ;@TEST get data for specific node
 N I,IEN,NODES,RETURN,X
 F IEN=0:0 S IEN=$O(^A1AE(11005,IEN)) Q:IEN'>0  I $D(^(IEN,"P"))>1 Q
        I IEN'>0 Q
 D GETNODES^A1AEBLD(.NODES)
 D GETDATA^A1AEBLD(.RETURN,11005,IEN,NODES(0))
 D CHKTF($D(RETURN(0)),"NO DATA RETURNED FROM COPYNODE FOR NODE 0")
 D CHKEQ($P(^A1AE(11005,IEN,0),U),RETURN(0,"FLDS",.01),"Incorrect value for 1st piece of zero node")
 D CHKEQ($P(^DIC(9.4,+$P(^A1AE(11005,IEN,0),U,2),0),U),RETURN(0,"FLDS",2),"Incorrect external value for piece 2 of zero node")
 F I=8:1:17 S X=$P(^A1AE(11005,IEN,0),U,I) Q:X'=""
 I X'="" D CHKTF($G(RETURN(0,"FLDS",I))="","Data at node 0, piece "_I_" is being transported that shouldn't be")
 D GETMULT^A1AEBLD(.RETURN,IEN,"P")
 D CHKTF($D(RETURN("P"))>1,"Expected multiple not returned for node ""P""")
 Q
 ;
GETMULT ; @TEST return multiple values
 N DONE,IEN,NODE,RETURN,SIEN,SUBS1,VAL1,VAL2,X,XNODE
 S DONE=0 F IEN=0:0 Q:DONE  S IEN=$O(^A1AE(11005,IEN)) Q:IEN'>0  S NODE="" D
 . F  Q:DONE  S NODE=$O(^A1AE(11005,IEN,NODE)) Q:NODE=""  I $D(^(NODE))>1 S SIEN="" D
 . . F  S SIEN=$O(^A1AE(11005,IEN,NODE,SIEN)) Q:SIEN=""  I SIEN>0 S DONE=1 Q
 . . Q
 . Q
 I (IEN'>0)!(NODE="")!(SIEN="") Q
 M X(NODE)=^A1AE(11005,IEN,NODE)
 D GETMULT^A1AEBLD(.RETURN,IEN,NODE)
 S XNODE="X" F  S XNODE=$Q(@XNODE) Q:XNODE=""  D
 . S SUBS1=$P(XNODE,"X(",2,99),VAL1=@XNODE
 . S VAL2=$G(@("RETURN("""_NODE_""",""MULT"","_SUBS1))
 . D CHKTF($D(@("RETURN("""_NODE_""",""MULT"","_SUBS1))=1,"Incorrect match expected node at RETURN("_SUBS1)
 . D CHKEQ(VAL1,VAL2,"Incorrect data returned for RETURN("_SUBS1)
 . Q
 Q
 ;
GETBASE ; @TEST Check return of base location for install
 N TESTNAME,TESTIEN,TESTBLD,TESTRSLT,TESTVAL
 ; create a non-existent patch number, use routine name and DUZ
 S TESTNAME="A1AEUBLD"_DUZ_"*1.2*54"
 ; check for failure return if doesn't exist
 K ^XPD(9.7,"B",TESTNAME)
 S TESTVAL=$$GETBASE^A1AEBLD(.TESTRSLT,TESTNAME)
 D CHKTF(TESTVAL=0,"Did not indicate failure if no INSTALL entry present")
 ; create a "B" cross reference for a non-existent patch id in a high number for the INSTALL file (#9.7)
 S TESTIEN=$P(^XPD(9.7,0),U,3)+100 F  Q:'$D(^XPD(9.7,TESTIEN))  S TESTIEN=TESTIEN+1
 S ^XPD(9.7,"B",TESTNAME,TESTIEN)=""
 K ^XTMP("XPDI",TESTIEN)
 S TESTVAL=$$GETBASE^A1AEBLD(.TESTRSLT,TESTNAME)
 D CHKTF(TESTVAL=0,"Did not indicate failure if INSTALL entry present, but no entry in ^XTMP(""XPDI""")
 ; create a dummy XPDI entry
 S ^XTMP("XPDI",TESTIEN,"PATCHES",14)=""
 S TESTVAL=$$GETBASE^A1AEBLD(.TESTRSLT,TESTNAME)
 I TESTVAL>0 D CHKEQ(TESTRSLT,$NA(^XTMP("XPDI",TESTIEN,"PATCHES")),"Incorrect value returned")
 K ^XTMP("XPDI",TESTIEN,"PATCHES")
 ; create a dummy "B" cross reference in BUILD file (#9.6)
 S TESTBLD=$P(^XPD(9.6,0),U,3)+100
 S ^XPD(9.6,"B",TESTNAME,TESTBLD)=""
 S ^XTMP("XPDI",TESTBLD,"PATCHES",14)=""
 S TESTVAL=$$GETBASE^A1AEBLD(.TESTRSLT,TESTNAME)
 I TESTVAL>0 D CHKEQ(TESTRSLT,$NA(^XTMP("XPDI",TESTIEN,"BLD",TESTBLD,"PATCHES")),"Incorrect value after BUILD number returned")
 ; and clean up
 K ^XPD(9.7,"B",TESTNAME,TESTIEN),^XPD(9.6,"B",TESTNAME,TESTBLD),^XTMP("XPDI",TESTIEN,"BLD",TESTBLD,"PATCHES",14)
 Q
 ;
CHKPACKG ; @TEST Check for PACKAGE entry present, if not add it
 N A1AEBASE,A1AEIEN,DA,DIE,DR,PACKGNAM
 ; setup
 L +^DIC(9.4):0 I '$T W !,"Unable to get Lock on PACKAGE file (#9.4)" Q
 S PACKGNAM="A1AE"_DUZ
 S A1AEBASE=$NA(^XTMP("XPDI","A1AE"_$J,"PATCHES")) K @A1AEBASE
 S @A1AEBASE@("FLDS",2)=PACKGNAM
 S @A1AEBASE@(9.4,"FLDS",.01)=PACKGNAM
 S @A1AEBASE@(9.4,"FLDS",1)="ZZA" ; PREFIX
 S @A1AEBASE@(9.4,"FLDS",2)="TEST PACKAGE NAME" ; SHORT DESCRIPTION
 ; perform action
 D CHKPACKG^A1AEBLD(A1AEBASE)
 ; and run tests
 S A1AEIEN=$O(^DIC(9.4,"B",PACKGNAM,""))
 D CHKTF(A1AEIEN>0,"No IEN found for new PACKAGE file entry, update failed") I A1AEIEN>0 D
 . D CHKEQ(PACKGNAM_"^ZZA^TEST PACKAGE NAME",$P($G(^DIC(9.4,A1AEIEN,0)),U,1,3),"Incorrect data present after update")
 . S DIK="^DIC(9.4,",DA=A1AEIEN D ^DIK
 . Q
 K @A1AEBASE
 L -^DIC(9.4)
 Q
 ;
CHKSTREM ; @TEST Check for STREAM entry present, if not add it
 N A1AEBASE,A1AEIEN,DA,DIE,DR,STRMNAME,A1AEORIG
 L +^A1AE(11007.1):0 I '$T W !,"Unable to get Lock on DHCP PATCH STREAM file (#11007.1)",! Q
 S STRMNAME="A1AE"_DUZ
 S A1AEBASE=$NA(^XTMP("XPDI","A1AE"_$J,"PATCHES")) K @A1AEBASE
 S @A1AEBASE@("FLDS",.2)=STRMNAME
 S @A1AEBASE@(11007.1,"FLDS",.001)=20001
 S @A1AEBASE@(11007.1,"FLDS",.01)=STRMNAME
 S @A1AEBASE@(11007.1,"FLDS",.02)="NO" ; PRIMARY
 S @A1AEBASE@(11007.1,"FLDS",.05)="UU" ; ABBREVIATION
 ;S @A1AEBASE@(11007.1,"FLDS",.06)="NO" ; SUBSCRIPTION
 S A1AEORIG=^A1AE(11007.1,0)
 ;
 D CHKSTREM^A1AEBLD(A1AEBASE)
 ;
 S A1AEIEN=$O(^A1AE(11007.1,"B",STRMNAME,""))
 D CHKTF(A1AEIEN>0,"No IEN found for new DHCP PATCH STREAM entry, update failed") I A1AEIEN>0 D
 . D CHKEQ(STRMNAME_"^0^^^UU",$P($G(^A1AE(11007.1,A1AEIEN,0)),U,1,6),"Incorrect data present after update")
 . Q
 I ^A1AE(11007.1,0)'=A1AEORIG S DA=+$P(^A1AE(11007.1,0),U,3) I $P(^A1AE(11007.1,DA,0),U)=STRMNAME D
 . K ^A1AE(11007.1,DA)
 . K ^A1AE(11007.1,"B",STRMNAME)
 . K ^A1AE(11007.1,"C","UU")
 . S ^A1AE(11007.1,0)=A1AEORIG
 . Q
 L -^A1AE(11007.1)
 K @A1AEBASE
 Q
 ;
UPDATFIL ; @TEST
        N A1AEBASE,A1AEPTID,A1AETEST,A1AETSTL,A1AEIEN,PATMOD,A1AEZERO,A1AEVAL
 ;
 S A1AEBASE=$NA(^XTMP("XPDI","A1"_$J,"PATCHES"))
 D SETDATA(A1AEBASE)
 S A1AEPTID=@A1AEBASE@("FLDS",.01)
 ;
 D UPDATFIL^A1AEBLD(A1AEBASE)
 ; remove .0 from version number if present
        S A1AETEST=$P(A1AEPTID,"*",2),A1AETSTL=$L(A1AETEST) I $E(A1AETEST,A1AETSTL-1,A1AETSTL)=".0" S A1AEPTID=$P(A1AEPTID,"*")_"*"_$E(A1AETEST,1,A1AETSTL-2)_"*"_$P(A1AEPTID,"*",3,99)
        ;
 S A1AEIEN=$O(^A1AE(11004,"B",A1AEPTID,0))
 D CHKTF(A1AEIEN>0,"No B x-ref for new entry in DHCP PATCHES file")
 I A1AEIEN>0 D
 . S PATMOD=$O(^DIC(9.4,"B","PATCH MODULE",0))
 . S A1AEZERO=^A1AE(11004,A1AEIEN,0)
 . D CHKEQ($P(A1AEZERO,U,1,7),A1AEPTID_U_PATMOD_"^1.0^1^Unit Tests: Testing this one^12^m","Not the expected values for pieces 1 to 7 of zero node")
 . S A1AEVAL=$$FMTE^XLFDT($P(A1AEZERO,U,18))
 . D CHKEQ(@A1AEBASE@("FLDS",18),A1AEVAL,"FileMan date ("_$P(A1AEZERO,U,18)_") on conversion to external value didn't match input")
 . N STREAM S STREAM=$O(^A1AE(11007.1,"B","FOIA VISTA",0))
 . D CHKEQ($P(A1AEZERO,U,20),STREAM,"Incorrect entry for DHCP PATCH STREAM")
 . N PATCH S PATCH=@A1AEBASE@("FLDS",5.7)
 . N PATCHIEN S PATCHIEN=$O(^A1AE(11004,"B",PATCH,0))
 . D CHKEQ(PATCHIEN,$P($G(^A1AE(11004,A1AEIEN,5)),U,7),"Incorrect value for UPDATE TO PATCH field")
 . D CHKEQ(@A1AEBASE@("FLDS",40),$P($G(^A1AE(11004,A1AEIEN,4)),U),"Incorrect value for NEW PACKAGE field")
 . D CHKEQ(@A1AEBASE@("FLDS",102),$P($G(^A1AE(11004,A1AEIEN,"P2")),U),"Incorrect value for SECOND LINE field")
 . D CHKEQ(@A1AEBASE@("MULT",3,0),$G(^A1AE(11004,A1AEIEN,3,0)),"Incorrect value for zero node of subfile 11004.19")
 . D CHKEQ(@A1AEBASE@("MULT",3,1,0),$G(^A1AE(11004,A1AEIEN,3,1,0)),"Incorrect data entry in subfile 11004.19")
 . D CHKEQ(@A1AEBASE@("MULT","C",0),$G(^A1AE(11004,A1AEIEN,"C",0)),"Incorrect value for zero node of subfile 11004.05")
 . D CHKEQ(@A1AEBASE@("MULT","C",1,0),$G(^A1AE(11004,A1AEIEN,"C",1,0)),"Incorrect data entry in subfile 11004.05")
 . D CHKEQ(@A1AEBASE@("MULT","D",0),$G(^A1AE(11004,A1AEIEN,"D",0)),"Incorrect value for zero node in subfile 11004.01")
 . D CHKEQ(@A1AEBASE@("MULT","D",2,0),$G(^A1AE(11004,A1AEIEN,"D",2,0)),"Incorrect data for second line in subfile 11004.01")
 . D CHKEQ(@A1AEBASE@("MULT","P",0),$G(^A1AE(11004,A1AEIEN,"P",0)),"Incorrect value for zero node in subfile 11004.03")
 . D CHKEQ(@A1AEBASE@("MULT","P",2,0),$G(^A1AE(11004,A1AEIEN,"P",2,0)),"Incorrect data for second line in subfile 11004.03")
 . D CHKTF($D(^A1AE(11004,A1AEIEN,"P","B","A1AEROU2",2)),"Incorrect or missing x-ref for A1AEROU2 in subfile 11004.03")
 . ; and remove data added
 . N DIK,DA S DIK="^A1AE(11004,",DA=A1AEIEN D ^DIK
 . Q
 K @A1AEBASE
 Q
 ;
SETDATA(A1AEBASE) ; setup data for UPDATFIL testing
 S @A1AEBASE@("FLDS",.01)="A1AE*1.0*915"
 S @A1AEBASE@("FLDS",.2)="FOIA VISTA"
 S @A1AEBASE@("FLDS",2)="PATCH MODULE"
 S @A1AEBASE@("FLDS",3)="1.0"
 S @A1AEBASE@("FLDS",4)="1"
 S @A1AEBASE@("FLDS",5)="Unit Tests: Testing this one"
 S @A1AEBASE@("FLDS",5.7)="DI*22.2*10001"
 S @A1AEBASE@("FLDS",6)="12"
 S @A1AEBASE@("FLDS",7)="MANDATORY"
 S @A1AEBASE@("FLDS",18)=$$FMTE^XLFDT($P($$FMADD^XLFDT($$NOW^XLFDT(),30),"."))
 S @A1AEBASE@("FLDS",40)="TEST 1.0"
 S @A1AEBASE@("FLDS",102)=";;8.0;KERNEL;**71,120,166,168,179,280**;Jul 10, 1995"
 S @A1AEBASE@("MULT",3,0)="^11004.019^1^1"
 S @A1AEBASE@("MULT",3,1,0)="TEXT FOR COMPLIANCE DATE COMMENT"
 S @A1AEBASE@("MULT","C",0)="^11004.05SA^1^1"
 S @A1AEBASE@("MULT","C",1,0)="r"
 S @A1AEBASE@("MULT","D",0)="^11004.01^2^2^3140918^^^^"
 S @A1AEBASE@("MULT","D",1,0)="Description text line 1 "
 S @A1AEBASE@("MULT","D",2,0)="Description text line 2 "
 S @A1AEBASE@("MULT","P",0)="^11004.03A^2^2"
 S @A1AEBASE@("MULT","P",1,0)="A1AEROU1"
 S @A1AEBASE@("MULT","P",2,0)="A1AEROU2"
 S @A1AEBASE@("MULT","P","B","A1AEROU1",1)=""
 S @A1AEBASE@("MULT","P","B","A1AEROU2",2)=""
 Q
 ;
CHKEQ(ACT,VAL,COMMENT) ;
 D CHKEQ^%ut(ACT,VAL,COMMENT)
 Q
 ;
CHKTF(TFVALUE,COMMENT) ;
 D CHKTF^%ut(TFVALUE,COMMENT)
 Q
 ;
FAIL(COMMENT) ;
 D FAIL^%ut(COMMENT)
 Q
 ;
