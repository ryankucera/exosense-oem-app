<template>
  <v-container fluid>
    <v-slide-y-transition mode="out-in">
      <v-layout row>
        <v-flex xs6>
          <v-list two-line subheader>
            <v-list-tile
              v-for="item in users"
              :key="item.id"
              avatar
              @click="selectedUser = item"
            >
              <v-list-tile-avatar>
                <v-icon>verified_user</v-icon>
              </v-list-tile-avatar>
              <v-list-tile-content>
                <v-list-tile-title>{{ item.name }}</v-list-tile-title>
                <v-list-tile-sub-title>{{ item.email }}</v-list-tile-sub-title>
              </v-list-tile-content>
            </v-list-tile>
          </v-list>
        </v-flex>
        <v-flex xs6>
          {{ selectedUser }}
        </v-flex>
      </v-layout>
    </v-slide-y-transition>
  </v-container>
</template>

<script>
import { auth } from '@/Auth'
import axios from '@/axios'
import Users from '@/users'

export default {
  components: {
  },
  data () {
    return {
      authenticated: auth.authenticated,
      selectedUser: false,
      users: [],
      loading: false,
      Users: new Users()
    }
  },
  methods: {
    fetchUsers() {
      const users = this.Users.users;
      if(!users) {
        this.Users.fetch().then(() => {
          this.users = this.Users.users
        })
      }

    }
  },
  mounted () {
    this.fetchUsers()
  },
  watch: {
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
