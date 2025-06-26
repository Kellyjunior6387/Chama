import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.scss';
import { Landing } from './landing.tsx';
import "../ui/globals.css"
import "./index.scss"

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <Landing/>
  </React.StrictMode>,
);

 