A1AEUTLC ;ven/toad-patch tools ;2015-06-13  9:15 PM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;
 ; Change History:
 ;
 ; original changes, isa/rmo/mjk: Robin M. Ostrander and Mike J. Kilmade
 ; of VA's Albany Field Office created the original A1AEUTL routine in
 ; an early version of Patch Module and updated it regularly.
 ;
 ; 2007-01-11, isf/rwf: previous change; by Wally Fort of the Oakland VA
 ; Field Office.
 ;
 ; 2014-01-06, ven/smh: Sam Habiel of the VISTA Expertise Network,
 ; in SETNUM, DIC(0) will be taken from the symbol table if it is
 ; defined to make the output silent for Unit Testing. Otherwise, it
 ; will default to LE. First change of OSEHRA Forum Phase One.
 ;
 ; 2014-01-10, ven/smh: replace awkward logic in SETNUM based on
 ; traditional simple index AB on file DHCP Patches (11005) to be
 ; based on replacement new-style compound index AB. Old algorithm
 ; was hard-coded to a limit of 999 as the highest patch number.
 ; New algorithm uses reverse $order to get last patch number, with
 ; no hard-coded limit.
 ;
 ; 2014-01-22, ven/smh: introduce new variable A1AESTRM and logic
 ; to set initial sequence number and patch number based on new file
 ; DHCP Patch Stream (11007.1)'s field Patch Number Start (.001).
 ; Changes in SEQ, NUM, SETNUM, & $$PRIMSTRM.
 ;
 ; 2014-02-10/11,25, ven/toad: Rick Marshall of the VISTA Expertise
 ; Network added change history, new subroutine ID11005 to
 ; replace file DHCP Patches (11005)'s WRITE identifier logic,
 ; changed $$PRIMSTRM to use new APRIM index instead of old PRIM
 ; index to avoid letting users select DHCP Patch Stream records
 ; by typing YES or NO. Changed name of default record from
 ; "VA PATCH STREAM" to "FOIA VISTA" and set its field Abbreviation
 ; (.05) to "FV". Fixed an intermediate-calculation bug in the WRITE
 ; ID logic - if patch had status of cancel, it calculated as
 ; "cancel^0" instead of "cancel" before extracting just the first
 ; three characters; the results were correct, but the intermediate
 ; value was wrong. Convert ID11005^A1AEUTL from write commands to
 ; use of EN^DDIOL; delimit components in silent mode.
 ;
 ; 2014-03-04, ven/smh: Now there is an Entry point SETNUM1 to set the
 ; patch directly. SETNUM can now be invoked independently from NUM as
 ; it does its own locks.
 ;
 ; 2014-03-06, ven/smh: Add check for security key A1AE IMPORT besides
 ; the user when importing, in IN.
 ;
 ; 2014-03-06, ven/toad: added new status abbreviations for
 ; secondary patches to ID11005. Add conditional line 2 of write ID
 ; for derived patches, to show "derived from [Stream]Subject".
 ; in ID11005 and split out new function $$STRMSUBJ. Last change of
 ; OSEHRA Forum Phase One.
 ;
 ; 2014-08-05, ven/lgc: Larry G. Carlson of the VISTA Expertise Network
 ; added code for a new M cross-reference (ASUBCNG) at linetag below by
 ; same name. This cross automates add a new SUBSCRIPTION DATE and
 ; RESPONSIBLE OFFICIAL to the active PATCH STREAM entry when the
 ; SUBSCRIPTION field is toggled to YES. Added Post Install at A1AEPST
 ; to run after KIDS install. sets PRIMARY? and SUBSCRIPTION with some
 ; input post install. First changes of OSEHRA Forum Phase Two.
 ;
 ; 2014-08-19, ven/lgc: added Unit Testing Code for post install
 ;
 ; 2014-08-20, ven/lgc: moved Unit Testing to routine A1AEUT3
 ;
 ; 2014-08-27, ven/lgc: moved Post install to A1AE2POS
 ;
 ; 2014-10-22, ven/lgc: added code at FORUM linetag to drop out of input
 ; transform early if this is not a forum site
 ;
 ; 2015-03-05, ven/lgc: move code for input transform for field
 ; Subscription (.06) in file DHCP Patch Stream (11007.1) out to
 ; STRM^A1AEK2.
 ;
 ; 2015-05-25/6, ven/lgc,toad: modify patch # and seq # handling to use
 ; correct patch stream. SEQ, DELSEQ, NUM, SETNUM, SETNUM1.
 ;
 ; 2015-05-28, ven/jli: Joel L. Ivey of the VISTA Expertise Network
 ; added a new api to split the application's patch stream. the first
 ; patch in the active stream being released creates an info-only patch,
 ; sets it to verified, sends it out with sequence number. in SPLITPKG.
 ;
 ; 2015-05-29, ven/jli: changed to use old stream sequence number if no
 ; previous. ensure next problem number and next patch number are set
 ; for stream. ensure assigned patch number is stream-specific. ensure
 ; stream-specific next patch number is updated in subfile. in SEQ, NUM.
 ;
 ; 2015-06-03, ven/jli: moved SPLITPKG out to routine A1AESPLT.
 ;
 ; 2015-06-04, ven/toad: fix change history, fix bug in STRMBPN where it
 ; calls $$GSTRMP without properly passing the DA parameter, fix bug in
 ; NUM in which non-foia-vista streams for new versions always got
 ; assigned the foia vista values for the next numbers (oops), strip out
 ; old code and embedded change-history comments, unwrap long lines,
 ; add contents, much refactoring. Change next # algorithm so that the
 ; fields really do store the *next* #, not the most recently assigned
 ; #. passim.
 ;
 ;
 ; contents:
 ;
 ; SEQ: get & set sequence #
 ; DELSEQ: delete sequence #
 ; IN: input transform for field .01 in file 11005
 ; PKG: select a patch/problem package
 ; VER: select an application version
 ; NUM: get next patch/problem number
 ; NUMINIT: init next #
 ; SETNUM: get & set last number & create stub record
 ; SETNUM1: create patch/problem stub record
 ; PRT: print field record printed by
 ; ENVER: option A1AE POST VERIFY
 ; $$EASCREEN: screen patch selection for option A1AE POST VERIFY
 ; NEWVER: set up a new version for application
 ; $$PRIMSTRM: return primary stream for this forum system
 ; ID11005: WRITE Identifier on DHCP Patches file (11005)
 ; $$STRMSUBJ: return [Stream]Subject
 ; ASUBCNG: xref ASUBCNG on file 11007.1
 ; STRMBPN: get PATCH STREAM by evaluating the PATCH NUMBER
 ; $$GSTRMP: get PATCH STREAM by evaluating the PATCH NUMBER
 ;
NUM ; get next patch/problem number
 ; called by:
 ;   1^A1AEPB1: option add a problem [A1AE PBADD]
 ;   1^A1AEPH1: option add a patch [A1AE PHADD]
 ;   OPTION^A1AEPH8: option copy a patch [A1AE COPY PATCH]
 ; calls:
 ;   $$PRIMSTRM = get primary patch stream
 ;   NUMINIT = initialize next #
 ;   SETNUM = get & set last # and create stub record
 ; input:
 ;   A1AEPKIF = new patch's package namespace
 ;   A1AEVR = new patch's version #
 ;   A1AETY = subfile subscript: PH for patch or PB for problem
 ;   A1AEFL = file to update (11005)
 ; output:
 ;   DA = new patch ien
 ;   A1AEPD = new patch id
 ;
 ; This entry point, and SETNUM below are only called by developers so
 ; selecting the patch stream using 11007.1 is fine.
 ;
NUMINIT(A1AEPKIF,A1AEVR,A1AESTRM,A1AETY,A1AEVAR) ; init next #
 ;;private;procedure;silent;clean;sac-compliant
 ; called by:
 ;   NUM
 ; calls:
 ;   SETPACKG^A1AESPLT when initializing next patch #
 ; input:
 ;   A1AEPKIF = new patch's package namespace
 ;   A1AEVR = new patch's version #
 ;   A1AESTRM = new patch's stream
 ;   A1AETY = subfile subscript: PH for patch or PB for problem
 ;   A1AEVAR = name of output variable
 ;   lock must be held on ^A1AE(11007,A1AEPKIF,"V",A1AEVR,A1AETY)
 ; output:
 ;   @A1AEVAR [A1AEPH or A1AEPB] = next patch/problem number
 ;   proper subfields are initialized with next number
 ;   if patch, info-only stream-split patch generated & sent
 ;
ID11005 ; WRITE Identifier on DHCP Patches file (11005)
 ; called by: ^DD(11005,0,"ID","WRITE")
 ; calls: $$STREAM()
 ; input:
 ;   $X
 ;   file DHCP Patches (11005), current record:
 ;     field Patch Stream (.2)
 ;       :file DHCP Patch Stream (11007.1)
 ;       :field Abbreviation (.05)
 ;     field Patch Subject (5)
 ;     field Status of Patch (8)
 ;       :DD definition of set of codes
 ;     field User Entering (9)
 ;       :file New Person (200)
 ;       :field Initial (1)
 ; output to current device (definition):
 ;   IEN  Designation  Stream  Subject  Status  User
 ; output in silent mode:
 ;   [Stream]Subject|Status|User
 ;
 ; Fields IEN (.001) and Patch Designation (.01) are provided by File
 ; Manager and are not part of this identifier. Everything after that
 ; - the spaces, field Abbreviation (.05) of file DHCP Patch Stream
 ; (11007.1) record pointed to by field Patch Stream (.2), truncated
 ; field Patch Subject (5), abbreviated field Status of Patch (8), and
 ; abbreviated field Initial (1) of file New Person (200) record of
 ; field User Entering (9) - are output as part of this write
 ; identifier. If this Patch Module supports only a single patch stream
 ; then field .2 will be empty, so it will be omitted from this ID.
 ;
 ; output to current device (sample):
 ;
 ; Select DHCP PATCHES PATCH DESIGNATION: ??
 ;
 ;   Choose from:
 ;   12           TIU*1*246    [FV]TESTING TESTING               UND TOA
 ;   13           TIU*1*10002  [OV]TEST                          UND TOA
 ;   14           ZZZ*2*10001  [OV]TEST                          VER USP
 ;
ASUBCNG(D0) ; xref ASUBCNG on file 11007.1
 ; called by xref ASUBCNG on file 11007.1
 ; input:
 ;   D0  = IEN of the PATCH STREAM entry being edited
 ;   DUZ = User changing the site's SUBSCRIPTION
 ;
 ; This code forces new entries in the SUBSCRIPTION DATE and RESPONSIBLE
 ; OFFICIAL fields when a new Patch Stream is toggled as the
 ; SUBSCRIPTION stream. We may wish to add code to force an entry into
 ; COMMENTS field associated with this change to fully document the
 ; rationale for changing a site's SUBSCRIPTION.
 ;
STRMSUBJ(IDLEN,PATCH,DELIM) ; [Stream]Subject
 ;;private;function;clean;silent;SAC-compliant
 ; called by: ID11005
 ; calls: none
 ; throughput:
 ;   IDLEN: length available left for identifier, updated
 ; input:
 ;   PATCH = patch's header node value
 ;   DELIM = ID-field delimiter
 ;   file DHCP Patches (11005), current record:
 ;     field Patch Stream (.2)
 ;       :file DHCP Patch Stream (11007.1)
 ;       :field Abbreviation (.05)
 ;     field Patch Subject (5)
 ;     field Status of Patch (8)
 ;       :DD definition of set of codes
 ; output = [Stream]Subject
 ;
PRIMSTRM() ; return primary stream for this forum system
 ;;private;function;clean;silent;SAC-compliant
 ; called by: SEQ, NUM
 ; calls: IX1^DIK
 ; input: index PRIM of file DHCP Patch Stream (11007.1)
 ; output = field Patch Number Start (.001/IEN) of primary stream
 ;   if file contains no records, initialize FOIA VISTA record
 ;
ENVER ; option A1AE POST VERIFY
 ; [Actually Verify Patches Verified by Postmaster]
 ; for permitting verifiers to clean up patches that had to be verified
 ; by the Postmaster for version 2.0 of the patch module.
 ; Now obsolete, but keep for now for history.
 ;
 ; 1. instructions
 ;
 W !!?27,"*** NOTE ***"
 W !!?3,*7
 W "This option will update the Verified information section of a patch"
 W !?3,"to a valid verifier, yourself, rather than the Postmaster."
 W !!?3
 W "It will put your name in as the Verifier and assign the current date"
 W !?3,"as the date the patch was verified."
 W !!?3
 W "Once you have verified the patch it will not appear as new again"
 W !?3
 W "to the user; the 'New Patch Bulletin' will not be sent since these"
 W !?3,"occurred when the patch was originally completed."
 ;
 N A1AEQUIT S A1AEUIT=0
 F  D  Q:A1AEQUIT
 . ;
 . ; 2. select patch
 . ;
 . N Y
 . D
 . . N DIC S DIC("A")="Select PATCH: "
 . . S DIC("S")="I $$EASCREEN^A1AEUTL(^(0))"
 . . S DIC="^A1AE(11005,"
 . . S DIC(0)="AEMQ"
 . . W !
 . . D ^DIC
 . S A1AEQUIT=Y<0
 . Q:A1AEQUIT
 . N DA S DA=+Y
 . N A1AEPD S A1AEPD=$P(Y,U,2)
 . K Y
 . ;
 . ; 3. confirm verification
 . ;
 . N %DT S %DT=""
 . N X S X="T"
 . D ^%DT
 . S DT=Y
 . ;
 . D
 . . N A1AERD,Y
 . . S A1AERD("A")="Are you sure you want to verify patch "_A1AEPD_"? "
 . . S A1AERD(0)="S"
 . . S A1AERD(1)="Yes^assign yourself as the Verifier"
 . . S A1AERD(2)="No^leave the verifier as the Postmaster"
 . . S A1AERD("B")=2
 . . D SET^A1AERD
 . S A1AEQUIT=X["^"
 . Q:A1AEQUIT
 . ;
 . ; 4. verify patch
 . ;
 . I $E(X,1)["Y" D
 . . W !!?3,"...please wait ",A1AEPD," is being verified..."
 . . N DIE S DIE="^A1AE(11005,"
 . . N DR S DR="8////v;11////"_DT_";14////"_DUZ
 . . N DE,DQ
 . . D ^DIE
 . . W "done"
 . . Q
 . Q
 ;
 D Q^A1AEPH1 ; cleanup
 ;
 QUIT  ; end of ENVER
 ;
