# 2025 Crystal Ball Cup 

## Format

You will be presented with a series of hypothetical events. For each event, you will have 
**one minute** to submit a probability $p \in [0, 1]$ that the event occurs before the end
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
\includegraphics[width=0.3\linewidth]{desmos-graph.png}
\end{center}

## Retrospective

On some day early next year we will reconvene to evaluate our 2025 predictions 
and make predictions for 2026.

