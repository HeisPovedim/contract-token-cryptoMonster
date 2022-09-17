// #: REACT
import React from 'react';
import { Routes, Route } from 'react-router-dom';

// #: CSS
import './App.scss';

// #: PAGES
import { Authorization } from './pages/Authorization';

const App = () => {
  return (
    <>
      <Routes>
        <Route path="/" element={<Authorization />} />
      </Routes>
    </>
  );
};

export default App;