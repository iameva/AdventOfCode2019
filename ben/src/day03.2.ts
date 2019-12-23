// answer 
//https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect

export {}

const fs = require('fs').promises
const path = require('path')
const data_path = path.resolve('data', 'day03.1.txt')

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
   
    if(x == 0) x = Math.abs(x)
    if(y == 0) y = Math.abs(y)

    return new Point(x, y)
}

function in_segment(a: Point, b: Point, c: Point) {
    let min = {
        x: Math.min(a.x, b.x),
        y: Math.min(a.y, b.y),
    }
    let max = {
        x: Math.max(a.x, b.x),
        y: Math.max(a.y, b.y),
    }

    let result = false
    if(
        (c.x >= min.x && c.x <= max.x)
        && (c.y >= min.y && c.y <= max.y)
    ) {
        result = true
    }
    return result
}

function get_segment_intersection(a: Point, b: Point, c: Point, d: Point) {
    let intersect = get_intersection(a, b, c, d)

    if(in_segment(a, b, intersect) && in_segment(c, d, intersect)) {
        return intersect
    }
    return false
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

function get_steps(a, b) {
    let steps = get_wire_steps(a) + get_wire_steps(b)
    return steps
}

function get_wire_steps(wires) {
    let steps = 0
    let start = wires.shift()
    while(wires.length > 0) {
        let end = wires.shift()
        steps += Math.abs(start.x - end.x) + Math.abs(start.y - end.y)
        start = end
    }
    return steps
}

async function run() {
    let data = await fs.readFile(data_path, "binary")
    data = data
        .toString()
        .split("\n")
        .map((line) => {
            return line.split(',')
        })

    // // debugging
    // let data = []
    // data[0] = 'R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51'.split(',')
    // data[1] = 'U98,R91,D20,R16,D67,R40,U7,R15,U6,R7'.split(',')
    // // data[0] = 'U7,R6,D4,L4'.split(',')
    // // data[1] = 'R8,U5,L5,D3'.split(',')
    let wires = {
        a: build_points(data[0]),
        b: build_points(data[1]),
    }

    let intersections = [];
    let steps = [];
    for(let a = 0; a < wires.a.length - 1; a++) {
        for(let b = 0; b < wires.b.length - 1; b++) {
            let points = [wires.a[a], wires.a[a+1], wires.b[b], wires.b[b+1]]
            let intersect = intersection.apply(null, points)
            if(intersect !== 0) {
                let intersection = get_segment_intersection.apply(null, points)
                if(intersection !== false) {
                    intersections.push(intersection)
                    let seta = wires.a.slice(0, a+1).push(intersection)

                    let step = get_steps.apply(null, [
                        wires.a.slice(0, a+1).concat(intersection), 
                        wires.b.slice(0, b+1).concat(intersection),
                    ])
                    steps.push(step)
                }
            }
        }
    }

    intersections = intersections.filter(function(point) {
        return (point.x !== 0 || point.y !== 0)
    }).map(function(point) {
        return Math.abs(point.x) + Math.abs(point.y)
    })

    steps = steps.filter(function(step) {
        return step !== 0
    })

    let shortest_dist = Math.min(...intersections)
    console.log(shortest_dist)
    console.log(Math.min(...steps))
}

run()