---
name: analyze-ego-network
description: Analyze ego-centric social networks to extract network size, composition, tie strength, and multiplexity using R egor package. Use for personal network data, social support analysis, or network health research.
---

# Analyze Ego-Network

A skill for analyzing ego-centric (personal) social networks in R using the `egor` and `igraph` packages. Extract network size, composition, relationship types, and structural measures.

## Quick Start

```r
library(data.table)
library(egor)
library(igraph)

# Create egor object from survey data
ego_network <- egor(
  alters = alters_data,
  egos = ego_data,
  aaties = alter_ties_data,
  ID.vars = list(
    ego = "respondent_id",
    alter = "alter_id",
    source = "alter1",
    target = "alter2"
  )
)
```

## Key Patterns

### 1. Prepare Ego-Network Data

Ego-network data typically comes in three tables:

```r
# Ego data: one row per respondent
ego_data <- data.table(
  respondent_id = 1:100,
  age = sample(25:75, 100, replace = TRUE),
  gender = sample(c("M", "F"), 100, replace = TRUE)
)

# Alter data: multiple rows per respondent (one per network member)
alters_data <- data.table(
  respondent_id = rep(1:100, each = 5),
  alter_id = paste0("A", 1:500),
  relationship = sample(c("spouse", "parent", "friend", "coworker"), 500, replace = TRUE),
  tie_strength = sample(1:5, 500, replace = TRUE)
)

# Alter-alter ties: connections between alters (optional)
aaties_data <- data.table(
  respondent_id = rep(1:100, each = 3),
  alter1 = sample(paste0("A", 1:500), 300, replace = TRUE),
  alter2 = sample(paste0("A", 1:500), 300, replace = TRUE),
  knows_each_other = sample(0:1, 300, replace = TRUE)
)
```

### 2. Summarize Network Measures

Create ego-level summary statistics:

```r
# Custom function to summarize network measures
summarize_network_measures <- function(dt) {
  dt[,
    .(
      n_size_all = .N,
      n_size_hassler = sum(is_hassler, na.rm = TRUE),
      p_hassler = mean(is_hassler, na.rm = TRUE),
      mean_tie_strength = mean(tie_strength, na.rm = TRUE)
    ),
    by = "respondent_id"
  ]
}

# Apply to data
network_summary <- summarize_network_measures(alters_data)
```

### 3. Summarize by Relationship Type

Get separate measures for different relationship categories:

```r
# Add prefix function for renaming columns
add_prefix <- function(dt, prefix) {
  if (prefix == "") return(dt)
  cols <- setdiff(names(dt), "respondent_id")
  setnames(dt, cols, paste0(prefix, cols))
  dt
}

# Summarize with prefix
summarize_with_prefix <- function(dt, prefix = "") {
  summary_dt <- summarize_network_measures(dt)
  add_prefix(summary_dt, prefix)
}

# Get measures by relationship type
dt_nsize_all <- summarize_with_prefix(alters_data)
dt_nsize_kin <- summarize_with_prefix(alters_data[relationship %in% c("parent", "sibling", "child")], "k_")
dt_nsize_nonkin <- summarize_with_prefix(alters_data[relationship %in% c("friend", "coworker", "neighbor")], "nk_")
dt_nsize_spouse <- summarize_with_prefix(alters_data[relationship == "spouse"], "sp_")
```

### 4. Define Relationship Categories

Classify alters into relationship types:

```r
# Define kin vs non-kin
alters_data[, n_rel_kin := rowSums(.SD, na.rm = TRUE),
            .SDcols = c("is_parent", "is_sibling", "is_child", "is_relative")]

alters_data[, n_rel_nonkin := rowSums(.SD, na.rm = TRUE),
            .SDcols = c("is_friend", "is_coworker", "is_neighbor")]

alters_data[, rel_type := fcase(
  is_spouse == 1, "spouse",
  n_rel_kin > 0, "kin",
  n_rel_nonkin > 0, "nonkin",
  default = "other"
)]
```

### 5. Compute Tie Proportions

Calculate the proportion of ties in each category:

```r
compute_tie_proportions <- function(dt, vars, prefix = "p_") {
  vars <- intersect(vars, names(dt))
  if (length(vars) == 0) return(NULL)

  prop_dt <- dt[,
    lapply(.SD, function(x) mean(x > 0, na.rm = TRUE)),
    by = "respondent_id",
    .SDcols = vars
  ]

  prop_cols <- paste0(prefix, vars)
  setnames(prop_dt, vars, prop_cols)

  # Replace NaN with NA
  for (col in prop_cols) {
    prop_dt[is.nan(get(col)), (col) := NA_real_]
  }
  prop_dt
}

# Usage
tie_vars <- c("is_hassler", "is_close_tie", "gives_support")
proportions <- compute_tie_proportions(alters_data, tie_vars)
```

### 6. Merge Multiple Tables

Combine ego-level measures:

```r
merge_by_id <- function(tables, id_var = "respondent_id") {
  tables <- Filter(Negate(is.null), tables)
  if (length(tables) == 0) return(NULL)
  Reduce(function(left, right) merge(left, right, by = id_var, all = TRUE), tables)
}

# Combine all summary tables
network_measures <- merge_by_id(list(
  ego_data[, .(respondent_id)],
  dt_nsize_all,
  dt_nsize_kin,
  dt_nsize_nonkin,
  dt_nsize_spouse
))

# Fill missing network sizes with 0
size_vars <- grep("n_size", names(network_measures), value = TRUE)
for (var in size_vars) {
  network_measures[is.na(get(var)), (var) := 0]
}
```

### 7. Create egor Object

Use the `egor` package for advanced network analysis:

```r
library(egor)

# Clean alter data (remove invalid entries)
alters_clean <- alters_data[alter_id %in% c("91", "92") == FALSE]

# Clean alter-alter ties
aaties_clean <- aaties_data[knows_each_other > 0]

# Create egor object
ego_network <- egor(
  alters = alters_clean,
  egos = ego_data,
  aaties = aaties_clean,
  ID.vars = list(
    ego = "respondent_id",
    alter = "alter_id",
    source = "alter1",
    target = "alter2"
  )
)

# Access components
ego_network$ego      # Ego data
ego_network$alter    # Alter data
ego_network$aatie    # Alter-alter ties
```

### 8. Define "Hasslers" or Negative Ties

Identify problematic network members:

```r
# Based on frequency of negative interactions
alters_data[hassle_freq > 90, hassle_freq := NA]  # Clean missing codes

# Define hassler: frequent negative interactions
alters_data[, is_hassler := fcase(
  hassle_freq %in% c(0, 1, 2), 0L,  # Never/rarely/sometimes
  hassle_freq == 3, 1L,              # Often
  default = NA_integer_
)]

# Create hassler type (combines relationship and hassler status)
alters_data[, hassler_type := fcase(
  is_hassler == 0 & rel_type == "spouse", "Spouse non-hassler",
  is_hassler == 0 & rel_type == "kin", "Kin non-hassler",
  is_hassler == 0 & rel_type == "nonkin", "Non-kin non-hassler",
  is_hassler == 1 & rel_type == "spouse", "Spouse hassler",
  is_hassler == 1 & rel_type == "kin", "Kin hassler",
  is_hassler == 1 & rel_type == "nonkin", "Non-kin hassler"
)]
```

## Complete Example

```r
library(data.table)
library(egor)

# Load ego-network data
dt_alters <- fread("alters.csv")
dt_egos <- fread("egos.csv")
dt_aaties <- fread("alter_ties.csv")

# Standardize names
names(dt_alters) <- tolower(names(dt_alters))
names(dt_aaties) <- tolower(names(dt_aaties))

# Clean missing value codes
for (var in c("tie_strength", "hassle_freq")) {
  dt_alters[get(var) %in% c(92, 96), (var) := NA]
}

# Define hassler
dt_alters[, is_hassler := fifelse(hassle_freq >= 3, 1L, 0L)]

# Summary function
summarize_network <- function(dt) {
  dt[,
    .(
      network_size = .N,
      n_hasslers = sum(is_hassler, na.rm = TRUE),
      prop_hasslers = mean(is_hassler, na.rm = TRUE),
      mean_strength = mean(tie_strength, na.rm = TRUE)
    ),
    by = "ego_id"
  ]
}

# Get overall and by-type summaries
summary_all <- summarize_network(dt_alters)
summary_kin <- summarize_network(dt_alters[is_kin == 1])
setnames(summary_kin, setdiff(names(summary_kin), "ego_id"),
         paste0("kin_", setdiff(names(summary_kin), "ego_id")))

# Merge
network_measures <- merge(summary_all, summary_kin, by = "ego_id", all.x = TRUE)

# Fill NA network sizes with 0
network_measures[is.na(network_size), network_size := 0]

# Save
saveRDS(network_measures, "ego_network_measures.rds")
```

## Required Packages

```r
install.packages(c("data.table", "egor", "igraph"))
```

## Tips

- Always clean missing value codes before analysis (e.g., 91, 92, 97, 98)
- Document your definition of "hassler" or negative tie
- Consider whether isolates (no alters) should be 0 or NA
- The egor package provides many built-in functions for ego-network analysis
- Export both ego-level and alter-level datasets for different analyses
