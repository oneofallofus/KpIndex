import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 600
    height: 800

    property var forecastData: [] // This will hold the parsed forecast data

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20

        Column {
            spacing: 5

            Repeater {
                model: root.forecastData

                Text {
                    text: "" + modelData.time + ", Date: " + modelData.dayOffset +
                          ", Kp: " + modelData.Kp
                    font.pixelSize: 14
                }
            }
        }
    }

    function request(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    callback(xhr.responseText);
                } else {
                    console.error("Request failed: " + xhr.status + " - " + xhr.statusText);
                }
            }
        };
        xhr.open("GET", url, true);
        xhr.send();
    }

    function downloadForecast() {
        var url = "https://services.swpc.noaa.gov/text/3-day-forecast.txt";
        request(url, function(data) {
            root.forecastData = parseForecastData(data);
        });
    }
function parseForecastData(forecastText) {
    // Remove all (Gn) values from the data
    var cleanedText = forecastText.replace(/\(G\d\)/g, '');

    var lines = cleanedText.split('\n');
    var dateLineIndex = lines.findIndex(line => line.includes("NOAA Kp index breakdown")) + 2;

    var forecastDataByDate = [[], [], []]; // Three arrays for three columns

    for (var i = dateLineIndex + 1; i < lines.length; i++) {
        var line = lines[i].trim();
        if (line.length === 0 || line.includes("Rationale:")) break;

        var columns = line.split(/\s+/);
        var time = columns.shift(); // Remove and store the time

        // Format time to keep only the first two digits and add ":00:00"
        var formattedTime = time.substring(0, 2) + ":00:00";

        columns.forEach((column, index) => {
            if (index >= forecastDataByDate.length) return;

            var kpValue = column.match(/\d+\.\d+/);
            if (!kpValue) return;

            var entry = {
                time: formattedTime,
                dayOffset: -(index + 1),
                Kp: parseFloat(kpValue[0])
            };

            forecastDataByDate[index].push(entry);
        });
    }

    var flattenedData = [];
    forecastDataByDate.forEach(function(dataArray) {
        flattenedData = flattenedData.concat(dataArray);
    });

    return flattenedData;
}





    Component.onCompleted: {
        downloadForecast();
    }
}
