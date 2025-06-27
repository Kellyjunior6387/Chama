import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.scss';
import { Landing } from './landing.tsx';
import "../ui/globals.css"
import "./index.scss"
import { Provider } from 'react-redux';
import { store } from './states/reduxStore';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <Provider store={store} >
      <Landing/>
    </Provider>
  </React.StrictMode>,
);

 