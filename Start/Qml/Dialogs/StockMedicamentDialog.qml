import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"
import "../DataHandlers"

import core

Dialog {
  id: root
  title: qsTr("Médicament")
  anchors.centerIn: parent
  property string idStock
  standardButtons: Dialog.Close
    
  function setId(id) {
    sqlEngine.updateStockIndex(id);
    preview.setId(id);    
    if (preview.idStock !== "-1") {
      root.idStock = id;
      preview.packetEnCours = sqlEngine.select("stock", ["id_current"], "code_CIP13", id)[0][0];      
      table.horizontalHeader = ["Id", "Reste", "Qt", "Achat", "Vente", "Acquis le", "Exp"];
      table.columnsWidth = [60, 60, 60, 80, 80, 100, 100];

      var result = sqlEngine.select("entres_stock", ["COUNT(*)"], "code_CIP13", root.idStock, "AND deleted = 0 AND restant > 0");
      if (result.length === 1) {
        preview.nombrePacket = result[0][0];
      }

      var result = sqlEngine.select(
        "entres_stock", ["quantite", "prix_d_achat","prix_de_vente"], "code_CIP13", 
        root.idStock, "AND deleted = 0 AND restant > 0"
      );
      qt = 0
      prixDeVenteMoyenne = 0
      for (var i = 0; i < result.length; i++) {
        qt += 1;
        prixDeVenteMoyenne += result[i][2];
      }
      console.log("Moyenne vente: ", prixDeVenteMoyenne / qt)

    } else {
      root.idStock = "-1"      
    }
  }

  width: Math.min(parent.width - 20, leftPadding + frame.leftPadding + 300 + layout.spacing + 540 + frame.rightPadding + rightPadding)
  height: root.parent ? Math.min(500, root.parent.height - 20) : 0  
  
  contentItem: Frame {
    id: frame
    padding: 5

    Flickable {
      id: flick
      anchors.fill: parent
      contentWidth:  layout.width
      contentHeight: height
      clip: true
      
      RowLayout {
        id: layout
        spacing: 15
        clip: true
        width: Math.max(flick.width, 300 + layout.spacing + 250)
        height: parent.height
        
        MedicamentPreview {
          id: preview
          Layout.preferredWidth: 300
          Layout.fillHeight: true

          Component.onCompleted: function() {
          }
        }
        
        ColumnLayout {
          spacing: 0
          Layout.fillHeight: true
          Layout.fillWidth: true
          
          TableAndFilter {
            id: table
            Layout.fillHeight: true
            Layout.fillWidth: true
            query: "SELECT id, restant, quantite, prix_d_achat,"
              + " prix_de_vente, date_acquisition, date_peremption from"
              + " entres_stock where deleted = 0 AND code_CIP13 = "
              + root.idStock + " AND restant > 0 AND ("
              + "id like '%" + search + "%' "
              + "OR date_acquisition like '%" + search + "%' "
              + "OR date_peremption like '%" + search + "%')"
            datesColumns: [5, 6]
            columnsWidth: [60, 60, 60, 80, 80, 100, 100]
            horizontalHeader: ["Id", "Reste", "Qt", "Achat", "Vente", "Acquis le", "Exp"]
            
            onActivated: function(idVal) {
              dialog.setId(idVal);
              dialog.readOnly = true;
              dialog.open();
            }
            
            contextMenuItems: ListModel {
              ListElement {
                title: qsTr("Voir")
                func: function(idVal) {
                  dialog.setId(idVal);
                  dialog.readOnly = true;
                  dialog.open();
                }
              }
              
              ListElement {
                title: qsTr("Editer")
                func: function(idVal) {
                  dialog.setId(idVal);
                  dialog.readOnly = false;
                  dialog.open();
                }
              }
            }
            
            onCurrentRowChanged: function() {
              var s = currentRow >= 0;
              editerButton.enabled = s;
              voirButton.enabled = s;
              supprimerToolButton.enabled = s && table.getVal(currentRow,1) === table.getVal(currentRow,2);
              supprimerToolButton.itemOn = s;
            }
          }
          
          ToolBar {
            Layout.fillWidth: true
            RowLayout {                            
              ToolButton {
                id: voirButton
                enabled: false
                text: qsTr("Voir")
                onClicked: function() {
                  var idVal = table.getIdVal(table.currentRow);
                  dialog.setId(idVal);
                  dialog.readOnly = true;
                  dialog.open()
                }
              }
              ToolButton {
                id: editerButton
                enabled: false
                text: qsTr("Editer")
                onClicked: function() {
                  var idVal = table.getIdVal(table.currentRow);
                  dialog.setId(idVal);
                  dialog.readOnly = false;
                  dialog.open()
                }
              }
              ToolButton {
                text: qsTr("Ajouter")
                onClicked: function() {
                  ajoutDialog.setId(root.idStock);
                  ajoutDialog.open();
                }
              }
              ToolButton {
                id: supprimerToolButton
                property bool itemOn: false
                enabled: false
                hoverEnabled: true
                
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered && !enabled && itemOn
                ToolTip.text: qsTr("La suppression n'est pas possible lorsqu'il y a des factures enregistrées.")
                
                text: qsTr("Supprimer")
                onClicked: function() {
                  var id_entre_stock = table.getIdVal(table.currentRow);
                  if (table.getVal(table.currentRow,1) === table.getVal(table.currentRow,2)) {
                    suppressionDialog.id_entre_stock = id_entre_stock;
                    suppressionDialog.open();                  
                  }
                }
              }
            }
          }
        }      
      }
      ScrollBar.horizontal: ScrollBar {}
    }
  }
  
  EntreStockDialog {
    id: dialog
    onClosed: function() {
      table.refresh();
    }
  }
  
  AjoutStockMedicamentDialog {
    id: ajoutDialog
    medicamentInfo: false
    onAccepted: function() {
      table.refresh();
    }
  }

  Dialog {
    id: suppressionDialog
    property int id_entre_stock: -1
    anchors.centerIn: parent
    title: qsTr("Suppression")
    
    Label {
      text: qsTr("Vueillez confirmer la suppression.")
    }
    onAccepted: function() {
      table.refresh();
    }
    
    footer: DialogButtonBox {
      standardButtons: Dialog.Cancel
      Button {
        text: qsTr("Confirmer")
        onClicked: function() {
          var result = sqlEngine.select("flux", ["id"], "id_entres_stock", suppressionDialog.id_entre_stock);
          if (result.length === 0 ) {
            sqlEngine.deleteRow("entres_stock", "id", suppressionDialog.id_entre_stock);
          } else {
            sqlEngine.update("entres_stock", ["deleted"], [1], "id", suppressionDialog.id_entre_stock);
          }
          suppressionDialog.accept();
        }
      }
    }
  }
}
