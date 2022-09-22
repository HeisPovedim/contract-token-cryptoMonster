// #: REACT
import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Web3 from 'web3';

// #: CSS
import './App.scss';

// #: PAGES
import { Authorization } from './pages/Authorization';


const App = () => {
  const [web3] = React.useState(new Web3('HTTP://127.0.0.1:8545'));
	const AddressContract='0xA99dD5A595b632418D2cB307F94Dc0ffEb5585c2';
	const [Contract] = React.useState(new web3.eth.Contract(UserList,AddressContract));
	web3.eth.defaultAccount='0x8E4c24e134908f2334aeF88556Fc1Daaa075A56c';

  return (
    <>
      <Routes>
        <Route path="/" element={<Authorization />} />
      </Routes>
    </>
  );
};

export default App;