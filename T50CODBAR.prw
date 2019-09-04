#Include "TOTVS.ch"
#Include "TBICONN.ch"              

#define DMPAPER_LETTER      1           /* Letter 8 1/2 x 11 in               */
#define DMPAPER_LETTERSMALL 2           /* Letter Small 8 1/2 x 11 in        */
#define DMPAPER_TABLOID     3           /* Tabloid 11 x 17 in                 */
#define DMPAPER_LEDGER      4           /* Ledger 17 x 11 in                  */
#define DMPAPER_LEGAL       5           /* Legal 8 1/2 x 14 in               */
#define DMPAPER_STATEMENT   6           /* Statement 5 1/2 x 8 1/2 in        */
#define DMPAPER_EXECUTIVE   7           /* Executive 7 1/4 x 10 1/2 in        */
#define DMPAPER_A3          8           /* A3 297 x 420 mm                    */
#define DMPAPER_A4          9           /* A4 210 x 297 mm                    */
#define DMPAPER_A4SMALL     10          /* A4 Small 210 x 297 mm              */
#define DMPAPER_A5          11          /* A5 148 x 210 mm                    */
#define DMPAPER_B4          12          /* B4 250 x 354                      */
#define DMPAPER_B5          13          /* B5 182 x 257 mm                    */
#define DMPAPER_FOLIO       14          /* Folio 8 1/2 x 13 in               */
#define DMPAPER_QUARTO      15          /* Quarto 215 x 275 mm               */
#define DMPAPER_10X14       16          /* 10x14 in                           */
#define DMPAPER_11X17       17          /* 11x17 in                           */
#define DMPAPER_NOTE        18          /* Note 8 1/2 x 11 in                 */
#define DMPAPER_ENV_9       19          /* Envelope #9 3 7/8 x 8 7/8          */
#define DMPAPER_ENV_10      20          /* Envelope #10 4 1/8 x 9 1/2        */
#define DMPAPER_ENV_11      21          /* Envelope #11 4 1/2 x 10 3/8        */
#define DMPAPER_ENV_12      22          /* Envelope #12 4 \276 x 11           */
#define DMPAPER_ENV_14      23          /* Envelope #14 5 x 11 1/2            */
#define DMPAPER_CSHEET      24          /* C size sheet                      */
#define DMPAPER_DSHEET      25          /* D size sheet                      */
#define DMPAPER_ESHEET      26          /* E size sheet                      */
#define DMPAPER_ENV_DL      27          /* Envelope DL 110 x 220mm            */
#define DMPAPER_ENV_C5      28          /* Envelope C5 162 x 229 mm           */
#define DMPAPER_ENV_C3      29          /* Envelope C3 324 x 458 mm          */
#define DMPAPER_ENV_C4      30          /* Envelope C4 229 x 324 mm          */
#define DMPAPER_ENV_C6      31          /* Envelope C6 114 x 162 mm          */
#define DMPAPER_ENV_C65     32          /* Envelope C65 114 x 229 mm          */
#define DMPAPER_ENV_B4      33          /* Envelope B4 250 x 353 mm          */
#define DMPAPER_ENV_B5      34          /* Envelope B5 176 x 250 mm          */
#define DMPAPER_ENV_B6      35          /* Envelope B6 176 x 125 mm          */
#define DMPAPER_ENV_ITALY   36          /* Envelope 110 x 230 mm              */
#define DMPAPER_ENV_MONARCH 37          /* Envelope Monarch 3.875 x 7.5 in    */
#define DMPAPER_ENV_PERSONAL 38        /* 6 3/4 Envelope 3 5/8 x 6 1/2 in    */
#define DMPAPER_FANFOLD_US 39          /* US Std Fanfold 14 7/8 x 11 in      */
#define DMPAPER_FANFOLD_STD_GERMAN 40 /* German Std Fanfold 8 1/2 x 12 in   */
#define DMPAPER_FANFOLD_LGL_GERMAN 41 /* German Legal Fanfold 8 1/2 x 13 in */

User Function T50CODBAR(aConteudo,lEtqMst)
	Local oRelat
	Local cTitulo 	  := ''
	Local nLinha      := 070 // Linha InItemcial em Pixels
	Local nColuna     := 050 // Coluna InItemcial em Pixels
	Local oFont08	  := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
	Local cCodBarr    := ''
	Default aConteudo := {}	
	Default lEtqMst   := .F.
	
	If Len(aConteudo) = 0 
		MsgAlert('Não há conteudo a ser impresso','Atenção!!!')
		return          
	EndIf 

	__RelDir := WSPLRelDir()
	oRelat 	 := TMSPrinter():New( cTitulo )
	oRelat:SetLandScape()	
	oRelat:setPaperSize(16)
	oRelat:StartPage()  
	
	For nI := 1 To Len(aConteudo)
		oRelat:Say(nLinha, nColuna, "Emissão:", oFont08) 
		oRelat:Say(nLinha, nColuna+100, dToc(aConteudo[nI][1]), oFont08)
			/*
			+------------------------------------------------------------------+
			| Parametros do MSBAR                                              |
			+------------------------------------------------------------------+
			| 01 cTypeBar String com o tipo do codigo de barras               |
			|    "EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128"                    |
			|    "INT25","MAT25,"IND25","CODABAR","CODE3_9"                    |
			| 02 nRow           Numero da Linha em centimentros               |
			| 03 nCol           Numero da coluna em centimentros               |
			| 04 cCode          String com o conteudo do codigo               |
			| 05 oPr            Objeto Printer                                 |
			| 06 lcheck        Se calcula o digito de controle               |
			| 07 Cor            Numero da Cor, utilize a "common.ch"           |
			| 08 lHort          Se imprime na Horizontal                      |
			| 09 nWidth        Numero do Tamanho da barra em centimetros      |
			| 10 nHeigth        Numero da Altura da barra em milimetros        |
			| 11 lBanner        Se imprime o linha em baixo do codigo          |
			| 12 cFont          String com o tipo de fonte                     |
			| 13 cMode          String com o modo do codigo de barras CODE128 |
			+------------------------------------------------------------------+
			*/ 
		cCodBarr :=  aConteudo[nI][2]+aConteudo[nI][3]+aConteudo[nI][4]+aConteudo[nI][5]+aConteudo[nI][6]+cValtochar(aConteudo[nI][7])			
		MSBAR('CODE128',1.4,1.0,alltrim(cCodBarr),oRelat,.F.,,.T.,0.080,5.6,,,,.F.)    
    	oRelat:EndPage()	
  	Next nI
	
	oRelat:IsPrinterActive()
	oRelat:print() 
	freeObj( oRelat )
	
Return (NIL)