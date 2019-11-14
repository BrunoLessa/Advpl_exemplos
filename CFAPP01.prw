#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

//+-------------------------------------------------------------------------------------------------------------------------------+
//| PROGRAMA  | CFAPP01  | Smart Develop (WRC)                                                                       | 30/09/2019 |
//+-------------------------------------------------------------------------------------------------------------------------------+
//| DESCRIÇÃO | Interface de login para apontamento de produção                                              							 |
//|           | Retorna HTML com a interface de login para o app de apontamento de produção                                       |
//+-------------------------------------------------------------------------------------------------------------------------------+
//| HISTORICO DAS ALTERAÇÕES                                                     															    |
//+-------------------------------------------------------------------------------------------------------------------------------+
//| DATA     | AUTOR                | DESCRICAO                             																	    |
//+-------------------------------------------------------------------------------------------------------------------------------+
//|          |                      |                                           																 	 |
//+-------------------------------------------------------------------------------------------------------------------------------+

User Function CFAPP01(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)

Local cRet := ""
Local cArqTxt
Local nHdl
Local nTamFile
Local cQry              
Local cLinhas     := ""                                       
Local cComboLinha := ""

Local cFil        := __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CFIL"}),2]
Local cNomeFil    := ""
Local cParamLinha := ""

Local nPos

nPos := aScan(__aProcParms, {|x| Upper(x[1]) = "CLINHA"})
If nPos > 0
	cParamLinha := __aProcParms[npos,2]
Endif

cArqTxt := "\APP-MENUS\LOGIN.HTML"
nHdl    := fOpen(cArqTxt,68)

nTamFile := fSeek(nHdl,0,2)
fSeek(nHdl,0,0)
cRet  := Space(99999)

fRead(nHdl,@cRet,99999) 
fClose(nHdl)

        
// Abre o Environment
U_AppEnv(,,cFil)                                                    
cNomeFil := SM0->M0_FILIAL                                                                   
RPCClearEnv() 

/*

ESTE TRECHO FOI COLOCADO EM COMENTÁRIO PORQUE A LINHA DEIXOU DE SER PARTE DO LOGIN

cQry := " SELECT PA4_COD,PA4_DESC FROM " + RetSqlName("PA4")
cQry += " WHERE D_E_L_E_T_ = '' AND PA4_FILIAL = '" + cFil +  "'"
cQry += "       AND PA4_OP <> ''"

If cParamLinha <> ""
   cQry += " AND PA4_COD = '" + cParamLinha + "'"   
Endif
cQry += " ORDER BY PA4_COD"

If Select("TMP") > 0
   TMP->(DbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)

While !TMP->(Eof())

	cLinhas += '<option value="' + TMP->PA4_COD + '">' + TMP->PA4_DESC + '</option>'
   TMP->(DbSkip())
End

TMP->(DbCloseArea())                                                                                                    



If cLinhas =""
   Return U_RetMsg("Acesso Negado","Não há linha de produção com OP ativa.")
Endif


cComboLinha := "<tr height='50px'>"
cComboLinha += "  <td align='right' >Linha : </td>"
cComboLinha += "  <td>"
cComboLinha += "	   <select id='gets' name='clinha' >"
cComboLinha += cLinhas
cComboLinha += "		</select>"
cComboLinha += "	</td>"
cComboLinha += "</tr>"
*/
	
cRet := StrTran(cRet,"XXXACTION"	,cSrvApp+"U_CFMENU01.APL")                                             
cRet := StrTran(cRet,"XXXLINHAS"	,cComboLinha)                                             
cRet := StrTran(cRet,"XXXFILIAL"	,cFil)                                             
cRet := StrTran(cRet,"XXXNOMEFIL",cNomeFil)                                             
cRet := StrTran(cRet,"XXXSERVER"	,cSrvApp)                                             
cRet := StrTran(cRet,"XXXAPP"		,"Apontamento")                                             


Return cRet



/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// CFMENU01 - Interface do Menu do apontamento de produção
//
// Retorna HTML com a interface de menu para o app de apontamento de produção
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////

User Function CFMenu01(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)

Local cRet := ""
Local cArqTxt
Local nHdl
Local nTamFile
Local cQry              

Local cMsgErro := ""

Local cLogin  :=  __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CUSER"}),2]
Local cPass   :=  __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CPASS"}),2]

Local cLinha  := ""
// TRATAMENTO DA LINHA COMENTADO APÓS TER SIDO RETIRADO DO LOGIN   // Local cLinha  :=  __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CLINHA"}),2]
Local cSessao :=  __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CSESSAO"}),2]  
Local cFil    :=  __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CFIL"}),2]
Local cNomeFil:=  __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CNOMEFIL"}),2]

Local cHoraAtual   := Alltrim(Str(Val(Substr(Time(),1,2))*60 + Val(Substr(Time(),4,2))))
Local cNovaSessao := DtoS(Date()) + cHoraAtual

Local cBackAction

If cSessao <> "01" 
	
	cSessao := Substr(cSessao,1,8) + Alltrim(Str(Val(Substr(cSessao,9,99))+60))   // Valida se já passou 1 hora da abertura da sessão original
   
   If cNovaSessao > cSessao   
   
	   Return U_RetMsg("Sessão Expirada","Por favor, efetue o login novamente.")
	   
	Endif
	   
Endif 

/*
COMENTADO APOS A LINHA TER SIDO RETIRADA DO LOGIN
If Empty(cLinha)
   
	Return U_RetMsg("Acesso Negado","Não há linha de produção ativa.")
	   
Endif
*/

cArqTxt := "\APP-MENUS\MENU.HTML"
nHdl    := fOpen(cArqTxt,68)

nTamFile := fSeek(nHdl,0,2)
fSeek(nHdl,0,0)
cRet  := Space(99999) // Variavel para criacao da linha do registro para leitura

fRead(nHdl,@cRet,99999) 
fClose(nHdl)

cSrvApp  :=  __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CSERVER"}),2]
cBackAction := cSrvApp+"U_CFAPP01.APL?cFil="+cFil

If !Empty(cLogin)
   
   cMsgErro := U_VldUser(cLogin,cPass,cFil,"MV_XAPUSER",cBackAction  )
   If cMsgErro <> ""
      Return cMsgErro
   Endif
                                                                              
Else
	Return U_RetMsg("Acesso Negado","Login inválido")
Endif	

cMenus := ""
cMenus += "<li class='menu-item'><a href='XXX_APONTA'  target='frameunico' data_scroll>Apontamento</a></li>"
cMenus += "<li class='menu-item'><a href='XXX_ESTORNO' target='frameunico' data_scroll>Estorno</a></li>"          
cMenus := StrTran(cMenus,"XXX_APONTA" ,cSrvApp+"U_CFPROD.APL?cOper=APONTA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cSessao="+cNovaSessao+"&cServer="+cSrvApp )
cMenus := StrTran(cMenus,"XXX_ESTORNO",cSrvApp+"U_CFPROD.APL?cOper=ESTORNA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cSessao="+cNovaSessao+"&cServer="+cSrvApp )


cRet := StrTran(cRet,"XXX_INFO",cSrvApp+"U_CFINFO01.APL?cFil="+cFil+"&cLinha="+cLinha+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cSessao="+cNovaSessao+"&cNomeFil="+cNomeFil )
cRet := StrTran(cRet,"XXX_MENUS",cMenus)
cRet := StrTran(cRet,"XXX_SAIR",cSrvApp+"U_CFAPP01.APL?cFil="+cFil)
                                                                                                    
Return Encodeutf8(cRet)
                                                                         


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// CFPROD 
// - Interface de apontamento de produção.   A função é chamada várias vezes e o retorno é de
//   acordo com os parâmetros cOper e cTpOper
//
// Trata os processos de apontamento de OP e respectivo estorno 
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////

User Function CFPROD(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)

Local cRet := ""
Local cArqTxt
Local nHdl
Local nTamFile

Local cOrdem
Local cProduto
Local nQuant                         
Local cTM
Local cEtiqueta
Local aVetor  
Local lEof
Local cDV1,cDV2
Local cBackAction        
Local nRecno                                     
Local aReg


Local cOp
Local cNumEtq   
Local cLinOp
Local	cLogin  :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CUSER"}),2]  
Local	cPass   :=  rc4crypt(__aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CPASS"}),2]  ,"SMARTDEV", .F., .T.)
Local	cLinha  :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CLINHA"}),2]
Local	cFil    :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CFIL"}),2]

Local	cOper   :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "COPER"}),2]
// cOper = APONTA  - Trata o apontamento da produção
// cOper = ESTORNA - Trata o estorno do apontamento da produção

Local	cTpOper   :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CTPOPER"}),2]
// cTpOper = READ  - Retorna a interface de leitura de dados
// cTpOper = COMMIT - Chama a função de gravação de dados


cSrvApp :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CSERVER"}),2]

Private lMsErroAuto := .F.
        
If cOper = "APONTA" 
   
   If cTpOper = "READ" // Retorna a interface de apontamento
		
		cRet := FormAponta(cFil,cLinha,cLogin,cPass)
		
	Elseif cTpOper = "COMMIT" // Chama a função de gravação do apontamento
		
		cBackAction := cSrvApp+"U_CFPROD.APL?cOper=APONTA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp 
      
      nQuant    := Val(__aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "NQUANT"}),2])
      cOrdem    := __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CORDEM"}),2]
      cProduto  := __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CPRODUTO"}),2]      
      cEtiqueta := __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CETIQUETA"}),2]            
      // cEtiqueta = 12345678 + 1 + 123456 + 1
      //             Sequencial + dv + numero da op + dv
      //             1 a 8        9    10 a 15        16
           
      cDv1 := Modulo11(Substr(cEtiqueta,1,8))
      cDv2 := Modulo11(Substr(cEtiqueta,10,6))
                  
      If nQuant = 0
	      cRet := U_RetMsg("Campo Obrigatório","Quantidade inválida",cBackAction)	
      Elseif Empty(cEtiqueta)
	      cRet := U_RetMsg("Campo Obrigatório","Etiqueta inválida",cBackAction)	      
// esta crítica foi retirada porque a linha nao está no login      ElseIf Substr(cEtiqueta,10,6) <> Substr(cOrdem,1,6) 
//	                                                       	cRet := U_RetMsg("Erro","Esta etiqueta não pertente à OP configurada.",cBackAction)		         

      Elseif cDV1 <> Substr(cEtiqueta,9,1) .or. cDv2 <> Substr(cEtiqueta,16,1)
			cRet := U_RetMsg("Erro","Código da Etiqueta inválido",cBackAction)		               
      Else                                                                                        
      
        	cOp     := Substr(cEtiqueta,10,6)
			cNumEtq := Substr(cEtiqueta,1,8)

		
			U_AppEnv(cLogin,cPass,cFil)

   	   cQry := " SELECT D3_XETIQ FROM " + RetSqlName("SD3")
	      cQry += " WHERE D_E_L_E_T_='' AND D3_FILIAL = '" + cFil + "' AND D3_XETIQ = '"  + cNumEtq + "'"
	      
			If Select("TMP") > 0
			   TMP->(DbCloseArea())
			Endif

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)
      
			lEof := TMP->(Eof())
                             
		   TMP->(DbCloseArea())      
	   
	   	If lEof
              
            // não havendo a linha no login ignora o cOrdem já preenchido e pega o numero completo com a query abaixo
				cQry := " SELECT C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,PA4_COD FROM " + RetSqlName("SC2") + " SC2 "
				cQry += " INNER JOIN " + RetSqlName("PA4") + " PA4 ON (PA4.D_E_L_E_T_='' AND PA4_FILIAL = '" + cFil + "'"
				cQry += "                                               AND C2_FILIAL + C2_NUM + C2_ITEM + C2_SEQUEN = PA4_FILIAL + PA4_OP)"
				cQry += " WHERE SC2.D_E_L_E_T_ = '' AND SC2.C2_FILIAL = '" + cFil + "' AND C2_NUM = '" + cOp + "'"

				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)

            cOrdem   := TMP->(C2_NUM +C2_ITEM + C2_SEQUEN)        
            cProduto := TMP->C2_PRODUTO                                 
            cLinOp   := TMP->PA4_COD
            
            TMP->(DbCloseArea())
            
            If Empty(Alltrim(cOrdem))
					cRet := U_RetMsg("Etiqueta Inválida","Esta OP não está em nenhuma linha.",cBackAction)	            
            Else
					lMsErroAuto := .F.
			      cTM         := Alltrim(SuperGetMv( "MV_XTMPRO" , , "010"  ))  

					aVetor := {}

					aVetor := { {"D3_FILIAL" 	,cFil 				,NIL},;
									{"D3_OP" 		,cOrdem 				,NIL},;
									{"D3_COD" 		,cProduto			,NIL},;
									{"D3_QUANT" 	,nQuant				,NIL},; 
									{"D3_PARCTOT" 	,"P"	 				,NIL},;
								 	{"D3_TM" 		,cTM 		  			,NIL},;
							 		{"D3_EMISSAO"	,Date()	  			,NIL},;							 	
								 	{"D3_XHORA"		,Time()	  			,NIL},;							 	
								 	{"D3_XLINHA"	,cLinOp	  			,NIL},;							 									 	
							 		{"D3_XETIQ" 	,cNumEtq 			,NIL}		} 
 
					MSExecAuto({|x, y| mata250(x, y)},aVetor, 3 )

					If lMsErroAuto              
						cErro := MostraErro()
						cRet := U_RetMsg("Erro ExecAuto","Erro na gravação do apontamento.<br>"+cErro,cBackAction)	
					Else
						cRet := U_RetMsg("Gravação OK","Apontamento Gravado com Sucesso !",cBackAction)	
					Endif
				Endif
		   Else 
				cRet := U_RetMsg("Duplicidade","Etiqueta já utilizada.",cBackAction)		   
	   	Endif
	   
		   RPCClearEnv()	   		
	   
	   Endif    

   Endif
   
ElseIf cOper = "ESTORNA" 
   
   If cTpOper = "READ" // Retorna a interface de estorno de apontamentos

		cRet := FormEstorna(cFil,cLinha,cLogin,cPass)
   
   ElseIf cTpOper = "COMMIT"
      
      nRecno := Val(__aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "NRECNO"}),2])
      
		U_AppEnv(cLogin,cPass,cFil)

	   DbSelectArea("SD3")                       
	   DbSetOrder(1)
	   SD3->(DbGoTo(nRecno))          
	   cOp    := SD3->D3_OP
	   cCod   := SD3->D3_COD
	   cLocal := SD3->D3_LOCAL
	   nQuant := SD3->D3_QUANT

      DbSelectArea("SC2")
      DbSetOrder(1)
      If !DbSeek(cFil+cOp)
			cRet := U_RetMsg("Erro","Op Não Encontrada",cSrvApp+"U_CFPROD.APL?cOper=ESTORNA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp)	      
		Elseif SC2->C2_TPOP <> "F" .or. !Empty(SC2->C2_DATRF) .or. SC2->C2_STATUS <> "N"	
			cRet := U_RetMsg("Erro","Op inválida para apontamento",cSrvApp+"U_CFPROD.APL?cOper=ESTORNA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp)	      		
	   ElseIf SD3->D3_ESTORNO = 'S'
			cRet := U_RetMsg("Erro","Estorno já realizado !",cSrvApp+"U_CFPROD.APL?cOper=ESTORNA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp)	      
      ElseIf SD3->D3_XTRANSF = 'S'
			cRet := U_RetMsg("Erro","Etiqueta já transferida !",cSrvApp+"U_CFPROD.APL?cOper=ESTORNA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp)	      
      Else
                  
	  	   DbSelectArea("SD3")                       
		   DbSetOrder(1)
	   	SD3->(DbGoTo(nRecno))          
       
	   	RecLock("SD3",.F.)         
         SD3->D3_ESTORNO := "S"
         MsUnlock()
         aReg := {}
	   	For i:=1 to FCount()
	   	   aadd(aReg,FieldGet(i))
	   	Next      
	   	
         RecLock("SD3",.T.)                         
         For i:=1 to FCount()
             FieldPut(i,aReg[i])
         Next
         SD3->D3_CF  := "ER0"
         SD3->D3_TM  := "999"
         msunlock()
         
         DbSelectArea("SC2")
         RecLock("SC2",.F.)
         SC2->C2_QUJE := SC2->C2_QUJE - nQuant
         MsUnlock()
         
         DbSelectArea("SB2")
         DbSetOrder(1)
         If DbSeek(cFil+cCod+cLocal)
            RecLock("SB2",.F.)
            SB2->B2_QATU  :=  SB2->B2_QATU - nQuant
            SB2->B2_VATU1 :=  SB2->B2_VATU1 - (nQuant * SB2->B2_CM1)
            MsUnlock()
         Endif
         
			cRet := U_RetMsg("Gravação OK","Estorno Gravado com Sucesso !",cSrvApp+"U_CFPROD.APL?cOper=ESTORNA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp)	
                
                   
 	    //    EXECAUTO DO ESTORNO
   	 //    O PADRAO ESTA PEGANDO APENAS O 1O REGISTRO DE APONTAMENTO AO INVÉS DO REGISTRO PONTEIRADO
   	     		   
  		   /*
   	   DbSelectArea("SD3")  
   	   DbSetOrder(1)  
  		   SD3->(DbGoTo(nRecno))   	     
  		   
	     // aVetor := { {"D3_FILIAL" 	,SD3->D3_FILIAL	,NIL},; 
   	  // 				{"D3_COD" 		,SD3->D3_COD		,NIL},;   
        //				{"D3_LOCAL" 	,SD3->D3_LOCAL		,NIL},;         				
        //				{"D3_NUMSEQ" 	,SD3->D3_NUMSEQ	,NIL},;         				
		  //	 	      {"D3_OP" 		,SD3->D3_OP 		,NIL},;  
        //				{"D3_QUANT" 	,SD3->D3_QUANT		,NIL},;   
        //				{"D3_PARCTOT" 	,SD3->D3_PARCTOT	,NIL},;        				
        //				{"ESTORNO"     ,SD3->(D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ), NIL},;
	     // 				{"D3_TM" 		,SD3->D3_TM			,NIL}}    
       
         
			aVetor := { ;
						{"D3_OP"    ,cOp    ,NIL},;
						{"D3_QUANT" ,nQuant ,NIL},;
						{"D3_TM"    ,cTM    ,NIL};
				   }
        		   
			lMsErroAuto := .F.		
			MSExecAuto({|x, y| mata250(x, y)},aVetor, 5 )
	  
			If lMsErroAuto
			   cErro := MostraErro()
				cRet := U_RetMsg("Erro ExecAuto"," Erro na gravação do estorno."+cErro,cSrvApp+"U_CFPROD.APL?cOper=ESTORNA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp)	
            //	cRet := U_RetMsg("Erro ExecAuto","Recno Antes " + Str(nRecno) + "<br> Recno Depois " + Str(SD3->(Recno())),cSrvApp+"U_CFPROD.APL?cOper=ESTORNA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp)	
				
			Else               
				cRet := U_RetMsg("Gravação OK","Estorno Gravado com Sucesso !",cSrvApp+"U_CFPROD.APL?cOper=ESTORNA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp)	
			Endif	   	      
			
         */
         	      
	   Endif
	   
	   RPCClearEnv()	   		
	      
   Endif
   
Endif


Return cRet
           

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// FormEstorna        
//
// - Retorna a Interface HTML para estorno de apontamento de produção. 
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////

Static Function FormEstorna(cFil,cLinha,cLogin,cPass)

Local cRet := ""
Local cQry
Local cAction

U_AppEnv(,,cFil)

cAction := cSrvApp+"U_CFPROD.APL?cOper=ESTORNA&cTpOper=COMMIT&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp+"&nRecno=" 

cRet += "<div Style='Align:center;text-align:center;'>"                     
cRet += "<font face='Verdana' color='#2A3752'> "
cRet += "<h3>Estorno de Produção</h3>"
cRet += "<table Style='border-collapse: collapse;border: 1px solid black;text-align:center;width:100%'> "
cRet += "<tr Style='font-size:110%;border: 1px solid black;height:40px;'>"
cRet += "<td Style=''> </td>"                      
cRet += "<td Style='font-weight: bold;text-align:center;'>Data /<br>Hora</td>"
cRet += "<td Style='font-weight: bold;text-align:center;'>Ord.Produção /<br>Etiqueta</td>"
cRet += "<td Style='font-weight: bold;text-align:center;'>Quant.</td>"
cRet += "</tr>"

cQry := " SELECT SD3.R_E_C_N_O_ NUMREC,D3_XETIQ,D3_XHORA,D3_QUANT,D3_EMISSAO,D3_OP,D3_USERLGI FROM " + RetSqlName("SD3") + " SD3"
cQry += " INNER JOIN " + RetSqlName("PA4")+ " PA4 ON (PA4.D_E_L_E_T_ = '' AND PA4_FILIAL = D3_FILIAL AND PA4_OP = D3_OP)" // AND PA4_COD = '" + clinha + "')" 
cQry += " WHERE SD3.D_E_L_E_T_ = '' AND D3_FILIAL = '" + cFil+ "' AND D3_ESTORNO <> 'S' AND D3_CF='PR0' AND D3_XETIQ <> '' AND D3_XTRANSF<>'S' "

If Select("TMP") > 0
	TMP->(DbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)

While !TMP->(Eof())          

   DbSelectArea("SD3")
   SD3->(DbGoTo(TMP->NUMREC))   

   If Alltrim(cLogin) =  Alltrim(FWLeUserlg("D3_USERLGI",1)) 
		cRet += "<tr Style='border: 1px solid black;height:50px;'>"
		cRet += "<td><a href='" + cAction + Alltrim(Str(TMP->NUMREC)) + "' onclick='return confirm("+  '"' + "Confirma a Exclusão?" +  '"'  + ")'><img src='excluir.jpg' Style='width:40px;'></a></td>"
		cRet += "<td Style='text-align:center;'>" + Dtoc(Stod(TMP->D3_EMISSAO)) + "<br>" + TMP->D3_XHORA + "</td>"
		cRet += "<td Style='text-align:center;'>" + Substr(TMP->D3_OP,1,6) + "<br>" + TMP->D3_XETIQ + "</td>"
		cRet += "<td Style='text-align:center;'>" + Str(TMP->D3_QUANT) + "</td>"
		cRet += "</tr>"
   Endif
	TMP->(DbSkip())

End

cRet+="</table>"

cRet+="</font>"
cRet+="</div>"
cRet+="<br><br><br>"
cRet+="<br><br><br>"

TMP->(DbCloseArea())

RPCClearEnv()

Return EncodeUtf8(cRet)



/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// FormAponta 
// - Retorna a Interface HTML de apontamento de produção. 
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////

Static Function FormAponta(cFil,cLinha,cLogin,cPass)


Local cRet  := Space(99999)
Local cOrdens := ""

Local cArqTxt := "\APP-MENUS\PROD.HTML"
Local nHdl    := fOpen(cArqTxt,68)
Local nTamFile := fSeek(nHdl,0,2)

fSeek(nHdl,0,0)
fRead(nHdl,@cRet,99999) 
fClose(nHdl)

/*                                                            
TRECHO COMENTADO APOS A LINHA TER SIDO RETIRADA DO LOGIN

U_AppEnv(,,cFil)

cQry := " SELECT C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_QUANT,C2_QUJE,PA4_DESC,B1_DESC FROM " + RetSqlName("SC2") + " SC2 "
cQry += " INNER JOIN " + RetSqlName("PA4") + " PA4 ON (PA4.D_E_L_E_T_='' AND PA4_FILIAL = '" + cFil + "' AND PA4_COD = '" + cLinha + "'"
cQry += "                                               AND C2_FILIAL + C2_NUM + C2_ITEM + C2_SEQUEN = PA4_FILIAL + PA4_OP)"
cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON (SB1.D_E_L_E_T_='' AND B1_FILIAL = '" + cFil + "' AND B1_COD = C2_PRODUTO)"
cQry += " WHERE SC2.D_E_L_E_T_ = '' AND SC2.C2_FILIAL = '" + cFil + "'"

If Select("TMP") > 0
   TMP->(DbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)


cRet := StrTran(cRet,"XXX_ORDEM",TMP->C2_NUM+TMP->C2_ITEM+TMP->C2_SEQUEN )
cRet := StrTran(cRet,"XXX_OP",TMP->C2_NUM )
cRet := StrTran(cRet,"XXX_PRODUTO",TMP->C2_PRODUTO)
cRet := StrTran(cRet,"XXX_DESCPROD",TMP->B1_DESC)
cRet := StrTran(cRet,"XXX_LINHA",cLinha)

TMP->(DbCloseArea())

RPCClearEnv() 
*/



//  Carrega os dados das OPS em aberto no formulario

U_AppEnv(,,cFil)

cOrdens := u_OPSnaLinha(cFil)
cRet := StrTran(cRet,"XXXAORDENS",EncodeUtf8(cOrdens) )
	
RPCClearEnv()                            


cRet := StrTran(cRet,"XXX_FILIAL",cFil)

cRet := StrTran(cRet,"XXXACTION" ,cSrvApp+"U_CFPROD.APL?cOper=APONTA&cTpOper=COMMIT&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp )

Return cRet



////////////////////////////////////////////////////////////////////////////////////////////////
//
//  CFINFO001
// 
// Retorna informações referente à linha de produção logada 
// Chamada do Menu Principal de Apontamento de Produção
//
////////////////////////////////////////////////////////////////////////////////////////////////
User Function CFINFO01(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)

Local cQry

Local	cLogin   :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CUSER"}),2]
Local	cLinha   :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CLINHA"}),2]
Local	cFil     :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CFIL"}),2]
Local cNomeFil :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CNOMEFIL"}),2]

Local cRet := ""

/*
ESSE TRECHO ERA USADO PARA RETORNAR OS DADOS DA OP DA LINHA DE PRODUCAO
FOI DESABILITADO QUANDO A LINHA SAIU DO LOGIN
U_AppEnv(,,cFil)

cRet := Retinfo(cLinha,cFil,cLogin)

RPCClearEnv() 
*/

cRet += "  <div style='background-color:#F0FFF0;text-align:center;padding-top:5px;padding-bottom:5px;'>"
cRet += "    <h2>Filial : " + cNomeFil + "<br>"
cRet += "        Usuário : " + cLogin + "<br>"
cRet += "    </h2>"
cRet += "   </div>"
cRet += "<br>"                
cRet += "<br>"                
cRet := EncodeUtf8(cRet)

Return cRet
                                          

Static Function Retinfo(cLinha,cFil,cLogin)

Local cOp
Local cProduto
Local nQuant
Local nQuje
Local cDescLin
Local cDescProd           
Local cNomeFil
Local cRet := ""

cQry := " SELECT C2_NUM,C2_PRODUTO,C2_QUANT,C2_QUJE,PA4_DESC,B1_DESC FROM " + RetSqlName("SC2") + " SC2 "
cQry += " INNER JOIN " + RetSqlName("PA4") + " PA4 ON (PA4.D_E_L_E_T_='' AND PA4_FILIAL = '" + cFil + "' AND PA4_COD = '" + cLinha + "'"
cQry += "                                               AND C2_FILIAL + C2_NUM + C2_ITEM + C2_SEQUEN = PA4_FILIAL + PA4_OP)"
cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON (SB1.D_E_L_E_T_='' AND B1_FILIAL = '" + cFil + "' AND B1_COD = C2_PRODUTO)"
cQry += " WHERE SC2.D_E_L_E_T_ = '' AND SC2.C2_FILIAL = '" + cFil + "'"

If Select("TMP") > 0
   TMP->(DbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)

cOp      := TMP->C2_NUM
cProduto := TMP->C2_PRODUTO
nQuant   := TMP->C2_QUANT
nQuje    := TMP->C2_QUJE
cDescLin := TMP->PA4_DESC
cDescProd:= TMP->B1_DESC                    
cNomeFil := SM0->M0_FILIAL 

TMP->(DbCloseArea())

cRet += "<div style='background-color:#F0FFF0;text-align:center;padding-top:5px;padding-bottom:5px;'  >"
cRet += "<h2>Filial : " + cNomeFil + "<br>"
cRet += "Usuário : " + cLogin + "<br>"
cRet += cDescLin + "</h2>"
cRet += "</div>"

cRet += "<div style='background-color:white;text-align:center;padding-top:5px;padding-bottom:5px;'>"
cRet += "<h2>Ordem de Produção<br>"
cRet += cOp + "</h2>"
cRet += "</div>"

cRet += "<div style='background-color:#F0FFF0;text-align:center;padding-top:5px;padding-bottom:5px;'>"
cRet += "<h2>Produto<br>"
cRet += cProduto + "<br>"
cRet += cDescProd + "</h2>"
cRet+="</div>"

cRet += "<div style='background-color:white;text-align:center;padding-top:5px;padding-bottom:5px;'>"
cRet += "<h2>Qtd.Prevista<br>"
cRet += Str(nQuant,0) + "</h2>"
cRet += "</div>"                                           

cRet += "<div style='background-color:#F0FFF0;text-align:center;padding-top:5px;padding-bottom:5px;'>"
cRet += "<h2>Qtd.Apontada<br>"
cRet += Str(nQuje,0) + "</h2>"
cRet+="</div>"                

cRet+="<br>"                
cRet+="<br>"                

/*
cRet+="<div Style='position:relative;  bottom:0; width:100%;text-align:center;padding-top:10px'>"
cRet+="<img src='logo.jpg' height=35px ></img>"
cRet+="</div>"
*/       

Return EncodeUtf8(cRet)
              





///////////////////////////////////////////////////////////////////////////
//
// Retorna um padrão HTML de mensagens 
//
///////////////////////////////////////////////////////////////////////////
User Function RetMsg(cCab,cMsg,cAction)
Local cRet := ""      

Default cAction := "javascript:history.go(-1)"

cRet += "<html>"
cRet += "<html lang='pt-br'>"
cRet += "<meta charset='utf-8'>"
cRet += "<body >"
cRet += "<div Style='width:80%;margin-top:15%;margin-left:10%;border-style:groove;padding:1px;'>"
cRet += "  <div Style='text-align:center;background-color:#333833;color:white;padding:2px;float:none;'><h2>" + cCab + "</h2></div>"
cRet += "  <br>"
cRet += "  <div Style='text-align:center;background-color:white;color:black;padding:2px;'><h2>" + cMsg + "</h2></div>""
cRet += "  <br>"
cRet += "</div>"                                           
cRet += "<br>"
cRet += "<br>"                                        
cRet += "<div Style='Width:100%;align:center;text-align:center'>"                                             
cRet += "<span Style='font-size:35px;background-color:#DCDCDC;padding:8px;'><a Style='text-decoration:none;color: inherit;' href='" + cAction + "' >Voltar</a></span>"
//cRet += "<span Style='font-size:40px;background-color:#DCDCDC;' onclick='" + cAction + "'>Voltar</span>"
cRet += "</div>"                                           
cRet += "</body>"
cRet += "</html>"

Return EncodeUtf8(cRet)




///////////////////////////////////////////////////////////////////////////
//
// Executa a abertura do Environment
//
///////////////////////////////////////////////////////////////////////////
User Function AppEnv(cLogin,cPass,cFil)

DEFAULT cLogin := ""
DEFAULT cPass  := ""

If cLogin <> ""
	
	//RPCSetType(3)     
	RPCSetEnv("01",cFil,cLogin,cPass)   
	
Else                                   
	RPCSetEnv("01",cFil)   
Endif	

Public cSrvApp := Alltrim(SuperGetMv( "MV_XAPPSRV" , , "http://localhost:80/"  ))  
      
Return .T.



//////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// VldUser                                                                            
//
// Valida os dados de login
// Retorna "" se Validou Usuário e Senha ou retorna a mensagem de erro em formato HTML
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////

User Function VldUser(cLogin,cPass,cFil,cParametro,cBackAction)

Local ddatausu
Local lliberado
Local ndiasVenc
Local dPrazoSenha                             
Local cCodUsers
   
PswOrder(2) // Pesquisa pelo Nome do Usuário
If PswSeek( cLogin, .T. ) .and. PswName(cPass)

	ddatausu  := PSWRET(1)[1,6] // Data de validade 
   lliberado := !PSWRET(1)[1,17] .and. !PSWRET(1)[1,9]                       	      
     
   If (ddatausu = Ctod("") .or. ddatausu >= Date()) .and. lliberado

      ndiasVenc   := PSWRET(1)[1,7] // Número de dias de validade da senha
      dPrazoSenha := PSWRET(1)[1,16] + ndiasVenc  // Data da última troca + número de dias de validade da senha
		If ndiasVenc <> 0 
         If dPrazosenha <= Date()
	         Return U_RetMsg("Senha Expirada","Para trocar sua senha acesse o Protheus.",cBackAction)
			Endif   
		Endif                         
	             	 	   
	Else                                                 
	 	   
 	   Return U_RetMsg("Acesso Negado","Senha Expirada / Usuário Bloqueado.<br>Entre em contato com a TI.",cBackAction)
    	 	
  	Endif   

	U_AppEnv(cLogin,cPass,cFil)

   cCodUsers := Alltrim(SuperGetMv( cParametro , , "000000;"  )) 				
   
	RPCClearEnv() 

	If !( __cUserId $ cCodUsers)
		Return U_RetMsg("Acesso Negado","Usuário sem permissão para este aplicativo.",cBackAction)		
	Endif
		
Else

   Return U_RetMsg("Acesso Negado","Usuário/Senha Inválidos",cBackAction)

Endif     

Return ""




//////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// DadosOrdens
//
// Retorna os dados das ordens de produções ativas no formato de vetor para o formulario html
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////


User Function OPSnaLinha(cFil)

Local cQry
Local cOrdens := ""

cQry := " SELECT PA4_OP,B1_COD,B1_DESC,B5_XINDLAS,B5_XINDALT,B5_XPLTLAS,B5_XPLTALT FROM " + RetSqlName("PA4") + " PA4 "
cQry += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON (SB1.D_E_L_E_T_='' AND B1_FILIAL = '" + cFil + "' AND B1_COD = PA4_PRODUT)"
cQry += " INNER JOIN " + RetSqlName("SB5") + " SB5 ON (SB5.D_E_L_E_T_='' AND B5_FILIAL = '" + cFil + "' AND B5_COD = PA4_PRODUT)"
cQry += " WHERE PA4.D_E_L_E_T_ = '' AND PA4.PA4_FILIAL = '" + cFil + "' AND PA4_OP <> ''"

If Select("TMP") > 0
   TMP->(DbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)

cOrdens := "["
While !TMP->(Eof())
   cOrdens += "['" + Substr(TMP->PA4_OP,1,6) + "'," + ;
                    "'<b>OP</b><BR>" + Substr(TMP->PA4_OP,1,6) + "<BR><BR>" + ;
                    "<b>Produto</b><BR>" +TMP->B1_COD + "<BR>" + ;
						  TMP->B1_DESC + "<BR><BR>" +;
						  "<b>Padrão</b><BR>" +;
						  "Ind. : L " + Str(TMP->B5_XINDLAS) + " x A " + Str(TMP->B5_XINDALT) + "&nbsp;&nbsp; / &nbsp;&nbsp;" + ;
						  "PBR. : L " + Str(TMP->B5_XPLTLAS) + " x A " + Str(TMP->B5_XPLTALT) + "']"
	TMP->(DbSkip())    
	If !TMP->(Eof())
	   cOrdens += ","
	Endif	
End            

cOrdens += "]"

TMP->(DbCloseArea())
Return cOrdens







Static Function tst_est
		   /*
		   
		   FORÇA A FUNÇÃO INTERNA DO ESTORNO
		    
		   Pergunte("MTA250",.F.)     
	   	   
		   Private dDataFec := MVUlmes()
	   	Private l250Auto := .T.
		   Private aRotAuto := aVetor
		   Private cCusMed  := GetMv("MV_CUSMED")
	   	Private lProdAut := GetMv("MV_PRODAUT")
			Private lPerdInf    := SuperGetMV("MV_PERDINF",.F.,.F.)	   
		
		   A250Estorn("SD3",nRecno,5)
			cRet := U_RetMsg("Gravação OK","Estorno Gravado com Sucesso !",cSrvApp+"U_CFPROD.APL?cOper=ESTORNA&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cLinha="+cLinha+"&cServer="+cSrvApp )		   
				
	      */          				
Return
