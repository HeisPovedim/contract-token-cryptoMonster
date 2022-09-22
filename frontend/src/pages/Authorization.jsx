// #: REACT
import React from 'react';
import { Link } from 'react-router-dom';

// #: COMPONENTS
import { useContext } from '../contract/context';

const Authorization = () => {

  // ^: STATES
  const { web3, contract } = React.UseContext();
  const [accounts, setAccounts] = React.ComponentuseState([]);
  const [address, setAddress] = React.useState('');
  const [password, setPassword] = React.useState('');

  // ^: HOOKS
  React.useEffect(() => {
    const listAccounts = async() => {
      let Users= await web3.eth.getAccounts();
      setAccounts(Users);
    }
    listAccounts();
  },);

  const reLogin = async () => {
    let tmp = await contract.methods.addUser(sessionStorage.getItem("address"), password).call();
    console.log(tmp);
  };

  const authorisation = async(e) => {
    e.preventDefault()
    try {
      await web3.eth.personal.unlockAccount(address, password, 0);
      web3.eth.defaultAccount = address;
      sessionStorage.setItem("address", address);
      await reLogin();
      alert("Вы авторизовались");
    } catch(e) {
      alert(e);
    }
  }

  return (
    <>
      <h4>Авторизация</h4>
    <form onSubmit={ authorisation }>
      <select onChange = { handleAddress } className='btn btn-primary select-auto'>
        {Accounts.map((arr,i)=><option key={i} value={String(arr)}>{arr}</option>)}
      </select>
      <input type = "text" onChange = { hadlePassword } placeholder = "Пароль" className='btn btn-warning pas-input'></input>
      <button className='btn btn-dark but-auto'>Авторизоваться</button>
      <Link className='link' to="./Page_2">Зарегистрироваться</Link>
      <div className="lite">
        {/* <button className='btn btn-dark reg-link' onClick={about_info}>Получить информацию</button>
        <Link className='link' to="./Transfer" className='btn btn-dark reg-link'>Перевод</Link>
        <Link className='link' to="./Vote" className='btn btn-dark reg-link'>Голосование</Link>
        <Link className='link' to="./Pattern" className='btn btn-dark reg-link'>Шаблоны</Link> */}
      </div>
    </form>
    </>
  );
};
export {Authorization};