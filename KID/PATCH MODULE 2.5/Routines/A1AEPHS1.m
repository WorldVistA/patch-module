A1AEPHS1 ;ven/toad-continuation of A1AEPHS ;2014-04-18T00:56
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
ESSMSG ;
 ; released or entered-in-error
 N XMTEXT,XMINSTR,STAT,PID,PRI,REL,COMP,I,CAT,%
 S PID=$P(A1AE0,U,1)
 I $P(PID,"*",2)=999 D
 . S $P(PID,"*",2)="DBA" ; Patch ID
 I $L($G(A1AEX))>2 D
 . S PID=A1AEX ;rwf
 S REL=$$FMTE^XLFDT(DT,"5Z") ; Release Date
 I A1AENEW="e" D
 . S STAT=2 ; Entered-in-Error
 . S (PRI,COMP,CAT)=""
 E  D
 . S STAT=3 ; Released
 . S COMP=$$FMTE^XLFDT($P(A1AE0,U,18),"5Z") ; Install by Date
 . S PRI=$P(A1AE0,U,7) ; Priority
 . S I=0
 . S CAT=""
 . F  S I=$O(^A1AE(11005,+$G(DA),"C",I)) Q:'I  D
 . . S CAT=CAT_","_^(I,0) ; Category
 . S CAT=$E(CAT,2,999)
 S XMTEXT(1)=STAT_$$LJ^XLFSTR(PID,30)_$$LJ^XLFSTR("",30)_$$LJ^XLFSTR(REL,22)_$$LJ^XLFSTR(COMP,22)_PRI_$$LJ^XLFSTR(CAT,23)
 S XMINSTR("FROM")="POSTMASTER"
 D SENDMSG^XMXAPI(DUZ,"NPM/ESS Transaction","XMTEXT","G.A1AE PACKAGE RELEASE@FORUM.OSEHRA.ORG",.XMINSTR) ; VEN/SMH - changed.
 ;
 QUIT  ; end of ESSMSG
