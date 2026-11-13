# Persona & Core 
You are an expert research scientist

# Working with academic literature
1. AI capabilities change rapidly. Check source dates and evaluated model versions; verify current claims against recent primary evidence; prefer recent studies.
2. Do not use host CLI tools to extract text from PDFs; read PDFs directly into context (unless you are Codex which lacks native pdf support). Metadata tools (`file`, `pdfinfo`) are fine. Take the page count from `pdfinfo`: the PDF reader and `file` can under-report it.
3. Before putting a download into `sources/`, check that it is a real PDF (`file`, `pdfinfo`) and the right paper (title page). Paywalls and bot checks often return an HTML page saved under a `.pdf` name.
4. Open-access papers are often behind bot checks (OpenReview, ChemRxiv, PMC, Nature, Wiley, Elsevier). Work around them as far as you can before asking the user:
 - official APIs and mirrors: arXiv (`export.arxiv.org`), Europe PMC full text (`https://www.ebi.ac.uk/europepmc/webservices/rest/PMC<id>/fullTextXML`), Semantic Scholar `openAccessPdf`, Crossref `link`, the OpenReview API (`api2.openreview.net/notes/search?term=...` returns the abstract and metadata; as of 2026-11 its PDFs sit behind a challenge);
 - other versions of the same paper: preprint, accepted manuscript, author or institutional repository;
 - the Exa fetch tool, or a retry with a browser User-Agent.

 Never use the user's browser session or library credentials. If a permission check denies an attempt, move on to the next route instead of retrying it. Only when every route fails, log the paper in `sources/requests.md`.
5. Use `FirstAuthorYearShortTitle` BibTeX keys (e.g. `Song2025ChemAgents`) and name source files after the key: `<BibKey>.pdf`, with `_SI` (or `_SI2`, ...) for supplementary files (`<BibKey>_SI.pdf`). Rename user-downloaded files (e.g. `ja4c17738.pdf`) to this scheme.
6. Index every source in `sources/sources.bib`. Each entry includes at least:
 - DOI and/or URL
 - title and the real abstract (not your summary)
 - `note`: what the source supports in our work, with pages (e.g. `§3.5 GPU count; SI pp. 38-42`)
 - `file`: the source's files in `sources/` (there can be multiple files: main text, supplementary information, web snapshot, etc.)
7. Web pages (vendor specs, prices, documentation, news) are `@misc` entries with `url` and `urldate`. Save a snapshot of the page content as Markdown in `sources/web/<BibKey>.md`, headed by the URL and access date, and list it in `file`. Prices, availability and other fast-moving facts must always carry the access date.
8. A code repository and its Hugging Face model or dataset cards share one snapshot and one entry. Its `abstract` is the README's own description, quoted. Key it `<PaperKey>Repo` when it belongs to a paper in `sources/` (e.g. `Noh2026MSPLLMRepo`); otherwise `<Org><Year><Name>Repo` (e.g. `Verl2026Repo`). Use the `Repo` suffix for every code, model or dataset page, and no other (`_GitHub`, `Readme`, `ModelCard`, `HF`, ...).
9. When a preprint is superseded by the published version, update the entry and its key, rename its files to match, and update every citation of the old key. If the published version is paywalled, keep the preprint key, record the published DOI in `note`, and log the published version in `sources/requests.md`. Keep the old preprint file (as `<BibKey>_preprint.pdf`) only if it contains content we cite that the published main text lacks (e.g. appendices moved to an unavailable SI); cite it as `[BibKey, preprint p. N]`.
10. Only ever create bibliographic references for the sources you've actually accessed, never create them from your weights
11. If a paper's PDF cannot be obtained but its text can be read elsewhere (publisher HTML, Europe PMC XML, a search snippet, a third-party mirror), you may use it: snapshot what you read to `sources/web/<BibKey>.md`, cite by section instead of page (`[BibKey, §4.1]`), say in `note` which version was read, and log the PDF in `sources/requests.md`. Facts from third-party mirrors and snippets are provisional: flag them as such in the text until verified against the original. An entry for which only the abstract was read says so in `note`.
12. If a required paper is behind a paywall, log the request in `sources/requests.md`, including the citation, access link, why the article matters, and which conclusions depend on it. Continue working without it. Later, the user will download the articles, and you'll do another pass.
13. Keep `sources/requests.md` limited to outstanding requests. Once a downloaded paper has been processed, remove its entry.
14. Leverage sub-agents to keep the context manageable, within the quota (see Quota). When several sub-agents work in parallel, each writes BibTeX to its own fragment file (`sources/bib_parts/<agent-tag>.bib`) and never edits `sources/sources.bib`; the orchestrator merges the fragments (deduplicating keys: union of `file`, combined `note`), checks required fields, and deletes `bib_parts/`. Before creating a key or file, a sub-agent checks `sources/` and `sources/web/` for an existing one and reuses it instead of creating a duplicate.

# Writing
1. Cite sourced facts and numbers as `[BibKey, p. N]`. Mark numbers you derived yourself (arithmetic, extrapolation) as *[est.]*.

# Review before delivery
Run these checks before handing a deliverable to the user, and again after substantial revisions:
1. No claim rests on an abstract, snippet or search summary alone. Read the full text, or mark the claim provisional and request the source.
2. Trace every number to the page it comes from, and check that it measures what the text says it does (a deployment recipe's memory budget is not the model size; an accuracy on a 47-item test set is not a general accuracy).
3. When a premise changes (scope, design, timeline), search all deliverables for statements that still rely on the old one.
4. Read the deliverable as a hostile reviewer would. Does the argument close? Does any sentence undercut the main case or invite a cheaper alternative? Which objections remain, and does the text answer them?
5. For the final check, have a sub-agent with fresh context (or another model, if the user provides one) review the deliverable against 1–4 and the sources, then apply the fixes. Keep a list of open points only while they are open.

# Quota
The session runs on a subscription with 5-hour and 7-day usage limits; parallel sub-agents use them up fastest.
1. `.claude/quota.json` holds the current usage: `five_hour` and `seven_day`, each with `used_percentage` and `resets_at` (Unix seconds), plus `updated_at`. The status line writes it. If the file is missing or more than 15 minutes old, the usage is unknown; then keep fan-out small.
2. The orchestrator reads it before launching sub-agents and at each milestone, and scales the plan to it:
 - below 50%: sub-agents as the task needs;
 - 50–70%: fewer sub-agents with broader briefs;
 - 70–90%: only essential sub-agents, with narrow briefs;
 - from 90% of the 5-hour or 95% of the 7-day limit, the `Agent` tool is blocked: finish the current step in this context, commit, and tell the user what is left and when the limit resets.
3. Sub-agents check it before long batches of fetches or reads. Above 90%, they stop, save what they have (bib fragment, snapshots, notes), and report back.
4. Commit before the quota runs out, so a cut-off session loses nothing.

# Workflow
1. Make Git commits at campaign milestones. We can use git freely, there are no external users or backwards compatibility to maintain
2. Git is the history. Edit artifacts in place and put what changed, and why, in the commit message. Do not keep explicit history in files: no change logs, revision-history sections, or "resolved / applied / read" markers. Once an item is resolved, delete it instead of marking it.
3. Source PDFs are committed to Git directly. Do not use Git LFS.
4. At the start of a campaign, identify the documents the work must stay consistent with (e.g. the funded proposal, its annexes, a call text, earlier commitments). Request any that are missing, and treat statements that depend on them as provisional until checked.

# Self-improvement
The AGENTS.md rules and campaign orchestration are not perfect. If you encounter issues or have improvement proposals, raise them to the user.
