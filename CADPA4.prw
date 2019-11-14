#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CADPA4     º Autor ³ WRC               º Data ³  20/09/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Linhas de Produção                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CADPA4()

Local cCodUsers := Alltrim(SuperGetMv( "MV_XLNUSER" , , "000000;"  )) 				
   
Private cCadastro := "Cadastro de Linhas de Produção"          

Private aRotina := {	{"Pesquisar","AxPesqui",0,1} ,;
							{"Visualizar","AxVisual",0,2} }

If PswAdmin(,,__cUserId) = 0 
	aadd(aRotina,{"Incluir","AxInclui",0,3})
	aadd(aRotina,{"Alterar","AxAltera",0,4})
	aadd(aRotina,{"Excluir","U_PA4DEL",0,5})
Endif				 

If ( __cUserId $ cCodUsers)			
	aadd(aRotina,{"Iniciar OP","U_PA4OP('I')",0,4})
	aadd(aRotina,{"Terminar OP","U_PA4OP('T')",0,4} )
	aadd(aRotina,{"Etiquetas","U_PA4ETQ",0,2} )	
	aadd(aRotina,{"Reimpr. Etiqueta","U_PA4ETQ2",0,2} )		
Endif

alert("CADPA4 - 2019.11.12")

dbSelectArea("PA4")
dbSetOrder(1)

mBrowse( 6,1,22,75,"PA4",,"PA4_OP")

Return               


///////////////////////////////////////////////////////////////////////////////////////////////
//
// Atribui / Retira uma op da linha de produção
//
//
//////////////////////////////////////////////////////////////////////////////////////////////

User Function PA4OP(cOperacao)
Local cQry
Local lEof

Local aParambox := {}
aAdd(aParamBox,{1,"Ordem de Produção" 			,Space(11)   ,""		 ,"","SC2","", 60,.F.})	// MV_PAR01
	 

If cOperacao = 'I'  // Inclui OP na linha
   
   If !Empty(PA4->PA4_OP)
      MsgBox("Já existe OP nesta linha","Operação Inválida","ALERT")
      Return
   Endif                                                           
   
	If ParamBox(aParamBox,"OP na Linha",/*aRet*/,/*bOk*/,/*aButtons*/,.T.,,,,FUNNAME(),.F.,.F.)
   	
   	DbSelectArea("SC2")
   	DbSetOrder(1)
   	If DbSeek(xFilial("SC2") + MV_PAR01 )  
   	   If SC2->C2_TPOP = "F" .And. Empty(SC2->C2_DATRF) .and. SC2->C2_STATUS = "N"
   	   
   	      cQry := " SELECT PA4_COD,PA4_OP FROM " + RetSqlName("PA4")
   	      cQry += " WHERE D_E_L_E_T_ = '' AND PA4_FILIAL = '" + SC2->C2_FILIAL + "' AND PA4_OP = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + "'"

				If Select("TMP") > 0
				   TMP->(DbCloseArea())
				Endif

				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)

   	      lEof := TMP->(Eof())
   	      
   	      TMP->(DbCloseArea())
   	      
   	      If !lEof 
   	         MsgBox("Esta OP já está vinculada em outra linha","Operação Inválida","ALERT")
   	         Return
   	      Endif
   	      
	   	   If MsgBox("Confirma o início da OP na linha ?","Confirmação","YESNO")
	   	   
   			   RecLock("PA4",.F.)
   			   PA4->PA4_OP      := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
   	   		PA4->PA4_PRODUTO := SC2->C2_PRODUTO
	   	   	msunlock()
	   	   	
	   	   	RecLock("SC2",.F.)
	   	   	SC2->C2_XHRINI := Time()
	   	   	SC2->C2_XDTINI := Date()
	   	   	SC2->C2_XLINHA := PA4->PA4_COD
	   	   	msunlock()
	   	   	
	   	   Endif	
   	   Else
   	      MsgBox("Esta OP não pode ser usada na linha","OP Inválida","ALERT")
   	      Return
   	   Endif    
   	   
   	Endif
   	
	Endif

Else // Finaliza a OP na linha de produção

   If Empty(PA4->PA4_OP)
      MsgBox("Não existe OP nesta linha","Operação Inválida","ALERT")
      Return
   Endif                                                           

  	DbSelectArea("SC2")
  	DbSetOrder(1)
  	If DbSeek(xFilial("SC2") + PA4->PA4_OP )  
  	   If MsgBox("Confirma o fim da OP na linha ?","Confirmação","YESNO")
                  
		  	RecLock("SC2",.F.)
  			SC2->C2_XHRFIM  := Time()
		  	SC2->C2_XDTFIM  := Date()
  			SC2->C2_XLINHA  := ""
  			msunlock()

			RecLock("PA4",.F.)
   		PA4->PA4_OP      := ""
   		PA4->PA4_PRODUTO := ""
		   msunlock()
                                         
		Endif
   Endif
   
Endif 

DbSelectArea("PA4")
DbSetOrder(1)

Return



///////////////////////////////////////////////////////////////////////////////////////////////
//
// Exclui Linha de produção
//
//
//////////////////////////////////////////////////////////////////////////////////////////////

User Function PA4DEL

If !Empty(Alltrim(PA4->PA4_OP))
   Alert("Esta linha possui uma OP")
   Return
Endif
                                  
If MsgBox("Confirma a Exclusão da Linha "+PA4->PA4_COD+" ?","Exclusão","YESNO")
   RecLock("PA4",.F.)
   DbDelete()
   msunlock()
Endif        

Return


///////////////////////////////////////////////////////////////////////////////////////////////
//
// PA4ETQ
//
// Imprime etiquetas por linha de produção
//
//////////////////////////////////////////////////////////////////////////////////////////////

User Function PA4ETQ

Local nNumEtq
Local aParambox := {}
Local dDataEtq := Date()
Local cCodBar

MV_PAR01 := Space(2)
MV_PAR02 := 0                    
If Empty(PA4->PA4_OP)
   MsgBox("Não existe OP nesta linha","Operação Inválida","ALERT")
   Return
Endif                                                           

DbSelectArea("SC2")
DbSetOrder(1)
DbSeek(xFilial("SC2")+PA4->PA4_OP)

If SC2->C2_TPOP <> "F" .OR. !Empty(SC2->C2_DATRF) .or. SC2->C2_STATUS <> "N"
   MsgBox("Esta OP não está ativa.","Operação Inválida","ALERT")
   Return   
Endif

aAdd(aParamBox,{1,"Impressora"  		,MV_PAR01 	,""			,"ExistCpo('PA5')"	,"PA5"	,""	,50	,.T.})	// MV_PAR01
aAdd(aParamBox,{1,"Qtd.Etiquetas" 	,MV_PAR02	,"@E 999"	,"" 						,"   "	,""	,35	,.T.})	// MV_PAR02              
	 
If !ParamBox(aParamBox,"Parâmetros",/*aRet*/,/*bOk*/,/*aButtons*/,.T.,,,,"PA4ETQ",.T.,.T.)
   Return
Endif

DbSelectArea("SC2")
DbSetOrder(1)
DbSeek(xFilial("SC2")+PA4->PA4_OP)

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+SC2->C2_PRODUTO)

DbSelectArea("SB5")
DbSetOrder(1)
DbSeek(xFilial("SB5")+SC2->C2_PRODUTO)

PrepImp(MV_PAR01) // Prepara a impressora que será usada
                          
nNumEtq := GetMv( "MV_XETQNUM")

PutMV("MV_XETQNUM",nNumEtq + MV_PAR02)
   
For i:=0 to MV_PAR02-1
     
   cNumEtq := StrZero(nNumEtq,8)
   cDV1    := Modulo11(cNumEtq)
   
   cDV2    := Modulo11(SC2->C2_NUM)            
   cCodBar := cNumEtq + cDV1 + SC2->C2_NUM + cDV2
   
   Imprime(PA4->PA4_COD,cCodBar,dDataEtq)

   nNumEtq++
Next                      

// DA UM SALTO NA ETIQUETA PARA DESTACAR A PAGINA
MSCBBEGIN(1,4)                     
MSCBEND()
		
MSCBCLOSEPRINTER()    

MsgBox("Fim de Impressão","Etiqueta","INFO")

Return
  

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Prepimp
//
// Prepara a impressora que será utilizada
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////

Static Function PrepImp(cImp)
Local _cPorta
Local cPath
Local cBat

DbSelectArea("PA5")
DbSetOrder(1)
DbSeek(xFilial("PA5")+cImp)
    
cPath := Alltrim(GetSrvProfString("RootPath", ""))

If SubStr(cPath,len(cPath),1) <> "\"
   cPath+="\"
Endif

cBat := "NET USE LPT1 /DEL" + Chr(13) + Chr(10)
cBat += "NET USE LPT1 " + PA5->PA5_PATH
memowrite("\TERMICA.BAT",cBat)
WaitRunSrv(cPath+"TERMICA.BAT", .t., cPath)

_cPorta := "lpt1"  // Default
MSCBPRINTER("ZEBRA",_cPorta,,,.t.) 

MSCBCHKSTATUS(.F.)

// DA UM SALTO NA ETIQUETA ALINHAMENTO
MSCBBEGIN(1,4)                     
MSCBEND()

Return

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Imprime dados da etiqueta
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function Imprime(cLinha,cCodBar,dDataEtq)

	MSCBBEGIN(1,4)                     

	MSCBSAY(95,55,"LINHA "+cLinha,"R","C","040,040")  // fonte de 5mm x 5mm

	MSCBSAY(85,15,"OP:"+SC2->C2_NUM	,"R","C","035,035") 
	MSCBSAY(85,85,Dtoc(dDataEtq)		,"R","C","035,035") 

	MSCBSAY(70,5,SB1->B1_COD,"R","C","030,030")
	MSCBSAY(62,5,Substr(SB1->B1_DESC,01,30),"R","C","030,030")  
	MSCBSAY(57,5,Substr(SB1->B1_DESC,31,30),"R","C","030,030")
	
	MSCBSAY(40,5,"Industrial : L " + Alltrim(Str(SB5->B5_XINDLAS)) + "  x  A " + Alltrim(Str(SB5->B5_XINDALT))	, "R","C","030,020") 
	MSCBSAY(35,5,"PBR        : L " + Alltrim(Str(SB5->B5_XPLTLAS)) + "  x  A " + Alltrim(Str(SB5->B5_XPLTALT))	, "R","C","030,020") 
	                      
//	MSCBSAYBAR(30, 5, cCodBar ,"R","MB01",15,.F.,.F.,.F.,,4,3,,.F.,.F.,.F.)		// Padrao I2o5

	MSCBSAYBAR(10, 25, cCodBar ,"R","MB07",15,.F.,.F.,.F.,,4,3,,.F.,.F.,.F.)	// Padrao code 128	
   
	MSCBSAY(5,35,cCodBar,"R","A","032,035") 

	//MSCBSAY(5,5,"POSICAO 5,5","R","A","015,008")
	

	MSCBEND()           

Return

                            


///////////////////////////////////////////////////////////////////////////////////////////////
//
// PA4ETQ2
//
// Reimpressão de uma etiqueta individual
//
//////////////////////////////////////////////////////////////////////////////////////////////

User Function PA4ETQ2

Local aParambox := {}
Local dDataEtq
Local cCodBar                                   
Local cEtiqueta
Local cDV1
Local cDV2
Local cOP
Local cNumEtq
Local cLinha

MV_PAR01 := Space(2)
MV_PAR02 := Space(16)

aAdd(aParamBox,{1,"Impressora"  		,MV_PAR01 	,""	,"ExistCpo('PA5')"	,"PA5"	,""	,35	,.T.})	// MV_PAR01
aAdd(aParamBox,{1,"Cod.Etiqueta" 	,MV_PAR02	,"@"	,"" 						,"   "	,""	,60	,.T.})	// MV_PAR02              
	 
If !ParamBox(aParamBox,"Parâmetros",/*aRet*/,/*bOk*/,/*aButtons*/,.T.,,,,"PA4ETQ2",.T.,.T.)
   Return
Endif        

cEtiqueta := MV_PAR02
// cEtiqueta = 12345678 + 1 + 123456 + 1
//             Sequencial + dv + numero da op + dv
//             1 a 8        9    10 a 15        16
      
cDv1 := Modulo11(Substr(cEtiqueta,1,8))
cDv2 := Modulo11(Substr(cEtiqueta,10,6))
                  
If cDV1 <> Substr(cEtiqueta,9,1) .or. cDv2 <> Substr(cEtiqueta,16,1)
	MsgBox("Etiqueta Inválida","Etiqueta Inválida","ALERT")
	Return
Endif


cOp     := Substr(cEtiqueta,10,6)
cNumEtq := Substr(cEtiqueta,1,8)
		
cQry := " SELECT D3_OP,D3_EMISSAO,D3_XLINHA FROM " + RetSqlName("SD3")
cQry += " WHERE D_E_L_E_T_='' AND D3_ESTORNO <>'S' AND D3_CF='PR0' AND D3_XTRANSF<>'S' AND D3_FILIAL = '" + xFilial("SD3") + "' AND D3_XETIQ = '"  + cNumEtq + "' AND SUBSTRING(D3_OP,1,6)='" + cOp + "'"
	      
If Select("TMP") > 0
	TMP->(DbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)

cOp := TMP->D3_OP                
dDataEtq := Stod(TMP->D3_EMISSAO)
cLinha := TMP->D3_XLINHA

TMP->(DbCloseArea())

If Empty(cOp)
   MsgBox("Etiqueta inválida","Etiqueta inválida","ALERT")
   Return
Endif                                                   

DbSelectArea("SC2")
DbSetOrder(1)
DbSeek(xFilial("SC2")+cOP)

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+SC2->C2_PRODUTO)

DbSelectArea("SB5")
DbSetOrder(1)
DbSeek(xFilial("SB5")+SC2->C2_PRODUTO)

PrepImp(MV_PAR01) // Prepara a impressora que será usada
        
cDV1    := Modulo11(cNumEtq)   
cDV2    := Modulo11(SC2->C2_NUM)            
cCodBar := cNumEtq + cDV1 + SC2->C2_NUM + cDV2
   
Imprime(cLinha,cCodBar,dDataEtq)

// DA UM SALTO NA ETIQUETA PARA DESTACAR A PAGINA
MSCBBEGIN(1,4)                     
MSCBEND()
		
MSCBCLOSEPRINTER()    

MsgBox("Fim de Impressão","Etiqueta","INFO")

Return
