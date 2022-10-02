export const createNewUser = async (event, Contract, web3, login, password, accounts) => {
  try {
    const address = await web3.eth.personal.newAccount(password)
    await web3.eth.personal.unlockAccount(address, password, 0)
    const protectPassword = await web3.utils.keccak256(password)
    await Contract.methods.createUser(address, login, protectPassword).send({from: accounts[0]})
    await web3.eth.sendTransaction({from: accounts[0], to: address, value: 1000000000000000000})
    alert("Аккаунт создан, адрес:\n" + address)
  } catch (e) {
    alert("Ошибка при вызове функции!")
    console.log(e)
  }
}