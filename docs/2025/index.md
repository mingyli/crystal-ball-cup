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

## Standings

<div id="standings-table-container"></div>
<script src="main.js"></script>

[Back to home](../) | [Back to top](#title-block-header)