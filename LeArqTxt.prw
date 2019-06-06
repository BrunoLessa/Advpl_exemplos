#INCLUDE "PROTHEUS.CH"

User Function LeArqTxt() 
	Private nOpc := 0 
	Private cCadastro := "Ler arquivo texto" 
	Private aSay := {} 
	Private aButton := {} 
	AADD( aSay, "O objetivo desta rotina e efetuar a leitura em um arquivo texto" ) 
	AADD( aButton, { 1,.T.,{|| nOpc := 1,FechaBatch()}}) 
	AADD( aButton, { 2,.T.,{|| FechaBatch() }} ) 
	FormBatch( cCadastro, aSay, aButton ) 
	If nOpc == 1 
		Processa( {|| Import() }, "Processando..." )
	Endif 
Return
Static Function Import()
	Local Buffer 	:= ''
	Local cFileOpen := ""
	Local cTitulo1  := "Selecione o arquivo"
	Local cExtens   := "Arquivo CVS | *.csv"
	Local cForn     := ''
	Local cLj		:= ''        
	Local lTrue     := .F.
	Local aArea     := GetArea()
	local nHandle   := FCREATE("C:\Temp_msiga\file.csv")
	Local nLin      := 0
	Local cLinha    := ''
	Local aArr      := {}
	
	cFileOpen := cGetFile(cExtens,cTitulo1,,cMainPath,.T.)
	If !File(cFileOpen)
		MsgAlert("Arquivo texto: "+cFileOpen+" não localizado",cCadastro)
		Return
	EndIf           
	dbSelectArea("SA1")  
	SA1->(dbSetOrder(1))
	FT_FUSE(cFileOpen)
	FT_FGOTOP()
	ProcRegua(FT_FLASTREC())
	While !FT_FEOF()
		IncProc()           
		cBuffer := FT_FREADLN()
		nLin++
		aArr := StrTokArr( cBuffer,';' )

		If Substr(cBuffer,1,3) !='Cod'
			cForn := Substr(aArr[4],1,6)
			cLj   := Substr(aArr[3],Len(Trim(aArr[3]))-1,2)

			If SA1->(DbSeek(xFilial("SA1")+cForn+cLj))  
				
			    If nHandle = -1
			        conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
			    Else
			        FWrite(nHandle, cBuffer + ';' + Trim(SA1->A1_MSBLQL) + ';' + Trim(SA1->A1_VEND) + ';' + Trim(SA1->A1_XROTA)  + ';' + Trim(SA1->A1_XSETOR) + ';' + Trim(SA1->A1_COD) + ';' + Trim(SA1->A1_NREDUZ) + ';' + Trim(SA1->A1_END) + ';' + Trim(SA1->A1_BAIRRO) + ';' + Trim(SA1->A1_MUN) + ';' + Trim(SA1->A1_CEP) + ';' + Trim(SA1->A1_EST) + ';' + Trim(SA1->A1_BAIRRO) + ';' + Trim(SA1->A1_MUN) + ';' + Trim(SA1->A1_EST) +  CRLF)
		    	Endif				
			Else
		    	If nHandle = -1
					conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
			    Else
				    FWrite(nHandle, cBuffer + CRLF)
			    Endif							
			EndIf		
		Else
	    	If nHandle = -1
				conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
		    Else
			    FWrite(nHandle, cBuffer + CRLF)
		    Endif				
		EndIf
		FT_FSKIP()
	EndDo
    FClose(nHandle)
	FT_USE()        	
	MsgInfo("Processo finalizada")
	RestArea(aArea)
Return
	