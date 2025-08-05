import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"
import "../Utils/functions.mjs" as Functions

Frame {
  id: root
  property string name: "Spécialité"
  property bool readOnly: false
  property string codeCIS: "-1"
  property alias codeCISFieldText: codeCISField.text
  
  property var columns: ["code_CIS", "denomination_du_medicament",
                         "titulaires", "forme_pharmaceutique",
                         "voies_dadministration"]
  
  function setCodeCIS(codeCIS) {
    if (codeCIS === "-1") {
      root.codeCIS = "-1";
      codeCISField.text = "";
      denominationField.text = "";
      titulairesField.text = "";
      formeField.text = "";
      voiesField.text = "";
    } else {
      if (fillFields(codeCIS))
        root.codeCIS = codeCIS;
      else setCodeCIS("-1");
    }
  }
  
  function fillFields(codeCIS) {
    var result = sqlEngine.select("specialite", root.columns, "code_CIS", codeCIS);
    if (result.length === 1) {
      codeCISField.text      = result[0][0];
      denominationField.text = result[0][1];
      titulairesField.text   = result[0][2];
      formeField.text        = result[0][3];
      voiesField.text        = result[0][4];
      return true;
    }
    return false;
  }
  
  function save() {
    if (!validate()) return false;
    var values = [codeCISField.text, denominationField.text,
                  titulairesField.text, formeField.text,
                  voiesField.text];
    
    var saved = false;
    if (codeCIS === "-1") {
      saved = Functions.save("specialite", columns, values, "code_CIS", codeCISField.text);
    } else {
      saved = Functions.update("specialite", columns, values, "code_CIS", codeCIS);
    }
    if (saved) root.codeCIS = codeCISField.text;
    return saved;
  }
  
  function validate() {
    if (codeCISField.text === "") {
      codeCISField.error = "Le code CIS ne doit pas etre vide."
      return false;
    }
    else codeCISField.error = ""
    return true;
  }
    
  contentItem: ColumnLayout {
    property bool readOnly: root.readOnly
    CustomTextLabelField {
      id: codeCISField
      title: "Code CIS"
      validator: /\d\d\d\d\d\d\d\d/
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: denominationField
      title: "Denomination du medicament"
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: titulairesField
      title: "Titulaires"
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: formeField
      title: "Forme Pharmaceutique"
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: voiesField
      title: "Voies d'administration"
      Layout.fillWidth: true
    }
  }
}
