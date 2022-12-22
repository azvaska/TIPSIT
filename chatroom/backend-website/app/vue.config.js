const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true
})
// const { Config } = require('./utils/config')
// const ip_addr= Config.ip_addr;

// module.exports = {
//   // pwa: {
//   //   workboxOptions: {
//   //     navigateFallback: '/index.html'
//   //   }
//   // },
//   // devServer: {
//   //   proxy: {
//   //     '^/api': {
//   //       target: `http://${ip_addr}:3080`,
//   //       changeOrigin: true
//   //     }
//   //   }
//   // }
// }