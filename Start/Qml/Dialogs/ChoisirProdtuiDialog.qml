import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"

import core

Dialog {
  id: root
  title: "Choisir le produit"
  anchors.centerIn: parent
  property string selected: "-1"
  
  footer: DialogButtonBox {
    standardButtons: Dialog.Cancel
    Button {
      id: okButtton
      text: "Ok"
      enabled: false
      onClicked: function() {
        root.accept();
      }
    }
  }
    
  contentItem: Frame {
    padding: 5
    ColumnLayout {
      anchors.fill: parent
      spacing: 0
      
      TableAndFilter {
        id: table
        Layout.fillHeight: true
        Layout.fillWidth: true  
        query: "SELECT ean_13, designation || '\n' || libelle as nom "
          + "from presentation_produit join produits "
          + "on presentation_produit.code_produit = produits.code_produit "
          + "WHERE ean_13 like '%" + search + "%' "
          + "OR nom like '%" + search + "%'"
        horizontalHeader: ["EAN13", qsTr("Produit")]
        columnsWidth: [120, 400]
        onActivated: function(idVal) {
          root.selected = table.getIdVal(table.currentIndex.row);
          root.accept();
        }
        
        onCurrentRowChanged: function() {
          if (currentRow === -1) {
            root.selected = "-1"
            okButtton.enabled = false;
          } else {
            root.selected = getIdVal(currentRow)
            okButtton.enabled = true;
          }
        }
      }
      
      ToolBar {
        Layout.fillWidth: true
        RowLayout {
          ToolButton {
            id: ajouterButton
            text: qsTr("Ajouter un présentation")
            onClicked: function() {
              codeProduitDial.open();
            }
          }        
        }
      }
    }
  }

  Dialog {
    id: codeProduitDial
    title: qsTr("Ajouter une présentation")
    onOpened: function() {
      tableC.search = "";
      tableC.clearSelection();
    }
    anchors.centerIn: parent
    contentWidth: 500
    contentHeight: 300

    contentItem: Frame {
      padding: 5
      ColumnLayout {
        anchors.fill: parent
        Label {
          text: qsTr("Entrez le code produit ou la désignation du produit")
        }
        TableAndFilter {
          id: tableC
          Layout.fillWidth: true
          Layout.fillHeight: true
          
          query: "SELECT code_produit, designation FROM produits "
            + "WHERE code_produit like '%" + search + "%' "
            + "OR designation like '%" + search + "%'"
          horizontalHeader: ["Code Produit", "Désignation"]
          columnsWidth: [100, 400]

          onCurrentRowChanged: function() {
            choisir.enabled = currentRow >= 0
          }

          onActivated: function(idVal) {
            codeProduitDial.choisirCodeProduit(idVal);
          }
        }
      }
    }

    function choisirCodeProduit(idVal) {
      dialog.ean13 = "";
      dialog.setCodeProduit(idVal);
      dialog.open();
    }
    
    footer: DialogButtonBox {
      standardButtons: Dialog.Cancel
      Button {
        id: choisir
        text: qsTr("Choisir")
        onClicked: function() {
          var idVal = tableC.getIdVal(tableC.currentRow);
          codeProduitDial.choisirCodeProduit(idVal);
        }
      }
    }
  }

  AjoutStockPresentationProduit {
    id: dialog
    property string ean13: ""
    onSaved: function(ean13) {
      root.selected = ean13;
      dialog.accept();
      codeProduitDial.accept();
      root.accept();
    }
  }
}
