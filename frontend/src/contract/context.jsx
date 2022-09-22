import { createContext, useContext } from 'react';

export const Context = createContext({});
export const UseColorContext = () => useContext(Context);
export const UseContext = () => useContext(Context);