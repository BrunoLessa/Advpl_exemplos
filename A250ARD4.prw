#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOPCONN.CH"
/*************************************************************************************************************************************************
 Ponto de Entrada: A250ARD4 - executado logo apos a confirmacao do apontamento de producao
 Descricao:        responsavel por alterar o array de empenhos e acertar os apontamentos de producao a maior para que nao consuma os produtos em 
                   processo pois estes obtiveram ganho.
                   OBS: Essa rotina somente é ativada quando a producao for apontada como parcial
                        Somente é ativada quando o parametro MV_XREF250 for preenchido com .T.
                        Funciona em conjunto com o P.E. MT250EST                                        
 Solicitante:      -
 Programador:      Bruno Lessa
 Data       :      10/05/19
 Alteracao  :      -
 *************************************************************************************************************************************************/
User Function A250ARD4()
	Local aItensSD4 	:= ParamIXB  
 	Local aArea     	:= GetArea()
 	Local aAreaSB1  	:= SB1->(GetArea())
    Local lAtiva        := SuperGetMv( "MV_XREF250" , .F. , .F. , ) 	
 	Local aIndices  	:= {} 	 	
 	Local nPosArr       := 0
 	Local nQuant    	:= Iif(SD3->D3_TM ='010',SD3->D3_QUANT,0)
 	Local nSaldo    	:= 0               
 //desc do array ParamIXB
 /* 1- recno
    2- QUANT A MOV 
    3- cod prod
    4-armazem
    5- ?
    6- ?
    7- d4_quant
    8- ?
    9- ?
    10- ?
    11- Op
    12- d4_qtdeOri
    13- ?
    14- ?
 */
//SD3->D3_QUANT   
//SD3->D3_QTMAIOR ->PROD A MAIOR
//SD3->D3_QTGANHO ->GANHO DE PROD
//SC2->C2_QUANT   
//SC2->C2_QUJE       	          
	If SD3->D3_QTMAIOR > 0 .And. Inclui .And. lAtiva
		For nI := 1  To Len(aItensSD4)
			For nX := 1 To Len(aItensSD4[nI])					
				SB1->(dbSetOrder(1))      	
				If dbSeek(Xfilial('SB1') + aItensSD4[nI][nX][3])
					If SB1->B1_TIPO ='PP' 
						If ( nQuant + SC2->C2_QUJE ) > SC2->C2_QUANT
							If ObtIndice(SD3->D3_OP, aItensSD4[nI][nX][3]) > 0
							   aItensSD4[nI][nX][2] := ObtIndice(SD3->D3_OP, aItensSD4[nI][nX][3])
							Else 
							   aItensSD4[nI][nX][2] := 0
							EndIf 																		 	
						EndIf
					EndIf
				EndIf
			Next nX
		Next nI
	EndIf			         
	
	SB1->(restArea(aAreaSB1))
	restArea(aArea)
Return(aItensSD4)	
/*************************************************************************************************************************************************/
Static Function ObtIndice(cOp, cPrd)
	Local aAreaIn := GetArea()     
	Local cAliInd := GetNextAlias()
	Local nIndice := 0
	Local cQry    := ''          
	
	cQry := "SELECT " + CRLF
	cQry += "	D4_QUANT " + CRLF
	cQry += "FROM " + CRLF
	cQry += RetSqlName('SD4') + " SD4 " + CRLF
	cQry += "WHERE " + CRLF
	cQry += "	D4_FILIAL ='" + xFilial("SD4") + "' AND " + CRLF
	cQry += "	D4_OP ='" + cOp + "' AND " + CRLF
	cQry += "	D4_COD ='" + cPrd + "' AND " + CRLF
	cQry += "	D_E_L_E_T_ =' ' "

	If Select( cAliInd) <> 0
		dbSelectArea(cAliInd)
		dbCloseArea()
	EndIf	         
	
	TcQuery cQry New Alias cAliInd 		 

	Count To nTotReg                                
	cAliInd->(dbGoTop())
	
	If nTotReg > 0    
		While cAliInd->(!Eof())
			nIndice := cAliInd->D4_QUANT
			cAliInd->(dbSkip())
		EndDo	
	EndIf 
	
	cAliInd->(dbCloseArea())	
	restArea(aAreaIn)
Return( nIndice )