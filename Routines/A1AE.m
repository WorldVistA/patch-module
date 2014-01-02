A1AE	;RMO,MJK/ALBANY ; Main Patch/Problem Driver ;24 NOV 87 11:00 am
	;;2.3;Patch Module;;Oct 17, 2007;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;12/02/92
	G:$D(^DOPT("A1AE",3)) A S ^DOPT("A1AE",0)="Region 1 Patch and Problem Menu Option^1N^" F I=1:1 S X=$T(@I) Q:X=""  S ^DOPT("A1AE",I,0)=$P(X,";;",2,99)
	S DIK="^DOPT(""A1AE""," D IXALL^DIK
A	W !! S DIC="^DOPT(""A1AE"",",DIC(0)="AEQM" D ^DIC Q:Y<0  D @+Y G A
	;
1	;;Authorized Users Menu
	G ^A1AEAU
	;
2	;;Patch Menu
	G ^A1AEPH
	;
3	;;Problem Menu
	G ^A1AEPB
