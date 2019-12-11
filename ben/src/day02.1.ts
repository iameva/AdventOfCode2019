const fs = require('fs').promises
const path = require('path')
const data_path = path.resolve(__dirname, 'data', 'day02.1.txt')

const intcode_methods = {
    1: add,
    2: multiply, 
    99: stop,
}

function add() {
    return [].slice.call(arguments).reduce((acc, val) => {
        return acc += val
    }, 0)
}

function multiply() {
    return [].slice.call(arguments).reduce((acc, val) => {
        return acc *= val
    }, 0)
}

function stop() {

}

function run_intcode(index, intcode) {
    if(intcode_methods[index] == undefined) {
        throw `Unknown intcode command ${intcode[index]}`
    }
    
    if(intcode[index] == 99) {
        return intcode[0]
    }

    // run calc 
    intcode_methods[index](intcode[index + 1], intcode[index + 2])
}

async function run() {
    let data = await fs.readFile(data_path, "binary")
    // data = data
    data = [1,0,0,0,99] 
        .toString()
        .split(",")

    
}


run()