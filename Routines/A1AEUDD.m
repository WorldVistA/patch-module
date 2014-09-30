A1AEUDD ;JLI - Unit tests for Data Dictionary Code ;2014-09-30  1:59 AM
 ;;2.4;PATCH MODULE
 D EN^%ut($T(+0))
 Q
 ;
PLU949 ; @test prelookup transform for VERSION sub file in 9.4
 N X
 S X="15" D PLU949^A1AEDD1
 D CHKTF^%ut(X="15.0","failed to add decimal zero returned X="_X)
 S X="15." D PLU949^A1AEDD1
 D CHKTF^%ut(X="15.0","failed to identify . no digit returned X="_X)
 S X="15.01" D PLU949^A1AEDD1
 D CHKTF^%ut(X="15.01","failed on .01 as part of value returned X="_X)
 S X="15P2" D PLU949^A1AEDD1
 D CHKTF^%ut(X="15.0P2","failed on Numeric alpha numeric returned X="_X)
 Q
 ;
 ; CURRENTLY PLU96 and PLU97 run the same code, but they are
 ; included for both, since they might be moved at aome time
 ;
PLU96 ; @TEST prelookup transform for file 9.6
 N X
 S X="PACKAGE 1" D PLU96^A1AEDD1
 D CHKTF^%ut(X="PACKAGE 1.0","failed on adding .0 to package version returned X="_X)
 S X="PK*4*1" D PLU96^A1AEDD1
 D CHKTF^%ut(X="PK*4.0*1","failed on adding .0 to * setup returned X="_X)
 S X="PK*4.*1T2" D PLU96^A1AEDD1
 D CHKTF^%ut(X="PK*4.0*1T2","failed on adding zero after decimal returned X="_X)
 Q
 ;
PLU97 ; @TEST prelookup transform for file 9.7
 N X
 S X="PACKAGE 1" D PLU97^A1AEDD1
 D CHKTF^%ut(X="PACKAGE 1.0","failed on adding .0 to package version returned X="_X)
 S X="PK*4*1" D PLU97^A1AEDD1
 D CHKTF^%ut(X="PK*4.0*1","failed on adding .0 to * setup returned X="_X)
 S X="PK*4.*1T2" D PLU97^A1AEDD1
 D CHKTF^%ut(X="PK*4.0*1T2","failed on adding zero after decimal returned X="_X)
 S X="PK" D PLU97^A1AEDD1
 D CHKTF^%ut(X="PK","Didn't return original without any numbers")
 Q
 ;
PLU11005 ; @TEST prelookup transform for file 11005
 N X
 S X="PACKAGE 1.0" D PLU11005^A1AEDD1
 D CHKTF^%ut(X="PACKAGE 1","Didn't remove terminal .0 returned X="_X)
 S X="PK*1.0*2" D PLU11005^A1AEDD1
 D CHKTF^%ut(X="PK*1*2","Didn't remove .0 from * format, returned X="_X)
 S X="PK*1.02*2T3" D PLU11005^A1AEDD1
 D CHKTF^%ut(X="PK*1.02*2T3","Didn't handle multiple decimal places, returned X="_X)
 S X="PK*1.0*2T3" D PLU11005^A1AEDD1
 D CHKTF^%ut(X="PK*1*2T3","Didn't remove .0 from full * format, returned X="_X)
 Q

