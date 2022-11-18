/*ESERCIZIO 1*/
/*1*/
DROP SCHEMA IF EXISTS previsioni CASCADE;
CREATE SCHEMA PREVISIONI;
SET search_path TO PREVISIONI;
/*2*/

CREATE TABLE previsione (
	citta VARCHAR NOT NULL,
	giorno DATE,
	fascia_oraria VARCHAR,
	temperaturaMin FLOAT ,
	temperaturaMax FLOAT ,
	tempo VARCHAR,
	PRIMARY KEY (citta, giorno, fascia_oraria));

CREATE TABLE luogo (
	citta VARCHAR ,
	regione VARCHAR,
	stato VARCHAR ,
	PRIMARY KEY (citta));

CREATE TABLE perturbazione (
	nome VARCHAR NOT NULL ,
	citta VARCHAR,
	giorno DATE ,
	PRIMARY KEY (nome,citta));


SET datestyle='DMY';


/*3*/
INSERT INTO previsione (citta,giorno,fascia_oraria,temperaturaMin,temperaturaMax,tempo) 
		VALUES ('PERUGIA', '17-06-2000','mattina','0','11','Sereno');
INSERT INTO previsione (citta,giorno,fascia_oraria,temperaturaMin,temperaturaMax,tempo) 
		VALUES ('TERNI', '17-06-2000','notturna','0','11','Sereno');
INSERT INTO previsione (citta,giorno,fascia_oraria,temperaturaMin,temperaturaMax,tempo) 
		VALUES ('ROMA', '17-06-2000','sera','18','35','Pioggia');
INSERT INTO previsione (citta,giorno,fascia_oraria,temperaturaMin,temperaturaMax,tempo) 
		VALUES ('GENOVA', '17-06-2000','notturna','0','25','Sereno');
INSERT INTO previsione (citta,giorno,fascia_oraria,temperaturaMin,temperaturaMax,tempo) 
		VALUES ('PALERMO', '17-03-2000','pomeriggio','15','20','Nuvoloso');
INSERT INTO previsione (citta,giorno,fascia_oraria,temperaturaMin,temperaturaMax,tempo) 
		VALUES ('BARCELLONA', '17-06-2000','notturna','15','20','Sereno');

INSERT INTO luogo (citta,regione,stato) 
		VALUES ('PERUGIA', 'UMBRIA','ITA');
INSERT INTO luogo (citta,regione,stato) 
		VALUES ('TERNI', 'UMBRIA','ITA');
INSERT INTO luogo (citta,regione,stato) 
		VALUES ('ROMA', 'LAZIO','ITA');
INSERT INTO luogo (citta,regione,stato) 
		VALUES ('GENOVA', 'LIGURIA','ITA');
INSERT INTO luogo (citta,regione,stato) 
		VALUES ('PALERMO', 'SICILIA','ITA');
INSERT INTO luogo (citta,regione,stato) 
		VALUES ('BARCELLONA', 'CATALOGNA','SPA');


INSERT INTO perturbazione (nome,citta,giorno) 
		VALUES ('Ciclone tropicale', 'PERUGIA','20-05-2000');
INSERT INTO perturbazione (nome,citta,giorno) 
		VALUES ('Saccatura', 'ROMA','28-08-2000');
INSERT INTO perturbazione (nome,citta,giorno) 
		VALUES ('Ciclone mediterraneo', 'PALERMO','27-01-2000');

/*ESERCIZIO 2*/
/*1*/
SELECT DISTINCT citta FROM previsione NATURAL LEFT JOIN luogo
WHERE previsione.tempo='Sereno' AND previsione.fascia_oraria='mattina' AND previsione.giorno='17-06-2000' AND luogo.stato='ITA';
/*2*/
SELECT DISTINCT citta,COUNT(fascia_oraria) AS numero_notti FROM previsione NATURAL LEFT JOIN luogo
WHERE previsione.giorno >= '17-06-2000' AND previsione.giorno <= '24-06-2000' AND previsione.fascia_oraria='notturna' AND luogo.stato='ITA'
GROUP BY citta;
/*3*/
CREATE VIEW escursione(citta,differenza)
AS SELECT citta,MAX(temperaturaMax-temperaturaMin)
FROM previsione
GROUP BY citta,temperaturaMax-temperaturaMin;

SELECT * FROM escursione;

SELECT escursione.citta
FROM escursione,previsione NATURAL LEFT JOIN luogo
WHERE differenza=(SELECT MAX(differenza) FROM escursione) AND previsione.giorno='17-06-2000' AND previsione.fascia_oraria='notturna' AND luogo.stato='ITA' 
GROUP BY  escursione.citta;
/*4*/
SELECT DISTINCT regione
FROM luogo NATURAL LEFT JOIN previsione
WHERE previsione.giorno='17-06-2000' AND (previsione.temperaturaMax-previsione.temperaturaMin)>10 AND luogo.stato='ITA'
GROUP BY regione,citta
;

/*ESERCIZIO 4*/
ALTER TABLE luogo
ADD numeroPerturbazioni INTEGER;

CREATE FUNCTION aggiornamento()
RETURNS TRIGGER AS 
$BODY$
	DECLARE
		c INTEGER;
	BEGIN
		SELECT numeroPerturbazioni INTO c FROM luogo;
		RETURN NEW;
	END;
$BODY$
LANGUAGE PLPGSQL;
;

CREATE TRIGGER aggiornamento AFTER
INSERT OR UPDATE
ON luogo FOR EACH ROW
EXECUTE PROCEDURE aggiornamento();