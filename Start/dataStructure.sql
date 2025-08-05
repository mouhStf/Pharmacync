CREATE TABLE avis_smr_de_la_has (code_CIS INT, code_de_dossier_HAS VARCHAR(20), motif_devaluation VARCHAR(200), date_de_lavis_de_la_commission_de_la_transparence DATE, valeur_de_lASMR VARCHAR(100), libelle_de_lASMR VARCHAR(100), PRIMARY KEY(code_de_dossier_HAS));
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE IF NOT EXISTS "fournisseur" (
	"id"	INTEGER NOT NULL UNIQUE,
	"nom"	TEXT,
	"site"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "avis_asmr_de_la_has" (
	"code_CIS"	INTEGER,
	"code_de_dossier_HAS"	TEXT,
	"motif_devaluation"	TEXT,
	"date_de_lavis_de_la_commission_de_la_transparence"	TEXT,
	"valeur_de_lASMR"	TEXT,
	"libelle_de_lASMR"	TEXT,
	PRIMARY KEY("code_de_dossier_HAS")
);
CREATE TABLE IF NOT EXISTS "liens_avis_ct_has" (
	"code_de_dossier_HAS"	TEXT,
	"lien"	TEXT,
	PRIMARY KEY("code_de_dossier_HAS")
);
CREATE TABLE IF NOT EXISTS "groupe_generique" (
	"identifiant_du_goupe_generique"	VARCHAR(100),
	"libelle_du_groupe_generique"	VARCHAR(150),
	"code_CIS"	INT,
	"type_de_generique"	INT,
	"numero_de_tri"	INT,
	"tempon"	TEXT,
	PRIMARY KEY("code_CIS")
);
CREATE TABLE IF NOT EXISTS "conditions_prescription_delivrance" (
	"code_CIS"	INTEGER,
	"condition_prescription_delivrance"	TEXT,
	PRIMARY KEY("code_CIS")
);
CREATE TABLE IF NOT EXISTS "informations_importantes" (
	"code_CIS"	INTEGER,
	"date_debut_information_securite"	TEXT,
	"date_fin_information_securite"	TEXT,
	"lien"	TEXT,
	PRIMARY KEY("code_CIS")
);
CREATE TABLE IF NOT EXISTS "disponibilite_specialites_pharmaceutique" (
	"code_CIS"	INTEGER,
	"code_CIP13"	TEXT,
	"code_statut"	INTEGER,
	"libelle_statut"	TEXT,
	"date_debut"	TEXT,
	"date_mise_a_jour"	TEXT,
	"date_remise_a_disposition"	TEXT,
	"lien"	TEXT,
	PRIMARY KEY("code_CIS")
);
CREATE TABLE IF NOT EXISTS "indications_therapeutiques" (
	"code_CIS"	INTEGER,
	"indications"	TEXT,
	PRIMARY KEY("code_CIS")
);
CREATE TABLE IF NOT EXISTS "categories" (
	"id"	INTEGER NOT NULL UNIQUE,
	"category"	TEXT NOT NULL UNIQUE,
	"description"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "stock" (
	"code_CIP7"	INTEGER UNIQUE,
	"code_CIP13"	INTEGER UNIQUE,
	"restant"	INTEGER NOT NULL DEFAULT 0,
	"id_current"	INTEGER,
	"restant_current"	INTEGER,
	"category"	INTEGER NOT NULL DEFAULT 1
);
CREATE TABLE IF NOT EXISTS "produits" (
	"category"	INTEGER,
	"code_produit"	INTEGER NOT NULL UNIQUE,
	"designation"	TEXT NOT NULL,
	"titulaire"	TEXT,
	"detail"	TEXT,
	"technical_data_sheet"	TEXT,
	PRIMARY KEY("code_produit")
);
CREATE TABLE IF NOT EXISTS "presentation_produit" (
	"ean_13"	INTEGER NOT NULL UNIQUE,
	"code_produit"	INTEGER,
	"libelle"	TEXT,
	"description"	TEXT,
	"image"	TEXT,
	"image_data"	BLOB,
	PRIMARY KEY("ean_13")
);
CREATE TABLE IF NOT EXISTS "fournisseurs_produits" (
	"id"	INTEGER NOT NULL UNIQUE,
	"nom"	TEXT NOT NULL UNIQUE,
	"site"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "utilisateur" (
	"id"	INTEGER NOT NULL UNIQUE,
	"titre"	TEXT NOT NULL DEFAULT 'Mr',
	"prenom"	TEXT,
	"nom"	TEXT,
	"pseudo"	TEXT UNIQUE,
	"pass"	TEXT,
	"niveau"	INTEGER NOT NULL DEFAULT -1,
	"actif"	INTEGER NOT NULL DEFAULT 1,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "flux" (
	"id"	INTEGER NOT NULL UNIQUE,
	"code_CIP7"	INTEGER NOT NULL DEFAULT -1,
	"code_CIP13"	INTEGER DEFAULT -1,
	"quantite"	INTEGER NOT NULL DEFAULT 0,
	"restant"	INTEGER,
	"id_facture"	INTEGER NOT NULL,
	"id_entres_stock"	INTEGER NOT NULL DEFAULT -1,
	"consumed"	INTEGER DEFAULT 1,
	"date"	NUMERIC,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "retours" (
	"id"	INTEGER NOT NULL UNIQUE,
	"id_flux"	INTEGER NOT NULL,
	"quantite"	INTEGER NOT NULL DEFAULT 0,
	"date"	NUMERIC,
	"err"	INTEGER DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "entres_stock" (
	"id"	INTEGER NOT NULL UNIQUE,
	"code_CIP7"	INTEGER,
	"code_CIP13"	INTEGER,
	"restant"	INTEGER NOT NULL DEFAULT 0,
	"quantite"	INTEGER NOT NULL DEFAULT 1,
	"prix_d_achat"	INTEGER,
	"prix_de_vente"	INTEGER,
	"date_acquisition"	INTEGER,
	"id_fournisseur"	INTEGER,
	"date_peremption"	TEXT,
	"deleted"	INTEGER DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "facture" (
	"id"	INTEGER NOT NULL UNIQUE,
	"date"	TEXT,
	"valeur"	INTEGER,
	"paye"	INTEGER,
	"donne"	INTEGER,
	"rendu"	INTEGER,
	"id_user"	INTEGER NOT NULL DEFAULT -1,
	"devis"	INTEGER NOT NULL DEFAULT 0,
	"emetteurDevis"	INTEGER,
	"dateEmissionDevis"	TEXT,
	"deleted"	INTEGER DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "specialite" (
	"code_CIS"	INT,
	"denomination_du_medicament"	VARCHAR(200),
	"forme_pharmaceutique"	VARCHAR(100),
	"voies_dadministration"	VARCHAR(100),
	"statut_administratif_de_lAMM"	VARCHAR(100),
	"type_procedure_dAMM"	INT,
	"etat_de_commercialisation"	VARCHAR(100),
	"date_dAMM"	DATE,
	"statutBdm"	VARCHAR(20),
	"numero_de_lautorisation_europeenne"	INT,
	"titulaires"	VARCHAR(200),
	"surveillance_renforcee"	BOOL,
	"source"	TEXT,
	"deleted"	INTEGER DEFAULT 0,
	PRIMARY KEY("code_CIS")
);
CREATE TABLE IF NOT EXISTS "presentation" (
	"code_CIS"	INT,
	"code_CIP7"	INT,
	"libelle_de_la_presentation"	VARCHAR(200),
	"statut_administratif_de_la_presentation"	VARCHAR(100),
	"etat_de_commercialisation"	INT,
	"date_de_la_declaration_de_commercialisation"	DATE,
	"code_CIP13"	VARCHAR(13),
	"agrement_aux_collectivite"	VARCHAR(100),
	"taux_de_remboursement"	FLOAT,
	"prix_du_medicament_en_euro"	FLOAT,
	"prix_du_medicament_en_euro_1"	FLOAT,
	"prix_du_medicament_en_euro_2"	FLOAT,
	"indications_ouvrant_droit_au_remboursement"	VARCHAR(100),
	"image"	TEXT,
	"image_data"	BLOB,
	"deleted"	INTEGER DEFAULT 0,
	PRIMARY KEY("code_CIP13")
);
CREATE TABLE IF NOT EXISTS "composition" (
	"code_CIS"	INT,
	"designation_de_lelement_pharmaceutique"	VARCHAR(200),
	"code_de_la_substance"	INT,
	"denomination_de_la_substance"	VARCHAR(150),
	"dosage_de_la_substance"	VARCHAR(100),
	"referene_de_ce_dosage"	VARCHAR(100),
	"nature_du_composant"	VARCHAR(100),
	"numero_de_liaison_SA_FT"	INT,
	"tempon"	TEXT,
	"deleted"	INTEGER DEFAULT 0,
	PRIMARY KEY("code_CIS")
);
