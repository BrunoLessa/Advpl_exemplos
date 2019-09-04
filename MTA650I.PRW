#include 'totvs.ch'
#include 'topconn.ch'
#include 'PROTHEUS.CH'

User Function MTA650I 
	Local aArea  := GetArea()
	Local lRet   := .T.    
	Local lAtivo :=  SuperGetMv("MV_XLPROD", .T., xFilial("SC2"))
	
	If lAtivo   
		lRet := MsAguarde({||GerRegs() },"Gerando registro mestre das etiquetas","Aguarde...")
	EndIf       

	RestArea(aArea)	
Return lRet          

//*********************************************************************************************************************************
Static Function GerRegs()                   
	Local cTipo    := SuperGetMv("MV_XPRDTP",.T., xFilial("SC2"))
	Local lRet     := .T.                  
	Local nSeq     := 0 // numero sequencial para etiqueta 
	Local nBasUnit := 5 // Base Unitizacao
	Local nAltUnit := 10 // Altura Unitizacao
	Local nQtdEtiq := 0 // Quant Etiq baseada no Calculo
	Local nQtdPall := 0 // Quant Pallets baseada no Calculo 
	Local nQtdOp   := SC2->C2_QUANT  //Quantidade da OP
	Local aArray   := {} // Array com o conteudo a ser impresso
	
	    // Registra a Etiqueta Mestre para que a mesma seja impressa e lida na linha de producao a cada apontamento 
	    // apartir de um codigo de barras gerado pela mesma
		If cTipo = 'M'
		
			MsProcTxt("Imprimindo etiqueta mestre...")     			                                     		  	
		  	aAdd(aArray,{;
				  		date(),; 
				  		Time(),;
				  		SC2->C2_FILIAL,;
				  		SC2->C2_NUM,;
				  		SC2->C2_ITEM,;
				  		SC2->C2_SEQUEN,; 
				  		SC2->C2_PRODUTO,;
				  		SB1->B1_DESC,;   
				  		0,;				  		
				  		0})			

            u_T50CODBAR(aArray,.T.)
			
	    // Registra o Ativamento da linhaseja pré selecionada na tela de apontamento e
	    // apartir disso gerar a etiqueta dos apontamentos a cada apontamento
		ElseIf cTipo = 'P'

			MsProcTxt("Gravando registros...")
			
            If MsgYesno("Deseja que Essa Op já inicie o ativamento na linha [" + SC2->C2_LINHA  + "] ?","Atenção!!!")
				SC2->C2_ATIVA := .T.
			Else                    
				SC2->C2_ATIVA := .F.
            EndIf

	    // Registra e imprime todas as etiquetas de movimentacao apartir da quantidade informada x pallets padrao 
		ElseIf cTipo = 'T'                         
		
			MsProcTxt("Gerando Etiquetas...")
				
			nQtdPall := SC2->C2_QUANT / (nBasUnit * nAltUnit)
		
			If nQtdPall - int(nQtdPall) > 0
				nQtdPall := int(nQtdPall) + 1 	
			EndIf                            

			nQtdEtiq := (nBasUnit * nAltUnit)

			For nI := nQtdOp To 0 Step (nQtdEtiq * -1)
			  	If nQtdEtiq > nI .And. nI > 0
				  	aAdd(aArray,{;
				  		date(),; 
				  		Time(),;
				  		SC2->C2_FILIAL,;
				  		SC2->C2_NUM,;
				  		SC2->C2_ITEM,;
				  		SC2->C2_SEQUEN,; 
				  		SC2->C2_PRODUTO,;
				  		SB1->B1_DESC,;   
				  		++nSeq,;				  		
				  		nI})
				ElseIf nI > 0
				  	aAdd(aArray,{;
				  		date(),;
				  		Time(),;
				  		SC2->C2_FILIAL,;
				  		SC2->C2_NUM,;
				  		SC2->C2_ITEM,;
				  		SC2->C2_SEQUEN,;
				  		SC2->C2_PRODUTO,;
				  		SB1->B1_DESC,;
				  		++nSeq,;				  		
				  		nQtdEtiq})			
				EndIf
			Next 
			
			u_T50CODBAR(aArray,.F.)
		Else
			lRet := .F.
			MsgAlert("Parâmetro [MV_XPRDTP] com conteudo invalido, favor entrar em contato com administrador!" , "Atenção!!!")			
		EndIf	
Return lRet
Static Function obtSeq(cIdEtiq)
	Local cRet      := ''
	Local cQry      := ''    
	Local aArea     := GetArea()
	Local cSeqResul := getNextAlias()
	
	cQry := "SELECT " + CRLF
	cQry += "	CASE WHEN REGS IS NULL THEN 1 ELSE REGS + 1 END NUMB " + CRLF
	cQry += "FROM  " + CRLF
	cQry += "	( " + CRLF
	cQry += "		SELECT " + CRLF 
	cQry += "			MAX(COALESCE(ZB_SEQUEN,0)) REGS " + CRLF
	cQry += "		FROM  " + CRLF
	cQry += "			" + retSqlName("SZB") + CRLF
	cQry += "		WHERE  " + CRLF
	cQry += "			ZB_FILIAL = '" + xFilial("SZB") + "' AND " + CRLF	
	cQry += "			ZB_ID = '" + cIdEtiq + "' " + CRLF	
	cQry += "	)TB_TMB	 " + CRLF 
	
	If Select(cSeqResul) > 0
		cSeqResul->(dbCloseArea())
	EndIf                         
	
	TcQuery cQry Alias cSeqResul New
	
	While cSeqResul->(!Eof())
		cRet := Transform(cSeqResul->NUMB,PesqPict("SZB","ZB_SEQUEN"))
		cSeqResul->(dbSkip())
	EndDo
	cSeqResul->(dbCloseArea())
	restArea(aArea)
Return( cRet )