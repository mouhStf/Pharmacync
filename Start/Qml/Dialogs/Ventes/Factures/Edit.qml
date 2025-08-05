import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../../Widgets"

Dialog {
  id: root
  title: "Edition (" + (err ? "Erreur" : "Retour") + ") de la Facture nº"+ idVal
  property int idVal: -1
  property bool err: false
  
  ListModel {
    id: productList
  }
  
  ListModel {
    id: userList
  }
  
  Component.onCompleted: function() {
    var result = sqlEngine.select("utilisateur", ["id", "titre", "prenom", "nom"]);
    for (var i = 0; i < result.length; i++) {
      userList.append({"text": result[i][1] + " " + result[i][2] + " " + result[i][3],
                       "value": result[i][0]});
    }
  }
  
  function setId(val) {
    currentDateTime.checked = true;
    productList.clear();
    var result = sqlEngine.select("facture", ["date", "valeur", "paye", "donne", "rendu", "id_user"], "id", val);
    dateField.text = sqlEngine.dateFromSec(result[0][0]);
    timeField.text = sqlEngine.timeFromSec(result[0][0]);
    
    valeurField.setValue(result[0][1]);
    payeField.setValue(result[0][2]);
    donneField.setValue(result[0][3]);
    renduField.setValue(result[0][4]);
    
    userComboBox.setValue(result[0][5]);
    
    if (result.length !== 1) {
      idVal = -1;
    } else {
      idVal = val;
      
      result = sqlEngine.select("flux JOIN stock ON flux.code_CIP13 = stock.code_CIP13 JOIN entres_stock ON flux.id_entres_stock = entres_stock.id",
                                ["flux.id", "id_entres_stock", "flux.code_CIP13", "flux.restant", "category", "prix_de_vente", "entres_stock.restant"],
                                "id_facture", idVal, "AND flux.restant > 0");
      
      for (var i = 0; i < result.length; i++) {
        var line = result[i];
        var idFlux = line[0];
        var idEntreStock = line[1];
        var cip13 = line[2].toString();
        var quantite = line[3];
        var category = line[4];
        var prix = line[5];
        var restant = line[6];
        var nom0 = "";
        var nom1 = cip13;
        
        var nmTable = "";
        var nmCols = [];
        var nmIdCol = "";
        if (category === 1) {
          nmTable = "presentation JOIN specialite ON presentation.code_CIS = specialite.code_CIS";
          nmCols = ["denomination_du_medicament", "libelle_de_la_presentation"];
          nmIdCol = "code_CIP13";
        } else {
          nmTable = "presentation_produit JOIN produits ON presentation_produit.code_produit = produits.code_produit";
          nmCols = ["designation", "libelle"];
          nmIdCol = "ean_13";
        }
        
        var nmResult = sqlEngine.select(nmTable, nmCols, nmIdCol, cip13);
        
        if (nmResult.length === 1) {
          nom0 = nmResult[0][0];
          nom1 = nmResult[0][1];
        }
        
        productList.append({
          "idFlux": idFlux, "cip13": cip13,
          "nom0": nom0, "nom1": nom1,
          "quantite": quantite, "prix": prix,
          "restant": restant, "firstValue": quantite
        });
      }
      
      
    }
    
  }
  
  function updateValeur() {
    var total = 0;
    for (var i = 0; i < productList.count; i++)
      total += productList.get(i).prix * productList.get(i).quantite;
    valeurField.value = total;
  }
  
  function present(cip13) {
    for (var i = 0; i < productList.count; i++) {
      if (productList.get(i).cip13 === cip13)
        return i;
    }
    return false;
  }
  
  function ajouter(cip13) {
    cip13 = cip13.toString();
    var result = sqlEngine.select("stock", ["restant", "id_current",
                                            "category"],
                                  "code_CIP13", cip13);
    if (result.length !== 1) return;
    if (result[0][0] <= 0) return;
    let id_current = result[0][1];
    let category = result[0][2];
    
    result = sqlEngine.select("entres_stock", ["restant", "prix_de_vente"],
                              "id", id_current);
    if (result.length !== 1) return;
    let restant = result[0][0];
    let prix = result[0][1];
    
    if (category === 1) {
      result = sqlEngine.select("presentation JOIN specialite "
                                + "ON presentation.code_CIS = "
                                +"specialite.code_CIS",
                                ["denomination_du_medicament",
                                 "libelle_de_la_presentation"], "code_CIP13", cip13);
    } else {
      result = sqlEngine.select("produits JOIN presentation_produit "
                                + "ON presentation_produit.code_produit"
                                +" = produits.code_produit",
                                ["designation", "libelle"],
                                "ean_13", cip13);
    }
    
    if (result.length !== 1) return;
    let nom0 = result[0][0];
    let nom1 = result[0][1];
    
    var indx = present(cip13);
    
    if (indx !== false) {
      var qt = productList.get(indx).quantite;
      if (qt >= restant) return;
      productList.setProperty(indx, "quantite", qt+1);
    } else {
      productList.append({
        "idFlux": -1,
        "cip13": cip13,
        "nom0": nom0 ,
        "nom1": nom1,
        "quantite": 1,
        "prix": prix,
        "restant": restant,
        "firstValue": 0
      });
      updateValeur();
    }
  }
  
  
  contentItem: RowLayout {
    
    Item {
      Layout.fillHeight: true
      width: 400
      ColumnLayout {
        anchors.fill: parent
        Label {
          text: qsTr("Produits")
          font.bold: true
        }
        
        Frame {
          Layout.fillHeight: true
          Layout.fillWidth: true
          clip: true
          rightPadding: 2
          
          ListView {
            anchors.fill: parent
            model: productList
            spacing: 5
            ScrollBar.vertical: ScrollBar{}
            delegate: Frame {
              width: 380
              height: 80
              
              Item {
                anchors.fill: parent
                Rectangle {
                  x: -22
                  y: -12
                  width: 20
                  height: 20
                  z: 1
                  border.width: 1
                  border.color: "gray"
                  Image {
                    anchors.fill: parent
                    source: "qrc:/icons/svgs/solid/xmark.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.margins: 2
                  }
                  MouseArea {
                    anchors.fill: parent
                    onClicked: function() {
                      if (firstValue !== 0) {
                        productList.setProperty(index, "quantite", 0);
                      } else {
                        productList.remove(index);
                        root.updateValeur();
                      }
                    }
                  }
                }
                RowLayout {
                  id: rowLay
                  enabled: numField.value > 0
                  anchors.fill: parent
                  Label {                                        
                    maximumLineCount: 4
                    elide: Label.ElideRight
                    wrapMode: Label.Wrap
                    text: model.nom0 + " " + model.nom1
                    Layout.fillWidth: true
                    height: 60
                  }
                  
                  Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: "gray"
                  }
                  
                  ColumnLayout {
                    id: colPrixQuant
                    RowLayout {
                      Layout.preferredWidth: 120
                      spacing: 2
                      Image {
                        Layout.preferredHeight: 11
                        Layout.preferredWidth: 11
                        source: "qrc:/icons/svgs/solid/money-bill-wave.svg"
                        fillMode: Image.PreserveAspectFit
                      }
                      
                      Label {
                        text: model.prix.toLocaleString() + " x " + numField.value + " = " + (model.prix * numField.value).toLocaleString()
                      }
                    }
                    
                    NumberField {
                      id: numField
                      Layout.preferredHeight: 40
                      Layout.preferredWidth: 120
                      from: 1
                      to: model.restant
                      value: model.quantite
                      onValueChanged: function() {
                        productList.setProperty(index, "quantite", value);
                        value = Qt.binding(function() { return quantite;});
                        root.updateValeur()
                      }
                    }
                  }
                }
                
                Button {
                  visible: !rowLay.enabled
                  anchors.centerIn: parent
                  icon.source: "qrc:/icons/svgs/solid/arrow-rotate-left.svg"
                  text: qsTr("Restaurer")
                  onClicked: function() {
                    productList.setProperty(index, "quantite", firstValue);
                  }
                }
              }
            }
          }
        }
        
        Button {
          Layout.fillWidth: true
          icon.source: "qrc:/icons/svgs/solid/cart-plus.svg"
          text: qsTr("Ajouter un produit")
          onClicked: ajoutProduit.open()
        }
      }
    }
    
    Rectangle {
      Layout.fillHeight: true
      width: 1
      color: "gray"
    }
    
    ColumnLayout {
      id: mainLayout
      property bool readOnly: false
      
      Label {
        text: qsTr("Produits")
        font.bold: true
      }
      Row {
        property bool readOnly: parent.readOnly
        spacing: 4
        
        CDateField {
          id: dateField
          enabled: !currentDateTime.checked
          title: qsTr("Date")
          width: 148
        }
        
        CTimeField {
          id: timeField
          enabled: !currentDateTime.checked
          title: qsTr("Heure")
          width: 148
        }
      }
      
      CheckBox {
        id: currentDateTime
        text: qsTr("Actualiser la date et l'heure")
      }
      
      CNumberPreviousField {
        id: valeurField
        title: qsTr("Valeur")
        readOnly: true
      }
      CNumberPreviousField {
        id: payeField
        title: qsTr("Payee")
        readOnly: true
      }
      CNumberPreviousField {
        id: donneField
        title: qsTr("Donne")
        onValueChanged: payeField.value = value - renduField.value
      }
      CNumberPreviousField {
        id: renduField
        title: qsTr("Rendu : (doit rendre ") + (donneField.value - valeurField.value).toLocaleString() + qsTr(" FCFA, soit ") + ((donneField.value - valeurField.value) - renduField.value).toLocaleString() + qsTr(" FCFA en plus)")
        onValueChanged: payeField.value = donneField.value - value
      }
      CustomComboBox {
        id: userComboBox
        title: qsTr("Vendeur")
        model: userList
        width: 200
      }
    }
  }
  
  function updateFlux() {
  }
  
  footer: DialogButtonBox {
    standardButtons: Dialog.Cancel
    Button {
      enabled: payeField.value >= valeurField.value
      text: qsTr("Ok")
      onClicked: function() {
        var prods = {};
        var deleteq = true;
        
        for (var i = 0; i < productList.count; i++) {
          var val = [
            productList.get(i).cip13,
            productList.get(i).quantite,
            productList.get(i).firstValue
          ];
          if (val[1] !== 0)
            deleteq = false;
          var idF = productList.get(i).idFlux;
          if (idF === -1)               // this is to
            idF = -productList.count; // avoid redondance
          prods[idF] = val;
        }

        if (deleteq) {
          suppressionDialog.open();
        } else {
          if (sqlEngine.editFacture(root.idVal, prods, valeurField.value,
                                    donneField.value, renduField.value, root.err))
            root.accept();
        }
      }
    }
  }
  
  AjoutProduit {
    id: ajoutProduit
    onChoisi: function (cip13) {
      root.ajouter(cip13);
    }
  }

  Dialog {
    id: suppressionDialog
    anchors.centerIn: parent
    title: qsTr("Suppression de la facture")
    Label {
      text: qsTr("La facture va etre supprimer")
    }
    footer: DialogButtonBox {
      standardButtons: Dialog.Cancel
      Button {
        text: qsTr("Confirmer")
        onClicked: function() {
          if (sqlEngine.update("facture", ["deleted"], [1], "id", root.idVal)) {
            suppressionDialog.accept();
            root.accept();
          }
        }
      }
    }
  }
}
