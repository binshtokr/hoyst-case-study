workspace "ERP-Architektur Case Study" "C4-Modell mit Fokus auf die zentrale Angular-Webanwendung" {

    model {
        financeUser = person "Finance-Nutzer" "Erstellt Finanzberichte und wertet ERP-Daten aus." "person"
        hrManager = person "HR-Manager" "Erfasst neue Mitarbeitende und steuert Onboarding-Prozesse." "person"
        identityProvider = softwareSystem "Identity Provider / SSO" "Stellt Anmeldung, Benutzeridentität und Rolleninformationen bereit." "external"
        erpSystem = softwareSystem "ERP-System" "Zentrale ERP-Plattform mit mehreren fachlichen Domänen." {
        angularApp = container "Zentrale Angular-Webanwendung" "Frontend-Anwendung, in der die Domänen Finance, HR, Sales und Inventory zusammengeführt werden." "Angular" "frontend" {
        appShell = component "App Shell / Routing" "Stellt Layout, Navigation und lazy-loaded Routen für die Domänen bereit." "Angular Router" "shell"
        coreServices = component "Core Services" "Bündelt technische Querschnittsfunktionen wie Authentifizierung, HTTP-Interceptor, Fehlerbehandlung und Konfiguration." "Angular Services" "core"
        sharedUi = component "Shared UI / Design System" "Stellt gemeinsame UI-Komponenten, Formulare, Tabellen und Styling-Regeln bereit." "Angular Components" "shared"
        globalState = component "Globaler Zustand" "Enthält domänenübergreifende Zustände wie Benutzer, Berechtigungen, Tenant, Sprache und Layout." "NgRx Store / SignalStore" "state"
        financeFeature = component "Finance Feature-Bereich" "Lazy-loaded Bereich für Finanzberichte, Tabellen, Charts und Filter." "Angular Feature Area" "domain"
        hrFeature = component "HR Feature-Bereich" "Lazy-loaded Bereich für Mitarbeiter-Onboarding und HR-Workflows." "Angular Feature Area" "domain"
        salesFeature = component "Sales Feature-Bereich" "Lazy-loaded Bereich für vertriebsbezogene Ansichten." "Angular Feature Area" "domain"
        inventoryFeature = component "Inventory Feature-Bereich" "Lazy-loaded Bereich für Bestands- und Inventaransichten." "Angular Feature Area" "domain"
        }
            financeApi = container "Finance API" "Backend-API für den Finance Bounded Context." "REST API" "backend"
            hrApi = container "HR API" "Backend-API für den HR Bounded Context." "REST API" "backend"
            salesApi = container "Sales API" "Backend-API für den Sales Bounded Context." "REST API" "backend"
            inventoryApi = container "Inventory API" "Backend-API für den Inventory Bounded Context." "REST API" "backend"

            financeUser -> angularApp "nutzt für Finanzberichte"
            hrManager -> angularApp "nutzt für Mitarbeiter-Onboarding"

            angularApp -> identityProvider "nutzt für Login, SSO und Rolleninformationen"
            appShell -> coreServices "nutzt technische Basisdienste"
            appShell -> sharedUi "nutzt gemeinsames Layout und UI-Komponenten"
            appShell -> globalState "liest Benutzer- und Berechtigungszustand"
            appShell -> financeFeature "lädt Finance-Bereich lazy"
            appShell -> hrFeature "lädt HR-Bereich lazy"
            appShell -> salesFeature "lädt Sales-Bereich lazy"
            appShell -> inventoryFeature "lädt Inventory-Bereich lazy"

            financeFeature -> sharedUi "nutzt gemeinsame UI-Komponenten"
            hrFeature -> sharedUi "nutzt gemeinsame UI-Komponenten"
            salesFeature -> sharedUi "nutzt gemeinsame UI-Komponenten"
            inventoryFeature -> sharedUi "nutzt gemeinsame UI-Komponenten"

            financeFeature -> globalState "liest Berechtigungen"
            hrFeature -> globalState "liest Berechtigungen"
            salesFeature -> globalState "liest Berechtigungen"
            inventoryFeature -> globalState "liest Berechtigungen"
            angularApp -> financeApi "ruft Finanzdaten und Berichte ab"
            angularApp -> hrApi "ruft HR- und Onboarding-Daten ab"
            angularApp -> salesApi "ruft Vertriebsdaten ab"
            angularApp -> inventoryApi "ruft Bestands- und Inventardaten ab"
        }
    }

    views {
        systemContext erpSystem "SystemContext" {
            include *
            autolayout
        }

        container erpSystem "Containers" {
            include *
            autolayout
        }
        component angularApp "AngularComponents" {
        include *
        autolayout
        }

        styles {
            element "person" {
                shape person
                background "#9fb0b1"
                color "#ffffff"
            }

            element "frontend" {
                background "#1168bd"
                color "#ffffff"
            }

            element "backend" {
                background "#a77e7e"
                color "#ffffff"
            }

            element "external" {
                background "#2484d3"
                color "#ffffff"
            }
        }
    }
}