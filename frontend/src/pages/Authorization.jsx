// #: REACT
import React, { useState, useEffect } from 'react'

// #: COMPONENTS && FUNCTIONS
  // - COMPONENTS
    import { UseContext } from '../contract/context';
  // - FUNCTIONS
    import { unlockUser } from '../functions/unlock-user';
    import { createNewUser } from '../functions/create-new-user';
    import { funcBlackList } from '../functions/owner-func';
    import { funcPhaseControl } from '../functions/private-func';
    import { funcApplication } from '../functions/application';

const Authorization = () => {

  // ^: STATES
  const {web3, Contract} = UseContext()
  const [accounts, setAccounts] = useState([]) // общее список пользовтелей в системе
  const [address, setAddress] = useState() // текущий выбранный адрес
  const [applicationsAmountAdr, setApplicationsAmountAdr] = useState([]) // список подающих заявки
  const [newAccount, setNewAccount] = useState({
    login: "",
    password: Number
  })
  const [registration, setRegistration] = useState({
    password: Number
  })
  const [blackList, setBlackList] = useState({
    addAddress: "",
    removalAddress: ""
  })
  const [addressInfo, setAddressInfo] = useState({ // информация по адресу
    role: "",
    balanceETH: "",
    balanceCMONCurrent: "",
    balanceCMONSeed: "",
    balanceCMONPrivate: "",
    balanceCMONPublic: ""
  })
  const [application, setApplication] = useState({
    login: "",
    contact: ""
  })
  var roleArray = ["владелец", "public провайдер", "private провайдер", "инвестор", "пользователь"]
  var infoArray = [
    ["Роль: ", addressInfo.role],
    ["Балланс в ETH: ", addressInfo.balanceETH],
    ["Баланс CMON: ", addressInfo.balanceCMONCurrent],
    ["Баланс CMON Seed: ", addressInfo.balanceCMONSeed],
    ["Баланс CMON Private: ", addressInfo.balanceCMONPrivate],
    ["Баланс CMON Public: ", addressInfo.balanceCMONPublic]
  ]

// ^: HANDLERS
const handlerSetAddress = async (currentAddress) => {
  setAddress(currentAddress)
  var structUser = await Contract.methods.structUsers_(currentAddress).call()
  var basicRole = roleArray[structUser[0]]
  if(!basicRole) {
    basicRole = "неопределенная роль"
  } 
  setAddressInfo({
    role: basicRole,
    balanceETH: await Contract.methods.getBalanceEth(currentAddress).call(),
    balanceCMONCurrent: await Contract.methods.currentBalance(currentAddress).call(),
    balanceCMONSeed: await Contract.methods.getBalanceSeedToken(currentAddress).call(),
    balanceCMONPrivate: await Contract.methods.getBalancePrivateToken(currentAddress).call(),
    balanceCMONPublic: await Contract.methods.getBalancePublicToken(currentAddress).call()
  })
}

  // ^: USEEFFECT
  useEffect(() => {
    const listAccounts = async () => {
      let users = await web3.eth.getAccounts()
      setAccounts(users)
      setAddress(users[0])
      handlerSetAddress(users[0])
    }
    listAccounts()
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => console.log(blackList), [blackList])

  // ^: HANDLERS
  // Обработка функции создания пользовтеля
  const handlerCreateAccount = async (event) => {
    await createNewUser(event, Contract, web3, newAccount.login, newAccount.password, accounts)
    let users = await web3.eth.getAccounts()
    setAccounts(users)
  }

  // ?: Функция получения списка подающих заявки
  const funcApplicationsAmountAdr = async () => {
    setApplicationsAmountAdr(await Contract.methods.getApplicationAmountAdr().call({from: address}))
  }

  // #: HTML
  return(
    <>
      <div>
        <h3 style={{margin: "0"}}>Создание новых пользовтелей</h3>
        <button onClick={event => handlerCreateAccount(event)}>Создать пользовтеля</button>
        <input onInput={event => setNewAccount({...newAccount, login: event.target.value})} placeholder="Введите логин" />
        <input onInput={event => setNewAccount({...newAccount, password: event.target.value})} placeholder="Введите пароль" />
      </div>
      <div style={{paddingTop: "15px"}}>
        <h3 style={{margin: "0"}}>Выберите аккаунт для взаимодействия</h3>
        <select onChange={event => {handlerSetAddress(event.target.value); console.log("Current address: " + event.target.value)}}>
          <option disabled>Выберите аккаунт</option>
          {accounts.map((arr,i) => <option key={i} value={String(arr)}>{arr}</option>)}
        </select>
        <input onInput={event => setRegistration({...registration, password: event.target.value})} placeholder="Введите пароль" />
        <button onClick={event => unlockUser(event, web3, registration.password, address)}>Разблокировать пользователя</button>
        <p style={{marginBottom: "0"}}>Информация об аккаунте:</p>
        {infoArray.map((value, key) => <span key={key} style={{display: "block"}}>{value}</span>)}
      </div>
      <div style={{paddingTop: "15px"}}>
        <h3 style={{margin: "0"}}>Панель пользователя</h3>
        <button onClick={() => funcApplication(Contract, address, application.login, application.contact)}>Отправка заявки</button>
        <input onInput={event => setApplication({...application, login: event.target.value})} placeholder="Введите логин" />
        <input onInput={event => setApplication({...application, contact: event.target.value})} placeholder="Введите контакты для связи" />
      </div>
      <div style={{paddingTop: "15px"}}>
        <h3 style={{margin: "0"}}>Панель Владельца системы</h3>
        <div>
          <p style={{marginBottom: "0"}}>Редактирование blacklist:</p>
          <button onClick={event => funcBlackList(event, "add", blackList.addAddress, address, Contract)}>Добавить пользователя</button> 
          <input onInput={event => setBlackList({...blackList, addAddress: event.target.value})} placeholder="Введите адрес" style={{width: "30em"}}/>
          <br/>
          <button onClick={event => funcBlackList(event, "remove", blackList.removalAddress, address, Contract)}>Удалить пользователя</button> 
          <input onInput={event => setBlackList({...blackList, removalAddress: event.target.value})} placeholder="Введите адрес" style={{width: "30em"}}/>
        </div>
      </div>
      <div style={{paddingTop: "15px"}}>
        <h3 style={{margin: "0"}}>Панель Private провайдера</h3>
          <div>
            <p style={{marginBottom: "0"}}>Кнопки для запуска и остановки Private фазы:</p>
            <button onClick={event => funcPhaseControl(event, "start", Contract, address)}>Запуск</button>
            <button onClick={event => funcPhaseControl(event, "end", Contract, address)}>Остановка</button>
          </div>
          <div>
            <p style={{marginBottom: "0"}}>Обработка заявок:</p>
            <button onClick={() => funcApplicationsAmountAdr()} >Получить список подающих заявки</button>
            <select>
              <option disabled>Выберите аккаунт</option>
              {applicationsAmountAdr.map((arr,i) => <option key={i} value={String(arr)}>{arr}</option>)}
            </select>
          </div>
      </div>
    </>
  )
}

export {Authorization}