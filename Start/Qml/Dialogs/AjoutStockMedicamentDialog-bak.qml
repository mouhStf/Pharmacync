import QtQuick
import QtQuick.Controls
import QtQml
import "../Widgets"
import "../DataHandlers"

import core

Dialog {
  id: root
  title: "Medicament"
  anchors.centerIn: parent
  property string idStock
  property bool initiating: false
  property bool medicamentInfo: true
  
  function setId(id) {
    initiating = true;
    preview.setId(id);
    if (preview.idStock !== "-1") {
      root.idStock = id;
    } else {
      root.idStock = "-1"
    }
    
    var result = sqlEngine.select("entres_stock", ["id_fournisseur", "quantite", "prix_d_achat", "prix_de_vente"],
                                      "code_CIP13", id);
    if (result.length>0) {
      var line = result[result.length - 1];
      fournisseurBox.currentIndex = fournisseurBox.indexOfValue(line[0]);
      quantiteField.value = line[1];
      achatField.value = line[2];
      venteField.value = line[3];
    }
    initiating = false;
  }
  
  Component.onCompleted: function() {
    var result = sqlEngine.select("fournisseur", ["id", "nom"]);
    var fournisseurs = [];
    for (var i = 0; i < result.length; i++) {
      fournisseurs.push({"value": result[i][0], "text": result[i][1].toString()});
    }
    fournisseurBox.model = fournisseurs;
  }
  
  contentItem: Flickable {
    implicitWidth: rrw.width
    implicitHeight: rrw.height
    contentWidth: rrw.width
    contentHeight: rrw.height
    Row {
      id: rrw
      spacing: 15
      clip: true
      
      MedicamentPreview {
        id: preview
        implicitHeight: root.parent ? Math.min(root.parent.height - 100, presentationHeight) : 0
        visible: root.medicamentInfo
      }
      
      Rectangle {
        visible: preview.visible
        width: 2
        color: "black"
        height: parent.height
      }
      
      Flickable {
        id: flick
        implicitWidth: 300
        implicitHeight: root.parent ? Math.min(root.parent.height - 100, column.height) : 0
        contentWidth: column.width
        contentHeight: column.height
        ScrollBar.vertical: ScrollBar {}
        Column {
          id: column
          property bool readOnly: false
          Column {
            spacing: 3
            Label {
              text: "Fournisseur"
              font.pixelSize: 11
            }
            ComboBox {
              valueRole: "value"
              textRole: "text"
              id: fournisseurBox
              width: 300
            }
          }
          CNumberField {
            id: quantiteField
            title: "Quantité"
            onValueChanged: function() {
              if (root.initiating) return;
              if (value < 0)
                error = qsTr("La quantité ne peut pas etre negatif");
              else error = "";
            }
          }
          CNumberField {
            id: achatField
            title: "Prix d'achat"
            onValueChanged: function() {
              if (root.initiating) return;
              if (achatField.value > venteField.value)
                error = qsTr("Le prix d'achat est plus grand que le prix de vente.");
              else
                error = "";
            }
          }
          CNumberField {
            id: venteField
            title: "Prix de vente"
            onValueChanged: function() {
              if (root.initiating) return;
              if (achatField.value > venteField.value)
                error = qsTr("Le prix de vente est plus petit que le prix d'achat.");
              else 
                error = "";
            }
          }
          CustomTextField {
            id: peremptionField
            title: "Date de peremption"
            property string old: text
            text: "__/__/____"
            
            function addOne(t, c, p) {
              var r = t.slice(0,p) + c + t.slice(p+1);
              return r.slice(0,8);
            }
            
            function delOne(t,p) {
              return t.slice(0,p-1) + "_" + t.slice(p)
            }
            
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
                  t = addOne(t, txt[p -s + i], p-s+i);
                
                if (cp - s === 2 || cp - s === 5)
                  cp++;
                if (cp === 2 || cp === 5)
                  cp++;
              } else if (s < 0) {
                for (i = 0; i < -s; i++)
                  t = delOne(t, p-s-i);
                
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
      
      Rectangle {
        width: 5
        height: 5
      }
    }
    
    ScrollBar.horizontal: ScrollBar {}
  }
    
  footer: DialogButtonBox {
    standardButtons: Dialog.Cancel
    Button {
      visible: !root.readOnly
      text: "Ok"
      onClicked: function() {
        var valid = true;
        if (Number(quantiteField.text) <= 0)
          quantiteField.error = "Mettez une quantite valide.";
        valid = valid && quantiteField.error === "";
        
        if (achatField.text === "")
          achatField.error = "Entrer un prix d'achat.";
        valid = valid && achatField.error === "";
        
        if (venteField.text === "")
          venteField.error = "Entrer un prix de vente.";
        valid = valid && venteField.error === "";        
        
        if (!sqlEngine.isDateValid(peremptionField.text))
          peremptionField.error = "Entrer une date valide.";
        valid = valid && peremptionField.error === "";
        
        if (!valid)
          return;
        var result = sqlEngine.ajouterStock(root.idStock, fournisseurBox.currentValue,
                                            quantiteField.text, achatField.text,
                                            venteField.text, peremptionField.text);
        if (result === "")
          accept();
        else console.log("Error", result);
        
      }
    }
  }
}
