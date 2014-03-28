A1AEPH	; RMO,MJK/ALBANY ; Patch Menu ;24 NOV 87 11:00 am
	;;2.4;PATCH MODULE;;Mar 28, 2014;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;11/23/92
	G:$D(^DOPT("A1AEPH",2)) A S ^DOPT("A1AEPH",0)="Patch Menu Option^1N^" F I=1:1 S X=$T(@I) Q:X=""  S ^DOPT("A1AEPH",I,0)=$P(X,";",2,99)
	S DIK="^DOPT(""A1AEPH""," D IXALL^DIK
A	W !! S DIC="^DOPT(""A1AEPH"",",DIC(0)="AEQM" D ^DIC Q:Y<0  D @+Y G A
	;
1	;Entry/Edit Patch Menu
	G ^A1AEPH1
	;
2	;Print Patch Menu
	G ^A1AEPH2
