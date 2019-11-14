#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
                                                                                                 

//+-------------------------------------------------------------------------------------------------------------------------------+
//| PROGRAMA  | CFAPP02  | Smart Develop (WRC)                                                                       | 30/09/2019 |
//+-------------------------------------------------------------------------------------------------------------------------------+
//| DESCRIÇÃO | Interface de login para Transferência de Pallets                                             							 |
//|           | Retorna HTML com a interface de login para o app de Transferência de Pallets                                      |
//+-------------------------------------------------------------------------------------------------------------------------------+
//| HISTORICO DAS ALTERAÇÕES                                                     															    |
//+-------------------------------------------------------------------------------------------------------------------------------+
//| DATA     | AUTOR                | DESCRICAO                             																	    |
//+-------------------------------------------------------------------------------------------------------------------------------+
//|          |                      |                                           																 	 |
//+-------------------------------------------------------------------------------------------------------------------------------+

User Function CFAPP02(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)

Local cRet := ""
Local cArqTxt
Local nHdl
Local nTamFile
Local cQry              

Local cFil        := __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CFIL"}),2]

Local nPos


cArqTxt := "\APP-MENUS\LOGIN.HTML"
nHdl    := fOpen(cArqTxt,68)

nTamFile := fSeek(nHdl,0,2)
fSeek(nHdl,0,0)
cRet  := Space(99999)

fRead(nHdl,@cRet,99999) 
fClose(nHdl)

U_AppEnv(,,cFil)

cRet := StrTran(cRet,"XXXACTION",cSrvApp+"U_CFMENU02.APL")                                             
cRet := StrTran(cRet,"XXXLINHAS","")                                             
cRet := StrTran(cRet,"XXXFILIAL",cFil)                                             
cRet := StrTran(cRet,"XXXSERVER",cSrvApp)                                             
cRet := StrTran(cRet,"XXXNOMEFIL",SM0->M0_FILIAL)
cRet := StrTran(cRet,"XXXAPP"		,EncodeUtf8("Transferência"))

RPCClearEnv()


Return cRet



/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// CFMENU02 - Menu Interface de Transferência de Pallets
//
// Retorna HTML com a interface de Menu para o app de Transferência de Pallets
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////

User Function CFMenu02(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)

Local cRet := ""
Local cArqTxt
Local nHdl
Local nTamFile
Local cQry              

Local ddatausu
Local lliberado
Local ndiasVenc
Local dPrazoSenha

Local cApontUsers := ""

Local cLogin  :=  __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CUSER"}),2]
Local cPass   :=  __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CPASS"}),2]
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

cSrvApp  :=  __aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "CSERVER"}),2]
cBackAction := cSrvApp+"U_CFAPP02.APL?cFil="+cFil

cArqTxt := "\APP-MENUS\MENU.HTML"
nHdl    := fOpen(cArqTxt,68)

nTamFile := fSeek(nHdl,0,2)
fSeek(nHdl,0,0)
cRet  := Space(99999) // Variavel para criacao da linha do registro para leitura

fRead(nHdl,@cRet,99999) 
fClose(nHdl)

If !Empty(cLogin)

   cMsgErro := U_VldUser(cLogin,cPass,cFil,"MV_XTRUSER",cBackAction  )
   If cMsgErro <> ""
      Return cMsgErro
   Endif

Else
	Return U_RetMsg("Acesso Negado","Login inválido",cBackAction)
Endif	

cMenus := ""
cMenus += "<li class='menu-item'><a href='XXX_TRANSFERE'  target='frameunico' data_scroll>Transferência</a></li>"
cMenus := StrTran(cMenus,"XXX_TRANSFERE" ,cSrvApp+"U_CFTRANSF.APL?cOper=TRANSF&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt( cPass ,"SMARTDEV", .T.)+"&cSessao="+cNovaSessao+"&cServer="+cSrvApp )

cRet := StrTran(cRet,"XXX_INFO",cSrvApp+"U_CFINFO02.APL?cFil="+cFil+"&cUser="+cLogin+"&cNomeFil="+cNomeFil)
cRet := StrTran(cRet,"XXX_MENUS",cMenus)
cRet := StrTran(cRet,"XXX_SAIR",cSrvApp+"U_CFAPP02.APL?cFil="+cFil)
                                                                                                    
Return EncodeUTF8(cRet)



////////////////////////////////////////////////////////////////////////////////////////////////
//                    
// CFINFO02
//
// Retorna nformações referente à sessão logada na interface de Transferência de Pallets
//
////////////////////////////////////////////////////////////////////////////////////////////////
User Function CFINFO02(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)

Local	cLogin  :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CUSER"}),2]
Local	cFil    :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CFIL"}),2]
Local cNomeFil:=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CNOMEFIL"}),2]

Local cRet := ""

/*
U_AppEnv(,,cFil)

cNomeFil := SM0->M0_FILIAL 

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



/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// CFTRANSF
// - Interface de transferência de Pallets.   
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////

User Function CFTRANSF(__aCookies,__aPostParms,__nProcID,__aProcParms,__cHTTPPage)

Local cRet := ""
Local cArqTxt
Local nHdl
Local nTamFile

Local cProduto
Local nQuant                         
Local cEtiqueta
Local aVetor  
Local lEof
Local cDV1,cDV2
Local cBackAction        
Local nRecno
Local nD3Quant


Local cDocumen
Local	aItem  := {}
Local	aLinha := {}    
Local aAuto  :={}
Local cLocal

Local	cLogin  :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CUSER"}),2]
Local	cPass   :=  rc4crypt(__aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CPASS"}),2] ,"SMARTDEV", .F. , .T.)
Local	cFil    :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CFIL"}),2]

Local	cOper   :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "COPER"}),2]
// cOper = TRANSF  - Trata a transferência do Pallet

Local	cTpOper   :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CTPOPER"}),2]
// cTpOper = READ  - Retorna a interface de leitura de dados
// cTpOper = COMMIT - Chama a função de gravação de dados

cSrvApp :=  __aProcParms[aScan(__aProcParms, {|x| Upper(x[1]) = "CSERVER"}),2]

Private lMsErroAuto := .F.
        
If cOper = "TRANSF" 
   
   If cTpOper = "READ" // Retorna a interface de transferência
		
		cRet := FormTransf(cFil,cLogin,cPass)
		
	Elseif cTpOper = "COMMIT" // Chama a função de gravação da transferência
		
		cBackAction := cSrvApp+"U_CFTRANSF.APL?cOper=TRANSF&cTpOper=READ&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt(cPass,"SMARTDEV", .T.)+"&cServer="+cSrvApp 
      
      nQuant    := Val(__aPostParms[aScan(__aPostParms, {|x| Upper(x[1]) = "NQUANT"}),2])
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
      Elseif cDV1 <> Substr(cEtiqueta,9,1) .or. cDv2 <> Substr(cEtiqueta,16,1)
			cRet := U_RetMsg("Erro","Código da Etiqueta inválido",cBackAction)		               
      Else	
			cEtiqueta := Substr(cEtiqueta,1,8)
		
			U_AppEnv(cLogin,cPass,cFil)

   	   cQry := " SELECT R_E_C_N_O_ NUMREC,D3_QUANT FROM " + RetSqlName("SD3")
	      cQry += " WHERE D_E_L_E_T_='' AND D3_ESTORNO <>'S' AND D3_CF='PR0' AND D3_XTRANSF<>'S' AND D3_FILIAL = '" + cFil + "' AND D3_XETIQ = '"  + cEtiqueta + "'"
	      
			If Select("TMP") > 0
			   TMP->(DbCloseArea())
			Endif

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TMP", .F., .T.)
      
			lEof     := TMP->(Eof())
         nRecNo   := TMP->NUMREC
         nD3Quant := TMP->D3_QUANT
                             
		   TMP->(DbCloseArea())      
	      
	      If lEof
  				cRet := U_RetMsg("Reg.Inválido","Esta Etiqueta não é válida.",cBackAction)		      
	      ElseIf nD3Quant <> nQuant
  				cRet := U_RetMsg("Qtd.inválida","Qtd.digitada diferente da etiqueta.",cBackAction)
	      Else
  
   	
            DbSelectArea("SD3")
            DbGoTo(nRecno)              
                      
				lMsErroAuto := .F.
            
				aAuto  := {}
				aItem  := {}
				aLinha := {}
            
				
				//Cabecalho
				cDocumen := GetSxeNum("SD3","D3_DOC")
				aadd(aAuto,{cDocumen,Date()}) //Cabecalho

				DbSelectArea("SB1")
				DbSetOrder(1)
				SB1->(DbSeek(xFilial("SB1")+SD3->D3_COD)) 

				//cLocal := Alltrim(SuperGetMv( "MV_XLOCTR" , , "02"  ))  
				cLocal := SB1->B1_LOCPAD

				//Origem                     
				aadd(aLinha,{"ITEM"			, '001'				, Nil})
			   aadd(aLinha,{"D3_COD"		, SB1->B1_COD		, Nil}) //Cod Produto origem
   	 		aadd(aLinha,{"D3_DESCRI"	, SB1->B1_DESC		, Nil}) //descr produto origem
    			aadd(aLinha,{"D3_UM"			, SB1->B1_UM		, Nil}) //unidade medida origem
	    		aadd(aLinha,{"D3_LOCAL"		, SD3->D3_LOCAL	, Nil}) //armazem origem       
			   aadd(aLinha,{"D3_LOCALIZ"	, ''					, Nil}) //Informar endereço    	    		    
		    	//Destino
		  		aadd(aLinha,{"D3_COD"		, SB1->B1_COD		, Nil}) //cod produto destino
    			aadd(aLinha,{"D3_DESCRI"	, SB1->B1_DESC		, Nil}) //descr produto destino
    			aadd(aLinha,{"D3_UM"			, SB1->B1_UM		, Nil}) //unidade medida destino
    			aadd(aLinha,{"D3_LOCAL"		, cLocal				, Nil}) //armazem destino
			   aadd(aLinha,{"D3_LOCALIZ"	, ''					, Nil}) //Informar endereço
                                                               
                                                                                    
            //USO OBRIGATÓRIO
		    	aadd(aLinha,{"D3_NUMSERI"	, ""	, Nil}) //Numero serie
    			aadd(aLinha,{"D3_LOTECTL"	, ""	, Nil}) //Lote Origem
    			aadd(aLinha,{"D3_NUMLOTE"	, ""	, Nil}) //sublote origem
    			aadd(aLinha,{"D3_DTVALID"	, ""	, Nil}) //data validade
    			aadd(aLinha,{"D3_POTENCI"	, 0	, Nil}) // Potencia
    
    			aadd(aLinha,{"D3_QUANT"		, SD3->D3_QUANT	, Nil}) //Quantidade
                                                                 
            //USO OBRIGATÓRIO
            aadd(aLinha,{"D3_QTSEGUM"	, 0	, Nil}) //Seg unidade medida
    			aadd(aLinha,{"D3_ESTORNO"	, ""	, Nil}) //Estorno
    			aadd(aLinha,{"D3_NUMSEQ"	, ""	, Nil}) // Numero sequencia D3_NUMSEQ    
    			aadd(aLinha,{"D3_LOTECTL"	, ""	, Nil}) //Lote destino
    			aadd(aLinha,{"D3_NUMLOTE"	, ""	, Nil}) //sublote destino
    			aadd(aLinha,{"D3_DTVALID"	, ''	, Nil}) //validade lote destino
    			aadd(aLinha,{"D3_ITEMGRD"	, ""	, Nil}) //Item Grade    
    			aadd(aLinha,{"D3_CODLAN"	, ""	, Nil}) //cat83 prod origem
    			aadd(aLinha,{"D3_CODLAN"	, ""	, Nil}) //cat83 prod destino
    
				aAdd(aAuto,aLinha)
				MSExecAuto({|x,y| mata261(x,y)},aAuto,3)
                                               
				If lMsErroAuto                                                            
   				cErro := MostraErro()
					cRet := U_RetMsg("Erro ExecAuto","Erro na gravação da transferência.<br>"+cErro,cBackAction)	
				Else   
		         
		         DbSelectArea("SD3")
  		         DbGoTo(nRecno)              
      	      RecLock("SD3",.F.)
         	   SD3->D3_XTRANSF := "S"
            	msunlock()
  
					cRet := U_RetMsg("Gravação OK","Transferência gravada com Sucesso !",cBackAction)	
				Endif			 
				
	   	Endif
	   
		   RPCClearEnv()	   		
	   Endif    

   Endif   
   
Endif


Return cRet
           


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// FormTransf
// - Retorna a Interface HTML de Transferência de Pallet
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////

Static Function FormTransf(cFil,cLogin,cPass)

Local cOrdens
Local cRet  := Space(99999)

Local cArqTxt := "\APP-MENUS\TRANSF.HTML"
Local nHdl    := fOpen(cArqTxt,68)

Local nTamFile := fSeek(nHdl,0,2)
fSeek(nHdl,0,0)

fRead(nHdl,@cRet,99999) 
fClose(nHdl)


//  Carrega os dados das OPS em aberto no formulario

U_AppEnv(,,cFil)

cOrdens := u_OPSnaLinha(cFil)
cRet := StrTran(cRet,"XXXAORDENS",EncodeUtf8(cOrdens) )
	
RPCClearEnv()                            
                                                            
cRet := StrTran(cRet,"XXX_FILIAL",cFil)

cRet := StrTran(cRet,"XXXACTION" ,cSrvApp+"U_CFTRANSF.APL?cOper=TRANSF&cTpOper=COMMIT&cFil="+cFil+"&cUser="+cLogin+"&cPass="+rc4crypt(cPass,"SMARTDEV", .T.)+"&cServer="+cSrvApp )

Return cRet
