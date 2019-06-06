#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "TOTVS.CH"
#define DS_MODALFRAME   128
/*/

ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function REFP001()

	Local aIndDAK   := {}
	Local aArea     := GetArea()
	Local aCores    := {{ "DAK_FEZNF == '2'"                                                                          , 'BR_CINZA'    },;  // Carga não faturada
	{ "DAK_FEZNF == '1' .AND. DAK_ACECAR == '2'"                                                  , 'BR_BRANCO'	  },;  // Nota Emitida mas o carregamento nao liberado
	{ "DAK_FEZNF == '1' .AND. DAK_ACECAR == '1' .AND. DAK_ACEFIN == '2'"                          , 'BR_VERDE'	  },;  // Carga a conferir 
	{ "DAK_FEZNF == '1' .AND. DAK_ACECAR == '1' .AND. DAK_ACEFIN == '1' .AND. DAK_STAFIN != '1' " , 'BR_LARANJA'  },;  // Carga conferida mas com pendencias financeiras						
	{ "DAK_FEZNF == '1' .AND. DAK_ACECAR == '1' .AND. DAK_ACEFIN == '1' .AND. DAK_STAFIN == '1'"  , 'BR_VERMELHO' },;  // Carga Encerrada
	{ "DAK_ACEVAS =='2' .OR. DAK_BLWMS == '1' .OR. DAK_STAFIN #'1| ' "                            , 'BR_VIOLETA'  }}   // Carga bloqueada por WMS, Embalagens ou simplesmente bloqueada
	Local oBtnCnl
	Local oBtnOk
	Local oCargAte
	Local oCargDe
	Local oCmbTpCa
	Local oDtAte  
	Local oDtde
	Local oGroup1
	Local oMotAte
	Local oMotDe
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local cCargAte 	:= Replicate("Z",Len(DAK->DAK_COD))
	Local cCargDe  	:= Space(Len(DAK->DAK_COD))
	Local nCmbTpCa 	:= 1                     
	Local dDtAte 	:= Date()
	Local dDtde 	:= Date()
	Local cMotAte 	:= Replicate("Z",Len(DA4->DA4_COD))
	Local cMotDe 	:= Space(Len(DA4->DA4_COD))
	Local aSize 	:= GetScreenRes()

	Private bFiltraBrw 	:= {|| Nil}
	Private cCadastro 	:= OemtoAnsi( "Prestacao de Contas - V 1.0" )
	Private aRotina 	:= MenuDef()
	Private cCondicao 	:= ""   

	//Minhas alteracoes
	Private cPath 		:= "c:\TEMP_MSIGA\" 
	Private cNomArq 	:= "REFA005"

	Static oDlg


	DEFINE MSDIALOG oDlg TITLE "Filtro" FROM 000, 000  TO 320, 302 COLORS 0, 16777215 PIXEL

	@ 001, 001 GROUP oGroup1 TO 135, 149 PROMPT "Parâmetros: " OF oDlg COLOR 0, 16777215 PIXEL
	@ 013, 005 SAY oSay1 PROMPT "Data de:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 012, 046 MSGET oDtde VAR dDtde SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, 005 SAY oSay2 PROMPT "Data até:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 046 MSGET oDtAte VAR dDtAte SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 046, 005 SAY oSay3 PROMPT "Status da Carga:" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 044, 046 MSCOMBOBOX oCmbTpCa VAR nCmbTpCa ITEMS {"1=Todos","2=Conferido e Efetuado","3=Conferido","4=Em Aberto"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 061, 005 SAY oSay4 PROMPT "Carga de:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 060, 046 MSGET oCargDe VAR cCargDe SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "DAK" PIXEL
	@ 077, 005 SAY oSay5 PROMPT "Carga até:" SIZE 027, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 076, 046 MSGET oCargAte VAR cCargAte SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "DAK" PIXEL
	@ 093, 005 SAY oSay6 PROMPT "Motorista de:" SIZE 032, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 092, 046 MSGET oMotDe VAR cMotDe SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "DA4" PIXEL
	@ 109, 005 SAY oSay7 PROMPT "Motorista até:" SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 108, 046 MSGET oMotAte VAR cMotAte SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "DA4" PIXEL
	DEFINE SBUTTON oBtnCnl FROM 140, 017 TYPE 02 OF oDlg ENABLE
	DEFINE SBUTTON oBtnOk FROM 140, 109 TYPE 01 OF oDlg ENABLE
	ACTIVATE MSDIALOG oDlg CENTERED

	dbSelectArea("DAK")
	dbSetOrder(1)

	//cCondicao := "DAK_FILIAL == '" + xFilial("DAK") + "' .And. DAK_FEZNF == '1' .And. DAK_ACECAR == '1' "

	Pergunte("OMS341",.F.)
	SetKey(VK_F12,{|| Pergunte("OMS341",.T.)})

	bFiltraBrw := {|| FilBrowse("DAK",@aIndDAK,@cCondicao) } //passado para após ponto de entrada por Edson - ItAdvanced - 27/10/2008
	Eval(bFiltraBrw)

	mBrowse(6,1,22,75,"DAK",,,,,,aCores)

	dbSelectArea("DAK")
	RetIndex("DAK")
	dbClearFilter()
	aEval(aIndDAK,{|x| Ferase(x[1]+OrdBagExt())})
	SetKey(VK_F12,Nil)


Return()
//Carrega os dados carga
User Function Refp001a()
	Local aArea := GetArea()
	Local oCarga     

	oCarga:= oCarga():Create(;
	DAK->DAK_FILIAL,; //cFil
	DAK->DAK_COD   ,; //cNumero
	DAK->DAK_SEQCAR,; //cSeq
	DAK->DAK_ROTEIR,; //cRoteiro
	DAK->DAK_MOTORI,; //cCodMot 
	DAK->DAK_CAMINH,; //cCaminh
	DAK->DAK_PESO  ,; //nPeso
	DAK->DAK_CAPVOL,; //nVolume
	DAK->DAK_PTOENT,; //nPtosEnt
	DAK->DAK_VALOR ,; //nValor
	DAK->DAK_FEZNF ,; //cGerouNF
	DAK->DAK_DATA  ,; //dDtCarga
	DAK->DAK_HORA  ,; //cHrCarga
	DAK->DAK_JUNTOU,; //cJuntou
	DAK->DAK_ACECAR,; //cCargaOk
	DAK->DAK_ACEVAS,; //cEmbalOk
	DAK->DAK_ACEFIN,; //cAcertFi    
	DAK->DAK_DATA  ,;// VERIFICAR DDTFINA
	DAK->DAK_DTACCA,; // VERIFICAR DDTRETOR
	' ',;           // VERIFICAR MARKOK
	DAK->DAK_FLGUNI,;
	DAK->DAK_DATENT,;// VERIFICAR DDTENTR
	DAK->DAK_BLWMS ,; //cLibWMS
	DAK->DAK_BLQCAR,; //cBloqCar
	DAK->DAK_HRSTAR,; //cHrEntr
	DAK->DAK_IDENT ,; //cIdViag
	DAK->DAK_TRANSP,; //cCodTrsp
	''             ,; //cNomTrsp
	DAK->DAK_VIAROT ,; //cViagRot
	DAK->DAK_STAFIN ,; //cStatFin
	.F.             ,; // bConfer
	Recno() ;
	) 
	MsAguarde({||,oCarga:ObtItens()},"Aguarde...","Obtendo registros")	
	MntAcoes(oCarga)
	FreeObj(oCarga)
	RestArea(aArea)	
Return                  

// **************************** REFP001L - Monta a legenda ***********************************//
Static Function MntAcoes(oCarga)                                                                       
	Local aAdvSize  	:= MsAdvSize( .F. , .F. )
	Local aInfoAdvSize 	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4],  5 , 5 , 5 , 5 }
	Local aObjCoords 	:= { { 000 , 000 , .T. , .T. } }
	Local aMsObjSize 	:= MsObjSize( aInfoAdvSize , aObjCoords )    
	Local nObCli     	:= aAdvSize[5] - aAdvSize[3]
	local oFont1 		:= TFont():New("Arial" ,-11,-11,,,,,,,.F.,.F.) // Textos
	local oFont2 		:= TFont():New("Arial" ,-12,-12,,.T.,,,,,.F.,.F.) // Textos
	Local oVerde     	:= LoadBitmap(GetResources(),'BR_VERDE')    
	Local oAmarelo   	:= LoadBitmap(GetResources(),'BR_AMARELO') 
	Local oVermelho  	:= LoadBitmap(GetResources(),'BR_VERMELHO') 
	Local oPreto     	:= LoadBitmap(GetResources(),'BR_PRETO') 
	Local oAzul      	:= LoadBitmap(GetResources(),'BR_AZUL') 	
	Local oOk      		:= LoadBitmap(GetResources(),'LBOK') 	
	Local oNO      		:= LoadBitmap(GetResources(),'LBNO')	
	Local aCabFis    	:= {' ','Filial','Serie','Espécie','Nota Fiscal','Cliente','Loja','Emissao','Carga','Valor','Condicao','Duplicata' } 
	Local aCabFin    	:= {' ','Filial','Tipo','Prefixo','Numero','Parcel','Cliente','Loja','Emissao','Carga','Valor','Desconto','Juros','Baixa','Saldo','Identee','Pedido','Banco','Agencia','Conta','Liquidacao','Cond Pgto','Descricao' }
	Local nI			:= 0
	Private oGrpCab	  
	Private oSay      
	Private oSay2     
	Private oSay3     
	Private oSay4     
	Private oSay5     
	Private oSay6     
	Private oSay7     
	Private oSay8     
	Private oSay9     
	Private oSay10    
	Private oSay11    
	Private oSay12    
	Private oSay13    
	Private oSay14    
	Private oSay15    
	Private oSay16    
	Private oSay17    
	Private oSay18    		
	Private oSay19    
	Private oSay20    
	Private oSay21    
	Private oSay22    
	Private oSay23    
	Private oSay24    
	Private oSay25    
	Private oSay26    
	Private oGrpOpt	  
	Private oMnuConf
	Private oTButton1 
	Private oTButton2 
	Private oTButton3 
	Private oGrpFis	  
	Private oBrwFis
	Private oGrpFin
	Private oBrwFin		        
	Private oDlgAct   	
	Private aArrFis       := {}
	Private aArrFin       := {}
	Private nQtdNfs       := 0	
	Private nValNfs       := 0
	Private nQtdTit       := 0		
	Private nValTit       := 0	
	Private nTitBxs       := 0		
	Private nSldTit       := 0		
	Private nNfsSel       := 0			
	Private nTitSel       := 0			
	Private nValSel       := 0	

	/*
	MsAdvSize (http://tdn.totvs.com/display/public/mp/MsAdvSize+-+Dimensionamento+de+Janelas)
	aSize[1] = 1 -> Linha inicial área trabalho.    0
	aSize[2] = 2 -> Coluna inicial área trabalho. 30
	aSize[3] = 3 -> Linha final área trabalho.676
	aSize[4] = 4 -> Coluna final área trabalho. 299.5
	aSize[5] = 5 -> Coluna final dialog (janela). 1352
	aSize[6] = 6 -> Linha final dialog (janela).  599
	aSize[7] = 7 -> Linha inicial dialog (janela). 0
	aSize[8] = 8 -> Linha inicial dialog (janela). 5	 
	*/         
	For nI := 1 To Len(oCarga:aItens)
		aAdd(aArrFis,{ ;
		.F.,;//1
		oCarga:aItens[nI]:oNotaFi:cNumNf,;//2
		oCarga:aItens[nI]:oNotaFi:cSerie,;//3	 					
		oCarga:aItens[nI]:oNotaFi:cEspec,;//4
		oCarga:aItens[nI]:oNotaFi:cClient,;//5
		oCarga:aItens[nI]:oNotaFi:cLoja,;//6
		oCarga:aItens[nI]:oNotaFi:dEmissao,;//7
		oCarga:aItens[nI]:oNotaFi:cTipoCli,;//8
		oCarga:aItens[nI]:oNotaFi:nValor,;//9
		oCarga:aItens[nI]:oNotaFi:cPrefixo,;//10
		oCarga:aItens[nI]:oNotaFi:cDuplic,;//11			
		oCarga:aItens[nI]:oNotaFi:cNomCli;//12			
		})   
	Next nI
	ObtNums(oCarga)

	oDlgAct := MSDIALOG():New(000,000,aAdvSize[6],aAdvSize[5], 'Detalhes da Carga',,,,DS_MODALFRAME/*nOr(WS_VISIBLE,WS_POPUP)*/,,,,,.T.)  


	oGrpCab	  := tGroup():New(aAdvSize[7] ,  aAdvSize[8] ,aAdvSize[3]* 0.071, aAdvSize[3] * 0.905 ,OemToAnsi('Dados da Carga: '),oDlgAct,,,.T.)
	oSay      := TSay():New(  aAdvSize[4]* 0.034, aAdvSize[3] * 0.015 ,{||'Carga:'},oGrpCab,,oFont1,,,,.T.,,,200,20)		
	oSay2     := TSay():New(  aAdvSize[4]* 0.034, aAdvSize[3] * 0.049 ,{||oCarga:cNumero},oGrpCab,,oFont2,,,,.T.,CLR_HBLUE,,200,20)				
	oSay3     := TSay():New(  aAdvSize[4]* 0.070, aAdvSize[3] * 0.015 ,{||OemToAnsi('Emissão:')},oGrpCab,,oFont1,,,,.T.,,,200,20)		
	oSay4     := TSay():New(  aAdvSize[4]* 0.070, aAdvSize[3] * 0.049 ,{||OemToAnsi(Dtoc(oCarga:dDtCarga))},oGrpCab,,oFont1,,,,.T.,,,200,20)				
	oSay5     := TSay():New(  aAdvSize[4]* 0.112, aAdvSize[3] * 0.015 ,{||OemToAnsi('Status:')},oGrpCab,,oFont1,,,,.T.,,,200,20)
	oSay6     := TSay():New(  aAdvSize[4]* 0.112, aAdvSize[3] * 0.049 ,{||OemToAnsi(oCarga:ObtStatus())},oGrpCab,,oFont1,,,,.T.,,,200,20)										
	oSay7     := TSay():New(  aAdvSize[4]* 0.034, aAdvSize[3] * 0.185 ,{||'Quant. NFs:'},oGrpCab,,oFont1,,,,.T.,,,200,20)		//200
	oSay8     := TSay():New(  aAdvSize[4]* 0.034, aAdvSize[3] * 0.235 ,{||Padr(AllTrim(Transform(nQtdNfs ,"@E 9999")),10)},oGrpCab,,oFont1,,,,.T.,,,200,20)
	oSay9     := TSay():New(  aAdvSize[4]* 0.070, aAdvSize[3] * 0.185 ,{||'Valor  NFs:'},oGrpCab,,oFont1,,,,.T.,,,200,20)				
	oSay10    := TSay():New(  aAdvSize[4]* 0.070, aAdvSize[3] * 0.235 ,{||Padr(AllTrim(Transform(nValNfs ,"@E 999,999,999.99")),10) },oGrpCab,,oFont1,,,,.T.,,,200,20) 
	oSay11    := TSay():New(  aAdvSize[4]* 0.112, aAdvSize[3] * 0.185 ,{||'Qtd. Titulos:'},oGrpCab,,oFont1,,,,.T.,,,200,20)						
	oSay12    := TSay():New(  aAdvSize[4]* 0.112, aAdvSize[3] * 0.235 ,{||Padr(Alltrim(Transform(nQtdTit ,"@E 9999")),10) },oGrpCab,,oFont1,,,,.T.,,,200,20)						
	oSay13    := TSay():New(  aAdvSize[4]* 0.034, aAdvSize[3] * 0.310 ,{||'Valor  Tit:'},oGrpCab,,oFont1,,,,.T.,,,200,20) //385
	oSay14    := TSay():New(  aAdvSize[4]* 0.034, aAdvSize[3] * 0.350 ,{||Padr(AllTrim(Transform(nValTit ,"@E 999,999,999.99")),10) },oGrpCab,,oFont1,,,,.T.,,,200,20) 
	oSay15    := TSay():New(  aAdvSize[4]* 0.070, aAdvSize[3] * 0.310 ,{||'Tit. Baix:'},oGrpCab,,oFont1,,,,.T.,,,200,20)		
	oSay16    := TSay():New(  aAdvSize[4]* 0.070, aAdvSize[3] * 0.350 ,{||Padr(AllTrim(Transform(nTitBxs,"@E 9999")),10) },oGrpCab,,oFont1,,,,.T.,,,200,20) 
	oSay17    := TSay():New(  aAdvSize[4]* 0.112, aAdvSize[3] * 0.310 ,{||'Saldo  Tit:'},oGrpCab,,oFont1,,,,.T.,,,200,20)		
	oSay18    := TSay():New(  aAdvSize[4]* 0.112, aAdvSize[3] * 0.350 ,{||Padr(AllTrim(Transform(nSldTit ,"@E 999,999,999.99")),10) },oGrpCab,,oFont1,,,,.T.,,,200,20) 		
	oSay19    := TSay():New(  aAdvSize[4]* 0.034, aAdvSize[3] * 0.425 ,{||'Nfs Sel:'},oGrpCab,,oFont1,,,,.T.,,,200,20)		// 570
	oSay20    := TSay():New(  aAdvSize[4]* 0.034, aAdvSize[3] * 0.475 ,{||Padr(AllTrim(Transform(nNfsSel,"@E 9999")),10)},oGrpCab,,oFont1,,,,.T.,,,200,20)		
	oSay21    := TSay():New(  aAdvSize[4]* 0.070, aAdvSize[3] * 0.425 ,{||'Tit. Sel:'},oGrpCab,,oFont1,,,,.T.,,,200,20)		
	oSay22    := TSay():New(  aAdvSize[4]* 0.070, aAdvSize[3] * 0.475 ,{||Padr(AllTrim(Transform(nTitSel,"@E 9999")),10) },oGrpCab,,oFont1,,,,.T.,,,200,20) 
	oSay23    := TSay():New(  aAdvSize[4]* 0.112, aAdvSize[3] * 0.425 ,{||'Valor Sel:'},oGrpCab,,oFont1,,,,.T.,,,200,20)		
	oSay24    := TSay():New(  aAdvSize[4]* 0.112, aAdvSize[3] * 0.475 ,{||Padr(AllTrim(Transform(nValSel,"@E 999,999,999.99")),10) },oGrpCab,,oFont1,,,,.T.,,,200,20) 
	oSay25    := TSay():New(  aAdvSize[4]* 0.034, aAdvSize[3] * 0.755 ,{||'Conferido:'},oGrpCab,,oFont1,,,,.T.,,,200,20)				
	oSay26    := TSay():New(  aAdvSize[4]* 0.034, aAdvSize[3] * 0.805 ,{||'Sim'},oGrpCab,,oFont2,,,,.T.,CLR_HGREEN,,200,20)						
	oGrpOpt	  := tGroup():New(aAdvSize[7] ,  aAdvSize[3] * 0.91 ,aAdvSize[4], aAdvSize[3] * 0.998 ,OemToAnsi('Opções: '),oDlgAct,,,.T.) 
	oMnuConf := TMenu():New(0,0,0,0,.T.)		
	oMnuConf1 := TMenuItem():New(oDlg,"&Inserir    ",,,,{||Confere(oCarga,1)},,,,,,,,,.T.)
	
	If len(oCarga:aConfer) > 0
		oMnuConf1:lActive := .F.
	EndIf		
	
	oMnuConf2 := TMenuItem():New(oDlg,"&Alterar    ",,,,{||Confere(oCarga,2)},,,,,,,,,.T.)
	oMnuConf3 := TMenuItem():New(oDlg,"&Visualizar ",,,,{||Confere(oCarga,3)},,,,,,,,,.T.)
	oMnuConf4 := TMenuItem():New(oDlg,"&Excluir    ",,,,{||Confere(oCarga,4)} ,,,,,,,,,.T.)
	oMnuConf:Add(oMnuConf1)
	oMnuConf:Add(oMnuConf2)
	oMnuConf:Add(oMnuConf3)
	oMnuConf:Add(oMnuConf4)		
	oTButton1 := TButton():New( aAdvSize[3]* 0.018 , aAdvSize[3] * 0.921, "&Conferir",oGrpOpt,{||}, 44,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton1:SetPopupMenu(oMnuConf)
	oTButton2 := TButton():New( aAdvSize[3]* 0.039 , aAdvSize[3] * 0.921, "&Prestar Contas",oGrpOpt,{||alert("Botão 03")}, 44,12,,,.F.,.T.,.F.,,.F.,,,.F. )		
	oTButton3 := TButton():New( aAdvSize[3]* 0.059 , aAdvSize[3] * 0.921, "&Sair",oGrpOpt,{||oDlgAct:End()}, 44,12,,,.F.,.T.,.F.,,.F.,,,.F. )				
	oGrpFis	  := tGroup():New( aAdvSize[3]* 0.073 ,  aAdvSize[8] ,aAdvSize[4] * 0.57, aAdvSize[3] * 0.905 ,OemToAnsi('Notas Fiscais: '),oDlgAct,,,.T.)
	oBrwFis   := TCBrowse():New( aAdvSize[3]* 0.082 , aAdvSize[8]+2, aAdvSize[3] * 0.893, aAdvSize[4] * 0.38,,,,oGrpFis,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrwFis:AddColumn( TCColumn():New(         ,	{ || Iif(aArrFis[oBrwFis:nAt,01],oOK,oNO)},,,,"LEFT", 10,.T.,.F.,,,,.T.))  
	oBrwFis:addColumn( TCColumn():new( 'Num. Nota',	{ || aArrFis[oBrwFis:nAt,02]},,,, 'LEFT',, .F., .F.,,,, .F. ) )  
	oBrwFis:addColumn( TCColumn():new( 'Serie'    ,	{ || aArrFis[oBrwFis:nAt,03]},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 			
	oBrwFis:addColumn( TCColumn():new( 'Especie'  ,	{ || aArrFis[oBrwFis:nAt,04]},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 			
	oBrwFis:addColumn( TCColumn():new( 'Cliente'  ,	{ || aArrFis[oBrwFis:nAt,05]},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 			
	oBrwFis:addColumn( TCColumn():new( 'Loja'     ,	{ || aArrFis[oBrwFis:nAt,06]},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 			
	oBrwFis:addColumn( TCColumn():new( 'Nome Cli.',	{ || aArrFis[oBrwFis:nAt,12]},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 						
	oBrwFis:addColumn( TCColumn():new( 'Emissao'  ,	{ || dToc(stod(aArrFis[oBrwFis:nAt,07]))},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 			
	oBrwFis:addColumn( TCColumn():new( 'Valor'    ,	{ || Padl(AllTrim(Transform(aArrFis[oBrwFis:nAt,09],"@E 999,999,999.99")),10)},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 
	oBrwFis:SetArray(aArrFis)    
	oGrpFin	  := tGroup():New( aAdvSize[4] * 0.58 ,  aAdvSize[8] ,aAdvSize[4] , aAdvSize[3] * 0.905 ,OemToAnsi('Títulos Financeiros: '),oDlgAct,,,.T.)		
	oBrwFin   := TCBrowse():New( aAdvSize[4]* 0.60 , aAdvSize[8]+2, aAdvSize[3] * 0.893, aAdvSize[4] * 0.40,, ,, oGrpFin,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrwFin:AddColumn( TCColumn():New(              ,	{ || Iif(aArrFin[oBrwFin:nAt,01],oOK,oNO)},,,,"LEFT", 10,.T.,.F.,,,,.T.))  
	oBrwFin:addColumn( TCColumn():new( 'Tipo'       ,   { || aArrFin[oBrwFin:nAt,03]},,,, 'LEFT',, .F., .F.,,,, .F. ) )  
	oBrwFin:addColumn( TCColumn():new( 'Prefixo'    ,	{ || aArrFin[oBrwFin:nAt,04]},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 
	oBrwFin:addColumn( TCColumn():new( 'Num. Titulo',	{ || aArrFin[oBrwFin:nAt,05]},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 			 			
	oBrwFin:addColumn( TCColumn():new( 'Parcela'    ,	{ || aArrFin[oBrwFin:nAt,06]},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 			
	oBrwFin:addColumn( TCColumn():new( 'Cliente'    ,	{ || aArrFin[oBrwFin:nAt,07]},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 			
	oBrwFin:addColumn( TCColumn():new( 'Loja'       ,	{ || aArrFin[oBrwFin:nAt,08]},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 			
	oBrwFin:addColumn( TCColumn():new( 'Emissao'    ,	{ || dToc(sTod(aArrFin[oBrwFin:nAt,09]))},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 			
	oBrwFin:addColumn( TCColumn():new( 'Vencto'     ,	{ || dToc(sTod(aArrFin[oBrwFin:nAt,10]))},,,, 'LEFT',, .F., .F.,,,, .F. ) ) 						
	oBrwFin:addColumn( TCColumn():new( 'Valor'      ,	{ || Padl(AllTrim(Transform(aArrFin[oBrwFin:nAt,11],"@E 999,999,999.99")),10)},,,, 'RIGHT',, .F., .F.,,,, .F. ) )			
	oBrwFin:addColumn( TCColumn():new( 'Acrescimo'  ,	{ || Padl(AllTrim(Transform(aArrFin[oBrwFin:nAt,12],"@E 999,999,999.99")),10)},,,, 'RIGHT',, .F., .F.,,,, .F. ) )			
	oBrwFin:addColumn( TCColumn():new( 'Descontos'  ,	{ || Padl(AllTrim(Transform(aArrFin[oBrwFin:nAt,13],"@E 999,999,999.99")),10)},,,, 'RIGHT',, .F., .F.,,,, .F. ) )			
	oBrwFin:addColumn( TCColumn():new( 'Baixa'      ,	{ || dToc(Stod(aArrFin[oBrwFin:nAt,14]))},,,, 'LEFT',, .F., .F.,,,, .F. ) )				
	oBrwFin:addColumn( TCColumn():new( 'Saldo'      ,	{ || Padl(AllTrim(Transform(aArrFin[oBrwFin:nAt,15],"@E 999,999,999.99")),10)},,,, 'RIGHT',, .F., .F.,,,, .F. ) )			
	oBrwFin:addColumn( TCColumn():new( 'Borderô'   ,	{ || aArrFin[oBrwFin:nAt,16]},,,, 'LEFT',, .F., .F.,,,, .F. ) )
	oBrwFin:addColumn( TCColumn():new( 'Pedido'     ,	{ || aArrFin[oBrwFin:nAt,17]},,,, 'LEFT',, .F., .F.,,,, .F. ) )
	oBrwFin:addColumn( TCColumn():new( 'Banco'      ,	{ || aArrFin[oBrwFin:nAt,18]},,,, 'LEFT',, .F., .F.,,,, .F. ) )
	oBrwFin:addColumn( TCColumn():new( 'Agencia'    ,	{ || aArrFin[oBrwFin:nAt,19]},,,, 'LEFT',, .F., .F.,,,, .F. ) )
	oBrwFin:addColumn( TCColumn():new( 'Conta'      ,	{ || aArrFin[oBrwFin:nAt,20]},,,, 'LEFT',, .F., .F.,,,, .F. ) )
	oBrwFin:addColumn( TCColumn():new( 'Liquidacao' ,	{ || aArrFin[oBrwFin:nAt,21]},,,, 'LEFT',, .F., .F.,,,, .F. ) )
	oBrwFin:addColumn( TCColumn():new( 'Cond Pgto'  ,	{ || aArrFin[oBrwFin:nAt,22]},,,, 'LEFT',, .F., .F.,,,, .F. ) )
	oBrwFin:addColumn( TCColumn():new( 'Descricao'  ,	{ || aArrFin[oBrwFin:nAt,23]},,,, 'LEFT',, .F., .F.,,,, .F. ) )													
	oBrwFin:addColumn( TCColumn():new( 'Status'     ,	{ || aArrFin[oBrwFin:nAt,24]},,,, 'LEFT',, .F., .F.,,,, .F. ) )																
	oBrwFin:SetArray(aArrFin)					

	oBrwFis:bWhen := { || Len(aArrFis) > 0 }      
	oBrwFis:bHeaderClick :=  {|| fSelectAll(oCarga) }
	oBrwFis:bLDblClick 	 :=  {|| aArrFis[oBrwFis:nAt,01] := !aArrFis[oBrwFis:nAt,01],fSelectOne(oCarga) }
	oBrwFin:bLDblClick 	 :=  {|| aArrFin[oBrwFin:nAt,01] := !aArrFin[oBrwFin:nAt,01],fOneTit()}
	oBrwFin:bHeaderClick :=  {|| fAllTits(oCarga) }

	oDlgAct:lCentered 	:= .T.
	oDlgAct:Activate()

Return
// **************************** MenuDef ***********************************//
Static Function MenuDef()

	If cPaisLoc!="BRA"   

	Else              
		aRotina := {	{ OemtoAnsi("&Pesquisar" ), "PesqBrw"	 , 0, 1 , 0 , .F.},;	//"Pesquisa"  
		{ OemtoAnsi("&Visualizar"), ""  , 0, 2 , 0 , NIL},;    //"Visualiza"
		{ OemtoAnsi("&Ações"     ), "U_REFP001A" , 0, 4 , 0 , NIL},;	//"Legenda"
		{ OemtoAnsi("&Legenda "  ), "U_REFP001L" , 0, 3 , 0 , NIL}}	//"Legenda"						
	EndIf

Return(aRotina)

// **************************** REFP001L - Monta a legenda ***********************************//
User Function REFP001L() 

	BrwLegenda( cCadastro, OemToAnsi( "Status" ), {;
	{ "BR_CINZA"        , OemToAnsi( "Carga não faturada									" ) },; 
	{ "BR_BRANCO"       , OemToAnsi( "Carga faturada e não liberada						" ) },;
	{ "BR_VIOLETA"      , OemToAnsi( "Carga bloqueada ou sem liberação WMS ou embalagens	" ) },;                                                 												  
	{ "BR_VERDE"        , OemToAnsi( "Carga em aberto										" ) },;
	{ "BR_LARANJA"      , OemToAnsi( "Carga conferida e com pendências financeiras			" ) },;
	{ "BR_VERMELHO"     , OemToAnsi( "Carga conferida e encerrada							" ) };
	} ) //"Em aberto"

Return( Nil ) 
// **************************** fSelectAll - Marca todos os registros do Browse Fiscal e popula o Browse Financeiro ***********************************//
Static Function fSelectAll(oCarga)
	Local nCount  := 0                                                               
	Local lZerArr := .F.
	aArrFin       := {}	
	nNfsSel 	  := 0  	
	nTitSel 	  := 0 
	nTitBxs       := 0
	nValSel       := 0

	For nCount:=1 to Len(aArrFis)
		aArrFis[nCount,1] := !aArrFis[nCount,1]
		If aArrFis[nCount,1]                   	     			

			If !lZerArr
				lZerArr := .T. 
				aArrFin := {}    							
				nNfsSel := 0
				nTitBxs := 0
				nValSel := 0				 			
			EndIf         	 

			nNfsSel++

			For nX := 1 To Len(oCarga:aItens[nCount]:oNotaFi:aTitulos)

				aAdd(aArrFin,{ ;
				.F.,;//1
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cCodFil,;//2
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cTipo,;//3
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cPrefixo,;//4
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cNumero,;//5
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cParcela,;//6
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cClient,;//7
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cLoja,; //8
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:dEmissao,;//9								
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:dVencrea,;//10								
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:nValor,;//11							
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:nAcres,;//12								
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:nDesc,;//13
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:dBaixa,;//14
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:nSaldo,;//15
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cNumBco,;//16
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cPedido,;//17
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cBcoChq,;//18
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cAgeChq,;//19
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cCtaChq,;//20
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cNumLiq,;//21
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cCondic,;//22
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cCndDes,;//23
				IIf(oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cStatus ='A','Aberto','Baixado');//24
				})
				If oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cStatus ='B'
					nTitBxs++
				EndIf

			Next nX
		EndIf          
	Next nCount                                                
		
	oSay20:SetText(Padr(AllTrim(Transform(nNfsSel,"@E 9999")),10))
	oSay22:SetText(Padr(AllTrim(Transform(nTitSel,"@E 9999")),10))
	oSay24:SetText(Padr(AllTrim(Transform(nValSel,"@E 999,999,999.99")),10))

	oBrwFis:Refresh()
	oBrwFin:setArray(aArrFin)
	oBrwFin:Refresh()
Return
// **************************** fSelectOne - Marca todos os registros do Browse Fiscal e popula o Browse Financeiro ***********************************//
Static Function fSelectOne(oCarga)
	Local nCount  := 0                                                               
	Local lZerArr := .F.
	aArrFin       := {} 	
	nNfsSel 	  := 0  	
	nTitSel 	  := 0      
	nValSel       := 0

	For nCount:=1 to Len(aArrFis)

		If aArrFis[nCount,1] 

			If !lZerArr
				lZerArr := .T. 
				aArrFin := {}
				nNfsSel := 0
				nTitBxs := 0
				nValSel := 0   	    			
			EndIf    

			nNfsSel++		

			For nX := 1 To Len(oCarga:aItens[nCount]:oNotaFi:aTitulos)

				aAdd(aArrFin,{ ;
				.F.,;//1
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cCodFil,;//2
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cTipo,;//3
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cPrefixo,;//4
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cNumero,;//5
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cParcela,;//6
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cClient,;//7
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cLoja,; //8
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:dEmissao,;//9								
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:dVencrea,;//10								
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:nValor,;//11							
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:nAcres,;//12								
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:nDesc,;//13
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:dBaixa,;//14
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:nSaldo,;//15
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cIdentee,;//16
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cPedido,;//17
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cNumBco,;//18
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cAgeChq,;//19
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cCtaChq,;//20
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cNumLiq,;//21
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cCondic,;//22
				oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cCndDes,;//23
				IIf(oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cStatus ='A','Aberto','Baixado');//24
				})				              
				If oCarga:aItens[nCount]:oNotaFi:aTitulos[nX]:cStatus ='A'
					nTitBxs++
				EndIf
			Next nX
		EndIf          
	Next nCount                                                   
	
	oSay20:SetText(Padr(AllTrim(Transform(nNfsSel,"@E 9999")),10))
	oSay22:SetText(Padr(AllTrim(Transform(nTitSel,"@E 9999")),10))
	oSay24:SetText(Padr(AllTrim(Transform(nValSel,"@E 999,999,999.99")),10))
	oBrwFis:Refresh()
	oBrwFin:setArray(aArrFin)
	oBrwFin:Refresh()
Return                                                                        
// **************************** fAllTits - Marca todos os registros do Browse  Financeiro ************************************************//
Static Function fAllTits(oCarga)
	Local nCount  := 0                                                               
	nTitSel 	  := 0  	
	nValSel       := 0
	For nCount:=1 to Len(aArrFin)
		aArrFin[nCount,1] := !aArrFin[nCount,1]

		If aArrFin[nCount,1]
			nTitSel++ 
			nValSel += aArrFin[nCount,15]
		EndIf

	Next nCount

	oSay22:SetText(Padr(AllTrim(Transform(nTitSel,"@E 9999")),10))
	oSay24:SetText(Padr(AllTrim(Transform(nValSel,"@E 999,999,999.99")),10))
	oBrwFin:Refresh()
Return
// **************************** fOneTits - Marca todos os registros do Browse  Financeiro ************************************************//
Static Function fOneTit()
	Local nCount  := 0                                                               
	nTitSel 	  := 0  	
	nValSel       := 0

	For nCount:=1 to Len(aArrFin)

		If aArrFin[nCount,1]
			nTitSel++ 
			nValSel += aArrFin[nCount,15]
		EndIf

	Next nCount

	oSay22:SetText(Padr(AllTrim(Transform(nTitSel,"@E 9999")),10))          
	oSay24:SetText(Padr(AllTrim(Transform(nValSel,"@E 999,999,999.99")),10))	
	oBrwFin:Refresh()
Return

// **************************** ObtNums - Retorna todos os tipos de somatorio e numeros da carga para serem mostrados na tela ***************//
Static Function ObtNums(oCarga)
	Local   nRet  := 0
	Local   nI 	  := 0
	Local   nX 	  := 0	
	Default nTipo := 1

	nQtdNfs := Len(oCarga:aItens)
	nValNfs := 0
	nSldTit := 0
	nTitBxs := 0

	For nI := 1 To Len(oCarga:aItens)
		nValNfs += oCarga:aItens[nI]:oNotaFi:nValor            
		nQtdTit += Len(	oCarga:aItens[nI]:oNotaFi:aTitulos)
		For nX := 1 To Len(	oCarga:aItens[nI]:oNotaFi:aTitulos)
			nValTit += oCarga:aItens[nI]:oNotaFi:aTitulos[nX]:nValor
			nSldTit += oCarga:aItens[nI]:oNotaFi:aTitulos[nX]:nSaldo
			If  oCarga:aItens[nI]:oNotaFi:aTitulos[nX]:nValor > oCarga:aItens[nI]:oNotaFi:aTitulos[nX]:nSaldo 
				nTitBxs++			
			EndIf
		Next nX 
	Next nI
Return
// **************************** Confere - Monta a tela de Conferencia  ************************************************//     
Static function Confere(oCarga,nOpt)
	Local oBtnCnl
	Local oBtnOk
	Local oGetCrg
	Local cGetCrg := oCarga:cNumero
	Local oGroup1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oValConf
	Local nValConf := 0
	Local oValCrg
	Local nValCrg  := 0
	Local oValDev
	Local nValDev  := 0
	Local oValDif
	Local nValDif  := 0
	Local aAconfs  := oCarga:aConfer
	Local cColumn1
	Local oMSNewGe1 
	Static oDlgCnf

	For nI := 1 To Len(oCarga:aItens)
		For nX := 1 To Len(oCarga:aItens[nI]:oNotaFi:aTitulos)
			nValCrg +=oCarga:aItens[nI]:oNotaFi:aTitulos[nX]:nValor
		Next nX
	Next nI    

	DEFINE MSDIALOG oDlgCnf TITLE "Conferência" FROM 000, 000  TO 445, 750 COLORS 0, 16777215 PIXEL

	@ 011, 007 SAY oSay1 PROMPT "Carga:" SIZE 025, 007 OF oDlgCnf COLORS 0, 16777215 PIXEL
	@ 009, 026 MSGET oGetCrg VAR cGetCrg SIZE 025, 010 OF oDlgCnf COLORS 0, 16777215 readonly PIXEL
	fMSNewGe1(@oMSNewGe1,nOpt,oCarga)
	@ 144, 002 GROUP oGroup1 TO 196, 371 PROMPT "Totais:    " OF oDlgCnf COLOR 0, 16777215 PIXEL
	@ 153, 007 SAY oSay2 PROMPT "Valor Finan.: " SIZE 033, 007 OF oDlgCnf COLORS 0, 16777215 PIXEL
	@ 150, 047 MSGET oValCrg VAR nValCrg SIZE 060, 010 OF oDlgCnf COLORS 0, 16777215 PIXEL PICTURE "@E 999,999,999.99
	@ 153, 155 SAY oSay3 PROMPT "Valor Devolução:" SIZE 043, 007 OF oDlgCnf COLORS 0, 16777215 PIXEL
	@ 150, 202 MSGET oValDev VAR nValDev SIZE 060, 010 OF oDlgCnf COLORS 0, 16777215 PIXEL PICTURE "@E 999,999,999.99
	@ 172, 007 SAY oSay4 PROMPT "Valor Conferido:" SIZE 039, 007 OF oDlgCnf COLORS 0, 16777215 PIXEL
	@ 170, 047 MSGET oValConf VAR nValConf SIZE 060, 010 OF oDlgCnf COLORS 0, 16777215 PIXEL PICTURE "@E 999,999,999.99
	@ 172, 155 SAY oSay5 PROMPT "Diferença:" SIZE 025, 007 OF oDlgCnf COLORS 0, 16777215 PIXEL
	@ 170, 202 MSGET oValDif VAR nValDif SIZE 060, 010 OF oDlgCnf COLORS 0, 16777215 PIXEL PICTURE "@E 999,999,999.99	
		
	oGetCrg:lActive  := .F.    
	oValCrg:lnoButton := .T.
	oValCrg:lActive  := .F.    
	oValDev:lnoButton := .T.
	oValDev:lActive  := .F.
	oValConf:lnoButton := .T.
	oValConf:lActive := .F.
	oValDif:lnoButton := .T.
	oValDif:lActive  := .F.
	
	If nOpt = 1 .Or. nOpt = 2
		@ 204, 318 BUTTON oBtnOk  PROMPT "&Confirmar" SIZE 037, 012 OF oDlgCnf PIXEL
		@ 204, 245 BUTTON oBtnCnl PROMPT "&Fechar"    SIZE 037, 012 OF oDlgCnf PIXEL Action(oDlgCnf:End())
	ElseIf nOpt = 3
		@ 204, 245 BUTTON oBtnCnl PROMPT "&Fechar"    SIZE 037, 012 OF oDlgCnf PIXEL Action(oDlgCnf:End())
	Else
		@ 204, 318 BUTTON oBtnOk  PROMPT "E&xcluir" SIZE 037, 012 OF oDlgCnf PIXEL
		@ 204, 245 BUTTON oBtnCnl PROMPT "&Fechar"    SIZE 037, 012 OF oDlgCnf PIXEL Action(oDlgCnf:End())		
	EndIf	
	
	ACTIVATE MSDIALOG oDlgCnf CENTERED

Return
 // **************************** fMsNewGe1 - Monta o Grid para a tela de Conferencia  ************************************************//
Static Function fMsNewGe1(oMSNewGe1,nOpt,oCarga)
 
	Local nX
	Local aHeaderEx     := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {'DAP_CODGRU','DAP_GRUPO','DAP_PREVIS','DAP_REALIZ','DAP_DTACER','DAP_XLOGIN'}
	Local aAlterFields := {'DAP_CODGRU','DAP_GRUPO','DAP_PREVIS','DAP_REALIZ'}
	Local aConfs       := oCarga:aConfer	

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {;
			AllTrim(X3Titulo()),;
			SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO;
			})
		Endif
	Next nX

	// Define field values
	If nOpt = 1
		For nX := 1 to Len(aFields)
			If DbSeek(aFields[nX])
				If aFields[nX] == "DAP_DTACER"
					Aadd(aFieldFill, dDataBase)
				ElseIf aFields[nX] == "DAP_XLOGIN"
					Aadd(aFieldFill, cUserName)
				Else
					Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO,.T.))
				EndIf
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	Else
		aCols:={} 
		
		For nI := 1 To Len(aConfs)	
			aFieldFill := {}				 			
			Aadd(aFieldFill,aConfs[nI][3])			 
			Aadd(aFieldFill,aConfs[nI][4])
			Aadd(aFieldFill,aConfs[nI][5])
			Aadd(aFieldFill,aConfs[nI][6])
			Aadd(aFieldFill,Dtoc(Stod(aConfs[nI][7])))
			Aadd(aFieldFill,aConfs[nI][22])
			Aadd(aFieldFill,.F.)
			Aadd(aColsEx, aFieldFill)			                									
		Next nI				
	EndIf

	oMSNewGe1 := MsNewGetDados():New( 022, 002, 142, 371, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgCnf, aHeaderEx, aColsEx)
	oMSNewGe1:refresh()
Return