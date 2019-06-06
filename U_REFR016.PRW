#Include "Protheus.ch"
#Include "TopConn.ch"
//***************************************************************************************************************************************************
/*	Data: 08/08/2018
	Programador: Bruno Lessa	
	Motivo: Melhorias	
/*	Controle de Alterações **************************************************************************************************************************
	Versao:1.2 
	Data:27/12/18        
	Programador: Bruno Lessa
	Alteracao: 	
	Motivo: Importar para o Excel
*/
User Function  REFR016
	Local oCmbTipo
	Local oCmbTpCli
	Local oCmbTpPr
	Local oDperiodo
	Local oGroup1
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSButton1
	Local oSButton2
	Local oChkBx1
	Local oChkBx2
	Private cCmbTipo 	:= '01'
	Private cCmbTpCli 	:= '001' 
	Private nPerc       := 000.00	
	Private cCmbTpPr 	:= '01'
	Private dDperiodo 	:= Date()
	Private cPath 		:= "c:\TEMP_MSIGA\" 
	Private cNomArq 	:= "REFR016"
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

  DEFINE MSDIALOG oDlg TITLE "Apuração de Redes de Clientes" FROM 000, 000  TO 260, 290 COLORS 0, 16777215 PIXEL

    @ 000, 002 GROUP oGroup1 TO 095, 142 PROMPT "Parâmetros: " OF oDlg COLOR 0, 16777215 PIXEL
    @ 010, 007 SAY oSay1 PROMPT "Rede de Clientes: " SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 008, 052 MSCOMBOBOX oCmbTpCli VAR cCmbTpCli ITEMS {"001=Grand Marchê","002=Super Marketing"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL On Change( Iif( cCmbTpCli !='001',oPerc:lActive := .F., oPerc:lActive := .T.))
    @ 023, 007 SAY oSay2 PROMPT "Marca de Prod.:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 021, 052 MSCOMBOBOX oCmbTpPr VAR cCmbTpPr ITEMS {"01=Todos","02=Mineirinho","03=Flexa"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL  

    @ 036, 007 SAY oSay3 PROMPT "Perc. Contrat.:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 052 MsGet oPerc VAR nPerc  SIZE 072, 010 OF oDlg PICTURE "@E 999.99" COLORS 0, 16777215 PIXEL HASBUTTON

    @ 051, 007 SAY oSay4 PROMPT "Periodo:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 049, 052 MSGET oDperiodo VAR dDperiodo SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 064, 007 SAY oSay5 PROMPT "Tipo:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 065, 052 MSCOMBOBOX oCmbTipo VAR cCmbTipo ITEMS {"01=Analítico","02=Sintético"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
   	@ 081, 020 CHECKBOX oChkBx1 VAR lChkRel PROMPT "&Relatório" SIZE 048, 007 OF oDlg COLORS 0, 16777215 PIXEL
   	@ 081, 090 CHECKBOX oChkBx2 VAR lChkExc PROMPT "&Excel" SIZE 048, 008 OF oDlg COLORS 0, 16777215 PIXEL

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
	cQry += "		A1_COD,  " + CRLF
	cQry += "		A1_LOJA,  " + CRLF
	cQry += "		A1_NOME,  " + CRLF
	cQry += "		A1_XSETOR,  " + CRLF
	cQry += "		A1_XROTA,  " + CRLF      
	cQry += "		A1_XGRPCLI, " + CRLF	

	If cCmbTipo ='01'
		cQry += "		D2_COD, " + CRLF
		cQry += "		B1_DESC, " + CRLF
		cQry += "		B1_XFAMILI,	 " + CRLF
	EndIf

	cQry += "		SUM(D2_QUANT - D2_QTDEDEV) QUANT, " + CRLF
	cQry += "		SUM(CASE WHEN D2_TES ='575' THEN D2_VALBRUT - D2_VALDEV ELSE 0 END ) VALOR " + CRLF
	cQry += "	FROM   " + CRLF
	cQry += "		" + retSqlName("SD2") + " SD2  " + CRLF
	cQry += "	JOIN   " + CRLF
	cQry += "		" + retSqlName("SA1") + " SA1  " + CRLF
	cQry += "	ON  " + CRLF
	cQry += "		D2_FILIAL  = A1_FILIAL AND   " + CRLF
	cQry += "		D2_CLIENTE = A1_COD AND   " + CRLF
	cQry += "		D2_LOJA    = A1_LOJA AND   " + CRLF
	cQry += "		SA1.D_E_L_E_T_ =' '  " + CRLF
	cQry += "	JOIN   " + CRLF
	cQry += "		" + retSqlName("SB1") + " SB1  " + CRLF
	cQry += "	ON	  " + CRLF
	cQry += "		D2_FILIAL = B1_FILIAL AND  " + CRLF
	cQry += "		D2_COD = B1_COD AND   " + CRLF
	cQry += "		SB1.D_E_L_E_T_ =' '  " + CRLF
	cQry += "	WHERE   " + CRLF
	cQry += "		D2_FILIAL  ='" + xFilial("SD2") + "' AND  " + CRLF
	cQry += "		D2_EMISSAO BETWEEN '" + AnoMes(dDperiodo) +"01' AND '" + AnoMes(dDperiodo) + "31' AND  " + CRLF

	If cCmbTpCli = '001'
		cQry += "		A1_XGRPCLI ='001' AND " + CRLF	
	ElseIf cCmbTpCli = '002'                        
		cQry += "		A1_XGRPCLI ='002' AND " + CRLF			
	EndIf

	If cCmbTpPr ='01'
		cQry += "		B1_XFAMILI IN('01','02') AND " + CRLF
	ElseIf cCmbTpPr ='02'
		cQry += "		B1_XFAMILI = '01' AND " + CRLF			
	ElseIf cCmbTpPr ='03'
		cQry += "		B1_XFAMILI = '02' AND " + CRLF
	EndIf
	
	cQry += "		SD2.D_E_L_E_T_ =' '   " + CRLF

	If cCmbTipo ='01' //Analitico
		cQry += "	GROUP BY	 " + CRLF
		cQry += "		A1_COD,  " + CRLF
		cQry += "		A1_LOJA,  " + CRLF
		cQry += "		A1_NOME ,  " + CRLF
		cQry += "		A1_XSETOR,  " + CRLF
		cQry += "		A1_XROTA,  " + CRLF 
		cQry += "		A1_XGRPCLI, " + CRLF  
		cQry += "		D2_COD, " + CRLF
		cQry += "		B1_DESC, " + CRLF
		cQry += "		B1_XFAMILI " + CRLF
		cQry += "	ORDER BY	 " + CRLF
		cQry += "		A1_COD,  " + CRLF
		cQry += "		A1_LOJA, " + CRLF		
		cQry += "		D2_COD   " + CRLF		
	ElseIf cCmbTipo ='02' //Sintetico
		cQry += "	GROUP BY	 " + CRLF
		cQry += "		A1_COD,  " + CRLF
		cQry += "		A1_LOJA,  " + CRLF
		cQry += "		A1_NOME ,  " + CRLF
		cQry += "		A1_XSETOR,  " + CRLF
		cQry += "		A1_XROTA,  " + CRLF 
		cQry += "		A1_XGRPCLI " + CRLF 	
		cQry += "	ORDER BY	 " + CRLF
		cQry += "		A1_COD,  " + CRLF
		cQry += "		A1_LOJA  " + CRLF		
	EndIf
	MemoWrite( cPath + "\" + cNomArq+ ".txt",cQry)		
Return( cQry )

//*****************************************************************************************************************************************************
Static Function ProcArq(cQuery)                     
	Local cTMP   	:= GetNextAlias()
	Local aDados 	:= {}
	Local aTotal 	:= {}
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

		MsProcTxt("Coletando dados do cliente:" + Trim(cTMP->A1_COD + '-' + cTMP->A1_LOJA ))	  
		
		If cCmbTipo = '01' //Analitico
            
			aAdd(aDados,{ ;
							Trim(cTMP->A1_COD + '-' + cTMP->A1_LOJA) ,;
							Trim(cTMP->A1_NOME)   ,;
							Trim(cTMP->A1_XSETOR) ,;							
							Trim(cTMP->A1_XROTA)  ,;
							Trim(cTMP->D2_COD)    ,;
							Trim(cTMP->B1_DESC)   ,;
							Trim(cTMP->B1_XFAMILI),;
							Trim(cTMP->A1_XGRPCLI),;
							cTMP->QUANT           ,;
							cTMP->VALOR           ;
						})
		ElseIf cCmbTipo = '02' //Sintetico
            
			aAdd(aDados,{ ;
							Trim(cTMP->A1_COD + '-' + cTMP->A1_LOJA) ,;
							Trim(cTMP->A1_NOME)   ,;
							Trim(cTMP->A1_XSETOR) ,;							
							Trim(cTMP->A1_XROTA)  ,;
							Trim(cTMP->A1_XGRPCLI),;
							cTMP->QUANT           ,;
							cTMP->VALOR           ;
						})                        
		EndIf

		cTMP->(dbSkip())
	EndDo   
	
	cTMP->(dbCloseArea())         
	If lChkRel
		oRelat	:= DefRel()	                 
		nMaxLin := oRelat:nVertRes() -50
    
		If cCmbTipo = '01' // analitico
			aCabeca := {}
			aAdd( aCabeca,{ Nil  	,"Código"		 			   						} )
			aAdd( aCabeca,{ ((oRelat:nHorzRes() * 010)/100)	,"Cliente" 					} )
			aAdd( aCabeca,{ ((oRelat:nHorzRes() * 030)/100)	,"Setor" 					} )
			aAdd( aCabeca,{ ((oRelat:nHorzRes() * 035)/100)	,"Cod. Prod."				} )		
			aAdd( aCabeca,{ ((oRelat:nHorzRes() * 045)/100)	,"Desc. Prod."				} )	
			aAdd( aCabeca,{ ((oRelat:nHorzRes() * 070)/100)	,"Volume"					} )		
			aAdd( aCabeca,{ ((oRelat:nHorzRes() * 085)/100)	,"Faturamento"				} )			
	
   		ElseIf cCmbTipo = '02' // sintetico

			aCabeca := {}
			aAdd( aCabeca,{ Nil  	,"Código"		 			   						} )
			aAdd( aCabeca,{ ((oRelat:nHorzRes() * 010)/100)	,"Cliente" 					} )
			aAdd( aCabeca,{ ((oRelat:nHorzRes() * 040)/100)	,"Setor" 					} )
			aAdd( aCabeca,{ ((oRelat:nHorzRes() * 060)/100)	,"Volume"					} )		
			aAdd( aCabeca,{ ((oRelat:nHorzRes() * 080)/100)	,"Faturamento"				} )		

	   	EndIf
	
		For nI := 1 To Len(aDados)
			MsProcTxt("Montando relatório do cliente:" + Trim(aDados[nI][1]))	  

			If cCmbTipo = '01' //Analitico
				If nI = 1 
					cFor   := aDados[nI][1] 
					EscRel(Trim(aDados[nI][1]) , , , , , , .T.)
					EscRel(Trim(OemToAnsi(aDados[nI][2])),((oRelat:nHorzRes() * 010)/100), , , )		
					EscRel(Trim(OemToAnsi(aDados[nI][3])),((oRelat:nHorzRes() * 030)/100), , , )			
					EscRel( , ,.T.) 
				EndIf
	
				If aDados[nI][1] != cFor 
					EscRel("Total: "  , , , , .T. )			
					EscRel(Transform(nTotQtd  ,"@E 9999" ) ,((oRelat:nHorzRes() * 073.8) /100),Nil, Nil, .T., 1)	
					EscRel(Transform(nTotVal  ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 092) /100),Nil, Nil, .T., 1)
					EscRel( , ,.T.) 
					cFor := aDados[nI][1] 
					nTotVal := 0
					nTotQtd := 0
					If nI != Len(aDados) 
						EscRel(Trim(aDados[nI][1]) , , , , , , .T.)
						EscRel(Trim(OemToAnsi(aDados[nI][2])),((oRelat:nHorzRes() * 010)/100), , , )		
						EscRel(Trim(OemToAnsi(aDados[nI][3])),((oRelat:nHorzRes() * 030)/100), , , )			
						EscRel( , ,.T.) 
					EndIf
				EndIf		 				
				EscRel(Trim(OemToAnsi(aDados[nI][5])),((oRelat:nHorzRes() * 035)/100), , , )
				EscRel(Trim(OemToAnsi(aDados[nI][6])),((oRelat:nHorzRes() * 045)/100), , , )
				EscRel(Transform(aDados[nI][9]  ,"@E 9999" ) ,((oRelat:nHorzRes() * 073.8) /100),Nil, Nil, Nil, 1)	
				EscRel(Transform(aDados[nI][10] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 092) /100),Nil, Nil, Nil, 1)
				EscRel( , ,.T.)
				nTotQtd +=  aDados[nI][9] 
				nTotVal +=  aDados[nI][10]
				nQtdGer +=  aDados[nI][9] 
				nVlrGer +=  aDados[nI][10] 			
				If nI = Len(aDados)
					EscRel("Total: "  , , , , .T. )			
					EscRel(Transform(nTotQtd  ,"@E 9999" ) ,((oRelat:nHorzRes() * 073.8) /100),Nil, Nil, .T., 1)	
					EscRel(Transform(nTotVal  ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 092) /100),Nil, Nil, .T., 1)
					EscRel( , ,.T., , , , , .T.)  
					EscRel("Total Geral: "  , , , , .T. )			
					EscRel(Transform(nQtdGer  ,"@E 9999" ) ,((oRelat:nHorzRes() * 073.8) /100),Nil, Nil, .T., 1)	
					EscRel(Transform(nVlrGer  ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 092) /100),Nil, Nil, .T., 1)
					EscRel( , ,.T.) 				
				EndIf
						
			ElseIf cCmbTipo = '02' //Sintetico	
				nTotQtd   += aDados[nI][6]
				nTotVal   += aDados[nI][7]
				EscRel(Trim(aDados[nI][1]) , , , , )
				EscRel(Trim(OemToAnsi(aDados[nI][2])),((oRelat:nHorzRes() * 010)/100), , , )
				EscRel(Trim(OemToAnsi(aDados[nI][3])),((oRelat:nHorzRes() * 040)/100), , , )			
				EscRel(Transform(aDados[nI][6] ,"@E 9999" ) ,((oRelat:nHorzRes() * 063.8) /100),Nil, Nil, Nil, 1)	
				EscRel(Transform(aDados[nI][7] ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 086) /100),Nil, Nil, Nil, 1)					               			
				EscRel( , ,.T.) 
			EndIf		
		Next nI
		If cCmbTipo = '01' //Analitico
			If cCmbTpCli = '001' 
				EscRel("Valor a ser pago: "  , , , , .T. )						
				EscRel(Transform((nVlrGer * (nPerc/100))  ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 092) /100),Nil, Nil, .T., 1)
				EscRel( , ,.T.) 				
			EndIf	
		ElseIf cCmbTipo = '02' //Sintetico
			EscRel( , , , , , , , .T. )
			EscRel( OemToAnsi("Total:") , , , .T.,.T.)
			EscRel(Transform(nTotQtd ,"@E 9999999" ) ,((oRelat:nHorzRes() * 063.8) /100),Nil, Nil,.T., 1)	
			EscRel(Transform(nTotVal ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 086) /100),Nil, Nil,.T., 1)					               			
			EscRel( , , , , , , , .T. )		
			If cCmbTpCli = '001'  
				EscRel( , ,.T.) 				
	   			EscRel( OemToAnsi("Valor a Ser pago:") , , , .T.,.T.)
				EscRel(Transform((nTotVal * (nPerc/100)) ,"@E 999,999,999.99" ),((oRelat:nHorzRes() * 086) /100),Nil, Nil,.T., 1)					               			
			EndIf   
		EndIf
		EndRel()		
	EndIf
	
	If lChkExc
		oFWMsExcel := FWMSExcel():New()
		nTotQtd  := 0
		nTotVal  := 0
		nQtdGer  := 0
		nVlrGer  := 0                  
		
		If cCmbTipo = '01' // analitico
		
			If cCmbTpCli = '001'
				cTitRel := "Apuracao de Redes de Clientes Grand Marchê Analitico"
			ElseIf cCmbTpCli = '002'
				cTitRel := "Apuracao de Redes de Clientes Super Marketing Analitico"
			EndIf
			
			oFWMsExcel:AddworkSheet("Dados") 
			oFWMsExcel:AddTable("Dados",cTitRel)
			oFWMsExcel:AddColumn("Dados",cTitRel,"Código",1,1)
			oFWMsExcel:AddColumn("Dados",cTitRel,"Cliente",1,1)
			oFWMsExcel:AddColumn("Dados",cTitRel,"Setor",1,1)
			oFWMsExcel:AddColumn("Dados",cTitRel,"Cod. Prod.",1,1)						
			oFWMsExcel:AddColumn("Dados",cTitRel,"Desc. Prod.",1,1)
			oFWMsExcel:AddColumn("Dados",cTitRel,"Volume",2,2)
			oFWMsExcel:AddColumn("Dados",cTitRel,"Faturamento",3,3)			
			
			For nI := 1 To Len(aDados)
				MsProcTxt("Montando relatório do cliente:" + Trim(aDados[nI][1]))	  
	    		lCab 	:= .F.
	    		cForn   := aDados[nI][1]
				nTotQtd := 0
				nTotVal := 0
                While aDados[nI][1] = cForn
                	If !lCab
                		lCab := .T.
						oFWMsExcel:AddRow("Dados",cTitRel, {;
									  Trim(aDados[nI][1]),;
									  Trim(OemToAnsi(aDados[nI][2])),;
									  Trim(OemToAnsi(aDados[nI][3])),;
									  ' ',;
									  ' ',;
									  ' ',;
									  ' ';
									  })  									  						
						oFWMsExcel:AddRow("Dados",cTitRel, {;
									  ' ',;
									  ' ',;
									  ' ',;
						              Trim(OemToAnsi(aDados[nI][5])),;
						              Trim(OemToAnsi(aDados[nI][6])),;
						              aDados[nI][9],;
						              aDados[nI][10];
									  })  									  
						nTotQtd  += aDados[nI][9] 
						nTotVal  += aDados[nI][10] 
						nQtdGer  += aDados[nI][9] 
						nVlrGer  += aDados[nI][10] 
                	Else
						oFWMsExcel:AddRow("Dados",cTitRel, {;
									  ' ',;
									  ' ',;
									  ' ',;
						              Trim(OemToAnsi(aDados[nI][5])),;
						              Trim(OemToAnsi(aDados[nI][6])),;
						              aDados[nI][9],;
						              aDados[nI][10];
									  })                	
						nTotQtd  += aDados[nI][9] 
						nTotVal  += aDados[nI][10] 
						nQtdGer  += aDados[nI][9] 
						nVlrGer  += aDados[nI][10] 
                	EndIf
                	nI++
                	Loop
                EndDo    
				oFWMsExcel:AddRow("Dados",cTitRel, {;
								  'Total: ',;
								  ' ',;
								  ' ',;
					              ' ',;
					              ' ',;
					              nTotQtd,;
					              nTotVal;
								  })                	            
                nI--       
                lCab 	:= .F.
				cForn   := aDados[nI][1]                
                Loop
			Next nI
			oFWMsExcel:AddRow("Dados",cTitRel, {;
							  'Total Geral: ',;
							  ' ',;
							  ' ',;
				              ' ',;
				              ' ',;
				              nQtdGer,;
				              nVlrGer;
							  })                	            
			oFWMsExcel:AddRow("Dados",cTitRel, {;
							  'Valor a ser pago: ',;
							  ' ',;
							  ' ',;
				              ' ',;
				              ' ',;
				              nPerc,;
				              nVlrGer * (nPerc/100);
							  })                	            
   		ElseIf cCmbTipo = '02' // sintetico
			
			If cCmbTpCli = '001'
				cTitRel := "Apuracao de Redes de Clientes Grand Marchê Sintetico"
			ElseIf cCmbTpCli = '002'
				cTitRel := "Apuracao de Redes de Clientes Super Marketing Sintetico"
			EndIf
			
			oFWMsExcel:AddworkSheet("Dados") 
			oFWMsExcel:AddTable("Dados",cTitRel)
			oFWMsExcel:AddColumn("Dados",cTitRel,"Código",1,1)
			oFWMsExcel:AddColumn("Dados",cTitRel,"Cliente",1,1)
			oFWMsExcel:AddColumn("Dados",cTitRel,"Setor",1,1)
			oFWMsExcel:AddColumn("Dados",cTitRel,"Volume",2,2)
			oFWMsExcel:AddColumn("Dados",cTitRel,"Faturamento",3,3)			
			For nI := 1 To Len(aDados)
				MsProcTxt("Montando relatório do cliente:" + Trim(aDados[nI][1]))	  
				oFWMsExcel:AddRow("Dados",cTitRel, {;
								   Trim(OemToAnsi(aDados[nI][1])),;
								   Trim(OemToAnsi(aDados[nI][2])),;
								   Trim(OemToAnsi(aDados[nI][3])),;
                                   aDados[nI][6],;
                                   aDados[nI][7];
							  	})                	            
				nQtdGer  += aDados[nI][6] 
				nVlrGer  += aDados[nI][7] 
			Next nI                       
			oFWMsExcel:AddRow("Dados",cTitRel, {;
							  'Total Geral: ',;
							  ' ',;
							  ' ',;
				              nQtdGer,;
				              nVlrGer;
							  })                	            
			oFWMsExcel:AddRow("Dados",cTitRel, {;
							  'Valor a ser pago: ',;
							  ' ',;
							  ' ',;
				              nPerc,;
				              nVlrGer * (nPerc/100);
							  })                	            			
   		EndIf
	    oFWMsExcel:Activate()
    	oFWMsExcel:GetXMLFile(cPath + '\' + cNomArq + '.xml')
	    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    	oExcel:WorkBooks:Open(cPath + '\' + cNomArq + '.xml')     //Abre uma planilha
	    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    	oExcel:Destroy()      	   					
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
	Local cNomEmp 	:= "REFLEXA - INDUSTRIA DE BEBIDAS REFLEXA LTDA."
	Local cEndEmp 	:= "Rua Clóvis Bevilaqua, 285 - São Gonçalo, Rio de Janeiro "
	Local cTelEmp 	:= "Tels:(21) 3715-8686 "
	Local cFaxEmp 	:= "Fax: (21) 3715-8686 "
	Local cEmitido  := "Emitido por: " + cUserName
	Local cPagina   := "Página: " + strzero( nPag,3)
	Local cTitRel   := "Apuração de Redes " 
	Local cArqBmp   :=  GetSrvProfString("StartPath", "\system_INDUSTRIA") + "\lgrl05.bmp"
	Local nTam      := 0 
	Local nI        := 0

	If cCmbTpCli = '001'
		cTitRel += "Grand Marchê"
	ElseIf cCmbTpCli = '002'
		cTitRel += "Super Marketing"
	EndIf
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

//	cTxtRod 	:= "Filial:  " + cFilDe + " a " + cFilAte + Space(10)
	cTxtRod     := "Periodo: " + AnoMes(dDperiodo)  + Space(10)
    cTxtRod     += "Rede de Clientes :" + Iif( cCmbTpCli ='001','Grand Marchê','Super Marketing') + Space(10)
    cTxtRod     += "Marca: " +  Iif(cCmbTpPr='01','Todos',Iif(cCmbTpPr='02','Mineirinho','Todos')) + Space(10)
    cTxtRod     += "Percentual: " + Iif( cCmbTpCli ='001',Transform(nPerc,"@E 999.99%"),'Não se aplica') + Space(10)
	oRelat:Line( nMaxLin,nIniCol,nMaxLin,nMaxCol )
	oRelat:Say(nMaxLin + 40, 0230, cTxtRod, oFont2, 100)

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
