// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import router from './router'
import Vuetify from 'vuetify'
import 'vuetify/dist/vuetify.min.css'
import VueNativeSock from 'vue-native-websocket'

Vue.use(Vuetify, { theme: {
  primary: '#2C9DB6',
  secondary: '#222736',
  accent: '#F15C2E',
  error: '#FF5252',
  info: '#2196F3',
  success: '#4CAF50',
  warning: '#FFC107'
}})

Vue.use(VueNativeSock, 'ws://localhost:3000/api/subscribe')
Vue.use(require('vue-moment'))

Vue.config.productionTip = false

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>'
})
