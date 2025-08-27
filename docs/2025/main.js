const GREEN = 'green';
const RED = 'red';
const GRAY = 'gray';
const GREEN_FILL = 'rgba(0, 128, 0, 0.1)';
const RED_FILL = 'rgba(255, 0, 0, 0.1)';
const GRAY_FILL = 'rgba(128, 128, 128, 0.1)';
const HIGHLIGHT_COLOR = 'blue';
const UNHIGHLIGHT_COLOR = 'rgba(128, 128, 128, 0.2)';

const createLayout = (event, eventId, outcomeText, outcomeClass) => {
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

  if (eventId !== 'all') {
    layout.title = event.short;
    layout.margin = { l: 20, r: 20, b: 20, t: 40 };
    layout.height = 150;
    d3.select('#event-description').text(event.precise);
    d3.select('#event-description').append('div').html(`<span class="outcome-chip">${outcomeText}</span>`).attr('class', outcomeClass).style('font-weight', 'bold');
  } else {
    layout.margin = { l: 20, r: 20, b: 20, t: 20 };
    layout.height = 100;
    d3.select('#event-description').text('');
  }
  return layout;
};

const createScatterTrace = (x, y, allRespondents, highlightedRespondent, responsesAndScores) => {
  const colors = allRespondents.map(u => u === highlightedRespondent ? HIGHLIGHT_COLOR : UNHIGHLIGHT_COLOR);
  const customdata = allRespondents.map((_, index) => {
    const prediction = x[index].toFixed(2);
    return { prediction };
  });

  return {
    x: x,
    y: y,
    type: 'scatter',
    mode: 'markers',
    text: allRespondents,
    customdata: customdata,
    hovertemplate: '<b>%{customdata.prediction}</b> %{text}<extra></extra>',
    marker: {
      size: 10,
      color: colors
    }
  };
};

function renderStandings(responsesAndScores) {
  const container = document.getElementById('standings-container');
  container.innerHTML = '';

  const standings = [];
  for (const respondent in responsesAndScores) {
    const respondentData = responsesAndScores[respondent];
    const meanTotalScore = respondentData.scores.mean_score;
    standings.push({ respondent: respondent, meanTotalScore: meanTotalScore });
  }

  standings.sort((a, b) => {
    if (isNaN(a.meanTotalScore) && isNaN(b.meanTotalScore)) return 0;
    if (isNaN(a.meanTotalScore)) return 1;
    if (isNaN(b.meanTotalScore)) return -1;
    return b.meanTotalScore - a.meanTotalScore; // Sort descending
  });

  const respondents = standings.map(s => s.respondent);
  const displayScores = standings.map(s => s.meanTotalScore);

  const finiteScores = displayScores.filter(s => isFinite(s));
  const maxAbsScore = finiteScores.length > 0 ? Math.max(...finiteScores.map(s => Math.abs(s))) : 1;

  const finalDisplayScores = displayScores.map(s => {
    if (s === Infinity) return maxAbsScore * 1.1;
    if (s === -Infinity) return -maxAbsScore * 1.1;
    return s;
  });

  const data = [{
    y: respondents,
    x: finalDisplayScores,
    type: 'bar',
    orientation: 'h',
    text: displayScores.map(s => {
      if (s === Infinity) return '∞';
      if (s === -Infinity) return '-∞';
      if (isNaN(s)) return 'NaN';
      return s.toFixed(3);
    }),
    textposition: 'auto',
    hoverinfo: 'none',
    textfont: {
      size: 10
    },
    marker: {
      color: displayScores.map(score => score >= 0 ? GREEN_FILL : RED_FILL),
      line: {
        color: displayScores.map(score => score >= 0 ? GREEN : RED),
        width: 1
      }
    }
  }];

  const layout = {
    title: 'Standings',
    yaxis: {
      autorange: 'reversed',
      automargin: true,
      tickfont: {
        size: 10
      },
      fixedrange: true
    },
    xaxis: {
      title: '',
      showticklabels: false,
      zeroline: false,
      fixedrange: true
    },
    shapes: [{
      type: 'line',
      x0: 0,
      y0: -0.5,
      x1: 0,
      y1: respondents.length - 0.5,
      line: {
        color: 'black',
        width: 1,
      }
    }],
    margin: {
      l: 200,
      r: 20,
      t: 40,
      b: 40
    },
    height: 20 * respondents.length + 80,
  };

  Plotly.newPlot(container, data, layout, { displayModeBar: false });
}

function renderSubmissionsTable(eventId, responsesAndScores, highlightedRespondent) {
  const container = document.getElementById('submissions-table-container');
  container.innerHTML = '';

  if (eventId === 'all') {
    return;
  }

  const sortedRespondents = Object.keys(responsesAndScores).sort((a, b) => {
    const scoreA = (responsesAndScores[a] && responsesAndScores[a].scores.mean_score) ? responsesAndScores[a].scores.mean_score : -Infinity;
    const scoreB = (responsesAndScores[b] && responsesAndScores[b].scores.mean_score) ? responsesAndScores[b].scores.mean_score : -Infinity;
    return scoreB - scoreA;
  });

  const table = d3.select(container).append('table').attr('class', 'table');
  const thead = table.append('thead');
  const tbody = table.append('tbody');

  thead.append('tr')
    .selectAll('th')
    .data(['Respondent', 'Submission', 'Score'])
    .enter()
    .append('th')
    .text(d => d);

  const rows = tbody.selectAll('tr')
    .data(sortedRespondents)
    .enter()
    .append('tr')
    .attr('class', d => d === highlightedRespondent ? 'highlighted' : null);

  rows.append('td').text(d => d);
  rows.append('td').text(d => responsesAndScores[d].responses.probabilities[eventId]);
  rows.append('td').text(d => {
    const respondent = d;
    if (responsesAndScores[respondent] && responsesAndScores[respondent].scores.event_scores && responsesAndScores[respondent].scores.event_scores[eventId]) {
      return responsesAndScores[respondent].scores.event_scores[eventId].toFixed(3);
    }
    return 'N/A';
  });
}

Promise.all([
  d3.json('events.json'),
  d3.text('responses_and_scores.json')
]).then(([events, responsesAndScoresText]) => {
  const responsesAndScores = JSON.parse(responsesAndScoresText
    .replace(/-Infinity/g, '"__NEGATIVE_INFINITY__"')
    .replace(/Infinity/g, '"__INFINITY__"')
    .replace(/NaN/g, '"__NAN__"'), function (key, value) {
      if (typeof value === 'string') {
        if (value === '__INFINITY__') return Infinity;
        if (value === '__NEGATIVE_INFINITY__') return -Infinity;
        if (value === '__NAN__') return NaN;
      }
      return value;
    });

  const allEvents = [{ id: 'all', short: 'All' }, ...events];

  const plotTypeDropdown = d3.select('#plot-type-dropdown');
  const eventDropdown = d3.select('#event-dropdown');
  const respondentDropdown = d3.select('#respondent-dropdown');

  eventDropdown.selectAll('option')
    .data(allEvents)
    .enter()
    .append('option')
    .attr('value', d => d.id)
    .text(d => d.short);

  const respondents = Object.keys(responsesAndScores).sort();
  respondentDropdown.selectAll('option')
    .data(['No respondent selected', ...respondents])
    .enter()
    .append('option')
    .attr('value', d => d)
    .text(d => d);

  // Set initial dropdown values
  plotTypeDropdown.property('value', 'density');
  eventDropdown.property('value', 'all');
  respondentDropdown.property('value', 'No respondent selected');

  const attachClickHandler = (plotContainerId) => {
    document.getElementById(plotContainerId).on('plotly_click', function (data) {
      if (data.points.length > 0) {
        const point = data.points[0];
        if (point.curveNumber === 1) { // scatter plot trace
          const respondent = point.text;
          respondentDropdown.property('value', respondent);
          plotData(eventDropdown.property('value'), respondent, plotTypeDropdown.property('value'));
        }
      }
    });
  };

  const renderPlot = (plotContainer, event, eventData, allRespondents,
    highlightedRespondent, responsesAndScores, plotType, fillColor, lineColor, outcomeText,
    outcomeClass, eventId) => {
    const layout = createLayout(event, eventId, outcomeText, outcomeClass);
    let traces;

    if (plotType === 'density') {
      const trace1 = {
        x: eventData,
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
      const trace2 = createScatterTrace(eventData, Array(eventData.length).fill(' '), allRespondents, highlightedRespondent, responsesAndScores, event.id);
      traces = [trace1, trace2];
    } else { // CDF
      const n = eventData.length;
      const sortedData = [...eventData].sort(d3.ascending);

      const cdfX = [0, ...sortedData, 1];
      const cdfY = [0, ...sortedData.map((d, i) => (i + 1) / n), 1];

      const cdfTrace = {
        x: cdfX,
        y: cdfY,
        mode: 'lines',
        type: 'scatter',
        name: 'Cumulative',
        hoverinfo: 'none',
        line: { color: lineColor },
        fill: 'tozeroy',
        fillcolor: fillColor
      };

      const freqMap = d3.rollup(eventData, v => v.length, d => d);
      const uniqueSorted = Array.from(freqMap.keys()).sort(d3.ascending);
      const cdfMap = new Map();
      let cumulative = 0;
      for (const val of uniqueSorted) {
        cumulative += freqMap.get(val);
        cdfMap.set(val, cumulative / n);
      }
      const respondentPointsY = eventData.map(p => cdfMap.get(p));
      const scatterTrace = createScatterTrace(eventData, respondentPointsY, allRespondents, highlightedRespondent, responsesAndScores, event.id);
      traces = [cdfTrace, scatterTrace];
      layout.yaxis.range = [0, 1.1];
    }

    Plotly.newPlot(plotContainer.attr('id'), traces, layout, { displayModeBar: false });
    attachClickHandler(plotContainer.attr('id'));
  }

  const plotData = (eventId, highlightedRespondent, plotType) => {
    const plotDiv = d3.select('#plot');
    plotDiv.html(''); // Clear previous plot(s)

    renderSubmissionsTable(eventId, responsesAndScores, highlightedRespondent);

    const eventsToPlot = (eventId === 'all') ? events : events.filter(e => e.id == eventId);

    eventsToPlot.forEach(event => {
      const allRespondents = Object.keys(responsesAndScores);
      const eventData = allRespondents.map(respondent => responsesAndScores[respondent].responses.probabilities[event.id]);

      const outcomeText = event.outcome[0];
      const outcomeClass = `outcome-${outcomeText.toLowerCase()}`;

      let fillColor, lineColor;
      if (outcomeText === 'Yes') {
        fillColor = GREEN_FILL;
        lineColor = GREEN;
      } else if (outcomeText === 'No') {
        fillColor = RED_FILL;
        lineColor = RED;
      } else { // Pending
        fillColor = GRAY_FILL;
        lineColor = GRAY;
      }

      let plotContainer;
      if (eventId === 'all') {
        const row = plotDiv.append('div').attr('class', 'plot-row');
        row.append('div').attr('class', `plot-outcome ${outcomeClass}`)
          .html(`<span class="outcome-chip">${outcomeText}</span>`);
        row.append('div').attr('class', 'plot-label').text(event.short);
        plotContainer = row.append('div').attr('id', 'plot-' + event.id).attr('class', 'plot-container');
      } else {
        // For a single plot, we can just use the main plot div.
        plotContainer = plotDiv.append('div').attr('id', 'plot-single');
      }

      renderPlot(plotContainer, event, eventData, allRespondents, highlightedRespondent, responsesAndScores, plotType, fillColor, lineColor, outcomeText, outcomeClass, eventId);
    });
  };

  plotTypeDropdown.on('change', function () {
    plotData(eventDropdown.property('value'), respondentDropdown.property('value'), this.value);
  });

  eventDropdown.on('change', function () {
    const selectedEventId = this.value;
    plotData(selectedEventId, respondentDropdown.property('value'), plotTypeDropdown.property('value'));
  });

  respondentDropdown.on('change', function () {
    plotData(eventDropdown.property('value'), this.value, plotTypeDropdown.property('value'));
  });

  plotData(eventDropdown.property('value'), respondentDropdown.property('value'), plotTypeDropdown.property('value'));
  renderStandings(responsesAndScores);
});
