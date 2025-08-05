pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"
import "../DataHandlers"

import "../Utils/functions.mjs" as Functions

Dialog {
  id: root
  title: "Medicament"
  anchors.centerIn: parent
  property int code_CIS
  property bool readOnly: false
  property string addedPresentationCIP13: "-1"
  
  Component.onCompleted: function() {
    Functions.setSqlEngine(sqlEngine);    
  }
  
  function setAddingPresentation(code_CIS) {
    root.readOnly = true;
    root.setCode_CIS(code_CIS);
    presentationRepeater.model.unshift({"modelCIP13": "-1"});
    presentationRepeater.itemAt(0).readOnly = false;
    root.addedPresentationCIP13 = Qt.binding(function() {
      return presentationRepeater.itemAt(0).codeCIP13;
    });
    okButton.visible = true;
  }
  
  function refresh() {
    setCode_CIS(root.code_CIS);
  }
  
  function setCode_CIS(code_CIS) {
    if (!code_CIS)
      return;
    
    root.code_CIS = code_CIS;
    specialite.setCodeCIS(code_CIS)
    composition.setCodeCIS(code_CIS)
    
    var presentations = [];
    if (code_CIS !== -1)
      presentations = sqlEngine.select("presentation", ["code_CIP13"],
                                       "code_CIS", code_CIS, " AND deleted = 0");    
    presentationRepeater.model = [];
    for (var i = 0; i < presentations.length; i++) {
      presentationRepeater.model.push({"modelCIP13": presentations[i][0]});
    }
  }
  
  function setNew() {
    setCode_CIS(-1);
  }

  width: Math.min(
    parent.width - 20,
    leftPadding + frame.leftPadding + layout.width
      + frame.rightPadding + rightPadding
  )
  height: Math.min(
    parent.height - 20,
    topPadding + implicitHeaderHeight + frame.topPadding + layout.height
      + (toolBar.visible ? colLayout.spacing + toolBar.height : 0)
      + frame.bottomPadding + implicitFooterHeight + bottomPadding
  )
  
  contentItem: Frame {
    id: frame
    padding: 5
    
    ColumnLayout {
      anchors.fill: parent
      id: colLayout
      Flickable {
        id: flickable
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: layout.width
        contentHeight: layout.height
        clip: true
        
        Row {
          id: layout
          spacing: 15          

          ColumnLayout {
            id: specialiteLayout
            width: 300
            Label {
              font.pixelSize: 13
              font.bold: true
              text: qsTr("Spécialité")
            }
            Specialite {
              id: specialite
              readOnly: root.readOnly
              Layout.fillWidth: true
            }            
          }
          ColumnLayout {
            id: compositionLayout
            width: 300
            Label {
              font.pixelSize: 13
              font.bold: true
              text: qsTr("Composition")
            }
            Composition {
              id: composition
              readOnly: root.readOnly
              Layout.fillWidth: true
            }
          }
          

          ColumnLayout {
            width: 300
            height: Math.max(specialiteLayout.height, compositionLayout.height)
            Label {
              font.pixelSize: 13
              font.bold: true
              text: qsTr("Présentations")
            }
            Frame {
              Layout.fillWidth: true
              Layout.fillHeight: true
              Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: presentationsLayout.height
                clip: true
                  
                ColumnLayout {
                  id: presentationsLayout
                  width: parent.width
                  Repeater {
                    id: presentationRepeater
                    Layout.fillWidth: true
                    Presentation {
                      id: presentation
                      required property int index
                      readOnly: root.readOnly
                      implicitWidth: presentationsLayout.width
                      
                      onDeleteDone: function() {
                        presentationRepeater.model.splice(index, 1);
                      }
                      onOpenStock: function(idVal) {
                        stockMedicDialog.setId(idVal);
                        stockMedicDialog.open();
                      }
                    }
                  }
                }
              }
            }
            ToolBar {
              Layout.fillWidth: true
              visible: ! root.readOnly

              ToolButton {
                text: qsTr("Ajouter une présentation")
                onClicked: function() {
                  presentationRepeater.model.push({"modelCIP13": "-1"});
                }
              }
            }
          }
        }
          
        ScrollBar.horizontal: ScrollBar {}
        ScrollBar.vertical: ScrollBar {}
      }

      ToolBar {
        id: toolBar
        Layout.fillWidth: true
        visible: !root.readOnly && root.code_CIS !== -1

        RowLayout {
          ToolButton {
            enabled: presentationRepeater.model ? presentationRepeater.model.length === 0 : false
            text: qsTr("Supprimer la Spécialité et la composition")
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.text: qsTr("Vous devez d'abord supprimer tous les présentations.")
            ToolTip.visible: hovered && !enabled
            onClicked: suppressionDialog.open()
          }
        }
      }
    }
  }
  StockMedicamentDialog {
    id: stockMedicDialog
    anchors.centerIn: parent
    onClosed: root.refresh();
  }
  
  footer: DialogButtonBox {
    standardButtons: root.readOnly ? Dialog.Close : Dialog.Cancel
    Button {
      id: okButton
      visible: !root.readOnly
      text: qsTr("Ok")
      onClicked: function() {
        var saved = true;
        saved = saved && specialite.save();
        
        composition.codeCISFieldText = specialite.codeCISFieldText;
        saved = saved && composition.save();
        for (var i = 0; i < presentationRepeater.model.length; i++) {
          presentationRepeater.itemAt(i).codeCISFieldText = specialite.codeCISFieldText;
          saved = saved && presentationRepeater.itemAt(i).save();
        }
        if (saved) {
          root.code_CIS = specialite.codeCIS;
          accept();
        }
      }
    }
  }

  Dialog {
    id: suppressionDialog
    anchors.centerIn: parent
    standardButtons: Dialog.Cancel | Dialog.Ok
    Label {
      text: qsTr("Confirmer la suppression")
    }
    onAccepted: if (Functions.deleteFromDictionnaire(root.code_CIS)) root.accept();
  }
}
