# Forum Subscription Instructions

*** PORT 25 WARNING ***

Port 25 is frequently abused. If you are on a residential internet connections, it is very likely that you will not be able to send anything over port 25. If you try these instructions on a local machine at a residential address, you will fail. You must do this on a business connection. An easy way to obtain a business connections is by ssh'ing into a cloud server; e.g. AWS, Rackspace, or DigitalOcean.

If you set-up port 25 for your server, esp. if you are holding patient data, make sure you follow the following steps:

1. Use XINETD rather than Mumps to listen to port 25.
2. Restrict XINETD to one process
3. Restrict XINETD to traffic from forum.osehra.org

See this page for more information:

https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/3/html/Reference_Guide/s1-tcpwrappers-xinetd-config.html

# Setting up your system in order to become a subscriber
We won't go over configuring each item in detail as most of that should have been done by you or your agent when first setting up a VISTA system.

## Pre-requisites

 * VISTA domain configuration is complete
 * NULL device must work correctly
 * Taskman must be running
 * Mailman Background Filer is running
 * DNS on VISTA must be functional
 * Have at least one active user (i.e. must have access and verify code and can sign in)

If you are on GT.M, make sure that you fix bug with $$RETURN^%ZOSV so it won't
steal your device.

To check that your domain configuration is complete in VISTA, all of these three calls must return the same result.

```
VISTA>W ^DD("SITE")
MEMPHIS.SMH101.COM
VISTA>W ^XMB("NETNAME")
MEMPHIS.SMH101.COM
VISTA>W $$GET1^DIQ(8989.3,1,.01)
MEMPHIS.SMH101.COM
```

## Steps
### Install Patch Client KIDS build
Ask your Forum Contact for the Patch Client KIDS build and install it. 

```
Select Installation <TEST ACCOUNT> Option: 1  Load a Distribution
Enter a Host File: /home/sam/repos/patch-module/KID/PATCH_CLIENT_2P5_150703B.KID



KIDS Distribution saved on Jul 03, 2015@21:27:34
Comment: Patch Client 2.5

This Distribution contains Transport Globals for the following Package(s):
Build PATCH CLIENT 2.5 has been loaded before, here is when: 
      PATCH CLIENT 2.5   Install Completed
                         was loaded on Jul 03, 2015@14:03:45
OK to continue with Load? NO// YES

Distribution OK!

Want to Continue with Load? YES//  
Loading Distribution...

   PATCH CLIENT 2.5
Use INSTALL NAME: PATCH CLIENT 2.5 to install this Distribution.



   1      Load a Distribution
   2      Verify Checksums in Transport Global
   3      Print Transport Global
   4      Compare Transport Global to Current System
   5      Backup a Transport Global
   6      Install Package(s)
          Restart Install of Package(s)
          Unload a Distribution

Select Installation <TEST ACCOUNT> Option: 6  Install Package(s)
Select INSTALL NAME:    PATCH CLIENT 2.5     Loaded from Distribution    7/3/15@
14:55:01
     => Patch Client 2.5  ;Created on Jul 03, 2015@21:27:34

This Distribution was loaded on Jul 03, 2015@14:55:01 with header of 
   Patch Client 2.5  ;Created on Jul 03, 2015@21:27:34
   It consisted of the following Install(s):
PATCH CLIENT 2.5
Checking Install for Package PATCH CLIENT 2.5

Install Questions for PATCH CLIENT 2.5

Incoming Files:


   11004     PATCH
Note:  You already have the 'PATCH' File.


   11007.1   DHCP PATCH STREAM
Note:  You already have the 'DHCP PATCH STREAM' File.

Incoming Mail Groups:

Enter the Coordinator for Mail Group 'A1AESTRMCHG': POSTMASTER//            

Want KIDS to Rebuild Menu Trees Upon Completion of Install? NO// 


Want KIDS to INHIBIT LOGONs during the install? NO// 
Want to DISABLE Scheduled Options, Menu Options, and Protocols? NO// 

Enter the Device you want to print the Install messages.
You can queue the install by enter a 'Q' at the device prompt.
Enter a '^' to abort the install.

DEVICE: HOME// ;P-OTHER;  TELNET

 
 Install Started for PATCH CLIENT 2.5 : 
               Jul 03, 2015@14:55:10
 
Build Distribution Date: Jul 03, 2015
 
 Installing Routines:............
               Jul 03, 2015@14:55:11
 
 Installing Data Dictionaries: ...
               Jul 03, 2015@14:55:11
 
 Installing PACKAGE COMPONENTS: 
 
 Installing HELP FRAME..
 
 Installing SECURITY KEY..
 
 Installing INPUT TEMPLATE..
 
 Installing MAIL GROUP..
 
 Installing OPTION...
               Jul 03, 2015@14:55:11
 
 Running Post-Install Routine: ^A1AE2POS.
 
 Updating Routine file......
 
 Updating KIDS files.......
 
 PATCH CLIENT 2.5 Installed. 
               Jul 03, 2015@14:55:21
 
 NO Install Message sent 
```

### Add a new domain, `FORUM.OSEHRA.ORG` to your DOMAIN (#4.2) File. 
This is a simple fileman entry where you just need to enter the name.

### Re-christen your domain, this time making `FORUM.OSEHRA.ORG` is the parent

```
GTM>D ^XMUDCHR



         * * * *  WARNING  * * * *

You are about to change the domain name of this facility
in the MailMan Site Parameters file.

Currently, this facility is named: FOIA.DOMAIN.EXT

You must be extremely sure before you proceed!

Are you sure you want to change the name of this facility? NO// YES
Select DOMAIN NAME: FOIA.DOMAIN.EXT// HELIOPOLIS.SMH101.COM

The domain name for this facility is now: HELIOPOLIS.SMH101.COM
PARENT: DOMAIN.EXT// FORUM.OSEHRA.ORG
TIME ZONE: EST// PST       PACIFIC STANDARD

FORUM.OSEHRA.ORG has been initialized as your 'parent' domain.
(Forum is usually the parent domain, unless this is a subordinate domain.)

You may edit the MailMan Site Parameter file to change your parent domain.

We will not initialize your transmission scripts.

Use the 'Subroutine editor' option under network management menu to add your
site passwords to the MINIENGINE script, and the 'Edit a script' option
to edit any domain scripts that you choose to.
```

### Set-up Mailman Transmission Script to Forum
While it's possible to send email to Forum via a regular SMTP server, this will require more set-up on your side.

Instead, here we set-up a DIRECT Polling connection to Forum. Please note the Cache vs. GT.M section below. If you use another MUMPS Virtual Machine, please consult your FORUM contact for more information.

Use the menu option `Edit a script [XMSCRIPTEDIT]`

```
   Select Transmission Management <TEST ACCOUNT> Option: EDIT a script
Select DOMAIN NAME: FORUM.OSEHRA.ORG                   0 msgs
PHYSICAL LINK DEVICE: NULL Stored internally as NULL  
FLAGS: SP
SECURITY KEY:
VALIDATION NUMBER:
NEW VALIDATION NUMBER:
DISABLE TURN COMMAND: N  NO
RELAY DOMAIN:
Select TRANSMISSION SCRIPT: MAIN
  Are you adding 'MAIN' as a new TRANSMISSION SCRIPT (the 1ST for this DOMAIN)?
 No// Y  (Yes)
  PRIORITY: 1
  NUMBER OF ATTEMPTS: 3
  TYPE: SMTP  Simple Mail Transfer Protocol
  PHYSICAL LINK / DEVICE: NULL Stored internally as NULL
  NETWORK ADDRESS (MAILMAN HOST): FORUM.OSEHRA.ORG
  OUT OF SERVICE:
  TEXT:
    No existing text
    Edit? NO// YES

==[ WRAP ]==[ INSERT ]================< TEXT >===============[ <PF1>H=Help ]====
O H="FORUM.OSEHRA.ORG",P=TCP/GTM
C TCPCHAN-SOCKET25/GTM
```

On Cache, you have to change the text above to say:
```
O H="FORUM.OSEHRA.ORG",P=TCP/IP-MAILMAN
C TCPCHAN-SOCKET25/CACHE/NT
```

### Test transmission script
This will test whether you can connect to Forum. This is a very important QA step.

Use menu option `Play a script [XMSCRIPTPLAY]`:
```
Select Transmission Management <TEST ACCOUNT> Option: PLay a script
Select DOMAIN NAME:    FORUM.OSEHRA.ORG                0 msgs

  #  Script Name              Type      Priority
 --  -----------              ----      --------
  1  MAIN                     SMTP       1

15:10:44 To FORUM.OSEHRA.ORG from HELIOPOLIS.SMH101.COM on 7/3/2015
15:10:44 Script: MAIN
15:10:44 O H="FORUM.OSEHRA.ORG",P=TCP/GTM
15:10:44 Channel opened to FORUM.OSEHRA.ORG
15:10:44 Device 'NULL', Protocol 'TCP/GTM' (file 3.4)
15:10:44 C TCPCHAN-SOCKET25/GTM
15:10:44 Calling script 'TCPCHAN-SOCKET25/GTM' (file 4.6)
15:10:44 Xecuting 'L +^XMBX("TCPCHAN",XMHOST):99 E  S ER=1,XMER="CHANNEL IN USE"
'
15:10:44 Xecuting 'S X="ERRSCRPT^XMRTCP",@^%ZOSF("TRAP")'
15:10:44 Xecuting 'S XMRPORT=$G(XMRPORT,25)'
15:10:44 Xecuting 'D CALL^%ZISTCP(XMHOST,XMRPORT) I POP S ER=1 L -^XMBX("TCPCHAN
",XMHOST)'
15:10:44 Xecuting 'S XMHANG="D CLOSE^%ZISTCP"'
15:10:44 Xecuting 'U IO:(DELIMITER=$C(13))'
15:10:44 Look: Timeout=45, Command String='220'
15:10:46 R: 220
15:10:46 Beginning sender-SMTP service
15:10:46 R:  FORUM.OSEHRA.ORG MailMan 8.0 ready
15:10:46 S: NOOP
15:10:47 R: 250 OK
15:10:47 S: HELO HELIOPOLIS.SMH101.COM
15:10:47 R: 250 OK FORUM.OSEHRA.ORG [8.0,DUP,SER,FTP]
15:10:47 There are no messages in the queue to send
15:10:47 S: TURN
15:10:47 R: 502 FORUM.OSEHRA.ORG has TURN disabled.
15:10:47 S: QUIT
15:10:47 R: 221 FORUM.OSEHRA.ORG Service closing transmission channel
15:10:47 Xecuting 'L -^XMBX("TCPHAN",XMHOST) K XMSIO'
15:10:47 Returning to script 'MAIN'.
15:10:47 Script complete.
15:10:47 0 sent, 0 received.
```

### Set-up Polling
In order to avoid having to open port 25 on your machine, it's easiest to talk
to FORUM by having it store the email for you so that you can grab it; rather
than having it send it to you via your port 25 over the Internet. To do that,
set up the job XMPOLL to run every 120 seconds. Schedule this job via 
Schedule/Unschedule Options [XUTM SCHEDULE].

### Provide your Forum contact with your VISTA Domain Name.
This is the value of ^XMB("NETNAME").
```
VISTA>W ^XMB("NETNAME")
MEMPHIS.SMH101.COM
```

### FORUM CONTACT'S Tasks
#### Add Domain to DOMAIN file.
```
Select OPTION: ENTER OR EDIT FILE ENTRIES  



Input to what File: MAIL GROUP// DOMAIN    (1095 entries)
EDIT WHICH FIELD: ALL// 


Select DOMAIN NAME: MEMPHIS.SMH101.COM
  Are you adding 'MEMPHIS.SMH101.COM' as a new DOMAIN (the 1096TH)? No// Y
  (Yes)
```
#### Add Domain to 11007.2 file
```
Select OPTION: ENTER OR EDIT FILE ENTRIES  


Input to what File: DOMAIN// 11007.2  PATCH STREAM HISTORY
                                          (3 entries)
EDIT WHICH FIELD: ALL// 


Select PATCH STREAM HISTORY DOMAIN: MEMPHIS.SMH101.COM  
  Are you adding 'MEMPHIS.SMH101.COM' as 
    a new PATCH STREAM HISTORY (the 4TH)? No// Y  (Yes)
ACTIVE PATCH STREAM: ^
```
### Set-up Change Request Mail Group
You MUST add the server option S.A1AENEWSTRM to the mail group A1AESTRMCHG.
Optionally, you should add an active user so that they can see the mail
messages going back and forth.

```
Select MAIL GROUP NAME:    A1AESTRMCHG
NAME: A1AESTRMCHG// 
Select MEMBER: 
DESCRIPTION:
Mailgroup to receive email message if the site's patch stream is 
changed.  This mailgroup notifies local users AND sends email out through 
the MEMBERS - REMOTE server S.A1AENEWSTRM to notify FORUM.

  Edit? NO// 
TYPE: public// 
ORGANIZER: USER,ONE// 
COORDINATOR: POSTMASTER// 
Select AUTHORIZED SENDER: 
ALLOW SELF ENROLLMENT?: 
REFERENCE COUNT: 3// 
LAST REFERENCED: JUL 3,2015// 
RESTRICTIONS: 
Select MEMBER GROUP NAME: 
Select REMOTE MEMBER: S.A1AENEWSTRM
  Are you adding 'S.A1AENEWSTRM@HELIOPOLIS.SMH101.COM' as 
    a new REMOTE MEMBER (the 1ST for this MAIL GROUP)? No// Y  (Yes)
Select REMOTE MEMBER: 
```
### Ask for a strem change using the standalone menu option `A1AE CHANGE SITE SUBSCRIPTION`
We are finally at the point where we can ask to change the patch stream.
subscription. Go ahead and follow the prompts below to change subscription.

Before you invoke this menu option, you need to hold the key A1AE MGR. Give
yourself that key, then run the menu option:

```
Select OPTION NAME:    A1AE CHANGE SITE SUBSCRIPTION     CHANGE SITE PATCH SUBSC
RIPTION
CHANGE SITE PATCH SUBSCRIPTION

Select DHCP PATCH STREAM NAME: ?
    Answer with DHCP PATCH STREAM PATCH NUMBER START, or NAME, or
        ABBREVIATION, or SUBSCRIPTION DATE
   Choose from:
   1            FOIA VISTA   
   10001        OSEHRA VISTA   
    
Select DHCP PATCH STREAM NAME: OSEHRA VISTA  
SUBSCRIPTION: NO// YES 

Confirm desire to switch PATCH SUBSCRIPTION? N// YES

*** Forum is being notified of your request
to change your site's SUBSCRIPTION to 
   OSEHRA VISTA***
??
     Only editable by Forum Action
     Choose from: 
       1        YES
       0        NO
SUBSCRIPTION: NO// 
```

Once you do that, you can check in your mailbox (provided that you set-up
yourself as part of the mail group A1AESTRMCHG) for the message that got sent
to Forum:

```
MailMan message for USER,ONE
Printed at MEMPHIS.SMH101.COM  07/05/15@15:08
Subj: MEMPHIS.SMH101.COM:::SUBSCRIPTION CHNG REQUEST  [#1] 07/05/15@03:06
6 lines
From: POSTMASTER  In 'IN' basket.  Automatic Deletion Date: Oct 13, 2015
Page 1
-------------------------------------------------------------------------------
SERVER:::MEMPHIS.SMH101.COM
ACTIVE SUBSCRIPTION:::1
DATE SUBSCRIPTION ACTIVE:::
REQUESTOR DUZ:::1
SWITCH TO SUBSCRIPTION:::10001
SWITCH REQUEST DATE:::3150705.030648

Local Message-ID: 1@MEMPHIS.SMH101.COM (4 recipients)

POSTMASTER         Last read: 07/05/15@03:06 [First read: 07/05/15@03:06]
USER,ONE           Last read: 07/05/15@15:08 [First read: 07/05/15@15:08]
G.A1AEFMSC@FORUM.OSEHRA.ORG Sent: 07/05/15@03:25 Time: 2 seconds
                   Message ID: 36563@FORUM.OSEHRA.ORG
                   Forwarded by: POSTMASTER 07/05/15@03:06
S.A1AENEWSTRM      Date: 07/05/15@03:06 Status: Served (hand off done)
```

### FORUM Administrator turn to approve
Once you have sent the message, the FORUM administrator needs to approve your
site to receive new streams. They do that by editing the subscription field in
file PATCH STREAM HISTORY (#11007.2):

When a message is received from your site, here is what the FORUM user should
see:
```
Output from what File: PATCH STREAM HISTORY//   (3 entries)
Select PATCH STREAM HISTORY DOMAIN:    HELIOPOLIS.SMH101.COM
Another one: 
Standard Captioned Output? Yes//   (Yes)
Include COMPUTED fields:  (N/Y/R/B): NO//  - No record number (IEN), no Computed
 Fields

DOMAIN: HELIOPOLIS.SMH101.COM           ACTIVE PATCH STREAM: FOIA VISTA
  STREAM CHANGE STATUS: WAITING FORUM APPROVAL
DATE STREAM CHANGE REQUESTED: JUL 4,2015@20:47:49
  ACTIVE SUBSCRIPTION: 1                SERVER: HELIOPOLIS.SMH101.COM
  REQUESTOR DUZ: 1                      SWITCH TO SUBSCRIPTION: 10001
  SWITCH REQUEST DATE: 3150704.204749
  MOST RECENT MSG NUMBER: HELIOPOLIS.SMH101.COM:::SUBSCRIPTION CHNG REQUEST
```

To approve, the FORUM user edits the "STREAM CHANGE STATUS". An approval
message is sent to the client.
```
Select OPTION: ENTER OR EDIT FILE ENTRIES  



Input to what File: PATCH STREAM HISTORY//   (3 entries)
EDIT WHICH FIELD: ALL// 


Select PATCH STREAM HISTORY DOMAIN:    HELIOPOLIS.SMH101.COM
DOMAIN: HELIOPOLIS.SMH101.COM// 
ACTIVE PATCH STREAM: FOIA VISTA// 
DATE PATCH STREAM ACTIVE: 
INFORMATIONAL PATCHES REQUIRED: 
INFORMATIONAL PATCHES SENT: 
STREAM CHANGE STATUS: WAITING FORUM APPROVAL// ?
     Choose from: 
       0        NO REQUESTS
       1        IN REVIEW
       2        WAITING FORUM APPROVAL
       3        CHANGE CONFIRMED
STREAM CHANGE STATUS: WAITING FORUM APPROVAL// 3  CHANGE CONFIRMED One moment. S
ending email to Client. 
Select DATE STREAM CHANGE REQUESTED: JUL 4,2015@20:47:49
         // ^
```
After approval, the FORUM administrator needs to add the G.PATCHES mail group
on your server so that it can receive anything that gets released to the 
remote receipients of the A1AE PACKAGE RELEASE mail group.

E.g.
```
Select REMOTE MEMBER: XXXXXXXX@OSEHRA.ORG// G.PATCHES@HELIOPOLIS.SMH101.COM
  Are you adding 'G.PATCHES@HELIOPOLIS.SMH101.COM' as 
    a new MEMBERS - REMOTE (the 6TH for this MAIL GROUP)? No// Y  (Yes)
Select REMOTE MEMBER: 
```

At this point, you are approved and you are subscribed to the OSEHRA Forum
stream.

For details' sake, I will print the messages that are actually sent during the
approval process.

First, this message is received.

```
Subj: SUBSCRIPTION CHNG APPROVED  [#4] 5 Jul 2015 07:28:16 -0400 (EDT)
7 lines
From: <POSTMASTER@FORUM.OSEHRA.ORG>  In 'IN' basket.
Automatic Deletion Date: Oct 12, 2015@20:01   Page 1
-------------------------------------------------------------------------------
SERVER:::MEMPHIS.SMH101.COM
ACTIVE SUBSCRIPTION:::1
DATE SUBSCRIPTION ACTIVE:::
REQUESTOR DUZ:::1
SWITCH TO SUBSCRIPTION:::10001
SWITCH REQUEST DATE:::3150705.030648
APPROVED:::YES
```
Then, your VISTA instance echoes back to FORUM that it got this message:
```
Subj: SUBSCRIPTION CHNG COMPLETED  [#5] 07/05/15@03:28  21 lines
From: POSTMASTER  In 'IN' basket.  Automatic Deletion Date: Oct 13, 2015
Page 1
-------------------------------------------------------------------------------
Received: from FORUM-A.OSEHRA.ORG by MEMPHIS.SMH101.COM (MailMan/8.0 TCP/GTM) i
d 4 ; 5 Jul 2015 03:28:20 -0800 (PST)
Received: from FORUM.OSEHRA.ORG (localhost.localdomain [127.0.0.1])
by forum-a.osehra.org (Postfix) with SMTP id 5ED5D13E13C
for <G.A1AESTRMCHG@MEMPHIS.SMH101.COM>; Sun,  5 Jul 2015 07:28:17 +0000 (UTC)
Subject: SUBSCRIPTION CHNG APPROVED
Date: 5 Jul 2015 07:28:16 -0400 (EDT)
Message-ID: <36566.3150705@FORUM.OSEHRA.ORG>
From: <POSTMASTER@FORUM.OSEHRA.ORG>
Expiry-Date: 13 Oct 2015 00:00:00 -0400 (EDT)
To: G.A1AESTRMCHG@MEMPHIS.SMH101.COM

SERVER:::MEMPHIS.SMH101.COM
ACTIVE SUBSCRIPTION:::1
DATE SUBSCRIPTION ACTIVE:::
REQUESTOR DUZ:::1
SWITCH TO SUBSCRIPTION:::10001
SWITCH REQUEST DATE:::3150705.030648
APPROVED:::YES
FORUM ACTION EDIT:::SUCCESSFUL
NEW SUBSCRIPTION DATE:::3150705.03282
NEW ACTIVE SUBSCRIPTION:::10001
```
Forum Sends back another message saying that it got the last confirmation.
```
Subj: SUBSCRIPTION CHNG CONFIRMED  [#6] 5 Jul 2015 07:28:28 -0400 (EDT)
11 lines
From: <POSTMASTER@FORUM.OSEHRA.ORG>  In 'IN' basket.
Automatic Deletion Date: Oct 12, 2015@20:01   Page 1  *New*
-------------------------------------------------------------------------------
SERVER:::MEMPHIS.SMH101.COM
ACTIVE SUBSCRIPTION:::1
DATE SUBSCRIPTION ACTIVE:::
REQUESTOR DUZ:::1
SWITCH TO SUBSCRIPTION:::10001
SWITCH REQUEST DATE:::3150705.030648
APPROVED:::YES
FORUM ACTION EDIT:::SUCCESSFUL
NEW SUBSCRIPTION DATE:::3150705.03282
NEW ACTIVE SUBSCRIPTION:::10001
SUBSCRIPTION CHANGE CONFIRMED:::3150705.03282
```

### Steps after approval
The FORUM administrator needs to place your G.PATCHES@NAME mailgroup into the 
mailgroup A1AE PACKAGE RELEASE on FORUM. You will receive approved patches
from FORUM there.
