import QtQuick
import QtQuick.Layouts

Item {
    width: 300
    height: mainField.height
    property alias title: mainField.title
    property alias value: mainField.value
    property bool readOnly: parent.readOnly

    function setValue(val) {
        mainField.value = val;
        previousField.value = val;
    }

    RowLayout {
        id: root
        spacing: -1
        property alias title: mainField.title
        property alias value: mainField.value
        property bool readOnly: parent.readOnly
        anchors.fill: parent

        CNumberField {
            id: mainField
            Layout.fillWidth: true
        }
        CNumberField {
            Layout.alignment: Qt.AlignBottom
            visible: mainField.value !== value
            id: previousField
            enabled: false
            width: 100
        }
    }
}
