import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Frame {
  id: root
  
  clip: true
  property int total: 0
  signal vendre(products: var);
  padding: 5
  
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
      let qt = listModel.get(indx).quantite;
      if (qt >= restant) return;
      listModel.setProperty(indx, "quantite", qt+1);
      listView.positionViewAtIndex(indx, ListView.Visible);
    } else {
      var img = "";
      if (category === 1)
        img = "image://imageProvider/db://presentation/code_CIP13/" + cip13;
      else
        img = "image://imageProvider/db://presentation_produit/ean_13/" + cip13;
      listModel.append({
        "cip13": cip13, "nom0": nom0,
        "nom1": nom1,
        "quantite": 1, "prix": prix,
        "img": img, "restant": restant
      });
      listView.positionViewAtEnd();
    }
    updateTotal();
  }
  
  function present(cip13) {
    for (var i = 0; i < listModel.count; i++) {
      if (listModel.get(i).cip13 === cip13)
        return i;
    }
    
    return false;
  }
  
  function updateTotal() {
    total = 0;
    for (var i = 0; i < listModel.count; i++)
      total += listModel.get(i).prix * listModel.get(i).quantite;
  }
  
  function effacerTout() {
    total = 0;
    listModel.clear();
  }
  
  FontLoader {
    id: fontAwesome
    source: "qrc:/fa-solid-900.otf"
  }
  
  ListModel {
    id: listModel
  }
  
  ColumnLayout {
    anchors.fill: parent
    Pane {
      Layout.fillWidth: true
      Layout.fillHeight: true
      
      ListView {
        id: listView
        anchors.fill: parent
        model: listModel
        spacing: 3
        delegate: Rectangle {
          required property string cip13
          required property string nom0
          required property string nom1
          required property int quantite
          required property int prix
          required property string img
          required property int restant
          required property int index
          border.width: 1
          border.color: "black"
          
          Rectangle {
            x: -5
            y: -5
            width: 20
            height: 20
            z: 1
            border.width: 1
            border.color: "gray"
            
            MouseArea {
              anchors.fill: parent
              Image {
                anchors.fill: parent
                source: "qrc:/icons/svgs/solid/xmark.svg"
                fillMode: Image.PreserveAspectFit
                anchors.margins: 2
              }
              onClicked: listModel.remove(index)
            }
          }
          
          width: listView.width
          height: 50
          RowLayout {
            anchors.fill: parent
            spacing: 0
            
            Item {
              width: 50
              height: 50
              Image {
                anchors.centerIn: parent
                width: 48
                height: 48
                source: img
                sourceSize.width: width
                sourceSize.height: height
              }
            }
            
            Rectangle {
              width: 1
              Layout.fillHeight: true
              color: "gray"
            }
            
            Item {
              Layout.fillWidth: true
              Layout.fillHeight: true
              Text {
                width: parent.width - 20
                height: parent.height
                elide: Text.ElideRight
                x: 10
                wrapMode: Text.Wrap
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
                text: nom0 + "\n" + nom1
              }
            }
            Rectangle {
              width: 1
              Layout.fillHeight: true
              color: "gray"
            }
            Item {
              Layout.fillHeight: true
              width: 100
              Text {
                anchors.centerIn: parent
                text: (prix * quantite).toLocaleString() + " FCFA"
                font.pixelSize: 15
              }
            }
            Rectangle {
              width: 1
              Layout.fillHeight: true
              color: "gray"
            }
            Item {
              width: 122
              Layout.fillHeight: true
              NumberField {
                height: 48
                width: 120
                anchors.centerIn: parent
                from: 1
                to: restant
                value: quantite
                onValueChanged: function() {
                  listModel.setProperty(index, "quantite", value);
                  updateTotal();
                }
              }
            }
            
          }
        }
        
        ScrollBar.vertical: ScrollBar {}
      }
    }
    ToolBar {
      Layout.fillWidth: true
      RowLayout {
        anchors.fill: parent
        Label {
          Layout.fillWidth: true
          Layout.fillHeight: true
          text: "Total: " + total.toLocaleString() + " FCFA"
          leftPadding: 20
          font.pixelSize: 15
          verticalAlignment: Text.AlignVCenter
        }
        
        ToolButton {
          text: "Effacer tout"
          enabled: listModel.count > 0
          onClicked: effacerTout()
          icon.source: "qrc:/icons/svgs/solid/broom.svg"
        }
        ToolButton {
          text: "Vendre"
          enabled: listModel.count > 0
          icon.source: "qrc:/icons/svgs/solid/money-bill-transfer.svg"
          onClicked: function() {
            if (listModel.count === 0) return;
            var products = [];
            for (var i = 0; i < listModel.count; i++) {
              products.push({
                "code": listModel.get(i).cip13,
                "quantite": listModel.get(i).quantite
              });
            }
            root.vendre(listModel);
          }
        }
      }
    }
  }
}
