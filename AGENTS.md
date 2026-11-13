# Persona & Core 
You are an expert research scientist

# Working with sources
1. AI capabilities change rapidly. Check source dates and evaluated model versions; verify current claims against recent primary evidence; prefer recent studies.
2. Do not use host CLI tools to extract text from PDFs; read PDFs directly into context (unless you are Codex which lacks native pdf support). Metadata tools (`file`, `pdfinfo`) are fine.
3. Before putting a download into `sources/`, check that it is a real PDF (`file`, `pdfinfo`) and the right paper (title page). Paywalls and bot checks often return an HTML page saved under a `.pdf` name.
4. Work around bot checks as far as you can before asking the user
5. Use `FirstAuthorYearShortTitle` BibTeX keys (e.g. `Song2025ChemAgents`) and name source files after the key: `<BibKey>.pdf`, with `_SI` (or `_SI2`, ...) for supplementary files (`<BibKey>_SI.pdf`). Rename user-downloaded files (e.g. `ja4c17738.pdf`) to this scheme.
6. Index every source in `sources/sources.bib`. Each entry includes at least:
 - DOI and/or URL
 - title and the real abstract (not your summary)
 - `note`: what the source supports in our work, with pages (e.g. `§3.5 GPU count; SI pp. 38-42`)
 - `file`: the source's files in `sources/` (there can be multiple files: main text, supplementary information, web snapshot, etc.)
7. Web pages (vendor specs, prices, documentation, news) are `@misc` entries with `url` and `urldate`. Save a snapshot of the page content as Markdown in `sources/web/<BibKey>.md`, headed by the URL and access date, and list it in `file`.
8. A code repository and its Hugging Face model or dataset cards share one snapshot and one entry. Its `abstract` is the README's own description, quoted. Key it `<PaperKey>Repo` when it belongs to a paper in `sources/` (e.g. `Noh2026MSPLLMRepo`); otherwise `<Org><Year><Name>Repo` (e.g. `Verl2026Repo`). Use the `Repo` suffix for every code, model or dataset page, and no other (`_GitHub`, `Readme`, `ModelCard`, `HF`, ...).
9. When a preprint is superseded by the published version, update the entry and its key, rename its files to match, and update every citation of the old key. If the published version is paywalled, keep the preprint key, record the published DOI in `note`, and log the published version in `sources/requests.md`. Keep the old preprint file (as `<BibKey>_preprint.pdf`) only if it contains content we cite that the published main text lacks (e.g. appendices moved to an unavailable SI); cite it as `[BibKey, preprint p. N]`.
10. Only ever create bibliographic references for the sources you've actually accessed, never create them from your weights
11. If a paper's PDF cannot be obtained but its text can be read elsewhere (publisher HTML, Europe PMC XML, a search snippet, a third-party mirror), you may use it: snapshot what you read to `sources/web/<BibKey>.md`, cite by section instead of page (`[BibKey, §4.1]`), say in `note` which version was read, and log the PDF in `sources/requests.md`. Facts from third-party mirrors and snippets are provisional: flag them as such in the text until verified against the original. An entry for which only the abstract was read says so in `note`.
12. If a required paper is behind a paywall or a botwall you can't bypass, log the request in `sources/requests.md`, including the citation, access link, why the article matters, and which conclusions depend on it. Continue working without it. Later, the user will download the articles, and you'll do another pass.
13. Keep `sources/requests.md` limited to outstanding requests. Once a downloaded paper has been processed, remove its entry.
14. Leverage sub-agents to keep the context manageable, within the quota (see Quota). When several sub-agents work in parallel, each writes BibTeX to its own fragment file (`sources/bib_parts/<agent-tag>.bib`) and never edits `sources/sources.bib`; the orchestrator merges the fragments (deduplicating keys: union of `file`, combined `note`), checks required fields, and deletes `bib_parts/`. Before creating a key or file, a sub-agent checks `sources/` and `sources/web/` for an existing one and reuses it instead of creating a duplicate.
15. Cite sourced facts and numbers as `[BibKey, p. N]`. Mark numbers you derived yourself (arithmetic, extrapolation) as *[est.]*.

# Workflow
1. Make Git commits at campaign milestones. We can use git freely, there are no external users or backwards compatibility to maintain
2. Git is the history. Edit artifacts in place and put what changed, and why, in the commit message. Do not keep explicit history in files: no change logs, revision-history sections, or "resolved / applied / read" markers. Once an item is resolved, delete it instead of marking it.
3. Source PDFs are committed to Git directly. Do not use Git LFS.

# Self-improvement
The AGENTS.md rules and campaign orchestration are not perfect. If you encounter issues or have improvement proposals, raise them to the user.
