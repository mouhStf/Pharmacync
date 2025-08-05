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
    TableAndFilter {
      id: table
      Layout.fillHeight: true
      Layout.fillWidth: true

      query: "SELECT stock.code_CIP13, stock.restant, entres_stock.restant, "
      + "prix_d_achat, prix_de_vente, designation || '\n' || libelle AS nom "
      + "FROM stock JOIN entres_stock ON stock.id_current = entres_stock.id "
      + "JOIN presentation_produit on stock.code_CIP13 = presentation_produit.ean_13"
      + " JOIN produits ON presentation_produit.code_produit = produits.code_produit "
      + "WHERE stock.code_CIP13 like '%" + search + "%' "
      + "OR prix_d_achat like '%" + search + "%' "
      + "OR prix_de_vente like '%" + search + "%' "
        + "OR nom like '%" + search + "%' "
      
      horizontalHeader: ["Code", "Quantite", "Courant", "Prix d'achat",
                         "Prix de vente", "Denomination"]
      columnsWidth: [130, 60, 60, 80, 80, 450]
      contextMenuItems: ListModel {
        ListElement {
          title: qsTr("Voir")
          func: function(idVal) {
            dialog.setId(idVal);
            dialog.open();
          }
        }
        ListElement {
          title: qsTr("Voir dans le dictionnaire")
          func: function(idVal) {
            var result = sqlEngine.select("presentation_produit", ["code_produit"], "ean_13", idVal);
            if (result.length === 1) {
              dictionnaireDialog.setCodeProduit(result[0][0]);
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
  
  ChoisirProdtuiDialog {
    id: choisirDialog
    width: 600
    height: 500
    onAccepted: function() {
      ajoutDialog.setId(selected);
      ajoutDialog.open();
    }
  }
  
  AjoutStockProduitDialog {
    id: ajoutDialog
    onAccepted: function() {
      table.refresh();
    }
  }
  
  StockProduitDialog {
    id: dialog
    onClosed: function() {
      sqlEngine.updateStockIndex(dialog.idStock);
      table.refresh();
    }
  }
  
  DictionnaireProduitDialog {
    id: dictionnaireDialog
  }
}
