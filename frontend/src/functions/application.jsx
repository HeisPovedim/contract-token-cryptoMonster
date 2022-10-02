export const funcApplication = async (Contract, address, login, contact) => {
  try {
    await Contract.methods.application(login, contact, address).send({from: address})
    alert("Вы подали заявку.")
  } catch (e) {
    alert("Ошибка при вызове функции!")
    console.log(e)
  }
}