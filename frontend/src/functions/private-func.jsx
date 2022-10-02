// ?: Функция добавления или удаление пользователя из blacklist'а
export const funcPhaseControl = async (event, type, Contract, addressFrom) => {
  if(type === "start") {
    alert("Дождитесь выполнения...")
    try {
      await Contract.methods.startPrivatePhase().send({from: addressFrom})
      alert("Вы запустили Private фазу")
    } catch (e) {
      alert("Ошибка при вызове функции!")
      console.log(e)
    }
  } else if(type === "end") {
    alert("Дождитесь выполнения...")
    try {
      await Contract.methods.endPrivatePhase().send({from: addressFrom})
      alert("Вы остановили Private фазу")
    } catch (e) {
      alert("Ошибка при вызове функции!")
      console.log(e)
    }
  } else alert("Произошла непредвиденная ошибка!")
}