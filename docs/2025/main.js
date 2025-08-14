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

  for (const user in scores) { // Iterate through the new scores object
    const userData = scores[user];
    const meanTotalScore = userData.mean_score;
    const questionScores = userData.question_scores;

    let questionScoreValue = NaN;
    if (questionId !== 'all') {
      questionScoreValue = questionScores[questionId];
    }

    standings.push({ user: user, meanTotalScore: meanTotalScore, questionScore: questionScoreValue });
  }

  // Initial sort (highest mean score first)
  standings.sort((a, b) => b.meanTotalScore - a.meanTotalScore);
  renderTable(questionId); // Initial render
}

Promise.all([
  d3.json('events.json'),
  d3.csv('responses.csv'),
  d3.text('scores.json')
]).then(([events, responses, scoresText]) => {
  const HIGHLIGHT_COLOR = 'blue';
  const UNHIGHLIGHT_COLOR = 'rgba(128, 128, 128, 0.2)';
  const allEvents = [{ id: 'all', short: 'All' }, ...events];

  // Parse scores.json with custom reviver
  const scores = JSON.parse(scoresText.replace(/-Infinity/g, '"__NEGATIVE_INFINITY__"').replace(/Infinity/g, '"__INFINITY__"').replace(/NaN/g, '"__NAN__"'), function (key, value) {
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
      const prediction = x[allUsernames.indexOf(u)].toFixed(2);
      return { prediction };
    });

    return {
      x: x,
      y: y,
      type: 'scatter',
      mode: 'markers',
      text: allUsernames,
      customdata: customdata,
      hovertemplate: '<b>%{customdata.prediction}</b> %{text}<extra></extra>',
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

      Plotly.newPlot(plotContainer.attr('id'), traces, layout, { displayModeBar: false });
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
