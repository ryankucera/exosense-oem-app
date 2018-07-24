<template>
  <v-container v-if="device">
    <div>
      <p class="headline">{{ device.identity }}</p>
      <p class="caption" v-if="device.lastip">IP: {{ device.lastip }} &nbsp; Auth: {{ device.auth.type }}</p>
    </div>

    <v-toolbar dense class="mt-5" color="primary" small>
      <v-toolbar-title>
        data_in
      </v-toolbar-title>
      <v-spacer />
      {{ device.dataIn.timestamp | moment(timestampFormat) || "Has not reported" }}
    </v-toolbar>
    <div class="resource-value">
      <pre v-if="device.dataIn.reported" class="pa-4 mb-2 api-result">{{ device.dataIn.reported }}</pre>
    </div>

    <v-toolbar dense class="mt-5" color="primary" small v-if="device.configIo && device.configIo.reported">
      <v-toolbar-title>
        config_io
      </v-toolbar-title>
      <v-spacer />
      {{ device.configIo.timestamp | moment(timestampFormat) || "Has not reported"}}
    </v-toolbar>
    <div class="resource-value">
      <pre v-if="device.configIo.reported" class="pa-4 mb-2 api-result">{{ device.configIo.reported }}</pre>
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
.api-result {
  background-color: #222736;
  color: #efefef;
}
</style>
