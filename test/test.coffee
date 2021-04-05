'use strict'
{expect} = require 'chai'
Plugin = require '../'

data = {}

describe 'Plugin', ->
  plugin = null

  beforeEach -> plugin = new Plugin plugins: {}

  it 'should be an object', ->
    expect(plugin).to.be.an 'object'

  it 'should have #optimize method', ->
    expect(plugin).to.respondTo 'optimize'

  it 'should compile correctly', ->
    path = 'test/fixtures/one.js'
    expected = 'var x=3;\n'
    plugin.optimize({data, path})
      .then (result) ->
        expect(result.data).to.equal(expected)

  it 'should produce source maps', ->
    path = 'test/fixtures/two.js'

    expected =
      data: '(function(){window.bar=100})();\n'
      map: """{\n"version":3,\n"file":"",\n"lineCount":1,
          "mappings":"AAAC,SAAQ,EAAG,CAEVA,MAAOC,CAAAA,GAAP,CAAa,GAFH,CAAX,CAAD;",
          "sources":["test/fixtures/two.js"],\n"names":["window","bar"]\n}\n
          """

    plugin.optimize({data, path})
      .then (result) ->
        expect(result).to.eql(expected)


describe 'Plugin#Customized', ->
  it 'should respect config opts', ->
    plugin = new Plugin plugins: closurecompiler:
      compilationLevel: 'ADVANCED'
    expect(plugin.config.compilationLevel).to.equal 'ADVANCED'

  it 'should not produce source map if configured', ->
    plugin = new Plugin plugins: closurecompiler: createSourceMap: no
    path = 'test/fixtures/one.js'

    plugin.optimize({data, path})
      .then (result) ->
        expect(result.map).to.not.be.ok
