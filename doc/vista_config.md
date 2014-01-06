# Forum System Configuration

## MASTER PARAMTERS
If you don't want to read any of the rest of this, this is the summary of
the VISTA system configuration.

 * UCI: DEV
 * VOLUME SET: FORUM
 * SITE NUMBER: 121
 * INERNET DOMAIN NAMES: FORUM.OSEHRA.ORG (A), Q-PATCH.OSEHRA.ORG [MX].

## Baseline Routines and Globals
Cloned from <https://github.com/OSEHRA/VistA-M> on December 25th 2013.

Applied fixes for GT.M:
 * <https://github.com/OSEHRA/VistA/blob/master/Testing/Setup/XINDX2.ro>
 * <https://github.com/OSEHRA/VistA/blob/master/Testing/Setup/ZTLOAD1.ro>

My random utility routines for VISTA were imported into the system:
<https://github.com/shabiel/random-vista-utilities>

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
All of these are entries in the DOMAIN (#4.2) file.

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
To send messages to Q-PATCH.OSEHRA.ORG from your own VISTA system, you can send
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

### Chistening
System is chistened using menu option XMCHIRS as FORUM.OSEHRA.ORG with parent
GW.OSEHRA.ORG in EDT Time Zone.

### Pointing KSP and RSP to new Domain
Domain FORUM.OSEHRA.ORG has an IEN of 76.

    DEV,FORUM>S $P(^XTV(8989.3,1,0),"^")=76
    DEV,FORUM>S $P(^XWB(8994.1,1,0),"^")=76

Re-index the files after making this change.

	DEV,FORUM>F DIK="^XTV(8989.3,","^XWB(8994.1," S DA=1 D IXALL2^DIK,IXALL^DIK

### Identifying local mail for relay
In the MAILMAN SITE PARAMTERS file (#4.3), the MY DOMAINS multiple contains
.OSEHRA.ORG as one of the sites we can relay mail for. Without that, mailman
will reject incoming messages coming for us.

### Postfix configuration
Postfix's function is to send emails to the outside world from VISTA.

In `/etc/postfix/main.cf`, `mynetworks_style = host` was added to have postfix
only listen to the localhost for messages.

In `/etc/postfix/master.cf`, comment out the smtp line and add a line for
listening on 10025.

	#smtp      inet  n       -       n       -       -       smtpd # VEN/SMH - don't listen on 25 but on 10025
	10025      inet  n       -       n       -       -       smtpd

### XMRUCX routine changes for xinetd support
Add this code to the bottom of the routine.

	GTMLNX  ;From Linux xinetd script
	 S U="^",$ETRAP="D ^%ZTER S ZZIO=$ZIO H 33 D R^XMCTRAP Q"
	 ;S (XMRPORT,IO,IO(0))=$P X "U XMRPORT:(nowrap:delimiter=$C(13))" 
	 S (XMRPORT,IO,IO(0))=$P X "U XMRPORT:(nowrap:delimiter=$C(13):ioerror=""GTMIOER"")"
	 S @("$ZINTERRUPT=""I $$JOBEXAM^ZU($ZPOSITION)""")
	 ;GTM specific code
	 S %="",@("%=$ZTRNLNM(""REMOTE_HOST"")") S:$L(%) IO("GTM-IP")=%
	 D SETNM^%ZOSV($E(XMRPORT_"INETMM",1,15)),COUNT^XUSCNT(1) ;Process counting under GT.M
	 S XMCHAN="TCP/GTM",XMNO220=""
	 N DIQUIET S DIQUIET=1 D DT^DICRW,DUZ^XUP(.5)
	 D ENT^XMR
	 D COUNT^XUSCNT(-1) ;Check out GT.M counting
	 Q
	GTMIOER ; For Sam...
	 D COUNT^XUSCNT(-1)
	 QUIT

### Create xinetd service and shell script
Create a xinetd service listening on port 25 to run the shell script.

	[forum@forum-a ~]$ cat /etc/xinetd.d/mailman-forum-smtp-25 
	# Written by Sam Habiel on 30 Dec 2013 for Mailman

	service mailman-forum-smtp-25
	{
			port        = 25
			socket_type = stream
			protocol    = tcp
			type        = UNLISTED
			user        = forum
			server      = /home/forum/bin/mailman_smtp.sh
			wait        = no
			disable     = no
			per_source  = UNLIMITED
			instances   = UNLIMITED
			env         =  HOME=/home/forum
	}

Shell script that invokes `GTMLNX^XMRUCX`:

	[forum@forum-a ~]$ cat /home/forum/bin/mailman_smtp.sh
	#!/bin/bash
	# Written by Sam Habiel on 30 December 2013

	cd  # goto home directory
	source /home/forum/bin/set_env 

	$gtm_dist/mumps -run GTMLNX^XMRUCX 2>> /home/forum/log/mailman.log

### Firewall
Not VISTA related, but the Firewall was modified to to allow port 25 in.

### DNS Records
* FORUM.OSEHRA.ORG (A)
* Q-PATCH.OSEHRA.ORG (MX)
* FORUM.OSHERA.ORG (SPF) (NOT COMPLETED YET)
* REVERSE DNS TO FORUM.OSHERA.ORG (NOT COMPLETED YET)

Dig output:

	sakura@icarus:~$ dig forum.osehra.org ANY +short
	10 forum.osehra.org.
	23.253.7.225
	sakura@icarus:~$ dig q-patch.osehra.org ANY +short
	10 q-patch.osehra.org.
	23.253.7.225

Host output:

	sakura@icarus:~$ host 23.253.7.225
	Host 225.7.253.23.in-addr.arpa. not found: 3(NXDOMAIN)

### Testing
Testing was done using netcat and telnet to confirm that the VISTA SMTP service 
works. Testing was done also by making a direct link between two VISTA instances
and using the script runner (shown below) to send the message.

Sending emails to external domains using VISTA was tested from VISTA's script
runner. First change the domain to Queue in the domain file rather than send,
and when you send a message, run the script runner.

First, XMMGR > XMNET > XMNET-TRANSMISSION-MANAGEMENT, then...

	Select Transmission Management <TEST ACCOUNT> Option: EDIT a script
	Select DOMAIN NAME:    GW.OSEHRA.ORG                   0 msgs
	PHYSICAL LINK DEVICE: 
	FLAGS: S// Q
	SECURITY KEY: ^
	TRANSMISSION TASK#: ^

Second, send a message

	Select Transmission Management <TEST ACCOUNT> Option: "MAILMAN

	VA MailMan 8.0 service for POSTMASTER@FORUM.OSEHRA.ORG
	You last used MailMan: 01/03/14@14:13
	You have no new messages.


	   NML    New Messages and Responses
	   RML    Read/Manage Messages
	   SML    Send a Message
			  Query/Search for Messages
	   AML    Become a Surrogate (SHARED,MAIL or Other)
			  Personal Preferences ...
			  Other MailMan Functions ...
			  Help (User/Group Info., etc.) ...

	Select MailMan Menu <TEST ACCOUNT> Option: SML  Send a Message

	Subject: TEST
	You may enter the text of the message...
	  1>TEST
	  2>
	EDIT Option: 
	Send mail to: POSTMASTER// SAM.HABIEL@GMAIL.COM  GW.OSEHRA.ORG via GW.OSEHRA.ORG
	 (Queued)
	And Send to: 

	Select Message option: Transmit now// Sending [69]...
	  Sent

Thrid, transmit using the script runner.

	Select Transmission Management <TEST ACCOUNT> Option: play a script
	Select DOMAIN NAME: gw.OSEHRA.ORG                      1 msgs

	  #  Script Name              Type      Priority
	 --  -----------              ----      --------
	  1  MAIN                     SMTP       1

	14:16:06 To GW.OSEHRA.ORG from FORUM.OSEHRA.ORG on 1/3/2014
	14:16:06 Script: MAIN
	14:16:06 O H="127.0.0.1",P=TCP/GTM
	14:16:06 Channel opened to GW.OSEHRA.ORG
	14:16:06 Device 'NULL', Protocol 'TCP/GTM' (file 3.4)
	14:16:06 Xecuting 'S XMRPORT=10025'
	14:16:06 C TCPCHAN-SOCKET25/GTM
	14:16:06 Calling script 'TCPCHAN-SOCKET25/GTM' (file 4.6)
	14:16:06 Xecuting 'L +^XMBX("TCPCHAN",XMHOST):99 E  S ER=1,XMER="CHANNEL IN USE"
	'
	14:16:06 Xecuting 'S X="ERRSCRPT^XMRTCP",@^%ZOSF("TRAP")'
	14:16:06 Xecuting 'S XMRPORT=$G(XMRPORT,25)'
	14:16:06 Xecuting 'D CALL^%ZISTCP(XMHOST,XMRPORT) I POP S ER=1 L -^XMBX("TCPCHAN
	",XMHOST)'
	14:16:06 Xecuting 'S XMHANG="D CLOSE^%ZISTCP"'
	14:16:06 Xecuting 'U IO:(DELIMITER=$C(13))'
	14:16:06 Look: Timeout=45, Command String='220'
	14:16:06 R: 220
	14:16:06 Beginning sender-SMTP service
	14:16:06 R:  forum-a.osehra.org ESMTP Postfix
	14:16:06 S: NOOP
	14:16:06 R: 250 2.0.0 Ok
	14:16:06 S: HELO FORUM.OSEHRA.ORG
	14:16:06 R: 250 forum-a.osehra.org
	14:16:06 S: MAIL FROM:<POSTMASTER@FORUM.OSEHRA.ORG>
	14:16:06 R: 250 2.1.0 Ok
	14:16:06 S: RCPT TO:<SAM.HABIEL@GMAIL.COM>
	14:16:06 R: 250 2.1.5 Ok
	14:16:06 S: DATA
	14:16:06 R: 354 End data with <CR><LF>.<CR><LF>
	14:16:06 S: Subject: TEST
	14:16:06 S: Date: 3 Jan 2014 14:14:40 -0400 (EDT)
	14:16:06 S: Message-ID: <69.3140103@FORUM.OSEHRA.ORG>
	14:16:06 S: From: <POSTMASTER@FORUM.OSEHRA.ORG>
	14:16:06 S: To: SAM.HABIEL@GMAIL.COM
	14:16:06 S: 
	14:16:06 S: TEST
	14:16:06 S: .
	14:16:06 R: 250 2.0.0 Ok: queued as 9E45213E0DE
	14:16:07 TURN command disabled for GW.OSEHRA.ORG
	14:16:07 S: QUIT
	14:16:07 R: 221 2.0.0 Bye
	14:16:07 Xecuting 'L -^XMBX("TCPHAN",XMHOST) K XMSIO'
	14:16:07 Returning to script 'MAIN'.
	14:16:07 Script complete.
	14:16:07 1 sent, 0 received.

### Extra config item
There was an old domain with a transmission script that was failing. This was
deleted from the domain file and the entries pointing to it were repointed to
FORUM.OSEHRA.ORG.

## Insitution and Station Set-up
The OSEHRA FORUM institution was modeled after the FORUM institution, except
that it has the station number of 121 instead of FORUM's 120.

	Select INSTITUTION NAME: OSEHRA FORUM    VA  OTHER  121  
	Another one: 
	Standard Captioned Output? Yes//   (Yes)
	Include COMPUTED fields:  (N/Y/R/B): NO//  - No record number (IEN), no Computed
	 Fields

	NAME: OSEHRA FORUM                      STATE: VIRGINIA
	  STATUS: National
	  STREET ADDR. 1: Virginia Tech Research Building
	  STREET ADDR. 2: 900 North Glebe Road, Suite 4-009
	  CITY: ARLINGTON                       ZIP: 22203
	CONTACT: MAIN                           PHONE #: (571) 858-3061
	  FACILITY TYPE: OTHER                  DOMAIN: FORUM.OSEHRA.ORG
	  STATION NUMBER: 121                   OFFICIAL VA NAME: OSEHRA FORUM
	  AGENCY CODE: EHR                      POINTER TO AGENCY: EHR
	CODING SYSTEM: VASTANUM                 ID: 121

The lone entry in the `STATION NUMBER (TIME SENSITIVE)` file was modified to
look as follows:

	Output from what File: INSTITUTION// STATION NUMBER (TIME SENSITIVE)  
											  (1 entry)

	Select STATION NUMBER (TIME SENSITIVE) REFERENCE NUMBER: 121       12-30-13     
	OSEHRA FORUM     121
	Another one: 
	Standard Captioned Output? Yes//   (Yes)
	Include COMPUTED fields:  (N/Y/R/B): NO//  - No record number (IEN), no Computed
	 Fields

	REFERENCE NUMBER: 121                   EFFECTIVE DATE: DEC 30,2013
	  MEDICAL CENTER DIVISION: OSEHRA FORUM
	  STATION NUMBER: 121                   IS PRIMARY DIVISION: YES

The lone entry in the `MEDICAL CENTER DIVISION` file was modified to point to
the correct institution and modified to have the right station number.

	Output from what File: STATION NUMBER (TIME SENSITIVE)// medical cenTER DIVISION
											  (1 entry)
	Select MEDICAL CENTER DIVISION NAME: `1  OSEHRA FORUM     121
	Another one: 
	Standard Captioned Output? Yes//   (Yes)
	Include COMPUTED fields:  (N/Y/R/B): NO//  - No record number (IEN), no Computed
	 Fields

	NUM: 1                                  NAME: OSEHRA FORUM
	  FACILITY NUMBER: 121                  INSTITUTION FILE POINTER: OSEHRA FORUM

To test all these changes, the API `$$SITE^VASITE` should return the correct
data:

	DEV,FORUM>W $$SITE^VASITE
	2957^OSEHRA FORUM^121
	DEV,FORUM>W $$PRIM^VASITE
	1

Not strictly necessary on this system, but we need to change the 
`MASTER PATIENT INDEX (LOCAL NUMBERS)` file to have the right station number.

	Output from what File: MEDICAL CENTER DIVISION// MASTER PATIENT INDEX (LOCAL NUM
	BERS)                                     (1 entry)
	Select MASTER PATIENT INDEX (LOCAL NUMBERS) SITE ID NUMBER: `1  121
	Another one: 
	Standard Captioned Output? Yes//   (Yes)
	Include COMPUTED fields:  (N/Y/R/B): NO//  - No record number (IEN), no Computed
	 Fields

	SITE ID NUMBER: 121                     LAST NUMBER USED: 500000000
	  CHECK SUM FOR LAST NUMBER USED: 217407
	  NEXT NUMBER TO USE: 500000001         CHECK SUM FOR NEXT: 075322

## Kernel Site Parameters adjustments
These are just a few tweaks to make sure the system is configured properly.

 * DEFAULT INSTITUTION -> OSEHRA FORUM
 * AGENCY CODE -> EHR
 * MULTIPLE SIGN-ON -> YES
 * AUTO-MENU -> YES
 * DEFAULT HFS DIRECTORY -> /tmp/
 * DNS IPs -> (same as those in /etc/resolve.conf)

## VISTA system local mods
Lloyd Milligan's excellent ZSY routine for M process monitoring was downloaded
from <http://www.seaislandsystems.com/ZSY/ZSY.m> and applied. For it to be
invoked, JOBEXAM+1^ZU needs to be

	 I $T(NTRUPT^ZSY)]"" D NTRUPT^ZSY Q 1; SIS/LM - Custom interrupt completion

I made that change ZUGTM and then ran ^ZUSET.

As mentioned before, XMRUCX now has an entry point for GTMLNX for xinetd entry.
XMRUCX has an issue right now with TCP alive checks which tend to invoke the
boiler plate code for process set-up in VISTA. I need to fix that before
deciding that XMRUCX is good enough.

Because of this same issue, the process counting in %ZOSV for GT.M (already
pretty awful) was not working. I got Bhaskar's %ZOSV routine, changed the
process counting code so that it doesn't use a global reference, fixed another
bug in $$RTNDIR, and modified COUNT^XUSCNT so that it is a no op. I would
have liked to make CLEAR^XUSCNT a no op as well, but I have to fix the
mailman problem first as it is setting ^XUTL("XUSYS") nodes and they are only
cleaned by CLEAR^XUSCNT.

Joel Ivey's M-Tools (XT*7.3*81) was applied. I then applied my modified
routines (XTMUNIT and XTMUNIT1) from the vista-less-branch
<https://github.com/shabiel/M-Tools/tree/vista-less-support/Utilities%20XT_7.3_81%20not%20yet%20released>.
I plan to put these in the main KIDS build once I have unit tests for 
everything I changed in there and can prove to my satisfaction that everything
is still working.
