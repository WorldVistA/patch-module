A1AEOS	; VEN/SMH - Patch Module Operating System Interface;2014-03-31  1:27 PM
	;;2.4;PATCH MODULE;;Mar 28, 2014
	;
	; This routine is not SAC compliant
	;
MKDIR(DIR)	; [PUBLIC] - $$; mkdir DIR name. Unix output for success and failure.
	N CMD S CMD="mkdir -p '"_DIR_"'" ; mk sure that we take in account spaces
	N OUT ; Exit value of command.
	I +$SY=47 D  ; GT.M
	. O "p":(shell="/bin/sh":command=CMD)::"pipe" U "p" C "p"
	. I $ZV["V6.1" S OUT=$ZCLOSE ; GT.M 6.1 only returns the status!!
	. E  S OUT=0
	I +$SY=0 S OUT=$ZF(-1,CMD) ; Cache
	QUIT OUT
	;
T2	; @TEST Make a directory
	N % S %=$$MKDIR("/tmp/test/sam")
	D CHKEQ^XTMUNIT(%,0,"Status of mkdir should be zero")
	N % S %=$$MKDIR("/lksjdfkjsdf/")
	D CHKEQ^XTMUNIT(%,1,"Status of failed mkdir should be one")
	QUIT
	;
PWD() ; [PUBLIC] $$ - Current directory
 I +$SY=47 Q $ZD
 I +$SY=0 Q $ZU(168)
 S $EC=",U-M-VM-NOT-SUPPORTED,"
 QUIT
 ;
D() ; [PUBLIC] $$ - Delimiter
 N OS S OS=$$OS^%ZOSV
 I $$UP^XLFSTR(OS)["UNIX" Q "/"
 I $$UP^XLFSTR(OS)["NT" Q "\"
 S $EC=",U-M-VM-NOT-SUPPORTED,"
 QUIT
 ;
CD(ND) ; [PUBLIC] $$ - Change directory
 I +$SY=47 S $ZD=ND Q $$PWD()
 I +$SY=0 N % S %=$ZU(168,ND) Q $$PWD()
 S $EC=",U-M-VM-NOT-SUPPORTED,"
 ;
RDPIPE(RTN,CMD) ; [PUBLIC] $$ - Execute a read only (non-interactive) command as a pipe
 I +$SY=47 D  QUIT:$ZV["V6.1" $ZCLOSE QUIT 0
 . N P S P="pipe"
 . O P:(shell="/bin/sh":command=CMD:PARSE:READONLY)::"pipe"
 . U P
 . N CNT S CNT=1
 . N X F  R X:1 Q:$ZEOF  U $P D EN^DDIOL(X) S RTN(CNT)=X,CNT=CNT+1 U P  ; just loop around until we are done.
 . C P
 I +$SY=0 D  Q 0
 . O CMD:"QR"
 . U CMD
 . N CNT S CNT=1
 . N X F  R X:1 Q:$ZEOF  U $P D EN^DDIOL(X) S RTN(CNT)=X,CNT=CNT+1 U CMD  ; ditto
 . C CMD
 S $EC=",U-M-VM-NOT-SUPPORTED,"
 QUIT
