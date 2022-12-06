import { createApp } from 'vue'
import App from './App.vue'

import router from './router'
import './registerServiceWorker'

import io from 'socket.io-client';

const app =  createApp(App);
app.config.globalProperties.$Wsaddress = 'localhost:3000';
app.config.globalProperties.$soketio = io(app.config.globalProperties.$Wsaddress);
app.use(router).mount('#app')


//createApp(App).use(router).mount('#app')
