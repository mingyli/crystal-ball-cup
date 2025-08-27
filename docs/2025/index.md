---
title: Crystal Ball Cup 2025
---

<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<script src="https://cdn.plot.ly/plotly-3.0.3.min.js"></script>
<script src="https://d3js.org/d3.v7.min.js"></script>
<style>

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

## Standings

<div id="standings-container"></div>

## Events

<div class="all-dropdowns-container">
<select id="event-dropdown"></select>
<select id="plot-type-dropdown">
    <option value="density">Density</option>
    <option value="cumulative">Cumulative</option>
</select>
<select id="respondent-dropdown"></select>
</div>
<div id="event-description" style="margin-top: 1rem; font-style: italic;"></div>
<div id="plot"></div>
<div id="submissions-table-container"></div>
<script src="main.js"></script>

## Explorer

<script src="https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/sql-wasm.js"></script>

<style>
    #query-editor {
        width: 100%;
        height: 150px;
        font-family: monospace;
        margin-bottom: 10px;
    }
    #query-results {
        width: 100%;
        border-collapse: collapse;
        margin-top: 10px;
    }
    #query-results th, #query-results td {
        border: 1px solid #ddd;
        padding: 8px;
        text-align: left;
    }
    #query-results th {
        background-color: #f2f2f2;
    }
</style>

<div id="explorer-section">
  <textarea id="query-editor">SELECT name FROM sqlite_master WHERE type='table';</textarea>
  <button id="run-query-btn">Run Query</button>
  <pre id="query-error" style="color: red;"></pre>
  <table id="query-results"></table>
</div>

<script>
    async function initializeDatabaseExplorer() {
        try {
            const SQL = await initSqlJs({
                locateFile: file => `https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/${file}`
            });

            const response = await fetch('crystal.db');
            const buffer = await response.arrayBuffer();
            const db = new SQL.Database(new Uint8Array(buffer));

            const queryEditor = document.getElementById('query-editor');
            const runQueryBtn = document.getElementById('run-query-btn');
            const queryResults = document.getElementById('query-results');
            const queryError = document.getElementById('query-error');

            runQueryBtn.addEventListener('click', () => {
                queryError.textContent = '';
                queryResults.innerHTML = '';
                try {
                    const stmt = queryEditor.value;
                    const res = db.exec(stmt);

                    if (res.length === 0) {
                        queryResults.innerHTML = '<tr><td>No results</td></tr>';
                        return;
                    }

                    res.forEach(table => {
                        const headerRow = document.createElement('tr');
                        table.columns.forEach(col => {
                            const th = document.createElement('th');
                            th.textContent = col;
                            headerRow.appendChild(th);
                        });
                        queryResults.appendChild(headerRow);

                        table.values.forEach(row => {
                            const dataRow = document.createElement('tr');
                            row.forEach(val => {
                                const td = document.createElement('td');
                                td.textContent = val;
                                dataRow.appendChild(td);
                            });
                            queryResults.appendChild(dataRow);
                        });
                    });

                } catch (err) {
                    queryError.textContent = err.message;
                }
            });

            // Run initial query
            runQueryBtn.click();

        } catch (err) {
            console.error("Failed to load SQL.js or database:", err);
            document.getElementById('explorer-section').innerHTML = `<p style="color: red;">Failed to load database explorer: ${err.message}</p>`;
        }
    }

    initializeDatabaseExplorer();
</script>




