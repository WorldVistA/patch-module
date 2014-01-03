# VISTA Configuration
## Baseline Routines and Globals
Cloned from <https://github.com/OSEHRA/VistA-M> on December 25th 2013.

Applied fixes for GT.M:
https://github.com/OSEHRA/VistA/blob/master/Testing/Setup/XINDX2.ro
https://github.com/OSEHRA/VistA/blob/master/Testing/Setup/ZTLOAD1.ro


## ZTMGRSET

	UCI,VOLUME SET: DEV,FORUM
	Temp Directory: /tmp/

## DINIT
VA Forum is at 120. We chose 121 for OSEHRA forum.

	SITE NAME: FORUM.OSEHRA.ORG
	SITE NUMBER: 121

## Taskman configuration (done automatically using ^KBANTCLN)
### VOLUME SET (#14.5)

	VOLUME SET: FORUM                       INHIBIT LOGONS?: NO
	  OUT OF SERVICE?: NO                   REQUIRED VOLUME SET?: NO
	  TASKMAN FILES UCI: DEV                DAYS TO KEEP OLD TASKS: 0
	  TYPE: GENERAL PURPOSE VOLUME SET      SIGNON/PRODUCTION VOLUME SET: Yes
	
### UCI ASSOCIATION (#14.6)

	NUMBER: 1                               FROM UCI: DEV
	  FROM VOLUME SET (FREE TEXT): FORUM    FROM VOLUME SET: FORUM
	
### TASKMAN SITE PARAMETERS (#14.7)

	BOX-VOLUME PAIR: FORUM:forum-a          SUBMANAGER RETENTION TIME: 0
	  TASKMAN JOB LIMIT: 24                 TASKMAN HANG BETWEEN NEW JOBS: 0
	  MODE OF TASKMAN: GENERAL PROCESSOR    MIN SUBMANAGER CNT: 0
	  Auto Delete Tasks: Yes                Manager Startup Delay: 1

### OPTION SCHEDULING (#19.2)

	OPTION SCHEDULING List                                 JAN 3,2014@11:10   PAGE 1
	--------------------------------------------------------------------------------

	NAME: XUSER-CLEAR-ALL                   SPECIAL QUEUEING: STARTUP

	NAME: XUDEV RES-CLEAR                   SPECIAL QUEUEING: STARTUP

	NAME: XU PROC CNT CLUP
	  QUEUED TO RUN AT WHAT TIME: JAN 3,2014@11:22
	  RESCHEDULING FREQUENCY: 1H            TASK ID: 190

	NAME: XMAUTOPURGE
	  QUEUED TO RUN AT WHAT TIME: JAN 4,2014@00:10
	  RESCHEDULING FREQUENCY: 1D            TASK ID: 156

	NAME: XMCLEAN
	  QUEUED TO RUN AT WHAT TIME: JAN 4,2014@00:15
	  RESCHEDULING FREQUENCY: 1D            TASK ID: 157

	NAME: XQBUILDTREEQUE
	  QUEUED TO RUN AT WHAT TIME: JAN 4,2014@00:20
	  RESCHEDULING FREQUENCY: 1D            TASK ID: 158

	NAME: XQ XUTL $J NODES
	  QUEUED TO RUN AT WHAT TIME: JAN 4,2014@00:25
	  RESCHEDULING FREQUENCY: 1D            TASK ID: 160

	NAME: XUERTRP AUTO CLEAN
	  QUEUED TO RUN AT WHAT TIME: JAN 4,2014@00:30
	  RESCHEDULING FREQUENCY: 1D            TASK ID: 161

	NAME: XUTM QCLEAN
	  QUEUED TO RUN AT WHAT TIME: JAN 4,2014@00:35
	  RESCHEDULING FREQUENCY: 1D            TASK ID: 162

### Volume Set in KSP

				  MAX   LOG
	VOLUME     SIGNON   SYSTEM
	SET        ALLOWED  RT?
	--------------------------------------------------------------------------------

	FORUM          30   

## Fileman Upgrade
Fileman 22.2 was installed. See <http://flap.vistaexpertise.net/>.

## Device configuration
I fixed GTM-UNIX-CONSOLE so that SIGN-ON/SYSTEM DEVICE is YES.
Other Null devices had to be renamed to make sure there is only one Null.

	NAME: GTM-UNIX-CONSOLE                  $I: /dev/tty
	  ASK DEVICE: YES                       SIGN-ON/SYSTEM DEVICE: YES
	  LOCATION OF TERMINAL: Console (GT.M)
	MNEMONIC: GTM-LINUX-CONSOLE
	MNEMONIC: CONSOLE
	  SUBTYPE: C-VT100                      TYPE: VIRTUAL TERMINAL


	NAME: GTM-UNIX-TELNET                   $I: /dev/pts/
	  ASK DEVICE: YES                       SIGN-ON/SYSTEM DEVICE: YES
	  QUEUING: ALLOWED                      LOCATION OF TERMINAL: TELNET
	  ASK HOST FILE: YES                    OPEN COUNT: 427
	MNEMONIC: GTM-LINUX-TELNET
	MNEMONIC: TELNET
	  SUBTYPE: C-VT320                      TYPE: VIRTUAL TERMINAL


	NAME: NULL                              $I: /dev/null
	  SIGN-ON/SYSTEM DEVICE: NO
	  LOCATION OF TERMINAL: Bit Bucket (GT.M-Unix)
	  OPEN COUNT: 459
	MNEMONIC: GTM-LINUX-NULL
	MNEMONIC: GTM-UNIX-NULL
	  SUBTYPE: P-OTHER                      TYPE: TERMINAL

## Mailman configuration
### Forum Instance Domain Name Creation
All of these are entries in the domain file.

#### Main Domain 
TURN enabled so that it can function as a mail drop.

	NAME: FORUM.OSEHRA.ORG                  DISABLE TURN COMMAND: NO

#### Patches Domain
Must be entered so that Mailman will know to store the messages and
not forward them.

	NAME: Q-PATCH.OSEHRA.ORG

#### Mailman External SMTP Gateway
GW.OSEHRA.ORG (named per mailman/Forum code usage) sends emails out using Postfix.
Postfix listens on 10025 ONLY on localhost.

	NAME: GW.OSEHRA.ORG                     FLAGS: S
	  STATION: 121                          DISABLE TURN COMMAND: YES
	TRANSMISSION SCRIPT: MAIN               PRIORITY: 1
	  NUMBER OF ATTEMPTS: 2                 TYPE: Simple Mail Transfer Protocol
	  PHYSICAL LINK / DEVICE: NULL
	  NETWORK ADDRESS (MAILMAN HOST): 127.0.0.1
	 TEXT:   
	 O H="127.0.0.1",P=TCP/GTM
	 X S XMRPORT=10025
	 C TCPCHAN-SOCKET25/GTM
	SYNONYM: ORG
	SYNONYM: COM
	SYNONYM: INFO
	SYNONYM: NAME
	SYNONYM: US
	SYNONYM: UK
	SYNONYM: NET
	SYNONYM: IN
	SYNONYM: JO

### Remote Instance Domain Name Creation
To send messages to FORUM.OSEHRA.ORG from your own VISTA system, you can send
it via the internet by setting up postfix and having it do the work for you 
(as above). An easier alternative is to configure a direct link, as follows:
(NB: This example is only for GT.M. Use the Cache Mailman Conduits for Cache.)

	NAME: Q-PATCH.OSEHRA.ORG                FLAGS: Q
	TRANSMISSION SCRIPT: MAIN               PRIORITY: 1
	  NUMBER OF ATTEMPTS: 2                 TYPE: Simple Mail Transfer Protocol
	  PHYSICAL LINK / DEVICE: NULL
	  NETWORK ADDRESS (MAILMAN HOST): FORUM.OSEHRA.ORG
	 TEXT:   
	 O H="FORUM.OSEHRA.ORG",P=TCP/GTM
	 C TCPCHAN-SOCKET25/GTM

