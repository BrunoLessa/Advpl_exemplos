#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
/*************************************************************************************************************************************************
 Ponto de Entrada: MT250EST - executado logo apos a confirmacao do estorno do apontamento de producao
 Descricao:        responsavel por alterar o campo D3_QTMAIOR para o acerto dos estornos dos produtos
                   que obtiveram ganho.
                   OBS: Essa rotina somente é ativada quando a producao for apontada como parcial 
                        Somente é ativada quando o parametro MV_XREF250 for preenchido com .T.
                        Funciona em conjunto com o P.E. A250ARD4                  
 Solicitante:      -
 Programador:      Bruno Lessa
 Data       :      15/12/18
 Alteracao  :      -
 *************************************************************************************************************************************************/
User Function MT250EST
	Local cCmd      := ''                                       
    Local lRet      := .T.                
    Local aArea     := GetArea()
    Local lAtiva    := SuperGetMv( "MV_XREF250" , .F. , .F. , )
	Private cPath 	:= "c:\TEMP_MSIGA\" 
	Private cNomArq := "MT250EST"
		
	cCmd := "UPDATE  " + CRLF                 
	cCmd += RetSqlName("SD3") +  CRLF
	cCmd += " SET " + CRLF
	cCmd += "    D3_QTMAIOR = 0 " + CRLF
	cCmd += "WHERE " + CRLF
	cCmd += "    R_E_C_N_O_ " + CRLF
	cCmd += "    IN ( " + CRLF						
	cCmd += "		SELECT  " + CRLF
	cCmd += "			SD3.R_E_C_N_O_ " + CRLF
	cCmd += "		FROM  " + CRLF
	cCmd += "			  " + RetSqlName("SD3") + " SD3 " + CRLF
	cCmd += "		JOIN  " + CRLF
	cCmd += "			  " + RetSqlName("SB1") + " SB1 " + CRLF
	cCmd += "		ON  " + CRLF
	cCmd += "			D3_FILIAL = SB1.B1_FILIAL AND  " + CRLF
	cCmd += "			D3_COD    = SB1.B1_COD AND  " + CRLF
	cCmd += "			SB1.D_E_L_E_T_ =' '  " + CRLF      
	cCmd += "		JOIN  " + CRLF
	cCmd += "			  " + RetSqlName("SC2") + " SC2 " + CRLF
	cCmd += "		ON  " + CRLF
	cCmd += "			D3_FILIAL = C2_FILIAL AND  " + CRLF			
	cCmd += "			D3_OP     = C2_NUM + C2_ITEM + C2_SEQUEN AND  " + CRLF						
	cCmd += "			SC2.D_E_L_E_T_ =' ' " + CRLF									
	cCmd += "		JOIN  " + CRLF
	cCmd += "			  " + RetSqlName("SB1") + " C2B1 " + CRLF
	cCmd += "		ON  " + CRLF
	cCmd += "			C2_FILIAL  = C2B1.B1_FILIAL AND  " + CRLF
	cCmd += "			C2_PRODUTO = C2B1.B1_COD AND  " + CRLF
	cCmd += "			C2B1.D_E_L_E_T_ =' '  " + CRLF      
	cCmd += "		WHERE  " + CRLF
	cCmd += "	        D3_FILIAL  ='" + xFilial("SC2") + "' AND  " + CRLF
	cCmd += "	        D3_OP  ='" + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "' AND  " + CRLF
	cCmd += "		    D3_DOC ='" + cDoc + "' AND " + CRLF
	cCmd += "			D3_ESTORNO !='S' AND  " + CRLF
	cCmd += "			D3_TM !='010' AND " + CRLF    
	cCmd += "			C2B1.B1_TIPO ='PA' AND " + CRLF			
	cCmd += "			SB1.B1_TIPO ='PP' AND " + CRLF
	cCmd += "			D3_QTMAIOR > 0 AND " + CRLF
	cCmd += "			SD3.D_E_L_E_T_ =' ' " + CRLF
	cCmd += "	)" + CRLF                            
	
	If lAtiva .And. CriaDir()                                        

		MemoWrite( cPath + "\" + cNomArq + ".txt",cCmd)
	
		If TCSqlExec(cCmd) < 0
			Alert("Erro ao atualizar os registros da tabela [SD3], favor verificar o ponto de entrada MT250EST !!! " + CRLF + ;
    		"TCSQLError() " + TCSQLError()) 
			lRet := .F.
		EndIf	
	
	EndIf	 
		
	RestArea(aArea)	
Return( lRet )
//*****************************************************************************************************************************************************
Static Function CriaDir()           	
	Local lRet := .T.

	If !ExistDir( cPath )
		If MakeDir( cPath )  != 0 
			lRet := .F.
			Alert( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
		EndIf
	EndIf

Return( lRet )