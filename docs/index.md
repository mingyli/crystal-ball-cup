---
title: Crystal Ball Cup
---

<script type="text/javascript">
MathJax = {
  tex: {
      inlineMath: [['$', '$']],
  },
  options: {
      enableMenu: false,
  },
  svg: {
      attributes: {
      pointerEvents: 'none'
      }
  }
};
</script>
<script
    type="text/javascript"
    id="MathJax-script"
    async src="https://cdn.jsdelivr.net/npm/mathjax@4/tex-svg.js">
</script>

## Years

[2025](./2025/)

## Format

You will be presented with a series of hypothetical events. For each event, you
will submit a probability $p \in [0, 1]$ that the event occurs before the end of
the year.

## Scoring

Your score is the sum of your scores across all events. Your score on one event
is defined according to an adjusted logarithmic scoring rule.

$$
\mathsf{score}(p) =
\begin{cases}
  \ln p - \ln 0.5 & \text{if event occurs} \\
  \ln (1 - p) - \ln 0.5 & \text{otherwise}
\end{cases}
$$

## Confidence

Define "scaling $p$ by confidence $c$" as

$$
\mathsf{scale}_c(p) = \frac{p^c}{p^c + (1 - p)^c}
$$

Let $\mathsf{score}_c(p)$ be your score if you scale $p$ by confidence $c$. Then
there exists some $c$ that maximizes the score of your probability scaled by
$c$. Your confidence is the multiplicative inverse of this optimal $c$. For
example, if your score would have been maximized by scaling your probabilities
by $2$, then your confidence is $0.5$.

The methodology is described in my blog post
[Scaling Probability by Confidence](https://mingyli.github.io/blog/2025/09/30/probability-confidence-scaling.html).
