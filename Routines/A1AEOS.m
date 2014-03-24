A1AEOS ; VEN/SMH - Patch Module Operating System Interface;2014-03-24  4:05 PM
 ;;2.4;PATCH MODULE;
 ;
 ; This routine is not SAC compliant
 ;
MKDIR(DIR) ; [PUBLIC] - $$; mkdir DIR name. Unix output for success and failure.
 N CMD S CMD="mkdir -p '"_DIR_"'" ; mk sure that we take in account spaces
 N OUT ; Exit value of command.
 I +$SY=47 D  ; GT.M
 . O "p":(shell="/bin/sh":command=CMD)::"pipe" U "p" C "p"
 . I $ZV["V6.1" S OUT=$ZCLOSE ; GT.M 6.1 only returns the status!!
 . E  S OUT=0
 I +$SY=0 S OUT=$ZF(-1,CMD) ; Cache
 QUIT OUT
 ;
T2 ; @TEST Make a directory
 N % S %=$$MKDIR("/tmp/test/sam")
 D CHKEQ^XTMUNIT(%,0,"Status of mkdir should be zero")
 N % S %=$$MKDIR("/lksjdfkjsdf/")
 D CHKEQ^XTMUNIT(%,1,"Status of failed mkdir should be one")
 QUIT
 ;
