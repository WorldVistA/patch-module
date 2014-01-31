# Forum System Installation and Administration
## Purpose
This is a writeup of how the OSEHRA Forum machines were built.
Machine Creation

## Baseline Linux System
Peter Li created the two machines, forum-a.osehra.org and forum-b.osehra.org.
based on Rackspace CentOS 6.

After this, the following packages were installed from the CentOS repositories:

	ctags							rcs
	dos2unix						redhat-lsb-core
	figlet							screen
	git								system-config-firewall-tui
	hg								system-config-network-tui
	locatedb						system-config-network-tui
	locatem						    system-config-services
	lsb_release					    system-config-users
	mailx							unzip
	mlocate						    vim
	nc								wireshark
	ntp								xinetd
	ntpdate

## Users / Groups
### System Users (100 range)
username | uid | gid | Real Name
--- | --- | --- | ---
gtm | 101 | 101 | GT.M
osehra | 102 | 102 | OSEHRA Local Git Repository
bup | 103 | 103 | Backup Manager
fwbcs | 104 | 104 | Fourth Watch BCS

### Forum and Forum User (400 range)
username | uid | gid | Real Name
--- | --- | --- | ---
forum | 400 | 400 | Forum Database Instance Home
citizen | 401 | 401 | Forum Citizen

### Forum System Administrators (500 range)
username | uid | gid | Real Name
--- | --- | --- | ---
petercyli | 502 | 502 | Peter Li
ldl | 503 | 503 | LD Landis

### Forum Administrative Programmers (600 range)
username | uid | gid | Real Name
--- | --- | --- | ---
toad | 600 | 600 | Rick Marshall
sam | 601 | 601 | Sam Habiel
cedwards | 602 | 602 | Christopher Edwards

### Group Membership Assignments
The following group assignments were made to the various users:

| Group | Users that are members of the group |
| --- | --- |
| bup | forum |
| gtm | forum |
| forum | petercyli, ldl, toad, sam, cedwards, citizen |
| admin | petercyli, ldl, sam |

## VISTA Repository
The 'osehra' user holds a local copy of the OSEHRA VISTA, from which the Forum instance is populated. The process used is documented separately. For the current version of this, see: forum-a.osehra.org:~osehra/README.clone.
OSEHRA VISTA routines and data are segmented by package. The forum-a:~osehra/Makefile takes the current clone (in which VISTA is scattered by the various packages) and creates two directories in the home directory of ~osehra:

	r/		All of the routines
	zwr/ 	All of the data files 

## Installation of VISTA
The 'forum' user is the owner of the Forum database instance. Version and linkage information is set in `~forum/lib` and at the time of creation, was set to:

	lib/fws -> /opt/lsb-fws/201301/
	lib/gtm -> /opt/fis-gtm/6.0-003/

Controlling the locations globals are stored is the global directory defined as follows:

	File: g/db.gde

	change -segment DEFAULT -file="$DBINST/g/default.dat" -allocation=400000
		-block_size=4096 -lock_space=1000 -extension_count=0
	add    -segment TEMPGBL -file="$DBINST/g/tempgbl.dat" -allocation=10000
		-block_size=4096 -lock_space=1000 -extension_count=0
	change -region  DEFAULT -record_size=4080 -key_size=355
	add    -region  TEMPGBL -record_size=4080 -key_size=355 -dyn=TEMPGBL
	add    -name    HLTMP   -region=TEMPGBL
	add    -name    TMP     -region=TEMPGBL
	add    -name    UTILITY -region=TEMPGBL
	add    -name    XTMP    -region=TEMPGBL
	add    -name    XUTL    -region=TEMPGBL
	show -all

From the above global directory the database instance is created (using `mupip create`) which create the datafiles in the instance home g/ directory.

Routines were loaded and compiled from the OSEHRA repository (located in ~oshera) using the following script:

	File: bin/cprtns.sh

	(cd ~osehra/; tar cf - r) | (tar xf -)
	(cd r/${GTMVER};
	 date > compile.log
	 for r in ../*.m ; do mumps ${r} >> compile.log 2>&1 ; done
	 date >> compile.log
	)

Data was loaded into the database from the OSEHRA repository (located in ~osehra) using the following script:

	File: bin/loaddb.sh

	for z in ~osehra/zwr/*.zwr ; do cp -v "${z}" x ; mupip load x ; done
	rm x

## Submitted by
Larry D. Landis, Fourth Watch Business Continuity Services
