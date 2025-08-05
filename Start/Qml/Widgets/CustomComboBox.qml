import QtQuick
import QtQuick.Controls

Column {
    id: root
    property alias title: label.text
    property alias model: valueComboBox.model
    width: 140

    property bool readOnly: parent !== undefined ? parent.readOnly : false

    function setValue(val) {
        var idx = valueComboBox.indexOfValue(val);
        if (idx !== -1) {
            valueComboBox.currentIndex = idx;
            valueLabel.text = valueComboBox.textAt(idx);
        }
    }

    function getValue() {
        return valueComboBox.currentValue;
    }

    spacing: 3

    Label {
        id: label
        font.pixelSize: 11
    }
    TextField {
        id: valueLabel
        readOnly: true
        width: valueComboBox.width
        horizontalAlignment: Text.AlignHCenter
        visible: root.readOnly
    }
    ComboBox {
        id: valueComboBox
        width: parent.width
        valueRole: "value"
        textRole: "text"
        visible: !root.readOnly
    }
}
