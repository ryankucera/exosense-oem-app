<template>
  <v-container v-if="device">
    <v-toolbar dense>
      <v-toolbar-title>
        {{ device.identity }}
      </v-toolbar-title>
    </v-toolbar>
    <div>
      Last Reported: {{ device.lastReported | moment(timestampFormat) }}
    </div>
    <v-toolbar dense class="red lighten-2 mt-5" small>
      <v-toolbar-title>
        data_in
      </v-toolbar-title>
      <v-spacer />
      {{ device.dataIn.timestamp | moment(timestampFormat) }}
    </v-toolbar>
    <div class="resource-value">
      <pre class="ma-3 pa-3 caption">{{ device.dataIn.reported }}</pre>
    </div>

    <v-toolbar dense class="blue darken-1" small>
      <v-toolbar-title>
        config_io
      </v-toolbar-title>
      <v-spacer />
      {{ device.configIo.timestamp | moment(timestampFormat) }}
    </v-toolbar>
    <div class="resource-value">
      <pre class="ma-3 pa-3 caption">{{ device.configIo.reported }}</pre>
    </div>
  </v-container>
</template>

<script>
export default {
  props: {
    device: {
      type: [Object, Boolean],
      required: false,
      default: () => Object.assign({})
    }
  },
  data () {
    return {
      timestampFormat: 'MMMM Do YYYY, h:mm:ss a'
    }
  }
}
</script>

<style>

</style>
