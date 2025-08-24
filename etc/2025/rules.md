# 2025 Crystal Ball Cup

## Format

You will be presented with a series of hypothetical events. For each event, you will have
one minute to submit a probability $p \in [0, 1]$ that the event occurs before the end
of 2025.

No discussion is allowed except for clarifying questions.

You may not consult external resources. You may not collude with each other to affect the
outcome of any event before 2026-01-01.

## Scoring

On 2026-01-01, I will compute your score to be the mean of your scores across all events.
Your score on one event with submitted probability $p$ is defined as:

$$
\text{score}(p) =
\begin{cases}
\ln p - \ln 0.5 & \text{if the event occurred} \\
\ln (1 - p) - \ln 0.5 & \text{otherwise}
\end{cases}
$$

\begin{center}
\includegraphics[width=0.3\linewidth]{score.png}
\end{center}

## Retrospective

On some day early next year we will reconvene to evaluate our 2025 predictions
and make predictions for 2026.

Spend ten minutes discussing rewards and punishments.

## Form

\begin{center}
\includegraphics[width=0.3\linewidth]{form.png}
\end{center}

## Confidence

$$
\frac{\left(\frac{p}{1-p}\right)^{c}}{1+\left(\frac{p}{1-p}\right)^{c}}
$$

This has the following properties:

- Scaling by a confidence of one produces the same prediction $p$.
- Scaling by a confidence of zero produces a prediction of $0.5$.
- Scaling by a confidence of infinity produces $0.5$ if $p$ is $0.5$, zero if
$p$ is less than $0.5$, and one if $p$ is greater than $0.5$.

##

\begin{center}
\begin{tikzpicture}
  \begin{axis}[
      xlabel={Probability $p$},
      ylabel={Probability $p$ scaled by confidence $c$},
      legend style={at={(1.05,1)},anchor=north west},
      width=0.5\linewidth,
      height=0.5\linewidth,
      domain=0.00:1.00,
      samples=999,
      colormap/viridis,
    ]
    % Curves for different confidence levels
    \addplot[thick, color of colormap={0}] { ((x/(1-x))^(0.1)) / (1 + (x/(1-x))^(0.1)) };
    \addlegendentry{$c=0.1$}

    \addplot[thick, color of colormap={250}] { ((x/(1-x))^(0.5)) / (1 + (x/(1-x))^(0.5)) };
    \addlegendentry{$c=0.5$}

    \addplot[thick, color of colormap={500}] { ((x/(1-x))^(1)) / (1 + (x/(1-x))^(1)) };
    \addlegendentry{$c=1$}

    \addplot[thick, color of colormap={750}] { ((x/(1-x))^(2)) / (1 + (x/(1-x))^(2)) };
    \addlegendentry{$c=2$}

    \addplot[thick, color of colormap={1000}] { ((x/(1-x))^(10)) / (1 + (x/(1-x))^(10)) };
    \addlegendentry{$c=10$}
  \end{axis}
\end{tikzpicture}
\end{center}
