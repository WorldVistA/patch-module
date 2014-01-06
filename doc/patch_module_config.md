# Patch module configuration
The following will be a brief overview of how to configure the patch module
so that it is operational.

## Install the Patch Module
KIDS: <https://downloads.va.gov/files/FOIA/Software/Patches_By_Application/A1AE-Patch%20Module/A1AE.KID>

## Hang the main menu
Menu is A1AE USER. Hang it off XUCORE and EVE.

## Create Users
For a complete workflow, you need at least 3 users: 2 developers and 1 verifier.

## Allocate keys
I am not clear as of today on which keys are exactly needed, so I gave myself 
all of them. I know that A1AE MGR is certainly required for set-up.

 * A1AE COMPDATE   
 * A1AE DEVELOPER  
 * A1AE MGR        
 * A1AE PHVER      
 * A1AE PKGEDIT
 * A1AE SCAN MESSAGE
 * A1AE SUPPORT   
 * A1AE XUSEC

## Set-Up Patch Moudle Package in the Patch Module (!!)
That's a weird step, but it's necessary. The PM uses this to figure out where
to send messages out. Here we configure it to use mail group `A1AE PACKAGE
RELEASE` on domain `FORUM.OSEHRA.ORG`, which happens to be the local domain.
Right now the patch module cannot support arbitrary domains. Any domain has to
be in the Domain file.

	A1AE USER > A1AE MGR > A1AE MGRADD

	Select PACKAGE: A1AE  PATCH MODULE     A1AE
			 ...OK? Yes//   (Yes)
		  
	-------------------------------------------------------------------------------
	USER SELECTION PERMITTED: NO// 
	* PERMIT DEVELOPER TO COMPLETE: YES// 
	FOR TEST SITE ONLY?: NO// 
	PERFORMANCE MEASURE FLAG: 
	ASK PATCH DESCRIPTION COPY: 
	-------------------------------------------------------------------------------
	Select SUPPORT PERSONNEL: 
	-------------------------------------------------------------------------------
	Select DEVELOPMENT PERSONNEL: 
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	Select NETWORK ROUTING: G.A1AE PACKAGE RELEASE// 
	  NETWORK ROUTING: G.A1AE PACKAGE RELEASE  Replace 
	  DOMAIN: FORUM.OSEHRA.ORG// 
	For Verified Patches
	  TEST SITE: 
	Select NETWORK ROUTING: 

## Add users to the mail group
Through mailman menus, you need to add users to the `A1AE PACKAGE RELEASE`
group. All external emails must go through remote users.

## Set-up your new package for patching in the Patch Module
Your package has to be in the Package file already. If you are modifying a new
package, you have to manually add it to the package file then add it the Patch
Module.

	Select PACKAGE:    TEST PACKAGE       ZZZ

	This package is considered a TEST SITE PACKAGE in the Patch Module.


	-------------------------------------------------------------------------------
	* PERMIT DEVELOPER TO COMPLETE: YES// <-- NOT USED!
	FOR TEST SITE ONLY?: YES// <-- Affects where you can send this.
	PERFORMANCE MEASURE FLAG: YES// <-- Don't know what that does
	ASK PATCH DESCRIPTION COPY: YES// <-- Affects a question to ask when importing patches from mailman.
	-------------------------------------------------------------------------------
	Select SELECTED USERS FOR PACKAGE: MARSHALL,RICK// <-- This user can see patches for this package. Just SEE! No keys necessary
	  SELECTED USERS FOR PACKAGE: MARSHALL,RICK// 
	  TEST SITE DOMAIN: FORUM.OSEHRA.ORG// 
	Select SELECTED USERS FOR PACKAGE: 
	-------------------------------------------------------------------------------
	Select SUPPORT PERSONNEL: EDWARDS,CHRISTOPHER// <-- This user is the verifier. Must have A1AE PHVER.
	  SUPPORT PERSONNEL: EDWARDS,CHRISTOPHER// 
	  VERIFY PERSONNEL: VERIFIER// 
	  VERIFIER'S DOMAIN: FORUM.OSEHRA.ORG// 
	Select SUPPORT PERSONNEL: 
	-------------------------------------------------------------------------------
	Select DEVELOPMENT PERSONNEL: MARSHALL,RICK// ? <-- This user is a developer. Must have A1AE DEVELOPER.
		Answer with DEVELOPMENT PERSONNEL
	   Choose from:
	   50           HABIEL,SAM
	   51           MARSHALL,RICK
			 
			You may enter a new DEVELOPMENT PERSONNEL, if you wish
	   
	 Answer with NEW PERSON NAME, or INITIAL, or SSN, or VERIFY CODE, or
		 NICK NAME, or SERVICE/SECTION, or DEA#, or VA#, or ALIAS, or NPI
	 Do you want the entire NEW PERSON List? n  (No)
	Select DEVELOPMENT PERSONNEL: MARSHALL,RICK// 50  HABIEL,SAM
	  DEVELOPMENT PERSONNEL: HABIEL,SAM// 
	Select DEVELOPMENT PERSONNEL: 51  MARSHALL,RICK
	  DEVELOPMENT PERSONNEL: MARSHALL,RICK// 
	Select DEVELOPMENT PERSONNEL: 
	-------------------------------------------------------------------------------

## Typical workflow
 * Developer emails patch to PM via XXX@Q-PATCH.OSEHRA.ORG
 * Developer creates PM patch via `Add a Patch` and loads emailed patch. Status is now `UNDER DEVELOPMENT`. Second developer gets emailed that there is a patch ready to review.
 * Second developer reviews patch via `Edit a Patch` and then changes status to `COMPLETED`. Verifier gets emailed that there is a patch ready to review.
 * Verifier reviews patch via `Release a Patch` and then changes status to `VERIFIED`. Once verified, patch automatically gets emailed to the Network routing list configured inside the A1AE package.
