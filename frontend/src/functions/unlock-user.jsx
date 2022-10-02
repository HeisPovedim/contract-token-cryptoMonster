export const unlockUser = async (event, web3, password, address) => {
  try {
    await web3.eth.personal.unlockAccount(address, password, 0)
    alert("Вы разблокировали аккаунт")
  } catch (e) {
    alert("Ошибка при вызове функции!")
    console.log(e)
  }
}