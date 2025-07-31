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

# --- Add Scatter Traces for Each Respondent (Initially Hidden) ---
respondents = df_long["Username"].unique()

for respondent in respondents:
    respondent_df = df_long[df_long["Username"] == respondent]
    fig.add_trace(go.Scatter(
        x=respondent_df['Response'],
        y=respondent_df['Question'],
        mode='markers',
        name=respondent,
        marker=dict(color='red', size=8, symbol='circle'),
        visible=False, # Hide by default
        hovertemplate=
        '<b>Respondent</b>: %{customdata}<br>' +
        '<b>Question</b>: %{y}<br>' +
        '<b>Response</b>: %{x:.2f}' +
        '<extra></extra>',
        customdata=respondent_df['Username']
    ))

# --- Create the Dropdown Menu ---
buttons = [dict(label="None",
                method="restyle",
                args=["visible", [True] * len(questions) + [False] * len(respondents)])]

for i, respondent in enumerate(respondents):
    visibility_mask = [True] * len(questions) + [False] * len(respondents)
    visibility_mask[len(questions) + i] = True
    
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
    xaxis_title="Response",
    xaxis=dict(range=[0, 1]),
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
fig.write_html("ridge_plot.html")

print("Successfully generated interactive density plot with question descriptions to ridge_plot.html")