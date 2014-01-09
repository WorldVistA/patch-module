# Developer Docs

These are my collected notes over what I find out while programming the
Patch Module.

## Shared Variables
The module is written pre-1990 Mumps, so it relies on a lot of symbol table
leakage to pass variables. Here are some of the important varibles

The three following are set by PKG^A1AEUTL, which selects a package using ^DIC.

 * A1AEPKIF -> Ien of Package in Package file. Also happens to be the IEN of
   the package in 11007, since it's DINUMMED.
 * A1AEPK -> Package Abbreviation. i.e. PSO for Outpatient Pharmacy
 * A1AEPKNM -> Whole Name. i.e. Outpatient Pharmacy

This is set by VER^A1AEUTL, which lets you select a version to work on.

 * A1AVR -> Version Number. The code does a pre-1990 $order walking through
   the whole file to find the biggest version number and then set it to
   DIC("B") so the user will pick the largest version number. File is laygoable
   by default.

In 1^A1AEPH1 (Entry point to Add a Patch), the following are set:
 
 * A1AEFL -> File 11005 (constant)
 * A1AETY -> "TYPE". What type is a good question. For better or worse, the
   original programmer has a sneaky way of using the variable. Its contents
   mean different things at different levels of the global.

    ^A1AE(11007,IEN,"PH" or "PB" ->

   This is used to control access to the file by making sure you are either
   a developer or a verifier.

   ^A1AE(11007,IEN,"V",version_no,PB) <-- Next problem number. Unused.
                                 ,PH) <-- Next patch number.
                                 ,PR) <-- Next sequence number.

To actually create the patch number, NUM^A1AEUTL is called. The following
variables are set:

  * A1AENB -> Patch Number. NB = Number
  * A1AEPD -> Patch Designation. E.g. PSO*7*234.

NUM is pretty remarkable in the logic that it uses. Patch 999 has a very
special meaning and is the end of the loop. We will have to change that.

## Patch Addition Workflow
When you add a patch using Add a Patch option, the following happens
 * Entry is 1^A1AEPH1
 * Package is selected using D PKG^A1AEUTL. Laygo is not allowed.
 * Version is selected using D VER^A1AEUTL. Laygo is allowed. Reverse $order
   isn't used, but forward order is used to find the last version and set it
   as default.
 * Patch number is automatcially computed using D NUM^A1AEUTL. Lots of logic
   there. Entry gets created in 11005.
 * Piece 0,8 (status) is hard set to 'u' (under development) to prevent calling 
   the input transform.
 * A Dinummed entry in 11005.1 is created. Ultimately this will contain the
   entire KIDS message.
 * At this point the input template \[A1AE ADD/EDIT PATCHES\] is invoked.
 * This template is rather complex. Here it is. Comments inline.

Template:

 	S A1AETVR=$P(^A1AE(11005,DA,0),U,3),A1AEST=$P(^A1AE(11005,DA,0),U,8),A1AEKIDS=0 S:A1AEST'="u" DIE("NO^")="OUTOK" S Y=$S(A1AEST="c":"@3",A1AEST="v":"@10",A1AEST="e":"@20",A1AEST="r":"@30",A1AEST="x":"@10",1:"@5")
 	@3
 	PATCH SUBJECT  //When we add a patch, we start here.
 	HOLDING DATE
 	I A1AEST="u" S Y="@6" // This was hardcoded before, so we jump to @6.
 	W ! D CONT^A1AEM
 	STATUS OF PATCH///U
 	S A1AEST="u" K DIE("NO^")
 	@5
 	PATCH SUBJECT
 	HOLDING DATE
 	@6
 	PRIORITY
 	S:A1AETVR=999 Y="@7" // If we use patch 999, Category automatically gets set for us to DBA in the ^A1AEPH1 routine.
 	CATEGORY OF PATCH
 	   ALL
 	@7
 	D ^A1AECOPD // This routine uses QUE^A1AEM to get the Postmaster basket for Q-PATCH.MUMPS.ORG, then looks in there using LOC^A1AEM to grab the message, then ask you to load the text. If it can't find a message (guess) or you say you don't want to load the message, then it will look in the HFS messages file (11005.5) and try to load the messages from there. More on this below.
 	PATCH DESCRIPTION // a chance to edit the text.
 	S:A1AETVR=999 Y="@10" //DBA ditto
 	DHCP PATCH MESSAGE: // This is a backwards navigation jump to 11005.1.
 	   W !?20,"editing MESSAGE TEXT"
 	   D ^A1AEM1 // From the same message, copy the KIDS build text
 	   W !
 	   MESSAGE TEXT  // a chance to edit this manually.
 	S:A1AEKIDS Y="@8" // If this is a a KIDS build (set in A1AECOPD), skip the packman related questions.
 	ROUTINE NAME
 	   ROUTINE NAME
 	   W !?20,"editing DESCRIPTION OF ROUTINE CHANGES"
 	   D ^A1AECOPY // Copy routine lines FROM CURRENT ENVIRONMENT into description. Uses Cacheisms.
 	   D ^A1AECOPR // Copy routine lines from Packman message.
 	   DESCRIPTION OF ROUTINE CHANGES // chance to edit
 	   ROUTINE CHECKSUM // ditto
 	@8
 	DISPLAY ROUTINE PATCH LIST//Yes  //does absolutely nothing here. Does not display it for the current user.
 	W !,"editing comments only seen by releasers/developers"
 	INTERNAL COMMENTS
 	PATCH RELEASE CHECK
 	   ALL
 	W !
 	@10
 	STATUS OF PATCH // CENTER OF THE UNIVERSE FOR PATCH MODULE. The workflow is tied to the Input Transform!
 	S Y=$S(X="e":"@20",X="r":"@30",1:"@99")
 	@20
 	ENTERED IN ERROR DESCRIPTION
 	S Y="@99"
 	@30
 	RETIRED AFTER VERSION
 	RETIREMENT COMMENTS
 	@99
 	K A1AETVR,A1AEST,A1AEKIDS

## Patch completion and verification
Patch completion and verification is done by setting the STATUS OF PATCH
to "c" and then "v". Each invokation invokes the input template which invokes
A1AEPHS.

Verification calls SEQ^A1AEUTL to obtain the sequence number.

Verification is rather complex on how it decides to route mail. 
I need to write more on it later.

## Random other facts
The D index on 11005 says which package the patch belongs to.

It's set by hand in NUM^A1AEUTL (ewww).

It's possible to "trick" various entry points in A1AEUTL to be silent by
passing certain items in the symbol table. I used that in Unit Tests.

To copy a message A1AECOPD is called from the Add/Edit Patch Input Template.

A1AECOPD checks I $P(^A1AE(11007,$O(^DIC(9.4,"C",$P(A1AEPD,"*"),0)),0),U,5)'="y" Q
to see if it's okay to ask.

The A1AEPB* are not currently used.

## HFS Server for Messages that are not going into the Patch Module.
On the development system (not Forum), in XPDT, every time KIDS exports a 
build to a file; and either:

 * if the development domain has .va.gov, then send message to S.A1AE HFS CHKSUM SVR@FORUM.VA.GOV
 * OR: XPD PATCH HFS SERVER parameter at the Package level is set, send an email to there.

The message going to Forum looks like this:

	Subject: **KIDS** Checksum for ZZZ*2.0*1                                        
	Date: 8 Jan 2014 11:11:51 -0800 (PST)                                           
	Message-ID: <3487.3140108@VEN.SMH101.COM>                                       
	From: <TESTMASTER.USER@VEN.SMH101.COM>                                          
	To: "S.A1AE HFS CHKSUM SVR"@FORUM.OSEHRA.ORG                                    
																					
	~~1:ZZZ*2.0*1                                                                   
	~~3:ZOSV2GTM^0^1^B7008460^**275,425**                                           
	~~4: ;;8.0;KERNEL;**[Patch List]**;Jul 10, 1995;Build 6                         
	~~8:VEN.SMH101.COM                                                              
	~~9:Save                                                                        

If everything works correctly, the checksums will be loaded to the routine
multiple in 11005.1 if a message for the patch cannot be found in Q-PATCH 
queue or the user says not to load it.
