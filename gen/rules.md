# 2025 Crystal Ball Cup Rules

## Format

You will be presented with a series of hypothetical events. For each event, you will have 
**one minute** to submit a probability $p \in [0, 1]$ of the event occurring before the end
of 2025. No discussion is allowed except for clarifying questions. 

After all submissions are collected, we will analyze the distributions.

## Scoring

On 2026-01-01, I will determine your scores.  Your score on one particular event with 
submitted probability $p$ is defined as:

$$
\text{score}(p) =
\begin{cases}
\ln p - \ln 0.5 & \text{if the event occurred} \\
\ln (1 - p) - \ln 0.5 & \text{otherwise}
\end{cases}
$$

\begin{center}
\includegraphics[width=0.3\linewidth]{desmos-graph.png}
\end{center}
