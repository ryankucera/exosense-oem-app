import axios from 'axios'

const origin = window.location.origin
let baseURL = '/'
if (origin.indexOf('http://localhost') > -1) {
  baseURL = 'http://localhost:3000'
}

const instance = axios.create({
  baseURL,
  timeout: 3000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Cache-Control': 'no-cache'
  }
})

export default instance
