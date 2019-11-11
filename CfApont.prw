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
Local oGroup1
Local oSay1 
Local cFile     := "ETIQUETA" + cEmpAnt
Private cGetBar := Space(16) 
Private oGetBar
Private oDlg
  
  OpenTbl(cFile)
  
  DEFINE MSDIALOG oDlg TITLE "Apontamento de Produção: " FROM 000, 000  TO 140, 500 COLORS 0, 16777215 PIXEL

    @ 002, 002 GROUP oGroup1 TO 064, 246 OF oDlg COLOR 0, 16777215 PIXEL
    @ 030, 007 SAY oSay1 PROMPT "Cód. de Barras:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 047 GET oGetBar VAR cGetBar SIZE 192, 010 OF oDlg  COLORS 0, 16777215 PIXEL on Change Aponta(cFile)
    @ 040, 047 GET oGetBar2 VAR cGetBar2 SIZE 000, 000 OF oDlg  COLORS 0, 16777215 PIXEL                      
    
  ACTIVATE MSDIALOG oDlg CENTERED
  
  oDlg:End()
  
Return 
Static Function Aponta(cFile)
	Local cCmd    := ''
		cGetBar := Space(16)
		oGetBar:Refresh() 
		oDlg:Refresh() 		
Return(.F.)
//************************************************************************************************************************************
Static Function Valida(cFile)
	Local lRet    := .T.
	Local cQry    := ''
	Local cTMP    := GetNextAlias()
	Local aArea   := GetArea()   
	
	cQry := "SELECT " + CRLF
	cQry += " * " + CRLF
	cQry += "FROM " + CRLF
	cQry += cFile + CRLF
	cQry +="WHERE " + CRLF 
	cQry +="	FILIAL ='" + cFilAnt + "' AND " + CRLF 
	cQry +="	ETIQUETA ='" + AllTrim(cGetBar) +"' AND " + CRLF
	cQry +=" D_E_L_E_T_ =' ' "
	
	If Select( cTMP ) <> 0
		dbSelectArea( cTMP )
		dbCloseArea()
	EndIf
	
	TcQuery cQry Alias cTMP New
	//acertar para continuar o relatorio	
	Count To nTotReg                                
	cTMP->(dbGoTop())
	
	If nTotReg <= 0
	  //	Alert("Nenhuma informação para exibir, favor verifique os parametros")
		cTMP->(dbCloseArea())
		return( .F. )
	EndIf 	
	
	While cTMP->(!Eof())
		If cTMP->CSTATUS = 'A'
			lRet := .F.   
			Alert("Etiqueta já apontada anteriormente!")
		ElseIf cTMP->CSTATUS = 'T'  
			lRet := .F.
			Alert("Etiqueta já transferida!")
		ElseIf cTMP->CSTATUS = 'C'       
			lRet := .F.
			Alert("Etiqueta cancelada!")
		EndIf		
	EndDo   
	cTMP->(dbCloseArea())
	RestArea(aArea)
Return( lRet ) 
//************************************************************************************************************************************
Static Function OpenTbl(cFile)
	Local nH
	Local aStru := {}

	If !tccanopen(cFile)
  	// Se o arquivo nao existe no banco, cria
  		aadd(aStru,{"FILIAL"   ,"C",02,0})
  		aadd(aStru,{"ETIQUETA" ,"C",16,0})
  		aadd(aStru,{"OP"       ,"C",16,0})
  		aadd(aStru,{"STATUS"   ,"C",01,0})
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
  		//DBCREATEINDEX (cFile+'3',"EMPRESA+FILIAL+ETIQUETA",{ || EMPRESA+FILIAL+ETIQUETA },.T.)
  		INDEX ON "EMPRESA+FILIAL+ETIQUETA" TO (cFile+'_02')
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