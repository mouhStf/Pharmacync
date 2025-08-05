import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"
import "../Dialogs/Ventes/Factures"

import core

Frame {
  id: root
  
  property int state: 1
  property int subState: 0
  property int selectedRow: -1
  
  padding: 5
  
  ListModel {
    id: listModel
  }

  function updateQuery() {
    nombre_lignes.text = Qt.binding(function(){
      if (factures.checked) {
        query = "SELECT COUNT(*) FROM facture "
        + "WHERE (id like '%" + table.search + "%' "
        + "OR date like '%" + table.search + "%' "
        + "OR valeur like '%" + table.search + "%') "
        + "AND facture.deleted = 0 "
      } else {
        query = "SELECT COUNT(*) from flux join "
        + "presentation on flux.code_CIP13 = presentation.code_CIP13 "
        + "join specialite on specialite.code_CIS = presentation.code_CIS "
        + "join facture on flux.id_facture = facture.id "
        + "WHERE (id_facture like '%" + table.search + "%' "
        + "OR facture.date like '%" + table.search + "%' "
        + "OR quantite like '%" + table.search + "%' "
        + "OR nom like '%" + table.search + "%') "
        + "AND facture.deleted = 0 "
        + "UNION "
        "SELECT COUNT(*) from flux join presentation_produit on flux.code_CIP13 = "
        + "presentation_produit.ean_13 join produits on produits.code_produit "
        + "= presentation_produit.code_produit join facture on flux.id_facture "
        + "= facture.id "
        + "WHERE (id_facture like '%" + table.search + "%' "
        + "OR facture.date like '%" + table.search + "%' "
        + "OR quantite like '%" + table.search + "%' "
        + "OR nom like '%" + table.search + "%') "
        + "AND facture.deleted = 0 "
      }

    });
    table.query = Qt.binding(function() {
      if (factures.checked)
        return table.queryFacture
        + "WHERE (id like '%" + table.search + "%' "
        + "OR date like '%" + table.search + "%' "
        + "OR valeur like '%" + table.search + "%') "
        + "AND facture.deleted = 0 "
        + "ORDER BY date DESC "
      else
        return table.queryProduits0
        + "WHERE (id_facture like '%" + table.search + "%' "
        + "OR facture.date like '%" + table.search + "%' "
        + "OR quantite like '%" + table.search + "%' "
        + "OR nom like '%" + table.search + "%') "
        + "AND facture.deleted = 0 "
        + "UNION "
        + table.queryProduits1
        + "WHERE (id_facture like '%" + table.search + "%' "
        + "OR facture.date like '%" + table.search + "%' "
        + "OR quantite like '%" + table.search + "%' "
        + "OR nom like '%" + table.search + "%') "
        + "AND facture.deleted = 0 "
        + "ORDER BY facture.date DESC"
    });
    table.horizontalHeader = Qt.binding(function() {
      if (factures.checked)
        return table.headerFactures;
      else
        return table.headerProduits;
    });
    table.columnsWidth = Qt.binding(function() {
      if (factures.checked)
        return 160;
      else
        return 210;
    });
    table.columnsWidth = Qt.binding(function() {
      if (factures.checked)
        return table.facturesWidths;
      else
        return table.produitsWidths;
    });
    
    if (root.selectedRow < 0)
      root.selectedRow = 0;
    else if (root.selectedRow >= table.rowCount())
      root.selectedRow = table.rowCount() - 1;
    
    Qt.callLater(() => table.selectRow(root.selectedRow));
  }
  
  states: [
    State {
      name: "Facture"
      when: factures.checked
      PropertyChanges {
        target: tableColumn
        Layout.minimumWidth: 260
        Layout.maximumWidth: 260
        Layout.fillWidth: false
      }
      PropertyChanges {
        target: factureColumn
        visible: true
        Layout.fillWidth: true
        Layout.maximumWidth: -1
      }
      PropertyChanges {
        target: afficherFacture
        visible: false
      }
    },
    State {
      name: "Produits"
      when: produits.checked && !afficherFacture.checked
      PropertyChanges {
        target: tableColumn
        Layout.maximumWidth: -1
        Layout.fillWidth: true
      }
      PropertyChanges {
        target: factureColumn
        visible: false
      }
      PropertyChanges {
        target: afficherFacture
        visible: true
      }
    },
    State {
      name: "ProduitsFacture"
      when: produits.checked && afficherFacture.checked
      PropertyChanges {
        target: tableColumn
        // Layout.minimumWidth: 600
        Layout.maximumWidth: -1
        Layout.fillWidth: true
      }
      PropertyChanges {
        target: factureColumn
        visible: true
        Layout.maximumWidth: 400
        Layout.minimumWidth: 400
      }
      PropertyChanges {
        target: afficherFacture
        visible: true
      }
    }
  ]
  
  RowLayout {
    anchors.fill: parent
    
    Component.onCompleted: function() {
      root.updateQuery();    
    }
    
    ColumnLayout {
      id: tableColumn
      Layout.fillHeight: true
      // Layout.minimumWidth: 260
      Layout.minimumWidth: 260
      Layout.maximumWidth: 260

      Frame {
        Layout.fillWidth: true
        CustomLabelField {
          id: nombre_lignes
          title: "Nombre de factures"
        }
      }
      
      TableAndFilter {
        id: table
        Layout.fillHeight: true
        Layout.fillWidth: true
        
        property string queryFacture: "SELECT id, facture.date, valeur FROM facture "
        property string queryProduits0: "SELECT id_facture, facture.date, quantite, denomination_du_medicament "
          + "|| '\n' || libelle_de_la_presentation as nom from flux join "
          + "presentation on flux.code_CIP13 = presentation.code_CIP13 "
          + "join specialite on specialite.code_CIS = presentation.code_CIS "
          + "join facture on flux.id_facture = facture.id "
        property string queryProduits1: "SELECT id_facture, facture.date, quantite, designation || '\n' || libelle "
          + "as nom from flux join presentation_produit on flux.code_CIP13 = "
          + "presentation_produit.ean_13 join produits on produits.code_produit "
          + "= presentation_produit.code_produit join facture on flux.id_facture "
          + "= facture.id "
        
        property var headerFactures: ["N°", "Date", "Valeur (FCFA)"]
        property var headerProduits: ["Fact", "Date", "Qt", "Denomination - Presentation"]
        property var facturesWidths: [60, 100, 100]
        property var produitsWidths: [60, 100, 50, 500]
        datesColumns: [1]
        
        onCurrentIndexChanged: function() {
          root.selectedRow = currentIndex.row
          var idVal = table.getIdVal(root.selectedRow);
          facture.setId(idVal);
        }
        
        onActivated: function(idVal) {
          facture.setId(idVal);
          if (produits.checked && !afficherFacture.checked)
            afficherFacture.checked = true;
        }
      }
      
      ToolBar {
        Layout.fillWidth: true
        RowLayout {
          anchors.fill: parent
          RadioButton {
            id: factures
            text: "Factures"
            checked: true
            onCheckedChanged: function() {
              Qt.callLater(() => table.selectRow(root.selectedRow));
            }
          }
          RadioButton {
            id: produits
            text: "Produits"
          }
          Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
          }
          CheckBox {
            id: afficherFacture
            text: "Afficher facture"
          }
        }
      }
    }
    
    ColumnLayout {
      id: factureColumn
      Layout.fillHeight: true
      // Layout.minimumWidth: 400
      Layout.fillWidth: true
      Layout.maximumWidth: -1
      Frame {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Frame {
          anchors.centerIn: parent
          width: Math.min(500, parent.width - 50)
          height: parent.height - 50
          Facture {
            id: facture
            anchors.fill: parent
            numero: -1
          }
        }
      }
      ToolBar {
        Layout.fillWidth: true
        RowLayout {
          anchors.right: parent.right
          
          ToolButton {
            icon.source: "qrc:/icons/svgs/solid/print.svg"
            text: "Imprimer"
            onClicked: function() {
              painterEngine.printFacture(facture.numero);
            }
          }
          ToolButton {
            icon.source: "qrc:/icons/svgs/solid/pen.svg"
            text: "Editer"
            onClicked: function() {
              typeOfEdit.open();
            }
          }
          ToolButton {
            icon.source: "qrc:/icons/svgs/solid/xmark.svg"
            text: "Supprimer"
            onClicked: function() {
              confirmSuppression.open();
            }
          }
        }
      }
    }
  }  
  
  Dialog {
    id: confirmSuppression
    title: qsTr("Suppression de la facture nº") + facture.numero
    property bool err: supressSimple.checked
    anchors.centerIn: parent
    contentItem: ColumnLayout{
      Label {
        Layout.preferredWidth: _df3b.width
        wrapMode: Label.Wrap
        font.pixelSize: 14
        text: qsTr("Sagit-il d'un retour client, ou d'une suppression simple ?")
      }
      RowLayout {
        id: _df3b
        RadioButton {
          id: supressSimple
          Layout.preferredWidth: Math.max(supressSimple.width, retourClient.width)
          text: qsTr("Suppression simple")
        }
        RadioButton {
          id: retourClient
          Layout.preferredWidth: Math.max(supressSimple.width, retourClient.width)          
          text: qsTr( "Retour client")
        }
      }
      Label {
        Layout.preferredWidth: _df3b.width
        wrapMode: Label.Wrap
        horizontalAlignment: Label.AlignHCenter
        text: qsTr("Les produits seront retournes dans le stock.")
      }
      
    }
    
    onAccepted: function() {
      root.updateQuery();
    }
    
    footer: DialogButtonBox {
      standardButtons: Dialog.Cancel
      Button {
        enabled: supressSimple.checked || retourClient.checked
        text: qsTr("Confirmer")
        onClicked: function() {
          var prods = {};
          
          var good = true;
          for (var i = 0; i < listModel.count; i++) {
            good = good && sqlEngine.doRetour(listModel.get(i).idFlux, listModel.get(i).quantite, confirmSuppression.err);
          }
          if (good)
            good = sqlEngine.update("facture", ["deleted"], [1], "id", facture.numero); 
          if (good)
            confirmSuppression.accept();
        }
      }
    }
  }
  
  Dialog {
    id: typeOfEdit
    title: "Type d'edition"
    anchors.centerIn: parent
    contentItem: Label {
      text: "S'agit-il d'un retour ou d'une erreur ?"
    }
    footer: DialogButtonBox {
      standardButtons: Dialog.Cancel
      Button {
        text: "Retour"
        onClicked: function() {
          typeOfEdit.accept();
          editDialog.setId(facture.numero);
          editDialog.err = false;
          if (editDialog.idVal !== -1)
            editDialog.open();
        }
      }
      Button {
        text: "Erreur"
        onClicked: function() {
          typeOfEdit.accept();
          editDialog.setId(facture.numero);
          editDialog.err = true;
          if (editDialog.idVal !== -1)
            editDialog.open();
        }
      }
    }
  }
  
  Edit {
    id: editDialog
    anchors.centerIn: parent
    onAccepted: root.updateQuery();
  }
}
