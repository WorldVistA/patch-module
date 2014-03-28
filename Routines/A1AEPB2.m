A1AEPB2	; RMO,MJK/ALBANY ; Print Problem Menu ;24 NOV 87 11:00 am
	;;2.4;PATCH MODULE;;Mar 28, 2014;Build 8
	;;Version 2.2;PROBLEM/PATCH REPORTING;;11/23/92
	G:$D(^DOPT("A1AEPB2",4)) A S ^DOPT("A1AEPB2",0)="Print Problem Menu Option^1N^" F I=1:1 S X=$T(@I) Q:X=""  S ^DOPT("A1AEPB2",I,0)=$P(X,";;",2,99)
	S DIK="^DOPT(""A1AEPB2""," D IXALL^DIK
A	W !! S DIC="^DOPT(""A1AEPB2"",",DIC(0)="AEQM" D ^DIC Q:Y<0  D @+Y G A
	;
1	;;Print a Specific Problem
	G Q
	;
2	;;Tabled Problems
	G Q
	;
3	;;Unresolved Problems
	G Q
	;
4	;;Unprinted Problems
	G Q
	;
Q	Q
