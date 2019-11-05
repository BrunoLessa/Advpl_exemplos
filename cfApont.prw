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
User Function CfApont(cFile)                        
  Local oGroup1
  Local oSay1 
  Local cFile      := "ETIQUETA" + cEmpAnt
  Private cDescPrd := ''
  Private cDescLin := ''
  Private cNumOrdP := ''
  Private cIteOrdP := ''
  Private cSeqOrdP := ''
  Private nHPallet := 0
  Private nLPallet := 0
  Private nHPbr    := 0
  Private nLPbr    := 0
  Private nQtdOP   := 0
  Private nQtdEnt  := 0
  Private cGetBar  := Space(16)
  Private lMsErroAuto := .F. 
  Private oGetBar
  Private oDlg
  
  MsgRun('Aguarde','Abrindo arquivos',{||OpenTbl(cFile)})
  
  DEFINE MSDIALOG oDlg TITLE "Apontamento de Produção: " FROM 000, 000  TO 140, 500 COLORS 0, 16777215 PIXEL

    @ 002, 002 GROUP oGroup1 TO 064, 246 OF oDlg COLOR 0, 16777215 PIXEL
    @ 030, 007 SAY oSay1 PROMPT "Cód. de Barras:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 047 GET oGetBar VAR cGetBar SIZE 192, 010 OF oDlg  COLORS 0, 16777215 PIXEL Valid Iif(Valida(cFile),InfoQtd(cFile),.F.) 
    @ 040, 047 GET oGetBar2 VAR cGetBar2 SIZE 000, 000 OF oDlg  COLORS 0, 16777215 PIXEL                      
    
  ACTIVATE MSDIALOG oDlg CENTERED
  
  oDlg:End()
  
Return 
//************************************************************************************************************************************
Static Function Valida(cFile)
  Local lRet    := .T.
  Local cQry    := ''
  Local cTMP    := GetNextAlias()
  Local cTMP2   := GetNextAlias()	
  Local aArea   := GetArea()   
	
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
  cQry += "  CASE WHEN PA4.OP IS NULL THEN ' ' ELSE PA4.OP END OP_PA4,               " + CRLF
  cQry += "  CASE WHEN PA4.CSTATUS IS NULL THEN ' ' ELSE PA4.CSTATUS END CSTATUS_PA4 " + CRLF
  cQry += "FROM " + CRLF
  cQry += "	" + retSqlName("SC2") + " SC2 " + CRLF
  cQry += "JOIN " + CRLF
  cQry += "	" + retSqlName("SB1") + " SB1 " + CRLF
  cQry += "ON " + CRLF
  //cQry += "   C2_FILIAL = B1_FILIAL AND  " + CRLF
  cQry += "	C2_PRODUTO = B1_COD AND    " + CRLF
  cQry += "	SB1.D_E_L_E_T_ =' '	       " + CRLF
  cQry += "LEFT JOIN
  cQry += "	" + retSqlName("SB5") + " SB5 " + CRLF
  cQry += "ON " + CRLF
  cQry += "	B1_FILIAL = B5_FILIAL AND   " + CRLF
  cQry += "	B1_COD    = B5_COD    AND   " + CRLF
  cQry += "	SB5.D_E_L_E_T_ =' '         " + CRLF
  cQry += "LEFT JOIN" + CRLF
  cQry += "	" + cFile + " ETQ" + CRLF
  cQry += "ON " + CRLF
  cQry += "	C2_FILIAL = FILIAL AND     " + CRLF
  cQry += "	C2_NUM    =  OP    AND     " + CRLF
  cQry += "	ETQ.D_E_L_E_T_ = ' '       " + CRLF
  cQry += "LEFT JOIN " + CRLF
  cQry += "	PA4990 PA4" + CRLF
  cQry += "ON" + CRLF
  cQry += " C2_FILIAL = PA4.FILIAL AND " + CRLF
  cQry += "	C2_NUM    = PA4.OP " + CRLF
  cQry += "WHERE " + CRLF
  cQry += " C2_FILIAL = '" +cFilAnt +"' AND " + CRLF
  cQry += " C2_NUM    = '" + AllTrim(cGetBar) + "' AND " + CRLF
  cQry += " SC2.D_E_L_E_T_ =' ' "
     	
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
      msgAlert("O produto a ser apontado encontra-se bloqueado, favor verificar o cadastro do mesmo!","Atenção!!!")
    ElseIf cTMP->B1_TIPO  != 'PA'
      lRet := .F.   
      msgAlert("Não é permitido apontamento de produção automático para produtos diferentes do tipo PA, entre em contato com o administrador do sistema!","Atenção!!!")							  	  	  
    ElseIf cTMP->C2_STATUS != 'N'
      lRet := .F.
      msgAlert("Não é permitido o apontamento de produção para OPs que não estejam em situação normal, favor verificar o cadastro da op!","Atenção!!!")
    ElseIf cTMP->C2_TPOP != 'F'
      lRet := .F.
      msgAlert("Não é permitido o apontamento de produção para OPs com tipo prevista, favor verificar o cadastro da op!","Atenção!!!")
    ElseIf cTMP->CSTATUS_ETQ = 'A'
      lRet := .F.   
      msgAlert("Etiqueta já apontada anteriormente!","Atenção!!!")
    ElseIf cTMP->CSTATUS_ETQ = 'T'  
      lRet := .F.
      msgAlert("Etiqueta já transferida!","Atenção!!!")
    ElseIf cTMP->CSTATUS_ETQ = 'C'       
      lRet := .F.
      msgAlert("Etiqueta cancelada!","Atenção!!!")
    EndIf
    
    cDescPrd := AllTrim(cTMP->B1_DESC)
    nQtdOp   := cTMP->C2_QUANT
    nQtdEnt  := cTMP->C2_QUJE
    nHPallet := cTMP->B5_COMPR
    nLPallet := cTMP->B5_LARG
    nHPbr    := cTMP->B5_COMPR
    nLPbr    := cTMP->B5_LARG
    cNumOrdP := AllTrim(cTMP->C2_NUM)
    cIteOrdP := AllTrim(cTMP->C2_ITEM)
    cSeqOrdP := AllTrim(cTMP->C2_SEQUEN)
    cDescLin := AllTrim(cTMP->CSTATUS_PA4)
    cTMP->(dbSkip())		
  EndDo   
  cTMP->(dbCloseArea())
  RestArea(aArea)
  
  If !lRet
    cGetBar := Space(16)
    oGetBar:Refresh() 
    oDlg:Refresh()
  EndIf
			
Return( lRet ) 
//************************************************************************************************************************************
Static Function InfoQtd(cFile)
  Local nQuant
  Local nQuant := 0
  Local oBtnCnl
  Local oBtnOK
  Local oGroup1
  Local oGroup2
  Local oLinha
  Local oNPallet
  Local oNPBR
  Local oNumOP
  Local oPBR
  Local oPrdDesc
  Local oQtdPal
  Local oSay1
  Local oSay2
  Local oSay3
  Local oSay4
  Local oSay5
  Local oSay7
  Local nOpc     := 1
  Static oDlg2

  DEFINE MSDIALOG oDlg2 TITLE "Quantidade" FROM 000, 000  TO 260, 406 COLORS 0, 16777215 PIXEL

    @ 002, 002 GROUP oGroup1 TO 076, 200 PROMPT "Dados do Produto:  " OF oDlg2 COLOR 0, 16777215 PIXEL
    @ 012, 007 SAY oSay1 PROMPT    "Num. OP:"     SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 012, 032 SAY oNumOP PROMPT   cNumOrdP       SIZE 050, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 022, 007 SAY oSay3 PROMPT    "Linha      :" SIZE 030, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 022, 032 SAY oLinha PROMPT   cDescLin       SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 032, 007 SAY oSay5 PROMPT    "Produto  :"   SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 032, 032 SAY oPrdDesc PROMPT cDescPrd       SIZE 162, 007 OF oDlg2 COLORS 0, 16777215 PIXEL   
    @ 042, 007 SAY oSay2 PROMPT    "Pallets   :"  SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 042, 125 SAY oSay4 PROMPT    "Quant. Sugerida:" SIZE 044, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 052, 032 SAY oQtdPal PROMPT  "Normal -> " + StrZero(nLPallet,3) + ' x ' + StrZero(nHPallet,3) SIZE 090, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 052, 167 SAY oNPallet PROMPT StrZero(nLPallet * nHPallet,3) SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 062, 032 SAY oPBR PROMPT     "PBR     -> " + StrZero(nLPallet,3) + ' x ' + StrZero(nHPallet,3) SIZE 090, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 062, 167 SAY oNPBR PROMPT    StrZero(nLPallet * nHPallet,3) SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 077, 002 GROUP oGroup2 TO 107, 200 PROMPT "Quantidade:  " OF oDlg2 COLOR 0, 16777215 PIXEL
    @ 087, 007 SAY oSay7 PROMPT "Informe a Quantidade:" SIZE 052, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 086, 062 MSGET nQuant VAR nQuant SIZE 127, 010 OF oDlg2 PICTURE '@<E 999,999.99' COLORS 0, 16777215 PIXEL valid ((nQuant > 0) .And.  (!nQuant <0))
    DEFINE SBUTTON oBtnOK FROM 112, 020 TYPE 01 OF oDlg2  Action  oDlg2:End() ENABLE 
    DEFINE SBUTTON oBtnCnl FROM 112, 158 TYPE 02 OF oDlg2 Action (nOpc:= 2, oDlg2:End())ENABLE   
  ACTIVATE MSDIALOG oDlg2 CENTERED
  
  If nOpc == 1
    If MsgYesNo('Confirmar a quantidade de ' + TransForm(nQuant,PesqPict( 'SD3', 'D3_QUANT' )),'Atenção!!!')
    	Aponta(nQuant,cFile)
    EndIf  	
  EndIf
  
  cGetBar := Space(16)
  oGetBar:Refresh() 
  oDlg:Refresh()
    
Return
//************************************************************************************************************************************
Static Function Aponta(nQuant,cFile)
  Local aArea  := GetArea()
  Local aVetor := {}  
  lMsErroAuto := .F.
  
  aVetor := {;
              {'D3_OP'     , cNumOrdP+cIteOrdP+cSeqOrdP ,Nil},;
              {'D3_COD'    , cNumOrdP+cIteOrdP+cSeqOrdP ,Nil},;
              {'D3_QUANT'  , cNumOrdP+cIteOrdP+cSeqOrdP ,Nil},;
              {'D3_PARCTOT', 'P'                        ,Nil},;
              {'ATUEMP'    , 'T'                        ,Nil},;
              {'D3_TM'     , '010'                      ,Nil},;
              {'D3_QTMAIOR', 0                          ,Nil},;                        
             }             
  Begin Transaction
  	reclock(cFile,.T.)
  	cFile->FILIAL := cFilAnt
  	MsUnLock()
    MsExecAuto({|x, y| mata250(x, y)},aVetor, 3 )
    If lMsErroAuto
    	MostraErro()
    	DisarmTransaction()
    	Break
    EndIf
  End Transaction
  restArea(aArea)
Return .T.
//************************************************************************************************************************************
Static Function OpenTbl(cFile)
  Local nH
  Local aStru := {}
  Local aInds := {"FILIAL","ETIQUETA"}
  If !tccanopen(cFile)
  // Se o arquivo nao existe no banco, cria
    aadd(aStru,{"FILIAL"   ,"C",02,0})
    aadd(aStru,{"ETIQUETA" ,"C",16,0})
    aadd(aStru,{"OP"       ,"C",Len(SD3->D3_OP),0})
    aadd(aStru,{"PRODUTO"  ,"C",Len(SD3->D3_COD),0})
    aadd(aStru,{"LOTEPRD"  ,"C",Len(SD3->D3_LOTECTL),0})  		  	
    aadd(aStru,{"CSTATUS"  ,"C",01,0})
    DBCreate(cFile,aStru,"TOPCONN")
  Endif
  
  If !tccanopen(cFile,cFile+'_01')
    // Se o indice por nome nao existe, cria
    USE (cFile) ALIAS (cFile) EXCLUSIVE NEW VIA "TOPCONN"
    INDEX ON "FILIAL" TO (cFile+'_01')
    USE
  EndIf 
  
  If !tccanopen(cFile,cFile+'_02')
    // Se o indice por nome nao existe, cria
    USE (cFile) ALIAS (cFile) EXCLUSIVE NEW VIA "TOPCONN"
    DBCREATEINDEX (cFile+'_02',aInds,{ || EMPRESA+FILIAL+ETIQUETA },.T.)  		
    USE
  EndIf

  // Abra o arquivo de agenda em modo compartilhado
  USE (cFile) ALIAS cFile SHARED NEW VIA "TOPCONN"
  // Liga o filtro para ignorar registros deletados 
  SET DELETED ON
  // Abre os indices, seleciona ordem por ID
  // E Posiciona no primeiro registro 
  DbSetIndex(cFile+'1')
  DbSetIndex(cFile+'2')
  DbSetIndex(cFile+'3')
  DbSetOrder(1)
  DbGoTop()

Return .T.         
