// answer 
//https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect

export {}

const fs = require('fs').promises
const path = require('path')
const data_path = path.resolve(__dirname, 'data', 'day03.1.txt')

class Point {
    x: number
    y: number 

    constructor(x: number, y: number) {
        this.x = x
        this.y = y
    }
}

function intersection(a: Point, b: Point, c: Point, d: Point) {
    return (a.x - b.x) * (c.y - d.y) - (a.y - b.y) * (c.x - d.x)
}

function get_intersection(a: Point, b: Point, c: Point, d: Point) {
    let divisor = intersection(a,b,c,d)
    let x = ((a.x * b.y - a.y * b.x) * (c.x - d.x) - (a.x - b.x) * (c.x * d.y - c.y * d.x)) / divisor
    let y = ((a.x * b.y - a.y * b.x) * (c.y - d.y) - (a.y - b.y) * (c.x * d.y - c.y * d.x)) / divisor
    return new Point(x, y)
}

function build_points(wire, points = [new Point(0,0)]) {
    if(wire.length == 0) return points

    let point = points.slice(-1).pop()
    let next = wire.shift()
    let vector = Number(next.substring(1))
    let direction = next.substring(0, 1)

    let x, y;
    switch (direction) {
        case 'U':
            x = point.x
            y = point.y + vector
            break;
        case 'D':
            x = point.x
            y = point.y - vector
            break;
        case 'R':
            x = point.x + vector
            y = point.y
            break;
        case 'L':
            x = point.x - vector 
            y = point.y
            break;
        default:
            throw `Unknown direction: ${direction}`
    } 

    points.push(new Point(x, y))

    return build_points(wire, points)
}

async function run() {
    // let data = await fs.readFile(data_path, "binary")
    // data = data
    //     .toString()
    //     .split("\n")
    //     .map((line) => {
    //         return line.split(',')
    //     })
    
    let data = []
    data[0] = 'R8,U5,L5,D3'.split(',')
    data[1] = 'U7,R6,D4,L4'.split(',')
    let wires = {
        a: build_points(data[0]),
        b: build_points(data[1]),
    }

    let intersections = [];
    for(let a = 0; a < wires.a.length - 1; a++) {
        for(let b = 0; b < wires.b.length - 1; b++) {
            let points = [wires.a[a], wires.a[a+1], wires.b[b], wires.b[b+1]]
            let intersect = intersection.apply(null, points)
            if(intersect !== 0) {
                intersections = get_intersection.apply(null, points)
            }
        }
    }

    console.log(intersections)
}

run()