import EventEmitter from 'eventemitter3'
import router from '@/router'
import axios from '@/axios'

export default class AuthService {
  authenticated = this.isAuthenticated()
  authNotifier = new EventEmitter()

  constructor () {
    this.processingLogin = false
    this.login = this.login.bind(this)
    this.setSession = this.setSession.bind(this)
    this.logout = this.logout.bind(this)
    this.signup = this.signup.bind(this)
    this.isAuthenticated = this.isAuthenticated.bind(this)
    this.authNotifier.emit('authChange', { authenticated: this.isAuthenticated() })
  }

  login (data) {
    return axios.post('/users/login', data).then(response => {
      if (JSON.stringify(response.data).toLowerCase().indexOf('invalid login') > -1) {
        return Promise.reject(new Error('invalid login'))
      }
      this.setSession(response)
      this.setProfile()
      return response
    })
  }

  signup (data) {
    return axios.post('/users/create', data).then(response => {
      if (response.data && response.data.error) {
        return Promise.reject(new Error('invalid signup'))
      }
      this.setSession(response)
      this.setProfile()
    })
  }

  setProfile () {
    return axios.get('/users/currentUser').then(response => {
      localStorage.setItem('profile', JSON.stringify(response.data))
    })
  }

  setSession (response) {
    const token = response.data
    if (token) {
      axios.defaults.headers.common['Authorization'] = token
      localStorage.setItem('token', token)
      this.authNotifier.emit('authChange', { authenticated: true })
      router.replace('/')
    }
  }

  logout () {
    // Clear access token and ID token from local storage
    localStorage.removeItem('token')
    localStorage.removeItem('profile')
    this.userProfile = null
    this.authNotifier.emit('authChange', false)
    // navigate to the home route
    router.replace('/login')
  }

  isAuthenticated () {
    const token = localStorage.getItem('token')
    if (token) {
      axios.defaults.headers.common['Authorization'] = token
    }
    return token
  }

  token () {
    return localStorage.getItem('token')
  }

  profile () {
    const profile = localStorage.getItem('profile')
    try {
      return JSON.parse(profile)
    } catch (err) {
      return {}
    }
  }
}
