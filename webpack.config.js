var webpack = require('webpack');
var HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: './src/entry.js',
  output: {
    path: './output/',
    filename: "main.js"
  },
  module: {
      loaders: [
          { test: /\.coffee$/, loader: 'coffee' },
          { test: /\.jade$/, loader: 'jade' },
          { test: /\.less$/, loader: 'style!css!less' }
      ]
  },
  plugins: [
    new webpack.optimize.UglifyJsPlugin({minimize: true}),
    new HtmlWebpackPlugin({template: './src/index.jade'})
  ]
};
