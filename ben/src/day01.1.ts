export {}

const fs = require('fs').promises
const path = require('path')
const data_path = path.resolve(__dirname, 'data', 'day01.1.txt')

async function run() {
    let data = await fs.readFile(data_path, "binary")
    data = data
        .toString()
        .split("\n")

    let result = data
        .reduce((acc, val) => {
            acc += Math.floor(Number(val) / 3) - 2
            return acc
        }, 0)
    console.log(result)
}

run()