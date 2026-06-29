# Hoyst Tech Challenge: Der erste Fall

## Kontext

Hoyst baut KI-Software für Insolvenzverwaltung. Wenn ein Insolvenzverfahren eröffnet wird, übernimmt der Verwalter ein Unternehmen, das er nicht kennt. Was er bekommt, ist ein Datenraum: Verträge, E-Mail-Korrespondenz, Kontoauszüge, Behördenpost, Gerichtsbeschlüsse.

Eine seiner zentralen Aufgaben: rückblickend verstehen, was in den Monaten und Jahren vor dem Insolvenzantrag passiert ist. Insbesondere muss er prüfen, ob Vermögen abgeflossen ist, das er für die Gläubiger zurückholen kann. Das deutsche Recht nennt das Insolvenzanfechtung: Bestimmte Zahlungen, Übertragungen und andere Vorgänge aus der Zeit vor dem Antrag können unter bestimmten Voraussetzungen rückabgewickelt werden. Welche Voraussetzungen das sind, steht in der Insolvenzordnung (InsO).

Heute macht diese Analyse ein Anwalt von Hand: Dokumente lesen, Zeitachse rekonstruieren, Auffälligkeiten gegen das Gesetz halten. Das dauert Tage bis Wochen pro Fall.

## Material

In diesem Repo liegt alles, was du brauchst:

`data/demo-case/` enthält einen fiktiven, aber realistischen Fall: die Nordwind Spedition GmbH, über deren Vermögen das Insolvenzverfahren eröffnet wurde. 23 PDFs, so wie sie ein Verwalter bekommen würde: Eröffnungsbeschluss, Kontoauszüge, Verträge, E-Mail-Threads, Behördenschreiben. Manches davon ist relevant, manches nicht.

`data/gesetze/inso/` enthält die komplette Insolvenzordnung als Markdown, eine Datei pro Paragraph, mit Metadaten im Frontmatter (Paragraphennummer, Titel).

## Insolvenzanfechtung in fünf Minuten

Damit du nicht bei Null startest, hier eine stark vereinfachte Landkarte. Die Tatbestände haben im Detail viele Feinheiten; dafür ist dein Interviewer da.

Grundidee: Wer kurz vor der Pleite noch Vermögen verschiebt oder einzelne Gläubiger bevorzugt bedient, benachteiligt die übrigen Gläubiger. Der Verwalter kann solche Vorgänge anfechten und das Weggegebene zur Masse zurückfordern (§ 143 InsO). Voraussetzung ist immer eine Benachteiligung der Gläubiger (§ 129 InsO). Die Fristen der einzelnen Tatbestände rechnen vom Insolvenzantrag aus rückwärts (§§ 139, 140 InsO).

Die wichtigsten Tatbestände:


| Norm  | Worum es geht                                                                                                                   | Zeitfenster                         | Typisches Beispiel                                                                                     |
| ----- | ------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------ |
| § 130 | Kongruente Deckung: Gläubiger bekommt, was ihm zusteht, aber der Schuldner ist schon zahlungsunfähig und der Gläubiger weiß es  | 3 Monate vor Antrag                 | Lieferant erhält eine fällige Rechnung bezahlt, kennt aber aus dem Mahnverkehr die Zahlungsunfähigkeit |
| § 131 | Inkongruente Deckung: Gläubiger bekommt etwas, das ihm nicht, nicht so oder nicht zu der Zeit zustand                           | 3 Monate vor Antrag                 | Kontopfändung kurz vor dem Antrag; Sicherheit, auf die kein Anspruch bestand                           |
| § 133 | Vorsatzanfechtung: Schuldner handelt mit dem Vorsatz, seine Gläubiger zu benachteiligen, und der Empfänger kennt diesen Vorsatz | bis zu 4 Jahre (in Sonderfällen 10) | Zahlung unter Druck ("sonst Liefersperre"), während andere Gläubiger leer ausgehen                     |
| § 134 | Unentgeltliche Leistung                                                                                                         | 4 Jahre                             | Schenkung; Vermögensübertragung ohne Gegenleistung                                                     |
| § 135 | Rückzahlung von Gesellschafterdarlehen                                                                                          | 1 Jahr                              | GmbH zahlt kurz vor der Pleite das Darlehen ihres Gesellschafters zurück                               |


Dazu drei Querschnittsnormen: § 138 definiert nahestehende Personen (z.B. Gesellschaften mit demselben Geschäftsführer); bei ihnen gelten Beweiserleichterungen zugunsten des Verwalters. § 142 nimmt Bargeschäfte aus: Leistung gegen gleichwertige Gegenleistung in engem zeitlichen Zusammenhang ist in der Regel nicht anfechtbar (sonst wäre jeder Diesel-Einkauf ein Fall). Und § 88 InsO (Rückschlagsperre) macht Sicherungen unwirksam, die im letzten Monat vor dem Antrag oder danach im Wege der Zwangsvollstreckung erlangt wurden.

Für die Praxis heißt das: Es kommt fast immer auf das Zusammenspiel von drei Dingen an: Was ist passiert (Vorgang), wann relativ zum Insolvenzantrag (Frist), und was wussten die Beteiligten (Kenntnis). Das Wissen über Kenntnis steckt selten in Verträgen, sondern in Korrespondenz.

## Aufgabe

Entwirf ein System, das aus diesen Dokumenten eine erste Analyse für den Insolvenzverwalter erzeugt: Welche Vorgänge in diesem Fall verdienen eine genauere Prüfung, warum, und worauf stützt sich das jeweils?

Das ist ein offenes Problem. Es gibt keine Musterlösung, und es gibt mehr als einen guten Weg. Ob dein Entwurf eine Pipeline ist, ein Agent, mehrere, oder etwas ganz anderes; was das System ausgibt und in welcher Form; wo das Modell arbeitet und wo der Mensch: alles deine Entscheidung. Genauso wichtig wie das, was du baust, ist das, was du bewusst weglässt.

Du musst kein Insolvenzrecht können. Fragen zu stellen ist ausdrücklich Teil der Aufgabe.

## Ablauf (ca. 60 Minuten)

1. **Problem verstehen.** Verschaff dir ein Bild von Fall, Material und Nutzer. Stell Fragen.
2. **Lösung entwerfen.** Skizziere dein System: Bausteine, Datenfluss, Output. Whiteboard, Notizen, Stichpunkte, was immer dir liegt.
3. **Plan schreiben (letzte ca. 20 Minuten).** Schreib gemeinsam mit dem Interviewer einen Plan, mit dem ein Coding-Agent (z.B. Claude Code) eine erste rohe Version deines Entwurfs bauen würde.

Es wird kein lauffähiger Code erwartet.

## Worauf wir achten

Wie du ein unbekanntes Problem durchdringst. Welche Fragen du stellst. Wie du priorisierst, wenn die Zeit nicht für alles reicht. Und wie du Arbeit so zerlegst und beschreibst, dass ein Coding-Agent etwas Brauchbares daraus baut.