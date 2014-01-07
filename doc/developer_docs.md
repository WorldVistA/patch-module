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

<pre>
   ^A1AE(11007,IEN,"V",version_no,PB) <-- Next problem number. Unused.
                                 ,PH) <-- Next patch number.
                                 ,PR) <-- Next sequence number.
</pre>

To actually create the patch number, NUM^A1AEUTL is called. The following
variables are set:

  * A1AENB -> Patch Number. NB = Number
  * A1AEPD -> Patch Designation. E.g. PSO*7*234.

NUM is pretty remarkable in the logic that it uses. Patch 999 has a very
special meaning and is the end of the loop. We will have to change that.

# Random other facts
The D index on 11005 says which package the patch belongs to.

It's set by hand in NUM^A1AEUTL (ewww).

I haven't figured out how the mail messages file (11005.1) relates to 11005
(Patches).

It's possible to "trick" various entry points in A1AEUTL to be silent by
passing certain items in the symbol table. I used that in Unit Tests.
