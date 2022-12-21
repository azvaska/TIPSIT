import { createApp } from 'vue'
import App from './App.vue'

import router from './router'
import './registerServiceWorker'

import io from 'socket.io-client';
import  Config  from "./utils/config"
const ip_addr= Config.ip_addr;
const app =  createApp(App);
app.config.globalProperties.$Wsaddress = `${ip_addr}:3000`;
app.config.globalProperties.$soketio = io(app.config.globalProperties.$Wsaddress);
app.use(router).mount('#app')


//createApp(App).use(router).mount('#app')
