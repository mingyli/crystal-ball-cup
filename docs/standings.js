  // Define standings outside to be accessible for sorting
  let standings = [];
  let sortColumn = 'user'; // Default sort column
  let sortDirection = 'asc'; // Default sort direction

  function renderTable(questionId) {
    const tableContainer = document.getElementById('standings-table-container');
    tableContainer.innerHTML = ''; // Clear previous table

    if (questionId === 'all') {
        // If no question is selected, don't render the table.
        // Or, render a message.
        tableContainer.innerHTML = '<p>Select a question to see the standings.</p>';
        return;
    }

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

    // Add sort indicator for user
    if (sortColumn === 'user') {
      userHeader.textContent += (sortDirection === 'asc' ? ' ▲' : ' ▼');
    }

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


    const tbody = table.createTBody();
    standings.forEach(item => {
      const row = tbody.insertRow();
      const userCell = row.insertCell();
      userCell.textContent = item.user;
      userCell.style.border = '1px solid #ddd';
      userCell.style.padding = '8px';

      const questionScoreCell = row.insertCell();
      questionScoreCell.textContent = isNaN(item.questionScore) ? 'NaN' : item.questionScore.toFixed(3);
      questionScoreCell.style.border = '1px solid #ddd';
      questionScoreCell.style.padding = '8px';
    });

    tableContainer.appendChild(table);
  }

  function sortTable(column) {
    if (sortColumn === column) {
      sortDirection = (sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      sortColumn = column;
      // Default to descending for scores, ascending for names
      sortDirection = (column === 'questionScore') ? 'desc' : 'asc';
    }

    standings.sort((a, b) => {
      let valA = a[column];
      let valB = b[column];

      // Handle NaN for sorting scores
      if (column === 'questionScore') {
        if (isNaN(valA) && isNaN(valB)) return 0;
        if (isNaN(valA)) return 1; // NaN to the end
        if (isNaN(valB)) return -1; // NaN to the end
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

    if (questionId === 'all') {
        renderTable(questionId);
        return;
    }

    for (const user in scores) { // Iterate through the new scores object
      const userData = scores[user];
      const questionScores = userData.question_scores;

      let questionScoreValue = NaN;
      if (questionId !== 'all') {
        questionScoreValue = questionScores[questionId];
      }

      standings.push({ user: user, questionScore: questionScoreValue });
    }

    // Initial sort
    sortTable(sortColumn);
  }