# LaTeX Template (ASR/Science Style)

Based on the AI-Augmented Surveys submission template. Requires `asr.bst` and `scicite.sty` (bundled in skill `assets/`).

## Setup

Copy style files to the manuscript directory before compiling:

```bash
cp ~/.claude/skills/draft-paper/assets/asr.bst manuscript/
cp ~/.claude/skills/draft-paper/assets/scicite.sty manuscript/
```

## Main Document Template

```latex
\documentclass[12pt]{article}
\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage{changepage}
\usepackage{setspace}
\usepackage{titling}
\usepackage{hyperref}
\usepackage{graphicx}
\usepackage{subcaption}
\usepackage[labelfont=bf]{caption}
\usepackage{cleveref}
\crefformat{figure}{Figure~#2#1#3}
\usepackage{booktabs}
\usepackage{multirow}
\usepackage{array}
\usepackage{longtable}
\usepackage{times}
\usepackage[sort]{natbib}
\usepackage{scicite}

\topmargin 0.0cm
\oddsidemargin 0.2cm
\textwidth 16cm
\textheight 21cm
\footskip 1.0cm

\begin{document}

% --- Title Page ---
\begin{titlepage}
\setlength{\droptitle}{-5em}
\title{[Paper Title]}
\author{[Author 1] \\ [Department] \\ [University] \\ [City, State]
  \and [Author 2] \\ [Department] \\ [University] \\ [City, State]}
\date{}
\maketitle
\thispagestyle{empty}

\begin{flushleft}
\textbf{Corresponding Author:}
{[Name], \href{mailto:[email]}{[email]}}

\vspace{0.5cm}

\textbf{Acknowledgments}: [Acknowledgment text]

\vspace{0.5cm}

\textbf{Funding:} [Funding sources]

\vspace{0.5cm}

\noindent \textbf{Keywords:}
{[keyword1, keyword2, keyword3]}

\end{flushleft}
\vspace*{\fill}
\end{titlepage}

% --- Author Biographies ---
\clearpage
\section*{Author Biographies}

\textbf{[Author 1]} [Bio text]

\vspace{1em}

\noindent
\textbf{[Author 2]} [Bio text]

\clearpage

% --- Abstract Page ---
\title{[Paper Title]}
\author{}
\date{}
\maketitle

\vspace{-1.5cm}

\begin{abstract}
[Abstract text -- 150-250 words]
\end{abstract}

\vspace{0.5cm}

% --- Body ---
\doublespacing

\section{Introduction}
[Introduction text]

\section{Literature Review}
[Literature review text]

\section{Data and Methods}
\subsection{Data}
[Data description]
\subsection{Measures}
[Variable descriptions]
\subsection{Analytic Strategy}
[Model specification]

\section{Results}
[Results text with references to tables and figures]

\section{Discussion}
[Discussion text]

\section{Conclusion}
[Conclusion text]

\singlespacing
\bibliographystyle{asr}
\bibliography{references}

\end{document}
```

## Figure Inclusion

Use PDF figures from `output/figures/` for best quality:

```latex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=\textwidth]{../output/figures/fig1_coefplot.pdf}
  \caption{Coefficient plot of main effects. Error bars show 95\% confidence intervals.}
  \label{fig:coefplot}
\end{figure}
```

Reference in text with cleveref: `\cref{fig:coefplot}` produces "Figure 1".

For subfigures:
```latex
\begin{figure}[htbp]
  \centering
  \begin{subfigure}[b]{0.48\textwidth}
    \includegraphics[width=\textwidth]{../output/figures/fig2a_panel1.pdf}
    \caption{Panel A}
    \label{fig:panel1}
  \end{subfigure}
  \hfill
  \begin{subfigure}[b]{0.48\textwidth}
    \includegraphics[width=\textwidth]{../output/figures/fig2b_panel2.pdf}
    \caption{Panel B}
    \label{fig:panel2}
  \end{subfigure}
  \caption{Main results by subgroup.}
  \label{fig:panels}
\end{figure}
```

## Table Inclusion

```latex
\begin{table}[htbp]
  \centering
  \caption{Main regression results}
  \label{tab:regression}
  \input{../output/tables/table2_regression.tex}
\end{table}
```

For long tables spanning pages:
```latex
\begin{longtable}{lccc}
  \caption{Descriptive statistics} \label{tab:descriptives} \\
  \toprule
  ...
\end{longtable}
```

## Bibliography

- Style: `asr` (ASR citation style) with `scicite` package
- File: `manuscript/references.bib`
- Citation: `\citep{smith2022}` for parenthetical, `\citet{smith2022}` for textual

## Appendix (Separate Document)

Create `manuscript/sm_manuscript_appendix.tex` as a separate document:

```latex
\documentclass[12pt]{article}
% [same preamble packages]
\usepackage[table]{xcolor}
\usepackage{listings}

\begin{document}
\title{Supplementary Materials}
\author{}
\date{}
\maketitle

\section{Appendix A: Additional Tables}
...

\section{Appendix B: Additional Figures}
...

\end{document}
```

## Compilation

```bash
cd manuscript
pdflatex paper
bibtex paper
pdflatex paper
pdflatex paper
```

Triple pass: first pdflatex creates .aux, bibtex resolves references, subsequent passes insert citations and resolve cross-references.
