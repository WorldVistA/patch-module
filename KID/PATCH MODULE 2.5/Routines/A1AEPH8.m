A1AEPH8 ;ven/toad-option copy a patch [A1AE COPY PATCH] ;2015-05-30T13:00
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;
 ; primary change history:
 ;
 ; originally created by Robin M. Ostrander of VA Information Systems
 ; Center Albany (isa/rmo)
 ;
 ; 1987-11-24, isa/rmo: added logic to copy 11005.1 if present, PCOPY
 ;
 ; 1992-11-23: released as part of version 2.2
 ;
 ; 2014-03-28: released as part of version 2.4
 ;
 ; 2015-05-29/30, ven/toad: refactored by Rick Marshall of the VISTA
 ; Expertise Network (ven/toad) during testing of version 2.5
 ;
 ;
 ; contents:
 ;
 ; OPTION: option copy a patch into a new patch [A1AE COPY PATCH]
 ; PICKPAT: select patch
 ; CONFIRM: confirm patch selection
 ; PICKVER: select version
 ; PCOPY: copy patch message/payload (11005.1)
 ; CRE8MSG: create patch-msg stub record
 ; COPYTXT: create patch-msg text
 ; EDITPAT: edit new patch
 ; Q: cleanup
 ;
 ;
OPTION ; option copy a patch into a new patch [A1AE COPY PATCH]
 ;private;procedure;clean?;silent?;sac-compliant?
 ; called by:
 ;   5^A1AEPH1
 ;
 ;
 ; 1. make a copy of a patch (11005)
 ;
 ;
 ; 1.a. select & confirm patch to copy
 ;
 NEW A1AEIFN SET A1AEIFN=0 ; original patch #
 NEW A1AEOLPD ; original patch id
 NEW A1AEPKIF ; original patch's application
 NEW A1AEVR ; original patch's application version
 NEW A1AEQUIT SET A1AEQUIT=0 ; give up and quit?
 ;
 FOR  DO  QUIT:A1AEQUIT!A1AEIFN
 . ; select patch:
 . DO PICKPAT(.A1AEIFN,.A1AEOLPD,.A1AEPKIF,.A1AEVR,.A1AEQUIT)
 . QUIT:A1AEQUIT
 . DO CONFIRM(.A1AEIFN,.A1AEOLPD,.A1AEQUIT) ; confirm selection
 . QUIT
 ;
 IF A1AEQUIT DO  QUIT  ; exit option
 . DO Q ; cleanup
 . QUIT
 ;
 ; 1.b. identify selected patch's application
 ;
 IF $DATA(^DIC(9.4,A1AEPKIF,0)) D  ; file package (9.4)
 . SET A1AEPKNM=$PIECE(^(0),U) ; field name (.01)
 . SET A1AEPK=$PIECE(^(0),U,2) ; field prefix (1)
 . QUIT
 ;
 IF '$DATA(A1AEPK) DO  QUIT  ; no application, exit option
 . DO Q ; cleanup
 . QUIT
 ;
 ; 1.c. copy patch to ^utility
 ;
 WRITE !!?3,"...copying ",A1AEOLPD," patch into utility global"
 DO
 . KILL ^UTILITY($JOB,"A1AECOP")
 . NEW %X SET %X="^A1AE(11005,A1AEIFN,"
 . NEW %Y SET %Y="^UTILITY($JOB,""A1AECOP"","
 . DO %XY^%RCR
 . QUIT
 ;
 ;
 ; 2. create a new patch from the copy of the original patch
 ;
 ;
 ; 2.a. select an application version to patch
 ;
 NEW A1AEFL SET A1AEFL=11005 ; we're going to work on patches
 NEW A1AETY SET A1AETY="PH" ; and on the next patch number
 D PICKVER(.A1AEVR,A1AEFL,A1AETY,A1AEPKIF,A1AEPKNM,A1AEOLPD,.A1AEQUIT)
 IF A1AEQUIT DO  QUIT  ; exit option
 . DO Q ; cleanup
 . QUIT
 ;
 ; 2.b. create new patch
 ;
 DO NUM^A1AEUTL ; create new patch
 IF '$DATA(A1AEPD) DO  QUIT
 . DO Q
 . QUIT
 ;
 ; 2.c. modify copy of original patch 
 ;
 WRITE !!?3,"...modifying utility global for new patch "
 IF $PIECE(A1AEPD,"*",2)=999 DO
 . SET $PIECE(A1AEPD,"*",2)="DBA"
 . QUIT
 SET $PIECE(^UTILITY($JOB,"A1AECOP",0),U,1,5)=$PIECE(^A1AE(A1AEFL,DA,0),U,1,5)
 ; set status to under development, clear later-status fields
 SET $PIECE(^UTILITY($JOB,"A1AECOP",0),U,8,14)="u"_U_DUZ_"^^^"_DT_"^^"
 KILL ^UTILITY($JOB,"A1AECOP",2) ; don't need subfile printed by
 KILL ^UTILITY($JOB,"A1AECOP","E") ; or entered in error description
 ;
 ; 2.d. copy modified original patch into new patch
 ;
 WRITE !!?3,"...copying modified utility global into new patch ",A1AEPD
 DO
 . NEW %X SET %X="^UTILITY($JOB,""A1AECOP"","
 . NEW %Y SET %Y="^A1AE(11005,DA,"
 . DO %XY^%RCR
 ;
 ; 2.e. fire set logic of all cross-references on new patch
 ;
 DO
 . NEW DIK SET DIK="^A1AE(11005,"
 . DO IX1^DIK ; set logic, all xrefs, 1 entry
 ;
 ; 2.f. copy patch message/payload (11005.1)
 ;
 DO PCOPY(DA,A1AEIFN,A1AEPD,A1AEOLPD)
 DO Q ; cleanup
 ;
 QUIT  ; end of OPTION-NEW
 ;
 ;
PICKPAT(A1AEIFN,A1AEOLPD,A1AEPKIF,A1AEVR,A1AEQUIT) ; select patch
 ;private;procedure;chatty;clean?;sac-compliant?
 ; called by:
 ;   OPTION
 ; calls:
 ;   ^DIC = select patch
 ; input:
 ;   file dhcp patches (11005)
 ;   user selection on current device
 ; output:
 ;  .A1AEIFN = original patch's ien
 ;  .A1AEOLPD = original patch id
 ;  .A1AEPKIF = original patch's application ien
 ;  .A1AEVR = original patch's application version
 ;  .A1AEQUIT = whether no selection made & option should exit
 ;   support for selection & help on current device
 ;
 NEW DIC SET DIC="^A1AE(11005," ; file dhcp patches (11005)
 SET DIC("A")="Select PATCH TO COPY: " ; patch-selection prompt
 SET DIC(0)="AEMQZ" ; ask, echo, multi-index, question, zero-node
 ; screen: current user must be a developer for this application
 ; [field development personnel (.01) of subfile development personnel
 ; (200/11007.03) of file dhcp patch/problem package (11007)]
 SET DIC("S")="IF $DATA(^A1AE(11007,+$PIECE(^(0),U,2),""PH"",DUZ,0))"
 WRITE !
 ;
 DO ^DIC ; select patch
 ;
 IF Y<0 DO  QUIT  ; no selection made, exit option
 . SET A1AEQUIT=1
 . QUIT
 SET A1AEIFN=+Y ; selected patch's ien
 SET A1AEOLPD=$PIECE(Y(0),U) ; selected patch's id
 SET A1AEPKIF=$PIECE(Y(0),U,2) ; selected patch's application ien
 KILL A1AEVR ; selected patch's application version
 IF $PIECE(A1AEOLPD,"*",2)=999 D  ; only set for dba patches
 . SET $PIECE(A1AEOLPD,"*",2)="DBA" ; fix version in id
 . SET A1AEVR=999 ; fix version in local variable
 . QUIT
 ;
 QUIT  ; end of PICKPAT
 ;
 ;
CONFIRM(A1AEIFN,A1AEOLPD,A1AEQUIT) ; confirm patch selection
 ;private;procedure;chatty;clean;sac-compliant
 ; called by:
 ;   OPTION
 ; calls:
 ;   SET^A1AERD = confirm selection
 ; input:
 ;   user confirmation on current device
 ; throughput:
 ;  .A1AEIFN = original patch's ien, set to 0 to redo selection
 ; output:
 ;  .A1AEOLPD = original patch id
 ;  .A1AEQUIT = whether confirmation escaped & option should exit
 ;   support for confirmation & help on current device
 ; to do:
 ;   replace with fileman reader call
 ;
 NEW A1AERD SET A1AERD("A")="Do you want to copy patch "_A1AEOLPD_"? "
 SET A1AERD(0)="S"
 SET A1AERD(1)="Yes^copy "_A1AEOLPD_" patch information"
 SET A1AERD(2)="No^not copy patch information"
 SET A1AERD("B")=2
 NEW DTOUT,C,I,J,L,S,T,V,X,X1,XQH
 ;
 DO SET^A1AERD ; confirm selection
 ;
 IF X=U DO  QUIT  ; escape from confirmation, exit option
 . SET A1AEQUIT=1
 . QUIT
 QUIT:"Y"[$EXTRACT(X)  ; selection made & confirmed, exit loop
 SET A1AEIFN=0 ; selection not confirmed, can't exit loop yet
 ;
 QUIT  ; end of CONFIRM
 ;
 ;
PICKVER(A1AEVR,A1AEFL,A1AETY,A1AEPKIF,A1AEPKNM,A1AEOLPD,A1AEQUIT) ; select version
 ;private;procedure;chatty;clean;sac-compliant
 ; called by:
 ;   OPTION
 ; calls:
 ;   VER^A1AEUTL = select version of application
 ; input:
 ;   A1AEFL = file to operate on (patches, 11005)
 ;   A1AETY = "PH" to indicate operating on next patch #
 ;   A1AEPKIF = original patch's application ien
 ;   A1AEPKNM = original patch's application name
 ;   A1AEOLPD = original patch id
 ;   user selection on current device
 ; throughput:
 ;  .A1AEVR = original patch's application version
 ; output:
 ;  .A1AEQUIT = whether confirmation escaped & option should exit
 ;   support for selection & help on current device
 ; to do:
 ;   replace with fileman reader call
 ;
 FOR  DO  QUIT:A1AEQUIT!$D(A1AEVR)
 . NEW A1AE SET A1AE(0)="AEQL" ; ask, echo, question, laygo
 . WRITE !!,"Copy into a new patch for: ",A1AEPKNM,!
 . IF '$DATA(A1AEVR) DO
 . . NEW DA,DIC,DLAYGO,DTOUT,DUOUT,X,Y
 . . DO VER^A1AEUTL ; select version of application
 . . QUIT:$DATA(A1AEVR)  ; continue if version selected
 . . SET A1AEQUIT=1 ; exit option if no version selected
 . . QUIT
 . QUIT:A1AEQUIT  ; exit option if escaped from selection
 . ;
 . QUIT:A1AEVR'=999  ; fine if not dba's special version
 . QUIT:$PIECE(A1AEOLPD,"*",2)="DBA"  ; fine if it is a dba patch
 . ; but can't use v999 unless it's a dba patch
 . WRITE !!?3,*7,"This version is reserved for 'DBA' type patches!"
 . KILL A1AEVR ; repeat selection
 . QUIT
 ;
 QUIT  ; end of PICKVER
 ;
 ;
PCOPY(DA,A1AEIFN,A1AEPD,A1AEOLPD) ; copy patch message/payload (11005.1)
 ;private;procedure;chatty;clean?;sac-compliant?
 ; called by:
 ;   OPTION-NEW
 ; calls:
 ;   CRE8MSG = create patch-msg stub record
 ;   COPYTXT = create patch-msg text
 ;   EDITPAT = edit new patch
 ; input:
 ;   DA = ien of new patch
 ;   A1AEIFN = ien of original patch
 ;   A1AEPD = new patch id 
 ;   A1AEOLPD = original patch id
 ;
 ; a. compare versions of original and copied patch
 ;
 NEW A1AESAME ; are the application versions of the 2 patches the same?
 SET A1AESAME=$PIECE(A1AEOLPD,"*",1,2)=$PIECE(A1AEPD,"*",1,2)
 IF 'A1AESAME DO
 . WRITE !!?3,*7,"...different versions!  patch MESSAGE text not copied"
 . QUIT
 ;
 ; b. copy input fields, if versions match
 ;
 NEW AXMZ SET AXMZ="" ; fld input message number (2)
 NEW ADT SET ADT="" ; fld input date/time (3)
 NEW A1AEOHDR SET A1AEOHDR=$GET(^A1AE(11005.1,A1AEIFN,0)) ; old hdr
 IF A1AESAME,A1AEOHDR'="" DO  ; if versions match (& hdr still exists)
 . SET AXMZ=$PIECE(A1AEOHDR,U,2) ; original patch's input msg #
 . SET ADT=$PIECE(A1AEOHDR,U,3) ; original patch's input date/time
 . QUIT
 ;
 ; c. create patch msg stub
 ;
 DO CRE8MSG(DA,AXMZ,ADT) ; create patch-msg stub record
 ;
 ; d. copy patch-payload text, if versions match
 ;
 IF A1AESAME,$DATA(^A1AE(11005.1,A1AEIFN,2)) DO
 . DO COPYTXT(DA,A1AEIFN) ; copy patch-msg text
 . QUIT
 ;
 ; e. edit new patch
 ;
 DO EDITPAT(A1AEPD,DA) ; edit new patch
 ;
 QUIT  ; end of PCOPY
 ;
 ;
CRE8MSG(DA,AXMZ,ADT) ; create patch-msg stub record
 ;private;procedure;silent;clean?;sac-compliant?
 ; called by:
 ;   PCOPY
 ; calls:
 ;   FILE^DICN = fileman record-create
 ; input:
 ;   DA = ien of new patch in file 11005
 ;   AXMZ = fld input message number (2)
 ;   ADT = fld input date/time (3)
 ; output:
 ;   new record created in file 11005.1
 ;
 NEW X SET X=DA ; fld name (.01), a pointer to file 11005
 NEW DINUM SET DINUM=DA ; force ien to match .01
 NEW DIC SET DIC="^A1AE(11005.1," ; file dhcp patch message (11005.1)
 ; flds input message number (2), input date/time (3), message text (20)
 SET DIC("DR")="2///"_AXMZ_";3///"_ADT_";20///"_"No routines included"
 NEW DD,DE,DO,DQ,DR,DTOUT,DUOUT,Y
 DO FILE^DICN ; add patch message
 ;
 QUIT  ; end of CRE8MSG
 ;
 ;
COPYTXT(DA,A1AEFN) ; create patch-msg text
 ;private;procedure;silent;clean?;sac-compliant?
 ; called by:
 ;   PCOPY
 ; calls:
 ;   %XY^%RCR = fileman array copy
 ; input:
 ;   DA = ien of new patch
 ;   A1AEIFN = ien of original patch
 ; output:
 ;   msg text copied in file 11005.1 from old to new msg
 ;
 NEW %X SET %X="^A1AE(11005.1,A1AEIFN,2," ; from original patch msg
 NEW %Y SET %Y="^A1AE(11005.1,DA,2," ; to new patch msg
 WRITE !!?3,"...copying patch message"
 DO %XY^%RCR ; copy array
 SET $PIECE(^A1AE(11005.1,DA,2,0),U,5)=DT ; fix hdr-node date
 ;
 QUIT  ; end of COPYTXT
 ;
 ;
EDITPAT(A1AEPD,DA) ; edit new patch
 ;private;procedure;chatty;clean?;sac-compliant?
 ; called by:
 ;   PCOPY
 ; calls:
 ;   ^DIE = fileman edit
 ; input:
 ;   A1AEPD = patch id
 ;   DA = ien of new patch
 ;   prompt user on current device to edit new patch
 ; output:
 ;   prompt & help support to current device
 ;   new patch in dhcp patches file (11005) is edited
 ;
 WRITE !!,"Patch Added: ",A1AEPD,!
 DO
 . NEW DIE SET DIE="^A1AE(11005," ; file dhcp patches (11005)
 . NEW DR SET DR="[A1AE ADD/EDIT PATCHES]" ; pm's master template
 . NEW DE,DIC,DIDEL,DIEBADK,DIEFIRE,DQ,DTOUT,X,Y
 . DO ^DIE ; edit the patch
 ;
 IF $GET(DA) DO  ; clear sequence # and compliance date
 . SET $PIECE(^A1AE(11005,DA,0),U,6)="" ; fld sequential release # (6)
 . SET $PIECE(^A1AE(11005,DA,0),U,18)="" ; fld compliance date (18)
 . QUIT
 ;
 QUIT  ; end of EDITPAT
 ;
 ;
Q ; cleanup
 ;
 KILL DA,AXMZ,ADT
 KILL ^UTILITY($J,"A1AECOP")
 KILL A1AEOLPD,A1AE0,A1AEPKIF,A1AEPKNM,A1AEPD,A1AEPK,A1AEVR,A1AENB,A1AEFL,A1AETY
 ;
 QUIT  ; end of Q
 ;
 ;
EOR ; end of routine A1AEPH8
