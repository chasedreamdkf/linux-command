import { createApp } from 'vue';
import { createRouter, createWebHistory } from 'vue-router';
import App from './App.vue';
import HomeView from './views/HomeView.vue';
import CommandView from './views/CommandView.vue';
import './assets/main.css';
import 'highlight.js/styles/github.css';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: HomeView },
    { path: '/command/:name', component: CommandView },
  ],
});

const app = createApp(App);
app.use(router);
app.mount('#app');
