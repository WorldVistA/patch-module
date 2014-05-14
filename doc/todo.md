# Forum stuff to be done:

- Load HFS for primary stream development (?)
- KIDS install bulletin to Patch Module
- Header build KIDS Multibuild issue.
- Creation of package entry for new packages
- Modify contents of KIDS patches to correspond to forked patches.
- Load associated patches
- Recalculate the associated patches to refer to derived patches, not original patches.
- Initialize PM with all past patches.
- Modify name of \[A1AE VERIFIED PATCH SUMMARY\] because of its general utility and use in non-verified statuses.
- FSBD report displays verified patches for every package. On import process, all patches are verified, so report is pointless.
- Releaser menu reports and workflow deal ONLY with completed patches. Need to create new menu for new statuses.
- Create Version Control to KIDS importer.
- Work out Version Control issues (Brad conversation)
- Work out gerrit issues (Brad conversation)

# Specific stuff in Routines
## A1AEPSVR, A1AEK2M

NO VCS handling for mailed patches. Brad's workflow will solve that, where we define our directory structure in the Patch Stream file.

Create package entry if it doesn't exist.

`RESULT` variable population needs to be abstracted. Done in two different places right now.

Recursion code is very immature and not documented properly.

When recursing, send a single mail message, not multiple.

## A1AEM2K
Move setting of DIC("S") to a central location in A1AEPH6.

## A1AEMAL and \[A1AE STANDARD PRINT\]
Cross calling code. Need to fix.

Print format NOT exactly the same as mail message. Ideally, same code should do both. Right now, columns don't align.

`USERS^A1AEMAL` is not populated at input transform time. Need to fix. Didn't have time to figure this one out. Perhaps instead of sending a message at IT, send using an x-ref.

## A1AEUT1
Checksum Unit Tests

## A1AEK2M0
Doc of params

Use FM API's rather than global sets. See if it will work. (The under development section).

## A1AEK2M1
Handle Multibulid Header (the **KIDS** line)
Handle MBREQ node in PM.

## A1AEK2M2
Documentation

## A1AEK2VC
Make this routine work from the file system and from inside KIDS... it's too valuable.
