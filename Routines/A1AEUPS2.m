A1AEUPS2 ;VEN-LGC/JLI - UNIT TESTS FOR THE PATCH MODULE ; 9/19/14 6:34pm
 ;;2.4;PATCH MODULE;;AUG 26, 2014
 ;
 ;
 ;
 ; Unit Test for Post Install which loads all BUILD [#9.6]
 ;   and INSTALL [#9.7] entries with pointers to 
 ;   DHCP PATCHES [#11005] file in the PAT multiple
 ;   
 ;   1. Lock DHCP PATCHES,BUILD,INSTALL files
 ;
 ;   2. Select 10 patches from DHCP PATCHES [#11005]
 ;       Save in A1AEP array A1AEP(1..10)
 ;       Replace A1AEP(3) with a patch with "1" in version
 ;       Replace A1AEP(10) with patch name  not in DHCP PATCHES
 ;          A1AE*999.1*12345
 ;
 ;       Save in A1AEP array A1AEP(10) *** should NOT build PAT
 ;       >>>>>>>>>>>>>>>>>>>>D SEL10(.A1AEP)
 ;
 ;   3. Install test entries
 ;      a.  Remove any BUILD / INSTALLs we will be testing
 ;       >>>>>>>>>>>>>>>>>> D ENTDEL
 ;
 ;      b.  one build (1) without multiple build [#10] field entries
 ;            BUILD=A1AE*1.0*9999980
 ;               BUILD MULTIPLE
 ;                  A1AEP(1)
 ;      >>>>>>>>>>>>>>>>>> D LOADBLDS
 ;
 ;      c.  one build (2) with multiple build [#10] entries
 ;            BUILD=A1AE MUNITPOO 1.0
 ;               BUILD MULTIPLE
 ;                  A1AEP(2)
 ;                  A1AEP(3)
 ;                  A1AEP(4)
 ;                  A1AEP(5)
 ;                  A1AEP(6)
 ;                  A1AEP(7)
 ;                  A1AEP(8)
 ;      >>>>>>>>>>>>>>>>>> D LOADBLDS
 ;
 ;      d.  One build (3) with multiple build entries - one
 ;          of which is build (2)
 ;            BUILD=A1AE*1.0*9999981
 ;               BUILD MULTIPLE
 ;                  A1AEP(9)
 ;                  A1AEP(10)
 ;                  A1AE MUNITPOO 1.0
 ;      >>>>>>>>>>>>>>>>>> D LOADBLDS
 ;
 ;      e.  two  install (2) which matches build (1)
 ;            INSTALL=A1AE*1.0*9999980
 ;      >>>>>>>>>>>>>>>>>> D LOADINST
 ;
 ;   3. Check new entries match expected
 ;      >>>>>>>>>>>>>>>>>> D CHKIBENT
 ;
 ;   4. Run section of Post Install to be tested
 ;      >>>>>>>>>>>>>>>>>> D RUNPOST
 ;
 ;   5. Run Unit Test to ensure PAT entries correct
 ;      >>>>>>>>>>>>>>>>>> D CHKIBPAT
 ;
 ;   6. Delete builds (1),(2) and (3)
 ;      >>>>>>>>>>>>>>>>>> D ENTDEL
 ;
 ;   7. Release Locks
 ;
 ;
START I $T(^%ut)="" W !,"*** UNIT TEST NOT INSTALLED ***" Q
 D EN^%ut($T(+0),1)
 Q
 ;
STARTUP L +^XPD(9.6):1 I '$T D  Q
 .  W !,"*** COULD NOT GET LOCK ON BUILD [#9.6]  TRY LATER ***"
 L +^XPD(9.7):1 I '$T D  Q
 .  W !,"*** COULD NOT GET LOCK ON INSTALL [#9.7]  TRY LATER ***"
 D ENTDEL I ERRMSG'["OK" D  Q
 . D FAIL^%ut("Unable to clear special 9.6,9.7 entries before test")
 ;
SHUTDOWN L -^XPD(9.6):1
 L -^XPD(9.7):1
 D ENTDEL I ERRMSG'["OK" D  Q
 . D FAIL^%ut("Unable to clear special 9.6,9.7 entries after test")
 Q
 ;
UTP0 N ERRMSG S ERRMSG="OK"
 D SEL10(.A1AEP)
 D LOADBLDS I ERRMSG'["OK" D  Q
 .  D FAIL^%ut(ERRMSG)
 D LOADINST I ERRMSG'["OK" D  Q
 .  D FAIL^%ut(ERRMSG)
 S OK=$$CHKIBENT I OK D  Q
 . D FAIL^%ut("Loading BUILDS and INSTALLS for testing FAILED!")
 ; Run post install to add PAT multiple to new 9.6 and 9.7 entries
 D RUNPOST
 ;  Test whether the post install worked correctly.
 S OK=$$CHKIBPAT
 D CHKEQ^%ut(0,OK,"Setting PAT multiple in 9.6 and 9.7 FAILED")
 Q
 ;
 ; Build an array of entries in DHCP PATCHES [#11005]
SEL10(A1AEP) K A1AEP
 N A1AEPM,ACNT S ACNT=0,A1AEPM="DG"
 F  S A1AEPM=$O(^A1AE(11005,"B",A1AEPM)) Q:'$L(A1AEPM)  D  Q:ACNT>9
 .  S A1AEPI=$O(^A1AE(11005,"B",A1AEPM,0))
 .  Q:'A1AEPI
 .  S ACNT=$G(ACNT)+1,A1AEP(ACNT)=A1AEPM_"^"_A1AEPI
 .  Q:ACNT>9
 S A1AEPI=0,A1AEPM=""
 F  S A1AEPM=$O(^A1AE(11005,"B",A1AEPM)) Q:A1AEPM=""  D  Q:A1AEPI
 . I $P(A1AEPM,"*",2)="1" S A1AEPI=$O(^A1AE(11005,"B",A1AEPM,0))
 I A1AEPI S $P(A1AEPM,"*",2)="1.0" D
 .  S A1AEP(3)=A1AEPM_"^"_A1AEPI
 S A1AEP(10)="A1AE*999.1*12345"
 Q
 ;
 ;
 ;
ENTDEL N PM
 D RMVENT(9.6,"A1AE*1.0*9999980",.ERRMSG) Q:$G(ERRMSG)'["OK"
 D RMVENT(9.6,"A1AE MUNITPOO 1.0",.ERRMSG) Q:$G(ERRMSG)'["OK"
 D RMVENT(9.6,"A1AE*1.0*9999981",.ERRMSG) Q:$G(ERRMSG)'["OK"
 D RMVENT(9.7,"A1AE*1.0*9999980",.ERRMSG) Q:$G(ERRMSG)'["OK"
 Q
 ;
 ; Remove all entries with this PATCH DESIGNATION
RMVENT(KFILE,PM,ERRMSG) ;
 N DA,DIERR,DIK K ERRMSG S ERRMSG="OK"
 F  S DA=$O(^XPD(KFILE,"B",PM,0)) Q:'DA  D  Q:ERRMSG["DIERR"
 .  S DIK="^XPD("_KFILE_","
 .  D ^DIK
 .  S:$D(DIERR) ERRMSG="DIERR"
 Q
 ;
 ; Load the necessary BUILDS
 ;
LOADBLDS N PTCHARR,PM
 S PM="A1AE*1.0*9999980"
 S PTCHARR(1)=$P(A1AEP(1),"^")
 S PTCHARR(2)="A1AE MUNITPOO 1.0"
 D LDBLDS(9.6,PM,.PTCHARR) Q:ERRMSG'["OK"
 ;
 K PTCHARR
 S PM="A1AE MUNITPOO 1.0"
 F I=2:1:8 S PTCHARR(I)=$P(A1AEP(I),"^")
 D LDBLDS(9.6,PM,.PTCHARR) Q:ERRMSG'["OK"
 ;
 K PTCHARR
 S PM="A1AE*1.0*9999981"
 F I=9:1:10 S PTCHARR(I)=$P(A1AEP(I),"^")
 D LDBLDS(9.6,PM,.PTCHARR) Q:ERRMSG'["OK"
 Q
 ;
 ;
LOADINST N PM
 S PM="A1AE*1.0*9999980"
 D LDINST(9.7,PM) Q:ERRMSG'["OK"
 D LDINST(9.7,PM) Q:ERRMSG'["OK"
 Q
 ;
 ;
 ;
LDBLDS(KFILE,PM,PTCHARR) ;
 N A1AEKI,A1AEPM,DIERR,FDA,FIEN
 ;W !,"PM=",PM
 S FDA(3,KFILE,"?+1,",.01)=PM
 S FDA(3,KFILE,"?+1,",2)=0
 S FDA(3,KFILE,"?+1,",.02)=$$HTFM^XLFDT($H,1)
 S FDA(3,KFILE,"?+1,",5)="n"
 D UPDATE^DIE("","FDA(3)","FIEN")
 I $D(DIERR) D  Q
 . S ERRMSG="*** DIERR encountered while attempting to enter BUILDS!"
 S A1AEKI=+FIEN(1)
 I A1AEKI D  Q:$G(ERRMSG)'["OK"
 . N PTCHS S PTCHS=0
 . F  S PTCHS=$O(PTCHARR(PTCHS)) Q:'PTCHS  D  Q:$G(ERRMSG)'["OK"
 .. S A1AEPM=PTCHARR(PTCHS)
 .. D LDBLDS1(A1AEKI,A1AEPM,9.63)
 Q
 ;
LDBLDS1(A1AEKI,A1AEPM,KSFILE) ;
 N FDA,DIERR
 S FDA(3,KSFILE,"?+1,"_A1AEKI_",",.01)=A1AEPM
 D UPDATE^DIE("","FDA(3)","")
 I $D(DIERR) D  Q
 . S ERRMSG="*** DIERR encountered while entering MULTIPLE BUILDS!"
 Q
 ;
 ;
 ;
LDINST(KFILE,PM) ;
 N FDA,DIERR
 S FDA(3,KFILE,"+1,",.01)=PM
 S FDA(3,KFILE,"+1,",.02)=3
 S FDA(3,KFILE,"+1,",2)=$$HTFM^XLFDT($H)
 D UPDATE^DIE("","FDA(3)","")
 I $D(DIERR) D  Q
 . S ERRMSG="*** DIERR encountered while entering MULTIPLE INSTALLS!"
 Q
 ;
 ; Run post install subroutine which builds
 ;  the BUILD [#9.6] and INSTALL [#9.7] PAT [#19] multiple
RUNPOST ;
 N KIEN S KIEN=$O(^XPD(9.6,"B","A1AE*1.0*9999980",0))
 S BN="A1AE*1.0*9999980"
 N BMARR D A1AEP2A^A1AE2POS(BN,.BMARR,KIEN)
 Q
 ;
 ; **************** CHK BLD/INS INIT ENTRIES START
 ; Check BUILD's and INSTALL's entries Multiple Builds
 ; BUILDS (1st piece of A1AEP(n)=PM)
 ;   A1AE*1.0*9999980
 ;     A1AEP(1)
 ;     A1AE MUNITPOO 1.0
CHKIBENT() N BLDNM,MB,OK
 S BLDNM="A1AE*1.0*9999980"
 S MB(1)=$P(A1AEP(1),"^")
 S MB(1)="A1AE MUNITPOO 1.0"
 S OK=$$CHKB0(BLDNM,.MB)
 ;W !,"A1AE*1.0*9999980"," OK=",OK
 Q:OK
 ;
 ;   A1AE MUNITPOO 1.0
 ;     A1AE(2)-A1AE(8)
 S BLDNM="A1AE MUNITPOO 1.0"
 K MB N I F I=2:1:8 S MB(I)=$P(A1AEP(I),"^")
 S OK=$$CHKB0(BLDNM,.MB)
 ;W !,"A1AE MUNITPOO 1.0"," OK=",OK
 Q:OK OK
 ;
 ;   A1AE*1.0*9999981
 ;     A1AE(9)-A1AE(10)
 S BLDNM="A1AE*1.0*9999981"
 K MB N I F I=9:1:10 S MB(I)=$P(A1AEP(I),"^")
 S OK=$$CHKB0(BLDNM,.MB)
 ;W !,"A1AE*1.0*9999981"," OK=",OK
 Q:OK OK
 ;
 ; INSTALLS (1st piece of A1AEP(n)=PM)
 ;   A1AE*1.0*9999980
 ;   A1AE*1.0*9999980
 S OK=$$CHKI0("A1AE*1.0*9999980")
 ;W !,"A1AE*1.0*9999980 INSTALLS"," OK=",OK
 Q:'OK OK
 Q 1
 ;
 ; Check BUILD entry and Multiple Build entries OK
 ; ENTER
 ;   BLDNM  = BUILD name
 ;   MB   = Array of Multiple Builds associated
 ; EXIT
 ;   0 = all OK
 ;   1 = fail
CHKB0(BLDNM,MB) N A1AEI,BIEN,OK S OK=0
 S A1AEI=$O(^XPD(9.6,"B",BLDNM,0)) Q:'A1AEI A1AEI
 S BIEN=0 F  S BIEN=$O(MB(BIEN)) Q:'BIEN  D  Q:'OK
 . S OK=$O(^XPD(9.6,A1AEI,10,"B",MB(BIEN),0))
 Q:'OK 1  Q:'BIEN 0
 ;
 ; Check INSTALL entry OK
 ; ENTER
 ;   INSTNM  = INSTALL name
 ; EXIT
 ;   0 = all OK
 ;   1 = fail
CHKI0(INSTNM) ;
 Q:$O(^XPD(9.7,"B",INSTNM,0)) 0
 Q 1
 ; **************** CHK BLD/INS INIT ENTRIES END
 ;
 ;
 ; **************** CHK BLD/INS FOR PAT START
CHKIBPAT() ;
 ; Check BUILD's and INSTALL's entries for PAT
 ; BUILDS (1st piece of A1AEP(n)=PM)
 ; INSTALLS (2nd piece of A1AEP(n)=A1AEPI (IEN 11005)
 ;   A1AE*1.0*9999980
 ;     A1AEP(1)
 ;     A1AE MUNITPOO 1.0
 N FILENBR,BINAME,PTCHS
 S FILENBR=9.6
 S BINAME="A1AE*1.0*9999980"
 N I F I=1:1:8 S PTCHS(I)=+$P(A1AEP(1),"^",2)
 S OK=$$CHKIBP(FILENBR,BINAME,.PTCHS)
 ;W !,"A1AE*1.0*9999980 PAT BLD","OK=",OK
 Q:ERRMSG'["OK" 1
 ;
 ;   A1AE*1.0*9999980
 ;     A1AEP(1)
 ;     A1AE MUNITPOO 1.0
 S FILENBR=9.7
 S BINAME="A1AE*1.0*9999980"
 K PTCHS F I=1:1:8 S PTCHS(I)=+$P(A1AEP(1),"^",2)
 S OK=$$CHKIBP(FILENBR,BINAME,.PTCHS)
 ;W !,"A1AE*1.0*9999980 PAT INSTS","OK=",OK
 Q:ERRMSG'["OK" 1
 ;
 ;   A1AE MUNITPOO 1.0
 ;     A1AE(2)-A1AE(8)
 S FILENBR=9.6
 S BINAME="A1AE MUNITPOO 1.0"
 K PTCHS F I=2:1:8 S PTCHS(I)=+$P(A1AEP(1),"^",2)
 S OK=$$CHKIBP(FILENBR,BINAME,.PTCHS)
 ;W !,"A1AE MUNITPOO 1.0 PAT BLD","OK=",OK
 Q:ERRMSG'["OK" 1
 ;
 ;   A1AE*1.0*9999981
 ;     A1AE(9)-A1AE(10)
 S FILENBR=9.6
 S BINAME="A1AE*1.0*9999981"
 S PTCHS(9)=$P(A1AEP(9),"^")
 S OK=$$CHKIBP(FILENBR,BINAME,.PTCHS)
 ;W !,"A1AE*1.0*9999981 PAT BLD","OK=",OK
 Q:ERRMSG'["OK" 1
 Q 0
 ;
 ; Check INSTALL/BUILD entry PAT multiples OK
 ; ENTER
 ;   BINAME = BUILD/INSTALL name
 ;   PTCHS  = Array of Patches IEN's associated
 ;   FILENB = 9.6 for BUILD, 9.7 for INSTALL
 ; EXIT
 ;   0 = all OK
 ;   1 = fail
CHKIBP(FILENBR,BINAME,PTCHS) N A1AEI,BIEN,OK S OK=0
 S A1AEI=$O(^XPD(FILENBR,"B",BINAME,0)) Q:'A1AEI A1AEI
 S BIEN=0 F  S BIEN=$O(PTCHS(BIEN)) Q:'BIEN  D  Q:'OK
 . S OK=$O(^XPD(FILENBR,A1AEI,"PAT","B",PTCHS(BIEN),0))
 Q:'OK 1  Q:'BIEN 0
 ; **************** CHK BLD/INS FOR PAT END
 ;
 ;
XTENT ;
 ;;UTP0;Testing post install setting 9.6, 9.7 PAT multiple
 Q
EOR ; end of routine A1AEUPS2
