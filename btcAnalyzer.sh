#!/bin/bash

trap ctrl_c INT

function ctrl_c(){
	echo "\n[!] Saliendo..."
	rm ut.t* hashes.tmp 2>/dev/null
  exit 1 
}

#Variables globales
unconfirmed_transactions="https://www.blockchain.com/es/btc/unconfirmed-transactions"
inspect_transaction_url="https://www.blockchain.com/es/btc/tx/"
inspect_address_url="https://www.blockchain.com/es/btc/address/"

#Formato tabla hecho por s4vitar-https://github.com/s4vitar
function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

# Panel de ayuda
function helpPanel(){
	echo "[!] Uso ./btcAnalizer"
	for i in $(seq 1 80); do echo -n "-"; done;
  echo -e "\n\n [-e] Modo exploracion"
  echo -e "\t\t unconfirmed_transactions: \t Inspeccionar transacciones no confirmadas (max:55)"
  echo -e "\t\t inspect: \t\t\t Inspeccionar una transaccion"
  echo -e "\t\t address: \t\t\t Inspeccionar una direccion"
  echo -e "\n [-n] Limita las transacciones"
  echo -e "\n\n [-i] Identificador de la transaccion (Ejemplo: -i 88ebd2196e5a176088c1fde8cdb037e5eec6fb1fa36ca4d25573dd9dd1767b8f)"
  echo -e "\n\n [-a] Identificador de la direccion (Ejemplo: -a bc1qqqp53p2cls7aqe67564qv2llfvvjdtwrqu3jnu)"
  echo -e "\n\n [-h] Muestra este panel de ayuda"
}

function inspectAddress(){
	inspect_address=$1
  echo "Transacciones_Total recibido_Total enviado_Saldo final" > info_direccion.tmp

  while [[ "$(cat info_direccion.tmp | wc -l)" == "1" ]]; do
    curl -s "${inspect_address_url}${inspect_address}" | html2text | grep "Transacciones" -A 10 | grep "Transacciones" -B 10 | grep -vE "Total*|Saldo|Transacciones" | xargs | awk '{print $1 "_" $2 " " $3 "_" $4 " " $5 "_" $6 " " $7}' >> info_direccion.tmp
  done

  curl -s "${inspect_address_url}${inspect_address}" | html2text | grep "Transacciones" -A 10 | grep "Transacciones" -B 10 | grep "BTC" | sed "s/ BTC//g" > address_btc.tmp
  
  printTable "_" "$(cat info_direccion.tmp)"
  rm info_direccion* 2>/dev/null

  echo "Transacciones_Total recibido (USD)_Total enviado (USD)_Saldo final (USD)" > info_direccion_usd.table

  price_btc=$(curl -s "https://www.google.com/finance/quote/BTC-USD" | html2text | grep "Bitcoin" -A 1 | head -n 2 | grep -v "Bitcoin*" | tr -d ',') 

  curl -s "${inspect_address_url}${inspect_address}" | html2text | grep "Transacciones" -A 2 | grep "Transacciones" -B 3 | grep -vE "Trans*|\--|Total" > result.tmp

  curl -s "${inspect_address_url}${inspect_address}" | html2text | grep -E "Total recibido|Total enviado|Saldo final" -A 1 | grep -v -E "Total*|Saldo*" | sed "s/ BTC//" > btc_to_usd.tmp

  cat btc_to_usd.tmp | while read value; do
    echo "\$$(printf "%'.d\n" 2>/dev/null $(echo "$value*$price_btc" | bc ))" >> result.tmp
  done

  line_null=$(cat result.tmp | grep -n "^\$$" | awk '{print $1}' FS=":")

  if [[ $line_null ]]; then
    sed "${line_null}s/\$/0/" -i result.tmp
  fi

  cat result.tmp | xargs | tr ' ' '_' >> info_direccion_usd.table


  printTable "_" "$(cat info_direccion_usd.table)"
  rm info_direccion* btc_to_usd.tmp address_btc.tmp result.tmp 2>/dev/null
} 

function inspectTransaction(){
  inspect_transaction_hash=$1

	echo "Entrada Total_Salida Total" > total_entrada_salida.tmp


	while [[ "$(cat total_entrada_salida.tmp | wc -l)" == "1" ]]; do
		curl -s "${inspect_transaction_url}${inspect_transaction_hash}" | html2text | grep -E "Entradas totales|Gastos totales" -A 1 | grep -v -E "Entradas totales|Gastos totales" | xargs | tr ' ' '_' | sed 's/_BTC/ BTC/g' >> total_entrada_salida.tmp
	done

	printTable "_" "$( cat total_entrada_salida.tmp)"
	rm total_entrada_salida.tmp

	echo "Direcciones (Entradas)_Valor" > entradas_valor.tmp

	while [[ "$(cat entradas_valor.tmp | wc -l)" == "1" ]]; do
		curl -s "{$inspect_transaction_url}{$inspect_transaction_hash}" | html2text | grep "Entradas" -A 1000 | grep "Gastos" -B 1000 | grep "Direcc" -A 3 | grep -v -E "Direcc|Valor|\--" | awk 'NF%2{printf "%s ",$0;next;}1' | awk '{print $1 "_" $2 " " $3}' >> entradas_valor.tmp
	done

	printTable "_" "$(cat entradas_valor.tmp)"
	rm entradas_valor.tmp

  echo "Direcciones (Salidas)_Valor" > salidas_valor.tmp

	while [[ "$(cat salidas_valor.tmp | wc -l)" == "1" ]]; do
		curl -s "{$inspect_transaction_url}{$inspect_transaction_hash}" | html2text | grep -v "Gastos totales" | grep "Gastos" -A 1000 | grep "Direc" -A 3 | grep -vE "Direc|Valor|\--" | awk 'NR%2{printf "%s ",$0;next;}1' | awk '{print $1 "_" $2 " " $3 }' >> salidas_valor.tmp
	done

	printTable "_" "$(cat salidas_valor.tmp)"
	rm salidas_valor.tmp
}

function unconfirmedTransactions(){
  number_output=$1

  echo '' > ut.tmp

  #obtiene los datos
  while [ "$(cat ut.tmp | wc -l)" == "1" ]; do
    curl -s "$unconfirmed_transactions" | html2text > ut.tmp
  done
  
  hashes=$(cat ut.tmp | grep "Hash" -A 1 | grep -v -E "Hash|\--|Tiempo" | head -n $number_output)
  
  echo "Hash_Cantidad_Bitcoin_Tiempo" > ut.table

	echo $hashes > hashes.tmp
  
	#Preparamos los datos para la tabla, es decir hash_cantidad_bitcoin_tiempo
  for hash in $hashes; do
    echo "${hash}_USD \$$(cat ut.tmp | grep "$hash" -A 6 | tail -n 1 | sed 's/Â//g' | tr -d "US" | sed "s/,/-/g" | sed "s/\./,/g" | sed "s/-/./g" | tr -d "$")_$(cat ut.tmp | grep "$hash" -A 4 | tail -n 1)_$(cat ut.tmp | grep "$hash" -A 2 | tail -n 1)" >> ut.table
  done 

	for hash_for_money in $hashes; do
    echo "$(cat ut.tmp | grep "$hash_for_money" -A 6 | tail -n 1 | sed 's/Â//g' | tr -d "US$" | sed 's/\.*,*//g')" >> premoney.tmp
	done

  money=0; cat premoney.tmp | while read money_one_line; do
    let money_clean=${money_one_line::-3}
    let money+=$money_clean 2>/dev/null
    echo $money > money.tmp
  done
  
  if [ "cat ut.table | wc -l" != 1 ]; then
    echo -n "Cantidad Total_" > mount.table
    mount="$(cat money.tmp)"
    echo "USD \$$(printf "%'.d\n" 2>/dev/null $mount.00)" >> mount.table
    printTable '_' "$(cat ut.table)"
    printTable '_' "$(cat mount.table)"
    rm ut.t* money* mount.table hashes.tmp premoney.tmp 2>/dev/null
  else
    rm ut.t* money* mount.table hashes.tmp premoney.tmp 2>/dev/null
  fi

}  

# Argumentos
param_count=0; while getopts "e:n:i:a:h:" arg; do
	case $arg in 
		e)exploration_mode=$OPTARG; let param_count+=1;;
    n)number_output=$OPTARG; let param_count+=1;;
    i)inspect_transaction=$OPTARG; let param_count+=1;;
		a)inspect_address=$OPTARG; let param_count+=1;;
		h)helpPanel;;
	esac
done

if [[ param_count -eq 0 ]]; then
  helpPanel
else
  if [[ $(echo $exploration_mode) == "unconfirmed_transactions" ]]; then
    if [[ ! "$number_output" ]]; then
      number_output=100
      unconfirmedTransactions $number_output
    else
      unconfirmedTransactions $number_output
    fi
  elif [[ $(echo $exploration_mode) == "inspect" ]]; then
    inspectTransaction $inspect_transaction
  
  elif [[ $(echo $exploration_mode) == "address" ]]; then
    inspectAddress $inspect_address
  fi
fi

