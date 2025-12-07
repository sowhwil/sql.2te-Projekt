DROP TABLE IF EXISTS warenhistorie CASCADE;
DROP TABLE IF EXISTS ware CASCADE;
DROP TABLE IF EXISTS regal CASCADE;


CREATE TABLE regal (
    regalnr        INTEGER PRIMARY KEY,
    lage           VARCHAR(5),
    platzgesamt    INTEGER NOT NULL,
    platzbelegt    INTEGER NOT NULL DEFAULT 0
);


CREATE TABLE ware (
    invnr             INTEGER PRIMARY KEY,
    regalnr           INTEGER REFERENCES regal(regalnr),
    warenname         VARCHAR(30),
    typ               VARCHAR(30),
    anzahl            INTEGER NOT NULL CHECK (anzahl >= 0),
    platzproeinheit   INTEGER NOT NULL CHECK (platzproeinheit >= 0),
    preisproeinheit   NUMERIC(8,2) NOT NULL CHECK (preisproeinheit >= 0),
    datumverfuegbar   DATE NOT NULL
);


CREATE TABLE warenhistorie (
    whnr          SERIAL PRIMARY KEY,
    invnr         INTEGER,
    regalnr       INTEGER,
    warenname     VARCHAR(30),
    preisalt      NUMERIC(10,2),
    verfuegbaralt DATE,
    operation     TEXT NOT NULL,
    benutzername  TEXT NOT NULL,
    geaendertam   TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP --DATE NOT NULL DEFAULT CURRENT_DATE
);

-- trigger function
CREATE OR REPLACE FUNCTION trig_ware()
RETURNS TRIGGER AS $$

DECLARE
    old_space     INTEGER;
    new_space     INTEGER;
    future_belegt INTEGER;
    chosen_regal  INTEGER;
    anz_an INTEGER;
BEGIN
    ----------------------------------------------------------------
    -- INSERT: Regeln 1, 2, 3
    ----------------------------------------------------------------
    IF TG_OP = 'INSERT' THEN

        new_space := NEW.anzahl * NEW.platzproeinheit;

        -- rule 2: auto shelf if none given (capacity + <4 prod)
        IF NEW.regalnr IS NULL THEN
            SELECT r.regalnr
            INTO chosen_regal
            FROM regal r
            WHERE (r.platzgesamt - r.platzbelegt) >= new_space
              AND (
                    SELECT COUNT(DISTINCT w.warenname)
                    FROM ware w
                    WHERE w.regalnr = r.regalnr
                  ) < 4
            ORDER BY r.regalnr
            LIMIT 1;

            IF chosen_regal IS NULL THEN
                RAISE EXCEPTION
                    'INSERT: Kein Regal mit weniger als 4 Waren verfügt über genug freien Platz!';
            END IF;

            NEW.regalnr := chosen_regal;

            RAISE NOTICE
                'Freier Platz in Regal % gefunden!', NEW.regalnr;
        END IF;

        -- rule 3: max 4 different prod per shelf
        IF NOT EXISTS (
            SELECT 1
            FROM ware w
            WHERE w.regalnr = NEW.regalnr
              AND w.warenname = NEW.warenname
        ) THEN
            -- new prod type in this shelf, check count
            IF (
                SELECT COUNT(DISTINCT w2.warenname)
                FROM ware w2
                WHERE w2.regalnr = NEW.regalnr
            ) >= 4 THEN
                RAISE EXCEPTION
                    'Regel 3 - INSERT: Es dürfen nicht mehr als 4 unterschiedliche Waren in einem Regal gelagert werden!';
            END IF;
        END IF;

        -- rule 1: capacity check
        IF new_space > (
            SELECT platzgesamt - platzbelegt
            FROM regal
            WHERE regalnr = NEW.regalnr
        ) THEN
            RAISE EXCEPTION
                'REGEL 1 - INSERT: Neue Ware darf nur dann hinzugefügt werden, wenn dadurch die Kapzität des Regals nicht überschritten wird!';
        END IF;

        -- update shelf usage
        UPDATE regal
        SET platzbelegt = platzbelegt + new_space
        WHERE regalnr = NEW.regalnr;

        RETURN NEW;
    END IF;

    ----------------------------------------------------------------
    -- UPDATE: Regeln 4, 5
    ----------------------------------------------------------------
    IF TG_OP = 'UPDATE' THEN

        -- rule 5: date cannot go backwards
        IF NEW.datumverfuegbar < OLD.datumverfuegbar THEN
            NEW.datumverfuegbar := OLD.datumverfuegbar;

            RAISE NOTICE E'Regel 5 - UPDATE: Das Verfügbarkeitsdatum wurde nicht verändert,\nweil es  nicht rückwirkend nach hinten verschoben werden darf!';

            -- only date changed? then stop, no history
            IF NEW.warenname       = OLD.warenname
               AND NEW.typ         = OLD.typ
               AND NEW.anzahl      = OLD.anzahl
               AND NEW.platzproeinheit = OLD.platzproeinheit
               AND NEW.preisproeinheit = OLD.preisproeinheit
               AND NEW.regalnr     = OLD.regalnr THEN
                RETURN NEW;
            END IF;
        END IF;

        -- rule 4: no moving to another shelf
        IF NEW.regalnr <> OLD.regalnr THEN
            RAISE EXCEPTION
                'REGEL 4 - UPDATE: Existierende Ware darf nicht in ein anderes Regal umsortiert werden';
        END IF;

        -- amount >= 0 already checked by table constraint

        -- calc old and new space
        old_space := OLD.anzahl * OLD.platzproeinheit;
        new_space := NEW.anzahl * NEW.platzproeinheit;

        -- rule 4: capacity check when increasing usage
        IF new_space > old_space THEN
            SELECT platzbelegt - old_space + new_space
            INTO future_belegt
            FROM regal
            WHERE regalnr = OLD.regalnr;

            IF future_belegt > (
                SELECT platzgesamt
                FROM regal
                WHERE regalnr = OLD.regalnr
            ) THEN
                RAISE EXCEPTION
                    'REGEL 4 - UPDATE: Die Anzahl/Platzproeinheit  bestehender Ware darf nicht über die Regalkapazität erhöht werden!';
            END IF;
        END IF;

        -- update shelf usage
        UPDATE regal
        SET platzbelegt = platzbelegt - old_space + new_space
        WHERE regalnr = NEW.regalnr;

        -- log update in history
        INSERT INTO warenhistorie (
            invnr, regalnr, warenname,
            preisalt, verfuegbaralt,
            operation, benutzername
        )
        VALUES (
            OLD.invnr, OLD.regalnr, OLD.warenname,
            OLD.preisproeinheit, OLD.datumverfuegbar,
            'UPDATE', CURRENT_USER
        );
        --anz_an COUNT

        RETURN NEW;
    END IF;

    ----------------------------------------------------------------
    -- DELETE: Regel 6 (Kapazität + History + Notice)
    ----------------------------------------------------------------
    IF TG_OP = 'DELETE' THEN

        old_space := OLD.anzahl * OLD.platzproeinheit;

        -- free shelf space
        UPDATE regal
        SET platzbelegt = platzbelegt - old_space
        WHERE regalnr = OLD.regalnr;

        -- notice for delete
        RAISE NOTICE
            'Regel 5 - DELETE: Ware entfernt. Regalkapazität wird aktualisiert!';

        -- log delete in history
        INSERT INTO warenhistorie (
            invnr, regalnr, warenname,
            preisalt, verfuegbaralt,
            operation, benutzername
        )
        VALUES (
            OLD.invnr, OLD.regalnr, OLD.warenname,
            OLD.preisproeinheit, OLD.datumverfuegbar,
            'DELETE', CURRENT_USER
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- trigger on ware table
CREATE TRIGGER ware_change_trig
BEFORE INSERT OR UPDATE OR DELETE ON ware
FOR EACH ROW
EXECUTE FUNCTION trig_ware();

--+++++++--------------------------------------------+++++++--
--+++++++--------------------------------------------+++++++--

--1)

