workspace "Hoyst Tech Challenge - Insolvenzanfechtung MVP" "C4-Architekturmodell für eine KI-gestützte Erstanalyse von Insolvenzdokumenten." {

    !identifiers hierarchical

    model {
        insolvencyProfessional = person "Insolvenzverwalter / Anwalt" "Benötigt eine schnelle, quellenbasierte Erstanalyse eines Insolvenz-Datenraums. Prüft verdächtige Vorgänge und trifft die finale juristische Entscheidung."
        paralegal = person "Juristischer Sachbearbeiter / Analyst" "Unterstützt den Insolvenzverwalter oder Anwalt bei der Prüfung von Dokumenten, Zeitachsen und Verdachtsfällen."

        demoDataRoom = softwareSystem "Demo-Fall-Datenraum" "Repository-Ordner data/demo-case/ mit 23 PDFs: Kontoauszüge, Verträge, E-Mails, Behördenschreiben und Gerichtsdokumente." "Dateisystem" {
            tags "External"
        }

        insoKnowledgeBase = softwareSystem "InsO-Markdown-Wissensbasis" "Repository-Ordner data/gesetze/inso/ mit einer Markdown-Datei pro Paragraph der Insolvenzordnung inklusive Frontmatter-Metadaten." "Markdown-Dateien" {
            tags "External"
        }

        llmProvider = softwareSystem "LLM-Anbieter" "Sprachmodell für das semantische Verständnis von E-Mails, Verträgen und Erklärungen. Das Modell darf keine finale juristische Entscheidung treffen." "LLM API" {
            tags "External"
        }

        hoyst = softwareSystem "Hoyst Analyse-Assistent für Insolvenzfälle" "Verwandelt einen unstrukturierten Insolvenz-Datenraum in eine strukturierte Erstanalyse mit Timeline, Verdachtsfällen, Belegen und offenen Fragen." {

            cli = container "MVP CLI / Batch Runner" "Führt das erste MVP lokal gegen das Demo-Repository aus und erzeugt einen Markdown-Report." "Python CLI"
            reviewUi = container "Review UI / Report Viewer" "Optionale Oberfläche, in der Anwälte Verdachtsfälle, Quellen, Unsicherheiten und nächste Schritte prüfen können." "Web UI"

            ingestion = container "Dokumentenaufnahme" "Lädt PDFs und InsO-Markdown-Dateien und bewahrt Dateinamen, Seitenzahlen und Rohtextreferenzen." "Python"
            pdfParser = container "PDF-Textextraktion / OCR" "Extrahiert Text aus maschinenlesbaren PDFs und nutzt bei Bedarf OCR als Fallback." "PyMuPDF / OCR"
            documentClassifier = container "Dokumentenklassifikation" "Klassifiziert Dokumente als Kontoauszug, E-Mail, Vertrag, Gerichtsdokument, Behördenschreiben oder Sonstiges." "Regeln + LLM"
            keyDateExtractor = container "Stichtags-Extraktion" "Findet relevante Daten wie Insolvenzantragsdatum und Eröffnungsdatum." "Regeln + LLM"
            entityEventExtractor = container "Entitäts- und Ereignisextraktion" "Extrahiert Parteien, Beträge, Zahlungsdaten, Kontobewegungen, E-Mails, Forderungen, Warnhinweise und Signale für Zahlungsschwierigkeiten." "Regeln + LLM"
            timelineBuilder = container "Timeline Builder" "Erstellt eine chronologische Zeitachse aus Zahlungen, Kommunikation, Verträgen und juristischen Ereignissen." "Python"
            insoRetrieval = container "InsO Retrieval / RAG" "Ruft relevante InsO-Paragraphen für mögliche Verdachtsfälle ab, insbesondere §§ 88, 129, 130, 131, 133, 134, 135, 138 und 142 InsO." "Embeddings / Suche"
            legalHeuristicEngine = container "Juristische Heuristik-Engine" "Wendet deterministische Prüfungen für Fristen, Vorgangstypen, Beteiligte, mögliche Ausnahmen und fehlende Fakten an." "Python-Regeln"
            semanticReasoner = container "Semantische Analyse-Schicht" "Nutzt das LLM, um unstrukturierte Korrespondenz zu interpretieren, insbesondere Kenntnis von Zahlungsschwierigkeiten, Drohungen, Mahnungen und Drucksituationen." "LLM-Orchestrierung"
            evidenceLinker = container "Beleg-Verknüpfung" "Verknüpft jeden Verdachtsfall mit konkreten Dokumenten, Seitenreferenzen und unterstützenden Textausschnitten. Nicht belegte Fakten werden als unbekannt markiert." "Python"
            findingRanker = container "Verdachtsfall-Priorisierung" "Priorisiert Verdachtsfälle nach Relevanz, Betrag, juristischer Passung, Belegstärke und Unsicherheit." "Regeln + Scoring"
            reportGenerator = container "Report Generator" "Erzeugt einen Markdown-Report mit Executive Summary, Stichtagen, Timeline, Verdachtsfällen, juristischen Hypothesen, Quellen, Unsicherheiten und nächsten Schritten." "Python / Markdown"

            caseStore = container "Fallanalyse-Speicher" "Speichert geparste Dokumente, extrahierte Ereignisse, Zahlungen, Entitäten, Verdachtsfälle und Quellenreferenzen." "SQLite oder PostgreSQL" {
                tags "Database"
            }

            evidenceIndex = container "Beleg-Index / Vektor-Speicher" "Indexiert Dokumentausschnitte und InsO-Paragraphen für Retrieval und quellenbasierte Analyse." "FAISS oder pgvector" {
                tags "Database"
            }
        }

        insolvencyProfessional -> hoyst.reviewUi "Prüft strukturierte Erstanalyse, Verdachtsfälle und Belege"
        paralegal -> hoyst.reviewUi "Prüft extrahierte Timeline und unterstützende Dokumente"
        insolvencyProfessional -> hoyst.cli "Startet oder erhält den MVP-Report im Interview- oder Demo-Setup"

        hoyst.cli -> hoyst.ingestion "Startet Analyse für den Demo-Fall"
        hoyst.ingestion -> demoDataRoom "Lädt 23 Fall-PDFs"
        hoyst.ingestion -> insoKnowledgeBase "Lädt InsO-Markdown-Dateien"
        hoyst.ingestion -> hoyst.pdfParser "Übergibt PDFs zur Textextraktion"
        hoyst.pdfParser -> hoyst.caseStore "Speichert extrahierten Text mit Dateiname und Seitenreferenzen"

        hoyst.documentClassifier -> hoyst.caseStore "Liest extrahierten Text und schreibt Dokumenttypen"
        hoyst.keyDateExtractor -> hoyst.caseStore "Liest Gerichtsdokumente und speichert Insolvenzantrags- und Eröffnungsdaten"
        hoyst.entityEventExtractor -> hoyst.caseStore "Liest klassifizierte Dokumente und speichert Ereignisse, Zahlungen, Entitäten und Hinweise auf Zahlungsschwierigkeiten"
        hoyst.timelineBuilder -> hoyst.caseStore "Liest extrahierte Ereignisse und schreibt chronologische Timeline"

        hoyst.insoRetrieval -> insoKnowledgeBase "Ruft relevante Rechtsnormen ab"
        hoyst.insoRetrieval -> hoyst.evidenceIndex "Indexiert und durchsucht InsO-Paragraphen und Dokumentausschnitte"
        hoyst.legalHeuristicEngine -> hoyst.caseStore "Liest Zahlungen, Ereignisse und Stichtage"
        hoyst.legalHeuristicEngine -> hoyst.insoRetrieval "Fragt relevante Paragraphen für juristische Hypothesen ab"
        hoyst.semanticReasoner -> llmProvider "Fragt semantische Interpretation von E-Mails, Verträgen und Erklärungen an"
        hoyst.semanticReasoner -> hoyst.evidenceIndex "Ruft unterstützende Textausschnitte ab"
        hoyst.evidenceLinker -> hoyst.caseStore "Verknüpft Verdachtsfälle mit Quelldokumenten, Seiten und Textausschnitten"
        hoyst.findingRanker -> hoyst.caseStore "Priorisiert Kandidaten nach Wichtigkeit und Belegstärke"
        hoyst.reportGenerator -> hoyst.caseStore "Liest Timeline, Verdachtsfälle, Belege und Unsicherheiten"
        hoyst.reportGenerator -> hoyst.reviewUi "Veröffentlicht Report zur menschlichen Prüfung"
        hoyst.reportGenerator -> insolvencyProfessional "Erzeugt Markdown-Report als MVP-Ergebnis"
    }

    views {
        systemContext hoyst "SystemContext" {
            include *
            autolayout lr
            title "Systemkontext - Hoyst Analyse-Assistent für Insolvenzfälle"
            description "Hoyst ersetzt nicht den Anwalt. Das System beschleunigt die erste Prüfung eines Insolvenz-Datenraums, indem es eine quellenbasierte Timeline und Verdachtsfälle erzeugt."
        }

        container hoyst "ContainerView" {
            include *
            autolayout lr
            title "Container View - MVP-Architektur"
            description "Hybride Pipeline: deterministische Regeln für Daten, Beträge und Fristen; LLM für semantisches Verständnis unstrukturierter Korrespondenz; strikte Quellenverknüpfung für juristische Nachvollziehbarkeit."
        }

        dynamic hoyst "MVPFlow" "Hauptablauf der MVP-Analyse" {
            insolvencyProfessional -> hoyst.cli "Analyse für data/demo-case starten"
            hoyst.cli -> hoyst.ingestion "Dokumente laden"
            hoyst.ingestion -> demoDataRoom "PDFs lesen"
            hoyst.ingestion -> insoKnowledgeBase "InsO-Markdown lesen"
            hoyst.ingestion -> hoyst.pdfParser "Text extrahieren"
            hoyst.pdfParser -> hoyst.caseStore "Text mit Quellenreferenzen speichern"
            hoyst.documentClassifier -> hoyst.caseStore "Dokumenttypen klassifizieren"
            hoyst.keyDateExtractor -> hoyst.caseStore "Insolvenzantragsdatum finden"
            hoyst.entityEventExtractor -> hoyst.caseStore "Zahlungen, Parteien und Hinweise auf Zahlungsschwierigkeiten extrahieren"
            hoyst.timelineBuilder -> hoyst.caseStore "Timeline erstellen"
            hoyst.legalHeuristicEngine -> hoyst.caseStore "Verdachtsfälle erzeugen"
            hoyst.semanticReasoner -> llmProvider "Kontext und Kenntnissignale interpretieren"
            hoyst.evidenceLinker -> hoyst.caseStore "Belege anhängen und Unsicherheiten markieren"
            hoyst.findingRanker -> hoyst.caseStore "Verdachtsfälle priorisieren"
            hoyst.reportGenerator -> insolvencyProfessional "Markdown-Report zurückgeben"
            autolayout lr
            title "Dynamic View - Von Dokumenten zur ersten juristischen Prüfung"
            description "Das System verwandelt rohe PDFs in einen für Anwälte prüfbaren Report: verdächtiger Vorgang, mögliche Norm, Beleg, Unsicherheit und nächster Schritt."
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