A1AEDD1 ;ven/jli-data dictionary related code ;2015-05-20T18:23
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ;
 Q
 ;
PLU949 ; pre-lookup transform for version field of file 9.4 add .0 to integer if exists
 ; ZEXCEPT: X already defined before lookup attempt starts
 I X?1.N1"."1.N.1A.2N Q
 I X?1.N.1A.2N D  Q  ; contains a numeric, but no decimal
 . N FOUND,DONE,VALUE,I
 . S FOUND=0,DONE=0
 . F I=1:1:$L(X) S VALUE="0123456789"[$E(X,I) S:VALUE FOUND=1 I FOUND,'VALUE S X=$E(X,1,I-1)_".0"_$E(X,I,$L(X)),DONE=1 Q
 . I FOUND,'DONE S X=X_".0" ; digit was the last character
 . Q
 I X?1.N1".".1A.2N S X=$P(X,".")_".0"_$P(X,".",2) ; no value following decimal
 Q
 ;
PLU96 ; Pre-Lookup Transform for Build file (#9.6)
PLU97 ; Pre-Lookup Transform for Install file (#9.7)
 ; ZEXCEPT: X defined before call is made
 I X?1A1.ANE1AP1.N1"."1.N Q  ; ONE CORRECT FORMAT WITH 1 OR more decimal places
 I X?1A1.APN1"*"1.N1"."1.N1"*"1.N Q  ; ANOTHER CORRECT FORMAT
 ; need to fix based on format
 I X?1A1.APN1"*"1.N1"."1"*"1.N.1A.2N S X=$P(X,"*")_"*"_$P(X,"*",2)_"0"_"*"_$P(X,"*",3) Q
 I X?1A1.APN1"*"1.N1"*"1.N.1A.2N S X=$P(X,"*")_"*"_$P(X,"*",2)_".0"_"*"_$P(X,"*",3) Q
 I X?1A1.ANE1AP1.N1"." S X=X_"0" Q
 I X?1A1.ANE1AP1.N S X=X_".0" Q
 ; any other input may be a partial - since it doesn't have a number in it.
 Q
 ;
PLU11005 ; pre-lookup transform for DHCP PATCHES file (#11005)
 ; ZEXCEPT: X defined before entry is made
 N VAL
 S VAL=$L(X)
 I X[".0",$E(X,VAL-1,VAL)=".0" S X=$P(X,".0")
 I X?1A1.APN1"*"1.N1"."1"0"1"*"1.N.1A.2N S X=$P(X,".0")_$P(X,".0",2)
 Q
 ;
PLU11004 ; pre-lookup transform for PATCH file (#11004)
 ; ZEXCEPT: X defined before entry is made
 N VAL
 S VAL=$L(X)
 I X[".0",$E(X,VAL-1,VAL)=".0" S X=$P(X,".0")
 I X?1A1.APN1"*"1.N1"."1"0"1"*"1.N.1A.2N S X=$P(X,".0")_$P(X,".0",2)
 Q
 ;
A1AESEQ ; called as SET cross-reference on NAME entry for PATCH APPLICATION HISTORY sub-file
 ; ZEXCEPT: DA,X - defined prior to entry
 N SEQ,PAT,PKG,VER,I,STRM,PATCH,PATNUM
 S SEQ=+$P(X,"#",2)
 I SEQ>0 S PKG=$P(^DIC(9.4,DA(2),0),U,2),VER=+^DIC(9.4,DA(2),22,DA(1),0),PATNUM=+X D
 . S STRM=0 F I=0:0 S I=$O(^A1AE(11007.1,I)) Q:I'>0  I PATNUM>(I-1) S STRM=I
 . I STRM=0 S STRM=1
 . S PATCH=PKG_"*"_VER_"*"_PATNUM
 . S ^DIC(9.4,"A1AESEQ",PKG,VER,STRM,SEQ,PATCH)=""
 . Q
 Q
 ;
KA1AESEQ ; called as KILL cross-reference on NAME entry for PATCH APPLICATION HISTORY sub-file
 ; ZEXCEPT: DA,X - defined prior to entry
 N SEQ,PAT,PKG,VER,I,STRM,PATCH,PATNUM
 S SEQ=+$P(X,"#",2)
 I SEQ>0 S PAT=$P(^(0),U),PKG=$P(^DIC(9.4,DA(2),0),U,2),VER=+^DIC(9.4,DA(2),22,DA(1),0),PATNUM=+X D
 . S STRM=0 F I=0:0 S I=$O(^A1AE(11007.1,I)) Q:I'>0  I PATNUM>(I-1) S STRM=I
 . I STRM=0 S STRM=1
 . S PATCH=PKG_"*"_VER_"*"_PATNUM
 . K ^DIC(9.4,"A1AESEQ",PKG,VER,STRM,SEQ,PATCH)
 . Q
 Q
