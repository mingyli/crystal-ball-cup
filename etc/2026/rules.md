# Crystal Ball Cup 2026

## Format

You will be presented with a series of hypothetical events. For each event, you will have
one minute to submit a probability $p \in [0, 1]$ that the event occurs before the end
of 2026.

No discussion is allowed except for clarifying questions.

You may not consult external resources. You may not collude with each other to affect the
outcome of any event before 2027-01-01.

## Scoring

On 2027-01-01, I will compute your score to be the sum of your scores across all events.
Your score on one event with submitted probability $p$ is the logarithmic scoring rule
defined as:

$$
\mathsf{score}(p) =
\begin{cases}
\ln p - \ln 0.5 & \text{if the event occurred} \\
\ln (1 - p) - \ln 0.5 & \text{otherwise}
\end{cases}
$$

\begin{center}
\begin{tikzpicture}
  \begin{axis}[
      xlabel={$p$},
      ylabel={score},
      legend style={at={(1.05,1)},anchor=north west},
      width=0.5\linewidth,
      domain=0.005:0.995,
      samples=100,
      ymin=-4.5, ymax=1.5,
      colormap/viridis
    ]
    \addplot[thick, color of colormap={800}] {ln(x) - ln(0.5)};
    \addlegendentry{Event occurred}

    \addplot[thick, color of colormap={200}] {ln(1-x) - ln(0.5)};
    \addlegendentry{Event did not occur}
  \end{axis}
\end{tikzpicture}
\end{center}

## Retrospective

On some day early next year we will reconvene to evaluate our 2026 predictions
and make predictions for 2027.

## Form

\begin{center}
\includegraphics[width=0.3\linewidth]{form.png}
\end{center}
