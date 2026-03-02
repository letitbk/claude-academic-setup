# Optional Skills (30)

Install any of these with `bash install-optional.sh`. They supplement the 13 core skills but are not required for the base workflow.

## Data Analysis

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `init-research-project` | Set up a new research project from data files: inspect data, generate codebook, conduct interactive research planning, and scaffold project structure with a reproducible pipeline. | Starting fresh with a new dataset and want structured project scaffolding from day one. |
| `finalize-analysis` | Organize messy exploratory work into a clean reproducible project with Snakemake pipeline and publication-ready outputs, one figure or table at a time. | Exploratory analysis is done and you need to clean up scripts into a numbered, reproducible pipeline. |
| `heterogeneity-analysis` | Subgroup and heterogeneity analysis in Stata using interaction models and stratified regression. | Examining whether treatment effects vary across groups (age, gender, race, etc.). |
| `konfound-sensitivity` | Quantify sensitivity to unmeasured confounding using the konfound package in Stata or R (ITCV and RIR metrics). | Assessing how much confounding would be needed to invalidate your causal findings. |
| `marginaleffects` | Compute marginal effects, comparisons, and predictions using the R marginaleffects package (AMEs, factor contrasts, continuous contrasts, predicted values). | Computing average marginal effects or factor contrasts from regression models in R. |
| `robustness-checks` | Sequential robustness checks with confounder blocks in Stata, showing how estimates change as potential confounders are added. | Running sensitivity analysis to demonstrate estimate stability across model specifications. |
| `analyze-ego-network` | Analyze ego-centric social networks to extract network size, composition, tie strength, and multiplexity using R egor package. | Working with personal network data, social support analysis, or network-health research. |

## Visualization

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `coefficient-plot` | Create publication-ready coefficient plots with significance coloring and category faceting in R ggplot2. | Visualizing regression results, marginal effects, or any estimates with confidence intervals. |
| `distribution-boxplot` | Create boxplots with custom statistics by group using R ggplot2, with reference lines and faceted layouts. | Comparing distributions across categories with median, quartiles, and range. |
| `marginal-effects-plot` | Visualize marginal effects from regression models with factor level parsing, reference category labeling, and multi-panel layouts in R ggplot2. | Plotting AMEs from Stata margins output or R marginaleffects output. |
| `viz` | Create any publication-ready data visualization using ggplot2 in R, with upfront visual requirement gathering. | Creating any chart, figure, or plot -- or refining an existing visualization. |
| `imagegen` | Generate or edit images via the OpenAI Image API using a bundled CLI for deterministic, reproducible runs. | Generating concept art, product shots, diagrams, or editing existing images (inpainting, background removal). |

## Writing & Docs

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `draft-paper` | Write a research paper from completed analysis results, companion .md files, and iterative user input, covering all manuscript sections and literature review. | Analysis is complete and you want to write up results into a publication-ready manuscript. |
| `humanizer` | Detect and remove signs of AI-generated writing based on Wikipedia's "Signs of AI writing" guide, covering 24 pattern categories. | Editing text to make it sound more natural and less like AI-generated prose. |
| `marp-slide` | Create professional Marp presentation slides with 7 built-in themes (default, minimal, colorful, dark, gradient, tech, business). | Building a slide deck for a talk, lecture, or seminar. |
| `stop-slop` | Eliminate predictable AI writing patterns from prose -- filler phrases, formulaic structures, and metronomic rhythm. | Drafting or editing prose and want to strip out obvious AI tells. |
| `grant-writing` | Draft grant proposal sections for NSF, NIH, and other agencies, covering Specific Aims, Significance, Innovation, Approach, Timeline, and Budget Justification. | Writing a competitive grant proposal with agency-specific formatting. |

## Research Workflow

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `clean-survey-data` | Clean survey data in R with missing value handling, variable recoding, and Stata label conversion to R factors. | Processing raw survey or health study data with coded missing values (91/92/97/98). |
| `compute-survey-weights` | Calculate participation-adjusted survey weights using logistic regression and inverse probability weighting in R. | Adjusting sampling weights for selection bias, non-response, or creating IPW weights. |
| `dataverse-sync` | Sync local repository with a Harvard Dataverse dataset using the Native API (upload, replace, delete files). | Uploading or updating files in a Dataverse dataset programmatically. |
| `dataverse-upload-zip` | Upload files to Harvard Dataverse via ZIP archive to bypass AWS WAF restrictions on .R and .do files. | Direct Dataverse uploads of R or Stata code files are failing with 403 Forbidden. |
| `qualtrics-survey` | Manage Qualtrics surveys via API -- list blocks/questions, create/update questions, add JavaScript, manage embedded data and display logic. | Programmatically modifying an existing Qualtrics survey with LLM-powered features. |
| `setup-snakemake-pipeline` | Initialize Snakemake workflows with R and Stata integration for reproducible research pipelines. | Setting up a multi-language (R + Stata) reproducible data processing and analysis pipeline. |
| `survey-analysis` | Design-based survey analysis in R using the survey package: survey design setup, weighted descriptives, svyglm regression, raking, and calibration. | Running weighted survey analysis with complex survey designs in R. |
| `survey-regression-stata` | Run survey-weighted regression in Stata with svyset, margins for AMEs, and esttab export. | Running complex survey regression analysis with sampling weights in Stata. |

## Academic

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `citation-verification` | Cross-check manuscript citations against Zotero library and Crossref to catch wrong years, missing references, orphaned entries, and formatting inconsistencies. | Auditing your bibliography before submission to catch citation errors. |
| `research-ideation` | Structured hypothesis generation from literature gaps -- maps existing research, identifies unanswered questions, and assesses feasibility with a rubric. | Brainstorming research questions or looking for what to study next in a given field. |
| `irb-protocol` | Draft IRB protocol documents from research descriptions, covering study purpose, procedures, risks/benefits, informed consent, and data security. | Preparing an IRB application for survey, interview, or secondary data research. |
| `notebooklm` | Query Google NotebookLM notebooks from Claude Code for source-grounded, citation-backed answers with browser automation and persistent auth. | Querying your uploaded documents in NotebookLM for answers grounded exclusively in your sources. |

## Security

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `security-best-practices` | Perform language- and framework-specific security reviews for Python, JavaScript/TypeScript, and Go, with vulnerability reporting and fix suggestions. | Requesting a security review, vulnerability report, or secure-by-default coding guidance. |
