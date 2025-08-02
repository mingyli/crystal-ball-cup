import pandas as pd
import plotly.graph_objects as go
import json

# --- Load and Prepare Data ---

# Load response data
df = pd.read_csv("../gen/responses.csv")

# Load event data for question strings
with open("../gen/events.json", 'r') as f:
    events_data = json.load(f)

# Create a mapping from question ID to short question string
question_map = {event['id']: event['short'] for event in events_data}

# Melt the dataframe to long format
df_long = df.melt(id_vars=["Timestamp", "Username"], var_name="Question", value_name="Response")

# --- Data Cleaning and Preparation ---
df_long["Question"] = pd.to_numeric(df_long["Question"])
df_long["Response"] = pd.to_numeric(df_long["Response"], errors='coerce')
df_long.dropna(subset=['Response'], inplace=True)
df_long.sort_values("Question", inplace=True)

# --- Create the Base Figure ---
fig = go.Figure()

# Get unique questions for y-axis setup
questions = sorted(df_long["Question"].unique())
respondents = df_long["Username"].unique()

# --- Add the Violin Traces (Density Plots) ---
for q in questions:
    fig.add_trace(go.Violin(
        x=df_long[df_long["Question"] == q]['Response'],
        y0=q, # Assign to a specific y-level
        name=question_map.get(q, f"Question {q}"), # Use the short question string
        side='negative',
        orientation='h',
        width=1, # Make violins thicker
        points=False,
        line_color='#636EFA',
        fillcolor='#636EFA',
        opacity=0.6,
        hoverinfo='none' # Hide hover info for the violins
    ))

# --- Add Background Scatter Traces (Always Visible, Transparent) ---
# These are all responses, always visible
fig.add_trace(go.Scatter(
    x=df_long['Response'],
    y=df_long['Question'],
    mode='markers',
    name='All Responses',
    marker=dict(color='red', size=6, symbol='circle', opacity=0.4),
    visible=True,
    hovertemplate=
    '<b>Respondent</b>: %{customdata}<br>' +
    '<b>Response</b>: %{x:.2f}' +
    '<extra></extra>',
    customdata=df_long['Username']
))

# --- Add Highlight Scatter Traces for Each Respondent (Controlled by Dropdown) ---
# These are initially hidden and become visible when selected
for respondent in respondents:
    respondent_df = df_long[df_long["Username"] == respondent]
    fig.add_trace(go.Scatter(
        x=respondent_df['Response'],
        y=respondent_df['Question'],
        mode='markers',
        name=respondent,
        marker=dict(color='green', size=8, symbol='circle', opacity=1.0), # Distinct color, full opacity
        visible=False, # Hide by default
        hovertemplate=
        '<b>Respondent</b>: %{customdata}<br>' +
        '<b>Response</b>: %{x:.2f}' +
        '<extra></extra>',
        customdata=respondent_df['Username']
    ))

# --- Create the Dropdown Menu ---
# Calculate trace indices:
# Violins: 0 to len(questions) - 1
# Background Scatter: len(questions)
# Highlight Scatters: len(questions) + 1 to len(questions) + len(respondents)

num_violin_traces = len(questions)
background_scatter_trace_idx = num_violin_traces
first_highlight_scatter_trace_idx = num_violin_traces + 1

buttons = [
    dict(label="None",
         method="restyle",
         args=["visible", 
               [True] * num_violin_traces + # Violins always visible
               [True] + # Background scatter always visible
               [False] * len(respondents) # All highlight scatters hidden
              ])
]

for i, respondent in enumerate(respondents):
    visibility_mask = (
        [True] * num_violin_traces + # Violins
        [True] + # Background scatter
        [False] * len(respondents) # All highlight scatters initially hidden
    )
    
    # Set the current respondent's highlight scatter to visible
    visibility_mask[first_highlight_scatter_trace_idx + i] = True
    
    buttons.append(
        dict(label=respondent,
             method="restyle",
             args=["visible", visibility_mask])
    )

# --- Update Layout and Add Dropdown ---
fig.update_layout(
    title="Density Plot of Responses per Question",
    showlegend=False,
    height=50 * len(questions) + 200,
    width=1200, # Increased width to accommodate text
    plot_bgcolor='white',
    xaxis=dict(
        title="Response",
        range=[0, 1],
        showticklabels=True,
        tickvals=[0, 0.2, 0.4, 0.6, 0.8, 1.0],
        ticktext=["0", "0.2", "0.4", "0.6", "0.8", "1.0"]
    ),
    xaxis2=dict(
        title="Response",
        range=[0, 1],
        anchor="y",
        overlaying="x",
        side="top",
        showticklabels=True,
        tickvals=[0, 0.2, 0.4, 0.6, 0.8, 1.0],
        ticktext=["0", "0.2", "0.4", "0.6", "0.8", "1.0"]
    ),
    yaxis=dict(
        title="", # Remove y-axis title
        tickmode='array',
        tickvals=questions,
        ticktext=[question_map.get(q, f"Q {q}") for q in questions], # Use short questions as labels
        autorange="reversed" # Display questions from top to bottom
    ),
    updatemenus=[
        dict(
            active=0,
            buttons=buttons,
            direction="down",
            pad={"r": 10, "t": 10},
            showactive=True,
            x=0.01, # Position dropdown to the far left
            xanchor="left",
            y=1.15,
            yanchor="top"
        )
    ]
)

# Save the plot as an HTML file
fig.write_html("../docs/index.html")

print("Successfully generated interactive density plot with all responses overlaid and dropdown to ridge_plot.html")