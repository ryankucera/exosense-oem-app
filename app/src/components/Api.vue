<template>
  <v-container>
    <v-layout>
      <v-flex xs6 class="px-4">
        <v-list two-line>
          <template v-for="(route, i) in routes">
            <v-subheader v-if="route.header" :key="i">{{ route.header }}</v-subheader>
            <v-list-tile v-else :key="i" @click="selectRoute(route)">
              <v-list-tile-content>
                <v-list-tile-title>{{ route.route }}</v-list-tile-title>
                <v-list-tile-sub-title>{{ route.description }}</v-list-tile-sub-title>
              </v-list-tile-content>
            </v-list-tile>
          </template>
        </v-list>
      </v-flex>

      <v-flex xs6 class="px-4 pt-4">
        <v-toolbar v-if="selectedRoute" dense>
          <v-toolbar-title>{{ selectedRoute.route }}</v-toolbar-title>
          <v-spacer />
          <v-toolbar-items>
            <v-btn flat @click="callApi()" :disabled="loading">
              <span v-if="!loading">Call API</span>
              <v-progress-circular indeterminate v-else></v-progress-circular>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-toolbar v-if="selectedRoute && selectedRoute.parameters">
          <v-text-field
            v-for="parameter in selectedRoute.parameters"
            :key="parameter.key"
            :label="parameter.label"
            v-model="parameter.value"
            single-line
          />
        </v-toolbar>
        <v-card class="mt-4" v-if="selectedRoute" dark>
          <v-card-text>
            <pre v-if="selectedRoute">{{ selectedRoute.response }}</pre>
          </v-card-text>
        </v-card>

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
import _ from 'lodash'
import axios from '@/axios'

export default {
  data() {
    return {
      loading: false,
      selectedRoute: '',
      snackbarText: '',
      snackbar: false,
      snackbarColor: '',
      result: 'The API response will appear here',
      routes: [
        {
          header: 'Devices'
        },
        {
          route: '/api/claim',
          method: 'post',
          description: 'Claim a device using a claim code',
          parameters: {
            claimCode: {
              key: 'claimCode',
              type: 'body',
              label: 'Claim Code',
              value: '',
            }
          }
        },
        {
          route: '/api/devices/${identity}',
          method: 'get',
          description: 'Get a single device that the user has access to',
          parameters: {
            identity: {
              key: 'identity',
              type: 'url',
              label: 'Device Identity',
              value: '',
            }
          }
        },
        {
          route: '/api/devices',
          method: 'get',
          description: 'Get a list of devices the user has claimed',
        },

      ]
    }
  },
  methods: {
    selectRoute(route) {
      let parameters = _.map(route.parameters, parameter => Object.assign({}, parameter, { value: '' }))
      this.selectedRoute = Object.assign({}, route, { response: '', parameters })
    },
    callApi() {
      if(!this.loading) {
        const { method, parameters } = this.selectedRoute
        let { route } = this.selectedRoute
        const body = {}
        if(parameters) {
          _.each(parameters, parameter => {
            const { type, key, value } = parameter
            if(type === 'url') {
              route = _.replace(route, "${"+key+"}", value)
            } else {
              body[key] = value
            }
          })
        }
        let promise
        if(method === 'get') {
          promise = axios[method](route)
        } else {
          promise = axios[method](route, body)
        }
        this.loading = true
        promise.then(response => {
          this.selectedRoute.response = _.get(response, 'data')
          this.loading = false
        }).catch(err => {
          this.loading = false
          this.selectedRoute.response = `[${_.get(err, 'response.status')}] ${_.get(err, 'response.data')}`
          this.snackbarText = this.selectedRoute.response
          this.snackbarColor = 'error'
          this.snackbar = true
        })
      }
    }
  }
}
</script>

<style>
.api-result {
  background-color: #777;
  color: white;
}
</style>
