A1AEPHD ;ven/toad-option delete a patch [A1AE PHDEL] ; 6/10/15 2:07am
 ;;2.5;PATCH MODULE;;Jun 05, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ;;(c) 2015, Frederick D. S. Marshall, all rights reserved
 ;;($) funded by Frederick D. S. Marshall of the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, Version 2.0.
 ; under primary development: initial drafts
 ;
 ; primary developer: Frederick D. S. Marshall (toad) <toad@mumps.org>
 ;
 ; primary change history:
 ;
 ; 2015-05-29, ven/toad: refactor subroutine 2 for readability, split
 ; out to new routine ^A1AEPHD, break up for unit testing, comment,
 ; and add support for nonproduction deletion of a released patch. based
 ; on subroutine 2^A1AEPH1 written by Robin M. Ostrander and Mike J.
 ; Kilmade of VA Albany Information Systems Center (isa/rmo,mjk).
 ;
 ; contents [all private]:
 ;
 ; DELETE: option Delete a Patch [A1AE PHDEL]
 ; SELECT: select a patch to delete
 ; $$SCREEN: screen patch selection for deletion
 ; CONFIRM: confirm deletion of a patch
 ; KILL: actual deletion
 ; KILLNUMS: reset next patch & seq #s during delete
 ;
 ;
OPTION ; option delete an notreleased patch [A1AE PHDEL]
 ; called by:
 ;   Menuman for option A1AE PHDEL
 ;   2^A1AEPH1, now unused & slated for deletion
 ; calls:
 ;   SELECT = select a patch to delete
 ;   CONFIRM = confirm deletion of a patch
 ;   KILL = actual deletion
 ; input:
 ;   prompt user on current device to select & confirm patch
 ;   A1AEOVER = 1 to override usual safeties during unit-test cleanup
 ;              undefined otherwise
 ; output:
 ;   prompt & help on current device for select & confirm
 ;   selected record in file 11005 deleted
 ;   selected record in file 11005.1 deleted
 ;   selected patch's application record in file 11007 updated:
 ;      next patch # (& sometimes sequence #) field reset
 ;
 NEW DA SET DA=-1 ; ien of selected patch
 NEW A1AEPD ; field patch designation (.01) of selected patch
 NEW A1AE0 ; header (0) node of selected patch
 DO
 . DO SELECT(.DA,.A1AEPD,.A1AE0) ; 1. select a patch to delete
 . QUIT:DA<0  ; done if no selection
 . DO CONFIRM(.DA,A1AEPD) ; 2. confirm deletion of a patch
 . QUIT:DA<0  ; done if not confirmed
 . DO KILL(DA,A1AEPD,A1AE0) ; 3. actual deletion
 . QUIT
 ;
 QUIT  ; end of OPTION
 ;
 ;
SELECT(DA,A1AEPD,A1AE0) ; select a patch to delete
 ; called by: OPTION
 ; calls:
 ;   ^DIC = fileman lookup
 ; input:
 ;   prompt current device to select a patch to delete
 ;   A1AEOVER = 1 to override usual safeties during unit-test cleanup
 ;              undefined otherwise
 ; throughput:
 ;  .DA = ien of selected patch, defaults to -1
 ; output:
 ;   prompt and help to current device
 ;  .A1AEPD = field patch designation (.01) of selected patch
 ;  .A1AE0 = header (0) node of selected patch
 ;
 ; a. lookup patch
 ;
 NEW Y ; lookup results
 DO
 . NEW DIC SET DIC="^A1AE(11005," ; file dhcp patches (11005)
 . SET DIC(0)="AEMQZ" ; ask, echo, multi-index, question, zero node
 . SET DIC("A")="Select PATCH: " ; prompt
 . SET DIC("S")="IF $$SCREEN^A1AEPHD(^(0))" ; screen
 . NEW DLAYGO,DTOUT,DUOUT,X ; other inputs and outputs
 . WRITE !
 . DO ^DIC ; fileman lookup api
 . QUIT
 QUIT:Y<0  ; done if no selection
 ;
 ; b. output results
 ;
 SET DA=+Y ; ien of selected patch
 SET A1AEPD=$PIECE(Y,U,2) ; patch ID, (e.g., "DI*22*150")
 IF $PIECE(A1AEPD,"*",2)=999 DO  ; fix id of dba patches (mailman)
 . SET $PIECE(A1AEPD,"*",2)="DBA" ; store dba instead of version # 999
 . QUIT
 SET A1AE0=Y(0) ; patch header node
 ;
 QUIT  ; end of SELECT
 ;
 ;
SCREEN(HEADER) ; screen patch selection for deletion
 ; called by: ^DIC, after it's called by SELECT
 ; calls: none
 ; input:
 ;   HEADER = header (0) node of patch to screen for deletion
 ;   A1AEOVER = 1 to override usual safeties during unit-test cleanup
 ;              undefined otherwise
 ; output = 1 if patch may be selected for deletion
 ;          0 if not
 ;
 ; a. select by patch status
 ;
 ; under normal conditions, for a patch to be deletable, it must be in
 ; one of the five following statuses. before version 2.4, it had to be
 ; in one of the first two
 ;
 NEW SELECT SET SELECT=1
 DO
 . NEW STATUS SET STATUS=$PIECE(HEADER,U,8) ; field status of patch (8)
 . QUIT:STATUS="u"  ; under development
 . QUIT:STATUS="c"  ; completed/unverified
 . QUIT:STATUS="i2"  ; in review
 . QUIT:STATUS="d2"  ; sec development
 . QUIT:STATUS="s2"  ; sec completion
 . SET SELECT=0 ; other statuses safe from deletion
 . QUIT
 ;
 ; b. select by user role
 ;
 ; to delete a patch, the current user must be listed in field
 ; development personnel (.01) of subfile development personnel
 ; (200/11007.03) of file dhcp patch/problem package (11007):
 ;
 NEW APP SET APP=+$PIECE(HEADER,U,2) ; field package (2)
 IF '$DATA(^A1AE(11007,APP,"PH",DUZ,0)) DO
 . SET SELECT=0 ; otherwise, no deleting allowed
 . QUIT
 ;
 ; c. support unit testing
 ;
 ; for applications listed as for unit testing only, the unit-test
 ; software may set special override local variable A1AEOVER to allow
 ; otherwise restricted behavior, such as deleting any patch, so the
 ; environment can be restored to a clean state during or after unit
 ; testing. A1AEOVER is to be used sparingly, so unit tests usually
 ; focus on replicating normal behavior. the special condition is called
 ; unit-test override.
 ;
 IF 'SELECT DO
 . NEW APPHEAD SET APPHEAD=$GET(^A1AE(11007,APP,0)) ; header or app
 . NEW FORUNIT SET FORUNIT=$PIECE(APPHEAD,U,7) ; fld for unit test only?
 . QUIT:'FORUNIT  ; if real app, protect safe patch even in override
 . QUIT:'$DATA(A1AEOVER)  ; if not in override, protect safe patch
 . SET SELECT=1 ; in override, can delete fake app's patch safe patch
 . QUIT
 ;
 QUIT SELECT ; end of $$SCREEN
 ;
 ;
CONFIRM(A1AEDA,A1AEPD) ; confirm deletion of a patch
 ; called by: OPTION
 ; calls:
 ;   ^DIR = fileman reader
 ; input:
 ;   prompt current device to select a patch to delete
 ; throughput:
 ;  .A1AEDA = ien of selected patch, set to -1 if not confirmed
 ;      (note name change to protect from reader's DA input parameter)
 ; output:
 ;   prompt and help to current device
 ;  .A1AEPD = field patch designation (.01) of selected patch
 ;
 ; 1. define confirmation prompt
 NEW DA,DIROUT,DIRUT,DTOUT,DUOUT,X,Y
 NEW DIR SET DIR(0)="Y^O"
 SET DIR("A")="Are you sure you want to delete patch "_A1AEPD
 SET DIR("B")="NO"
 SET DIR("?")="Enter YES to delete the selected patch, or NO to exit."
 ;
 ; 2. prompt user for confirmation
 DO ^DIR
 ;
 ; 3. record results
 IF 'Y DO
 . SET A1AEDA=-1
 . QUIT
 ;
 QUIT  ; end of CONFIRM
 ;
 ;
KILL(DA,A1AEPD,A1AE0) ; actual deletion
 ; called by: OPTION
 ; calls:
 ;   ^DIK = fileman delete
 ;   KILLNUMS = reset next patch & seq #s during delete
 ; input:
 ;   DA = ien of selected patch
 ;   A1AEPD = field patch designation (.01) of selected patch (opt)
 ;   A1AE0 = header (0) node of selected patch                (opt)
 ; output:
 ;   selected record in file 11005 deleted
 ;   selected record in file 11005.1 deleted
 ;   selected patch's application record in file 11007 updated:
 ;      next patch # (& sometimes next sequence #) field reset
 ;
 I '$D(A1AE0) D
 . S A1AE0=^A1AE(11005,DA,0)
 . S A1AEPD=$P(A1AE0,U)
 ;
 ; a. delete patch
 ;
 DO
 . NEW DIK SET DIK="^A1AE(11005," ; file dhcp patches (11005)
 . DO ^DIK ; delete patch
 . WRITE !!?3,"...deletion of "_A1AEPD_" from DHCP Patch File completed"
 . QUIT
 ;
 ; b. reset next patch # (& sometimes next sequence #)
 ;
 DO KILLNUMS(DA,A1AE0)
 ;
 ; c. delete patch payload
 ;
 DO
 . NEW DIK SET DIK="^A1AE(11005.1," ; file dhcp patch message (11005.1)
 . DO ^DIK ; delete patch message (payload)
 . QUIT
 ;
 QUIT  ; end of KILL
 ;
 ;
KILLNUMS(DA,A1AE0) ; reset next patch & seq #s during delete
 ; called by: KILL
 ; calls: none
 ; input:
 ;   DA = ien of selected patch
 ;   A1AE0 = header (0) node of selected patch
 ; output:
 ;   selected patch's application record in file 11007 updated:
 ;      next patch # (& sometimes next sequence #) field reset
 ;
 ; a. load patch info
 ;
 NEW HEADER SET HEADER=A1AE0 ; patch header, for readability
 NEW APP SET APP=+$PIECE(HEADER,U,2) ; field package (2)
 NEW VERSION SET VERSION=$PIECE(HEADER,U,3) ; field version (3)
 NEW STREAM SET STREAM=$$GSTRMP^A1AEUTL(DA) ; patch's stream
 ;
 ; b. lock app/version/stream
 ;
 LOCK +^A1AE(11007,APP,"V",VERSION,1,STREAM,"PH"):60 ; lock 
 NEW LOCKED SET LOCKED=$TEST ; did we get the lock?
 ;
 ; c. reset next patch #
 ;
 DO
 . NEW PATNUM SET PATNUM=$PIECE(HEADER,U,4) ; field patch number (4)
 . NEW NEXTPAT ; field next patch number (1)
 . ; for this stream of this version of this app:
 . SET NEXTPAT=$GET(^A1AE(11007,APP,"V",VERSION,1,STREAM,"PH"))
 . QUIT:'NEXTPAT  ; none yet
 . QUIT:PATNUM'<NEXTPAT  ; done if patch's # is >= next patch #
 . ; otherwise, roll back the next patch # to this patch's #
 . ; because this number is now available again
 . SET ^("PH")=PATNUM ; **naked**
 . QUIT
 ;
 ; d. conditionally reset next sequence #
 ;
 DO
 . NEW SEQNUM SET SEQNUM=$PIECE(HEADER,U,6) ; field seq release num (6)
 . QUIT:'SEQNUM  ; done if this patch had no seq #
 . NEW STATUS SET STATUS=$PIECE(HEADER,U,8) ; field status of patch (8)
 . QUIT:STATUS'="v"&(STATUS'="r2")  ; neither verified nor sec release
 . NEW NEXTSEQ ; field next sequence number (2)
 . ; for this stream of this version of this app:
 . SET NEXTSEQ=$GET(^A1AE(11007,APP,"V",VERSION,1,STREAM,"PR"))
 . QUIT:'NEXTSEQ  ; none yet
 . QUIT:PATNUM'<NEXTSEQ  ; done if patch's seq # is >= next seq #
 . ; otherwise, roll back the next seq # to this patch's seq # - 1
 . ; because this number is now available again
 . SET ^("PR")=SEQNUM-1 ; **NAKED**
 . QUIT
 ;
 ; e. unlock app/version/stream, if locked
 ;
 IF LOCKED DO  ; only unlock if we did in fact lock it
 . LOCK -^A1AE(11007,APP,"V",VERSION,1,STREAM,"PH") ; unlock 
 ;
 QUIT  ; end of KILLNUMS
 ;
 ;
EOR ; end of routine A1AEPHD
