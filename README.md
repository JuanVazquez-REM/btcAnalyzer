# btcAnalyzer
Herramienta para inspección de transacciones de Bitcoins.

## Requisitos previos
Para hacer uso de la herramienta debes de instalar las siguientes utilidades:
``` bash
apt install html2text bc 
```
Una vez instalas ya puedes hacer uso de la herramienta.

## Uso
Tras ejecutar la herramienta, se muestra un panel de ayuda, en el cual se encuentran 3 modos de exploración.
``` bash
❯ ./btcAnalyzer.sh
[!] Uso ./btcAnalizer
--------------------------------------------------------------------------------

 [-e] Modo exploracion
		unconfirmed_transactions: 	Inspeccionar transacciones no confirmadas (max:55)
		inspect: 			Inspeccionar una transaccion
		address: 			Inspeccionar una direccion

 [-n] Limita las transacciones


 [-i] Identificador de la transaccion (Ejemplo: -i 88ebd2196e5a176088c1fde8cdb037e5eec6fb1fa36ca4d25573dd9dd1767b8f)


 [-a] Identificador de la direccion (Ejemplo: -a bc1qqqp53p2cls7aqe67564qv2llfvvjdtwrqu3jnu)


 [-h] Muestra este panel de ayuda
                                    
```
Que son los siguientes:

1. Unconfirmed Transactions
2. Inspect
3. Address

La primera opción nos permite listar las ultimas transacciones que se realizaron junto con la
cantidad total de dinero, con el parametro **-e** y **unconfirmed_transactions**, ahora con el 
parametro **-n** podemos indicar la cantidad de transacciones que deseamos visualizar.
``` bash
❯ ./btcAnalyzer.sh -e unconfirmed_transactions -n 5
  +                                                                   +                   +                  +         +
  | Hash                                                              | Cantidad          | Bitcoin          | Tiempo  |
  +                                                                   +                   +                  +         +
  | c883e14c940108755c2c71c2fd2293b84c6791fa24084808635cbb1d436e7ed2  | USD $2222.02      | 0.11466498 BTC   | 03:32   |
  | cee96166255fd85dc8d9af5d367962d49d08af4da9d08f98c0b32a931e93e196  | USD $300.98       | 0.01553173 BTC   | 03:32   |
  | 0e5371527ebd814589413e42c5c055ed50482f12b0a20071967560846af7c24e  | USD $110,961.42   | 5.72604805 BTC   | 03:32   |
  | cf37b6ea607737ed8d126bc009f6a2b59f1b217fd0a6c08fc14641c54f94f53b  | USD $187,917.56   | 9.69728939 BTC   | 03:32   |
  | 0c3b707ff44a63418dde2808e9e0ef2298db26b765bc10d71871ba1f42d7821b  | USD $212,111.87   | 10.94581115 BTC  | 03:32   |
  +                                                                   +                   +                  +         +
  +                 +               +
  | Cantidad Total  | USD $513 511  |
  +                 +               +
                                           
```

La segunda opción, como su nombre indica inspecciona una transacción, con el parametro **-e** y **inspect**,
ahora con el parametro **-i** indicamos el identificador de la transaccion(HASH), esto mostrara como resultado
la entrada total y salida total en BTC, al igual que las direcciones de entrada y salida.
``` bash
❯ ./btcAnalyzer.sh -e inspect -i 0c3b707ff44a63418dde2808e9e0ef2298db26b765bc10d71871ba1f42d7821b
  +                  +                  +
  | Entrada Total    | Salida Total     |
  +                  +                  +
  | 10.94587635 BTC  | 10.94581115 BTC  |
  +                  +                  +
  +                                     +                  +
  | Direcciones (Entradas)              | Valor            |
  +                                     +                  +
  | 1GrwDkr33gT6LuumniYjKEGjTLhsL5kmqC  | 10.94587635 BTC  |
  +                                     +                  +
  +                                             +                  +
  | Direcciones (Salidas)                       | Valor            |
  +                                             +                  +
  | 1D8eMEzkcnC21roF3xyUqCMHT5QWWt47zs          | 0.06897491 BTC   |
  | 3KDoa3jUUJSdrJ9LXzkT6GpRz8xPAWjwkr          | 0.00241200 BTC   |
  | bc1qxy80slvtuk8ew5099j2gmlj5f54t380ct4u3sc  | 0.00179500 BTC   |
  | 1GrwDkr33gT6LuumniYjKEGjTLhsL5kmqC          | 10.87262924 BTC  |
  +                                             +                  +
```

Por ultimo la tercera opción nos permite inspeccionar una dirección, indicando el parametro **-e** y **address**,
al igual que el parametro **-a** y la dirección, con esto podremos visualizar información como la cantidad 
de transacciones, total recibido, total enviado y saldo final, las cantidad se muestran en Bitcoins(BTC)
y dolares(USD).
``` bash
❯ ./btcAnalyzer.sh -e address -a 1GrwDkr33gT6LuumniYjKEGjTLhsL5kmqC
  +                +                      +                      +                    +
  | Transacciones  | Total recibido       | Total enviado        | Saldo final        |
  +                +                      +                      +                    +
  | 71.496         | 926144.05745748 BTC  | 923286.74718000 BTC  | 2857.31027748 BTC  |
  +                +                      +                      +                    +
  +                +                       +                      +                    +
  | Transacciones  | Total recibido (USD)  | Total enviado (USD)  | Saldo final (USD)  |
  +                +                       +                      +                    +
  | 71.496         | $17 925 888 689       | $17 870 584 306      | $55 304 383        |
  +                +                       +                      +                    +
```


