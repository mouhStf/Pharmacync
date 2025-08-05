import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../Widgets"

ColumnLayout {
    id: root
    property string name: "Produit"
    property bool readOnly: false
    property string codeProduit: "-1"
    property alias codeProduitFieldText: codeProduitField.text

    property var columns: ["code_produit", "designation", "titulaire",
        "detail", "technical_data_sheet", "category"]

    Component.onCompleted: function() {
        var result = sqlEngine.select("categories", ["id", "category"]);
        var categoriesBoxModel = [];
        for (var i = 0; i < result.length; i++) {
            if (result[i][0] !== 1)
                categoriesBoxModel.push({"value": result[i][0], "text": result[i][1].toString()});
        }
        categoriesBox.model = categoriesBoxModel;
    }

    function setCodeProduit(codeProduit) {
        if (codeProduit === "-1") {
            root.codeProduit = "-1";
            codeProduitField.text = "";
            designationField.text = "";
            titulaireField.text = "";
            detailField.text = "";
            technicalDataField.text = "";
            categoriesBox.currentIndex = 0;
        } else {
            if (fillFields(codeProduit))
                root.codeProduit = codeProduit;
            else codeProduit("-1");
        }
    }

    function fillFields(codeProduit) {
        var result = sqlEngine.select("produits", root.columns, "code_produit", codeProduit);
        if (result.length === 1) {
            codeProduitField.text = result[0][0];
            designationField.text = result[0][1];
            titulaireField.text = result[0][2];
            detailField.text = result[0][3];
            technicalDataField.text = result[0][4];
            categoriesBox.currentIndex = categoriesBox.indexOfValue(result[0][5]);
            return true;
        }
        return false;
    }

    function save() {
        if (!validate()) return false;

        var values = [codeProduitField.text, designationField.text,
                      titulaireField.text, detailField.text,
                      technicalDataField.text, categoriesBox.currentValue];

        var saved = false;
        if (codeProduit === "-1") {
            saved = sqlEngine.insert("produits", columns, values);
        } else {
            saved = sqlEngine.update("produits", columns, values, "code_produit", codeProduit);
        }
        if (saved) root.codeProduit = codeProduitField.text;
        return saved;
    }

    function validate() {
        if (codeProduitField.text === "") {
            codeProduitField.error = "Le code produit ne doit pas etre vide."
            return false;
        }
        else codeProduitField.error = ""
        return true;
    }

    CustomTextField {
        id: codeProduitField
        title: "Code"
    }
    CustomTextField {
        id: designationField
        title: "Designation"
    }
    CustomTextField {
        id: titulaireField
        title: "Titulaire"
    }
    CustomTextField {
        id: detailField
        title: "Details"
    }
    Label {
        text: "Categorie"
        font.pixelSize: 11
    }
    ComboBox {
        id: categoriesBox
        implicitWidth: 300
        textRole: "text"
        valueRole: "value"
    }
    Label {
        text: "Details techniques"
        font.pixelSize: 11
    }
    TextArea {
        id: technicalDataField
        readOnly: root.readOnly
        implicitWidth: 300
        implicitHeight: 150
        background: Rectangle {
            color: palette.base
            border.color: technicalDataField.activeFocus ? "#0066ff" : "#bdbdbd"
            border.width: technicalDataField.activeFocus ? 2 : 1
        }
    }
}
