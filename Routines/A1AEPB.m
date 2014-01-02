A1AEPB	; RMO,MJK/ALBANY ; Problem Menu ;24 NOV 87 11:00 am
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;11/23/92
	S IOP="HOME" D ^%ZIS
	G:$D(^DOPT("A1AEPB",2)) A S ^DOPT("A1AEPB",0)="Problem Menu Option^1N^" F I=1:1 S X=$T(@I) Q:X=""  S ^DOPT("A1AEPB",I,0)=$P(X,";",2,99)
	S DIK="^DOPT(""A1AEPB""," D IXALL^DIK
A	W !! S DIC="^DOPT(""A1AEPB"",",DIC(0)="AEQM" D ^DIC Q:Y<0  D @+Y G A
	;
1	;Entry/Edit Problem Menu
	G ^A1AEPB1
	;
2	;Print Problem Menu
	G ^A1AEPB2
