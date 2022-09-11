Так как в Solidity импортировать файлы можно только по иерархической структуре, то в данном контракте
представлена такая иерархия:
──structures.sol
  └──modifireFunc.sol
     └──helpresFunc.sol
        └──validateFuncs.sol
           ├──CryptoMonster.sol
           ├──PhasePrivate.sol
           └──PhaseSeed.sol