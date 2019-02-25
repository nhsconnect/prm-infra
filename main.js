const fs = require("fs")
var format = require('date-format')

let project_names = new Set()
let time_series = new Set()
let data_points = []

fs.readFile(0, "utf8", function(err, data) {
    let lines = data.split("\n")
    lines.forEach(function(line) {
        if (line != "") {
            let fields = line.split("\t")

            project_names.add(fields[0])
            time_series.add(fields[1])
            data_points.push({"projectName":fields[0],"time":fields[1],"duration":fields[2]})
        }
    })
    

    // Header line
    process.stdout.write("Time,")
    project_names.forEach(function(project_name) {
        process.stdout.write(project_name + ",")
    })
    process.stdout.write("\n")

    let sorted_times = Array.from(time_series).sort()

    sorted_times.forEach(function(time) {
        let date = new Date(time * 1000)
        process.stdout.write(format.asString("yyyy-MM-dd hh:mm:ss", date) + ",")
        project_names.forEach(function(project_name) {
            data_points.forEach(function(data_point) {
                if (data_point.time === time && data_point.projectName === project_name) {
                    process.stdout.write(data_point.duration)
                }
            })
            process.stdout.write(",")
        })
        process.stdout.write("\n")
    })
})

