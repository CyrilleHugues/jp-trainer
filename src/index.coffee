window.onload = ->
  lodash = require './lodash.custom.min.js'
  hiragana = require './hiragana.coffee'
  katakana = require './katakana.coffee'
  Vue = require './vue.min.js'

  getLRU = (list) ->
    return null unless Array.isArray(list) and list.length > 0
    samples = lodash.sampleSize(list, 5)

    sorted = samples.sort (a, b) ->
      return -1 if a.rut is undefined
      return 1 if b.rut is undefined
      return a.rut - b.rut

    sorted[0].rut = Date.now()
    sorted[0]

  existInErrors = (list, type, char) ->
    return char.tra in list[type].map (error) -> error.tra

  removeFromSessionErrors = (sessionErrors, type, char) ->
    index = sessionErrors[type].reduce (index, error, pos) ->
      return index if index isnt -1
      return pos if error.tra is char.tra
      return index
    , -1
    sessionErrors[type].splice(index, 1) if index isnt -1

  SymbolProvider = {
    getListFromType: (type) ->
      return hiragana if type is 'hiragana'
      return katakana if type is 'katakana'
      return []
  }

  computeErrorDisplay = (sessionErrors, type) ->
    sessionErrors[type].length > 0

  vue = new Vue({
    el: 'box'
    data: {
      type: ''
      list: SymbolProvider.getListFromType @type
      availableTypes: ['hiragana', 'katakana', 'kanji']
      currentChar: getLRU @list
      guess: ''
      erroredChar: null
      errorExists: false
      sessionErrors: {
        hiragana: []
        katakana: []
        kanji: []
      }
    }
    watch: {
      type: (newValue) ->
        @type = 'hiragana' unless newValue in @availableTypes
        @list = SymbolProvider.getListFromType newValue
        @currentChar = getLRU @list
        @errorExists = computeErrorDisplay @sessionErrors, @type
    }
    methods: {
      validate: ->
        if @guess.toLowerCase() is @currentChar.tra
          @erroredChar = null
          removeFromSessionErrors @sessionErrors, @type, @currentChar
        else
          @erroredChar = @currentChar
          @sessionErrors[@type].push(@currentChar) unless existInErrors @sessionErrors, @type, @currentChar
        @errorExists = computeErrorDisplay @sessionErrors, @type
        @currentChar = getLRU @list
        @guess = ''
    }
  })
