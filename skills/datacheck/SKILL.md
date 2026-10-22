---
name: datacheck
description: Use when starting work with a new data file or folder, before analysis or visualization, before reusing a derived file, after a merge, filter, reshape, or recode, when parsing fails, when a count or result looks wrong or comes back zero, or when the user asks what a dataset contains.
---

# Data check

Inspect before analyzing. Do not modify the source file. Report problems with suggested fixes, and do not apply a fix without approval.

## 1. Confirm you have the right source

- Check the path, size, and modified date. A 0-byte file is often a cloud placeholder that has not downloaded. A partial scrape, an old committed copy, or a sample file can sit next to the full one.
- For a folder, list every file before summarizing it. Look for all name prefixes and variants, corrupt pieces of partial downloads, and files inside archives. Identify a file type by its first bytes, not its name.
- For a derived file, find the script and filter that produced it, and check that it is newer than its inputs. Recompute one aggregate from the source before you trust it.
- Treat codebooks, documentation, coverage notes, API metadata, and earlier summaries as claims. Check them against the records.

## 2. Read the raw file

- Run `file` and `head -c 500 <file> | cat -v`. Look for a byte order mark, `\r` line endings, the delimiter, extra header or footer rows, HTML entities, and literal `\n` text.
- Count records with a real parser, not `wc -l`, because text fields can contain line breaks. Compare the count with the expected N from the source, manifest, or codebook. Report both numbers.
- Read Stata and SPSS files with `haven`, so labels survive. Inspect Excel workbooks read only and list every sheet. Sample very large files by bytes before loading everything.

## 3. Profile what you loaded

- Print the real column names and types. Never guess a column name. Names, spelling, and nesting differ between sources, batches, and API versions.
- State what one row is, e.g., one person, one person per wave, or one posting per industry. Check that the identifier is unique at that level. Check the identifier's format for leading zeros lost, trailing spaces, `.0`, and long codes stored as decimal numbers.
- Check how missing values are stored after reading: `NA`, `NaN`, empty string, `"NULL"`, a text placeholder, or `"True"` and `"False"` as text. Keep blank, missing, and 0 apart. In Python, `NaN` counts as true, and `groupby` drops missing keys unless told not to.
- Flag possible coded missings, e.g., `97`, `98`, `99`, `-9`, or Stata `.a` to `.z`, when they sit outside the main range. Confirm their meaning from labels or a codebook. Never assume.
- Check what each column measures, not what its name says. Confirm the unit, the event a date records (interview, submission, conferral, or listing), whose attribute it is, and the direction of a sign.
- Never hard-code what a code means. Read the value labels, and check scale order and reverse coding before you average or recode.
- Check numeric ranges and impossible values, categorical levels, and date coverage.
- Find weights, strata, and clusters. Name the weight variable and count missing weights.
- Look for test, pilot, preview, and repeat respondent rows.
- When files cover several years, waves, or versions, compare variable names and types across them. A renamed variable can silently drop whole years.

## 4. Check again after you change the data

- Before a join, check that the key is unique where it should be, count missing keys, and normalize keys the same way on both sides (case, spaces, punctuation, `&`, name suffixes, abbreviations such as `D.C.` and `DC`). Check for column names that collide.
- After every merge, filter, reshape, or recode, compare row counts before and after, overall and by group. Report unmatched keys instead of dropping them. Join on keys. Never combine files by row position.
- Treat a zero, an empty result, or a sudden drop as a bug until you have checked the literal codes (e.g., `USA` against `US`), the encoding, and the matching rule.
- For every rate, state the numerator, the denominator, and the sample filter.
- Report the number of rows a model actually used. Models and `predict()` drop incomplete rows.

## Privacy

From participant level files, print counts and summaries, not values. Do not print identifiers, file names that contain identifiers, environment variables, or credentials. Do not open participant photos, audio, or free text unless the user asks.

## Report

Return a short report:

- the source, its version, and what one row is;
- expected and observed counts;
- problems found, each with suggested fix code that you have not run;
- what needs confirmation from the user or the codebook;
- the commands or log that produced the findings.
