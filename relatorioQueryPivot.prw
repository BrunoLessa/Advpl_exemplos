#Include "Protheus.ch"
#Include "TopConn.ch"
//***************************************************************************************************************************************************
/*	Data: 08/08/2018
	Programador: Bruno Lessa	
	Motivo: Melhorias	
*/
User Function  REFR020
	Local oGroup1
	Local oSay1
	Local oSay2
	Local oSay3     
	Local oPerIni
	Local oPerFin	
	Local oSButton1
	Local oSButton2
	Local oChkBx1
	Local oChkBx2
	Local oCmbTpPr
	Private cCmbTpPr 	:= '01'
	Private dPerIni 	:= Date()
	Private dPerFin 	:= Date()	
	Private cPath 		:= "c:\TEMP_MSIGA\" 
	Private cNomArq 	:= "REFR020"
	Private cDtEmiss  	:= "Data: "  + dToc(dDatabase)
	Private cHrEmiss	:= "Hora: " + Time()
	Private oRelat		                    
    Private oFWMsExcel
    Private oExcel	
	Private lCorLin		// variavel que indica se a linha sera colorida ou nao
	Private lFirstPage	:= .T.	// indicador se é a primeira pagina do relatorio
	Private nPag		:= 1	// numero de paginas do relatorio
	Private nLin		:= 420	// quantidade de linhas do relatorio
	Private aCabeca	    := {}	
	Private lChkExc := .F.
	Private lChkRel := .F.	
	Static oDlg

  DEFINE MSDIALOG oDlg TITLE "ANALISE GERENCIAL ANO X ANO" FROM 000, 000  TO 260, 290 COLORS 0, 16777215 PIXEL

    @ 000, 002 GROUP oGroup1 TO 095, 142 PROMPT "Parâmetros: " OF oDlg COLOR 0, 16777215 PIXEL
    @ 010, 007 SAY oSay1 PROMPT "Marca de Prod.:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 008, 052 MSCOMBOBOX oCmbTpPr VAR cCmbTpPr ITEMS {"01=Todos","02=Mineirinho","03=Flexa"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL  
    @ 036, 007 SAY oSay2 PROMPT "Periodo Ini:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 052 MSGET oPerIni VAR dPerIni SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 051, 007 SAY oSay3 PROMPT "Periodo Fin:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 049, 052 MSGET oPerFin VAR dPerFin SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
   	@ 081, 020 CHECKBOX oChkBx1 VAR lChkRel PROMPT "&Relatório" SIZE 048, 007 OF oDlg COLORS 0, 16777215 PIXEL
   	@ 081, 090 CHECKBOX oChkBx2 VAR lChkExc PROMPT "&Excel" SIZE 048, 008 OF oDlg COLORS 0, 16777215 PIXEL
	lChkRel := .T.
	oChkBx2:lReadOnly := .T. 
	oChkBx2:lVisibleControl := .F. 	
    DEFINE SBUTTON oSButton1 FROM 110, 011 TYPE 02 OF oDlg Action(oDlg:End())  ENABLE
    DEFINE SBUTTON oSButton2 FROM 110, 105 TYPE 01 OF oDlg  Action(ValidPar())  ENABLE

  ACTIVATE MSDIALOG oDlg CENTERED

Return   
//*****************************************************************************************************************************************************
Static Function ValidPar()	
    If !lChkRel .And. !lChkExc
    	MsgAlert('Favor selecionar a marcar a opção desejada [ relatório, Excel ou ambos ]','Atenção!')
    	Return
    EndIf 
	CriaDir()        
   	MsAguarde( {|| ProcArq( MntQry())}, "Aguarde...","Obtendo registros.", .T. )
	oDlg:End()  

return
//*********************************************************************************************************************************                   
Static Function MntQry()
	Local cQRY := ''
	cQry += "SELECT   " + CRLF
	cQry += "	ANO,  " + CRLF
	cQry += "    [1] AS JANEIRO,  " + CRLF
	cQry += "    [2] AS FEVEREIRO,  " + CRLF
	cQry += "    [3] AS MARCO,  " + CRLF
	cQry += "	 [4] AS ABRIL,  " + CRLF
	cQry += "    [5] AS MAIO,  " + CRLF
	cQry += "    [6] AS JUNHO,  " + CRLF
	cQry += "    [7] AS JULHO,  " + CRLF
	cQry += "    [8] AS AGOSTO,  " + CRLF
	cQry += "    [9] AS SETEMBRO,  " + CRLF
	cQry += "    [10] AS OUTUBRO,  " + CRLF
	cQry += "	 [11] AS NOVEMBRO,  " + CRLF
	cQry += "    [12] AS DEZEMBRO  " + CRLF
	cQry += "FROM(  " + CRLF
	cQry += "SELECT   " + CRLF
	cQry += "	YEAR(CAST(D2_EMISSAO AS DATETIME)) ANO,  " + CRLF
	cQry += "	MONTH(CAST(D2_EMISSAO AS DATETIME)) MES,  " + CRLF
	cQry += "	SUM(CASE WHEN D2_TES IN('575','576','501','522') THEN D2_QUANT - D2_QTDEDEV ELSE 0 END ) QUANT  " + CRLF
	cQry += "FROM   " + CRLF
	cQry += "	" + retSqlName("SD2") + " SD2  " + CRLF
	cQry += "JOIN	  " + CRLF
	cQry += "	" + retSqlName("SB1") + " SB1  " + CRLF
	cQry += "ON   " + CRLF
	cQry += "	D2_FILIAL = B1_FILIAL AND  " + CRLF
	cQry += "	D2_COD = B1_COD AND  " + CRLF
	cQry += "	SB1.D_E_L_E_T_ =' '  " + CRLF
	cQry += "JOIN     " + CRLF
	cQry += "	" + retSqlName("SA1") + " SA1    " + CRLF
	cQry += "ON    " + CRLF
	cQry += "	D2_FILIAL  = A1_FILIAL AND     " + CRLF
	cQry += "	D2_CLIENTE = A1_COD AND     " + CRLF
	cQry += "	D2_LOJA    = A1_LOJA AND     " + CRLF
	cQry += "	SA1.D_E_L_E_T_ =' '    " + CRLF
	cQry += "WHERE   " + CRLF
	cQry += "	D2_FILIAL ='" + xFilial("SD2") + "' AND  " + CRLF
	cQry += "	SUBSTRING(D2_EMISSAO,1,4) BETWEEN '" + Trim(cValtochar(Year(dPerIni))) + "' AND '" + Trim(cValtochar(Year(dPerFin))) + "' AND   " + CRLF
    
	If cCmbTpPr ='01'
		cQry += "		B1_XFAMILI IN('01','02') AND " + CRLF
	ElseIf cCmbTpPr ='02'
		cQry += "		B1_XFAMILI = '01' AND " + CRLF			
	ElseIf cCmbTpPr ='03'
		cQry += "		B1_XFAMILI = '02' AND " + CRLF
	EndIf
		
	cQry += "	B1_TIPO ='PA' AND   " + CRLF	
	cQry += "	SD2.D_E_L_E_T_ =' '  " + CRLF
	cQry += "GROUP BY   " + CRLF
	cQry += "	YEAR(CAST(D2_EMISSAO AS DATETIME)),  " + CRLF
	cQry += "	MONTH(CAST(D2_EMISSAO AS DATETIME))  " + CRLF
	cQry += ")DADOS PIVOT (SUM(QUANT) FOR MES IN([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) MES  " + CRLF
	cQry += "ORDER BY   " + CRLF
	cQry += "	ANO  " + CRLF
	
	MemoWrite( cPath + "\" + cNomArq+ ".txt",cQry)		
Return( cQry )

//*****************************************************************************************************************************************************
Static Function ProcArq(cQuery)                     
	Local cTMP   	:= GetNextAlias()
	Local aDados 	:= {}
	Local aTotal 	:= {0,0,0,0,0,0,0,0,0,0,0,0,0}
	Local nIndex 	:= 0
	Local lCab   	:= .F.
	Local lChange	:= .F.
	Local nRegs  	:= 0
	Local nTotQtd   := 0
	Local nTotVal   := 0 
	Local nQtdGer   := 0
	Local nVlrGer   := 0	
	Local nI        := 0 
	Local cForn     := ''
	
	If Select( cTMP ) <> 0
		dbSelectArea( cTMP )
		dbCloseArea()
	EndIf
	
	TcQuery cQuery Alias cTMP New
	//acertar para continuar o relatorio	
	Count To nTotReg                                
	cTMP->(dbGoTop())
	
	If nTotReg <= 0
		Alert("Nenhuma informação para exibir, favor verifique os parametros")
		cTMP->(dbCloseArea())
		return
	EndIf 	
   		    
	While cTMP->(!Eof())				

		MsProcTxt("Coletando dados do Ano:" + 	Trim(cValtochar(cTMP->ANO)))	  
		
		nTotAno :=	cTMP->JANEIRO  + cTMP->FEVEREIRO + cTMP->MARCO + cTMP->ABRIL 
		nTotAno +=  cTMP->MAIO     + cTMP->JUNHO     + cTMP->JULHO + cTMP->AGOSTO 
		nTotAno +=  cTMP->SETEMBRO + cTMP->OUTUBRO   + cTMP->NOVEMBRO + cTMP->DEZEMBRO
		aAdd(aDados,{ ;
						Trim(cValtochar(cTMP->ANO))		,;
						cTMP->JANEIRO   	,;
						cTMP->FEVEREIRO 	,;							
						cTMP->MARCO  		,;
						cTMP->ABRIL    	    ,;
						cTMP->MAIO   		,;
						cTMP->JUNHO		    ,;
						cTMP->JULHO		    ,;
						cTMP->AGOSTO		,;							
						cTMP->SETEMBRO	    ,;							
						cTMP->OUTUBRO		,;
						cTMP->NOVEMBRO	    ,;
						cTMP->DEZEMBRO	    ,;
						nTotAno             ;														
					})	
			
			aTotal[1]+= cTMP->JANEIRO 
			aTotal[2]+= cTMP->FEVEREIRO
			aTotal[3]+= cTMP->MARCO 			 			
			aTotal[4]+= cTMP->ABRIL
			aTotal[5]+= cTMP->MAIO
			aTotal[6]+= cTMP->JUNHO
			aTotal[7]+= cTMP->JULHO
			aTotal[8]+= cTMP->AGOSTO
			aTotal[9]+= cTMP->SETEMBRO
			aTotal[10]+= cTMP->OUTUBRO
			aTotal[11]+= cTMP->NOVEMBRO
			aTotal[12]+= cTMP->DEZEMBRO
			aTotal[13]+= nTotAno 			 			 			 			   			 			 			 
						
		cTMP->(dbSkip())
	EndDo   
	
	cTMP->(dbCloseArea())         
	If lChkRel
		oRelat	:= DefRel()	                 
		nMaxLin := oRelat:nVertRes() -50
    	aCabeca := {}
		aAdd( aCabeca,{ Nil  	,"Ano-Base" 		 			   					} )
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 010)/100)	,"Janeiro"	 				} )
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 016)/100)	,"Fevereiro"				} )		
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 023)/100)	,"Marco"					} )	
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 030)/100)	,"Abril"					} )		
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 037)/100)	,"Maio"						} )			
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 044)/100)	,"Junho"					} )						
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 051)/100)	,"Julho"					} )						
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 058)/100)	,"Agosto"					} )									
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 065)/100)	,"Setembro"					} )
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 072)/100)	,"Outubro"					} )
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 079)/100)	,"Novembro"					} )						
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 086)/100)	,"Dezembro"					} )										
		aAdd( aCabeca,{ ((oRelat:nHorzRes() * 093)/100)	,"Total Ano"				} )												
	
		For nI := 1 To Len(aDados)
			MsProcTxt("Montando relatório do Ano:" + Trim(aDados[nI][1]))	  
			If Mod(nI,2) = 0
				EscRel(Trim(cValtochar(aDados[nI][1])) , , , , , , .T.) 
			Else
				EscRel(Trim(cValtochar(aDados[nI][1]))) 
			EndIf
			EscRel(Transform(aDados[nI][2] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 013.5) /100),Nil, Nil, Nil, 1)
			EscRel(Transform(aDados[nI][3] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 020) /100),Nil, Nil, Nil, 1)
			EscRel(Transform(aDados[nI][4] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 026) /100),Nil, Nil, Nil, 1)
			EscRel(Transform(aDados[nI][5] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 032.5) /100),Nil, Nil, Nil, 1)
			EscRel(Transform(aDados[nI][6] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 039.5) /100),Nil, Nil, Nil, 1)						
			EscRel(Transform(aDados[nI][7] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 046.8) /100),Nil, Nil, Nil, 1)
			EscRel(Transform(aDados[nI][8] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 053.5) /100),Nil, Nil, Nil, 1)
			EscRel(Transform(aDados[nI][9] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 062) /100),Nil, Nil, Nil, 1)									
			EscRel(Transform(aDados[nI][10] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 069) /100),Nil, Nil, Nil, 1)			
			EscRel(Transform(aDados[nI][11] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 076) /100),Nil, Nil, Nil, 1)			
			EscRel(Transform(aDados[nI][12] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 083) /100),Nil, Nil, Nil, 1)			
			EscRel(Transform(aDados[nI][13] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 091) /100),Nil, Nil, Nil, 1)			
			EscRel(Transform(aDados[nI][14] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 098) /100),Nil, Nil, Nil, 1)						
			EscRel( , ,.T.) 

	    Next nI 
		EscRel( , , , , , , ,.T.)
		MsProcTxt("Montando Totais")	  
		EscRel("Total:" , , , ,.T. , ,)
		EscRel(Transform(aTotal[1] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 013.5) /100),Nil, Nil,.T.,1)
		EscRel(Transform(aTotal[2] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 020) /100),Nil, Nil, .T., 1)
		EscRel(Transform(aTotal[3] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 026) /100),Nil, Nil, .T., 1)
		EscRel(Transform(aTotal[4] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 032.5) /100),Nil, Nil, .T., 1)
		EscRel(Transform(aTotal[5] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 039.5) /100),Nil, Nil, .T., 1)						
		EscRel(Transform(aTotal[6] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 046.8) /100),Nil, Nil, .T., 1)
		EscRel(Transform(aTotal[7] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 053.5) /100),Nil, Nil, .T., 1)
		EscRel(Transform(aTotal[8] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 062) /100),Nil, Nil, .T., 1)									
		EscRel(Transform(aTotal[9] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 069) /100),Nil, Nil, .T., 1)			
		EscRel(Transform(aTotal[10] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 076) /100),Nil, Nil, .T., 1)			
		EscRel(Transform(aTotal[11] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 083) /100),Nil, Nil, .T., 1)			
		EscRel(Transform(aTotal[12] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 091) /100),Nil, Nil, .T., 1)			            
		EscRel(Transform(aTotal[13] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 098) /100),Nil, Nil, .T., 1)									
		EscRel( , ,.T.) 
		EscRel( , , , , , , ,.T.)			
		EndRel()	    
	EndIf
	
	If lChkExc // Não utilizo no momento
	EndIf
return
//*****************************************************************************************************************************************************
Static Function CriaDir()           	

	If !ExistDir( cPath )
		If MakeDir( cPath )  != 0
			Alert( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
		EndIf
	EndIf
   
Return
//*****************************************************************************************************************************************************
//Funcao que Cria  o relatorio a ser impresso
Static Function DefRel()
	Local cTitulo 	:= cNomArq
	Local oFont08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
	__RelDir := WSPLRelDir()
	oRelat 	 := TMSPrinter():New( cTitulo )
	oRelat:SetFile(__RELDIR + cTitulo +'.prt',.F.)
	oRelat:SetPaperSize(9) // A4
	oRelat:SetLandScape()
	oRelat:Setup()
Return( oRelat )  

//*********************************************************************************************************************************
Static Function MntCab()
	Local nMaxLin 	:= oRelat:nVertRes() -50
	Local nMaxCol 	:= oRelat:nHorzRes() -50
	Local nIniCol 	:= 0030
	Local nIniLin	:= 0050
	local oFont1 	:= TFont():New("Arial"      ,07,07,,.T.,,,,.F.,.F.) // NOME EMPRESA
	local oFont2 	:= TFont():New("Arial"      ,07,07,,.F.,,,,.F.,.F.) // CORPO DO TEXTO
	local oFont3 	:= TFont():New("Arial"      ,12,12,,.T.,,,,.F.,.T.) // TITULO DO RELATORIO
	local oFont4 	:= TFont():New("Arial"      ,09,09,,.T.,,,,,.F.,.F.) // CABECALHO
	Local cNomEmp 	:= "Industria Teste."
	Local cEndEmp 	:= "Endereco teste, cidade teste, Estado Teste "
	Local cTelEmp 	:= "Tels:(xx) 9999-9999 "
	Local cFaxEmp 	:= "Fax: (xx) 9999-9999 "
	Local cEmitido  := "Emitido por: " + cUserName
	Local cPagina   := "Página: " + strzero( nPag,3)
	Local cTitRel   := "Analise Gerencial Ano x Ano"
	Local cArqBmp   :=  GetSrvProfString("StartPath", "\system_INDUSTRIA") + "\lgrl05.bmp"
	Local nTam      := 0 
	Local nI        := 0

	oRelat:Line( nIniLin,nIniCol,nIniLin,nMaxCol )
	oRelat:SayBitmap(080,nIniCol,cArqBmp,200,200 )
	oRelat:Say(00100, 0230, cNomEmp, oFont1, 100)
	oRelat:Say(00150, 0230, cEndEmp, oFont2, 100)
	oRelat:Say(00200, 0230, cTelEmp, oFont2, 100)
	oRelat:Say(00250, 0230, cFaxEmp, oFont2, 100)
	oRelat:Say(00180, ((oRelat:nHorzRes() * 040) /100), cTitRel, oFont3, 100)
	oRelat:Say(00100, nMaxCol- 380, cEmitido, oFont2, 100)
	oRelat:Say(00150, nMaxCol- 380, cDtEmiss, oFont2, 100)
	oRelat:Say(00200, nMaxCol- 380, cHrEmiss, oFont2, 100)
	oRelat:Say(00250, nMaxCol- 380, cPagina,  oFont2, 100)
	oRelat:Line( 00300,nIniCol,00300,nMaxCol )
	For nI := 1 To Len( aCabeca )
		If aCabeca[nI][1] = Nil
			oRelat:Say( 00310, nIniCol, OemToAnsi(Trim( aCabeca[nI][2] )),oFont4)
		Else
			oRelat:Say( 00310, aCabeca[nI][1] , OemToAnsi( Trim( aCabeca[nI][2] ) ),oFont4 )
		EndIf
	Next nI
	oRelat:Line( 00360,nIniCol,00360,nMaxCol )
	nLin := 390
	lFirstPage := .F.
Return
//*********************************************************************************************************************************
Static Function MntRod()
	Local nMaxLin 	:= oRelat:nVertRes() -90
	Local nMaxCol 	:= oRelat:nHorzRes() -50
	Local nIniCol 	:= 0030
	Local nIniLin	:= 0050
	local oFont1 	:= TFont():New("Arial"      ,07,07,,.T.,,,,.F.,.F.) // NOME EMPRESA
	local oFont2 	:= TFont():New("Arial"      ,07,07,,.F.,,,,.F.,.F.) // CORPO DO TEXTO
	local oFont3 	:= TFont():New("Arial"      ,12,12,,.T.,,,,.F.,.T.) // TITULO DO RELATORIO
	local oFont4 	:= TFont():New("Arial"      ,09,09,,.T.,,,,,.F.,.F.) // CABECALHO
	Local cTxtRod 	:= " "
	oRelat:Line( nMaxLin,nIniCol,nMaxLin,nMaxCol )


Return

//*********************************************************************************************************************************
Static Function EscRel( cConteudo , nIniCol, lPulLin, lCab , lNegrito , nAlign, lCorlin,lLinha )

	Local 	nLinc   	:= 50 // espaçamento entre as linhas
	Local	nMaxLin 	:= oRelat:nVertRes() -100 // Maximo de linhas
	Local 	nMaxCol 	:= oRelat:nHorzRes() -50
	Local 	oBrush1 	:= TBrush():New( , RGB(230, 230, 250) )
	Local 	oFont1 		:= TFont():New("Arial"      ,08,08,,.F.,,,,.F.,.F.) // CORPO DO TEXTO
	Local 	oFont2 		:= TFont():New("Arial"      ,08,08,,.T.,,,,.F.,.F.) // CORPO DO TEXTO
	Default nAlign    	:= 0 // 0- esquerda 1- direita  2 -centro
	Default cConteudo 	:= Nil
	Default lCab 		:= .F.
	Default lPulLin 	:= .F.
	Default	nIniCol		:= 0030
	Default lNegrito	:= .F.
    Default lCorlin		:= .F.
    Default lLinha		:= .F.
                                                                                  
	If nLin > nMaxLin  .Or. lFirstPage
		MntRod() 						// Funcao que monta o rodapé padrao
		If !lFirstPage
			nPag ++
			oRelat:EndPage()    // Finaliza a pagina
		EndIf
		MntCab() 						// Funcao que monta o cabecalho padrao
	Endif             
	
	If lPulLin
		nLin := nLin + nLInc
	EndIf

	If lCorLin
		oRelat:FillRect( {nLin + 40 ,0030,(nLin + 40)-52,nMaxCol }, oBrush1 )
	EndIf                                              
	
	If lLinha	
		oRelat:Line( nLin,nIniCol,nLin,nMaxCol )
	EndIf
	
	If cConteudo = Nil
		return
	EndIf
	
	If lNegrito
		oRelat:Say( nLin, nIniCol, cConteudo , oFont2, 100, Nil, Nil, nAlign )
	Else
		oRelat:Say( nLin, nIniCol, cConteudo , oFont1, 100, Nil, Nil, nAlign )
	EndIf
	
Return
//*********************************************************************************************************************************
Static Function EndRel()
	oRelat:EndPage()
	oRelat:IsPrinterActive()
	oRelat:preview() 
	freeObj( oRelat )
Return
