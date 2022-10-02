// ?: Функция остановки и запуска Private фазы
export const funcBlackList = async (event, type, address, addressFrom, Contract) => {
  if(type === "add") {
    console.log("Who: " + address)
    console.log("From: " + addressFrom)
    alert("Дождитесь выполнения...")
    try {
      await Contract.methods.addBlackList(address).send({from: addressFrom})
      alert("Вы добавили пользователя в blacklist")
    } catch(e) {
      alert("Ошибка при вызове функции!")
      console.log(e)
    }
  } else if(type === "remove") {
    console.log("Who: " + address)
    console.log("From: " + addressFrom)
    alert("Дождитесь выполнения...")
    try {
      await Contract.methods.removeBlackList(address).send({from: addressFrom})
      alert("Вы удалили пользователя из blacklist")
    } catch(e) {
      alert("Ошибка при вызове функции!")
      console.log(e)
    }
  } else alert("Произошла непредвиденная ошибка!")
}