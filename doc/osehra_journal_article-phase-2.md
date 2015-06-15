# OSEHRA Forum Technical Journal Article

## Authors
Rick Marshall, Kathy Ice, Sam Habiel, Larry Carlson, Joel Ivey

## Introduction
In December 2013, OSEHRA contracted with VISTA Expertise Network to modify the
VA Forum package, especially the Patch Module, to meet the needs of the non-VA
VistA community. The goal of Phase One was to achieve an Initial Operating
Capability that would support not only code released under the Freedom of
Information Act by the Department of Veteran’s Affairs but would also support a
separate patch stream for code that was modified or created by OSEHRA and the
VistA community. The goal of phase two is to upgrade the Patch Module and KIDS
code to fully support patch stream switchover.

We are pleased to submit the results of Phase Two to the OSEHRA certification
process.

A brief discussion of the changes made to the original code to support the
needs of the community follows.

Items included in this submission are:

 * OSEHRA Forum Technical Journal Article—this paper
 * Patch Module 2.5 Code (two builds, the Subscriber side and the Patch Module side)
 * OSEHRA Primary Developer Checklist
 * Primary Developer User Manual
 * Secondary Developer User Manual
 * Verifier User Manual
 * Patch Subscriber User Manual
 * Release Notes
 * Technical Manual
 * Installation Manual

The configuration manual was suppiled in Phase One.

### Primary & Secondary Development
OSEHRA does some primary development, but much of what the organization does is
modifying and extending existing VA code. VA’s software hub is a Forum system
that only supports primary development. OSEHRA Forum Project’s Phase One
upgraded the Patch Module software to be able to support both primary and
secondary development.

### Multiple Software Streams
VA’s existing Forum system only supports a single outbound stream of patches,
but OSEHRA Forum now supports two outbound software streams, VA FOIA VistA and
OSEHRA VistA, and will support any number of streams later on.

Further, if Indian Health Service (IHS) wishes to take advantage of OSEHRA
Forum in the future rather than creating its own IHS Forum, then OSEHRA Forum
also will be able to support more than one inbound software stream, since it
will also need to be able to consume IHS’s stream of patches for distribution
without mixing up the VA and IHS patches with each other.

## OSEHRA Forum Functionality
The OSEHRA Forum system is a shared VistA-community resource that can make
possible for the first time a VistA life cycle that integrates the vertical
silos of the current VistA community into a truly unified VistA-development
community.

The five components of the VistA life cycle that OSEHRA supports are:

 1. FOIA VistA Patches
 2. OSEHRA VistA Patches from VA
 3. OSEHRA VistA patches From Community
 4. OSEHRA VistA Replacements For FOIA Vista Patches
 5. New Submissions To OSEHRA From The Community

The first four components are forms of secondary development. Secondary
development is when you are modifying or extending someone else’s VistA
package.

The fifth component is different; it supports primary development that
originates not from VA Forum but from the OSEHRA community itself, when we are
not modifying VA’s code but creating or modifying our own. File Manager version
22.2 is an example of primary development, since in this release we took
responsibility for an entire application rather than just inserting secondary
development into VA’s application. Other examples would be the initial or
subsequent versions of brand new VistA applications developed by the OSEHRA
community.

A subset of that fifth component, primary development by VA developers, is the
only form of VistA development that VA Forum currently supports. Merely by
setting up our own Forum system open to the entire OSEHRA community, we are
expanding our support to include all primary development, by VA or by any other
primary developer.

## Current User Interface
Although Gerrit, Git, Jira, and the OSEHRA Technical Journal have modern web
user interfaces, VA Forum uses a traditional terminal-based user interface, as
will OSEHRA Forum’s initial operating capability. Upgrading Forum to a web UI
is nontrivial work, too difficult to achieve in the early phases of the
project, because the Patch Module’s database and business logic are closely
intertwined with its UI, to support a rich user dialog.

The early phases of this project, including Phase One, began that disentangling
process, especially by opportunistically replacing hard-wired UI output built
into the database to instead use more modern UI tools capable of redirecting
output to arrays for silent operation, in preparation for sending those arrays
to GUIs or web UIs. Even so, for these early phases the Patch Module will
remain solidly terminal-based.

## Executed Unit Tests
The planned unit tests correspond to the non-database tasks planned for Phase
One. See the Initial Design Document for more details about what those tasks
were. Here is a list of the unit tests we have developed so far:

 * Make the FOIA VISTA and OSEHRA VISTA patch streams.
 * Make a package in file Package (9.4)
 * Make users in file New Person (200)
 * Add a package to Patch Module file DHCP Patch/Problem Package (11007)
 * Setup a package in the Patch Module
 * Setup a new version of a package
 * Delete all e-mail messages in Q-PATCH basket (used to receive patches)
 * Mail a KIDS build to XXX@Q-PATCH.OSEHRA.ORG (simulating a developer)
 * Get Postmaster basket for Q-PATCH in variable QUE
 * Obtain next patch number
 * Set up a new patch
 * Add routine set in file Message
 * Get messages matching a package.
 * Create a patch (status: under development)
 * Complete the patch (status: completed/unreleased)
 * Verify the patch (status: released)
 * Export Patch to File system using new exporter code
 * Create a second patch - complete this one (leave completed)
 * Create a third patch - don't complete or verify (leave under development)
 * Test new Write Identifiers for Patch file
 * Test Report 5^A1AEPH2 (option Summary Report for a Package)
 * Test Report 1^A1AEPH2 (option Completed/unverified Patch Report)
 * Analyze TXT files produced by the VA Patch Module (tested for ALL patches on OSEHRA repository)
 * Import KIDS files directly into the Patch Module (tested for ALL patches on OSEHRA repository)
 * Test Get Stream from Patch Designation
 * Test Import of Single Build KID files
 * Test Import of Multi Build KID files
 * Test that repeated Import does not duplicate patches
 * Test that a Forum message sent to S.A1AE LOAD RELEASED PATCH will add correctly to the current Forum system
 * Test ZWRITE subscript substitution for exporting KIDS components in a versionable format
 * Test export into versionable components for ALL KIDS files in OSEHRA repository
 * Test conversion of designation from Patch Module format to KIDS format
 * Test conversion of designation from KIDS format to Patch Module format
 * Return all required build descendants associated with the parent build searching all builds recursively
 * Return all multiple builds descendants associated with a multiple build searching all builds recursively
 * Load all requried build descendants found recursively into the required build multiple of the parent
 * Load all multiple build descendants found recursively into the multiple build multiple of the parent
 * Given a routine name return array of all DHCP PATCHES [#11005] that contain that entry
 * Given the IEN of an entry into the DHCP PATCHES [#11005] file, return an array of all routines and associated patches for those routines
 * Remove all BUILDS, INSTALLS, and PATCHES from an incoming array unless it matches a DHCP PATCHES entry and belongs to the PATCH STREAM of the domain calling
 * Filter array of PATCHES to remove any not belonging to the active patch stream of the domain calling
 * Update the PATCH multiple of a BUILD, and all of its INSTALLS with corresponding DHCP PATCHES
 * Remove BUILDS from an array that do not belong to the active version of the package
 * Check a BUILD's belonging to an active package version
 * Given an array of BUILD names, build a new array of only these BUILDS which install or modify a file, or contain a component not subsequently updated by a more recent install.
 * Assist a developer to assess the necessary required BUILDS, multiple BUILDS necessary to assure the BUILD brings all necessary previous BUILDs
 * Filter KIDS loaded for installation to assure they belong to the active patch stream
 * Support dialog between a Client and Forum when Client requests to change their Active Patch Stream
 * Support dialog between Forum and a Client who has requested to change their Active Patch Stream.

## Phase One Major Milestones
### Enhancements to Support Secondary Development (v 2.4)
Patch Module version 2.3 and before did not support secondary development, nor
multiple patch streams, nor multiple Forum systems, nor industry-standard
version control.

Reinterpret existing patch statuses:

 * Under Development [u]
 * Completed/Unverified [c]
 * Verified [v]
 * Entered in Error [e]
 * Retired [r]
 * Cancel [x]

as describing primary development, which is the original creation and release
of any patch.

For secondard development, add new statuses:

 * In Review [i2]
 * Sec Development [d2]
 * Sec Completion [s2]
 * Sec Release [r2]
 * Not for Sec Release [n2]

to describe secondary development, which is the import, review, possible
revision, and re-release of any patch in a new patch stream. Templates and
options were modified to support secondary development of a patch.

### Patch Stream FOIA VISTA
Reinterpret all VA VISTA patches released through VA’s redaction and Freedom of
Information Act (FOIA) process as constituting a FOIA VISTA patch stream. New
file DHCP Patch Stream (11007.1) defines this and other patch streams.

### Patch Stream OSEHRA VISTA
Add new patch stream OSEHRA VISTA, which is derived from patch stream FOIA
VISTA but can include secondary development on FOIA VISTA patches as well as
new, original primary development—new, certified community-developed patches to
VISTA applications. OSEHRA VISTA is defined in file DHCP Patch Stream
(11007.1).

### OSEHRA Forum & Distributing Multiple Patch Streams
Add a second Forum system, run by OSEHRA, which subscribes to patch stream FOIA
VISTA and creates two patch streams: (1) a rerelease of FOIA VISTA, and (2)
OSEHRA VISTA, which is this site’s primary patch stream, the one for which new,
primary development is released from this Forum site. (FOIA VISTA is primarily
released from VA Forum).

### Patch Load and Derivation
Add ability for Patch Module to load—either individually or en masse—already
released primary patches from patch stream FOIA VISTA, set their status to In
Review, and derive a copy of each loaded patch for patch stream OSEHRA VISTA,
with its status also set to In Review, and with its Derived from Patch field
set to point to the original FOIA VISTA patch.

### Patch & Sequence Numbers for Multiple Patch Streams
Patch and sequence numbers are now allowed to be longer. Sequence numbers are
now specific to each patch stream. Patch numbers are now numberspaced by patch
stream, so that an original FOIA VISTA patch and its derived OSEHRA VISTA patch
cannot be mixed up. FOIA VISTA begins numbering patches from 1, as it always
has. OSEHRA VISTA begins numbering patches from 10001.

### Improve Patch Integrity and Identification
A new key—A, on field Patch Designation (.01)—has been added to file DHCP
Patches (11005) to ensure that patch IDs are unique. The file’s identifiers
have been extended to handle the new secondary statuses, to identify a patch’s
stream, and to indicate when one patch is derived from another patch. Here’s a
sample of the new help listing (FV stands for FOIA VISTA, OV for OSEHRA VISTA,
and IN for In Review):

```
Select DHCP PATCHES PATCH DESIGNATION: ??

   Choose from:
   127569        PRCA*4.5*261     [FV]FIX <NOLINE> ERRORS               IN  TH
   127570        PRCA*4.5*10261     [OV]FIX <NOLINE> ERRORS             IN  TH
                                derived from [FV]PRCA*4.5*261
   127571        PRCA*4.5*263     [FV]FIX RCIB VARS & TRANS NUM         IN  TH
   127572        PRCA*4.5*10263     [OV]FIX RCIB VARS & TRANS NUM       IN  TH
                                derived from [FV]PRCA*4.5*263
```

### Improved Quality Control for Patches
When a patch is verified, export patch and its individual software elements for
manual import into Git or other version-control repositories. Before-and-after
checksum automation for routines transported by patches now supports multiple
patch streams.

### Improved Quality Control for Patch Module
All Patch Module software elements are now managed by Git version-control
systems. Unit tests were created to cover 50% of Patch Module code, to permit
OSEHRA Certification Level 3. Numerous old bugs were identified and fixed
during development of version 2.4.

## Phase Two Major Milestones
### Enhancement to Support Patch-stream Switchover
Patch Module versions 2.5 and before and KIDS prior to the Patch Client 2.5 did
not let KIDS refer explicitly to patches or patch streams, so did not support
switching a site over from one patch stream to another, nor supported
calculating and properly checking for required patches or checksums across a
switchover boundary.

### Distribute Patch Module Files to All VISTA Sites
Files describing patch streams and patches are now distributed for installation
in all development, test, production, and other VISTA environments, to provide
a frame of reference for KIDS to improve its handling of patching.

### Make Build and Install Files Patch-aware
Add a new Patch subfile to files Build (9.6) and Install (9.7) pointing to file
DHCP Patches (11005), so KIDS is aware of how its distributions correspond to
patches.

### Make VISTA Sites Subscribe to Patch Streams
Extend file DHCP Patch Stream (11007.1) to record which stream of patches the
current VISTA environment installs, and to remember the history of switchovers
from one patch stream to another.

### Required-patch Checks across Switchovers
Make patches transport required-patch names from both patch streams, so KIDS at
each site can require FOIA VISTA patches before the switchover but OSEHRA VISTA
patches afterward.

### Checksum Checks across Switchovers
Make patches transport checksum values for both patch streams, so KIDS at each
site can check FOIA VISTA checksums before the switchover but OSEHRA VISTA
patches afterward.

### Support Switchover from FOIA VISTA to OSEHRA VISTA
Add and modify KIDS options to let a system manager switch the current VISTA
environment from FOIA VISTA to OSEHRA VISTA.

### Auto-populate KIDS Build Description from Patch
For years it has been common practice to enter a complete description of the
patch in the Patch Module’s description but not in the KIDS build’s
description. During the KIDS distribution install process, KIDS does not have
access to the Patch Module description, increasing the chances that installers
will overlook critical information. Patch Module version 2.5, upon the release
of any patch, checks the KIDS build to see if its Description is missing; if it
is, it copies the description from the Patch Module into the Build, to ensure
it will be present during install at each site.

### New Documentation Suite
Because Patch Module was never distributed prior to version 2.4, it included
only scanty documentation that did not meet the VISTA documentation standards.
Version 2.5 brings its documentation suite into compliance with the standard.

### Improved Online Help
Help text, descriptions, technical descriptions, and help frames have been
improved throughout the Patch Module.

## Code Walkthrough
The patch module is a classic VISTA Fileman based application. It makes very
heavy use of Fileman primitives for virtually all of its functions.

### Fileman Files
The module has 9 files located in the 11000 range:
   
   11004        PATCH
   11005        DHCP PATCHES      
   11005.1      DHCP PATCH 
   11005.2      DHCP PATCH STATUS 
   11005.5      DHCP HFS MESSAGE  
   11006        DHCP PROBLEMS     
   11007        DHCP PATCH/PROBLEM 
   11007.1      DHCP PATCH STREAM
   11007.2      PATCH STREAM HISTORY      

11005 contains the patch message; and 11005.1 contains the KIDS build for the
patch. These files are DINUMm'ed to each other. Occassionally, a developer
can't send the patch to Forum because it's too large. In that case, when he/she
generates an patch to the host file system, a message is sent to 
S.A1AE HFS MESSAGES containing the checksums of routines in the patch. The
message is processed by A1AEHSVR and filed into 11005.5. If a developer says
that they don't have a patch in the process of creating the message, the system
will check 11005.5 to see if checksums for the routines can be found there.

11005.2 is a newly created reference file and has no relation to the other
11005 files. It was created in version 2.4.

11006 is not used.

11007 contains the package definition for each package in the patch module.
Importantly, it contains who is allowed to develop it, verify it, and whether
it's a test package. Through a sleigh of hand, the patch module entry in this
file contains the routing list of who receives any verified patch.

11007.1 is also new. It's created in version 2.4. Its function is to support
mulitple patch streams.

11004 was added in 2.5 to support client side (i.e. subscriber side)
management of patches.

11007.2 was added in 2.5 to support the server side managment of which subscribers
are on which stream.

### Routine Breakdown
Routine A1AEPH1 is the heart of the patch module. It's reponsible for adding
and editing of patches. Most of the heavy work is done by the Input Template
\[A1AE ADD/EDIT PATCHES\] on file 11005.

This input template invokes A1AECO* routines, which copy mail messages and routines into 11005 and 11005.1. It also calls A1AEM1 to copy KIDS builds and  DIFROM and Packman messages from Mailman.

A1AEM and A1AEM2 are called elsewhere in the module and perform mailman related functions. We will mention them again.

The input transform on field 8 is the center of the patch module's workflow.

It invokes ^A1AEPHS. This routine is responsible for moving the patch through
various statuses and eventually mailing it out. The routine A1AEMAL is responsible for building the message. A1AEM helps with addressing the message for release. A1AECL1 updates the old checksums with the latest patch released.

The rest of the A1AEPH* routines are reporting related.

Routine A1AEPK adds and edits package releases. Package releases are represented
as a patch with a patch number of zero. For example, VPR*1*0.

Managing the patch module is done via routine A1AEAU, which calls A1AEKEY for key allocation functions.

A1AEUTL* are shared utility routines. So is A1AEMGR, which is rather misnamed. A1AERD is a primitive reader used prior to the invention of ^DIR.

A1AEVP* are routines to help verifiers.

A1AEPB1 is for adding and editing Problems in 11006. It's not used.

A1AESP, A1AEZCON, A1AEZTST perform one off utility tasks.

A1AERCON compares patches to see if they modify the same routines.

A1AEK2M* are routines newly written in version 2.4 and are invoked through the new A1AE IMPORT menu. They import patches from the file system into the patch module. They are tested by A1AEK2MT. Any operating system functions are performed in A1AEOS if the functionality is not already provided by the Kernel.

A1AEPSVR performs the same function for VA Forum mailed messages received through S.A1AE LOAD RELEASED PATCH.

A1AEK2V* exports patch compoents to the file system for versioning. It's tested by A1AEK2MT since its invokation is on a cross-reference in 11005.

A1AEM2K exports patches from the Patch Module to the File system as KIDS HFS files.

A1AEUT* provide Unit Tests for the whole of the package.

A1AEF*  Represent functions to support patch developers in recognizing all other BUILDS which may influence construction of a new patch and functions include automating adding all necessary BUILDS and PATCHES to their respective multiple.
A1AEK1 A filter which examines a loaded patch, before installation, and determins the whether install is appropriate.
A1AEK2,A1AEK3 Routines which handle the Mailman dialog which occurs between a Client and the appropriate FORUM when requesting a patch stream change. 

A1AEDD1 handles various input transforms from various files.

A1AEBLD handles movements of data from 11005/11005.1 and 11004/11005.1.

## Conclusion
While there are still a lot of improvements that could be made to Forum and the Patch Module,
this code provides an Initial Operating Capability for the VistA community to use and a
foundation for further development.
