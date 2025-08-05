import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import "../Widgets"
import "../DataHandlers"

import core

Dialog {
  id: root
  title: qsTr("Ajouter au stock produit")
  anchors.centerIn: parent
  property string idStock
  property bool produitInfo: true
  
  function setId(id) {
    preview.setId(id);
    if (preview.idStock !== "-1") {
      root.idStock = id;
    } else {
      root.idStock = "-1"
    }
    
    var result = sqlEngine.select("entres_stock", ["id_fournisseur", "quantite",
                                                   "prix_d_achat", "prix_de_vente"],
                                  "code_CIP13", id);
    if (result.length>0) {
      var line = result[result.length - 1];
      fournisseurBox.currentIndex = fournisseurBox.indexOfValue(line[0]);
      quantiteField.value = line[1];
      achatField.value = line[2];
      venteField.value = line[3];
    }    
  }
  
  Component.onCompleted: function() {
    var result = sqlEngine.select("fournisseurs_produits", ["id", "nom"]);
    var fournisseurs = [];
    for (var i = 0; i < result.length; i++) {
      fournisseurs.push({"value": result[i][0], "text": result[i][1].toString()});
    }
    fournisseurBox.model = fournisseurs;
  }
  
  function achatVenteErrorCheck() {
    if (achatField.focus || venteField.focus) return;
    if (achatField.value > venteField.value) {
      venteField.error = qsTr("Le prix de vente est plus petit que le prix d'achat.");
      achatField.error = " ";
    }
    else {
      venteField.error = "";
      achatField.error = "";
    }
  }
  
  contentHeight: frame.topPadding + rightFrame.topPadding
    + column.implicitHeight + rightFrame.bottomPadding + frame.bottomPadding
  contentWidth: frame.leftPadding + rightFrame.leftPadding
    + (root.produitInfo ? preview.width : 0) + rowLayout.spacing + 150
    + rightFrame.rightPadding + frame.rightPadding
  
  contentItem: Frame {
    id: frame
    padding: 5
    
    Flickable {
      id: flickable
      anchors.fill: parent
      contentWidth: width
      contentHeight: height
      
      RowLayout {
        id: rowLayout
        spacing: 15
        anchors.fill: parent
        ProduitPreview {
          id: preview
          visible: root.produitInfo
          Layout.preferredWidth: 300
          Layout.fillHeight: true
        }
        
        Frame {
          id: rightFrame
          Layout.fillHeight: true
          Layout.fillWidth: true
          clip: true          
          
          Flickable {
            id: rightFlick
            anchors.fill: parent
            contentWidth: width
            contentHeight: column.implicitHeight
            ScrollBar.vertical: ScrollBar{}
            
            ColumnLayout {
              id: column
              width: parent.width
              property bool readOnly: false
              ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Label {
                  text: "Fournisseur"
                  font.pixelSize: 11
                }
                ComboBox {
                  valueRole: "value"
                  textRole: "text"
                  id: fournisseurBox
                  Layout.fillWidth: true
                }
              }
              CNumberField {
                id: quantiteField
                title: qsTr("Quantité")
                Layout.fillWidth: true
                onValueChanged: function() {
                  if (value < 0)
                    error = qsTr("La quantité ne peut pas etre negatif");
                  else error = "";
                }
              }
              CNumberField {
                id: achatField
                title: "Prix d'achat"
                Layout.fillWidth: true
                onValueChanged: root.achatVenteErrorCheck();
              }
              CNumberField {
                id: venteField
                title: "Prix de vente"
                Layout.fillWidth: true
                onValueChanged: root.achatVenteErrorCheck();
              }
              CustomTextField {
                id: peremptionField
                title: "Date de peremption"
                property string old: text
                Layout.preferredWidth: 80
                text: "__/__/____"
                onEditinFinished: function() {
                  if (!sqlEngine.isDateValid(text))
                    error = "Date invalide";
                  else error = "";
                }
                onEditingBeginning: function() {
                  var cp = cursorPosition;
                  while (cp > 0 && (text[cp-1] === "_" || text[cp-1] === "/")) {
                    cp = cp - 1;
                    if (text[cp] === "/" && text[cp-1] !== "_") {
                      cp += 1;
                      break
                    }
                  }
                  if (cursorPosition !== cp)
                    cursorPosition = cp;
                }
                onTextEdited: function() {
                  var txt = text.replace(/\//g, "");
                  var t = old.replace(/\//g, "");
                  var cp = cursorPosition
                  var s = txt.length - t.length;
                  var p = cp - (text.slice(0, cp).match(/\//g) || []).length;
                  var i = 0;
                  if (s>0) {
                    for (i = 0; i < s; i++)
                      t = (t.slice(0,p-s+i) + txt[p -s + i] + t.slice(p-s+i+1)).slice(0,8);
                    
                    if (cp - s === 2 || cp - s === 5)
                      cp++;
                    if (cp === 2 || cp === 5)
                      cp++;
                  } else if (s < 0) {
                    for (i = 0; i < -s; i++)
                      t = t.slice(0,p-s-i-1) + "_" + t.slice(p-s-i)
                    
                    if (cp === 3 || cp === 6)
                      cp--;
                  }
                  
                  text = t.slice(0,2) + "/" + t.slice(2,4) + "/" + t.slice(4);
                  old = text;
                  cursorPosition = Math.min(cp,10);
                }
              }              
            }
          }
        }
      }      
      ScrollBar.horizontal: ScrollBar {}
    }
  }
  
  footer: DialogButtonBox {
    standardButtons: Dialog.Cancel
    Button {
      visible: !root.readOnly
      text: "Ok"
      onClicked: function() {
        var valid = true;
        
        if (quantiteField.value <= 0)
          quantiteField.error = "Mettez une quantite valide.";
        else quantiteField.error = "";
        valid = valid && quantiteField.error === "";
        
        if (achatField.value <= 0)
          achatField.error = "Entrer un prix d'achat.";
        else achatField.error = "";
        
        if (venteField.value <= 0)
          venteField.error = "Entrer un prix de vente.";
        else venteField.error = "";

        root.achatVenteErrorCheck();
        valid = valid && achatField.error === "" && venteField.error === "";
        
        if (!sqlEngine.isDateValid(peremptionField.text))
          peremptionField.error = "Entrer une date valide.";
        else
          peremptionField.error = "";
        valid = valid && peremptionField.error === "";
        
        if (!valid)
          return;
        var result = sqlEngine.ajouterStock(root.idStock, fournisseurBox.currentValue,
                                            quantiteField.value, achatField.value,
                                            venteField.value, peremptionField.text);
        if (result === "")
          accept();
        else console.log("Error", result);
      }
    }
  }
}
