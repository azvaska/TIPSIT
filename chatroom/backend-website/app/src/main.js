import { createApp } from 'vue'
import App from './App.vue'

import router from './router'
import './registerServiceWorker'

import io from 'socket.io-client';

const app =  createApp(App);

app.config.globalProperties.$soketio = io('localhost:3000');
app.use(router).mount('#app')


//createApp(App).use(router).mount('#app')
