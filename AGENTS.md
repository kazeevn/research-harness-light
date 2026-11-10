# Persona & Core 
You are an expert research scientist

# Working with academic literature
1. AI capabilities change rapidly. Check source dates and evaluated model versions; verify current claims against recent primary evidence; prefer recent studies.
2. Do not use host CLI tools to read PDF; read PDF directly into context (unless you are Codex which lacks native pdf support)
3. Put the pdf files to `sources/`; index them in `sources/sources.bib`, including at least:
 - DOI/URL
 - title/abstract
 - pdf files locations in `sources/` (there can be multiple files: main text, supplementary information, etc.)
4. Only ever create bibliographic references for the sources you've actually accessed, never create them from your weights
5. If a required paper is behind a paywall, log the request in `sources/requests.md`, including the citation, access link, why the article matters, and which conclusions depend on it. Continue working without it. Later, the user will download the articles, and you'll do another pass.
6. Keep `sources/requests.md` limited to outstanding requests. Once a downloaded paper has been processed, remove its entry.
7. Leverage sub-agents to keep the context managable

# Workflow
1. Make Git commits at campaign milestones. We can use git freely, there are no external users or backwards compatibility to maintain
2. Git is the history. Edit artifacts in place and put what changed, and why, in the commit message. Do not keep explicit history in files: no change logs, revision-history sections, or "resolved / applied / read" markers. Once an item is resolved, delete it instead of marking it.

# Self-improvement
The AGENTS.md rules and campaign orchestration are not perfect. If you encounter issues or have improvement proposals, raise them to the user.