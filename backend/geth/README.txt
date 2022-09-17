Все команды, относящиеся к пути, должны быть настроены сугубо под вас !!!

Готовые команды для быстро пуска, наладки и отладки системы:
1. Создание нового аккаунта:
	geth account new --datadir C:\Users\Admin\Documents\GitHub\contract-token-cryptoMonster\backend\geth\config.json
2. Инициализая цепочки:
	geth --datadir C:\Users\Admin\Documents\GitHub\contract-token-cryptoMonster\backend\geth init C:\Users\Admin\Documents\GitHub\contract-token-cryptoMonster\backend\geth\config.json
3. Основная консоль GETH:
	geth.exe --http --http.addr "127.0.0.1" --http.api "eth, miner, net, web3, admin, personal, contract" --networkid 15 --datadir C:\Users\Admin\Documents\GitHub\contract-token-cryptoMonster\backend\geth --allow-insecure-unlock --http.corsdomain "*" console
4. Вторичная консоль без мусора:
	geth attach "http://127.0.0.1:8545"