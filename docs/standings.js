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