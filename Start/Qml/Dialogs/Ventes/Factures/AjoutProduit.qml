import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../Widgets"

import core

Dialog {
  title: "Ajouter un produit"
  anchors.centerIn: parent
  width: 750
  height: 400
  
  signal choisi(cip13: var)
  
  ColumnLayout {
    anchors.fill: parent
    Table {
      id: table
      Layout.fillHeight: true
      Layout.fillWidth: true
      tableView.model: TableModel {
        id: tableModel
        query: "SELECT stock.code_CIP13, stock.restant, prix_de_vente, "
          + "denomination_du_medicament || '\n' || libelle_de_la_presentation AS nom "
          + "FROM stock JOIN entres_stock ON stock.id_current = entres_stock.id "
          + "JOIN presentation on stock.code_CIP13 = presentation.code_CIP13 "
          + "JOIN specialite ON presentation.code_CIS = specialite.code_CIS "
          + "WHERE stock.restant > 0 AND ("
          + "stock.code_CIP13 like '%" + searchField.text + "%' "
          + "OR stock.restant like '%" + searchField.text + "%' "
          + "OR prix_de_vente like '%" + searchField.text + "%' "
          + "OR nom like '%" + searchField.text + "%' "
          + ") "
          + "UNION "
          + "SELECT stock.code_CIP13, stock.restant, prix_de_vente, "
          + "designation || '\n' || libelle AS nom "
          + "FROM stock JOIN entres_stock ON stock.id_current = entres_stock.id "
          + "JOIN presentation_produit on stock.code_CIP13 = presentation_produit.ean_13 "
          + "JOIN produits ON presentation_produit.code_produit = produits.code_produit "
          + "WHERE stock.restant > 0 AND ("
          + "stock.code_CIP13 like '%" + searchField.text + "%' "
          + "OR stock.restant like '%" + searchField.text + "%' "
          + "OR prix_de_vente like '%" + searchField.text + "%' "
          + "OR nom like '%" + searchField.text + "%' "
          + ")";
        horizontalHeader: ["Code", "Reste", "Prix (FCFA)", "Dénomination"]
        columnsWidth: [100, 50, 70, 500]
      }
      onCurrentIndexChanged: function() {
        choisirButton.enabled = true;
      }
      onActivated: function(idVal) {
        choisi(idVal);
        accept();
      }
    }
    
    ToolBar {
      Layout.fillWidth: true
      TextField {
        anchors.fill: parent
        id: searchField
        placeholderText: "Filtrer"
      }
    }
  }
  
  footer: DialogButtonBox {
    standardButtons: Dialog.Cancel
    Button {
      id: choisirButton
      enabled: false
      text: "Choisir"
      onClicked: function() {
        var idVal = tableModel.getIdVal(table.tableView.currentRow);
        choisi(idVal);
        accept();
      }
    }
  }
}
