<template>
  <v-container class="login-container full-height">
    <v-layout class="center">
      <v-flex md4 offset-md4 sm6 offset-sm3 xs8 offset-xs2>
        <div class="text-xs-center">
          <img :src="logo" class="login-logo mt-2 mb-2">
        </div>
        <v-tabs v-model="active" slider-color="accent" fixed-tabs color="secondary">
          <v-tab key="login" ripple class="white--text">
            Login
          </v-tab>
          <v-tab key="signup" ripple class="white--text">
            Signup
          </v-tab>

          <v-tab-item key="login" class="width-limit py-5">
            <v-form ref="login" v-model="loginValid">
              <v-text-field dark required :rules="emailRules" label="Email" v-model="email" />
              <v-text-field dark required :rules="passwordRules" type="password" label="Password" v-model="password" />
            </v-form>
            <div class="text-xs-center">
              <v-btn :disabled="!loginValid" @click="login()" color="primary">Login</v-btn>
            </div>
          </v-tab-item>

          <v-tab-item key="signup" class="width-limit py-4">
            <v-form ref="signup" v-model="signupValid">
              <v-text-field dark required :rules="nameRules" label="Name" v-model="name" />
              <v-text-field dark required :rules="emailRules" label="Email" v-model="email" />
              <v-text-field dark required :rules="passwordRules" type="password" label="Password" v-model="password" />
            </v-form>
            <div class="text-xs-center">
              <v-btn :disabled="!signupValid" @click="signup()" color="primary">Signup</v-btn>
            </div>
          </v-tab-item>
        </v-tabs>
      </v-flex>
    </v-layout>
    <v-snackbar v-model="snackbar" :color="snackbarColor">
      {{ snackbarText }}
      <v-btn dark flat @click="snackbar = false">
        Close
      </v-btn>
    </v-snackbar>
  </v-container>
</template>

<script>
import logo from '@/assets/exositelogo.png'
import { auth } from '@/Auth'

export default {
  data () {
    return {
      logo,
      active: 'login',
      signupValid: false,
      loginValid: false,
      name: '',
      nameRules: [
        v => !!v || 'Name is required',
        v => (v && v.length <= 30) || 'Name must be less than 30 characters'
      ],
      email: '',
      emailRules: [
        v => !!v || 'E-mail is required',
        v => /.+@.+/.test(v) || 'E-mail must be valid'
      ],
      password: '',
      passwordRules: [
        v => !!v || 'Password is required',
        v => v.length > 6 || 'Password too short'
      ],
      snackbar: false,
      snackbarText: '',
      snackbarColor: ''
    }
  },
  methods: {
    signup () {
      const data = {
        name: this.name,
        email: this.email,
        password: this.password
      }
      auth.signup(data).then(response => {}).catch(err => {
        console.warn({ err })
        this.snackbar = true
        this.snackbarText = 'Error signing up'
        this.snackbarColor = 'error'
      })
    },
    login () {
      const data = {
        email: this.email,
        password: this.password
      }
      auth.login(data).then(response => {
      }).catch(err => {
        console.warn({ err })
        this.snackbar = true
        this.snackbarText = 'Invalid Login'
        this.snackbarColor = 'error'
      })
    }
  }
}
</script>

<style>
.login-logo {
  width: 70%;
  min-width: 300px;
}
.login-container {
  background-color: #222736 !important;
  height: 100%;
  width: 100vw !important;
}

.center {
  height: 80vh !important;
}
.center > .flex {
  margin-top: 12vh;
}

.width-limit {
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

</style>
