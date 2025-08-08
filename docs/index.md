---
title: 2025 Crystal Ball Cup
---

<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<script src="https://cdn.plot.ly/plotly-3.0.3.min.js"></script>
<script src="https://d3js.org/d3.v7.min.js"></script>
<style>
body {
    font-family: 'Inter', sans-serif;
    font-variation-settings: 'wdth' 55;
    background-color: #f8f9fa;
    color: #212529;
    max-width: 50em;
}

main {
    max-width: 80rem;
    padding: 1rem;
    margin: auto;
}

h1 {
    text-align: center;
}

select {
    width: 100%;
    padding: 0.5rem;
    margin-bottom: 1rem;
    border: 1px solid #ced4da;
    border-radius: 0.25rem;
}

#plot {
    width: 100%;
}

.plot-row {
    display: flex;
    align-items: center;
    margin-bottom: 1rem;
}

.plot-label {
    width: 150px;
    padding-right: 1rem;
}

.plot-container {
    width: calc(100% - 150px);
}

@media (max-width: 600px) {
    .plot-row {
        flex-direction: column;
        align-items: flex-start;
    }

    .plot-label {
        width: 100%;
        padding-right: 0;
        margin-bottom: 0.5rem;
        font-weight: bold;
    }

    .plot-container {
        width: 100%;
    }
}
</style>

<select id="question-dropdown"></select>
<select id="email-dropdown"></select>
<div id="question-description" style="margin-top: 1rem; font-style: italic;"></div>
<div id="plot"></div>

<script>
Promise.all([
    d3.json('events.json'),
    d3.csv('responses.csv')
]).then(([events, responses]) => {
    const allEvents = [{ id: 'all', short: 'All' }, ...events];

    const questionDropdown = d3.select('#question-dropdown');
    const emailDropdown = d3.select('#email-dropdown');

    questionDropdown.selectAll('option')
        .data(allEvents)
        .enter()
        .append('option')
        .attr('value', d => d.id)
        .text(d => d.short);

    const usernames = ['No user selected', ...responses.map(r => r.Username)];
    emailDropdown.selectAll('option')
        .data(usernames)
        .enter()
        .append('option')
        .attr('value', d => d)
        .text(d => d);

    // Set initial dropdown values
    questionDropdown.property('value', 'all');
    emailDropdown.property('value', 'No user selected');

    const plotData = (questionId, highlightedUsername) => {
        const plotDiv = d3.select('#plot');
        plotDiv.html(''); // Clear previous plot(s)

        const questionsToPlot = (questionId === 'all') ? events : events.filter(e => e.id == questionId);

        questionsToPlot.forEach(event => {
            const questionData = responses.map(r => +r[event.id]);
            const allUsernames = responses.map(r => r.Username);

            let plotContainer;
            if (questionId === 'all') {
                const row = plotDiv.append('div').attr('class', 'plot-row');
                row.append('div').attr('class', 'plot-label').text(event.short);
                plotContainer = row.append('div').attr('id', 'plot-' + event.id).attr('class', 'plot-container');
            } else {
                // For a single plot, we can just use the main plot div.
                plotContainer = plotDiv.append('div').attr('id', 'plot-single');
            }

            const trace1 = {
                x: questionData,
                type: 'violin',
                name: ' ',
                orientation: 'h',
                hoverinfo: 'none',
                box: { visible: false },
                meanline: { visible: true },
                side: 'positive',
                fillcolor: 'rgba(0, 128, 0, 0.1)',
                line: {
                    color: 'green'
                }
            };

            const colors = allUsernames.map(u => u === highlightedUsername ? 'rgba(255, 0, 0, 0.85)' : 'rgba(0, 0, 255, 0.3)');

            const trace2 = {
                x: questionData,
                y: Array(questionData.length).fill(' '),
                type: 'scatter',
                mode: 'markers',
                text: allUsernames,
                hovertemplate: '%{text}<extra></extra>',
                marker: {
                    size: 10,
                    color: colors
                }
            };

            const layout = {
                showlegend: false,
                xaxis: { range: [0, 1] },
            };

            if (questionId !== 'all') {
                layout.title = event.short;
                d3.select('#question-description').text(event.precise);
            } else {
                layout.margin = { l: 20, r: 20, b: 20, t: 20 };
                layout.height = 100;
                d3.select('#question-description').text('');
            }

            Plotly.newPlot(plotContainer.attr('id'), [trace1, trace2], layout, {displayModeBar: false});

            document.getElementById(plotContainer.attr('id')).on('plotly_click', function (data) {
                if (data.points.length > 0) {
                    const point = data.points[0];
                    if (point.curveNumber === 1) { // scatter plot trace
                        const username = point.text;
                        emailDropdown.property('value', username);
                        plotData(questionDropdown.property('value'), username);
                    }
                }
            });
        });
    };

    questionDropdown.on('change', function () {
        plotData(this.value, emailDropdown.property('value'));
    });

    emailDropdown.on('change', function () {
        plotData(questionDropdown.property('value'), this.value);
    });

    // Initial plot
    plotData(questionDropdown.property('value'), emailDropdown.property('value'));
});
</script>