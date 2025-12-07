/* 
  Block 2 - Testfälle

  Die folgenden Testfälle sollen Sie überprüfen, indem Sie nacheinander
  jeweils ein Statement ausführen und alle anderen auskommentieren.
  Überprüfen Sie nach jedem Statement, ob Ihr Trigger die erwartete Ausgabe liefert 
  und die Tabellen die erwarteten Inhalte haben.
*/
-- ------------------------------------------------------------------------------------------------
-- Testfall 1: Angegebenes Regal hat zu wenig Kapazität 
--INSERT INTO ware VALUES (10, 1, 'M12-S', 'Schraube', 5, 20, 6.0, to_date('10.08.2024', 'DD.MM.YYYY'));

-- Wird zurückgewiesen wegen Regel 1
-- Erwartete Ausgabe 
-- ERROR:  REGEL 1 - INSERT: Neue Ware darf nur dann hinzugefügt werden, wenn dadurch die Kapzität des Regals nicht überschritten wird!

-- Tabellen sind unverändert

-- ------------------------------------------------------------------------------------------------
-- Testfall 2: Angegebenes Regal hat genügend Kapazität 
--INSERT INTO ware VALUES (10, 1, 'M12-S', 'Schraube', 2, 20, 6.0, to_date('10.08.2024', 'DD.MM.YYYY'));

-- OK
/* neuer Zustand der Tabellen:
dbs000=> table ware; table regal; table warenhistorie;
 invnr | regalnr | warenname |   typ    | anzahl | platzproeinheit | preisproeinheit | datumverfuegbar 
-------+---------+-----------+----------+--------+-----------------+-----------------+-----------------
     1 |       1 | M6-S      | Schraube |     10 |               5 |            2.00 | 2024-01-01
     2 |       1 | M8-S      | Schraube |      5 |              10 |            2.50 | 2024-03-15
     3 |       1 | M10-S     | Schraube |      5 |              15 |            3.00 | 2024-03-15
     4 |       2 | M6-M      | Mutter   |      5 |               5 |            1.50 | 2024-01-01
     5 |       2 | M8-M      | Mutter   |      3 |              10 |            2.00 | 2024-03-15
     6 |       2 | M10-M     | Mutter   |      3 |              15 |            2.40 | 2024-03-15
     7 |       3 | R-T       | Rohr     |     10 |               5 |            5.00 | 2024-06-01
     8 |       3 | R-N       | Rohr     |      5 |              20 |            7.50 | 2024-06-01
     9 |       3 | R-W       | Rohr     |     10 |               7 |            4.90 | 2024-07-01
    10 |       1 | M12-S     | Schraube |      2 |              20 |            6.00 | 2024-08-10
(10 Zeilen)

 regalnr | lage | platzgesamt | platzbelegt 
---------+------+-------------+-------------
       2 | B-2  |         120 |         100
       3 | C-37 |         310 |         220
       1 | A-5  |         220 |         215
(3 Zeilen)

 whnr | invnr | regalnr | warenname | preisalt | verfuegbaralt | operation | benutzername | geaendertam 
------+-------+---------+-----------+----------+---------------+-----------+--------------+-------------
(0 Zeilen)

*/


-- ------------------------------------------------------------------------------------------------
-- Testfall 3: Keine Regalnummer angegeben --> wird durch Trigger bestimmt (Regel 2)
--INSERT INTO ware(invnr, warenname, typ, anzahl, platzproeinheit, preisproeinheit, datumverfuegbar) VALUES (11, 'R-M', 'Rohr', 5, 15, 6.5, to_date('15.08.2024', 'DD.MM.YYYY'));

-- OK 
-- Erwartete Ausgabe
-- NOTICE:  Freier Platz in Regal 3 gefunden!

/* neuer Zustand der Tabellen:
dbs000=> table ware; table regal; table warenhistorie;
 invnr | regalnr | warenname |   typ    | anzahl | platzproeinheit | preisproeinheit | datumverfuegbar 
-------+---------+-----------+----------+--------+-----------------+-----------------+-----------------
     1 |       1 | M6-S      | Schraube |     10 |               5 |            2.00 | 2024-01-01
     2 |       1 | M8-S      | Schraube |      5 |              10 |            2.50 | 2024-03-15
     3 |       1 | M10-S     | Schraube |      5 |              15 |            3.00 | 2024-03-15
     4 |       2 | M6-M      | Mutter   |      5 |               5 |            1.50 | 2024-01-01
     5 |       2 | M8-M      | Mutter   |      3 |              10 |            2.00 | 2024-03-15
     6 |       2 | M10-M     | Mutter   |      3 |              15 |            2.40 | 2024-03-15
     7 |       3 | R-T       | Rohr     |     10 |               5 |            5.00 | 2024-06-01
     8 |       3 | R-N       | Rohr     |      5 |              20 |            7.50 | 2024-06-01
     9 |       3 | R-W       | Rohr     |     10 |               7 |            4.90 | 2024-07-01
    10 |       1 | M12-S     | Schraube |      2 |              20 |            6.00 | 2024-08-10
    11 |       3 | R-M       | Rohr     |      5 |              15 |            6.50 | 2024-08-15
(11 Zeilen)

 regalnr | lage | platzgesamt | platzbelegt 
---------+------+-------------+-------------
       2 | B-2  |         120 |         100
       1 | A-5  |         220 |         215
       3 | C-37 |         310 |         295
(3 Zeilen)

 whnr | invnr | regalnr | warenname | preisalt | verfuegbaralt | operation | benutzername | geaendertam 
------+-------+---------+-----------+----------+---------------+-----------+--------------+-------------
(0 Zeilen)

*/

-- ------------------------------------------------------------------------------------------------
--Testfall 4: Kein Regal angegeben (Regel 2), aber kein passendes Regal gefunden (genügend Platz und weniger als 4 Waren)

--INSERT INTO ware(invnr, warenname, typ, anzahl, platzproeinheit, preisproeinheit, datumverfuegbar) VALUES (12, 'R-ML', 'Rohr', 15, 25, 8.5, to_date('15.08.2024', 'DD.MM.YYYY'));

-- Wird zurückgewiesen 
-- Erwartete Ausgabe: ERROR: INSERT: Kein Regal mit weniger als 4 Waren verfügt über genug freien Platz!

-- Tabellen bleiben unverändert


-- ------------------------------------------------------------------------------------------------
--Testfall 5: Angegebenes Regal 3 hat schon vier verschiedene Waren (Regel 3)
--INSERT INTO ware VALUES (12, 3, 'R-S', 'Rohr', 2, 5, 8.0, to_date('10.10.2024', 'DD.MM.YYYY'));

-- Wird zurückgewiesen wegen Regel 3
-- Erwartete Ausgabe: ERROR:  Regel 3 - INSERT: Es dürfen nicht mehr als 4 unterschiedliche Waren in einem Regal gelagert werden!

-- Tabellen bleiben unverändert

-- ------------------------------------------------------------------------------------------------
--Testfall 6: Ware wird gelöscht --> Regalkapazität muss angepasst werden (Regel 6)

--DELETE FROM ware WHERE invnr = 8;
-- OK, wegen Regel 6 muss das Regal 3 angepasst werden
-- Erwartete Ausgabe: NOTICE:  Regel 5 - DELETE: Ware entfernt. Regalkapazität wird aktualisiert!

/* neuer Zustand der Tabellen:
dbs000=> table ware; table regal; table warenhistorie;
 invnr | regalnr | warenname |   typ    | anzahl | platzproeinheit | preisproeinheit | datumverfuegbar 
-------+---------+-----------+----------+--------+-----------------+-----------------+-----------------
     1 |       1 | M6-S      | Schraube |     10 |               5 |            2.00 | 2024-01-01
     2 |       1 | M8-S      | Schraube |      5 |              10 |            2.50 | 2024-03-15
     3 |       1 | M10-S     | Schraube |      5 |              15 |            3.00 | 2024-03-15
     4 |       2 | M6-M      | Mutter   |      5 |               5 |            1.50 | 2024-01-01
     5 |       2 | M8-M      | Mutter   |      3 |              10 |            2.00 | 2024-03-15
     6 |       2 | M10-M     | Mutter   |      3 |              15 |            2.40 | 2024-03-15
     7 |       3 | R-T       | Rohr     |     10 |               5 |            5.00 | 2024-06-01
     9 |       3 | R-W       | Rohr     |     10 |               7 |            4.90 | 2024-07-01
    10 |       1 | M12-S     | Schraube |      2 |              20 |            6.00 | 2024-08-10
    11 |       3 | R-M       | Rohr     |      5 |              15 |            6.50 | 2024-08-15
(10 Zeilen)

 regalnr | lage | platzgesamt | platzbelegt 
---------+------+-------------+-------------
       2 | B-2  |         120 |         100
       1 | A-5  |         220 |         215
       3 | C-37 |         310 |         195
(3 Zeilen)

 whnr | invnr | regalnr | warenname | preisalt | verfuegbaralt | operation | benutzername | geaendertam 
------+-------+---------+-----------+----------+---------------+-----------+--------------+-------------
    1 |     8 |       3 | R-N       |     7.50 | 2024-06-01    | DELETE    | dbs000       | 2024-12-11
(1 Zeile)
*/

-- ------------------------------------------------------------------------------------------------
-- Testfall 7: Neue Ware in Regal 3 --> jetzt ok, weil Anzahl unterschiedlicher Waren jetzt wieder = 3
--INSERT INTO ware VALUES (12, 3, 'R-S', 'Rohr', 2, 5, 8.0, to_date('10.10.2024', 'DD.MM.YYYY'));

-- OK
/* neuer Zustand der Tabellen:
dbs000=> table ware; table regal; table warenhistorie;
 invnr | regalnr | warenname |   typ    | anzahl | platzproeinheit | preisproeinheit | datumverfuegbar 
-------+---------+-----------+----------+--------+-----------------+-----------------+-----------------
     1 |       1 | M6-S      | Schraube |     10 |               5 |            2.00 | 2024-01-01
     2 |       1 | M8-S      | Schraube |      5 |              10 |            2.50 | 2024-03-15
     3 |       1 | M10-S     | Schraube |      5 |              15 |            3.00 | 2024-03-15
     4 |       2 | M6-M      | Mutter   |      5 |               5 |            1.50 | 2024-01-01
     5 |       2 | M8-M      | Mutter   |      3 |              10 |            2.00 | 2024-03-15
     6 |       2 | M10-M     | Mutter   |      3 |              15 |            2.40 | 2024-03-15
     7 |       3 | R-T       | Rohr     |     10 |               5 |            5.00 | 2024-06-01
     9 |       3 | R-W       | Rohr     |     10 |               7 |            4.90 | 2024-07-01
    10 |       1 | M12-S     | Schraube |      2 |              20 |            6.00 | 2024-08-10
    11 |       3 | R-M       | Rohr     |      5 |              15 |            6.50 | 2024-08-15
    12 |       3 | R-S       | Rohr     |      2 |               5 |            8.00 | 2024-10-10
(11 Zeilen)

 regalnr | lage | platzgesamt | platzbelegt 
---------+------+-------------+-------------
       2 | B-2  |         120 |         100
       1 | A-5  |         220 |         215
       3 | C-37 |         310 |         205
(3 Zeilen)

 whnr | invnr | regalnr | warenname | preisalt | verfuegbaralt | operation | benutzername | geaendertam 
------+-------+---------+-----------+----------+---------------+-----------+--------------+-------------
    1 |     8 |       3 | R-N       |     7.50 | 2024-06-01    | DELETE    | dbs000       | 2024-12-11
(1 Zeile)
*/
-- ------------------------------------------------------------------------------------------------
-- Testfall 8: Bestandsware wird zu stark erhöht
 --UPDATE ware SET anzahl = 50 WHERE invnr = 5;

-- Wird zurückgewiesen wegen Regel 4
-- Erwartete Ausgabe: ERROR:  REGEL 4 - UPDATE: Die Anzahl/Platzproeinheit  bestehender Ware darf nicht über die Regalkapazität erhöht werden!

-- Tabellen bleiben unverändert

-- ------------------------------------------------------------------------------------------------
-- Testfall 9: Gültiges Update mit neuem Eintrag in warenhistorie
--UPDATE ware SET anzahl = 5, preisproeinheit = 2.10 WHERE invnr = 5;

-- OK
/* neuer Zustand der Tabellen:
dbs000=> table ware; table regal; table warenhistorie;
 invnr | regalnr | warenname |   typ    | anzahl | platzproeinheit | preisproeinheit | datumverfuegbar 
-------+---------+-----------+----------+--------+-----------------+-----------------+-----------------
     1 |       1 | M6-S      | Schraube |     10 |               5 |            2.00 | 2024-01-01
     2 |       1 | M8-S      | Schraube |      5 |              10 |            2.50 | 2024-03-15
     3 |       1 | M10-S     | Schraube |      5 |              15 |            3.00 | 2024-03-15
     4 |       2 | M6-M      | Mutter   |      5 |               5 |            1.50 | 2024-01-01
     6 |       2 | M10-M     | Mutter   |      3 |              15 |            2.40 | 2024-03-15
     7 |       3 | R-T       | Rohr     |     10 |               5 |            5.00 | 2024-06-01
     9 |       3 | R-W       | Rohr     |     10 |               7 |            4.90 | 2024-07-01
    10 |       1 | M12-S     | Schraube |      2 |              20 |            6.00 | 2024-08-10
    11 |       3 | R-M       | Rohr     |      5 |              15 |            6.50 | 2024-08-15
    12 |       3 | R-S       | Rohr     |      2 |               5 |            8.00 | 2024-10-10
     5 |       2 | M8-M      | Mutter   |      5 |              10 |            2.10 | 2024-03-15
(11 Zeilen)

 regalnr | lage | platzgesamt | platzbelegt 
---------+------+-------------+-------------
       1 | A-5  |         220 |         215
       3 | C-37 |         310 |         205
       2 | B-2  |         120 |         120
(3 Zeilen)

 whnr | invnr | regalnr | warenname | preisalt | verfuegbaralt | operation | benutzername | geaendertam 
------+-------+---------+-----------+----------+---------------+-----------+--------------+-------------
    1 |     8 |       3 | R-N       |     7.50 | 2024-06-01    | DELETE    | dbs000       | 2024-12-11
    2 |     5 |       2 | M8-M      |     2.00 | 2024-03-15    | UPDATE    | dbs000       | 2024-12-11
(2 Zeilen)

*/

-- ------------------------------------------------------------------------------------------------
-- Testfall 10: Ungültiges Update, weil Verfügbarkeitsdatum vorverlegt wird (Regel 5)

--UPDATE ware SET datumverfuegbar = TO_DATE('15.03.2020', 'DD.MM.YYYY') WHERE invnr = 6;
-- Wird korrigiert wegen Regel 5
-- Erwartete Ausgabe: NOTICE:  Regel 5 - UPDATE: Das Verfügbarkeitsdatum wurde nicht verändert, weil es  nicht rückwirkend nach hinten verschoben werden darf!

-- Da sich der Datensatz sonst nicht geändert hat Tabellen bleiben unverändert


-- ------------------------------------------------------------------------------------------------
-- Testfall 11: Gültiges Update, weil Verfügbarkeitsdatum auf späteres Datum gelegt wird (Regel 5)

--UPDATE ware SET datumverfuegbar = TO_DATE('15.03.2025', 'DD.MM.YYYY') WHERE invnr = 6;
-- OK 

/* neuer Tabellenzustand:
dbs000=> table ware; table regal; table warenhistorie;
 invnr | regalnr | warenname |   typ    | anzahl | platzproeinheit | preisproeinheit | datumverfuegbar 
-------+---------+-----------+----------+--------+-----------------+-----------------+-----------------
     1 |       1 | M6-S      | Schraube |     10 |               5 |            2.00 | 2024-01-01
     2 |       1 | M8-S      | Schraube |      5 |              10 |            2.50 | 2024-03-15
     3 |       1 | M10-S     | Schraube |      5 |              15 |            3.00 | 2024-03-15
     4 |       2 | M6-M      | Mutter   |      5 |               5 |            1.50 | 2024-01-01
     7 |       3 | R-T       | Rohr     |     10 |               5 |            5.00 | 2024-06-01
     9 |       3 | R-W       | Rohr     |     10 |               7 |            4.90 | 2024-07-01
    10 |       1 | M12-S     | Schraube |      2 |              20 |            6.00 | 2024-08-10
    11 |       3 | R-M       | Rohr     |      5 |              15 |            6.50 | 2024-08-15
    12 |       3 | R-S       | Rohr     |      2 |               5 |            8.00 | 2024-10-10
     5 |       2 | M8-M      | Mutter   |      5 |              10 |            2.10 | 2024-03-15
     6 |       2 | M10-M     | Mutter   |      3 |              15 |            2.40 | 2025-03-15
(11 Zeilen)

 regalnr | lage | platzgesamt | platzbelegt 
---------+------+-------------+-------------
       1 | A-5  |         220 |         215
       3 | C-37 |         310 |         205
       2 | B-2  |         120 |         120
(3 Zeilen)

 whnr | invnr | regalnr | warenname | preisalt | verfuegbaralt | operation | benutzername | geaendertam 
------+-------+---------+-----------+----------+---------------+-----------+--------------+-------------
    1 |     8 |       3 | R-N       |     7.50 | 2024-06-01    | DELETE    | dbs000       | 2024-12-11
    2 |     5 |       2 | M8-M      |     2.00 | 2024-03-15    | UPDATE    | dbs000       | 2024-12-11
    3 |     6 |       2 | M10-M     |     2.40 | 2024-03-15    | UPDATE    | dbs000       | 2024-12-11
(3 Zeilen)
*/

-- ------------------------------------------------------------------------------------------------
-- Testfall 12: Delete mit Anpassung der Regalbelegung (Regel 6)
-- DELETE FROM ware WHERE invnr = 1;
-- OK, wegen Regel 6 wird Regal 1 angepasst
-- Erwartete Ausgabe: NOTICE:  Regel 5 - DELETE: Ware entfernt. Regalkapazität wird aktualisiert!

/* neuer Tabellenzustand:
dbs000=> table ware; table regal; table warenhistorie;
 invnr | regalnr | warenname |   typ    | anzahl | platzproeinheit | preisproeinheit | datumverfuegbar 
-------+---------+-----------+----------+--------+-----------------+-----------------+-----------------
     2 |       1 | M8-S      | Schraube |      5 |              10 |            2.50 | 2024-03-15
     3 |       1 | M10-S     | Schraube |      5 |              15 |            3.00 | 2024-03-15
     4 |       2 | M6-M      | Mutter   |      5 |               5 |            1.50 | 2024-01-01
     7 |       3 | R-T       | Rohr     |     10 |               5 |            5.00 | 2024-06-01
     9 |       3 | R-W       | Rohr     |     10 |               7 |            4.90 | 2024-07-01
    10 |       1 | M12-S     | Schraube |      2 |              20 |            6.00 | 2024-08-10
    11 |       3 | R-M       | Rohr     |      5 |              15 |            6.50 | 2024-08-15
    12 |       3 | R-S       | Rohr     |      2 |               5 |            8.00 | 2024-10-10
     5 |       2 | M8-M      | Mutter   |      5 |              10 |            2.10 | 2024-03-15
     6 |       2 | M10-M     | Mutter   |      3 |              15 |            2.40 | 2025-03-15
(10 Zeilen)

 regalnr | lage | platzgesamt | platzbelegt 
---------+------+-------------+-------------
       3 | C-37 |         310 |         205
       2 | B-2  |         120 |         120
       1 | A-5  |         220 |         165
(3 Zeilen)

 whnr | invnr | regalnr | warenname | preisalt | verfuegbaralt | operation | benutzername | geaendertam 
------+-------+---------+-----------+----------+---------------+-----------+--------------+-------------
    1 |     8 |       3 | R-N       |     7.50 | 2024-06-01    | DELETE    | dbs000       | 2024-12-11
    2 |     5 |       2 | M8-M      |     2.00 | 2024-03-15    | UPDATE    | dbs000       | 2024-12-11
    3 |     6 |       2 | M10-M     |     2.40 | 2024-03-15    | UPDATE    | dbs000       | 2024-12-11
    4 |     1 |       1 | M6-S      |     2.00 | 2024-01-01    | DELETE    | dbs000       | 2024-12-11
(4 Zeilen)
*/

-- ------------------------------------------------------------------------------------------------
-- Testfall 13: ungültiges Update wegen Umsortierung in ein anderes Regal
-- UPDATE ware SET regalnr = 1 WHERE invnr = 4;

-- Erwartete Ausgabe: ERROR:  REGEL 4 - UPDATE: Existierende Ware darf nicht in ein anderes Regal umsortiert werden
-- Tabellen bleiben unverändert

-- ------------------------------------------------------------------------------------------------
-- Testfall 14: 3 gültige Updates mit gleichzeitiger Veränderung verschiedener Attributwerte

-- UPDATE ware SET anzahl = 10, preisproeinheit = 1.50, datumverfuegbar = TO_DATE('01.05.2024', 'DD.MM.YYYY') WHERE invnr = 2;
-- OK

-- UPDATE ware SET anzahl = 2, preisproeinheit = 4.50, datumverfuegbar = TO_DATE('30.11.2024', 'DD.MM.YYYY') WHERE invnr = 2;
-- OK

-- UPDATE ware SET anzahl = 10, preisproeinheit = 3.50, datumverfuegbar = TO_DATE('10.02.2025', 'DD.MM.YYYY') WHERE invnr = 2;
-- OK

/* finaler Datenbankzustand:
dbs000=> table ware; table regal; table warenhistorie;
 invnr | regalnr | warenname |   typ    | anzahl | platzproeinheit | preisproeinheit | datumverfuegbar 
-------+---------+-----------+----------+--------+-----------------+-----------------+-----------------
     3 |       1 | M10-S     | Schraube |      5 |              15 |            3.00 | 2024-03-15
     4 |       2 | M6-M      | Mutter   |      5 |               5 |            1.50 | 2024-01-01
     7 |       3 | R-T       | Rohr     |     10 |               5 |            5.00 | 2024-06-01
     9 |       3 | R-W       | Rohr     |     10 |               7 |            4.90 | 2024-07-01
    10 |       1 | M12-S     | Schraube |      2 |              20 |            6.00 | 2024-08-10
    11 |       3 | R-M       | Rohr     |      5 |              15 |            6.50 | 2024-08-15
    12 |       3 | R-S       | Rohr     |      2 |               5 |            8.00 | 2024-10-10
     5 |       2 | M8-M      | Mutter   |      5 |              10 |            2.10 | 2024-03-15
     6 |       2 | M10-M     | Mutter   |      3 |              15 |            2.40 | 2025-03-15
     2 |       1 | M8-S      | Schraube |     10 |              10 |            3.50 | 2025-02-10
(10 Zeilen)

 regalnr | lage | platzgesamt | platzbelegt 
---------+------+-------------+-------------
       3 | C-37 |         310 |         205
       2 | B-2  |         120 |         120
       1 | A-5  |         220 |         215
(3 Zeilen)

 whnr | invnr | regalnr | warenname | preisalt | verfuegbaralt | operation | benutzername | geaendertam 
------+-------+---------+-----------+----------+---------------+-----------+--------------+-------------
    1 |     8 |       3 | R-N       |     7.50 | 2024-06-01    | DELETE    | dbs000       | 2024-12-11
    2 |     5 |       2 | M8-M      |     2.00 | 2024-03-15    | UPDATE    | dbs000       | 2024-12-11
    3 |     6 |       2 | M10-M     |     2.40 | 2024-03-15    | UPDATE    | dbs000       | 2024-12-11
    4 |     1 |       1 | M6-S      |     2.00 | 2024-01-01    | DELETE    | dbs000       | 2024-12-11
    5 |     2 |       1 | M8-S      |     2.50 | 2024-03-15    | UPDATE    | dbs000       | 2024-12-11
    6 |     2 |       1 | M8-S      |     1.50 | 2024-05-01    | UPDATE    | dbs000       | 2024-12-11
    7 |     2 |       1 | M8-S      |     4.50 | 2024-11-30    | UPDATE    | dbs000       | 2024-12-11
(7 Zeilen)

*/


------------------------------------------

SELECT w.warenname, w.invnr, w.regalnr, SUM(CASE WHEN h.operation = 'UPDATE' THEN 1 ELSE 0 END) AS update_count
  

FROM ware w
LEFT JOIN warenhistorie h
    ON w.invnr = h.invnr
GROUP BY w.invnr, w.warenname, w.regalnr;

------------------------------------------

CREATE OR REPLACE VIEW warenkomplett AS
SELECT 
    invnr, 
    regalnr, 
    warenname, 
    preisproeinheit,
    datumverfuegbar
FROM ware
UNION
SELECT 
    invnr, 
    regalnr, 
    warenname, 
    preisalt AS preisproeinheit, 
    verfuegbaralt AS datumverfuegbar
FROM warenhistorie
WHERE preisalt IS NOT NULL;
SELECT * FROM warenkomplett ORDER BY invnr, datumverfuegbar;

-----------------------------------------


CREATE OR REPLACE FUNCTION getprice(invtnr INT, datumv DATE)
RETURNS NUMERIC AS $$
DECLARE
    p NUMERIC;
BEGIN
    SELECT preisproeinheit INTO p
    FROM warenkomplett
    WHERE invnr = getprice.invtnr
      AND datumverfuegbar < getprice.datumv
      ORDER BY datumverfuegbar DESC
    LIMIT 1;

    RETURN p;
END;
$$ LANGUAGE plpgsql;

SELECT getprice( 2, to_date('01.12.2025', 'DD-MM-YYYY'));
