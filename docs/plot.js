Promise.all([
    d3.json('events.json'),
    d3.csv('responses.csv'),
    d3.text('scores.json') 
]).then(([events, responses, scoresText]) => { 
    const HIGHLIGHT_COLOR = 'blue';
    const UNHIGHLIGHT_COLOR = 'rgba(128, 128, 128, 0.2)';
    const allEvents = [{ id: 'all', short: 'All' }, ...events];

    // Parse scores.json with custom reviver
    const scores = JSON.parse(scoresText.replace(/-Infinity/g, '"__NEGATIVE_INFINITY__"').replace(/Infinity/g, '"__INFINITY__"').replace(/NaN/g, '"__NAN__"'), function(key, value) {
        if (typeof value === 'string') {
            if (value === '__INFINITY__') return Infinity;
            if (value === '__NEGATIVE_INFINITY__') return -Infinity;
            if (value === '__NAN__') return NaN;
        }
        return value;
    });

    const plotTypeDropdown = d3.select('#plot-type-dropdown');
    const questionDropdown = d3.select('#question-dropdown');
    const emailDropdown = d3.select('#email-dropdown');

    questionDropdown.selectAll('option')
        .data(allEvents)
        .enter()
        .append('option')
        .attr('value', d => d.id)
        .text(d => d.short);

    const usernames = responses.map(r => r['Email Address']).sort();
    emailDropdown.selectAll('option')
        .data(['No user selected', ...usernames])
        .enter()
        .append('option')
        .attr('value', d => d)
        .text(d => d);

    // Set initial dropdown values
    plotTypeDropdown.property('value', 'violin');
    questionDropdown.property('value', 'all');
    emailDropdown.property('value', 'No user selected');

    const createLayout = (event, questionId, outcomeText, outcomeClass) => {
        const layout = {
            showlegend: false,
            xaxis: { 
                range: [0, 1], 
                fixedrange: true,
                tickvals: [0, 0.25, 0.5, 0.75, 1],
                ticktext: ['0.0', '0.25', '0.5', '0.75', '1.0']
            },
            yaxis: { fixedrange: true },
        };

        if (questionId !== 'all') {
            layout.title = event.short;
            layout.margin = { l: 20, r: 20, b: 20, t: 40 };
            layout.height = 150;
            d3.select('#question-description').text(event.precise);
            d3.select('#question-description').append('div').html(`<span class="outcome-chip">${outcomeText}</span>`).attr('class', outcomeClass).style('font-weight', 'bold');
        } else {
            layout.margin = { l: 20, r: 20, b: 20, t: 20 };
            layout.height = 100;
            d3.select('#question-description').text('');
        }
        return layout;
    };

const createScatterTrace = (x, y, allUsernames, highlightedUsername, scores) => {
        const colors = allUsernames.map(u => u === highlightedUsername ? HIGHLIGHT_COLOR : UNHIGHLIGHT_COLOR);
        const customdata = allUsernames.map(u => {
            const scoreData = scores[u];
            if (!scoreData) return { prediction: 'N/A' };
            const prediction = (x[allUsernames.indexOf(u)] * 100).toFixed(1) + '%';
            return { prediction };
        });

        return {
            x: x,
            y: y,
            type: 'scatter',
            mode: 'markers',
            text: allUsernames,
            customdata: customdata,
            hovertemplate: '<b>%{text}</b><br>Prediction: %{customdata.prediction}<extra></extra>',
            marker: {
                size: 10,
                color: colors
            }
        };
    };

    const attachClickHandler = (plotContainerId) => {
        document.getElementById(plotContainerId).on('plotly_click', function (data) {
            if (data.points.length > 0) {
                const point = data.points[0];
                if (point.curveNumber === 1) { // scatter plot trace
                    const username = point.text;
                    emailDropdown.property('value', username);
                    plotData(questionDropdown.property('value'), username, plotTypeDropdown.property('value'));
                }
            }
        });
    };

    const plotData = (questionId, highlightedUsername, plotType) => {
        const plotDiv = d3.select('#plot');
        plotDiv.html(''); // Clear previous plot(s)

        const questionsToPlot = (questionId === 'all') ? events : events.filter(e => e.id == questionId);

        questionsToPlot.forEach(event => {
            const questionData = responses.map(r => +r[event.id]);
            const allUsernames = responses.map(r => r['Email Address']);

            const outcomeText = event.outcome[0];
            const outcomeClass = `outcome-${outcomeText.toLowerCase()}`;

            let fillColor, lineColor;
            if (outcomeText === 'Yes') {
                fillColor = 'rgba(0, 128, 0, 0.1)';
                lineColor = 'green';
            } else if (outcomeText === 'No') {
                fillColor = 'rgba(255, 0, 0, 0.1)';
                lineColor = 'red';
            } else { // Pending
                fillColor = 'rgba(128, 128, 128, 0.1)';
                lineColor = 'gray';
            }

            let plotContainer;
            if (questionId === 'all') {
                const row = plotDiv.append('div').attr('class', 'plot-row');
                row.append('div').attr('class', `plot-outcome ${outcomeClass}`).html(`<span class="outcome-chip">${outcomeText}</span>`);
                row.append('div').attr('class', 'plot-label').text(event.short);
                plotContainer = row.append('div').attr('id', 'plot-' + event.id).attr('class', 'plot-container');
            } else {
                // For a single plot, we can just use the main plot div.
                plotContainer = plotDiv.append('div').attr('id', 'plot-single');
            }

            const layout = createLayout(event, questionId, outcomeText, outcomeClass);
            let traces;

            if (plotType === 'violin') {
                const trace1 = {
                    x: questionData,
                    type: 'violin',
                    name: ' ',
                    orientation: 'h',
                    hoverinfo: 'none',
                    box: { visible: false },
                    meanline: { visible: true },
                    side: 'positive',
                    fillcolor: fillColor,
                    line: {
                        color: lineColor
                    },
                    points: false
                };
                const trace2 = createScatterTrace(questionData, Array(questionData.length).fill(' '), allUsernames, highlightedUsername, scores, event.id);
                traces = [trace1, trace2];
            } else { // CDF
                const n = questionData.length;
                const sortedData = [...questionData].sort(d3.ascending);

                const cdfX = [0, ...sortedData, 1];
                const cdfY = [0, ...sortedData.map((d, i) => (i + 1) / n), 1];

                const cdfTrace = {
                    x: cdfX,
                    y: cdfY,
                    mode: 'lines',
                    type: 'scatter',
                    name: 'CDF',
                    hoverinfo: 'none',
                    line: { color: lineColor },
                    fill: 'tozeroy',
                    fillcolor: fillColor
                };

                const freqMap = d3.rollup(questionData, v => v.length, d => d);
                const uniqueSorted = Array.from(freqMap.keys()).sort(d3.ascending);
                const cdfMap = new Map();
                let cumulative = 0;
                for (const val of uniqueSorted) {
                    cumulative += freqMap.get(val);
                    cdfMap.set(val, cumulative / n);
                }
                const userPointsY = questionData.map(p => cdfMap.get(p));
                const scatterTrace = createScatterTrace(questionData, userPointsY, allUsernames, highlightedUsername, scores, event.id);
                traces = [cdfTrace, scatterTrace];
                layout.yaxis.range = [0, 1.1];
            }

            Plotly.newPlot(plotContainer.attr('id'), traces, layout, {displayModeBar: false});
            attachClickHandler(plotContainer.attr('id'));
        });
    };

    plotTypeDropdown.on('change', function () {
        plotData(questionDropdown.property('value'), emailDropdown.property('value'), this.value);
    });

    questionDropdown.on('change', function () {
        const selectedQuestionId = this.value;
        plotData(selectedQuestionId, emailDropdown.property('value'), plotTypeDropdown.property('value'));
        updateStandingsTable(events, responses, scores, selectedQuestionId); // Call updateStandingsTable
    });

    emailDropdown.on('change', function () {
        plotData(questionDropdown.property('value'), this.value, plotTypeDropdown.property('value'));
    });

    // Initial plot and standings table update
    plotData(questionDropdown.property('value'), emailDropdown.property('value'), plotTypeDropdown.property('value'));
    updateStandingsTable(events, responses, scores, questionDropdown.property('value')); // Initial call for standings
});
