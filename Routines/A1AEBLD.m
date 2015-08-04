A1AEBLD ;ven/jli-handle transport of build entries for dhcp patches file(#11005) ;2015-07-06  11:53 PM
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 D EN^%ut("A1AEUBLD")
 Q
 ;
VERBOSE ;
 D EN^%ut("A1AEUBLD",1)
 Q
 ;
BUILDIT(PATCHNUM) ; Add DHCP PATCHES file field data to end of data in DHCP PATCH MESSAGE file (#11005.1)
 ; input - BUILDNUM - entry number in the BUILD file (#9.6)
 N GLOBNODE,GLOBREF,ENDNUM,A1AEIEN,BASE,BASE1,BASELEN,BUILDNAM,GLOBVAL,ENDKID
 S GLOBNODE="A1AEBLD"
 S BUILDNAM=$$BUILDNAM(PATCHNUM)
 S A1AEIEN=PATCHNUM
 S GLOBREF=$NA(^A1AE(11005.1,A1AEIEN,2))
 S BASE=$NA(^XTMP("A1AEBLD",$J,A1AEIEN))
 K @BASE
 D BUILDGLO(PATCHNUM,$NA(@BASE@("PATCHES")))
 ; originally was going to add a section PATCHES after KIDS, but add it into it
 ;S ENDNUM=$O(@GLOBREF@(""),-1)
 ;S ENDNUM=ENDNUM+1,@GLOBREF@(ENDNUM,0)="$PATCHES "_BUILDNAM,ENDNUM=ENDNUM+1
 ; above modified to
 S ENDNUM=$O(@GLOBREF@(""),-1) S ENDKID=@GLOBREF@(ENDNUM,0)
 S BASE1=$E(BASE,1,$L(BASE)-1),GLOBVAL=BASE,BASELEN=$L(BASE)+1
 F  S GLOBVAL=$Q(@GLOBVAL) Q:GLOBVAL'[BASE1  S @GLOBREF@(ENDNUM,0)=$E(GLOBVAL,BASELEN,$L(GLOBVAL)),ENDNUM=ENDNUM+1,@GLOBREF@(ENDNUM,0)=@GLOBVAL,ENDNUM=ENDNUM+1
 ; change from ending PATCHES back to ending KIDS
 ;S @GLOBREF@(ENDNUM,0)="$END PATCHES"
 ; replaced above line with
 S @GLOBREF@(ENDNUM,0)=ENDKID
 S $P(^A1AE(11005.1,A1AEIEN,2,0),U,3,4)=ENDNUM_U_ENDNUM ; update zero node for message
 K @BASE
 Q
 ;
BUILDGLO(PATCHNUM,BASE) ; Builds data structure to transport specific fields of file 11005
 ; input - PATCHNUM - internal entry number in the BUILD file (#9.6)
 ; input - BASE - location to save data
 N NAME,IEN,NODES,NODEVAL,RETURN,BUILDNAM
 S IEN=PATCHNUM
 I IEN="" Q  ; not in file 11005
 ; base storage location for data
 ; get list of nodes and data on those nodes to transport
 D GETNODES(.NODES)
 ; walk through nodes and move data to transport to part of build
 S NODEVAL=0
 ; zero contains all individual fields
 D GETDATA(.RETURN,11005,IEN,NODES(0))
 M @(BASE_"=RETURN(0)")
 ; 141117 following added to provide data in case referenced entries in other files don't already exist
 ; PACKAGE FILE entry
 K RETURN D GETDATA(.RETURN,9.4,+$P(^A1AE(11005,IEN,0),U,2),".01;1;2;")
 M @BASE@(9.4)=RETURN(0)
 ; PATCH STREAM entry
 K RETURN D GETDATA(.RETURN,11007.1,+$P(^A1AE(11005,IEN,0),U,20),".01;.05;")
 M @BASE@(11007.1)=RETURN(0)
 S @BASE@(11007.1,"FLDS",.02)="NO" ; if entry doesn't exist, set PRIMARY to NO
 S @BASE@(11007.1,"FLDS",.06)="NO" ; if entry doesn't exist, set SUBSCRIPTION to NO
 ; 141117 end of insertion
 ; rest are multiples
 F  S NODEVAL=$O(NODES(NODEVAL)) Q:NODEVAL=""  D
 . K RETURN
 . D GETMULT(.RETURN,IEN,NODEVAL) Q:'$D(RETURN)
 . M @(BASE_"=RETURN(NODEVAL)")
 . Q
 Q
 ;
BUILDNAM(PATCHNUM) ; Returns the name for the specified build number
 Q $P($G(^A1AE(11005,PATCHNUM,0)),U)
 ;
GETIEN(FILE,NAME) ; Returns whether an entry with NAME as .01 field exists in file number FILE
 ; input:
 ;     FILE - number of file to be checked
 ;     NAME - name of entry (.01 field value)
 ; return:
 ;     value > 0 if an entry for the patch is in FILE (DA value)
 ;     value = null if entry was not found in file FILE
 N GLOB
 S GLOB=$G(^DIC(FILE,0,"GL"))
 S GLOB=GLOB_"""B"","""_NAME_""","""")"
 Q +$O(@GLOB)
 ;
GETNODES(VALS) ; returns VALS with an array of nodes, and field numbers
 ; these are the fields that are to be transported.  Any changes to
 ; those fields that should be transported should occur below.
 ;
 ; input - VALS - passed by reference
 ; returns:
 ;      array of nodes - The zero node contains the list of semi-colon
 ;      separated field numbers to be transported.  The other nodes
 ;      represent the nodes of multiple fields.
 ;
 ; The following is the list of the nodes and fields to be transported.
 ; Fields followed by an 'm' indicate they are multiple fields and
 ; all data under them will be transported
 ;     node    fields
 ;      0   .01,2p,3,4,5,6,7,18,.2p
 ;      3   19m
 ;      4   40
 ;      5   5.7p
 ;      C   6.5m
 ;      D   5.5m
 ;      P   100m
 ;      P2  102
 ;
 K VALS
 S VALS(0)=".01;.2;2;3;4;5;6;7;18;40;5.7;102",VALS(3)="0,",VALS("C")="0,",VALS("D")="0,",VALS("P")="0,"
 Q
 ;
GETDATA(RETURN,FILE,IEN,NODELIST) ; get data for specified fields in file entry
 ; 141117 modified to handle different files, since some data needs to be carried if pointed to file entries aren't present on the system being installed on
 ; output - RETURN   - result array
 ; input  - FILENUM  - file number to obtain data for
 ; input  - IEN      - internal entry number for file entry to return data for
 ; input  - NODELIST - semi-colon separated list of field numbers
 N XXLIST,IENS,FLD,VAL
 S IENS=IEN_","
 D GETS^DIQ(FILE,IENS,NODELIST,"E","XXLIST")
 F FLD=0:0 S FLD=$O(XXLIST(FILE,IENS,FLD)) Q:FLD'>0  S VAL=XXLIST(FILE,IENS,FLD,"E") I VAL'="" S RETURN(0,"FLDS",FLD)=VAL
 Q
 ;
GETMULT(RETURN,IEN,NODEVAL) ; Returns the sub-file part of global
 ; input - RETURN - by reference contains the array part of the global
 ; input - IEN - subscript in file 11005
 ; input - NODEVAL - node under which all data should be transported
 ;
 M RETURN(NODEVAL,"MULT",NODEVAL)=^A1AE(11005,IEN,NODEVAL)
 Q
 ;
 ; JLI 150529 - Modified code below this point so that 11004 is used for the client instead of 11005
 ;
INSTALL(PATCHID) ; install data from patch section of build (if it includes data for file 11004)
 ; called from IN^XPDIJ1 during patch install
 ; JLI 150530 - commented next line, replaced with following - showing up during install as aborting and misleading
 ;N A1AEBASE,A1AEPTID,PKGNAME,STRMNAME I '$D(^A1AE(11004)) W !,"INSTALL ABORTED, NO GLOBAL ^A1AE(11004)" Q  ; PATCH file (#11004) is not present
 N A1AEBASE,A1AEPTID,PKGNAME,STRMNAME I '$D(^A1AE(11004)) Q  ; PATCH file (#11004) is not present
 ; get base location for INSTALL data, returns no true on not finding DHCP PATCHES data in the install file
 I '$$GETBASE(.A1AEBASE,PATCHID) W !,"FAILED IN GETBASE - A1AEBASE=",$G(A1AEBASE) Q
 ;
 ;  The following fields contain pointers to the files shown, which have the required fields shown
 ; .2 --> PATCH STREAM 11007.1
 ;     .01
 ;     .02  PRIMARY  --> NO if does not exist
 ;     .05  ABBREVIATION
 ;     .06  SUBSCRIPTION ---> No if does not exist
 ;
 ; 2 --> PACKAGE  9.4
 ;     .01 NAME
 ;     1 PREFIX
 ;     2 SHORT DESCRIPTION
 ;
 ; Check existence of PACKAGE and PATCH STREAM file entries and if an entry is not present, create it
 D CHKPACKG(A1AEBASE) D CHKSTREM(A1AEBASE) D UPDATFIL(A1AEBASE)
 Q
 ;
GETBASE(A1AEBASE,PATCHID) ;
 ; input
 ;    A1AEBASE - passed by reference - will contain the base reference for the data in the install file on return
 ;    PATCHID  - input name for the patch
 ; returns
 ;    0 or >0 value indcating whether finding location succeeded or not
 N A1AEBLD,A1AEINST,A1AEPTID,A1AEVAL
 S A1AEBASE=""
 ; get INSTALL file entry for PATCHID, it seems there might be more than one entry, take the last
 S A1AEINST=-1 F A1AEVAL=0:0 S A1AEVAL=$O(^XPD(9.7,"B",PATCHID,A1AEVAL)) Q:A1AEVAL'>0  S A1AEINST=A1AEVAL
 ; get the base entry as the one for this install
 I A1AEINST>0 S A1AEBASE=$NA(^XTMP("XPDI",A1AEINST,"PATCHES")) S A1AEVAL=$O(@A1AEBASE@(0))
 S A1AEBLD=$$GETIEN(9.6,PATCHID)
 ;
 I A1AEBLD'="",'A1AEVAL S A1AEBASE=$NA(^XTMP("XPDI",A1AEINST,"BLD",A1AEBLD,"PATCHES")),A1AEVAL=$D(^("PATCHES"))
 Q A1AEVAL
 ;
CHKPACKG(A1AEBASE) ; Check that entry PKGNAME exists in PACKAGE file (#9.4), if not create it
 N PKGIEN,PKGNAME,A1AEMSG,A1AEPKG
 S PKGNAME=$G(@A1AEBASE@("FLDS",2))
 S PKGIEN=$$GETIEN(9.4,PKGNAME)
 I PKGIEN'>0 D
 . ; create an entry with its required fields
 . N PKGIENS,PKGFDA,I
 . S PKGIENS="+1,"
 . F I=0:0 S I=$O(@A1AEBASE@(9.4,"FLDS",I)) Q:I'>0  S PKGFDA(9.4,PKGIENS,I)=^(I)
 . D UPDATE^DIE("E","PKGFDA","A1AEPKG","A1AEMSG")
 . Q
 Q
 ;
CHKSTREM(A1AEBASE) ; Check that entry PKGNAME exists in DHCP PATCH STREAM file (#11007.1), if not create it
 N STREMIEN,STREMNAM,A1AEMSG,A1AESTRM
 S STREMNAM=$G(@A1AEBASE@("FLDS",.2))
 I STREMNAM="" QUIT  ; Package. No stream.
 S STREMIEN=$$GETIEN(11007.1,STREMNAM) I STREMIEN'>0 D
 . ; create an entry with its required fields
 . N STRMIENS,STREMFDA,I
 . S STRMIENS="+1," I $D(@A1AEBASE@(11007.1,"FLDS",.001)) S STRMIENS="+"_^(.001)_","
 . F I=0:0 S I=$O(@A1AEBASE@(11007.1,"FLDS",I)) Q:I'>0  S STREMFDA(11007.1,STRMIENS,I)=^(I)
 . D UPDATE^DIE("E","STREMFDA","A1AESTRM","A1AEMSG")
 . Q
 Q
 ;
UPDATFIL(A1AEBASE) ;
 N A1AEFDA,A1AEFLD,A1AEIENS,A1AEROOT,MSGROOT,A1AEIEN,A1AEVAL,DA,DIK,A1AEPTID
 S A1AEPTID=@A1AEBASE@("FLDS",.01)
 S A1AEIEN=$O(^A1AE(11004,"B",A1AEPTID,0))
 ; if no entry for patch is in file #11004, will need to create it
 ; but FileManager non-friendly, since it forces you to use the install template
 ; so, have to force it by simply setting the global
 I A1AEIEN'>0 F A1AEVAL=1:1:6 L +^A1AE(11004):0 H:'$T 5 I $T S A1AEVAL=-1 Q
 ; ---- REALLY DON'T WANT TO SIMPLY EXIT WITHOUT FILLING IN DHCP PATCHES FILE ----
 ; I A1AEVAL>0 W !,"Can't get lock on the PATCH file (#11004)."
 ;
 I A1AEIEN'>0 D
 . S A1AEIEN=$P(^A1AE(11004,0),U,3)+1
 . S ^A1AE(11004,0)=$P(^A1AE(11004,0),U,1,2)_U_A1AEIEN_U_($P(^A1AE(11004,0),U,4)+1)
 . S A1AEVAL=@A1AEBASE@("FLDS",.01)
 . ; remove .0 from version if present
 . N A1AETEST,A1AETSTL
 . S A1AETEST=$P(A1AEVAL,"*",2),A1AETSTL=$L(A1AETEST)
 . I $E(A1AETEST,A1AETSTL-1,A1AETSTL)=".0" S A1AEVAL=$P(A1AEVAL,"*")_"*"_$E(A1AETEST,1,A1AETSTL-2)_"*"_$P(A1AEVAL,"*",3,99)
 . ;
 . S ^A1AE(11004,A1AEIEN,0)=A1AEVAL
 . S ^A1AE(11004,"B",A1AEVAL,A1AEIEN)=""
 . L -^A1AE(11004)
 . Q
 ; now update data associated with individual fields in patch entry
 K A1AEFDA,A1AEROOT
 S A1AEIENS=A1AEIEN_","
 S A1AEFLD=.01 F  S A1AEFLD=$O(@A1AEBASE@("FLDS",A1AEFLD)) Q:A1AEFLD'>0  S A1AEFDA(11004,A1AEIENS,A1AEFLD)=^(A1AEFLD)
 D FILE^DIE("E","A1AEFDA","MSGROOT")
 ; now move multiple nodes into the entry
 S A1AEFLD="" F  S A1AEFLD=$O(@A1AEBASE@("MULT",A1AEFLD)) Q:A1AEFLD=""  M ^A1AE(11004,A1AEIEN,A1AEFLD)=^(A1AEFLD)
 ; and make sure all cross-references are set
 S DIK="^A1AE(11004,",DA=A1AEIEN D IX^DIK
 Q
