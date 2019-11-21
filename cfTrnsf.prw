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
User Function cfTrnsf()
  Local aMainArea := GetArea()
  Local oGroup1
  Local oSay1 
  Local oGetBar2
  Local cGetBar2   := ''
  Private cTabela  := "ETIQUETA" + cEmpAnt
  Private cTabAli  := '_ET' 
  Private cCodPrd  := ''
  Private cDescPrd := ''
  Private cDescLin := ''
  Private cLinOp   := ''	
  Private cNumOrdP := ''
  Private cStaEtiq := '' 
  Private cIteOrdP := ''
  Private cSeqOrdP := ''
  Private nHPallet := 0
  Private nLPallet := 0
  Private nHPbr    := 0
  Private nLPbr    := 0
  Private nQtdOP   := 0
  Private nQtdEnt  := 0
  Private nRecEtiq := 0
  Private nQtdApt  := 0 
  Private cPrdUM   := '' 
  Private cTrfLoc  := ''
  Private cAptLoc  := ''
  Private cGetBar  := Space(16)
  Private lMsErroAuto := .F. 
  Private oGetBar
  Private oDlg
  
  MsgRun('Aguarde','Abrindo arquivos',{||OpenTbl()})
  
  DEFINE MSDIALOG oDlg TITLE "Transferencia de Produ��o - " + cUserName FROM 000, 000  TO 140, 500 COLORS 0, 16777215 PIXEL

    @ 002, 002 GROUP oGroup1 TO 064, 246 OF oDlg COLOR 0, 16777215 PIXEL
    @ 030, 007 SAY oSay1 PROMPT "C�d. de Barras:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 047 GET oGetBar VAR cGetBar SIZE 192, 010 OF oDlg  COLORS 0, 16777215 PIXEL Valid Iif(Valida(),InfoQtd(),.F.) 
    @ 040, 047 GET oGetBar2 VAR cGetBar2 SIZE 000, 000 OF oDlg  COLORS 0, 16777215 PIXEL                      
    
  ACTIVATE MSDIALOG oDlg CENTERED
  
  _ET->(dbCloseArea())     
  restArea(aMainArea)
Return 
//************************************************************************************************************************************
Static Function Valida(cFile)
  Local lRet    := .T.
  Local cQry    := ''
  Local cTMP    := GetNextAlias()
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
  cQry += "  B1_UM,      " + CRLF
  cQry += "  B1_LOCPAD,  " + CRLF
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
  cQry += "  CASE WHEN SD3.R_E_C_N_O_ IS NULL THEN ' ' ELSE SD3.D3_CF END SD3_CF,  " + CRLF 
  cQry += "  CASE WHEN SD3.R_E_C_N_O_ IS NULL THEN ' ' ELSE SD3.D3_LOCAL END SD3_LOCAL " + CRLF  
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
  
  MemoWrite('C:\Temp_Msiga\qryTransf.sql',cQry)   	
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
	msgAlert("N�o h� registros para essa Ordem de produ��o, favor verificar o cadastro de Ordens de produ��o!","Aten��o!!!")
	cGetBar := Space(16)
	oGetBar:Refresh() 
	oGetBar:SetFocus()
	oDlg:Refresh()	  	
	return .F.				
  EndIf 	
	
  While cTMP->(!Eof())
    If Empty(cTMP->OP_PA4)
      lRet := .F.   
      msgAlert("Etiqueta n�o ativa no setup, favor checar cadastro de setup de linha!","Aten��o!!!")    
    ElseIf cTMP->B1_MSBLQL ='1'
      lRet := .F.   
      msgAlert("O produto a ser apontado encontra-se bloqueado, favor verificar o cadastro do mesmo!","Aten��o!!!")
    ElseIf cTMP->B1_TIPO  != 'PA'
      lRet := .F.   
      msgAlert("N�o � permitido apontamento de produ��o autom�tico para produtos diferentes do tipo PA, entre em contato com o administrador do sistema!","Aten��o!!!")							  	  	  
    ElseIf cTMP->C2_DATRF !=' '
      lRet := .F.   
      msgAlert("Produ��o j� encerrada, favor verificar!","Aten��o!!!")							  	  	      
    ElseIf cTMP->C2_STATUS != 'N'
      lRet := .F.
      msgAlert("N�o � permitido o apontamento de produ��o para OPs que n�o estejam em situa��o normal, favor verificar o cadastro da op!","Aten��o!!!")
    ElseIf cTMP->C2_TPOP != 'F'
      lRet := .F.
      msgAlert("N�o � permitido o apontamento de produ��o para OPs com tipo prevista, favor verificar o cadastro da op!","Aten��o!!!")
    ElseIf cTMP->CSTATUS_ETQ = ' '
      lRet := .F.   
      msgAlert("Etiqueta n�o apontada!","Aten��o!!!")
    ElseIf cTMP->CSTATUS_ETQ = 'T'  
      lRet := .F.
      msgAlert("Etiqueta j� transferida!","Aten��o!!!")
    ElseIf cTMP->CSTATUS_ETQ = 'C'       
      lRet := .F.
      msgAlert("Etiqueta cancelada!","Aten��o!!!")
    EndIf
    
    cDescPrd := AllTrim(cTMP->B1_DESC)
    cCodPrd  := cTMP->C2_PRODUTO 
    nQtdOp   := cTMP->C2_QUANT
    nQtdEnt  := cTMP->C2_QUJE
    nHPallet := cTMP->B5_COMPR
    nLPallet := cTMP->B5_LARG
    nHPbr    := cTMP->B5_COMPR
    nLPbr    := cTMP->B5_LARG
    cNumOrdP := AllTrim(cTMP->C2_NUM)
    cIteOrdP := AllTrim(cTMP->C2_ITEM)
    cSeqOrdP := AllTrim(cTMP->C2_SEQUEN)
    cDescLin := AllTrim(cTMP->DESC_PA4)
    cStaEtiq := AllTrim(cTMP->CSTATUS_ETQ)
    cLinOp   := cTMP->LIN_PA4 
    nRecEtiq := cTMP->ETQ_REC
    nQtdApt  := cTMP->SD3_QTD
    cAptLoc  := cTMP->SD3_LOCAL
    cTrfLoc  := cTMP->B1_LOCPAD
    cPrdUM   := cTMP->B1_UM
    cTMP->(dbSkip())		
  EndDo   
  cTMP->(dbCloseArea())
  RestArea(aArea)
  
  If !lRet
    cGetBar := Space(16)
    oGetBar:Refresh() 
    oGetBar:SetFocus()
    oDlg:Refresh()
  EndIf
			
Return( lRet ) 
//************************************************************************************************************************************
Static Function InfoQtd(cFile)
  Local nQnt
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
  Local nOpc     := 2
  Static oDlg2

  DEFINE MSDIALOG oDlg2 TITLE "Quantidade" FROM 000, 000  TO 260, 406 COLORS 0, 16777215 PIXEL

    @ 002, 002 GROUP oGroup1 TO 076, 200 PROMPT "Dados do Produto:  " OF oDlg2 COLOR 0, 16777215 PIXEL
    @ 012, 007 SAY oSay1 PROMPT    "Num. OP:"     SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 012, 032 SAY oNumOP PROMPT   cNumOrdP       SIZE 050, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 022, 007 SAY oSay3 PROMPT    "Linha      :" SIZE 030, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
    @ 022, 032 SAY oLinha PROMPT   cDescLin       SIZE 162, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
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
    @ 086, 062 MSGET nQnt VAR nQuant SIZE 127, 010 OF oDlg2 PICTURE '@<E 999,999.99' COLORS 0, 16777215 PIXEL valid (nQuant >= 0.01)
    DEFINE SBUTTON oBtnOK FROM 112, 020 TYPE 01 OF oDlg2  Action (nOpc:= 1, oDlg2:End()) ENABLE 
    DEFINE SBUTTON oBtnCnl FROM 112, 158 TYPE 02 OF oDlg2 Action (nOpc:= 2, oDlg2:End())ENABLE   
  ACTIVATE MSDIALOG oDlg2 CENTERED
  
  If nOpc == 1
  	If nQtdApt != nQuant
  	  Alert("A quantidade informada diverge da quantidade apontada na OP")
  	  cGetBar := Space(16)
      oGetBar:Refresh()
      oGetBar:SetFocus() 
      oDlg:Refresh()
      return
    EndIf
    If MsgYesNo('Confirmar a quantidade de ' + TransForm(nQuant,PesqPict( 'SD3', 'D3_QUANT' )),'Aten��o!!!')
    	MsgRun('Aguarde','Transferindo produ��o apontada...',{||Aponta(nQuant)})
    EndIf  	
  EndIf
  
  cGetBar := Space(16)
  oGetBar:Refresh() 
  oGetBar:SetFocus()
  oDlg:Refresh()
    
Return
//************************************************************************************************************************************
Static Function Aponta(nQuant,cFile)
  Local aArea   := GetArea()
  Local cNumSeq := ''
  Local cTime   := ''
  Local aItem   := {}
  Local aAuto   := {}
  Local cDocNum := ''
  Local lAchou  := .F.
  Local cTM     := Alltrim(SuperGetMv( "MV_XTMTR" ,.F. , "010"  )) 
  Local lAtuemp := Alltrim(SuperGetMv( "MV_XATEMP" ,.F. , "F"    ))  
  lMsErroAuto   := .F.
  
       
  cTime   := Time()
  
  //Origem
  aAdd(aItem,{'D3_COD'    , cCodPrd                    ,Nil})
  aAdd(aItem,{'D3_DESCRI' , cDescPrd                   ,Nil})
  aAdd(aItem,{'D3_UM'     , cPrdUM                     ,Nil})
  aAdd(aItem,{'D3_LOCAL'  , cAptLoc                    ,Nil})
  aAdd(aItem,{'D3_LOCALIZ', ' '                        ,Nil})
 
  //Destino
  aAdd(aItem,{'D3_COD'    , cCodPrd                    ,Nil})
  aAdd(aItem,{'D3_DESCRI' , cDescPrd                   ,Nil})
  aAdd(aItem,{'D3_UM'     , cPrdUM                     ,Nil})
  aAdd(aItem,{'D3_LOCAL'  , cTrfLoc                    ,Nil})
  aAdd(aItem,{'D3_LOCALIZ', ' '                        ,Nil})
  
  // Itens obrigatorios
  aadd(aItem,{"D3_NUMSERI", ""      , Nil}) //Numero serie
  aadd(aItem,{"D3_LOTECTL", ""      , Nil}) //Lote Origem
  aadd(aItem,{"D3_NUMLOTE", ""      , Nil}) //sublote origem
  aadd(aItem,{"D3_DTVALID", ''      , Nil}) //data validade 
  aadd(aItem,{"D3_POTENCI", 0       , Nil}) // Potencia
  aadd(aItem,{"D3_QUANT"  , nQuant  , Nil}) //Quantidade
  aadd(aItem,{"D3_QTSEGUM", 0       , Nil}) //Seg unidade medida
  aadd(aItem,{"D3_ESTORNO", ""      , Nil}) //Estorno 
  aadd(aItem,{"D3_NUMSEQ" , ""      , Nil}) // Numero sequencia D3_NUMSEQ

  aadd(aItem,{"D3_LOTECTL", ""      , Nil}) //Lote destino
  aadd(aItem,{"D3_NUMLOTE", ""      , Nil}) //sublote destino 
  aadd(aItem,{"D3_DTVALID", ''      , Nil}) //validade lote destino
  aadd(aItem,{"D3_ITEMGRD", ""      , Nil}) //Item Grade

  aadd(aItem,{"D3_CODLAN", ""       , Nil}) //cat83 prod origem
  aadd(aItem,{"D3_CODLAN", ""       , Nil}) //cat83 prod destino 
 
  
  Begin Transaction
    cDocNum := GetSxeNum("SD3","D3_DOC")
    aadd(aAuto,{cDocNum,date()}) //Cabecalho
    aAdd(aAuto,aItem)
    
    MsExecAuto({|x, y| mata261(x, y)},aAuto, 3 )
    If lMsErroAuto    	    	
    	DisarmTransaction()    	
    	MostraErro()
    	Break
    EndIf
    
    dbSelectArea("SD3")
    SD3->(dbSetOrder(2))
    If dbSeek(cFilAnt+cDocNum+cCodPrd)
      lAchou  := .T.
      cNumSeq := SD3->D3_NUMSEQ
    EndIf
    
    If lAchou
      dbSelectArea("_ET")
      _ET->(dbGoto(nRecEtiq))	
      RecLock("_ET",.F.)
      _ET->CSTATUS  := 'T'
      _ET->QTDTRF   := nQuant
      _ET->CSEQTRF  := cNumSeq
      MsUnlock()
     EndIf          
      
  End Transaction
  restArea(aArea)
Return .T.
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