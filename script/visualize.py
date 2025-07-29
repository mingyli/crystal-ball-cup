
import pandas as pd
import plotly.graph_objects as go

# Load the data
df = pd.read_csv("../gen/responses.csv")

# Melt the dataframe to long format
df_long = df.melt(id_vars=["Timestamp", "Username"], var_name="Question", value_name="Response")

# --- Data Cleaning and Preparation ---
df_long["Question"] = pd.to_numeric(df_long["Question"])
df_long["Response"] = pd.to_numeric(df_long["Response"], errors='coerce')
df_long.dropna(subset=['Response'], inplace=True)
df_long.sort_values("Question", inplace=True)

# --- Create the Base Figure ---
# We use plotly.graph_objects for more control
fig = go.Figure()

# Get unique questions for y-axis setup
questions = sorted(df_long["Question"].unique())

# --- Add the Violin Traces (Density Plots) ---
for q in questions:
    fig.add_trace(go.Violin(
        x=df_long[df_long["Question"] == q]['Response'],
        y0=q, # Assign to a specific y-level
        name=str(q),
        side='positive',
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
# The first button shows no respondent dots
buttons = [dict(label="None",
                method="restyle",
                args=["visible", [True] * len(questions) + [False] * len(respondents)])]

# Add a button for each respondent
for i, respondent in enumerate(respondents):
    # Create a visibility mask: True for violins, True for the selected respondent, False for others
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
    width=800,
    plot_bgcolor='white',
    xaxis_title="Response",
    xaxis=dict(range=[0, 1]),
    yaxis=dict(
        title="Question",
        tickmode='array',
        tickvals=questions,
        ticktext=[str(q) for q in questions]
    ),
    updatemenus=[
        dict(
            active=0,
            buttons=buttons,
            direction="down",
            pad={"r": 10, "t": 10},
            showactive=True,
            x=0.1, # Position dropdown to the left
            xanchor="left",
            y=1.15,
            yanchor="top"
        )
    ]
)

# Save the plot as an HTML file
fig.write_html("ridge_plot.html")

print("Successfully generated interactive density plot with respondent dropdown to ridge_plot.html")
