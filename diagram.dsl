workspace "Hoyst Tech Challenge - Insolvenzanfechtung MVP" "Vereinfachtes C4-Architekturmodell für eine KI-gestützte Erstanalyse von Insolvenzdokumenten." {

    !identifiers hierarchical

    model {
        insolvencyProfessional = person "Insolvenzverwalter / Anwalt" "Benötigt eine schnelle, quellenbasierte Erstanalyse eines Insolvenz-Datenraums. Prüft Verdachtsfälle und trifft die finale juristische Entscheidung."
        paralegal = person "Juristischer Sachbearbeiter / Analyst" "Unterstützt die juristische Prüfung durch Sichtung von Timeline, Belegen und Verdachtsfällen."

        demoDataRoom = softwareSystem "Demo-Fall-Datenraum" "Repository-Ordner data/demo-case/ mit 23 PDFs: Kontoauszüge, Verträge, E-Mails, Behördenschreiben und Gerichtsdokumente." "Dateisystem" {
            tags "External"
        }

        insoKnowledgeBase = softwareSystem "InsO-Wissensbasis" "Repository-Ordner data/gesetze/inso/ mit Markdown-Dateien der Insolvenzordnung." "Markdown-Dateien" {
            tags "External"
        }

        llmProvider = softwareSystem "LLM-Anbieter" "Sprachmodell für semantisches Verständnis von E-Mails, Verträgen und Begründungen. Das LLM trifft keine finale juristische Entscheidung." "LLM API" {
            tags "External"
        }

        hoyst = softwareSystem "Hoyst Analyse-Assistent" "Verwandelt einen unstrukturierten Insolvenz-Datenraum in eine strukturierte Erstanalyse mit Timeline, Verdachtsfällen, Belegen und offenen Fragen." {

            cli = container "MVP CLI / Batch Runner" "Startet die Analyse lokal und erzeugt einen Markdown-Report." "Python CLI"

            documentProcessing = container "Dokumentenverarbeitung" "Lädt PDFs und InsO-Markdown, extrahiert Text, erkennt Dokumenttypen und bewahrt Quellenreferenzen wie Dateiname, Seite und Textausschnitt." "Python / PyMuPDF / OCR"

            extractionPipeline = container "Extraktion & Timeline" "Extrahiert Stichtage, Zahlungen, Beträge, Parteien, E-Mails, Mahnungen und andere Ereignisse. Baut daraus eine chronologische Timeline." "Python / Regeln / LLM"

            legalAnalysis = container "Anfechtungsanalyse" "Prüft mögliche Verdachtsfälle mit einfachen Heuristiken zu §§ 130, 131, 133, 134, 135 InsO sowie § 88 und § 142 InsO. Nutzt RAG für relevante Normtexte." "Python-Regeln / RAG / LLM"

            evidenceAndRanking = container "Belege & Priorisierung" "Verknüpft jeden Verdachtsfall mit Quellen, markiert Unsicherheiten und priorisiert Findings nach Betrag, Fristnähe, Belegstärke und juristischer Passung." "Python / Scoring"

            reportGenerator = container "Report Generator" "Erzeugt einen Markdown-Report mit Zusammenfassung, Stichtagen, Timeline, Verdachtsfällen, möglichen Normen, Belegen, Unsicherheiten und nächsten Schritten." "Python / Markdown"

            reviewUi = container "Review UI / Report Viewer" "Optionale Oberfläche, in der Anwälte den Report, Verdachtsfälle und Belege prüfen können." "Web UI" {
                tags "Optional"
            }

            caseStore = container "Fallanalyse-Speicher" "Speichert Dokumenttexte, Metadaten, Ereignisse, Zahlungen, Timeline, Verdachtsfälle und Quellenreferenzen." "SQLite oder PostgreSQL" {
                tags "Database"
            }

            evidenceIndex = container "Beleg-Index / Vektor-Speicher" "Indexiert Dokumentausschnitte und InsO-Paragraphen für Retrieval und quellenbasierte Analyse." "FAISS oder pgvector" {
                tags "Database"
            }
        }

        insolvencyProfessional -> hoyst.cli "Startet Analyse oder erhält Markdown-Report"
        insolvencyProfessional -> hoyst.reviewUi "Prüft Verdachtsfälle, Belege und Unsicherheiten"
        paralegal -> hoyst.reviewUi "Prüft Timeline und Quellen"

        hoyst.cli -> hoyst.documentProcessing "Startet Dokumentenverarbeitung"
        hoyst.documentProcessing -> demoDataRoom "Lädt Fall-PDFs"
        hoyst.documentProcessing -> insoKnowledgeBase "Lädt InsO-Markdown-Dateien"
        hoyst.documentProcessing -> hoyst.caseStore "Speichert extrahierten Text und Quellenreferenzen"

        hoyst.extractionPipeline -> hoyst.caseStore "Liest Dokumenttexte und schreibt Stichtage, Ereignisse, Zahlungen und Timeline"

        hoyst.legalAnalysis -> hoyst.caseStore "Liest Timeline, Zahlungen und Stichtage"
        hoyst.legalAnalysis -> insoKnowledgeBase "Ruft relevante InsO-Paragraphen ab"
        hoyst.legalAnalysis -> llmProvider "Lässt unstrukturierte Kommunikation semantisch interpretieren"
        hoyst.legalAnalysis -> hoyst.evidenceIndex "Sucht passende Dokumentausschnitte und Normtexte"

        hoyst.evidenceAndRanking -> hoyst.caseStore "Verknüpft Findings mit Quellen und priorisiert Verdachtsfälle"
        hoyst.reportGenerator -> hoyst.caseStore "Liest Timeline, Findings, Belege und Unsicherheiten"
        hoyst.reportGenerator -> insolvencyProfessional "Erzeugt Markdown-Report als MVP-Ergebnis"
        hoyst.reportGenerator -> hoyst.reviewUi "Stellt Report optional in UI bereit"
    }

    views {
        systemContext hoyst "01-Systemkontext" {
            include insolvencyProfessional
            include paralegal
            include hoyst
            include demoDataRoom
            include insoKnowledgeBase
            include llmProvider
            autolayout lr
            title "01 - Systemkontext"
            description "Hoyst ersetzt nicht den Anwalt. Das System beschleunigt die erste Prüfung eines Insolvenz-Datenraums und erzeugt eine quellenbasierte Voranalyse."
        }

        container hoyst "02-MVP-Container" {
            include insolvencyProfessional
            include paralegal
            include demoDataRoom
            include insoKnowledgeBase
            include llmProvider
            include hoyst.cli
            include hoyst.documentProcessing
            include hoyst.extractionPipeline
            include hoyst.legalAnalysis
            include hoyst.evidenceAndRanking
            include hoyst.reportGenerator
            include hoyst.reviewUi
            include hoyst.caseStore
            include hoyst.evidenceIndex
            autolayout lr
            title "02 - MVP-Container"
            description "Vereinfachte MVP-Architektur: Dokumente verarbeiten, Informationen extrahieren, Timeline bauen, Verdachtsfälle prüfen, Belege verknüpfen und Report erzeugen."
        }

        container hoyst "03-Analyse-Pipeline" {
            include hoyst.cli
            include hoyst.documentProcessing
            include hoyst.extractionPipeline
            include hoyst.legalAnalysis
            include hoyst.evidenceAndRanking
            include hoyst.reportGenerator
            include hoyst.caseStore
            include hoyst.evidenceIndex
            autolayout lr
            title "03 - Analyse-Pipeline"
            description "Diese View zeigt nur den Kernablauf des MVPs und blendet Nutzer sowie externe Systeme weitgehend aus."
        }

        dynamic hoyst "04-MVP-Ablauf" "Hauptablauf von Dokumenten zum Report" {
            insolvencyProfessional -> hoyst.cli "Analyse starten"
            hoyst.cli -> hoyst.documentProcessing "PDFs und InsO-Dateien laden"
            hoyst.documentProcessing -> demoDataRoom "Fall-PDFs lesen"
            hoyst.documentProcessing -> insoKnowledgeBase "InsO-Markdown lesen"
            hoyst.documentProcessing -> hoyst.caseStore "Text und Quellenreferenzen speichern"
            hoyst.extractionPipeline -> hoyst.caseStore "Stichtage, Zahlungen, Parteien und Timeline extrahieren"
            hoyst.legalAnalysis -> hoyst.caseStore "Kandidaten für Insolvenzanfechtung prüfen"
            hoyst.legalAnalysis -> llmProvider "E-Mails und Kontext semantisch interpretieren"
            hoyst.evidenceAndRanking -> hoyst.caseStore "Belege verknüpfen und Findings priorisieren"
            hoyst.reportGenerator -> insolvencyProfessional "Markdown-Report zurückgeben"
            autolayout lr
            title "04 - MVP-Ablauf"
            description "Das System verwandelt rohe PDFs in einen anwaltlich prüfbaren Report: verdächtiger Vorgang, mögliche Norm, Beleg, Unsicherheit und nächster Schritt."
        }

        styles {
            element "Person" {
                shape Person
                background "#08427b"
                color "#ffffff"
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
            element "Optional" {
                background "#85bbf0"
                color "#000000"
            }
        }
    }
}
