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
  var roleArray = ["владелец", "public провайдер", "private провайдер", "инвестор", "пользователь"]
  const [accounts, setAccounts] = useState([]) // общее список пользовтелей в системе
  const [address, setAddress] = useState() // текущий выбранный адрес
  const [applicationsAmountAdr, setApplicationsAmountAdr] = useState([]) // список подающих заявки
  const [whiteListAddress, setWhiteListAddress] = useState([]) // список подающих заявки
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
  var infoArray = [
    ["Роль: ", addressInfo.role],
    ["Балланс в ETH: ", addressInfo.balanceETH],
    ["Баланс CMON: ", addressInfo.balanceCMONCurrent],
    ["Баланс CMON Seed: ", addressInfo.balanceCMONSeed],
    ["Баланс CMON Private: ", addressInfo.balanceCMONPrivate],
    ["Баланс CMON Public: ", addressInfo.balanceCMONPublic]
  ]
  const [application, setApplication] = useState({
    login: "",
    contact: ""
  })
  const [addressWhiteList, setAddressWhiteList] = useState() // текущий выбранный адрес в whitelist'е
  const [addressWhiteListInfo, setAddressWhiteListInfo] = useState({
    name: "",
    contacts: "",
    address: "",
    status: ""
  })
  var infoArrayWhiteList = [
    ["Имя: ", addressWhiteListInfo.name],
    ["Контакты: ", addressWhiteListInfo.contacts],
    ["Адрес в сети: ", addressWhiteListInfo.address],
    ["Статус: ", addressWhiteListInfo.status],
  ]
  const [transfer, setTransfer] = useState({
    address: "",
    amount: ""
  })
  const [transferFrom, setTransferFrom] = useState({
    address: "",
    amount: ""
  })
  const [approve, setApprove] = useState({
    delegate: "",
    numTokens: ""
  })


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
    balanceCMONCurrent: await Contract.methods.balanceOf(currentAddress).call(),
    balanceCMONSeed: await Contract.methods.getBalanceSeedToken(currentAddress).call(),
    balanceCMONPrivate: await Contract.methods.getBalancePrivateToken(currentAddress).call(),
    balanceCMONPublic: await Contract.methods.getBalancePublicToken(currentAddress).call()
  })
  }

  const handlerSetAddressWhitelist = async (currentAddress) => {
    setAddressWhiteList(currentAddress)
    var structApplication = await Contract.methods.strucApplications_(currentAddress).call()
    console.log(structApplication[3])
    setAddressWhiteListInfo({
      name: structApplication[0],
      contacts: structApplication[1],
      address: structApplication[2],
      status: structApplication[3] ? "true" : "false"
    })
  }

  // ^: USEEFFECT
  useEffect(() => {
    const listAccounts = async () => {
      let users = await web3.eth.getAccounts()
      setAccounts(users)
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
        <select defaultValue="Выберите аккаунт" onChange={event => {handlerSetAddress(event.target.value); console.log("Current address: " + event.target.value)}}>
          <option disabled>Выберите аккаунт</option>
          {accounts.map((arr,i) => <option key={i} value={String(arr)}>{arr}</option>)}
        </select>
        <input onInput={event => setRegistration({...registration, password: event.target.value})} placeholder="Введите пароль" />
        <button onClick={event => unlockUser(event, web3, registration.password, address)}>Разблокировать пользователя</button>
        <p style={{marginBottom: "0"}}>Информация об аккаунте:</p>
        {infoArray.map((value, key) => <span key={key} style={{display: "block"}}>{value}</span>)}
      </div>

      <div style={{paddingTop: "15px"}}>
        <h3 style={{margin: "0"}}>Общие функции</h3>
        <div>
          <p style={{marginBottom: "0"}}>Перевод токенов:</p>
          <input onInput={event => setTransfer({...transfer, amount: event.target.value})} placeholder="Введите кол-во токенов" />
          <select defaultValue="Выберите аккаунт, которому собираетесь перевести" onChange={event => setTransfer({...transfer, address: event.target.value})}>
            <option disabled>Выберите аккаунт, которому собираетесь перевести</option>
            {accounts.map((arr,i) => <option key={i} value={String(arr)}>{arr}</option>)}
          </select>
          <button onClick={async () => {
            await Contract.methods.transfer(transfer.address, transfer.amount).send({from: address})
            alert("Вы перевели "+transfer.amount+" токенов.")
          }}>Перевести токены</button>
        </div>
        <div>
          <p style={{marginBottom: "0"}}>Перевод распоряжаюмищихся токенов:</p>
          <input onInput={event => setTransferFrom({...transfer, amount: event.target.value})} placeholder="Введите кол-во токенов" />
          <select defaultValue="Выберите аккаунт, которому собираетесь перевести:" onChange={event => setTransferFrom({...transfer, address: event.target.value})}>
            <option disabled>Выберите аккаунт предоставления</option>
            {accounts.map((arr,i) => <option key={i} value={String(arr)}>{arr}</option>)}
          </select>
          <button onClick={async () => {
            await Contract.methods.transferFrom(address ,transferFrom.address, transferFrom.amount).send({from: address})
            alert("Вы перевели "+transfer.amount+" токенов.")
          }}>Перевести токены</button>
        </div>
        <div>
          <p style={{marginBottom: "0"}}>Одобрение делегированной учетной записи:</p>
          <input onInput={event => setApprove({...approve, numTokens: event.target.value})} placeholder="Введите кол-во токенов" />
          <select defaultValue="Выберите аккаунт, которому собираетесь перевести:" onChange={event => setApprove({...approve, delegate: event.target.value})}>
            <option disabled>Выберите аккаунт предоставления</option>
            {accounts.map((arr,i) => <option key={i} value={String(arr)}>{arr}</option>)}
          </select>
          <button onClick={async () => {
            console.log(transfer.address, transfer.amount)
            await Contract.methods.approve(approve.delegate, approve.numTokens).send({from: address})
            alert("Вы перевели "+transfer.amount+" токенов.")
          }}>Перевести токены</button>
        </div>
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
        <button onClick={async () => setWhiteListAddress(await Contract.methods.get_whiteList().call({from: address}))}>Получить список пользовтелей в whitelist'е</button>
        <select defaultValue="Выберите аккаунт" onChange={event => {handlerSetAddressWhitelist(event.target.value); console.log("Current addressWhiteList: " + event.target.value)}}>
          <option disabled>Выберите аккаунт</option>
          {whiteListAddress.map((arr,i) => <option key={i} value={String(arr)}>{arr}</option>)}
        </select>
          <div>
            <p style={{marginBottom: "0"}}>Кнопки для запуска и остановки Private фазы:</p>
            <button onClick={event => funcPhaseControl(event, "start", Contract, address)}>Запуск</button>
            <button onClick={event => funcPhaseControl(event, "end", Contract, address)}>Остановка</button>
          </div>
          <div>
            <p style={{marginBottom: "0"}}>Обработка заявок:</p>
            <button onClick={() => funcApplicationsAmountAdr()} >Получить список подающих заявки</button>
            <select defaultValue="Выберите аккаунт" onChange={event => {handlerSetAddressWhitelist(event.target.value); console.log("Current addressWhiteList: " + event.target.value)}}>
              <option disabled>Выберите аккаунт</option>
              {applicationsAmountAdr.map((arr,i) => <option key={i} value={String(arr)}>{arr}</option>)}
            </select>
            <p style={{marginBottom: "0"}}>Информация о заявке:</p>
            {infoArrayWhiteList.map((value, key) => <span key={key} style={{display: "block"}}>{value}</span>)}
            <button onClick={async () => {
              alert("Дождитесь создания пользователя...")
              await Contract.methods.acceptApplication(addressWhiteList).send({from: address})
              handlerSetAddressWhitelist(addressWhiteList)
              alert("Заявка была принята.")
            }}>Принять</button>
            <button onClick={async () => {
              alert("Дождитесь создания пользователя...")
              await Contract.methods.deviationApplication(addressWhiteList).send({from: address})
              handlerSetAddressWhitelist(addressWhiteList)
              alert("Заявка была отклонена.")
            }}>Отклонить</button>
          </div>
      </div>
    </>
  )
}

export {Authorization}