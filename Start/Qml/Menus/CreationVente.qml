import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"

import core

Frame {
  id: root
  padding: 5

  signal updatedQuery()

  ColumnLayout {
    anchors.fill: parent

    TableAndFilter {
      Layout.fillWidth: true
      Layout.preferredHeight: (parent.height - parent.spacing)  / 2
      query: "SELECT stock.code_CIP13, stock.restant, prix_de_vente, "
      + "denomination_du_medicament || '\n' || libelle_de_la_presentation AS nom "
      + "FROM stock JOIN entres_stock ON stock.id_current = entres_stock.id "
      + "JOIN presentation on stock.code_CIP13 = presentation.code_CIP13 "
      + "JOIN specialite ON presentation.code_CIS = specialite.code_CIS "
      + "WHERE stock.restant > 0 AND ("
      + "stock.code_CIP13 like '%" + search + "%' "
      + "OR stock.restant like '%" + search + "%' "
      + "OR prix_de_vente like '%" + search + "%' "
      + "OR nom like '%" + search + "%' "
      + ") "
      + "UNION "
      + "SELECT stock.code_CIP13, stock.restant, prix_de_vente, "
      + "designation || '\n' || libelle AS nom "
      + "FROM stock JOIN entres_stock ON stock.id_current = entres_stock.id "
      + "JOIN presentation_produit on stock.code_CIP13 = presentation_produit.ean_13 "
      + "JOIN produits ON presentation_produit.code_produit = produits.code_produit "
      + "WHERE stock.restant > 0 AND ("
      + "stock.code_CIP13 like '%" + search + "%' "
      + "OR stock.restant like '%" + search + "%' "
      + "OR prix_de_vente like '%" + search + "%' "
      + "OR nom like '%" + search + "%' "
      + ")"
      horizontalHeader: ["Code", "Reste", "Prix (FCFA)", "Dénomination"]
      columnsWidth: [100, 50, 70]
      onActivated: function (idVal) {
        creationVente.ajouter(idVal);
      }
    }

    VenteBoard {
      id: creationVente
      Layout.fillWidth: true
      Layout.fillHeight: true
    
      onVendre: function(products) {
        facture.products = products;
        dialog.open();
      }
    }
  }  
  
  Dialog {
    id: dialog
    title: "Vente"
    width: 500
    anchors.centerIn: parent
    onAccepted: creationVente.effacerTout();
    
    function vendre() {
      var prods = {};
      for (var i = 0; i < facture.products.count; i++) {
        prods[facture.products.get(i).cip13] = facture.products.get(i).quantite;
      }
      
      if (sqlEngine.vendre(prods, facture.total, donne.value, reste.value)) {
        dialog.accept();
        updateQuery();
      }
    }
    
    Pane {
      id: pane
      Keys.onReturnPressed: dialog.vendre();
      Keys.onEnterPressed: dialog.vendre();
      anchors.fill: parent
      ColumnLayout {
        anchors.fill: parent
        
        RowLayout {
          Layout.fillWidth: true
          Item {
            Layout.fillWidth: true
            // Layout.fillHeight: true
            Label {
              anchors.centerIn: parent
              font.bold: true
              font.pixelSize: 20
              text: "Montant: " + facture.total
            }
          }
          Column {
            id: col
            spacing: 5
            
            NumberField {
              id: donne
              to: (1 + parseInt(facture.total / 10000)) * 10000
              from: 0
              step: 5
              title: "Donne"
            }
            
            NumberField {
              id: reste
              title: "Rendu"
              property int restant: donne.value - facture.total
              step: 5
              from: 0
              to: restant > 0 ? restant : 0
              onToChanged: value = to;
              value: to
            }
          }
        }
        
        ToolBar {
          Layout.fillWidth: true
          Row {
            CheckBox {
              id: devis
              checked: true
            }
            ToolButton {
              text: (devis.checked ? "Cacher" : "Montrer") + " le devis"
              onClicked: devis.checked = !devis.checked
            }
          }
        }
        
        Facture {
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.preferredHeight: 300
          id: facture
          numero: -1
          visible: devis.checked
        }
      }
    }
    
    footer: DialogButtonBox {
      standardButtons: Dialog.Cancel
      Button {
        enabled: donne.value >= facture.total
        text: "Vendre"
        onClicked: dialog.vendre()
        icon.source: "qrc:/icons/svgs/solid/check.svg"
      }
    }
  }
}
