# 2025 Crystal Ball Cup

## Format

You will be presented with a series of hypothetical events. For each event, you will have
one minute to submit a probability $p \in [0, 1]$ that the event occurs before the end
of 2025.

No discussion is allowed except for clarifying questions.

You may not consult external resources. You may not collude with each other to affect the
outcome of any event before 2026-01-01.

## Scoring

On 2026-01-01, I will compute your score to be the sum of your scores across all events.
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

On some day early next year we will reconvene to evaluate our 2025 predictions
and make predictions for 2026.

Spend ten minutes discussing rewards and punishments.

## Form

\begin{center}
\includegraphics[width=0.3\linewidth]{form.png}
\end{center}

## Confidence

$$
f_c (p)
=
\frac{\left(\frac{p}{1-p}\right)^{c}}{1+\left(\frac{p}{1-p}\right)^{c}}
=
\frac{1}{1+e^{-c \ln \frac{p}{1-p}}}
$$

This has the following properties:

- Scaling by a confidence of one produces the same prediction $p$.
- Scaling by a confidence of zero produces a prediction of $0.5$.
- Scaling by a confidence of infinity produces zero if $p$ is less than $0.5$,
  one if $p$ is greater than $0.5$, and $0.5$ if $p$ is $0.5$.

## Confidence

\begin{center}
\begin{tikzpicture}
  \begin{axis}[
      xlabel={$p$},
      ylabel={$p$ scaled by confidence $c$},
      width=0.7\linewidth,
      height=0.7\linewidth,
      domain=0.00:1.00,
      xtick={0,0.25,0.5,0.75,1},
      xticklabels={$0$,$0.25$,$0.5$,$0.75$,$1$},
      ytick={0,0.25,0.5,0.75,1},
      yticklabels={$0$,$0.25$,$0.5$,$0.75$,$1$},
      samples=200,
      colormap/viridis,
      colorbar,
      colorbar style={
        ylabel={$c$},
        ymode=log,
        ytick={0.0625,0.25,1,4,16},
        yticklabels={$0$,$0.25$,$1$,$4$,$\infty$}
      },
      point meta min=0.0625,
      point meta max=16,
    ]
    % Curves for different confidence levels
    \addplot[thick, color of colormap={0}] { ((x/(1-x))^(0.1)) / (1 + (x/(1-x))^(0.1)) };

    \addplot[thick, color of colormap={250}] { ((x/(1-x))^(0.5)) / (1 + (x/(1-x))^(0.5)) };

    \addplot[thick, color of colormap={500}] { ((x/(1-x))^(1)) / (1 + (x/(1-x))^(1)) };

    \addplot[thick, color of colormap={750}] { ((x/(1-x))^(2)) / (1 + (x/(1-x))^(2)) };

    \addplot[thick, color of colormap={1000}] { ((x/(1-x))^(10)) / (1 + (x/(1-x))^(10)) };
  \end{axis}
\end{tikzpicture}
\end{center}

## Confidence

\begin{center}
\begin{tikzpicture}
  \begin{axis}[
      xlabel={$c$},
      ylabel={$p$ scaled by confidence $c$},
      legend style={at={(1.05,1)},anchor=north west},
      width=0.8\linewidth,
      height=0.5\linewidth,
      domain=0.01:100.0,
      xmode=log,
      log basis x={2},
      xtick=      {0.01,  0.25,   1,   4,      100},
      xticklabels={$0$,  $0.25$, $1$, $4$, $\infty$},
      samples=200,
      colormap/viridis,
      point meta min=0.0,
      point meta max=1.0,
    ]
    % Curves for different probabilities
    \addplot[thick, color of colormap={0}] { ((0.1/(1-0.1))^(x)) / (1 + (0.1/(1-0.1))^(x)) };
    \addlegendentry{$p=0.1$}

    \addplot[thick, color of colormap={250}] { ((0.4/(1-0.4))^(x)) / (1 + (0.4/(1-0.4))^(x)) };
    \addlegendentry{$p=0.4$}

    \addplot[thick, color of colormap={500}] { ((0.5/(1-0.5))^(x)) / (1 + (0.5/(1-0.5))^(x)) };
    \addlegendentry{$p=0.5$}

    \addplot[thick, color of colormap={750}] { ((0.6/(1-0.6))^(x)) / (1 + (0.6/(1-0.6))^(x)) };
    \addlegendentry{$p=0.6$}

    \addplot[thick, color of colormap={1000}] { ((0.9/(1-0.9))^(x)) / (1 + (0.9/(1-0.9))^(x)) };
    \addlegendentry{$p=0.9$}
  \end{axis}
\end{tikzpicture}
\end{center}
