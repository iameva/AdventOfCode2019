export {}

const fs = require('fs').promises
const path = require('path')
const data_path = path.resolve('data', 'day04.txt')

async function run() {
    let data = await fs.readFile(data_path, "binary")
    let bounds = data.split('-')
    let min = bounds[0] 
    let max = bounds[1]

    let passwords = []
    for(let num = min; num <= max; num++) {
        let has_double = false 
        let is_increasing = false 

        has_double = num
            .toString()
            .split('')
            .reduce(function(set, number) {
                if(set[number] === undefined) set[number] = 0
                set[number]++
                return set
            }, [])
            .filter(function(value, index) {
                if(value == 2) return true
            })
            .length > 0
        is_increasing = num.toString().split('').sort().join('') == num

        if(is_increasing && has_double) {
            passwords.push(num)
        }
    }

    console.log(passwords.length)
}

run()