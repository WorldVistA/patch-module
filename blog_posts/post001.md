# Welcome to the OSEHRA Forum Project

## What is this?
If you are reading this, you must be wondering on why we are sending another
piece of mail into your Inbox. We will try to keep it short.

This relates to to VISTA development and patching. If you don't use VISTA, you
can stop here.

The VA has a system called Forum that is used to manage development, versioning,
code review, and distribution of software developed for VISTA. While there are
a lot of modern tools for this (gerrit, svn, git, hudson, travis),
VISTA doesn't work with them right now. In addition, due to the massive
difficulties of getting the VA to take the simplest of changes in code, we
need a system to interleave our changes into VA changes and allow us to 
distribute the software with the interleaved changes.

## Enter OSEHRA Forum
Succinctly, OSEHRA Forum project thus has two primary objectives:

- Output VA software in a form usable by the outside world.
- Integate modern software development tools and practices into VISTA development.

The project is divided into 3-4 increments of 3 months each. The objective of
the first 3 months increment is to install the Patch Module from the VA on an
OSEHRA system, modify the patch module to allow management of interleaving of
the VA VISTA Software, and to extract KIDS components in a way that can be
integrated into modern versioning systems.

## More questions?
I may have raised several questions above. These are topics for future posts.

- Why do modern tools for versioning, code commenting, and continous integration
  not work for VISTA?
- Why do we need to modify VA code?
