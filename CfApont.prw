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
User Function CfApont()
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
  Private cGetBar  := Space(16)
  Private lMsErroAuto := .F. 
  Private oGetBar
  Private oDlg
  
  MsgRun('Aguarde','Abrindo arquivos',{||OpenTbl()})
  
  DEFINE MSDIALOG oDlg TITLE "Apontamento de Produção - " + cUserName FROM 000, 000  TO 140, 500 COLORS 0, 16777215 PIXEL

    @ 002, 002 GROUP oGroup1 TO 064, 246 OF oDlg COLOR 0, 16777215 PIXEL
    @ 030, 007 SAY oSay1 PROMPT "Cód. de Barras:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
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
  cQry += "  CASE WHEN ETQ.R_E_C_N_O_ IS NULL THEN 0 ELSE ETQ.R_E_C_N_O_ END ETQ_REC," + CRLF
  cQry += "  CASE WHEN PA4.PA4_COD IS NULL THEN ' ' ELSE PA4.PA4_COD END LIN_PA4,    " + CRLF
  cQry += "  CASE WHEN PA4.PA4_OP IS NULL THEN ' ' ELSE PA4.PA4_OP END OP_PA4,       " + CRLF
  cQry += "  CASE WHEN PA4.PA4_DESC IS NULL THEN ' ' ELSE PA4.PA4_DESC END DESC_PA4  " + CRLF  
  cQry += "FROM " + CRLF
  cQry += "	" + retSqlName("SC2") + " SC2 " + CRLF
  cQry += "JOIN " + CRLF
  cQry += "	" + retSqlName("SB1") + " SB1 " + CRLF
  cQry += "ON " + CRLF
  cQry += " C2_FILIAL = B1_FILIAL AND  " + CRLF
  cQry += "	C2_PRODUTO = B1_COD AND    " + CRLF
  cQry += "	SB1.D_E_L_E_T_ =' '	       " + CRLF
  cQry += "LEFT JOIN
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
  cQry += "WHERE " + CRLF
  cQry += " C2_FILIAL = '" +cFilAnt +"' AND " + CRLF
  cQry += " C2_NUM    = '" + Substr(AllTrim(cGetBar),10,6) + "' AND " + CRLF
  cQry += " SC2.D_E_L_E_T_ =' ' "
  
  MemoWrite('C:\Temp_Msiga\qry.sql',cQry)   	
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
    ElseIf cTMP->C2_DATRF !=' '
      lRet := .F.   
      msgAlert("Produção já encerrada, favor verificar!","Atenção!!!")							  	  	      
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
    If MsgYesNo('Confirmar a quantidade de ' + TransForm(nQuant,PesqPict( 'SD3', 'D3_QUANT' )),'Atenção!!!')
    	MsgRun('Aguarde','Apontando produção...',{||Aponta(nQuant,cFile)})
    EndIf  	
  EndIf
  
  cGetBar := Space(16)
  oGetBar:Refresh() 
  oDlg:Refresh()
    
Return
//************************************************************************************************************************************
Static Function Aponta(nQuant,cFile)
  Local aArea   := GetArea()
  Local cNumSeq := ''
  Local cTime   := ''
  Local aVetor  := {}
  Local cTM     := Alltrim(SuperGetMv( "MV_XTMPRO" ,.F. , "010"  )) 
  Local lAtuemp := Alltrim(SuperGetMv( "MV_XATEMP" ,.F. , "F"    ))  
  lMsErroAuto   := .F.
  
       
  cTime   := Time()
  aVetor := {;
             {'D3_OP'     , cNumOrdP+cIteOrdP+cSeqOrdP ,Nil},;
             {'D3_COD'    , cCodPrd                    ,Nil},;
             {'D3_QUANT'  , nQuant                     ,Nil},;
             {'D3_EMISSAO', Date()                     ,Nil},;
             {'D3_PARCTOT', 'P'                        ,Nil},;
             {'ATUEMP'    , 'T'                        ,Nil},;
             {'D3_TM'     , cTM                        ,Nil},;
             {'D3_QTMAIOR', 0                          ,Nil},;              
             {'D3_XETIQ'  , Substr(cGetBar,1,8)        ,Nil},;
             {'D3_XHORA'  , cTime                      ,Nil},;
             {'D3_XLINHA' , cLinOp                     ,Nil};                                                                       
            }
                         
  If lAtuEmp == "T"
  	aAdd(aVetor,{'ATUEMP' , T ,Nil} )
  EndIf
  
  Begin Transaction

    MsExecAuto({|x, y| mata250(x, y)},aVetor, 3 )
    If lMsErroAuto    	    	
    	DisarmTransaction()    	
    	MostraErro()
    	Break
    EndIf

    cNumSeq := SD3->D3_NUMSEQ

    dbSelectArea("_ET")

    If nRecEtiq = 0    	
      RecLock("_ET",.T.)
      _ET->FILIAL   := cFilant
      _ET->ETIQUETA := AllTrim(cGetBar)
      _ET->OP       := cNumOrdP+cIteOrdP+cSeqOrdP
      _ET->PRODUTO  := cCodPrd
      _ET->LOTEPRD  := ''
      _ET->CSTATUS  := 'A'
      _ET->QTDAPT   := nQuant
      _ET->CSEQAPT  := cNumSeq
      MsUnlock() 
    Else
      dbGoto(nRecEtiq)	
      RecLock("_ET",.F.)
      _ET->FILIAL   := cFilant
      _ET->ETIQUETA := AllTrim(cGetBar)
      _ET->OP       := cNumOrdP+cIteOrdP+cSeqOrdP
      _ET->PRODUTO  := cCodPrd
      _ET->LOTEPRD  := ''
      _ET->CSTATUS  := 'A'
      _ET->QTDAPT   := nQuant
      _ET->CSEQAPT  := cNumSeq
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
