export {}

const fs = require('fs').promises
const path = require('path')
const data_path = path.resolve(__dirname, 'data', 'day02.1.txt')

const add = function() {
    return [].slice.call(arguments).reduce((acc, val) => {
        return acc += val
    }, 0)
}

const multiply = function() {
    return [].slice.call(arguments).reduce((acc, val) => {
        if(acc == 0) return acc = val
        return acc *= val
    }, 0)
}

const end = function(intcode) {
    return intcode[0]
}

let intcode_methods = {
    1: add,
    2: multiply, 
    99: end,
}

function run_intcode(index, intcode) {
    const method = intcode_methods[intcode[index]]
    if(method == undefined) {
        throw `Unknown intcode method ${intcode[index]}, at index ${index}`
    }
    
    if(method.name == 'end') {
        return method(intcode)
    }

    if(index + 4 > intcode.length) {
        throw `Unable to run another intcode chunk, stopped at index ${index}`
    }

    // run calc 
    let result = method(intcode[intcode[index + 1]], intcode[intcode[index + 2]])
    intcode[intcode[index + 3]] = result

    return run_intcode(index + 4, intcode)
}

async function run(noun, verb) {
    let data = await fs.readFile(data_path, "binary")
    data = data
        .toString()
        .split(",")
        .map((val) => {
            return Number(val)
        })

    data[1] = noun
    data[2] = verb
    return run_intcode(0, data)

}

async function multi_run() {
    let noun, verb, result;
    for(noun = 0; noun <= 99; noun++) {
        for(verb = 0; verb <= 99; verb++) {
            result = await run(noun, verb)
            console.log(noun, verb, result)
            if(result == 19690720) {
                console.log('Final answer:')
                console.log(noun, verb)
                console.log(100 * noun + verb)
                return result
            }
        }
    }
}

multi_run()