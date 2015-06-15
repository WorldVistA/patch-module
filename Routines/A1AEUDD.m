A1AEUDD ;ven/jli-unit tests for Data Dictionary code ;2015-05-22T17:33
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 D EN^%ut($T(+0))
 Q
 ;
VERBOSE ;
 D EN^%ut($T(+0),1)
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
 Q
 ;
PLU11005 ; @TEST prelookup transform for file 11005
 N X
 I '$D(^DIC(11005)) Q
 S X="PACKAGE 1.0" D PLU11005^A1AEDD1
 D CHKTF^%ut(X="PACKAGE 1","Didn't remove terminal .0 returned X="_X)
 S X="PK*1.0*2" D PLU11005^A1AEDD1
 D CHKTF^%ut(X="PK*1*2","Didn't remove .0 from * format, returned X="_X)
 S X="PK*1.02*2T3" D PLU11005^A1AEDD1
 D CHKTF^%ut(X="PK*1.02*2T3","Didn't handle multiple decimal places, returned X="_X)
 S X="PK*1.0*2T3" D PLU11005^A1AEDD1
 D CHKTF^%ut(X="PK*1*2T3","Didn't remove .0 from full * format, returned X="_X)
 S X="PK" D PLU11005^A1AEDD1
 D CHKTF^%ut(X="PK","Didn't return original without any numbers")
 Q
 ;
PLU11004 ; @TEST prelookup transform for file 11004
 N X
 I '$D(^DIC(11004)) Q
 S X="PACKAGE 1.0" D PLU11004^A1AEDD1
 D CHKTF^%ut(X="PACKAGE 1","Didn't remove terminal .0 returned X="_X)
 S X="PK*1.0*2" D PLU11004^A1AEDD1
 D CHKTF^%ut(X="PK*1*2","Didn't remove .0 from * format, returned X="_X)
 S X="PK*1.02*2T3" D PLU11004^A1AEDD1
 D CHKTF^%ut(X="PK*1.02*2T3","Didn't handle multiple decimal places, returned X="_X)
 S X="PK*1.0*2T3" D PLU11004^A1AEDD1
 D CHKTF^%ut(X="PK*1*2T3","Didn't remove .0 from full * format, returned X="_X)
 S X="PK" D PLU11004^A1AEDD1
 D CHKTF^%ut(X="PK","Didn't return original without any numbers")
 Q
 ;
A1AESEQ ; @TEST cross reference for sequence by package, version
 N PKGDA,VERDA,DAMIN,FDA,A1AEIEN,DA,DIK,A1AEMSG,PKGNAM,VERNUM
        S PKGDA=$O(^DIC(9.4,"B","PATCH MODULE",""))
        I PKGDA'>0 S PKGDA=$O(^DIC(9.4,"B","PATCH CLIENT","")) I PKGDA'>0 W !,"PACKAGE NOT FOUND" Q
 S PKGNAM=$P(^DIC(9.4,PKGDA,0),U,2)
 S VERDA=$O(^DIC(9.4,PKGDA,22," "),-1),VERNUM=$P(^DIC(9.4,PKGDA,22,VERDA,0),U)
 S DAMIN=$O(^DIC(9.4,PKGDA,22,VERDA,"PAH"," "),-1) S DAMIN=DAMIN+100
 S FDA(9.4901,"+"_DAMIN_","_VERDA_","_PKGDA_",",.01)="996 SEQ #996"
 S A1AEIEN(DAMIN)=DAMIN
 D UPDATE^DIE("E","FDA","A1AEIEN","A1AEMSG")
        D CHKTF^%ut($D(^DIC(9.4,"A1AESEQ",PKGNAM,+VERNUM,1,996,"A1AE*"_+VERNUM_"*996")),"A1AESEQ CROSS-REFERENCE NOT FOUND")
 S DA(2)=PKGDA,DA(1)=VERDA,DA=$G(A1AEIEN(DAMIN)),DIK="^DIC(9.4,DA(2),22,DA(1),""PAH""," D ^DIK
 D CHKTF^%ut('$D(^DIC(9.4,"A1AESEQ",PKGNAM,VERNUM,1,996,"A1AE*"_VERNUM_"*996")),"A1AESEQ CROSS-REFERENCE WAS NOT REMOVED ON DELETION")
 Q
