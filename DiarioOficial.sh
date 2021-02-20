#!/bin/bash

# ######################################################################################################
# DiarioOficial.sh - Realiza o download dos arquivos PDFs do site do Diario Oficial do SP
#
# AUTOR: Aristides Neto (aritidesbneto@gmail.com)
# CRIADO EM: 11/07/2018
#
# DESCRICAO: Baixa os arquivos em pdf do site do diario oficial do estado de sao paulo do dia atual
# e unifica em um arquivo unico e disponibiliza para download. Salva em logs cada download realizado
# e as datas dos arquivos disponiveis.
#
# REQUISITOS: Necessario o pacote pdftk para juntar os pdfs em um unico arquivo
# ######################################################################################################

# Datas
DIA=$(date +%d)
MES=$(date +%m)
ANO=$(date +%Y)
# DIA=14

# Diretorio WWW
DIR_WWW='/var/www/do.aristidesneto.com.br/web'

# Caminhos de LOGs e da raiz do site
LOG_DIARIO=$DIR_WWW'/logs/diario-oficial.log'
LOG_DATAS=$DIR_WWW'/logs/datas.txt'
DIR_WWW=$DIR_WWW

# Caminhos para rodar localmente - ambiente de testes
LOG_DIARIO='/home/abneto/Dropbox/html/diariooficial/logs/diario-oficial.log'
LOG_DATAS='/home/abneto/Dropbox/html/diariooficial/logs/datas.txt'
DIR_WWW='/home/abneto/Dropbox/html/diariooficial'

DIR_TEMP='/tmp/diario'

# URL do site do Diario Oficial
URL='http://diariooficial.imprensaoficial.com.br/doflash/prototipo'

case $MES in
	01) MES="janeiro" ;;
	02) MES="fevereiro" ;;
	03) MES="marco" ;;
	04) MES="abril" ;;
	05) MES="maio" ;;
	06) MES="junho" ;;
	07) MES="julho" ;;
	08) MES="agosto" ;;
	09) MES="setembro" ;;
	10) MES="outubro" ;;
	11) MES="novembro" ;;
	12) MES="dezembro" ;;
esac

# Data atual do sistema
DATA="$DIA $MES de $ANO $(date +%H:%M:%S)"

# Entra no diretorio temp a baixa apenas a primeira pagina
# Se sucesso continua a baixar o restantes de paginas
# Caso contrario salva no log que nao existe paginas para o dia
cd $DIR_TEMP
wget $URL/$ANO/$MES/$DIA/exec1/pdf/pg_0001.pdf

if [ $? -eq 0 ]; then

	# Busca da pagina 2 a 9
	for ((d=2;d<10;d++)) ; do
		wget $URL/$ANO/$MES/$DIA/exec1/pdf/pg_000$d.pdf
	done

	# Busca da pagina 10 a 99
	for ((d=10;d<100;d++)) ; do
		wget $URL/$ANO/$MES/$DIA/exec1/pdf/pg_00$d.pdf
		if [ $? -gt 0 ]; then
			break
		fi
	done

	# Busca da pagina 100 a 800
	for ((d=100;d<800;d++)) ; do
		wget $URL/$ANO/$MES/$DIA/exec1/pdf/pg_0$d.pdf
		if [ $? -gt 0 ]; then
			break
		fi
	done

	# Junta os arquivos um PDF único para download
	pdftk pg_* output $DIR_WWW/files/do_caderno1_$DIA$MES$ANO.pdf

	if [ $? -eq 0 ]; then	
		# Pega o tamanho do arquivo gerado
		TAMANHO_ARQUIVO=$(du -h $DIR_WWW/files/do_caderno1_$DIA$MES$ANO.pdf |cut -f1)

		echo "$DIA/$MES/$ANO;Caderno Executivo 1;do_caderno1_$DIA$MES$ANO.pdf;$TAMANHO_ARQUIVO" >> $LOG_DATAS
		echo "[ $DATA ] Arquivo baixado com sucesso" >> $LOG_DIARIO

		# Organiza o arquivo de log em ordem descrescente
		cat $LOG_DATAS |sort -r > $DIR_WWW/logs/arqtmp.txt
		mv $DIR_WWW/logs/arqtmp.txt $LOG_DATAS

		rm -f $DIR_TEMP/pg_*pdf
	else
		echo "[ $DATA ] Erro ao executar o comando PDFTK" >> $LOG_DIARIO
	fi
	
	exit 0
else
	echo "[ $DATA ] Data sem publicação" >> $LOG_DIARIO
	exit 1
fi
