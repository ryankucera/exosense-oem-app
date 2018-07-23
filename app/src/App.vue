<template>
  <v-app class="app">
    <v-navigation-drawer
      v-if="authenticated"
      persistent
      v-model="drawer"
      enable-resize-watcher
      fixed
      app
      :width="200"
    >
      <v-layout column style="height: 100%">
          <img :src="logo" class="logo mt-2 mb-2">
          <v-list>
            <v-list-tile
              exact
              v-for="(item, i) in items"
              :key="i"
              :to="{name: item.route}"
              active-class="primary--text active-link"
              class="white--text darken-2"
            >
              <v-list-tile-action>
                <v-icon class="grey--text lighten-2" v-html="item.icon"></v-icon>
              </v-list-tile-action>
              <v-list-tile-content>
                <v-list-tile-title v-text="item.title"></v-list-tile-title>
              </v-list-tile-content>
            </v-list-tile>
          </v-list>
          <v-spacer />
          <div class="ml-3 pb-2 grey--text darken-5">
            <span>Exosite &copy; 2018</span>
          </div>
      </v-layout>
    </v-navigation-drawer>
    <v-toolbar
      v-if="authenticated"
      app
      color="accent"
    >
      <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
      <v-toolbar-title v-text="title"></v-toolbar-title>
      <v-spacer></v-spacer>
      <v-menu offset-y>
        <v-btn
          slot="activator"
          flat
        >
          {{ profile.name }}
        </v-btn>
        <v-list>
          <v-list-tile key="logout" @click="logout()" >
            <v-list-tile-title>Log Out</v-list-tile-title>
          </v-list-tile>
        </v-list>
      </v-menu>
    </v-toolbar>

    <v-content :class="$route.name !== 'Login' ? 'content' : ''">
      <router-view :auth="auth" :authenticated="authenticated"/>
    </v-content>

  </v-app>
</template>

<script>
import { auth } from '@/Auth'
import logo from '@/assets/exositelogo.png'

export default {
  data () {
    return {
      auth,
      authenticated: auth.authenticated,
      drawer: true,
      logo,
      items: [{
        icon: 'bubble_chart',
        title: 'Devices',
        route: 'Devices'
      },
      {
        icon: 'group',
        title: 'Users',
        route: 'Users'
      },
      ],
      menuItems: [{
          title: 'Profile',
        }, {
          title: 'Sign Out',
          fn: this.logout,
        }
      ],
    }
  },
  name: 'app',
  computed: {
    profile() {
      return auth.profile() || {}
    },
    title() {
      return this.$route.name
    }
  },
  methods: {
    login() {
      auth.login()
    },
    logout() {
      auth.logout()
    },
    signup() {
      auth.signup()
    },
  },
  mounted() {
    if (!this.authenticated) {
      // if we aren't authenticated and we're not returning form Auth0
      this.$router.push({ path: '/login' })
    }
  },
  created () {
    auth.authNotifier.on('authChange', authState => {
      this.authenticated = authState.authenticated
      this.redirect = true
    })
  },
}
</script>

<style>
.app {
  background-color: #101420 !important;
}
.content {
  background-color: white;
}
.logo {
  width: 100%;
}
.v-footer, .v-navigation-drawer {
  width: 200px !important;
  background-color: #101420 !important;
}
.active-link {
  color: #2C9DB6 !important;
}
.v-list__tile--active .v-list__tile__action:first-of-type .v-icon {
  color: #2C9DB6 !important;
}

</style>
