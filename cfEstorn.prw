#Include "PROTHEUS.CH" 
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} CfApont
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author  -                                               
@since 30/10/2019                                                   
/*/                                                             
//--------------------------------------------------------------
User Function CfEstorn()
  Local aMainArea := GetArea()
  Local oGroup1
  Local oSay1 
  Local oGetBar2
  Local cGetBar2   := ''
  Private cTabela  := "ETIQUETA" + cEmpAnt
  Private cTabAli  := '_ET' 
  Private cGetBar  := Space(16)
  Private lMsErroAuto := .F. 
  Private oGetBar
  Private oDlg
  
  MsgRun('Aguarde','Abrindo arquivos',{||OpenTbl()})
  
  DEFINE MSDIALOG oDlg TITLE "Estorno de Produção - " + cUserName FROM 000, 000  TO 140, 500 COLORS 0, 16777215 PIXEL

    @ 002, 002 GROUP oGroup1 TO 064, 246 OF oDlg COLOR 0, 16777215 PIXEL
    @ 030, 007 SAY oSay1 PROMPT "Cód. de Barras:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 047 GET oGetBar VAR cGetBar SIZE 192, 010 OF oDlg  COLORS 0, 16777215 PIXEL Valid (Valida(),oDlg:End()) 
    @ 040, 047 GET oGetBar2 VAR cGetBar2 SIZE 000, 000 OF oDlg  COLORS 0, 16777215 PIXEL                      
    
  ACTIVATE MSDIALOG oDlg CENTERED
  
  _ET->(dbCloseArea())     
  restArea(aMainArea)
Return 
//************************************************************************************************************************************
Static Function Valida()
  Local lRet    := .T.
  Local cQry    := ''
  Local cTMP    := GetNextAlias()
  Local aArea   := GetArea()
  Local nD3Rec  := 0 
  Local nETRec  := 0
  Local cChave  := ''
  Local nQuant  := 0
  Local cNumOP  := ''
  Local cTM     := ''
  
  If !MsgYesNo('Deseja Realmente estornar o movimento da etiqueta - ' + AllTrim(cGetBar) ,'Atenção!!!')
    RestArea(aArea)
    return .F.
  EndIf
    
	
  cQry := "SELECT " + CRLF
  cQry += "  C2_FILIAL,  " + CRLF
  cQry += "  C2_NUM,     " + CRLF
  cQry += "  C2_ITEM,    " + CRLF
  cQry += "  C2_SEQUEN,  " + CRLF
  cQry += "  C2_PRODUTO, " + CRLF
  cQry += "  C2_LOCAL,   " + CRLF
  cQry += "  B1_DESC,    " + CRLF
  cQry += "  B1_TIPO,    " + CRLF
  cQry += "  B1_MSBLQL,  " + CRLF
  cQry += "  C2_QUANT,   " + CRLF
  cQry += "  C2_SEQUEN,  " + CRLF
  cQry += "  C2_QUJE,    " + CRLF
  cQry += "  C2_TPOP,    " + CRLF
  cQry += "  C2_STATUS,  " + CRLF
  cQry += "  C2_DATRF,   " + CRLF
  cQry += "  C2_OPTERCE, " + CRLF
  cQry += "  C2_TPPR,    " + CRLF
  cQry += "  CASE WHEN SB5.B5_COMPR IS NULL THEN 0   ELSE SB5.B5_COMPR END B5_COMPR, " + CRLF
  cQry += "  CASE WHEN SB5.B5_LARG  IS NULL THEN 0   ELSE SB5.B5_LARG  END B5_LARG,  " + CRLF    
  cQry += "  CASE WHEN ETQ.ETIQUETA IS NULL THEN ' ' ELSE ETQ.ETIQUETA END ETIQUETA, " + CRLF
  cQry += "  CASE WHEN ETQ.OP IS NULL THEN ' ' ELSE ETQ.OP END OP,                   " + CRLF
  cQry += "  CASE WHEN ETQ.CSTATUS IS NULL THEN ' ' ELSE ETQ.CSTATUS END CSTATUS_ETQ," + CRLF
  cQry += "  CASE WHEN ETQ.CSEQAPT IS NULL THEN ' ' ELSE ETQ.CSEQAPT END CSEQAPT_ETQ," + CRLF  
  cQry += "  CASE WHEN ETQ.R_E_C_N_O_ IS NULL THEN 0 ELSE ETQ.R_E_C_N_O_ END ETQ_REC," + CRLF
  cQry += "  CASE WHEN PA4.PA4_COD IS NULL THEN ' ' ELSE PA4.PA4_COD END LIN_PA4,    " + CRLF
  cQry += "  CASE WHEN PA4.PA4_OP IS NULL THEN ' ' ELSE PA4.PA4_OP END OP_PA4,       " + CRLF
  cQry += "  CASE WHEN PA4.PA4_DESC IS NULL THEN ' ' ELSE PA4.PA4_DESC END DESC_PA4, " + CRLF
  cQry += "  CASE WHEN SD3.R_E_C_N_O_ IS NULL THEN 0 ELSE SD3.R_E_C_N_O_ END SD3_REC," + CRLF
  cQry += "  CASE WHEN SD3.R_E_C_N_O_ IS NULL THEN ' ' ELSE SD3.D3_ESTORNO END SD3_ESTORNO, " + CRLF
  cQry += "  CASE WHEN SD3.R_E_C_N_O_ IS NULL THEN ' ' ELSE SD3.D3_OP END SD3_OP, " + CRLF
  cQry += "  CASE WHEN SD3.R_E_C_N_O_ IS NULL THEN ' ' ELSE SD3.D3_TM END SD3_TM, " + CRLF
  cQry += "  CASE WHEN SD3.R_E_C_N_O_ IS NULL THEN 0 ELSE SD3.D3_QUANT END SD3_QTD,   " + CRLF
  cQry += "  CASE WHEN SD3.R_E_C_N_O_ IS NULL THEN ' ' ELSE SD3.D3_CF END SD3_CF  " + CRLF 
  cQry += "FROM " + CRLF
  cQry += "	" + retSqlName("SC2") + " SC2 " + CRLF
  cQry += "JOIN " + CRLF
  cQry += "	" + retSqlName("SB1") + " SB1 " + CRLF
  cQry += "ON " + CRLF
  cQry += " C2_FILIAL = B1_FILIAL AND  " + CRLF
  cQry += "	C2_PRODUTO = B1_COD AND    " + CRLF
  cQry += "	SB1.D_E_L_E_T_ =' '	       " + CRLF
  cQry += "LEFT JOIN  " + CRLF
  cQry += "	" + retSqlName("SB5") + " SB5 " + CRLF
  cQry += "ON " + CRLF
  cQry += "	B1_FILIAL = B5_FILIAL AND   " + CRLF
  cQry += "	B1_COD    = B5_COD    AND   " + CRLF
  cQry += "	SB5.D_E_L_E_T_ =' '         " + CRLF
  cQry += "LEFT JOIN" + CRLF
  cQry += "	" + cTabela + " ETQ" + CRLF
  cQry += "ON " + CRLF
  cQry += "	C2_FILIAL = FILIAL AND     " + CRLF
  cQry += "	C2_NUM+C2_ITEM+C2_SEQUEN  =  OP    AND     " + CRLF
  cQry += "	ETIQUETA ='" + AllTrim(cGetBar) + "'    AND     " + CRLF
  cQry += "	ETQ.D_E_L_E_T_ = ' '       " + CRLF
  cQry += "LEFT JOIN " + CRLF
  cQry += "	" + retSqlName("PA4") + " PA4 " + CRLF
  cQry += "ON" + CRLF
  cQry += " C2_FILIAL = PA4.PA4_FILIAL AND " + CRLF
  cQry += "	C2_NUM+C2_ITEM+C2_SEQUEN = PA4.PA4_OP AND " + CRLF
  cQry += "	PA4.D_E_L_E_T_ =' ' " + CRLF
  cQry += "LEFT JOIN  " + CRLF
  cQry += "	" + retSqlName("SD3") + " SD3 " + CRLF
  cQry += "ON" + CRLF
  cQry += " C2_FILIAL = D3_FILIAL AND " + CRLF
  cQry += " C2_NUM+C2_ITEM+C2_SEQUEN = D3_OP AND " + CRLF
  cQry += " C2_PRODUTO = D3_COD AND " + CRLF
  cQry += " C2_PRODUTO = D3_COD AND " + CRLF 
  cQry += " C2_LOCAL = D3_LOCAL AND " + CRLF
  cQry += " ETQ.CSEQAPT = D3_NUMSEQ AND " + CRLF
  cQry += " D3_CF ='PR0' AND " + CRLF
  cQry += " SD3.D_E_L_E_T_ =' ' " + CRLF
  cQry += "WHERE " + CRLF
  cQry += " C2_FILIAL = '" +cFilAnt +"' AND " + CRLF
  cQry += " C2_NUM    = '" + Substr(AllTrim(cGetBar),10,6) + "' AND " + CRLF
  cQry += " SC2.D_E_L_E_T_ =' ' "
  
  MemoWrite('C:\Temp_Msiga\qryEst.sql',cQry) 
    	
  If Select( cTMP ) <> 0
	dbSelectArea( cTMP )
	dbCloseArea()
  EndIf
	
  TcQuery cQry Alias cTMP New
  //acertar para continuar o relatorio	
  Count To nTotReg                                
  cTMP->(dbGoTop())
  
  If nTotReg <= 0		
    cTMP->(dbCloseArea())
	RestArea(aArea)	  		  		  	
	msgAlert("Não há registros para essa Ordem de produção, favor verificar o cadastro de Ordens de produção!","Atenção!!!")
	cGetBar := Space(16)
	oGetBar:Refresh() 
	oDlg:Refresh()	  	
	return .F.				
  EndIf 	
	
  While cTMP->(!Eof())
    If Empty(cTMP->OP_PA4)
      lRet := .F.   
      msgAlert("Etiqueta não ativa no setup, favor checar cadastro de setup de linha!","Atenção!!!")    
    ElseIf cTMP->B1_MSBLQL ='1'
      lRet := .F.   
      msgAlert("O produto a ser estornado encontra-se bloqueado, favor verificar o cadastro do mesmo!","Atenção!!!")
    ElseIf cTMP->B1_TIPO  != 'PA'
      lRet := .F.   
      msgAlert("Não é permitido estorno de produção automático para produtos diferentes do tipo PA, entre em contato com o administrador do sistema!","Atenção!!!")							  	  	  
    ElseIf cTMP->C2_DATRF !=' '
      lRet := .F.   
      msgAlert("Produção já encerrada, favor verificar!","Atenção!!!")							  	  	      
    ElseIf cTMP->C2_STATUS != 'N'
      lRet := .F.
      msgAlert("Não é permitido o estorno de produção para OPs que não estejam em situação normal, favor verificar o cadastro da op!","Atenção!!!")
    ElseIf cTMP->C2_TPOP != 'F'
      lRet := .F.
      msgAlert("Não é permitido o estorno de produção para OPs com tipo prevista, favor verificar o cadastro da op!","Atenção!!!")
    ElseIf cTMP->CSTATUS_ETQ = 'T'  
      lRet := .F.
      msgAlert("Etiqueta já transferida!","Atenção!!!")
    ElseIf cTMP->CSTATUS_ETQ = 'C'       
      lRet := .F.
      msgAlert("Etiqueta cancelada!","Atenção!!!")
    ElseIf cTMP->ETQ_REC = 0       
      lRet := .F.
      msgAlert("Etiqueta não apontada!","Atenção!!!") 
    ElseIf cTMP->SD3_REC = 0       
      lRet := .F.
      msgAlert("Movimento não encontrado!","Atenção!!!")      
    ElseIf cTMP->SD3_ESTORNO != ' '       
      lRet := .F.
      msgAlert("Movimento já estornado!","Atenção!!!")      
    EndIf
    cChave  := cTMP->C2_FILIAL+cTMP->C2_PRODUTO+cTMP->C2_LOCAL+cTMP->CSEQAPT_ETQ+cTMP->SD3_CF
    nD3Rec  := cTMP->SD3_REC
    nETRec  := cTMP->ETQ_REC
    cTMP->(dbSkip())		
  EndDo   
  cTMP->(dbCloseArea())
  RestArea(aArea)  	
  
  If lRet
    lRet := MsgRun('Aguarde','Processando o estorno',{||Estorna(nETRec,nD3Rec,cChave)})     
  EndIf
Return( lRet ) 
//************************************************************************************************************************************
Static Function Estorna(nETRec,nD3Rec,cChave)
  Local aArea   := GetArea()  
  Local cTime   := ''  
  Local aVetor  := {}    
  lMsErroAuto   := .F.
        
  dbSelectArea("SD3")
  SD3->(dbSetOrder(3))
  If dbSeek(cChave)
  	If SD3->D3_ESTORNO == ' '
  		SD3->(dbGoto(nD3Rec)) //Forco o ponteiro na marra
  		aVetor := {;
  		           {'D3_DOC'    ,SD3->D3_DOC      , Nil},;
  		           {'D3_COD'    ,SD3->D3_COD      , Nil},;
  		           {'INDEX'     ,2                , Nil};
  		          }
  		Begin Transaction
  		 MsExecAuto({|x, y| mata250(x, y)},aVetor, 5 )
  		 
  		 dbSelectArea("_ET")
  		 _ET->(dbGoto(nETRec))
  		 RecLock("_ET",.F.)
           _ET->CSTATUS  := ' '
           _ET->QTDAPT   := 0
           _ET->CSEQAPT  := ' '
         MsUnlock()
           
  		 If lMsErroAuto
  		 	DisarmTransaction()
  		 	MostraErro()
  		 	Break
  		 EndIf
  		End Transaction
  	EndIf
  EndIf   
  restArea(aArea)
Return(Iif (lMsErroAuto , .F. ,.T.))
//************************************************************************************************************************************
Static Function OpenTbl()
  Local nH
  Local aStru := {}
  Local aInds := {"FILIAL","ETIQUETA"}
  If !tccanopen(cTabela)
  // Se o arquivo nao existe no banco, cria
    aadd(aStru,{"FILIAL"   ,"C",02,0})
    aadd(aStru,{"ETIQUETA" ,"C",16,0})
    aadd(aStru,{"OP"       ,"C",Len(SD3->D3_OP),0})
    aadd(aStru,{"PRODUTO"  ,"C",Len(SD3->D3_COD),0})
    aadd(aStru,{"LOTEPRD"  ,"C",Len(SD3->D3_LOTECTL),0})
    aadd(aStru,{"CSTATUS"  ,"C",01,0})
    aadd(aStru,{"QTDAPT"   ,"N",12,2})  		  	
    aadd(aStru,{"CSEQAPT"  ,"C",Len(SD3->D3_NUMSEQ),0})
    aadd(aStru,{"QTDTRF"   ,"N",12,2})  		  	
    aadd(aStru,{"CSEQTRF"  ,"C",Len(SD3->D3_NUMSEQ),0})    
    DBCreate(cTabela,aStru,"TOPCONN")
    
    If !tccanopen(cTabela,cTabela+'_01')
      // Se o indice por nome nao existe, cria
      USE (cTabela) ALIAS "_ET" EXCLUSIVE NEW VIA "TOPCONN"    
      DBCreateIndex(cTabela+'_01', "FILIAL+ETIQUETA" , {|| FILIAL+ETIQUETA }) 	
      USE
    EndIf
    
    If !tccanopen(cTabela,cTabela+'_02')  
      USE (cTabela) ALIAS  "_ET"  EXCLUSIVE NEW VIA "TOPCONN"       
      DBCreateIndex(cTabela+'_02', "FILIAL+OP" , {|| FILIAL+OP })  
      USE
    EndIf

    If !tccanopen(cTabela,cTabela+'_UNQ')    
      USE (cTabela) ALIAS  "_ET" EXCLUSIVE NEW VIA "TOPCONN"           
      TCUnique(cTabela, "FILIAL+ETIQUETA")
      USE
    EndIf  
       
  Endif

  // Abra o arquivo de agenda em modo compartilhado
  USE (cTabela) ALIAS  "_ET" SHARED NEW VIA "TOPCONN"
  // Liga o filtro para ignorar registros deletados 
  SET DELETED ON
  // Abre os indices, seleciona ordem por ID
  // E Posiciona no primeiro registro 
  DbSetIndex(cTabela+'_01')
  DbSetIndex(cTabela+'_02')  
  DbSetOrder(1)
  DbGoTop()

Return .T.     
