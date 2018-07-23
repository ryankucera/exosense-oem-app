const cors = require('cors')
const express = require('express')
const proxy = require('http-proxy-middleware');

const app = express()

const target = 'https://g4yqqp81g06g00000.apps.exosite.io'
const appProxy = proxy({
  target,
  ws: true,
  logLevel: 'debug',
  changeOrigin: true,
})

app.use(cors());
app.use(appProxy);
app.listen(3000, () => console.log('Example app listening on port 3000!'))