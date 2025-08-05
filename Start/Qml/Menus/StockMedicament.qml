import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"
import "../Dialogs"

import core

Frame {
  id: root
  padding: 5
  
  ColumnLayout {
    anchors.fill: parent
    Frame {
      Layout.fillWidth: true

      CustomLabelField {
        id: packetField
        Layout.fillWidth: true
        title: qsTr("Nombre de produits")
        visible: text !== ""
        width: 100
        Component.onCompleted: function() {
          var result = sqlEngine.select("stock JOIN entres_stock ON stock.id_current = entres_stock.id JOIN presentation ON stock.code_CIP13 = presentation.code_CIP13 JOIN specialite ON specialite.code_CIS = presentation.code_CIS",
          [ "COUNT(*)" ]);

          if (result.length === 1) {
            text = result[0][0]
          }
        }
      }
    }
    TableAndFilter {
      id: table
      
      Layout.fillWidth: true
      Layout.fillHeight: true

      query: "SELECT presentation.code_CIP13, stock.restant, "
        + "entres_stock.restant, prix_d_achat, prix_de_vente, "
        + "denomination_du_medicament || '\n' || libelle_de_la_presentation "
        + "AS nom FROM stock JOIN entres_stock ON stock.id_current = entres_stock.id "
        + "JOIN presentation on stock.code_CIP13 = presentation.code_CIP13 "
        + "JOIN specialite ON specialite.code_CIS = presentation.code_CIS "
        + "WHERE stock.code_CIP13 like '%" + search + "%' "
        + "OR prix_d_achat like '%" + search + "%' "
        + "OR prix_de_vente like '%" + search + "%' "
        + "OR nom like '%" + search + "%' ";
      
      horizontalHeader: ["Code", "Quantite", "Courant", "Prix d'achat",
                         "Prix de vente", "Denomination"]
      columnsWidth: [130, 60, 60, 80, 80, 450]
      contextMenuItems: ListModel {
        ListElement {
          title: "Voir"
          func: function(idVal) {
            dialog.setId(idVal);
            dialog.open();
          }
        }
        ListElement {
          title: "Voir dans le dictionnaire"
          func: function(idVal) {
            var result = sqlEngine.select("presentation", ["code_CIS"], "code_CIP13", idVal);
            if (result.length === 1) {
              dictionnaireDialog.setCode_CIS(result[0][0]);
              dictionnaireDialog.readOnly = true;
              dictionnaireDialog.open();
            }
          }
        }
      }
      onActivated: function(idVal) {
        dialog.setId(idVal);
        dialog.open();
      }

      onCurrentRowChanged: function() {
        editerButton.enabled = currentRow >= 0
      }      
    }

    ToolBar {
      Layout.fillWidth: true
      RowLayout {
        ToolButton {
          text: qsTr("Ajouter")
          onClicked: function() {
            choisirDialog.open();
          }
        }
        ToolButton {
          id: editerButton
          enabled: false
          text: qsTr("Voir")
          onClicked: function() {
            var idVal = table.getIdVal(table.currentIndex.row);
            dialog.setId(idVal);
            dialog.open()
          }
        }
      }      
    }
  }
  
  ChoisirMedicamentDialog {
    id: choisirDialog
    width: 600
    height: 500
    onAccepted: function() {
      ajoutDialog.setId(selected);
      ajoutDialog.open();
    }
  }
  
  AjoutStockMedicamentDialog {
    id: ajoutDialog
    onAccepted: function() {
      table.refresh();
    }
  }
  
  StockMedicamentDialog {
    id: dialog
    onClosed: function() {
      sqlEngine.updateStockIndex(dialog.idStock);
      table.refresh();
    }
  }
  
  DictionnaireMedicamentDialog {
    id: dictionnaireDialog
  }
}
