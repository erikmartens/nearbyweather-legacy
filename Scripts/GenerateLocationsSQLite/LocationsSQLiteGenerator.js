'use strict'

const fs = require('fs-extra')
const path = require('path')
const Database = require('better-sqlite3')
const StreamArray = require('stream-json/utils/StreamArray')
const zlib = require('zlib')
const http = require('http')
const ora = require('ora')

var totalCities = 0;

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
    const db = new Database(outputFilePath)

    fs.createReadStream(temporaryFilePath).pipe(jsonStream.input)

    const spinner = ora('Writing locations to database')
    spinner.color = 'white'

    const begin = db.prepare('BEGIN');
    const commit = db.prepare('COMMIT');
    const rollback = db.prepare('ROLLBACK');
    const insertStatement = db.prepare('INSERT INTO locations VALUES ($id, $name, $state, $country, $latitude, $longitude)')

    begin.run()
    spinner.start()    

    jsonStream.output.on('data', (object) => {
      try {
        insertStatement.run({
          id: object.value.id.toString(),
          name: object.value.name,
          state: object.value.state,
          country: object.value.country,
          latitude: object.value.coord.lat,
          longitude: object.value.coord.lon
        })
      } catch (error) {
        console.log('DB write error', error)
        rollback.run()
      }
    })

    jsonStream.output.on('end', () => {
      console.log('Stream did end')

      commit.run()
      db.close()

      spinner.stopAndPersist({symbol: '✓', text: 'Finished writing locations to database', prefixText: ''})

      fs.unlinkSync(temporaryFilePath)
    })
  }
}

module.exports = LocationsSQLiteGenerator
