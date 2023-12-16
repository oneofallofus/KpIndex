    import QtQuick 2.15
    import QtQuick.Controls 2.15
    import QtQuick.Layouts 1.15
    import org.kde.plasma.core 2.0 as PlasmaCore
    import org.kde.plasma.components 3.0 as PlasmaComponents
    import org.kde.plasma.plasmoid 2.0


    Item {
        id: root


        // Function to open new window with image
        function openImageWindow(imageSource) {
            var component = Qt.createComponent("ImageWindow.qml");
            if (component.status === Component.Ready) {
                var imageWindow = component.createObject(root, {"imageSource": imageSource});
                imageWindow.show();
            } else {
                console.error("Error loading ImageWindow.qml:", component.errorString());
            }
        }
        function openTextWindow(textFileUrl) {
            var component = Qt.createComponent("TextWindow.qml");
            if (component.status === Component.Ready) {
                var textWindow = component.createObject(root, {"textFileUrl": textFileUrl});
                textWindow.show();
            } else {
                console.error("Error loading TextWindow.qml:", component.errorString());
            }
        }

        // Links for North and South
        Column {

            spacing: 0 // Add some space between the North and South text items
            anchors.top: parent.top
            anchors.topMargin: 7// Adjust this value to set the top position
            anchors.right: parent.right
            anchors.margins: 20

            Text {
                text: "North"
                font.pixelSize: 10 // Set the font size
                font.bold: true // Make the font bold
                color: "#25b6c3" // A more vibrant blue color
                MouseArea {
                    cursorShape: Qt.PointingHandCursor // Change cursor to a hand when hovering over the text
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#0cffe1" // Darken the text color on hover
                    onExited: parent.color = "#25b6c3" // Revert the text color when not hovering
                    onClicked: openImageWindow("https://services.swpc.noaa.gov/images/animations/ovation/north/latest.jpg")
                }
            }

            Text {
                text: "South "
                font.pixelSize: 10 // Set the font size
                font.bold: true // Make the font bold
                color: "#25b6c3" // A more vibrant blue color
                MouseArea {
                    cursorShape: Qt.PointingHandCursor // Change cursor to a hand when hovering over the text
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#0cffe1" // Darken the text color on hover
                    onExited: parent.color = "#25b6c3" // Revert the text color when not hovering
                    onClicked: openImageWindow("https://services.swpc.noaa.gov/images/animations/ovation/south/latest.jpg")
                }
            }
            Text {
                text: "Forecast"
                font.pixelSize: 10
                font.bold: true
                color: "#25b6c3"
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#0cffe1"
                    onExited: parent.color = "#25b6c3"
                    onClicked: {
                        var link = "https://services.swpc.noaa.gov/text/3-day-forecast.txt";
                        Qt.openUrlExternally(link); // Open the link in the default web browser
                    }
                }
            }
                       Text {
                text: "SolarHam"
                font.pixelSize: 10
                font.bold: true
                color: "#25b6c3"
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#0cffe1"
                    onExited: parent.color = "#25b6c3"
                    onClicked: {
                        var link = "https://www.solarham.net/";
                        Qt.openUrlExternally(link); // Open the link in the default web browser
                    }
                }
            }
            Text {
                text: "Info "
                font.pixelSize: 10 // Set the font size
                font.bold: true // Make the font bold
                color: "#25b6c3" // A more vibrant blue color
                MouseArea {
                    cursorShape: Qt.PointingHandCursor // Change cursor to a hand when hovering over the text
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#0cffe1" // Darken the text color on hover
                    onExited: parent.color = "#25b6c3" // Revert the text color when not hovering
                    onClicked: openImageWindow("../images/background.png")
                }
            }


        }

        Plasmoid.compactRepresentation: Item{
            Image {
                id: myIcon
                source: "kp.svg"
                anchors.fill: parent
            }
        }

        Timer {
            id: refreshTimer
            interval: 60000 // Check every minute
            repeat: true
            running: true
            property var lastUpdateTime: new Date()

            onTriggered: {
                var now = new Date();
                // Check if 10 minutes have passed since the last update
                if (now - lastUpdateTime >= 600000) {
                    downloadKpIndex(processData);
                    lastUpdateTime = now;
                }
            }
        }

        property int numberOfBars: 20
        property var kpData: [] // This will hold the processed data for the last 'numberOfBars' entries
        property var forecastData: [] // Will hold processed forecast data


        Component.onCompleted: {
            console.log("Component completed. Starting download of KpIndex data.")
            downloadKpIndex(processData)
        }

        function request(url, callback) {
            var xhr = new XMLHttpRequest()
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        callback(xhr.responseText)
                    } else {
                        console.error("Request for " + url + " returned status " + xhr.status)
                    }
                }
            }
            xhr.open('GET', url, true)
            xhr.send()
        }

        function downloadKpIndex(callback) {
            var url = "https://services.swpc.noaa.gov/products/noaa-planetary-k-index.json";
            console.log("Starting download from:", url)

            request(url, function(data) {
                console.log("Data received. Length:", data.length)
                if (data.length !== 0) {
                    try {
                        var json = JSON.parse(data);
                        var kpData = json.slice(1).map(function(item) {
                            return {
                                time_tag: item[0],
                                Kp: parseFloat(item[1])
                            };
                        });
                        callback(kpData); // Pass the Kp data array to the callback
                    } catch (error) {
                        console.error("downloadKpIndex(): Response parsing failed for '" + url + "'");
                        console.error("downloadKpIndex(): error: '" + error + "'");
                        console.error("downloadKpIndex(): data: '" + data + "'");
                    }
                }
            });
        }

        function downloadForecast() {
            var url = "https://services.swpc.noaa.gov/text/3-day-forecast.txt";
            request(url, function(data) {
                forecastData = parseForecastData(data);
                processForecastData(); // Merge and redraw after getting forecast data
            });
        }
        function parseForecastData(forecastText) {
            // Define a helper function to convert month abbreviation to its number equivalent
            function getMonthNumber(monthAbbr) {
                const months = {
                    Jan: '01', Feb: '02', Mar: '03', Apr: '04', May: '05', Jun: '06',
                    Jul: '07', Aug: '08', Sep: '09', Oct: '10', Nov: '11', Dec: '12'
                };
                return months[monthAbbr];
            }

            // Remove all (Gn) values from the data
            var cleanedText = forecastText.replace(/\(G\d\)/g, '');
            var lines = cleanedText.split('\n');
            var dateLineIndex = lines.findIndex(line => line.includes("NOAA Kp index breakdown"));

            // Extract the starting date from the header
            var startDateMatch = lines[dateLineIndex].match(/(\w{3})\s(\d{2})/);
            if (!startDateMatch) {
                console.error('No start date found in the forecast.');
                return [];
            }
            var monthNumber = getMonthNumber(startDateMatch[1]);
            var startDate = new Date(`${new Date().getFullYear()}-${monthNumber}-${startDateMatch[2]}`);

            var forecastDataByDate = [[], [], []]; // Three arrays for three columns
            for (var i = dateLineIndex + 2; i < lines.length; i++) {
                var line = lines[i].trim();
                if (line.length === 0 || line.includes("Rationale:")) break;

                var columns = line.split(/\s+/);
                var time = columns.shift(); // Remove and store the time
                var formattedTime = time.substring(0, 2) + ":00:00";

                columns.forEach((column, index) => {
                    if (index >= forecastDataByDate.length) return;

                    var kpValue = column.match(/\d+\.\d+/);
                    if (!kpValue) return;

                    // Calculate the date for the column
                    var forecastDate = new Date(startDate);
                    forecastDate.setDate(startDate.getDate() + index);

                    var dateTimeString = forecastDate.toISOString().split('T')[0] + " " + formattedTime;
                    var entry = [dateTimeString, parseFloat(kpValue[0])];

                    forecastDataByDate[index].push(entry);
                });
            }

            var flattenedData = [];
            forecastDataByDate.forEach(function(dataArray) {
                dataArray.forEach(function(item) {
                    flattenedData.push({
                        time_tag: item[0],
                        Kp: item[1]
                    });
                });
            });
            console.log("Parsed forecast data:", JSON.stringify(flattenedData));

            return flattenedData;
        }




        // Modify processData to call downloadForecast after processing historical data
        function processData(data) {
            console.log("Processing historical data");
            kpData = data.slice(-numberOfBars);
            //chartCanvas.requestPaint(); // Redraw chart with historical data
            console.log("Historical data processed, now downloading forecast data");
            downloadForecast(); // After historical data, download forecast data
        }

        function processForecastData() {
            // Standardize the format of historical data
            var standardizedHistoricalData = kpData.map(function(data) {
                return {
                    time_tag: data.time_tag.substring(0, 19), // Remove milliseconds
                                                        Kp: data.Kp
                };
            });

            console.log("Standardized historical data: " + JSON.stringify(standardizedHistoricalData));

            // Merge standardized historical data with forecast data
            var mergedData = mergeDataSets(standardizedHistoricalData, forecastData);
            console.log("Merged data: " + JSON.stringify(mergedData));
            kpData = mergedData; // Update kpData with merged data
            chartCanvas.requestPaint(); // Redraw the chart with new data
        }

        function mergeDataSets(historicalData, forecastData) {
            // Create a set of time tags from historical data for quick lookup
            var historicalTimeTags = new Set(historicalData.map(data => data.time_tag));

            // Filter out forecast data entries with time tags already in historical data
            var filteredForecastData = forecastData.filter(data => !historicalTimeTags.has(data.time_tag));

            // Then merge the historical data with the filtered forecast data
            return historicalData.concat(filteredForecastData);
        }


        function getColorForKpValue(kp) {
            // Convert Kp value range from 0-9 to hue value range in degrees (0 - 120, where 0 is red and 120 is green)
            var hue = 120 - (kp / 9) * 120;
            return hsvToRgb(hue, 1, 1); // Full saturation and full value for vivid colors
        }

        function hsvToRgb(h, s, v) {
            var r, g, b, i, f, p, q, t;
            i = Math.floor(h / 60) % 6;
            f = h / 60 - i;
            p = v * (1 - s);
            q = v * (1 - f * s);
            t = v * (1 - (1 - f) * s);

            switch (i) {
                case 0: r = v, g = t, b = p; break;
                case 1: r = q, g = v, b = p; break;
                case 2: r = p, g = v, b = t; break;
                case 3: r = p, g = q, b = v; break;
                case 4: r = t, g = p, b = v; break;
                case 5: r = v, g = p, b = q; break;
            }

            return Qt.rgba(r, g, b, 1); // The last parameter '1' is for full opacity
        }



        Canvas {
            id: chartCanvas
            width: parent.width
            height: parent.height
            anchors.top: parent.top
            anchors.left: parent.left
            // Add a MouseArea for handling clicks on the forecast text

            onPaint: {
                var ctx = getContext("2d");
                var maxKp = 9; // Fixed to the max KP index
                var paddingLeft = 20; // Padding on the left
                var paddingRight = 20; // Padding on the right
                var paddingBottom = 30; // Space for x-axis labels
                var paddingTop = 10; // Space for top margin
                var graphHeight = height - paddingBottom - paddingTop;
                var graphWidth = width - paddingLeft - paddingRight;
                var barWidth = graphWidth / kpData.length; // Adjusted for the length of kpData
                ctx.clearRect(0, 0, width, height); // Clear the canvas

                // Sort kpData by time_tag
                kpData.sort(function(a, b) {
                    return new Date(a.time_tag) - new Date(b.time_tag);
                });

                // Draw horizontal grid lines and y-axis labels
                for (var i = 0; i <= maxKp; i++) {
                    var y = paddingTop + graphHeight - (i / maxKp) * graphHeight;
                    ctx.beginPath();
                    ctx.moveTo(paddingLeft, y);
                    ctx.lineTo(width - paddingRight, y);
                    ctx.strokeStyle = "#ddd";
                    ctx.stroke();
                    ctx.fillStyle = "#000";
                    ctx.textAlign = "right";
                    ctx.fillText(i.toString(), paddingLeft - 5, y + 3);
                }

                // Draw bars and x-axis labels, and background for forecast data
                var lastDay = -1;
                var forecastStartIndex = numberOfBars; // Index where forecast data starts

                // Draw a darker background and "Forecast" text for forecasted data
                if (forecastStartIndex < kpData.length) {
                    var forecastStartX = paddingLeft + forecastStartIndex * barWidth;
                    // Draw semi-transparent black background
                    ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
                    ctx.fillRect(forecastStartX, paddingTop, width - forecastStartX - paddingRight, graphHeight);

                    // Draw "Forecast" text
                    ctx.fillStyle = "#fff"; // White color for the text
                    ctx.font = "10px sans-serif"; // Adjust the font size and style as needed
                    ctx.textAlign = "left";
                    ctx.fillText("Forecast", forecastStartX + 5, paddingTop + 20); // Position the text slightly inside the gray area
                }


                for (var j = 0; j < kpData.length; j++) {
                    var dataPoint = kpData[j];
                    var KpValue = dataPoint.Kp;
                    var timeTag = dataPoint.time_tag;

                    var date = new Date(timeTag);
                    var day = date.getUTCDate();
                    var barHeight = (KpValue / maxKp) * graphHeight;
                    var x = paddingLeft + j * barWidth;

                    ctx.fillStyle = getColorForKpValue(KpValue);
                    ctx.fillRect(x, paddingTop + graphHeight - barHeight, barWidth - 1, barHeight);

                    if (day !== lastDay) {
                        ctx.fillStyle = "#000";
                        ctx.textAlign = "center";
                        ctx.fillText(day.toString(), x + (barWidth / 2), height - paddingBottom + 20);
                        lastDay = day;
                    }
                }

                // Draw legends for x and y axis
                ctx.fillStyle = "#000";
                ctx.textAlign = "center";
                ctx.save();
                ctx.translate(paddingLeft - 20, paddingTop + graphHeight / 2);
                ctx.rotate(-Math.PI / 2);
                ctx.restore();
            }




        }
    }

