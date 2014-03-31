# Forum System Installation and Administration
## Purpose
This is a writeup of how the OSEHRA Forum machines were built.

## Overview
The base installation of UNIX (in this case CentOS 6) is supplemented with the installation of a
few standard services: the GT.M database by Fidelity Information Systems, the OSEHRA
VISTA software, and a few support scripts from Fourth Watch BCS.

## Pre-requisites
You must be a moderately experienced Linux system adminitrator able to do the following:

* Install Linux
* Install Linux packages
* Create and Manager Users
* Set-up DNS
* Set-up an SMTP server
* Administer GT.M 
* Configure lsyncd, xinetd, nfs, pvm/lvm, and ssh

## Baseline Linux System (Step #1)...
Peter Li created the two machines, forum-a.osehra.org and forum-b.osehra.org.
based on Rackspace CentOS 6. This is done through the Rackspace console.

In addition to this, create two extra disks of 500G and 20G and attach them to the machine. We refer to these disks later.

## DNS Set-up (Step #2)...

The IP address of each of forum-a and forum-b are assigned and do not change. Only one of
forum-a or forum-b is the primary, and the well-known address of forum.osehra.org always
points to the active primary. It is not expected that any external users are at all aware of there
being more than one forum machine. Only system administrators and some forum programmers
know that there is more than a single machine. Switching between these is done via a load balancer.

This is done externally on Rackspace.

    FORUM.OSEHRA.ORG (A) pointing to the either forum-a or forum-b ip address.
    Q-PATCH.OSEHRA.ORG (MX) pointing to FORUM.OSEHRA.ORG
    FORUM.OSHERA.ORG (SPF) (NOT COMPLETED YET)
    REVERSE DNS RECORD TO FORUM.OSHERA.ORG

## Extra packages (Step #3)

Install the following packages on each of the systems.

    yum install ctags dos2unix figlet git hg locatedb locatem\
    lsb_release lsyncd mailx mlocate nc ntp ntpdate\
    rcs redhat-lsb-core screen system-config-firewall-tui\
    system-config-network-tui system-config-network-tui\
    system-config-services system-config-users tree unzip\
    vim wireshark xinetd

## User and Group Set-up (Step #4)
There are two collections of users (and groups) that have special mention:

* Infrastructure user
* Application user
  
Infrastructure users are those that hold a special place because of the
infrastructure. These users are similar in their role to the root user, in that
their presence serves a specific purpose. (Usage of the root user is eschewed
for all uses but for the uses that are necessary for management of the system).

These are:

gtm | To own the database software
osehra | To own the OSEHRA VISTA repository clone
bup | To own the backup areas
fwbcs | To own the infrastructure support

Application users are those that hold a special place for the VISTA application. There are two:

forum | To own the VISTA instance
citizen | For all users of the OSEHRA forum

Any users needing access to Forum VISTA and Linux need to be added to the forum group.

See below for reference tables on how everything is set-up.

Execute the following as root.

    # groupadd gtm -g 101
    # groupadd osehra -g 102
    # groupadd bup -g 103
    # groupadd fwbcs -g 104
    # groupadd forum -g 400
    # groupadd citizen -g 400
    # useradd gtm -u 101 -g 101 -c "GT.M"
    # useradd osehra -u 102 -g 102 -c "OSEHRA Local Git Repository" -G bup
    # useradd bup -u 103 -g 103 -c "Backup Manager"
    # useradd fwbcs -u 104 -g 104 -c "Fourth Watch BCS"
    # useradd forum -u 400 -g 400 -c "Forum Database Instance Home" -G bup,gtm
    # useradd citizen -u 401 -g 401 -c "Forum Citizen" -G forum
    # useradd sampleLinuxUser -u 600 -g 600 -c "A sample user" -G forum

After this, create the system administrators and users. 
They have been redacted from this document for security reasons.

### Reference Tables

#### System Users (100 range)
username | uid | gid | Real Name
--- | --- | --- | ---
gtm | 101 | 101 | GT.M
osehra | 102 | 102 | OSEHRA Local Git Repository
bup | 103 | 103 | Backup Manager
fwbcs | 104 | 104 | Fourth Watch BCS

#### Forum and Forum User (400 range)
username | uid | gid | Real Name
--- | --- | --- | ---
forum | 400 | 400 | Forum Database Instance Home
citizen | 401 | 401 | Forum Citizen

#### Forum System Administrators (500 range)
username | uid | gid | Real Name
--- | --- | --- | ---
-- (redacted) | 502 | 502 | (redacted)
-- (redacted) | 503 | 503 | (redacted)

#### Forum Administrative Programmers (600 range)
username | uid | gid | Real Name
--- | --- | --- | ---
-- (redacted) | 600 | 600 | (redacted)
-- (redacted) | 601 | 601 | (redacted)
-- (redacted) | 602 | 602 | (redacted)

#### Group Membership Assignments
The following group assignments were made to the various users:

| Group | Users that are members of the group |
| --- | --- |
| bup | forum |
| gtm | forum |
| forum | (redacted), citizen |
| admin | (redacted) |

## GT.M Installation (Step #5)
Download the latest version of GT.M from <http://sourceforge.net/projects/fis-gtm/>.

As root, install by untarring and then running ./configure. As this is interactive, here's a transcript:

    Script started on Tue 31 Dec 2013 12:07:36 PM PST
    [root@forum fis-gtm]# mkdir x
    [root@forum fis-gtm]# cd x
    [root@forum x]# tar xfz ../Archive/gtm_V61000_linux_x8664_pro.tar.gz 
    [root@forum x]# ./configure 
                         GT.M Configuration Script
    Copyright 2009, 2013 Fidelity Information Services, Inc. Use of this
    software is restricted by the provisions of your license agreement.

    What user account should own the files? (bin) 
    What group should own the files? (bin) gtm
    Should execution of GT.M be restricted to this group? (y or n) y
    In what directory should GT.M be installed? /opt/fis-gtm/6.1-000/

    Directory /opt/fis-gtm/6.1-000/ does not exist. Do you wish to create it as part of
    this installation? (y or n) y

    Installing GT.M....

    Should UTF-8 support be installed? (y or n) n

    All of the GT.M MUMPS routines are distributed with uppercase names.
    You can create lowercase copies of these routines if you wish, but
    to avoid problems with compatibility in the future, consider keeping
    only the uppercase versions of the files.

    Do you want uppercase and lowercase versions of the MUMPS routines? (y or n)n

    Compiling all of the MUMPS routines. This may take a moment.


    Object files of M routines placed in shared library /opt/fis-gtm/6.1-000//libgtmutil.so
    Keep original .o object files (y or n)? n


    Removing world permissions from gtmsecshr wrapper since group restricted to "gtm"

    Installation completed. Would you like all the temporary files
    removed from this directory? (y or n) y
    [root@forum x]# exit
    exit

    Script done on Tue 31 Dec 2013 12:08:21 PM PST

## FWS Scripts installation (Step #6)
As root, in a temp directory, clone <https://github.com/ldlandis/lsb-fws>

    git clone https://github.com/ldlandis/lsb-fws

Copy the files to /opt/lsb-fws

    cp -rv lsb-fws /opt/

## VISTA Repository (Step #7)

The 'osehra' user holds a local copy of the OSEHRA VISTA, from which the Forum instance is populated. The repositories holding OSEHRA VISTA are cloned as follows.

    $ su - osehra
    $ git clone https://github.com/OSEHRA/VistA
    $ git clone https://github.com/OSEHRA/VistA-M

OSEHRA VISTA routines and data are segmented by package. The forum-a:~osehra/Makefile takes the current clone (in which VISTA is scattered by the various packages) and creates two directories in the home directory of ~osehra:

	r/	All of the routines
	zwr/ 	All of the data files

The Makefile contents are as follows:

    all:
	    r zwr
	    rm r/files.m zwr/files.zwr

    r: files.m
	    mkdir r/
	    while read r ; do cp -p "$$r" r/ ; done < files.m

    zwr: files.zwr
	    mkdir zwr/
	    while read zwr ; do cp -p "$$zwr" zwr/ ; done < files.zwr

    files.m: Makefile
	    -rm -rf r/
	    find . -name "*.m" -print | sed "s:^.:`pwd`:" > files.m

    files.zwr: Makefile
	    -rm -rf zwr/
	    find . -name "*.zwr" -print | sed "s:^.:`pwd`:" > files.zwr

Invoke the Makefile as follows (still as the osehra user).

    $ make all

Once gathered from the package directories, the routines and data are now ready to load into a
VISTA instance.


## Installation of VISTA (Step #8)
The 'forum' user is the owner of the Forum database instance. Version and linkage information is set in `~forum/lib` and at the time of creation, was set to:

Change to the forum user:

        su - forum

Make a bunch of directories:

        mkdir o p r s v j g G p/6.1-000 r/6.1-000 etc lib bin

Make symbolic links to lsb-fws and fis-gtm:

	ln -s /opt/lsb-fws/201301/ ~/lib/fws
        ln -s /opt/fis-gtm/6.1-000/ ~/lib/gtm
        ln -s ~/lib/fws/inst.bin/set_env ~/bin/set_env

Go back to being root. Add the additional disks and link them to the globals (g) and journals (j) directory in fstab.
Add these two lines to /etc/fstab. You may need to adjust them for the mount names.

        /dev/xvdb1 /home/forum/g ext3 defaults 0 0
        /dev/xvde1 /home/forum/j ext3 defaults 0 0

Remount everything

        mount -a

Go back to being the forum user:

        sudo su - forum   

Create the environment file as follows:

        $ cat etc/env.conf
        #!/usr/bin/env bash
        # $Source: /var/nas/repository/lsb-fws/src/inst.etc/RCS/env.conf-primary,v $
        # $Revision: 20130122.1 $

        export ENV="forum"
        export BUP="forum-a"
        export GTM_REPLICATION="on"	#[on|off]
        #export GTM_REPLICATION="off"	#[on|off]
        export REPL_PORT="50188"	# /etc/services gtmrepl 50188/tcp # GT.M Repl
        export REPL_HOST="forum-b.osehra.org"
        export REPL_HOST="localhost"	#use ssh tunnel
        export REPL_HOST_SSH_HOST="forum-b.osehra.org"
        export REPL_HOST_SSH_PORT="22"
        export REPL_BUFSIZE="4096"	# journal buffer size in 512-byte blocks
        export REPL_AUTOSWITCH=8388600	# ~800MB

        ##
        # GT.M symbols
        export gtm_buffer_size="${REPL_BUFSIZE}"
        export gtm_repl_instname="forumaforum"
        export gtm_repl_instsecondary="forumbforum"

        ###
        # Nothing should be needing changes below here
        # ---------------------------------------------

        export DBINST="/home/${ENV}"
        export PATH="${DBINST}/lib/fws/inst.bin:${DBINST}/lib/gtm:${PATH}"

        ##
        # Local symbols
        export REPL_DAT="${DBINST}/g"		# Database files
        export REPL_JNL="${DBINST}/j"		# Database journals
        export REPL_CNF="${REPL_DAT}/db.conf"	# Replication Configuration
        export REPL_SIDE="`cat ${REPL_DAT}/db.side`"

        ##
        # GT.M symbols (do not change the symbol names)
        export gtm_dist="${DBINST}/lib/gtm"
        export gtm_sysid="${ENV}"
        export gtm_log="${DBINST}/log"
        export gtmgbldir="${REPL_DAT}/db.gld"
        if [ ${GTM_REPLICATION} = "on" ] ; then
        export gtm_repl_instance="${REPL_DAT}/db.repl"
        fi

        ##
        # Get GT.M version in use
        export GTMVER=`ls -l lib/gtm | awk '{print $NF}'`
        export GTMVER=`basename ${GTMVER}`

        #export m2web="${DBINST}/w"
        export ewd="${DBINST}/w/${GTMVER}(${DBINST}/w)"
        ##
        # Build up GT.M Routine Path (using GTMVER where needed)
        #export gtmroutines="${DBINST}/p/${GTMVER}(${DBINST}/p)"
        export gtmroutines="${gtmroutines} ${DBINST}/r/${GTMVER}(${DBINST}/r)"
        #export gtmroutines="${gtmroutines} ${DBINST}/o(${DBINST}/r)"
        #export gtmroutines="${gtmroutines} ${m2web}"
        #export gtmroutines="${gtmroutines} ${DBINST}/lib/vpe/${GTMVER}"
        #export gtmroutines="${gtmroutines} ${DBINST}/lib/ewd/routines/${GTMVER}"
        #export gtmroutines="${gtmroutines} ${DBINST}/lib/mgwsi/${GTMVER}"
        #export gtmroutines="${gtmroutines} ${DBINST}/lib/serenji/${GTMVER}"
        #export gtmroutines="${gtmroutines} ${gtm_dist}"
        export gtmroutines="${gtmroutines} lib/gtm/libgtmutil.so"

        export gtm_zinterrupt='I $$JOBEXAM^ZU($ZPOSITION)'

        # Added by VEN/SMH
        export gtm_prompt="DEV,FORUM>"
        export EDITOR=`which vim`

        # MD5 Library external-call table
        #export GTMXC_md5="${m2web}/xc/gtm_md5.xc"

        # $RCSfile: env.conf-primary,v $

Make sure to invoke set_env every time you log in:
        
        echo 'source bin/set_env' >> ~/.bash_profile

Source it yourself:

        source ~/bin/set_env

Create the Global directory as follows:

	File: ~/g/db.gde

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

Load the Global Directory into GT.M:
        
        mumps -r GDE < g/db.gde > g/db.gde.out 2>&1

Create the Databases:

        mupip create

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
