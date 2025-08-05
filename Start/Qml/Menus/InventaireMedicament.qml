import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"

Frame {
  id: root
  padding: 5

  function formated(n) {
    let locale = Qt.locale("fr_FR");
    return Number(n).toLocaleString(locale, 'f', n % 1 === 0 ? 0 : 2);
  }

  function stats() {
    let result = sqlEngine.queryExec("SELECT SUM(restant) FROM stock WHERE restant > 0");
    if (result.length === 1)
    volumeTotal.text = formated(result[0][0] || 0);

    result = sqlEngine.queryExec("SELECT COUNT(DISTINCT code_CIP13) FROM stock WHERE restant > 0");
    if (result.length === 1)
    nombreProduitsUniques.text = formated(result[0][0] || 0);

    result = sqlEngine.queryExec("SELECT SUM(e.prix_d_achat * s.restant) FROM stock s "
    + "JOIN entres_stock e ON s.code_CIP13 = e.code_CIP13 "
    + "WHERE e.deleted = 0 AND s.restant > 0");
    if (result.length === 1)
    valeurTotaleStock.text = formated(result[0][0] || 0) + " CFA";

    // Taux de rotation global
    result = sqlEngine.queryExec("SELECT "
    + "CAST(SUM(e.quantite) AS FLOAT) / NULLIF(SUM(f.quantite), 0) AS taux_rotation_global "
    + "FROM (SELECT SUM(quantite) AS quantite FROM entres_stock ) e, "
    + "(SELECT SUM(restant) AS quantite FROM flux) f");
    if (result.length === 1)
    tauxRotationGlobal.text = formated(result[0][0] || 0.0);

    // Produits en rupture
    result = sqlEngine.queryExec("SELECT COUNT(code_CIP13) FROM stock WHERE restant = 0");
    if (result.length === 1)
    produitsEnRupture. text = formated(result[0][0] || 0);

    // Taux de perte
    result = sqlEngine.queryExec("SELECT (SUM(r.quantite) / (SELECT SUM(restant) + SUM(r2.quantite) FROM stock s LEFT JOIN retours r2 ON r2.id_flux IN (SELECT id FROM flux WHERE flux.code_CIP13 = s.code_CIP13))) * 100 AS result_lines "
    + "FROM retours r "
    + "JOIN flux f ON r.id_flux = f.id "
    + "WHERE r.err = 1 AND r.date >= 'YYYY-MM-DD' AND r.date <= 'YYYY-MM-DD'");
    if (result.length === 1)
    tauxPerte.text = result[0][0] || 0.0;

    // Taux de rupture
    result = sqlEngine.queryExec("SELECT (COUNT(DISTINCT s.code_CIP13) / (SELECT COUNT(DISTINCT code_CIP13) FROM stock) * 100) AS result_lines "
    + "FROM stock s "
    + "WHERE s.restant = 0");
    if (result.length === 1)
    tauxRupture.text = result[0][0] || 0.0;

    // Délai moyen de réapprovisionnement
    result = sqlEngine.queryExec("SELECT AVG(julianday(e.date_acquisition) - julianday(f.date)) AS result_lines "
    + "FROM entres_stock e "
    + "JOIN facture f ON e.id = f.id "
    + "WHERE e.date_acquisition IS NOT NULL AND f.date IS NOT NULL AND e.deleted = 0");
    if (result.length === 1)
    delaiMoyenReapprovisionnement.text = result[0][0] || 0;

    // Taux de conformité
    result = sqlEngine.queryExec("SELECT (COUNT(s.code_CIS) / (SELECT COUNT(*) FROM stock WHERE restant > 0) * 100) AS result_lines "
    + "FROM stock s "
    + "JOIN disponibilite_specialites_pharmaceutique d ON s.code_CIS = d.code_CIS "
    + "JOIN entres_stock e ON s.code_CIP13 = e.code_CIP13 "
    + "WHERE d.libelle_statut = 'Commercialisé' AND e.date_peremption > date('now')");
    if (result.length === 1)
    tauxConformite.text = result[0][0] || 0.0;

    // Chiffre d'affaires généré (prix de vente)
    result = sqlEngine.queryExec("SELECT SUM(f.quantite * e.prix_de_vente) AS result_lines "
    + "FROM flux f "
    + "JOIN entres_stock e ON f.code_CIP13 = e.code_CIP13 "
    + "WHERE f.consumed = 1 AND f.date >= 'YYYY-MM-DD' AND f.date <= 'YYYY-MM-DD'");
    if (result.length === 1)
    chiffreAffaires.text = result[0][0] || 0;
  }

  RowLayout {
    anchors.fill: parent
    Frame {
      Layout.fillHeight: true
      Layout.preferredWidth: 220
      Flickable {
        anchors.fill: parent
        ColumnLayout {
          spacing: 10
          CustomLabelField {
            id: volumeTotal
            title: qsTr("Quantité totale en stock")
            textField.wrapMode: Text.NoWrap
            Layout.preferredWidth: Math.max(textField.contentWidth, label.contentWidth)
          }
          CustomLabelField {
            id: nombreProduitsUniques
            title: qsTr("Nombre de produits uniques")
            textField.wrapMode: Text.NoWrap
            Layout.preferredWidth: Math.max(textField.contentWidth, label.contentWidth)
          }
          CustomLabelField {
            id: valeurTotaleStock
            title: qsTr("Valeur totale du stock")
            textField.wrapMode: Text.NoWrap
            Layout.preferredWidth: Math.max(textField.contentWidth, label.contentWidth)
          }
          CustomLabelField {
            id: tauxRotationGlobal
            title: qsTr("Taux de rotation global")
            textField.wrapMode: Text.NoWrap
            Layout.preferredWidth: Math.max(textField.contentWidth, label.contentWidth)
          }
          CustomLabelField {
            id: produitsEnRupture
            title: qsTr("Produits en rupture")
            textField.wrapMode: Text.NoWrap
            Layout.preferredWidth: Math.max(textField.contentWidth, label.contentWidth)
          }
          CustomLabelField {
            id: tauxPerte
            title: qsTr("Taux de perte")
            textField.wrapMode: Text.NoWrap
            Layout.preferredWidth: Math.max(textField.contentWidth, label.contentWidth)
          }
          CustomLabelField {
            id: tauxRupture
            title: qsTr("Taux de rupture")
            textField.wrapMode: Text.NoWrap
            Layout.preferredWidth: Math.max(textField.contentWidth, label.contentWidth)
          }
          CustomLabelField {
            id: delaiMoyenReapprovisionnement
            title: qsTr("Délai moyen de réapprovisionnement")
            textField.wrapMode: Text.NoWrap
            Layout.preferredWidth: Math.max(textField.contentWidth, label.contentWidth)
          }
          CustomLabelField {
            id: tauxConformite
            title: qsTr("Taux de conformité")
            textField.wrapMode: Text.NoWrap
            Layout.preferredWidth: Math.max(textField.contentWidth, label.contentWidth)
          }
          CustomLabelField {
            id: chiffreAffaires
            title: qsTr("Chiffre d'affaires")
            textField.wrapMode: Text.NoWrap
            Layout.preferredWidth: Math.max(textField.contentWidth, label.contentWidth)
          }
        }
      }
    }
    
    ColumnLayout {
      Layout.fillHeight: true
      Layout.fillWidth: true
      Frame {
        Layout.fillWidth: true
        CustomLabelField {
          id: nombreLigne
          title: qsTr("Nombre de ligne")
        }
      }
      TableAndFilter {
        Layout.fillWidth: true
        Layout.fillHeight: true
        onQueryChanged: function() {
          let result = sqlEngine.queryExec("SELECT COUNT(*) FROM facture_stats");
          if (result.length === 1) 
          nombreLigne.text = result[0][0];
        }
        query: "SELECT STRFTIME('%d-%m-%Y', date), quantite, total_vente FROM facture_stats "
        + "WHERE date LIKE '%" + search + "%' "
        + "ORDER BY date DESC"

        horizontalHeader: ["Date", "Quantite", "Total"]
        columnsWidth: [100, 100]
      }
    }
  }

}
