<template>
  <v-container class="login-container">
    <v-layout>
      <v-flex xs6 offset-xs3>
        <img :src="logo" class="logo mt-2 mb-2">
        <v-tabs
          v-model="active"
          color="primary"
          dark
          slider-color="secondary"
          fixed-tabs
        >
          <v-tab key="login" ripple>
            Login
          </v-tab>
          <v-tab key="signup" ripple>
            Signup
          </v-tab>

          <v-tab-item key="login" class="pa-3">
            <v-form ref="login" v-model="loginValid">
              <v-text-field required :rules="emailRules" label="Email" v-model="email" />
              <v-text-field required :rules="passwordRules" type="password" label="Password" v-model="password" />
            </v-form>
            <div class="text-xs-center">
              <v-btn :disabled="!loginValid" @click="login()" color="accent">Login</v-btn>
            </div>
          </v-tab-item>

          <v-tab-item key="signup" class="pa-3">
            <v-form ref="signup" v-model="signupValid">
              <v-text-field required :rules="nameRules" label="Name" v-model="name" />
              <v-text-field required :rules="emailRules" label="Email" v-model="email" />
              <v-text-field required :rules="passwordRules" type="password" label="Password" v-model="password" />
            </v-form>
            <div class="text-xs-center">
              <v-btn :disabled="!signupValid" @click="signup()" color="accent">Signup</v-btn>
            </div>
          </v-tab-item>
        </v-tabs>
      </v-flex>
    </v-layout>
    <v-snackbar
      v-model="snackbar"
      :color="snackbarColor"
    >
      {{ snackbarText }}
      <v-btn
        dark
        flat
        @click="snackbar = false"
      >
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
.login-container {
  background-color: #222736 !important;
  height: 100%;
  width: 100vw !important;
}


</style>
