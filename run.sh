#!/bin/bash
#
# DiarioOficial.sh - Realiza o download dos arquivos PDFs do site do Diario Oficial do SP
#
# Autor: Aristides Neto (aritidesbneto@gmail.com)
# Criado em: 11/07/2018
#
# Descricao: Baixa os arquivos em pdf do site do diario oficial do estado de sao paulo do dia atual
# e unifica em um arquivo unico e disponibiliza para download. Salva em logs cada download realizado
# e as datas dos arquivos disponiveis.
#
# Requisitos: Necessario o pacote pdftk para juntar os pdfs em um unico arquivo
#

# Datas
DIA=$(date +%d)
MES=$(date +%m)
ANO=$(date +%Y)
DIA=23

# Caminhos de LOGs e da raiz do site
# LOG_DIARIO='/var/www/do.aristidesneto.com.br/web/logs/diario-oficial.txt'
# LOG_DATAS='/var/www/do.aristidesneto.com.br/web/logs/datas.txt'
# DIR_WWW='/var/www/do.aristidesneto.com.br/web'
DIR_TEMP='/tmp/diario'
# USER_DONO='usrc1_do'
# GROUP_DONO='client1'

# Caminhos para rodar localmente - ambiente de testes
LOG_DIARIO='/home/abneto/Dropbox/html/diariooficial/logs/diario-oficial.log'
LOG_DATAS='/home/abneto/Dropbox/html/diariooficial/logs/datas.txt'
DIR_WWW='/home/abneto/Dropbox/html/diariooficial'
USER_DONO='abneto'
GROUP_DONO='abneto'

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

if [ ! -d $DIR_TEMP ]; then
    mkdir /tmp/diario
    STATUS_DIR=" Diretorio TMP criado com sucesso -"
fi

cd $DIR_TEMP
clear
echo "Baixando arquivos. Aguarde..."
wget $URL/$ANO/$MES/$DIA/exec1/pdf/pg_0001.pdf 2> /dev/null

if [ $? -eq 0 ]; then

    # Busca da pagina 2 a 9
    for ((d=2;d<10;d++)) ; do
        wget $URL/$ANO/$MES/$DIA/exec1/pdf/pg_000$d.pdf 2> /dev/null
    done

    # Busca da pagina 10 a 99
    for ((d=10;d<100;d++)) ; do
        wget $URL/$ANO/$MES/$DIA/exec1/pdf/pg_00$d.pdf 2> /dev/null
        if [ $? -gt 0 ]; then
            break
        fi
    done

    # Busca da pagina 100 a 800
    for ((d=100;d<800;d++)) ; do
        wget $URL/$ANO/$MES/$DIA/exec1/pdf/pg_0$d.pdf 2> /dev/null
        if [ $? -gt 0 ]; then
            break
        fi
    done

    # Junta os arquivos um PDF único para download
    echo "Criando arquivo PDF. Aguarde..."
    pdftk pg_* output $DIR_WWW/files/do_caderno1_$DIA$MES$ANO.pdf

    echo "Finalizando o script..."
    if [ $? -eq 0 ]; then   
        # Pega o tamanho do arquivo gerado
        TAMANHO_ARQUIVO=$(du -h $DIR_WWW/files/do_caderno1_$DIA$MES$ANO.pdf |cut -f1)

        # Insere no arquivo datas.txt o registro da data do pdf baixado
        sed -i "1i $DIA/$(date +%m)/$ANO;Caderno Executivo 1;do_caderno1_$DIA$MES$ANO.pdf;$TAMANHO_ARQUIVO" $LOG_DATAS         

        # Atualiza o arquivo de LOG
        echo "[ $DATA ]$STATUS_DIR Arquivo baixado com sucesso" >> $LOG_DIARIO
        
        # Atualiza o arquivo de datas para manter apenas os 5 últimos registro de datas
        cat $LOG_DATAS | head -5 > $DIR_WWW/logs/arq.txt && mv $DIR_WWW/logs/arq.txt $LOG_DATAS

        # Apagando arquivo baixado (PDF) com datas antigas
        find $DIR_WWW/files/ -type f -mtime +6 |xargs rm -f

        # Setando permissao para o usuario usrc1_userdo
        chown -R $USER_DONO:$GROUP_DONO $DIR_WWW/logs/
        chown -R $USER_DONO:$GROUP_DONO $DIR_WWW/files/

        rm -f $DIR_TEMP/pg_*pdf
        echo "Finalizado."
    else
        echo "[ $DATA ] Erro ao executar o comando PDFTK" >> $LOG_DIARIO
    fi
    exit 0
else
    echo "[ $DATA ] Data sem publicação" >> $LOG_DIARIO
    exit 1
fi
