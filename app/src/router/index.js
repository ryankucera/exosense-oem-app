import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'
import Login from '@/components/Login'
import Users from '@/components/Users'
import Api from '@/components/Api'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Devices',
      component: Home
    },
    {
      path: '/login',
      name: 'Login',
      component: Login
    },
    {
      path: '/users',
      name: 'Users',
      component: Users
    },
    {
      path: '/api',
      name: 'Api',
      component: Api
    }

  ]
})
