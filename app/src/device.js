import _ from 'lodash'
import axios from '@/axios'

// Maybe do something with this to make it reactive
import Vue from 'vue'

export default class Device {
  constructor (data) {
    Object.assign(this, data)
    this.lastReported = 0
    this.base = `/devices/${data.identity}`
    const dataIn = this.state['data_in']
    if (dataIn) {
      const parsed = this.parseResource('data_in', dataIn.reported)
      dataIn.timestamp = dataIn.timestamp / 1e3
      this.dataIn = Object.assign({}, dataIn, { reported: parsed })
    }
    const configIo = this.state['config_io']
    if (configIo) {
      const parsed = this.parseResource('config_io', configIo.reported)
      configIo.timestamp = configIo.timestamp / 1e3
      this.configIo = Object.assign({}, configIo, { reported: parsed })
    }

    this.parseDevice()
  }

  parseDevice (live = false) {
    const stamps = [_.get(this._configIo, 'timestamp'), _.get(this._dataIn, 'timestamp'), this.lastseen / 1e6]
    this.lastReported = _.max(stamps)
  }

  set lastReported (data) {
    this._lastReported = data
  }

  get lastReported () {
    return this._lastReported || 0
  }

  set configIo (data) {
    this._configIo = data
  }

  get configIo () {
    return this._configIo || {}
  }

  set dataIn (data) {
    this._dataIn = data
  }

  get dataIn () {
    return this._dataIn || {}
  }

  parseResource (resource, raw) {
    let value
    try {
      value = JSON.parse(raw)
      value = JSON.stringify(value, null, 2)
    } catch (err) {
      value = `Invalid ${resource}`
    }
    return value
  }

  subscribe () {
    this.$options.sockets.onmessage = (raw) => {
      let event
      try {
        event = JSON.parse(raw.data)
      } catch (err) {
        console.warn(err)
        return
      }
      const data = event.data
      const identity = data.identity
      const payload = data.payload
      if (identity === this.identity) {
        _.each(payload, d => {
          const timestamp = d.timestamp
          const values = d.values
          _.each(values, (resource, name) => {
            const parsed = this.parseResource(name, resource)
            if (name === 'config_io') {
              this.configIo = {
                timestamp: timestamp / 1e3,
                reported: parsed
              }
            }
            if (name === 'data_in') {
              this.dataIn = {
                timestamp: timestamp / 1e3,
                reported: parsed
              }
            }
          })
        })
        this.parseDevice()
      }
    }
  }
  unsubscribe () {
    delete this.$options.sockets.onmessage
  }
  unclaim () {
    const url = `${this.base}/unclaim`
    return axios.post(url, {}).then(response => {
      this.refetch()
    })
  }
  del () {
    return axios.delete(this.base)
  }
  refetch () {
    axios.get(this.base).then(response => {
      const device = response.data
      Object.assign(this, device)
      this.parseDevice()
    })
  }
}
