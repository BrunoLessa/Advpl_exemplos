#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/**************************************************************************************************************************************************
******************************************************** CLASSE CARGA **************************************************************************
***************************************************************************************************************************************************/
Class oCarga
	Data cCodFil
	Data cNumero
	Data cSeq
	Data cRoteiro
	Data cCodMot
	Data cCaminh
	Data oMotoris
	Data nPeso
	Data nVolume
	Data nPtosEnt
	Data nValor
	Data cGerouNF
	Data dDtCarga
	Data cHrCarga
	Data cJuntou
	Data cCargaOk
	Data cEmbalOK
	Data cAcertFi
	Data dDtFina	
	Data aAjudans
	Data dDtRetor
	Data cMarkOk
	Data cUnitiz
	Data dDtEntr
	Data cLibWMS
	Data cBloqCar
	Data cHrEntr
	Data cIdViag
	Data cCodTrsp
	Data cNomTrsp
	Data cViagRot
	Data cStatFin
	Data aItens		
	Data cError
	Data bOpened 
	Data bConfer 
	Data nNumRec
	Data aConfer
	
	Method Create() Constructor
	Method ObtItens()
	Method ObtStatus()
EndClass   

//		Metodo Create da classe Carga
Method Create(cCodFil,cNumero,cSeq,cRoteiro, cCodMot, cCaminh, nPeso,nVolume,nPtosEnt,nValor,cGerouNF,dDtCarga,cHrCarga,cJuntou,cCargaOk,cEmbalOK,cAcertFi,dDtFina	,dDtRetor,cMarkOk,cUnitiz,dDtEntr,cLibWMS,cBloqCar,cHrEntr,cIdViag,cCodTrsp,cNomTrsp,cViagRot,cStatFin,bConfer,nNumRec) Class oCarga
	::cCodFil 	:= cCodFil
	::cNumero   := cNumero
	::cSeq		:= cSeq  
	::cRoteiro  := cRoteiro 
	::cCodMot	:= cCodMot
	::cCaminh   := cCaminh
	::nPeso		:= nPeso
	::nVolume	:= nVolume
	::nPtosEnt	:= nPtosEnt
	::nValor	:= nValor
	::cGerouNF	:= cGerouNF
	::dDtCarga	:= dDtCarga
	::cHrCarga  := cHrCarga
	::cJuntou	:= cJuntou
	::cCargaOk  := cCargaOk
	::cEmbalOK  := cEmbalOK
	::cAcertFi  := cAcertFi
	::dDtFina	:= dDtFina	
	::dDtRetor  := dDtRetor
	::cMarkOk   := cMarkOk
	::cUnitiz   := cUnitiz
	::dDtEntr   := dDtEntr
	::cLibWMS   := cLibWMS
	::cBloqCar  := cBloqCar
	::cHrEntr   := cHrEntr
	::cIdViag   := cIdViag
	::cCodTrsp  := cCodTrsp
	::cNomTrsp	:= cNomTrsp
	::cViagRot  := cViagRot
	::cStatFin  := cStatFin
	::aItens	:= {}
	::aAjudans  := {}
	::aConfer   := {}
	::bOpened 	:= .F.
	::bConfer   := bConfer
	::nNumRec   := nNumRec
	::cError 	:= ''	
 
Return Self                               

//		Metodo que Obtem os itens da Carga
Method ObtItens() Class oCarga
	::aAjudans  :=  fObtAjuds( ::cCodFil,::cNumero,::dDtCarga)
	::oMotoris  :=  fObtMotor( ::cCodFil,::cCodMot )
	::aItens    :=  fObtItens( ::cCodFil,::cNumero )
	::aConfer   :=  fObtConf(  ::cCodFil,::cNumero ) 
Return             
//		Metodo que Obtem os itens da Carga
Method ObtStatus() Class oCarga
	Local cRet := ''

	If ::cGerouNf == '2'
		cRet := 'Carga não faturada'
	ElseIf	::cGerouNf == '1' .And. ::cCargaOk == '2'
		cRet := 'Carga faturada e não liberada' 
	ElseIf	::cGerouNf == '1' .And. ::cCargaOk == '1' .And. ::cAcertFi =='2'		
		cRet := 'Carga em aberto'
	ElseIf	::cGerouNf == '1' .And. ::cCargaOk == '1' .And. ::cAcertFi =='1' .And. ::cStatFin != '1'
		cRet := 'Carga conferida e com pendênc.' 				
	ElseIf	::cGerouNf == '1' .And. ::cCargaOk == '1' .And. ::cAcertFi =='1' .And. ::cStatFin = '1'
		cRet := 'Carga conferida e encerrada' 						
	ElseIf	::cGerouNf == '1' .And. ::cLibWms == '1'  .And.  ::cStatFin # '1| '
		cRet := 'Carga bloqueada ou sem lib.WMS'
	EndIf	
		
Return( cRet )    
/**************************************************************************************************************************************************
******************************************************** CLASSE AJUDANTE **************************************************************************
***************************************************************************************************************************************************/
Class oAjudant
	Data cCod
	Data cNome
	Data cCPF
	Data cMatric
	Method Create() Constructor
EndClass   

//		Metodo Create da Classe oAjudant
Method Create(cCod, cNome, cCPF, cMatr ) Class oAjudant
	::cCod 		:= cCod	
	::cNome 	:= cNome
	::cCPF      := cCPF
	::cMatric   := cMatr		
Return Self       
/**************************************************************************************************************************************************
******************************************************** CLASSE MOTORISTA *************************************************************************
***************************************************************************************************************************************************/
Class oMotoris
	Data cCod
	Data cNome
	Data cCPF
	Data cMatric
	Data cTipo
	Data cCodFor
	Data cLoja

	Method Create() Constructor
EndClass   

// 		Metodo Create da Classe oMotoris
Method Create(cCod, cNome, cCPF, cMatr , cTipo, cCodFor, cLoja ) Class oMotoris
	::cCod 		:= cCod	
	::cNome 	:= cNome
	::cCPF      := cCPF 
	::cTipo     := cTipo
	::cMatric   := cMatr		
	::cCodFor   := cCodFor
	::cLoja     := cLoja
Return Self

/**************************************************************************************************************************************************
******************************************************** CLASSE ITENS DA CARGA ********************************************************************
***************************************************************************************************************************************************/
Class oCargIts
	Data cSequen
	Data cPedido
	Data cClient
	Data cLoja
	Data cVended
	Data nPeso
	Data nCapVol
	Data cZona
	Data cSetor
	Data cRota
	Data cSeqRot
	Data cNfisca
	Data cSerie
	Data dEmiCrg
	Data cHorCrg
	Data cCargOr
	Data cRemito
	Data cSerRem
	Data dDtCheg
	Data cHorChg
	Data cTimSrv
	Data dDtSaid
	Data cHrSaid
	Data nValFrt
	Data nFrtAut
	Data nNumRec	
	Data oNotaFi

	Method Create() Constructor
EndClass                 
// 		Metodo Create da Classe oCargIts
Method Create(cSequen,cPedido,cClient,cLoja,cVended,nPeso,nCapVol,cZona,cSetor,cRota,cSeqRot,cNfisca,cSerie,dEmiCrg,cHorCrg,cCargOr,cRemito,cSerRem,dDtCheg,cHorChg,cTimSrv,dDtSaid,cHrSaid,nValFrt,nFrtAut,nNumRec,oNotaFi ) Class oCargIts
	::cSequen   := cSequen
	::cPedido   := cPedido
	::cClient   := cClient
	::cLoja   	:= cLoja  
	::cVended   := cVended
	::nPeso   	:= nPeso  
	::nCapVol   := nCapVol
	::cZona   	:= cZona  
	::cSetor   	:= cSetor 
	::cRota   	:= cRota  
	::cSeqRot   := cSeqRot
	::cNfisca   := cNfisca
	::cSerie   	:= cSerie 
	::dEmiCrg   := dEmiCrg
	::cHorCrg   := cHorCrg
	::cCargOr   := cCargOr
	::cRemito   := cRemito
	::cSerRem   := cSerRem
	::dDtCheg   := dDtCheg
	::cHorChg   := cHorChg
	::cTimSrv   := cTimSrv
	::dDtSaid   := dDtSaid
	::cHrSaid   := cHrSaid
	::nValFrt   := nValFrt
	::nFrtAut   := nFrtAut
	::nNumRec   := nNumRec
	::oNotaFi   := oNotaFi
Return Self
/**************************************************************************************************************************************************
******************************************************** CLASSE NOTASFISCAIS *************************************************************************
***************************************************************************************************************************************************/
Class oNFiscais
	Data cCodFil
	Data cNumNf
	Data cSerie
	Data cEspec
	Data cClient
	Data cLoja
	Data dEmissao
	Data cTipoCli
	Data nValor	
	Data cPrefixo  
	Data cDuplic
	Data nNumRec
	Data cNomCli	
	Data aTitulos

	Method Create() Constructor
EndClass   

// 		Metodo Create da Classe oNFiscais
Method Create(cCodFil,cNumNf, cSerie, cEspec, cClient , cLoja, dEmissao, cTipoCli,nValor,cPrefixo,cDuplic,nNumRec,cNomCli  ) Class oNFiscais
	::cCodFil   := cCodFil
	::cNumNf 	:= cNumNf	
	::cSerie 	:= cSerie
	::cEspec    := cEspec 
	::cClient   := cClient
	::cLoja   	:= cLoja		
	::dEmissao  := dEmissao
	::cTipoCli  := cTipoCli
	::nValor   	:= nValor 
	::cPrefixo  := cPrefixo  
	::cDuplic	:= cDuplic
	::nNumRec   := nNumRec	
	::cNomCli   := cNomCli
	::aTitulos  := {}
	
Return Self

/**************************************************************************************************************************************************
******************************************************** CLASSE TITULOS *************************************************************************
***************************************************************************************************************************************************/
Class oTitfin 
	Data cCodFil
	Data cTipo
	Data cPrefixo
	Data cNumero
	Data cParcela	
	Data cClient
	Data cLoja
	Data dEmissao
	Data dVencrea	
	Data nValor	
	Data nAcres
	Data nDesc  	
	Data dBaixa
	Data nSaldo	
	Data cSeqBx	
	Data cIdentee
	Data cOrigem 
	Data nNumRec
	Data cPedido
	Data cNumBco
	Data cBcoChq
	Data cAgeChq
	Data cCtaChq
	Data cNumLiq
	Data cCondic
	Data cCndDes
	Data cStatus
	Method Create() Constructor
EndClass   

// 		Metodo Create da Classe oTitfin
Method Create( cCodFil,cTipo,cPrefixo,cNumero,cParcela,cClient,cLoja,dEmissao,dVencrea,nValor,nAcres,nDesc,dBaixa,nSaldo,cSeqBx,cIdentee,cOrigem,nNumRec,cPedido,cNumbco,cBcoChq,cAgeChq,cCtaChq,cNumLiq,cCondic,cCndDes, cStatus ) Class oTitfin						
	::cCodFil	:= cCodFil
	::cTipo		:= cTipo
	::cPrefixo	:= cPrefixo
	::cNumero	:= cNumero
	::cParcela	:= cParcela
	::cClient   := cClient
	::cLoja     := cLoja
	::dEmissao  := dEmissao
	::dVencrea	:= dVencrea
	::nValor	:= nValor
	::nAcres    := nAcres 
	::nDesc  	:= nDesc
	::dBaixa    := dBaixa
	::nSaldo	:= nSaldo
	::cSeqBx	:= cSeqBx
	::cIdentee  := cIdentee
	::cOrigem   := cOrigem 
	::nNumRec   := nNumRec
	::cPedido	:= cPedido
	::cNumbco   := cNumbco
	::cBcoChq   := cBcoChq
	::cAgeChq   := cAgeChq
	::cCtaChq	:= cCtaChq
	::cNumLiq   := cNumLiq
	::cCondic	:= cCondic
	::cCndDes	:= cCndDes 
	::cStatus   := cStatus
Return Self
/**************************************************************************************************************************************************
******************************************************** Funcoes Genericas ************************************************************************
***************************************************************************************************************************************************/
Static Function fObtAjuds(cCodFil, cCarga, dEmissao)
	Local cQry  	:= ''
	Local aArea 	:= GetArea()
	Local cAliAju   := GetNextAlias()
	Local aArr		:= {}            
	Local oAjud
		
	cQry  := "SELECT " + CRLF
	cQry  += "	DAK_COD," + CRLF
	cQry  += "	DAU_COD," + CRLF
	cQry  += "	DAU_NOME," + CRLF
	cQry  += "	DAU_CGC," + CRLF
	cQry  += "	DAU_XMATRI" + CRLF
	cQry  += "FROM " + CRLF
	cQry  += RetSqlname("DAK") + " DAK" + CRLF
	cQry  += "JOIN " + CRLF
	cQry  += RetSqlname("DAU") + " DAU" + CRLF
	cQry  += "ON " + CRLF              
	cQry  += "	DAK_FILIAL = DAU_FILIAL AND " + CRLF 
	cQry  += "	DAK_AJUDA1 = DAU_COD AND " + CRLF
	cQry  += "	DAU.D_E_L_E_T_ =' '" + CRLF
	cQry  += "WHERE " + CRLF
	cQry  += "	DAK_FILIAL ='" + cCodFil + "' AND " + CRLF
	cQry  += "	DAK_DATA ='" + dTos(dEmissao) + "' AND " + CRLF
	cQry  += "	DAK_COD ='" + cCarga + "' AND" + CRLF
	cQry  += "	DAK.D_E_L_E_T_ =' ' AND" + CRLF
	cQry  += "	DAK_AJUDA1 !=' '" + CRLF
	cQry  += "UNION " + CRLF
	cQry  += "SELECT  " + CRLF
	cQry  += "	DAK_COD, " + CRLF
	cQry  += "	DAU_COD, " + CRLF
	cQry  += "	DAU_NOME, " + CRLF
	cQry  += "	DAU_CGC, " + CRLF
	cQry  += "	DAU_XMATRI " + CRLF
	cQry  += "FROM  " + CRLF
	cQry  += RetSqlname("DAK") + " DAK" + CRLF
	cQry  += "JOIN " + CRLF
	cQry  += RetSqlname("DAU") + " DAU" + CRLF
	cQry  += "ON  " + CRLF
	cQry  += "	DAK_FILIAL = DAU_FILIAL AND " + CRLF
	cQry  += "	DAK_AJUDA2 = DAU_COD AND  " + CRLF
	cQry  += "	DAU.D_E_L_E_T_ =' ' " + CRLF
	cQry  += "WHERE  " + CRLF
	cQry  += "	DAK_FILIAL ='" + cCodFil + "' AND " + CRLF
	cQry  += "	DAK_DATA ='" + dTos(dEmissao) + "' AND  " + CRLF
	cQry  += "	DAK_COD ='" + cCarga + "' AND " + CRLF
	cQry  += "	DAK.D_E_L_E_T_ =' ' AND " + CRLF
	cQry  += "	DAK_AJUDA2 !=' '  " + CRLF
	cQry  += "UNION " + CRLF
	cQry  += "SELECT  " + CRLF
	cQry  += "	DAK_COD, " + CRLF
	cQry  += "	DAU_COD, " + CRLF
	cQry  += "	DAU_NOME, " + CRLF
	cQry  += "	DAU_CGC, " + CRLF
	cQry  += "	DAU_XMATRI " + CRLF
	cQry  += "FROM  " + CRLF
	cQry  += RetSqlname("DAK") + " DAK" + CRLF
	cQry  += "JOIN " + CRLF
	cQry  += RetSqlname("DAU") + " DAU" + CRLF
	cQry  += "ON  " + CRLF                          
	cQry  += "	DAK_FILIAL = DAU_FILIAL AND " + CRLF	
	cQry  += "	DAK_AJUDA3 = DAU_COD AND  " + CRLF
	cQry  += "	DAU.D_E_L_E_T_ =' ' " + CRLF
	cQry  += "WHERE  " + CRLF
	cQry  += "	DAK_FILIAL ='" + cCodFil + "' AND " + CRLF
	cQry  += "	DAK_DATA ='" + dTos(dEmissao) + "' AND  " + CRLF
	cQry  += "	DAK_COD ='" + cCarga + "' AND " + CRLF
	cQry  += "	DAK.D_E_L_E_T_ =' ' AND " + CRLF
	cQry  += "	DAK_AJUDA3 !=' '  " + CRLF
    memoWrite('c:\temp_msiga\qry01.txt',cQry)
  	If Select(cAliAju) > 0
		dbSelectArea(cAliAju)
		dbCloseArea()
	EndIf                  
	
	TcQuery cQry Alias cAliAju New

	While cAliAju->(!Eof())
		
		aAdd(aArr,oAjud := oAjudant():create(;
									 			cAliAju->DAU_COD,;
												cAliAju->DAU_NOME,;
												cAliAju->DAU_CGC,;
												cAliAju->DAU_XMATRI);
								   		     )
		cAliAju->(dbSkip())	
	EndDo
	cAliAju->(dbCloseArea())
	restArea(aArea)
Return( aArr )

//******************************
Static Function fObtMotor( cCodFil, cCod )
	Local cQry  	:= ''
	Local aArea 	:= GetArea()
	Local cAliMot   := GetNextAlias()
	Local oMotoris
		
	cQry  := "SELECT " + CRLF 
	cQry  += "	DA4_COD," + CRLF
	cQry  += "	DA4_NOME," + CRLF
	cQry  += "	DA4_CGC," + CRLF
	cQry  += "	DA4_TIPMOT," + CRLF
	cQry  += "	DA4_FORNEC," + CRLF
	cQry  += "	DA4_LOJA," + CRLF
	cQry  += "	DA4_MAT" + CRLF
	cQry  += "FROM " + CRLF
	cQry  += RetSqlname("DA4") + " DA4" + CRLF
	cQry  += "WHERE " + CRLF
	cQry  += "	DA4_FILIAL ='" + cCodFil + "' AND " + CRLF
	cQry  += "	DA4_COD ='" + cCod + "' AND " + CRLF
	cQry  += "	DA4.D_E_L_E_T_ =' ' " + CRLF

    memoWrite('c:\temp_msiga\qry02.txt',cQry)
  	If Select(cAliMot) > 0
		dbSelectArea(cAliMot)
		dbCloseArea()
	EndIf                  
	
	TcQuery cQry Alias cAliMot New

	While cAliMot->(!Eof())
		
		oMotoris:= oMotoris():create(;
				   			 			cAliMot ->DA4_COD,;
										cAliMot ->DA4_NOME,;
										cAliMot ->DA4_CGC,;
										cAliMot ->DA4_MAT,;
										cAliMot ->DA4_TIPMOT,;
										cAliMot ->DA4_FORNEC,;
										cAliMot ->DA4_LOJA;
				  				   )
		cAliMot->(dbSkip())	
	EndDo
	cAliMot->(dbCloseArea())
	restArea(aArea)
Return( oMotoris )

//******************************
Static Function fObtItens( cCodFil,cCod )
	Local cQry  	:= ''
	Local aArea 	:= GetArea()
	Local cAliDAI   := GetNextAlias()
	Local aArr      := {}
	Local oItens                 
	Local oNota
		
	cQry  := "SELECT " + CRLF 
	cQry  += "	DAI_FILIAL, " + CRLF
	cQry  += "	DAI_COD, " + CRLF
	cQry  += "	DAI_SEQCAR, " + CRLF
	cQry  += "	DAI_SEQUEN, " + CRLF
	cQry  += "	DAI_PEDIDO, " + CRLF
	cQry  += "	DAI_CLIENT, " + CRLF
	cQry  += "	DAI_LOJA, " + CRLF
	cQry  += "	DAI_VENDED, " + CRLF
	cQry  += "	DAI_PESO, " + CRLF
	cQry  += "	DAI_CAPVOL, " + CRLF
	cQry  += "	DAI_PERCUR, " + CRLF
	cQry  += "	DAI_ROTA, " + CRLF
	cQry  += "	DAI_ROTEIR, " + CRLF
	cQry  += "	DAI_SEQROT, " + CRLF
	cQry  += "	DAI_NFISCA, " + CRLF
	cQry  += "	DAI_SERIE, " + CRLF
	cQry  += "	DAI_DATA, " + CRLF
	cQry  += "	DAI_HORA, " + CRLF
	cQry  += "	DAI_CARORI, " + CRLF
	cQry  += "	DAI_REMITO, " + CRLF
	cQry  += "	DAI_SERREM, " + CRLF
	cQry  += "	DAI_DTCHEG, " + CRLF
	cQry  += "	DAI_CHEGAD, " + CRLF
	cQry  += "	DAI_TMSERV, " + CRLF
	cQry  += "	DAI_DTSAID, " + CRLF
	cQry  += "	DAI.R_E_C_N_O_ RECDAI, " + CRLF
	cQry  += "	DAI_VALFRE, " + CRLF
	cQry  += "	DAI_FREAUT, " + CRLF
	cQry  += "	DAI_SDOC, " + CRLF
	cQry  += "	DAI_SDOCRM, " + CRLF
	cQry  += "	F2_DOC, " + CRLF
	cQry  += "	F2_SERIE, " + CRLF
	cQry  += "	F2_CLIENTE, " + CRLF
	cQry  += "	F2_LOJA, " + CRLF
	cQry  += "	F2_COND, " + CRLF
	cQry  += "	F2_DUPL, " + CRLF
	cQry  += "	F2_EMISSAO, " + CRLF
	cQry  += "	F2_EST, " + CRLF
	cQry  += "	F2_FRETE, " + CRLF
	cQry  += "	F2_SEGURO, " + CRLF
	cQry  += "	F2_ICMFRET, " + CRLF
	cQry  += "	F2_TIPOCLI, " + CRLF
	cQry  += "	ISNULL(F2_VALBRUT, 0) F2_VALBRUT, " + CRLF
	cQry  += "	F2_VALICM, " + CRLF
	cQry  += "	F2_BASEICM, " + CRLF
	cQry  += "	F2_VALIPI, " + CRLF
	cQry  += "	F2_BASEIPI, " + CRLF
	cQry  += "	F2_VALMERC, " + CRLF
	cQry  += "	F2_NFORI, " + CRLF
	cQry  += "	F2_DESCONT, " + CRLF
	cQry  += "	F2_SERIORI, " + CRLF
	cQry  += "	F2_TIPO, " + CRLF
	cQry  += "	F2_ESPECI1, " + CRLF
	cQry  += "	F2_ESPECI2, " + CRLF
	cQry  += "	F2_ESPECI3, " + CRLF
	cQry  += "	F2_ESPECI4, " + CRLF
	cQry  += "	F2_VOLUME1, " + CRLF
	cQry  += "	F2_VOLUME2, " + CRLF
	cQry  += "	F2_VOLUME3, " + CRLF
	cQry  += "	F2_VOLUME4, " + CRLF
	cQry  += "	F2_ICMSRET, " + CRLF
	cQry  += "	F2_PLIQUI, " + CRLF
	cQry  += "	F2_PBRUTO, " + CRLF
	cQry  += "	F2_TRANSP, " + CRLF
	cQry  += "	F2_REDESP, " + CRLF
	cQry  += "	F2_VEND1, " + CRLF
	cQry  += "	F2_VEND2, " + CRLF
	cQry  += "	F2_VEND3, " + CRLF
	cQry  += "	F2_VEND4, " + CRLF
	cQry  += "	F2_VEND5, " + CRLF
	cQry  += "	F2_OK, " + CRLF
	cQry  += "	F2_FIMP, " + CRLF
	cQry  += "	F2_DTLANC, " + CRLF
	cQry  += "	F2_DTREAJ, " + CRLF
	cQry  += "	F2_REAJUST, " + CRLF
	cQry  += "	F2_DTBASE0, " + CRLF
	cQry  += "	F2_FATORB0, " + CRLF
	cQry  += "	F2_DTBASE1, " + CRLF
	cQry  += "	F2_FATORB1, " + CRLF
	cQry  += "	F2_VARIAC, " + CRLF
	cQry  += "	F2_FILIAL, " + CRLF
	cQry  += "	F2_BASEISS, " + CRLF
	cQry  += "	F2_VALISS, " + CRLF
	cQry  += "	F2_VALFAT, " + CRLF
	cQry  += "	F2_CONTSOC, " + CRLF
	cQry  += "	F2_BRICMS, " + CRLF
	cQry  += "	F2_FRETAUT, " + CRLF
	cQry  += "	F2_ICMAUTO, " + CRLF
	cQry  += "	F2_DESPESA, " + CRLF
	cQry  += "	F2_NEXTDOC, " + CRLF
	cQry  += "	F2_NEXTSER, " + CRLF
	cQry  += "	F2_ESPECIE, " + CRLF
	cQry  += "	F2_PDV, " + CRLF
	cQry  += "	F2_MAPA, " + CRLF
	cQry  += "	F2_ECF, " + CRLF
	cQry  += "	F2_PREFIXO, " + CRLF
	cQry  += "	F2_BASIMP1, " + CRLF
	cQry  += "	F2_BASIMP2, " + CRLF
	cQry  += "	F2_BASIMP3, " + CRLF
	cQry  += "	F2_BASIMP4, " + CRLF
	cQry  += "	F2_BASIMP5, " + CRLF
	cQry  += "	F2_BASIMP6, " + CRLF
	cQry  += "	F2_VALIMP1, " + CRLF
	cQry  += "	F2_VALIMP2, " + CRLF
	cQry  += "	F2_VALIMP3, " + CRLF
	cQry  += "	F2_VALIMP4, " + CRLF
	cQry  += "	F2_VALIMP5, " + CRLF
	cQry  += "	F2_VALIMP6, " + CRLF
	cQry  += "	F2_ORDPAGO, " + CRLF
	cQry  += "	F2_NFCUPOM, " + CRLF
	cQry  += "	F2_VALINSS, " + CRLF
	cQry  += "	F2_HORA, " + CRLF
	cQry  += "	F2_MOEDA, " + CRLF
	cQry  += "	F2_REGIAO, " + CRLF
	cQry  += "	F2_VALCSLL, " + CRLF
	cQry  += "	F2_VALCOFI, " + CRLF
	cQry  += "	F2_VALPIS, " + CRLF
	cQry  += "	F2_LOTE, " + CRLF
	cQry  += "	F2_TXMOEDA, " + CRLF
	cQry  += "	F2_CLEOK, " + CRLF
	cQry  += "	F2_CHVCLE, " + CRLF
	cQry  += "	F2_IDCLE, " + CRLF
	cQry  += "	F2_VALIRRF, " + CRLF
	cQry  += "	F2_CARGA, " + CRLF
	cQry  += "	F2_RECFAUT, " + CRLF
	cQry  += "	F2_SEQCAR, " + CRLF
	cQry  += "	F2_BASEINS, " + CRLF
	cQry  += "	F2_PEDPEND, " + CRLF
	cQry  += "	F2_DESCCAB, " + CRLF
	cQry  += "	F2_DTENTR, " + CRLF
	cQry  += "	F2_FORMUL, " + CRLF
	cQry  += "	F2_TIPODOC, " + CRLF
	cQry  += "	F2_NFEACRS, " + CRLF
	cQry  += "	F2_TIPOREM, " + CRLF
	cQry  += "	F2_SEQENT, " + CRLF
	cQry  += "	F2_ICMSDIF, " + CRLF
	cQry  += "	F2_VALACRS, " + CRLF
	cQry  += "	F2_RECISS, " + CRLF
	cQry  += "	F2_TIPORET, " + CRLF
	cQry  += "	F2_BASEPS3, " + CRLF
	cQry  += "	F2_VALPS3, " + CRLF
	cQry  += "	F2_BASECF3, " + CRLF
	cQry  += "	F2_VALCF3, " + CRLF
	cQry  += "	F2_BASPIS, " + CRLF
	cQry  += "	F2_NODIA, " + CRLF
	cQry  += "	F2_DIACTB, " + CRLF
	cQry  += "	F2_FILDEST, " + CRLF
	cQry  += "	F2_EMINFE, " + CRLF
	cQry  += "	F2_HAWB, " + CRLF
	cQry  += "	F2_ORDSEP, " + CRLF
	cQry  += "	F2_VEICUL2, " + CRLF
	cQry  += "	F2_VEICUL1, " + CRLF
	cQry  += "	F2_TIPIMP, " + CRLF
	cQry  += "	F2_CREDNFE, " + CRLF
	cQry  += "	F2_BSREIN, " + CRLF
	cQry  += "	F2_IDSA1, " + CRLF
	cQry  += "	F2_IDSA2, " + CRLF
	cQry  += "	F2_IDSED, " + CRLF
	cQry  += "	F2_HORNFE, " + CRLF
	cQry  += "	F2_NFELETR, " + CRLF
	cQry  += "	F2_DTESERV, " + CRLF
	cQry  += "	F2_BASEINA, " + CRLF
	cQry  += "	F2_VALFAC, " + CRLF
	cQry  += "	F2_VALFET, " + CRLF
	cQry  += "	F2_VALINA, " + CRLF
	cQry  += "	F2_CODNFE, " + CRLF
	cQry  += "	F2_RECOPI, " + CRLF
	cQry  += "	F2_FORMDES, " + CRLF
	cQry  += "	F2_NUMORC, " + CRLF
	cQry  += "	F2_ESTCRED, " + CRLF
	cQry  += "	F2_STATUS, " + CRLF
	cQry  += "	F2_SERSAT, " + CRLF
	cQry  += "	F2_BASEFMP, " + CRLF
	cQry  += "	F2_IDRECOP, " + CRLF
	cQry  += "	F2_TOTEST, " + CRLF
	cQry  += "	F2_TOTFED, " + CRLF
	cQry  += "	F2_TOTMUN, " + CRLF
	cQry  += "	F2_VALFMD, " + CRLF
	cQry  += "	F2_VALFMP, " + CRLF
	cQry  += "	F2_CHVNFE, " + CRLF
	cQry  += "	F2_FLAGDEV, " + CRLF
	cQry  += "	F2_TPFRETE, " + CRLF
	cQry  += "	F2_VALTST, " + CRLF
	cQry  += "	F2_BASEIRR, " + CRLF
	cQry  += "	F2_CGCCLI, " + CRLF
	cQry  += "	F2_LTRAN, " + CRLF
	cQry  += "	F2_TPCOMPL, " + CRLF
	cQry  += "	F2_MENNOTA, " + CRLF
	cQry  += "	F2_BASCOFI, " + CRLF
	cQry  += "	F2_BASCSLL, " + CRLF
	cQry  += "	F2_BASEFUN, " + CRLF
	cQry  += "	F2_VLSENAR, " + CRLF
	cQry  += "	F2_NFSUBST, " + CRLF
	cQry  += "	F2_NFICMST, " + CRLF
	cQry  += "	F2_NTFECP, " + CRLF
	cQry  += "	F2_CNO, " + CRLF
	cQry  += "	F2_TOTIMP, " + CRLF
	cQry  += "	F2_NUMMDF, " + CRLF
	cQry  += "	F2_CODRGS, " + CRLF
	cQry  += "	F2_DAUTNFE, " + CRLF
	cQry  += "	F2_EVENFLG, " + CRLF
	cQry  += "	F2_FLAGRGS, " + CRLF
	cQry  += "	F2_HAUTNFE, " + CRLF
	cQry  += "	F2_IDCCE, " + CRLF
	cQry  += "	F2_IDRGS, " + CRLF
	cQry  += "	F2_VALFAB, " + CRLF
	cQry  += "	F2_DESCZFR, " + CRLF
	cQry  += "	F2_DTTXREF, " + CRLF
	cQry  += "	F2_TXREF, " + CRLF
	cQry  += "	F2_FORDES, " + CRLF
	cQry  += "	F2_LOJADES, " + CRLF
	cQry  += "	F2_VREINT, " + CRLF
	cQry  += "	F2_REFTAXA, " + CRLF
	cQry  += "	F2_REFMOED, " + CRLF
	cQry  += "	F2_SDOCSUB, " + CRLF
	cQry  += "	F2_SDOCMAN, " + CRLF
	cQry  += "	F2_SDOCORI, " + CRLF
	cQry  += "	F2_SDOCMDF, " + CRLF
	cQry  += "	F2_SDOCNXT, " + CRLF
	cQry  += "	F2_SDOC, " + CRLF
	cQry  += "	F2_SERMDF, " + CRLF
	cQry  += "	F2_DTDIGIT, " + CRLF
	cQry  += "	F2_BASETST, " + CRLF
	cQry  += "	F2_VEICUL3, " + CRLF
	cQry  += "	F2_PREFORI, " + CRLF
	cQry  += "	F2_CLIENT, " + CRLF
	cQry  += "	F2_LOJENT, " + CRLF
	cQry  += "	F2_VALFDS, " + CRLF
	cQry  += "	F2_VLR_FRT, " + CRLF
	cQry  += "	F2_SERSUBS, " + CRLF
	cQry  += "	F2_GNRDIF, " + CRLF
	cQry  += "	F2_GNRFECP, " + CRLF
	cQry  += "	F2_VALFASE, " + CRLF
	cQry  += "	F2_VALFUND, " + CRLF
	cQry  += "	F2_VALIMA, " + CRLF
	cQry  += "	ISNULL(SF2.R_E_C_N_O_,0) SF2REC,  " + CRLF	
	cQry  += "	A1_NOME,  " + CRLF		
	cQry  += "	A1_NREDUZ  " + CRLF		
	cQry  += "FROM " + CRLF
	cQry  += RetSqlname("DAI") + " DAI" + CRLF 
	cQry  += "LEFT JOIN " + CRLF	
	cQry  += RetSqlname("SF2") + " SF2" + CRLF 	
	cQry  += "ON " + CRLF
	cQry  += "	DAI_FILIAL = F2_FILIAL  AND " + CRLF 	
	cQry  += "	DAI_NFISCA = F2_DOC     AND " + CRLF 
	cQry  += "	DAI_SERIE  = F2_SERIE   AND " + CRLF 				
	cQry  += "	DAI_CLIENT = F2_CLIENTE AND " + CRLF 		
	cQry  += "	DAI_LOJA   = F2_LOJA    AND " + CRLF
	cQry  += "	DAI_COD    = F2_CARGA   AND " + CRLF
	cQry  += "	SF2.D_E_L_E_T_ =' ' " + CRLF 			 			
	cQry  += "LEFT JOIN " + CRLF		
	cQry  += RetSqlname("SA1") + " SA1" + CRLF 	
	cQry  += "ON " + CRLF
	cQry  += "	F2_CLIENTE = A1_COD  AND " + CRLF 
	cQry  += "	F2_LOJA = A1_LOJA  AND " + CRLF 
	cQry  += "	SA1.D_E_L_E_T_ =' ' " + CRLF 			 			
	cQry  += "WHERE " + CRLF
	cQry  += "	DAI_FILIAL ='" + cCodFil + "' AND " + CRLF
	cQry  += "	DAI_COD ='" + cCod + "' AND " + CRLF
	cQry  += "	DAI.D_E_L_E_T_ =' ' " + CRLF

    memoWrite('c:\temp_msiga\qry03.txt',cQry)
  	If Select(cAliDAI) > 0
		dbSelectArea(cAliDAI)
		dbCloseArea()
	EndIf                  
	
	TcQuery cQry Alias cAliDAI New

	While cAliDAI->(!Eof())
		
		oItens := oCargIts():create(;
				  					cAliDAI ->DAI_SEQUEN,;
									cAliDAI->DAI_PEDIDO,; 
									cAliDAI->DAI_CLIENT,; 
									cAliDAI->DAI_LOJA,; 
									cAliDAI->DAI_VENDED,; 
									cAliDAI->DAI_PESO,; 
									cAliDAI->DAI_CAPVOL,; 
									cAliDAI->DAI_PERCUR,; 
									cAliDAI->DAI_ROTA,; 
									cAliDAI->DAI_ROTEIR,; 
									cAliDAI->DAI_SEQROT,; 
									cAliDAI->DAI_NFISCA,; 
									cAliDAI->DAI_SERIE,; 
									cAliDAI->DAI_DATA,; 
									cAliDAI->DAI_HORA,; 
									cAliDAI->DAI_CARORI,; 
									cAliDAI->DAI_REMITO,; 
									cAliDAI->DAI_SERREM,; 
									cAliDAI->DAI_DTCHEG,; 
									cAliDAI->DAI_CHEGAD,; 
									cAliDAI->DAI_TMSERV,; 
									cAliDAI->DAI_DTSAID,; 
									cAliDAI->DAI_VALFRE,; 
									cAliDAI->DAI_FREAUT,; 
									cAliDAI->RECDAI,;
									Nil;
					   			 )   
		oNota := oNFiscais():create( ;
									cAliDAI->F2_FILIAL,;
									cAliDAI->F2_DOC,;
									cAliDAI->F2_SERIE,;
									cAliDAI->F2_ESPECIE,;
									cAliDAI->F2_CLIENTE,;
									cAliDAI->F2_LOJA,;
									cAliDAI->F2_EMISSAO,;
									cAliDAI->F2_TIPOCLI,;
									cAliDAI->F2_VALBRUT,;
									cAliDAI->F2_PREFIXO,;
									cAliDAI->F2_DUPL,;
									cAliDAI->SF2REC,;
									cAliDAI->A1_NREDUZ;											
		)	                                                     
		oNota:aTitulos :=  fObtTits( cCodFil,oNota:cNumNf,oNota:cPrefixo , oNota:cSerie, oNota:cClient, oNota:cLoja, oNota:dEmissao)
		oItens:oNotaFi := oNota 				   			     
		aAdd(aArr,oItens)
		cAliDAI->(dbSkip())	
	EndDo
	cAliDAI->(dbCloseArea())
	restArea(aArea)
Return( aArr )
//******************************
Static Function fObtTits( cCodFil,cNumDoc, cPrefixo,cSerie,cCliente,cLoja,dEmissao )
	Local cQry  	:= ''
	Local aArea 	:= GetArea()
	Local cAliTit   := GetNextAlias()
	Local aArrTit  := {}
	Local oTitulo

	cQry := "SELECT " + CRLF
	cQry  += "	E1_FILIAL, " + CRLF
	cQry  += "	E1_PREFIXO, " + CRLF
	cQry  += "	E1_NUM, " + CRLF
	cQry  += "	E1_PARCELA, " + CRLF
	cQry  += "	E1_TIPO, " + CRLF
	cQry  += "	E1_NATUREZ, " + CRLF
	cQry  += "	E1_PORTADO, " + CRLF
	cQry  += "	E1_AGEDEP, " + CRLF
	cQry  += "	E1_CLIENTE, " + CRLF
	cQry  += "	E1_LOJA, " + CRLF
	cQry  += "	E1_NOMCLI, " + CRLF
	cQry  += "	E1_EMISSAO, " + CRLF
	cQry  += "	E1_VENCTO, " + CRLF
	cQry  += "	E1_VENCREA, " + CRLF
	cQry  += "	E1_VALOR, " + CRLF
	cQry  += "	E1_BASEIRF, " + CRLF
	cQry  += "	E1_IRRF, " + CRLF
	cQry  += "	E1_ISS, " + CRLF
	cQry  += "	E1_NUMBCO, " + CRLF
	cQry  += "	E1_INDICE, " + CRLF
	cQry  += "	E1_BAIXA, " + CRLF
	cQry  += "	E1_NUMBOR, " + CRLF
	cQry  += "	E1_DATABOR, " + CRLF
	cQry  += "	E1_EMIS1, " + CRLF
	cQry  += "	E1_HIST, " + CRLF
	cQry  += "	E1_LA, " + CRLF
	cQry  += "	E1_LOTE, " + CRLF
	cQry  += "	E1_MOTIVO, " + CRLF
	cQry  += "	E1_MOVIMEN, " + CRLF
	cQry  += "	E1_OP, " + CRLF
	cQry  += "	E1_SITUACA, " + CRLF
	cQry  += "	E1_CONTRAT, " + CRLF
	cQry  += "	E1_SALDO, " + CRLF
	cQry  += "	E1_SUPERVI, " + CRLF
	cQry  += "	E1_VEND1, " + CRLF
	cQry  += "	E1_VEND2, " + CRLF
	cQry  += "	E1_VEND3, " + CRLF
	cQry  += "	E1_VEND4, " + CRLF
	cQry  += "	E1_VEND5, " + CRLF
	cQry  += "	E1_COMIS1, " + CRLF
	cQry  += "	E1_COMIS2, " + CRLF
	cQry  += "	E1_COMIS3, " + CRLF
	cQry  += "	E1_COMIS4, " + CRLF
	cQry  += "	E1_DESCONT, " + CRLF
	cQry  += "	E1_COMIS5, " + CRLF
	cQry  += "	E1_MULTA, " + CRLF
	cQry  += "	E1_JUROS, " + CRLF
	cQry  += "	E1_CORREC, " + CRLF
	cQry  += "	E1_VALLIQ, " + CRLF
	cQry  += "	E1_VENCORI, " + CRLF
	cQry  += "	E1_CONTA, " + CRLF
	cQry  += "	E1_VALJUR, " + CRLF
	cQry  += "	E1_PORCJUR, " + CRLF
	cQry  += "	E1_MOEDA, " + CRLF
	cQry  += "	E1_BASCOM1, " + CRLF
	cQry  += "	E1_BASCOM2, " + CRLF
	cQry  += "	E1_BASCOM3, " + CRLF
	cQry  += "	E1_BASCOM4, " + CRLF
	cQry  += "	E1_BASCOM5, " + CRLF
	cQry  += "	E1_FATPREF, " + CRLF
	cQry  += "	E1_FATURA, " + CRLF
	cQry  += "	E1_OK, " + CRLF
	cQry  += "	E1_PROJETO, " + CRLF
	cQry  += "	E1_CLASCON, " + CRLF
	cQry  += "	E1_VALCOM1, " + CRLF
	cQry  += "	E1_VALCOM2, " + CRLF
	cQry  += "	E1_VALCOM3, " + CRLF
	cQry  += "	E1_VALCOM4, " + CRLF
	cQry  += "	E1_VALCOM5, " + CRLF
	cQry  += "	E1_OCORREN, " + CRLF
	cQry  += "	E1_INSTR1, " + CRLF
	cQry  += "	E1_INSTR2, " + CRLF
	cQry  += "	E1_PEDIDO, " + CRLF
	cQry  += "	E1_DTVARIA, " + CRLF
	cQry  += "	E1_VARURV, " + CRLF
	cQry  += "	E1_VLCRUZ, " + CRLF
	cQry  += "	E1_DTFATUR, " + CRLF
	cQry  += "	E1_NUMNOTA, " + CRLF
	cQry  += "	E1_SERIE, " + CRLF
	cQry  += "	E1_STATUS, " + CRLF
	cQry  += "	E1_ORIGEM, " + CRLF
	cQry  += "	E1_IDENTEE, " + CRLF
	cQry  += "	E1_NUMCART, " + CRLF
	cQry  += "	E1_FLUXO, " + CRLF
	cQry  += "	E1_DESCFIN, " + CRLF
	cQry  += "	E1_DIADESC, " + CRLF
	cQry  += "	E1_TIPODES, " + CRLF
	cQry  += "	E1_CARTAO, " + CRLF
	cQry  += "	E1_CARTVAL, " + CRLF
	cQry  += "	E1_CARTAUT, " + CRLF
	cQry  += "	E1_ADM, " + CRLF
	cQry  += "	E1_VLRREAL, " + CRLF
	cQry  += "	E1_TRANSF, " + CRLF
	cQry  += "	E1_BCOCHQ, " + CRLF
	cQry  += "	E1_AGECHQ, " + CRLF
	cQry  += "	E1_CTACHQ, " + CRLF
	cQry  += "	E1_NUMLIQ, " + CRLF
	cQry  += "	E1_ORDPAGO, " + CRLF
	cQry  += "	E1_RECIBO, " + CRLF
	cQry  += "	E1_INSS, " + CRLF
	cQry  += "	E1_FILORIG, " + CRLF
	cQry  += "	E1_DTACRED, " + CRLF
	cQry  += "	E1_TIPOFAT, " + CRLF
	cQry  += "	E1_TIPOLIQ, " + CRLF
	cQry  += "	E1_CSLL, " + CRLF
	cQry  += "	E1_COFINS, " + CRLF
	cQry  += "	E1_PIS, " + CRLF
	cQry  += "	E1_FLAGFAT, " + CRLF
	cQry  += "	E1_MESBASE, " + CRLF
	cQry  += "	E1_ANOBASE, " + CRLF
	cQry  += "	E1_PLNUCOB, " + CRLF
	cQry  += "	E1_CODINT, " + CRLF
	cQry  += "	E1_CODEMP, " + CRLF
	cQry  += "	E1_MATRIC, " + CRLF
	cQry  += "	E1_TXMOEDA, " + CRLF
	cQry  += "	E1_ACRESC, " + CRLF
	cQry  += "	E1_SDACRES, " + CRLF
	cQry  += "	E1_DECRESC, " + CRLF
	cQry  += "	E1_SDDECRE, " + CRLF
	cQry  += "	E1_MULTNAT, " + CRLF
	cQry  += "	E1_MSFIL, " + CRLF
	cQry  += "	E1_MSEMP, " + CRLF
	cQry  += "	E1_PROJPMS, " + CRLF
	cQry  += "	E1_DESDOBR, " + CRLF
	cQry  += "	E1_NRDOC, " + CRLF
	cQry  += "	E1_EMITCHQ, " + CRLF
	cQry  += "	E1_MODSPB, " + CRLF
	cQry  += "	E1_IDCNAB, " + CRLF
	cQry  += "	E1_PLCOEMP, " + CRLF
	cQry  += "	E1_PLTPCOE, " + CRLF
	cQry  += "	E1_CODCOR, " + CRLF
	cQry  += "	E1_PARCCSS, " + CRLF
	cQry  += "	E1_CODORCA, " + CRLF
	cQry  += "	E1_CODIMOV, " + CRLF
	cQry  += "	E1_FILDEB, " + CRLF
	cQry  += "	E1_NUMRA, " + CRLF
	cQry  += "	E1_NUMSOL, " + CRLF
	cQry  += "	E1_INSCRIC, " + CRLF
	cQry  += "	E1_SERREC, " + CRLF
	cQry  += "	E1_DATAEDI, " + CRLF
	cQry  += "	E1_CODBAR, " + CRLF
	cQry  += "	E1_CODDIG, " + CRLF
	cQry  += "	E1_CHQDEV, " + CRLF
	cQry  += "	E1_VLBOLSA, " + CRLF
	cQry  += "	E1_LIDESCF, " + CRLF
	cQry  += "	E1_NUMCRD, " + CRLF
	cQry  += "	E1_VLFIES, " + CRLF
	cQry  += "	E1_DEBITO, " + CRLF
	cQry  += "	E1_CCD, " + CRLF
	cQry  += "	E1_ITEMD, " + CRLF
	cQry  += "	E1_CLVLDB, " + CRLF
	cQry  += "	E1_CREDIT, " + CRLF
	cQry  += "	E1_CCC, " + CRLF
	cQry  += "	E1_ITEMC, " + CRLF
	cQry  += "	E1_CLVLCR, " + CRLF
	cQry  += "	E1_DESCON1, " + CRLF
	cQry  += "	E1_DESCON2, " + CRLF
	cQry  += "	E1_DTDESC3, " + CRLF
	cQry  += "	E1_DTDESC1, " + CRLF
	cQry  += "	E1_DTDESC2, " + CRLF
	cQry  += "	E1_VLMULTA, " + CRLF
	cQry  += "	E1_DESCON3, " + CRLF
	cQry  += "	E1_MOTNEG, " + CRLF
	cQry  += "	E1_SABTPIS, " + CRLF
	cQry  += "	E1_SABTCOF, " + CRLF
	cQry  += "	E1_SABTCSL, " + CRLF
	cQry  += "	E1_FORNISS, " + CRLF
	cQry  += "	E1_PARTOT, " + CRLF
	cQry  += "	E1_SITFAT, " + CRLF
	cQry  += "	E1_BASEPIS, " + CRLF
	cQry  += "	E1_BASECOF, " + CRLF
	cQry  += "	E1_BASECSL, " + CRLF
	cQry  += "	E1_VRETISS, " + CRLF
	cQry  += "	E1_PARCIRF, " + CRLF
	cQry  += "	E1_SCORGP, " + CRLF
	cQry  += "	E1_FRETISS, " + CRLF
	cQry  += "	E1_TXMDCOR, " + CRLF
	cQry  += "	E1_SATBIRF, " + CRLF
	cQry  += "	E1_TIPREG, " + CRLF
	cQry  += "	E1_CONEMP, " + CRLF
	cQry  += "	E1_VERCON, " + CRLF
	cQry  += "	E1_SUBCON, " + CRLF
	cQry  += "	E1_VERSUB, " + CRLF
	cQry  += "	E1_PLLOTE, " + CRLF
	cQry  += "	E1_PLOPELT, " + CRLF
	cQry  += "	E1_CODRDA, " + CRLF
	cQry  += "	E1_FORMREC, " + CRLF
	cQry  += "	E1_BCOCLI, " + CRLF
	cQry  += "	E1_AGECLI, " + CRLF
	cQry  += "	E1_CTACLI, " + CRLF
	cQry  += "	E1_PARCFET, " + CRLF
	cQry  += "	E1_FETHAB, " + CRLF
	cQry  += "	E1_MDCRON, " + CRLF
	cQry  += "	E1_MDCONTR, " + CRLF
	cQry  += "	E1_MEDNUME, " + CRLF
	cQry  += "	E1_MDPLANI, " + CRLF
	cQry  += "	E1_MDPARCE, " + CRLF
	cQry  += "	E1_MDREVIS, " + CRLF
	cQry  += "	E1_NUMMOV, " + CRLF
	cQry  += "	E1_PREFORI, " + CRLF
	cQry  += "	E1_IDMOV, " + CRLF
//	cQry  += "	E1_BOLETO, " + CRLF
	cQry  += "	E1_NUMPRO, " + CRLF
	cQry  += "	E1_INDPRO, " + CRLF
	cQry  += "	E1_JURFAT, " + CRLF
	cQry  += "	E1_NODIA, " + CRLF
	cQry  += "	E1_RETCNTR, " + CRLF
	cQry  += "	E1_MDDESC, " + CRLF
	cQry  += "	E1_MDBONI, " + CRLF
	cQry  += "	E1_MULTDIA, " + CRLF
	cQry  += "	E1_MDMULT, " + CRLF
	cQry  += "	E1_RELATO, " + CRLF
	cQry  += "	E1_FAMAD, " + CRLF
	cQry  += "	E1_FMPEQ, " + CRLF
	cQry  += "	E1_PARCFAM, " + CRLF
	cQry  += "	E1_PARCFMP, " + CRLF
	cQry  += "	E1_DESCJUR, " + CRLF
	cQry  += "	E1_FABOV, " + CRLF
	cQry  += "	E1_FACS, " + CRLF
	cQry  += "	E1_PRINSS, " + CRLF
	cQry  += "	E1_CCUSTO, " + CRLF
	cQry  += "	E1_NFELETR, " + CRLF
	cQry  += "	E1_DOCTEF, " + CRLF
	cQry  += "	E1_TITPAI, " + CRLF
	cQry  += "	E1_BASEINS, " + CRLF
	cQry  += "	E1_VLMINIS, " + CRLF
	cQry  += "	E1_TPDP, " + CRLF
	cQry  += "	E1_TPDESC, " + CRLF
	cQry  += "	E1_CODRET, " + CRLF
	cQry  += "	E1_PARTPDP, " + CRLF
	cQry  += "	E1_PARCFAC, " + CRLF
	cQry  += "	E1_PARCFAB, " + CRLF
	cQry  += "	E1_CDRETCS, " + CRLF
	cQry  += "	E1_CDRETIR, " + CRLF
	cQry  += "	E1_CLVL, " + CRLF
	cQry  += "	E1_ITEMCTA, " + CRLF
	cQry  += "	E1_NUMCON, " + CRLF
	cQry  += "	E1_APLVLMN, " + CRLF
	cQry  += "	E1_TPESOC, " + CRLF
	cQry  += "	E1_CNO, " + CRLF
	cQry  += "	E1_SABTIRF, " + CRLF
	cQry  += "	E1_DIACTB, " + CRLF
	cQry  += "	E1_BASEISS, " + CRLF
	cQry  += "	E1_CODISS, " + CRLF
	cQry  += "	E1_VRETIRF, " + CRLF
	cQry  += "	E1_NSUTEF, " + CRLF
	cQry  += "	E1_SEQBX, " + CRLF
	cQry  += "	E1_CHAVENF, " + CRLF
	cQry  += "	E1_CODIRRF, " + CRLF
	cQry  += "	E1_PRISS, " + CRLF
	cQry  += "	E1_CONHTL, " + CRLF
	cQry  += "	E1_TCONHTL, " + CRLF
	cQry  += "	E1_PERLET, " + CRLF
	cQry  += "	E1_PRODUTO, " + CRLF
	cQry  += "	E1_SDOC, " + CRLF
	cQry  += "	E1_SDOCREC, " + CRLF
	cQry  += "	E1_LTCXA, " + CRLF
	cQry  += "	E1_NOPER, " + CRLF
	cQry  += "	E1_TURMA, " + CRLF
	cQry  += "	E1_IDAPLIC, " + CRLF
	cQry  += "	E1_VLBOLP, " + CRLF
	cQry  += "	E1_SERVICO, " + CRLF
	cQry  += "	E1_IDBOLET, " + CRLF
	cQry  += "	E1_NUMINSC, " + CRLF
	cQry  += "	E1_PROCEL, " + CRLF
	cQry  += "	E1_IDLAN, " + CRLF
	cQry  += "	E1_CTRBCO, " + CRLF
	cQry  += "	E1_XCOND, " + CRLF
	cQry  += "	E1_DESCOND, " + CRLF
	cQry  += "	R_E_C_N_O_ NREC " + CRLF
	cQry  += "FROM " + CRLF
	cQry  += RetSqlname("SE1") + " SE1" + CRLF 	
	cQry  += "WHERE " + CRLF
	cQry  += "	E1_FILIAL ='" + cCodFil + "' AND " + CRLF
	cQry  += "	E1_NUM ='" + cNumDoc + "' AND " + CRLF
	cQry  += "	E1_PREFIXO = '" + cPrefixo + "' AND " + CRLF
	cQry  += "	E1_SERIE = '" + cSerie + "' AND " + CRLF
	cQry  += "	E1_CLIENTE = '" + cCliente + "' AND " + CRLF
	cQry  += "	E1_LOJA = '" + cLoja + "' AND " + CRLF
	cQry  += "	E1_EMISSAO = '" + dEmissao + "' AND "	
	cQry  += "	E1_ORIGEM = 'MATA460' AND "		
	cQry  += "	SE1.D_E_L_E_T_ =' ' "	
    memoWrite('c:\temp_msiga\qry04.txt',cQry)
   
  	If Select(cAliTit) > 0
		dbSelectArea(cAliTit)
		dbCloseArea()
	EndIf                  
	
	TcQuery cQry Alias cAliTit New

	While cAliTit->(!Eof())		  
		oTitulo := oTitfin():create( ;
						cAliTit->E1_FILIAL,;
						cAliTit->E1_TIPO,;
						cAliTit->E1_PREFIXO,;
						cAliTit->E1_NUM,;
						cAliTit->E1_PARCELA,;						
						cAliTit->E1_CLIENTE,;
						cAliTit->E1_LOJA,;
						cAliTit->E1_EMISSAO,;
						cAliTit->E1_VENCREA,;						
						cAliTit->E1_VALOR,;
						cAliTit->E1_SDACRES,;
						cAliTit->E1_SDDECRE,;                   
						cAliTit->E1_BAIXA,;						
						cAliTit->E1_SALDO,;						
						cAliTit->E1_SEQBX,;
						cAliTit->E1_IDENTEE,;
						cAliTit->E1_ORIGEM,;						
						cAliTit->NREC,;	
						cAliTit->E1_PEDIDO,;
						cAliTit->E1_NUMBCO,;
						cAliTit->E1_BCOCHQ,;
						cAliTit->E1_AGECHQ,;
						cAliTit->E1_CTACHQ,;
						cAliTit->E1_NUMLIQ,;
						cAliTit->E1_XCOND,;
						cAliTit->E1_DESCOND,;											
						cAliTit->E1_STATUS;
					  )		
		aAdd(aArrTit, oTitulo)					  
		cAliTit->(dbSkip())	
	EndDo                  
	cAliTit->(dbCloseArea())
	restArea(aArea)
return( aArrTit )

Static Function fObtConf(cCodFil, cCarga )
	Local cQry  	:= ''
	Local aArea 	:= GetArea()
	Local cAliConf  := GetNextAlias()
	Local aArrConf  := {}

	cQry  := "SELECT " + CRLF	
	cQry  += " DAP_FILIAL, " + CRLF
	cQry  += " DAP_CARGA, " + CRLF
	cQry  += " DAP_CODGRU, " + CRLF
	cQry  += " DAP_GRUPO, " + CRLF
	cQry  += " DAP_PREVIS, " + CRLF
	cQry  += " DAP_REALIZ, " + CRLF
	cQry  += " DAP_DTACER, " + CRLF
	cQry  += " DAP_FLGIMP, " + CRLF
	cQry  += " DAP_VALPRE, " + CRLF
	cQry  += " DAP_PREFIX, " + CRLF
	cQry  += " DAP_NUM, " + CRLF
	cQry  += " DAP_PARCEL, " + CRLF
	cQry  += " DAP_FORNEC, " + CRLF
	cQry  += " DAP_LOJA, " + CRLF
	cQry  += " DAP_TIPO, " + CRLF
	cQry  += " DAP_SEQCAR, " + CRLF
	cQry  += " DAP_FILCP, " + CRLF
	cQry  += " DAP_USER, " + CRLF
	cQry  += " DAP_RECIBO, " + CRLF
	cQry  += " DAP_XDEV, " + CRLF
	cQry  += " D_E_L_E_T_, " + CRLF
	cQry  += " R_E_C_N_O_, " + CRLF
	cQry  += " DAP_XLOGIN, " + CRLF
	cQry  += " DAP_XHORA " + CRLF
	cQry  += "FROM " + CRLF
	cQry  += RetSqlName("DAP") + " DAP " + CRLF
	cQry  += "WHERE " + CRLF
	cQry  += " DAP_FILIAL ='" + cCodFil + "' AND " + CRLF
	cQry  += " DAP_CARGA ='" + 	cCarga + "' AND " + CRLF
	cQry  += " D_E_L_E_T_ = ' ' "
	
  	If Select(cAliConf) > 0
		dbSelectArea(cAliConf)
		dbCloseArea()
	EndIf                  
	
	TcQuery cQry Alias cAliConf New

	While cAliConf->(!Eof())
		Aadd(aArrConf,{;
		              cAliConf->DAP_FILIAL,; //1
		              cAliConf->DAP_CARGA,;  //2
		              cAliConf->DAP_CODGRU,; //3
		              cAliConf->DAP_GRUPO,;  //4
		              cAliConf->DAP_PREVIS,; //5
		              cAliConf->DAP_REALIZ,; //6
		              cAliConf->DAP_DTACER,; //7
		              cAliConf->DAP_FLGIMP,; //8
		              cAliConf->DAP_VALPRE,; //9
		              cAliConf->DAP_PREFIX,; //10
		              cAliConf->DAP_NUM,;    //11
		              cAliConf->DAP_PARCEL,; //12
		              cAliConf->DAP_FORNEC,; //13
		              cAliConf->DAP_LOJA,;   //14
		              cAliConf->DAP_TIPO,;   //15
		              cAliConf->DAP_SEQCAR,; //16
		              cAliConf->DAP_FILCP,;  //17
		              cAliConf->DAP_USER,;   //18
		              cAliConf->DAP_RECIBO,; //19
		              cAliConf->DAP_XDEV,;   //20
		              cAliConf->R_E_C_N_O_,; //21
		              cAliConf->DAP_XLOGIN,; //22
		              cAliConf->DAP_XHORA;   //23
		              })
		cAliConf->(dbSkip())
	EndDo		            
	cAliConf->(dbCloseArea())
	RestArea(aArea)
return( aArrConf )