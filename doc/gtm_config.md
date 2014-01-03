# GT.M Confiugration

GT.M version is currently GT.M V6.0-003 Linux x86_64.

## Core Config

	$gtmroutines/$ZROUTINES=" /home/forum/r/6.0-003(/home/forum/r) lib/gtm/libgtmutil.so"

	$gtmgbldir/$ZGBLDIR="/home/forum/g/db.gld"

	$gtm_sysid/$SYSTEM="47,forum"

	$gtm_prompt/$ZPROMPT="DEV,FORUM>"

	$ZINT/gtm_zinterrupt='I $$JOBEXAM^ZU($ZPOSITION)'

## Replication

	export ENV="forum"
	export BUP="forum-a"
	export GTM_REPLICATION="on"     #[on|off]
	export GTM_REPLICATION="off"   #[on|off]
	export REPL_PORT="50188"        # /etc/services gtmrepl 50188/tcp # GT.M Repl
	export REPL_HOST="forum-b.osehra.org"
	export REPL_HOST="localhost"    #use ssh tunnel
	export REPL_HOST_SSH_HOST="forum-b.osehra.org"
	export REPL_HOST_SSH_PORT="22"
	export REPL_BUFSIZE="4096"      # journal buffer size in 512-byte blocks
	export REPL_AUTOSWITCH=8388600  # ~800MB
	export gtm_buffer_size="${REPL_BUFSIZE}"
	export gtm_repl_instname="forumaforum"
	export gtm_repl_instsecondary="forumbforum"

## Default Database characteristics

  Access method                          BG  Global Buffers                1024
  Reserved Bytes                          0  Block size (in bytes)         4096
  Maximum record size                  4080  Starting VBN                   513
  Maximum key size                      355  Total blocks            0x00061D8F
  Null subscripts                     NEVER  Free blocks             0x0001BDFE
  Standard Null Collation             FALSE  Free space              0x00000000
  Last Record Backup     0x0000000000000001  Extension Count                  0
  Last Database Backup   0x0000000003D3A4E9  Number of local maps           783
  Last Bytestream Backup 0x0000000000000001  Lock space              0x000003E8
  In critical section            0x00000000  Timers pending                   1
  Cache freeze id                0x00000000  Flush timer            00:00:01:00
  Freeze match                   0x00000000  Flush trigger                  960
  Current transaction    0x0000000003D4A81F  No. of writes/flush              7
  Maximum TN             0xFFFFFFFF83FFFFFF  Certified for Upgrade to        V6
  Maximum TN Warn        0xFFFFFFFD93FFFFFF  Desired DB Format               V6
  Master Bitmap Size                    496  Blocks to Upgrade       0x00000000
  Create in progress                  FALSE  Modified cache blocks            1
  Reference count                         6  Wait Disk                        0
  Journal State                          ON  Journal Before imaging        TRUE
  Journal Allocation                   2048  Journal Extension               10
  Journal Buffer Size                  4096  Journal Alignsize             4096
  Journal AutoSwitchLimit           8388598  Journal Epoch Interval         300
  Journal Yield Limit                     8  Journal Sync IO              FALSE
  Journal File: /home/forum/j/default.mjl
  Mutex Hard Spin Count                 128  Mutex Sleep Spin Count         128
  Mutex Queue Slots                    1024  KILLs in progress                0
  Replication State                      ON  Region Seqno    0x000000000022D19F
  Zqgblmod Seqno         0x0000000000000000  Zqgblmod Trans  0x0000000000000000
  Endian Format                      LITTLE  Commit Wait Spin Count          16
  Database file encrypted             FALSE  Inst Freeze on Error         FALSE
  Spanning Node Absent                 TRUE  Maximum Key Size Assured      TRUE

# GDE Configuration
									*** SEGMENTS ***
	 Segment                         File (def ext: .dat)Acc Typ Block      Alloc Exten Options
	 -------------------------------------------------------------------------------------------
	 DEFAULT                         $DBINST/g/default.dat
														 BG  DYN  4096     400000     0 GLOB=1024
																						LOCK=1000
																						RES =   0
																						ENCR=OFF
	 TEMPGBL                         $DBINST/g/tempgbl.dat
														 BG  DYN  4096      10000     0 GLOB=1024
																						LOCK=1000
																						RES =   0
																						ENCR=OFF
		
									*** REGIONS ***
																									Std      Inst
									 Dynamic                          Def      Rec   Key Null       Null     Freeze   Qdb
	 Region                          Segment                         Coll     Size  Size Subs       Coll Jnl on Error Rndwn
	 --------------------------------------------------------------------------------------------------------------------------
	 DEFAULT                         DEFAULT                            0     4080   355 NEVER      N    N   DISABLED DISABLED
	 TEMPGBL                         TEMPGBL                            0     4080   355 NEVER      N    N   DISABLED DISABLED

			 *** NAMES ***
	 Global                             Region
	 ------------------------------------------------------------------------------
	 *                                  DEFAULT
	 HLTMP                              TEMPGBL
	 TMP                                TEMPGBL
	 UTILITY                            TEMPGBL
	 XTMP                               TEMPGBL
	 XUTL                               TEMPGBL
