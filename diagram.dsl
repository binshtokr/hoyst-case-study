workspace "Hoyst Tech Challenge - Insolvenzanfechtung MVP" "C4 architecture model for an AI-assisted first analysis of insolvency case documents." {

    !identifiers hierarchical

    model {
        insolvencyProfessional = person "Insolvenzverwalter / Anwalt" "Needs a fast, source-backed first analysis of an insolvency data room. Reviews suspicious transactions and makes the final legal decision."
        paralegal = person "Juristischer Sachbearbeiter / Analyst" "Supports the insolvency lawyer by reviewing documents, timelines and findings."

        demoDataRoom = softwareSystem "Demo Case Data Room" "Repository folder data/demo-case/ with 23 PDFs: bank statements, contracts, emails, authority letters and court documents." "File system" {
            tags "External"
        }

        insoKnowledgeBase = softwareSystem "InsO Markdown Knowledge Base" "Repository folder data/gesetze/inso/ with one Markdown file per paragraph of the Insolvenzordnung and frontmatter metadata." "Markdown files" {
            tags "External"
        }

        llmProvider = softwareSystem "LLM Provider" "Language model used for semantic understanding of emails, contracts and explanations. The model must not make final legal decisions." "LLM API" {
            tags "External"
        }

        hoyst = softwareSystem "Hoyst Insolvency Analysis Assistant" "Transforms an unstructured insolvency data room into a structured first case analysis with timeline, suspicious findings, evidence and open questions." {

            cli = container "MVP CLI / Batch Runner" "Runs the first MVP locally against the demo repo and generates a Markdown report." "Python CLI"
            reviewUi = container "Review UI / Report Viewer" "Optional interface for lawyers to inspect findings, sources, uncertainties and next steps." "Web UI"

            ingestion = container "Document Ingestion" "Loads PDFs and InsO Markdown files, preserves filenames, page numbers and raw text references." "Python"
            pdfParser = container "PDF Text Extraction / OCR" "Extracts text from machine-readable PDFs and falls back to OCR when needed." "PyMuPDF / OCR"
            documentClassifier = container "Document Classifier" "Classifies documents as bank statement, email, contract, court document, authority letter or other." "Rules + LLM"
            keyDateExtractor = container "Key Date Extractor" "Finds relevant dates such as insolvency application date and opening decision date." "Rules + LLM"
            entityEventExtractor = container "Entity & Event Extraction" "Extracts parties, amounts, payment dates, account movements, emails, claims, warnings and financial distress signals." "Rules + LLM"
            timelineBuilder = container "Timeline Builder" "Builds a chronological timeline of payments, communications, contracts and legal events." "Python"
            insoRetrieval = container "InsO Retrieval / RAG" "Retrieves relevant InsO paragraphs for candidate findings, especially §§ 88, 129, 130, 131, 133, 134, 135, 138 and 142 InsO." "Embeddings / Search"
            legalHeuristicEngine = container "Legal Heuristic Engine" "Applies deterministic checks for time windows, transaction types, counterparties, possible exceptions and missing facts." "Python rules"
            semanticReasoner = container "Semantic Reasoning Layer" "Uses the LLM to interpret unstructured correspondence, especially knowledge of payment problems, threats, dunning letters and pressure." "LLM orchestration"
            evidenceLinker = container "Evidence Linker" "Links every finding to concrete documents, page references and supporting snippets. Marks unsupported facts as unknown." "Python"
            findingRanker = container "Finding Ranker" "Prioritizes suspicious findings by relevance, amount, legal fit, evidence strength and uncertainty." "Rules + scoring"
            reportGenerator = container "Report Generator" "Generates a Markdown report with executive summary, key dates, timeline, suspicious findings, legal hypotheses, sources, uncertainties and next steps." "Python / Markdown"

            caseStore = container "Case Analysis Store" "Stores parsed documents, extracted events, payments, entities, findings and source references." "SQLite or PostgreSQL" {
                tags "Database"
            }

            evidenceIndex = container "Evidence Index / Vector Store" "Indexes document snippets and InsO paragraphs for retrieval and source-backed reasoning." "FAISS or pgvector" {
                tags "Database"
            }
        }

        insolvencyProfessional -> hoyst.reviewUi "Reviews structured first analysis, suspicious findings and evidence"
        paralegal -> hoyst.reviewUi "Checks extracted timeline and supporting documents"
        insolvencyProfessional -> hoyst.cli "Runs or receives MVP report in the interview/demo setup"

        hoyst.cli -> hoyst.ingestion "Starts analysis for demo case"
        hoyst.ingestion -> demoDataRoom "Loads 23 case PDFs"
        hoyst.ingestion -> insoKnowledgeBase "Loads InsO Markdown files"
        hoyst.ingestion -> hoyst.pdfParser "Passes PDFs for text extraction"
        hoyst.pdfParser -> hoyst.caseStore "Stores extracted text with filename and page references"

        hoyst.documentClassifier -> hoyst.caseStore "Reads extracted text and writes document types"
        hoyst.keyDateExtractor -> hoyst.caseStore "Reads court documents and writes insolvency application/opening dates"
        hoyst.entityEventExtractor -> hoyst.caseStore "Reads classified documents and writes events, payments, entities and distress signals"
        hoyst.timelineBuilder -> hoyst.caseStore "Reads extracted events and writes chronological timeline"

        hoyst.insoRetrieval -> insoKnowledgeBase "Retrieves relevant legal norms"
        hoyst.insoRetrieval -> hoyst.evidenceIndex "Indexes and searches InsO paragraphs and document snippets"
        hoyst.legalHeuristicEngine -> hoyst.caseStore "Reads payments, events and key dates"
        hoyst.legalHeuristicEngine -> hoyst.insoRetrieval "Requests relevant paragraphs for legal hypotheses"
        hoyst.semanticReasoner -> llmProvider "Asks for semantic interpretation of emails, contracts and explanations"
        hoyst.semanticReasoner -> hoyst.evidenceIndex "Retrieves supporting snippets"
        hoyst.evidenceLinker -> hoyst.caseStore "Links findings to source documents, pages and snippets"
        hoyst.findingRanker -> hoyst.caseStore "Ranks candidate findings by priority and evidence strength"
        hoyst.reportGenerator -> hoyst.caseStore "Reads timeline, findings, evidence and uncertainties"
        hoyst.reportGenerator -> hoyst.reviewUi "Publishes report for human review"
        hoyst.reportGenerator -> insolvencyProfessional "Produces Markdown report as MVP output"
    }

    views {
        systemContext hoyst "SystemContext" {
            include *
            autolayout lr
            title "System Context - Hoyst Insolvency Analysis Assistant"
            description "Hoyst does not replace the lawyer. It accelerates the first review of an insolvency data room by producing a source-backed timeline and suspicious findings."
        }

        container hoyst "ContainerView" {
            include *
            autolayout lr
            title "Container View - MVP Architecture"
            description "Hybrid pipeline: deterministic rules for dates, amounts and time windows; LLM for semantic understanding of unstructured correspondence; strict source linking for legal traceability."
        }

        dynamic hoyst "MVPFlow" "Main MVP analysis flow" {
            insolvencyProfessional -> hoyst.cli "Run analysis for data/demo-case"
            hoyst.cli -> hoyst.ingestion "Load documents"
            hoyst.ingestion -> demoDataRoom "Read PDFs"
            hoyst.ingestion -> insoKnowledgeBase "Read InsO Markdown"
            hoyst.ingestion -> hoyst.pdfParser "Extract text"
            hoyst.pdfParser -> hoyst.caseStore "Store text with source references"
            hoyst.documentClassifier -> hoyst.caseStore "Classify document types"
            hoyst.keyDateExtractor -> hoyst.caseStore "Find insolvency application date"
            hoyst.entityEventExtractor -> hoyst.caseStore "Extract payments, parties and distress signals"
            hoyst.timelineBuilder -> hoyst.caseStore "Build timeline"
            hoyst.legalHeuristicEngine -> hoyst.caseStore "Create candidate findings"
            hoyst.semanticReasoner -> llmProvider "Interpret context and knowledge signals"
            hoyst.evidenceLinker -> hoyst.caseStore "Attach evidence and mark uncertainties"
            hoyst.findingRanker -> hoyst.caseStore "Prioritize findings"
            hoyst.reportGenerator -> insolvencyProfessional "Return Markdown report"
            autolayout lr
            title "Dynamic View - From Documents to First Legal Review"
            description "The system turns raw PDFs into a lawyer-reviewable report: suspicious event, possible norm, evidence, uncertainty and next step."
        }

        styles {
            element "Person" {
                shape Person
            }
            element "Software System" {
                background "#1168bd"
                color "#ffffff"
            }
            element "Container" {
                background "#438dd5"
                color "#ffffff"
            }
            element "Database" {
                shape Cylinder
                background "#2b6cb0"
                color "#ffffff"
            }
            element "External" {
                background "#999999"
                color "#ffffff"
            }
        }
    }
}
