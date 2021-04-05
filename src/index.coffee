'use strict'
fs = require 'fs'
compiler = require('google-closure-compiler').compiler
{ getNativeImagePath } = require 'google-closure-compiler/lib/utils.js'

module.exports = class ClosureCompiler
  brunchPlugin: yes

  constructor: (config) ->
    @config = Object.assign @defaultFlags, config?.plugins?.closurecompiler or {}

  defaultFlags:
    compilationLevel: 'SIMPLE'
    createSourceMap: yes

  optimize: (file) =>
    flags = {
      compilation_level: @config.compilationLevel
      js: file.path
    }

    if @config.createSourceMap
      flags.create_source_map = "#{file.path}.map"

    closureCompiler = new compiler flags
    closureCompiler.JAR_PATH = null
    closureCompiler.javaPath = getNativeImagePath()

    new Promise (resolve, reject) =>
      closureCompiler.run (exitCode, stdOut, stdErr) =>
        if exitCode isnt 0
          reject new Error("Google Closure Compiler exit #{exitCode}: #{stdErr}")
        else
          result = data: stdOut

          if @config.createSourceMap
            result.map = fs.readFileSync "#{file.path}.map", 'utf-8'

          resolve result
