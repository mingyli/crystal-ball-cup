---
title: 2025 Crystal Ball Cup
---

<center>[Jump to Standings](#standings)</center>

<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<script src="https://cdn.plot.ly/plotly-3.0.3.min.js"></script>
<script src="https://d3js.org/d3.v7.min.js"></script>
<style>
html {
    background-color: #f8f9fa;
}

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
    margin-top: 1rem;
    margin-bottom: 1rem;
}

header {
    margin-top: 0.5rem;
    margin-bottom: 0.5rem;
}

p {
    margin-block-start: 0.5em;
    margin-block-end: 0.5em;
}

.dropdowns-container {
    display: flex;
    gap: 1rem; /* Space between dropdowns */
    margin-bottom: 1rem;
    flex-wrap: wrap; /* Allow wrapping on smaller screens if needed */
}

.dropdowns-container select {
    flex: 1; /* Distribute space equally among dropdowns */
    min-width: 150px; /* Ensure a minimum width for readability */
}

select {
    padding: 0.5rem;
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

.plot-outcome {
    width: 80px;
    font-weight: bold;
    text-align: center;
    padding-right: 1rem;
}

.outcome-chip {
    display: inline-block;
    padding: 0.2em 0.6em;
    border-radius: 1em;
    font-size: 0.8em;
    text-align: center;
    white-space: nowrap;
    vertical-align: middle;
    line-height: 1;
}

.outcome-pending .outcome-chip {
    background-color: rgba(128, 128, 128, 0.2);
    color: rgba(128, 128, 128, 0.8);
}

.outcome-yes .outcome-chip {
    background-color: rgba(0, 128, 0, 0.2);
    color: green;
}

.outcome-no .outcome-chip {
    background-color: rgba(255, 0, 0, 0.2);
    color: red;
}

.plot-container {
    width: calc(100% - 230px); /* 150px for label + 80px for outcome */
}

.all-dropdowns-container {
    display: flex;
    gap: 1rem;
    margin-bottom: 1rem;
    flex-wrap: wrap; /* Allow wrapping on smaller screens */
}

.all-dropdowns-container select {
    flex: 1; /* Distribute space equally */
    min-width: 150px; /* Ensure a minimum width for readability */
    max-width: 300px;
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

<div class="all-dropdowns-container">
<select id="question-dropdown"></select>
<select id="plot-type-dropdown">
    <option value="violin">Violin</option>
    <option value="cdf">CDF</option>
</select>
<select id="email-dropdown"></select>
</div>
<div id="question-description" style="margin-top: 1rem; font-style: italic;"></div>
<div id="plot"></div>

<script>
Promise.all([
    d3.json('events.json'),
    d3.csv('responses.csv'),
    d3.text('scores.json') // Fetch scores.json here
]).then(([events, responses, scoresText]) => { // Add scoresText to the destructuring
    const FILL_COLOR = 'rgba(0, 128, 0, 0.1)';
    const LINE_COLOR = 'green';
    const HIGHLIGHT_COLOR = 'rgba(255, 0, 0, 0.85)';
    const UNHIGHLIGHT_COLOR = 'rgba(0, 0, 255, 0.1)';
    const allEvents = [{ id: 'all', short: 'All' }, ...events];

    // Parse scores.json once
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

    const plotData = (questionId, highlightedUsername, plotType) => {
        const plotDiv = d3.select('#plot');
        plotDiv.html(''); // Clear previous plot(s)

        const questionsToPlot = (questionId === 'all') ? events : events.filter(e => e.id == questionId);

        questionsToPlot.forEach(event => {
            const questionData = responses.map(r => +r[event.id]);
            const allUsernames = responses.map(r => r['Email Address']);

            const outcomeText = event.outcome[0];
            const outcomeClass = `outcome-${outcomeText.toLowerCase()}`;

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
                    fillcolor: FILL_COLOR,
                    line: {
                        color: LINE_COLOR
                    }
                };

                const colors = allUsernames.map(u => u === highlightedUsername ? HIGHLIGHT_COLOR : UNHIGHLIGHT_COLOR);

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
                    xaxis: { range: [0, 1], fixedrange: true },
                    yaxis: { fixedrange: true },
                };

                if (questionId !== 'all') {
                            layout.title = event.short;
                            d3.select('#question-description').text(event.precise);
                            d3.select('#question-description').append('div').html(`<span class="outcome-chip">${outcomeText}</span>`).attr('class', outcomeClass).style('font-weight', 'bold');
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
                            plotData(questionDropdown.property('value'), username, plotTypeDropdown.property('value'));
                        }
                    }
                });
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
                    line: { color: LINE_COLOR },
                    fill: 'tozeroy',
                    fillcolor: FILL_COLOR
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

                const colors = allUsernames.map(u => u === highlightedUsername ? HIGHLIGHT_COLOR : UNHIGHLIGHT_COLOR);

                const scatterTrace = {
                    x: questionData,
                    y: userPointsY,
                    mode: 'markers',
                    type: 'scatter',
                    text: allUsernames,
                    hovertemplate: '%{text}<extra></extra>',
                    marker: {
                        size: 10,
                        color: colors
                    }
                };

                const layout = {
                    showlegend: false,
                    xaxis: { range: [0, 1], fixedrange: true },
                    yaxis: { range: [0, 1.1], fixedrange: true },
                };

                if (questionId !== 'all') {
                    layout.title = event.short;
                    d3.select('#question-description').text(event.precise);
                    d3.select('#question-description').append('div').html(`<span class="outcome-chip">${outcomeText}</span>`).attr('class', outcomeClass).style('font-weight', 'bold');
                } else {
                    layout.margin = { l: 20, r: 20, b: 20, t: 20 };
                    layout.height = 100;
                    d3.select('#question-description').text('');
                }

                Plotly.newPlot(plotContainer.attr('id'), [cdfTrace, scatterTrace], layout, {displayModeBar: false});

                document.getElementById(plotContainer.attr('id')).on('plotly_click', function (data) {
                    if (data.points.length > 0) {
                        const point = data.points[0];
                        if (point.curveNumber === 1) { // scatter plot trace
                            const username = point.text;
                            emailDropdown.property('value', username);
                            plotData(questionDropdown.property('value'), username, plotTypeDropdown.property('value'));
                        }
                    }
                });
            }
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
</script>

## Standings

<div id="standings-table-container"></div>

<script>
  // Define standings outside to be accessible for sorting
  let standings = [];
  let sortColumn = 'meanTotalScore'; // Default sort column
  let sortDirection = 'desc'; // Default sort direction

  function renderTable(questionId) {
    const tableContainer = document.getElementById('standings-table-container');
    tableContainer.innerHTML = ''; // Clear previous table

    const table = document.createElement('table');
    table.style.width = '100%';
    table.style.borderCollapse = 'collapse';

    const thead = table.createTHead();
    const headerRow = thead.insertRow();

    const userHeader = headerRow.insertCell();
    userHeader.textContent = 'User';
    userHeader.style.border = '1px solid #ddd';
    userHeader.style.padding = '8px';
    userHeader.style.textAlign = 'left';
    userHeader.style.cursor = 'pointer'; // Make it clickable
    userHeader.onclick = () => sortTable('user');

    const meanScoreHeader = headerRow.insertCell();
    meanScoreHeader.textContent = 'Mean Total Score';
    meanScoreHeader.style.border = '1px solid #ddd';
    meanScoreHeader.style.padding = '8px';
    meanScoreHeader.style.textAlign = 'left';
    meanScoreHeader.style.cursor = 'pointer'; // Make it clickable
    meanScoreHeader.onclick = () => sortTable('meanTotalScore');

    // Add sort indicator for meanScore
    if (sortColumn === 'user') {
      userHeader.textContent += (sortDirection === 'asc' ? ' ▲' : ' ▼');
    } else if (sortColumn === 'meanTotalScore') {
      meanScoreHeader.textContent += (sortDirection === 'asc' ? ' ▲' : ' ▼');
    }

    // Conditionally add specific question score column
    if (questionId !== 'all') {
      const questionScoreHeader = headerRow.insertCell();
      questionScoreHeader.textContent = 'Question Score';
      questionScoreHeader.style.border = '1px solid #ddd';
      questionScoreHeader.style.padding = '8px';
      questionScoreHeader.style.textAlign = 'left';
      questionScoreHeader.style.cursor = 'pointer'; // Make it clickable
      questionScoreHeader.onclick = () => sortTable('questionScore');

      // Add sort indicator for questionScore
      if (sortColumn === 'questionScore') {
        questionScoreHeader.textContent += (sortDirection === 'asc' ? ' ▲' : ' ▼');
      }
    }

    const tbody = table.createTBody();
    standings.forEach(item => {
      const row = tbody.insertRow();
      const userCell = row.insertCell();
      userCell.textContent = item.user;
      userCell.style.border = '1px solid #ddd';
      userCell.style.padding = '8px';

      const meanScoreCell = row.insertCell();
      meanScoreCell.textContent = isNaN(item.meanTotalScore) ? 'NaN' : item.meanTotalScore.toFixed(3);
      meanScoreCell.style.border = '1px solid #ddd';
      meanScoreCell.style.padding = '8px';

      if (questionId !== 'all') {
        const questionScoreCell = row.insertCell();
        questionScoreCell.textContent = isNaN(item.questionScore) ? 'NaN' : item.questionScore.toFixed(3);
        questionScoreCell.style.border = '1px solid #ddd';
        questionScoreCell.style.padding = '8px';
      }
    });

    tableContainer.appendChild(table);
  }

  function sortTable(column) {
    if (sortColumn === column) {
      sortDirection = (sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      sortColumn = column;
      sortDirection = 'desc'; // Default to descending for new column, as scores are better when higher
    }

    standings.sort((a, b) => {
      let valA = a[column];
      let valB = b[column];

      // Handle NaN for sorting scores
      if (column === 'meanTotalScore' || column === 'questionScore') {
        if (isNaN(valA) && isNaN(valB)) return 0;
        if (isNaN(valA)) return sortDirection === 'asc' ? 1 : -1; // NaN to the end
        if (isNaN(valB)) return sortDirection === 'asc' ? -1 : 1; // NaN to the end
      }

      if (valA < valB) {
        return sortDirection === 'asc' ? -1 : 1;
      }
      if (valA > valB) {
        return sortDirection === 'asc' ? 1 : -1;
      }
      return 0;
    });

    renderTable(d3.select('#question-dropdown').property('value')); // Re-render the table with sorted data
  }

  // This function will be called from the first script block
  function updateStandingsTable(events, responses, scores, questionId) {
    standings = []; // Clear previous standings

    for (const userResponse of responses) {
      const user = userResponse['Email Address'];
      let totalSumOfValidScores = 0;
      let countOfValidScores = 0;
      let questionScoreValue = NaN;

      // Always calculate mean score
      events.forEach(event => {
        const eventId = event.id;
        const score = scores[user] ? scores[user][eventId] : NaN;
        if (!isNaN(score)) {
          totalSumOfValidScores += score;
          countOfValidScores++;
        }
      });
      const meanScoreValue = countOfValidScores > 0 ? totalSumOfValidScores / countOfValidScores : NaN;

      // Calculate specific question score if applicable
      if (questionId !== 'all') {
        questionScoreValue = scores[user] ? scores[user][questionId] : NaN;
      }

      standings.push({ user: user, meanTotalScore: meanScoreValue, questionScore: questionScoreValue });
    }

    // Initial sort (highest mean score first)
    standings.sort((a, b) => b.meanTotalScore - a.meanTotalScore);
    renderTable(questionId); // Initial render
  }
</script>