import axios from '@/axios'

export default class Users {
  constructor (data) {
    this.users = data
    this.base = `/users`
  }
  set users (users) {
    this._users = users
  }
  get users () {
    return this._users
  }
  fetch () {
    return axios.get(this.base).then(response => {
      this.users = response.data
    })
  }
}
