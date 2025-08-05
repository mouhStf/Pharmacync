import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"
import "../Utils/functions.mjs" as Functions

Frame {
  id: root
  property string name: "Composition"
  property bool readOnly: false
  property string codeCIS: "-1"
  property alias codeCISFieldText: codeCISField.text
  
  property var columns: ["code_CIS", "designation_de_lelement_pharmaceutique",
                         "code_de_la_substance", "denomination_de_la_substance",
                         "dosage_de_la_substance", "referene_de_ce_dosage",
                         "nature_du_composant"]
  
  function setCodeCIS(codeCIS) {
    if (codeCIS === "-1") {
      root.codeCIS = "-1";
      codeCISField.text = "";
      designationField.text = "";
      codeSubstanceField.text = "";
      denominationSubstanceField.text = "";
      dosageSubstanceField.text = "";
      referenceDosageField.text = "";
      natureComposantField.text = "";
    } else {
      if (fillFields(codeCIS)) {
        root.codeCIS = codeCIS;
      } else {
        setCodeCIS("-1");
      }
    }
  }
  
  function fillFields(codeCIS) {
    var result = sqlEngine.select("composition", root.columns, "code_CIS", codeCIS);
    if (result.length === 1) {
      codeCISField.text = result[0][0];
      designationField.text = result[0][1];
      codeSubstanceField.text = result[0][2];
      denominationSubstanceField.text = result[0][3];
      dosageSubstanceField.text = result[0][4];
      referenceDosageField.text = result[0][5];
      natureComposantField.text = result[0][6];
      return true;
    }
    return false;
  }
  
  function save() {
    if (!validate()) return false;
    var values = [codeCISField.text, designationField.text,
                  codeSubstanceField.text, denominationSubstanceField.text,
                  dosageSubstanceField.text, referenceDosageField.text,
                  natureComposantField.text];
    var saved = false;
    if (codeCIS === "-1") {
      saved = Functions.save("composition", columns, values, "code_CIS",
                             codeCISField.text);
    } else {
      saved = Functions.update("composition", columns, values, "code_CIS",
                               codeCIS);
    }
    if (saved) root.codeCIS = codeCISField.text
    return saved;
  }
  
  function validate() {
    if (codeCISField.text === "") {
      codeCISField.error = "Le code CIS ne doit pas être vide.";
      return false;
    } else {
      codeCISField.error = "";
    }
    return true;
  }
  
  contentItem: ColumnLayout {
    property bool readOnly: root.readOnly    
    CustomTextLabelField {
      id: codeCISField
      visible: false
      title: "Code CIS"
      validator: /\d{8}/
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: designationField
      title: "Désignation de l'élément pharmaceutique"
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: codeSubstanceField
      title: "Code de la substance"
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: denominationSubstanceField
      title: "Dénomination de la substance"
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: dosageSubstanceField
      title: "Dosage de la substance"
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: referenceDosageField
      title: "Référence du dosage"
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: natureComposantField
      title: "Nature du composant"
      Layout.fillWidth: true
    }
  }
  
}
