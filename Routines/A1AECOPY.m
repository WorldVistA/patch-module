A1AECOPY ;isa/rmo-copy routine code into routine description ;1987-11-24T11:00
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;1992-12-02: version 2.2 released
 ;
 ;
 S A1AEROU=X I $D(^("OS",^DD("OS"),18)) X ^(18)
 I '$T W !!?3,"The routine ",X," does not reside in the routine directory." G Q
ASK S A1AERD("A")="Copy routine lines from the routine directory into the description? ",A1AERD(0)="S",A1AERD(1)="Yes^select lines to copy from the routine "_A1AEROU,A1AERD(2)="No^not copy any lines",A1AERD("B")=2
 D SET^A1AERD K A1AERD D ASKLIN:"Y"[$E(X,1)
 ;
Q W ! S X=A1AEROU K A1AEROU,^UTILITY($J,"A1AECP"),A1AELINE,A1AEFRLN,A1AETOLN,A1AEOFF,A1AEBLK,A1AEPGLN,A1AELNCT,A1AELNB,A1AELNIN,A1AEBOT,A1AENMSP,A1AEWFLG
 Q
 ;
ASKLIN S IOP="HOME" D ^%ZIS K IOP S A1AERD("A")="from" W ! D LINE Q:X="^"!(X="")  S A1AEFRLN=A1AELINE,A1AERD("A")="through",A1AERD("B")=$S(A1AEOFF:X_"+"_A1AEOFF,1:X) D LINE Q:X="^"  S A1AETOLN=$S(X="":A1AEFRLN,1:A1AELINE) K A1AERD
 D SETUTI,ASKCOP:$D(^UTILITY($J,"A1AECP")) W:'$D(^UTILITY($J,"A1AECP")) !?3,"...No lines to copy"
 I $D(A1AEWFLG) W !!,*7,"NOTE: The text which you have just copied contains the word-processing",!?6,"window symbol '|'. To display the symbol as a character in the",!?6,"description, edit the line which contains '|' and put in '||'.",! H 2
 Q
 ;
LINE W !?2,"Copy ",A1AERD("A")," line: " W:$D(A1AERD("B")) A1AERD("B")_"// " R X:DTIME S:'$T X="^" Q:X="^"!(X="")  I X["?" W !?3,"Enter line to copy ",A1AERD("A") G LINE
 S A1AEOFF=+$P(X,"+",2) I X["+",'A1AEOFF W !?3,*7,"Line offset should be a numeric value" G LINE
 S X=$P(X,"+",1) I '(X?1U.UN!(X?1"%".UN)!(X?1N.N))!($L(X)>8) W !?3,*7,"Line label should be 1-8 characters" G LINE
 X "ZL @A1AEROU S A1AEPGLN=$T(@X)" I A1AEPGLN="" W !?3,*7,"Line label ",X," not found in ",A1AEROU G LINE
 S A1AEBLK=" " X "ZL @A1AEROU F A1AELNB=1:1 Q:$P($T(+A1AELNB),A1AEBLK,1)=X" S A1AELINE=A1AELNB+A1AEOFF
 I A1AEOFF X "ZL @A1AEROU S A1AEPGLN=$T(+A1AELINE)" I A1AEPGLN="" W !?3,*7,"Line ",X,"+",A1AEOFF," not found in ",A1AEROU G LINE
 I $D(A1AEFRLN),A1AELINE<A1AEFRLN W !?3,*7,"Line copying through precedes line copying from" G LINE
 Q
 ;
SETUTI K ^UTILITY($J,"A1AECP") X "ZL @A1AEROU S A1AELNCT=0 F A1AELNB=A1AEFRLN:1:A1AETOLN S A1AEPGLN=$T(+A1AELNB) S A1AELNCT=A1AELNCT+1,^UTILITY($J,""A1AECP"",A1AELNCT)=$S(""$TXT$ROU$END""'[$E(A1AEPGLN,1,4):A1AEPGLN,1:""xx""_$E(A1AEPGLN,5,245))"
 Q
 ;
ASKCOP W ! F A1AELNB=1:1:A1AELNCT I $D(^UTILITY($J,"A1AECP",A1AELNB)) W !,A1AELNB,"> ",^(A1AELNB)
 S A1AERD("A")="Do you want to copy "_$S(A1AELNCT=1:"this line",1:"these "_A1AELNCT_" lines")_"? "
 S A1AERD(0)="S",A1AERD(1)="Yes^copy these lines into the routine description",A1AERD(2)="No^not copy these lines",A1AERD("B")=2 D SET^A1AERD K A1AERD Q:X="^"  ;;;!("N"[$E(X,1))
 I "nN"[$E(X,1) G ASKLIN
 S A1AEBOT=$S($D(^A1AE(11005,DA(1),"P",DA,"D",0)):$P(^(0),"^",3),1:0),A1AELNIN=0 D INSERT:A1AEBOT,COPY:'A1AEBOT
 Q
 ;
INSERT R !!,"Insert code after what description line: ",X:DTIME Q:'$T!(X="^")  I X<0!(X>A1AEBOT)!(X'?1N.N)!(X["?") G HELP
 S A1AELNIN=X I A1AELNIN<A1AEBOT S A1AEFRLN=A1AEBOT+A1AELNCT,A1AETOLN=A1AELNIN+1+A1AELNCT F I=A1AEFRLN:-1:A1AETOLN S ^A1AE(11005,DA(1),"P",DA,"D",I,0)=^A1AE(11005,DA(1),"P",DA,"D",(I-A1AELNCT),0)
 D COPY
 Q
 ;
HELP I X["??" W @IOF F I=0:0 S I=+$O(^A1AE(11005,DA(1),"P",DA,"D",I)) Q:'I  W !,I,"> ",^(I,0) I ($Y+6)>IOSL D CRCHK Q:X1="^"  W @IOF
 I X'["??" W:X'["?" *7 W !!?3,"Enter a line number between 0 and ",A1AEBOT,", or",!?3,"'??' to list current description."
 G INSERT
 ;
COPY S A1AELNB=0,A1AEFRLN=A1AELNIN+1,A1AETOLN=A1AELNIN+A1AELNCT F I=A1AEFRLN:1:A1AETOLN S A1AELNB=A1AELNB+1,^A1AE(11005,DA(1),"P",DA,"D",I,0)=^UTILITY($J,"A1AECP",A1AELNB) I ^(0)["|" S A1AEWFLG=""
 S:'$D(^A1AE(11005,DA(1),"P",DA,"D",0)) ^(0)="" S $P(^A1AE(11005,DA(1),"P",DA,"D",0),"^",3)=A1AEBOT+A1AELNCT
 Q
 ;
CRCHK I $E(IOST,1)="C" W !!,*7,"Press RETURN to continue or '^' to stop " R X1:DTIME
 Q
