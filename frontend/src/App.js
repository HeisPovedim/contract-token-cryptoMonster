// #: REACT
import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Web3 from 'web3';

// #: COMPONENTS
import { userList } from './contract/userList';
import { Context } from './contract/context';

// #: CSS
import './App.scss';

// #: PAGES
import { Authorization } from './pages/Authorization';


const App = () => {
  const [web3] = React.useState(new Web3('HTTP://127.0.0.1:8545'));
	const AddressContract='0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8';
	const [Contract] = React.useState(new web3.eth.Contract(userList,AddressContract));
	web3.eth.defaultAccount='0x8E4c24e134908f2334aeF88556Fc1Daaa075A56c';

  return (
    <>
      <Context.Provider value={{web3,Contract}}>
        <Routes>
          <Route path="/" element={<Authorization />} />
        </Routes>
      </Context.Provider>
    </>
  );
};

export default App;