'use strict'

const fs = require('fs-extra')
const path = require('path')
const sqlite3 = require('sqlite3').verbose()
const StreamArray = require('stream-json/utils/StreamArray')
const zlib = require('zlib')
const http = require('http')

class LocationsSQLiteGenerator {

  constructor(inputFileUrl, temporaryFilePath, templateFilePath, outputFilePath) {
    this.inputFileUrl = inputFileUrl
    this.temporaryFilePath = temporaryFilePath
    this.templateFilePath = templateFilePath
    this.outputFilePath = outputFilePath
  }

  run() {
    this.downloadCityList(() => {
      this.extractCityList()
    })
  }

  downloadCityList(callback) {
    
    const temporaryFilePath = path.join(__dirname, this.temporaryFilePath)
    const gunzip = zlib.createGunzip()

    http.get(this.inputFileUrl, (res) => {
      const buffer = []

      res
        .pipe(gunzip)
        .on('data', (chunk) => {
          buffer.push(chunk.toString())
        })
        .on('end', () => {
          const writer = fs.createWriteStream(temporaryFilePath)
          writer.write(buffer.join(''))
          writer.end(() => {
           callback()
          })
        })
    })
  }

  extractCityList() {
    const templateFilePath = path.join(__dirname, this.templateFilePath)
    const outputFilePath = path.join(__dirname, this.outputFilePath)
    const temporaryFilePath = path.join(__dirname, this.temporaryFilePath)

    fs.copySync(templateFilePath, outputFilePath)
    
    const jsonStream = StreamArray.make()
    const db = new sqlite3.Database(outputFilePath)

    fs.createReadStream(temporaryFilePath).pipe(jsonStream.input)
    
    jsonStream.output.on('data', (object) => {
      db.serialize(() => {
        db.run('INSERT INTO locations(id, name, state, country, latitude, longitude) VALUES ($id, $name, $state, $country, $latitude, $longitude)', {
          $id: object.value.id,
          $name: object.value.name,
          $state: object.value.state,
          $country: object.value.country,
          $latitude: object.value.coord.lat,
          $longitude: object.value.coord.lon
        }, (dbErr) => {
          if (dbErr) {
            console.log('DB Write Error:', dbErr)
          }
        })
      })
    })

    jsonStream.output.on('end', () => {
      console.log('Stream did end')
      fs.unlinkSync(temporaryFilePath)
      db.close()
    })
  }
}

module.exports = LocationsSQLiteGenerator
