<template>
  <v-container fluid class="fill-height">
    <v-layout row>
      <v-flex xs6>
        <v-list two-line subheader>
          <v-subheader>Your devices</v-subheader>
          <v-list-tile
            v-for="item in yourDevices"
            :key="item.identity"
            avatar
            @click="selectedDevice=item"
            :class="selectedDevice.identity === item.identity ? 'active' : ''"
          >
            <v-list-tile-avatar>
              <v-icon>router</v-icon>
            </v-list-tile-avatar>

            <v-list-tile-content>
              <v-list-tile-title>{{ item.identity }}</v-list-tile-title>
              <v-list-tile-sub-title>Claimed // Status: {{ item.status }}</v-list-tile-sub-title>
            </v-list-tile-content>

            <v-list-tile-action @click.stop>
              <v-menu offset-y>
                <v-btn icon ripple slot="activator">
                  <v-icon color="grey lighten-1">more_vert</v-icon>
                </v-btn>
                <v-list>
                  <v-list-tile href="javascript:;" v-if="item.meta.claimed" @click="item.unclaim()">
                    <v-list-tile-title>Unclaim</v-list-tile-title>
                  </v-list-tile>
                  <!-- <v-list-tile href="javascript:;" @click="item.del()">
                    <v-list-tile-title>Delete</v-list-tile-title>
                  </v-list-tile> -->
                </v-list>
              </v-menu>
            </v-list-tile-action>
          </v-list-tile>
          <div class="subtitle px-3" v-if="!loading && yourDevices.length === 0">
            You have no claimed devices. You can claim a device by clicking the button below.
          </div>
          <v-divider />
          <div class="text-xs-center ma-1" v-if="loading">
            <v-progress-circular indeterminate color="primary"/>
          </div>
        </v-list>

        <div class="text-xs-center mt-5">
          <v-btn color="accent" @click="claimDeviceDialog=true">
            Claim Device
          </v-btn>
        </div>
      </v-flex>
      <v-flex xs6>
        <DeviceDetail :device="selectedDevice" />
      </v-flex>
    </v-layout>
    <v-dialog v-model="claimDeviceDialog" max-width="500">
      <v-card>
        <v-card-title class="headline">Claim Device Using Code</v-card-title>
        <v-card-text>
          <v-text-field v-model="claimCode" label="Claim Code" />
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn flat @click.native="claimDeviceDialog = false">Cancel</v-btn>
          <v-btn color="primary" flat @click.native="claimDevice()">Claim</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

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
import { auth } from '@/Auth'
import DeviceDetail from '@/components/DeviceDetail'
import Device from '@/device'

export default {
  components: {
    DeviceDetail
  },
  data () {
    return {
      authenticated: auth.authenticated,
      selectedDevice: false,
      devices: [],
      loading: false,

      claimDeviceDialog: false,
      claimingDevice: {},
      claimCode: '',
      snackbar: false,
      snackbarText: '',
      snackbarColor: ''
    }
  },
  methods: {
    fetchDevices () {
      this.loading = true
      axios.get('/api/devices')
        .then(response => {
          this.loading = false
          this.devices = response.data.map(device => {
            Object.assign(device, { $socket: this.$socket, $options: this.$options, $set: this.$set })
            const d = new Device(device)
            d.subscribe()
            return d
          })
        }).catch(err => {
          this.loading = false
        })
    },
    claimDevice () {
      const url = `/api/claim`
      return axios.post(url, { claimCode: this.claimCode }).then(response => {
        if (response.data && response.data.error) {
          this.snackbar = true
          this.snackbarColor = 'error'
          this.snackbarText = response.data.error
          this.claimDeviceDialog = false
        } else {
          this.claimCode = ''
          this.snackbar = true
          this.snackbarColor = 'success'
          this.snackbarText = 'Claimed device successfully'
          this.claimDeviceDialog = false
          this.fetchDevices()
        }
      }).catch(err => {
        console.warn(err)
      })
    }
  },
  computed: {
    yourDevices () {
      return _.filter(this.devices, device => device.meta.claimedBy === this.profile.id.toString())
    },
    profile () {
      return auth.profile() || {}
    }
  },
  mounted () {
    this.fetchDevices()
  },
  watch: {
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style>
.active {
  background-color: #2C9DB639 !important;
}

</style>
