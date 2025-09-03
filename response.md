You were right, using `plotly.react` is a better approach here for performance. I've updated the code to use `Plotly.react` instead of `Plotly.newPlot` for rendering the plots. This should make the UI more responsive when changing the event or respondent dropdowns.

I've made the following changes:
- Added a `react` function to `src/plotly/plotly.ml` and `src/plotly/plotly.mli`.
- Updated `src/bonsai/plots.ml` to use the new `react` function.