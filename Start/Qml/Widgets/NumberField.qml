import QtQuick
import QtQuick.Controls

Column {
    id: root
    spacing: 3
    width: 140
    height: 57
    required property int to
    required property int from
    property int step: 1
    property string title
    property int value

    signal accept(value: int);

    function setValue(val) {
        if (value > to)
            value = to;
        if (value < from)
            value = from;
    }

    Label {
        id: label
        text: title
        font.pixelSize: 11
        visible: text !== ""
    }
    Row {
        spacing: 0
        height: root.height - (label.visible ? label.height + 3 : 0)
        Button {
            icon.source: "qrc:/icons/svgs/solid/minus.svg"
            enabled: value > from
            width: 40
            height: parent.height
            font.pixelSize: 20
            autoRepeat: true
            focusPolicy: Qt.NoFocus
            onClicked: function () {
                value -= step;
                setValue(value);
            }
        }
        TextField {
            id: textField
            width: root.width - 80
            height: parent.height
            readOnly: true
            text: value.toLocaleString()
            validator: IntValidator {
                bottom: root.from
                top: root.to
            }

            horizontalAlignment: TextField.AlignHCenter

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    event.accepted = true;
                    root.accept(value);
                }

                if (event.key === Qt.Key_Up) {
                    value += step;
                    event.accepted = true;
                }
                if (event.key === Qt.Key_Down) {
                    value -= step;
                    event.accepted = true;
                }
                if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                    value = value * 10 + (event.key - Qt.Key_0);
                    event.accepted = true;
                }
                if (event.key === Qt.Key_Backspace) {
                    if (value > 10)
                        value = parseInt(value / 10);
                    else value = 0;
                    event.accepted = true;
                }
                setValue(value)
            }
        }
        Button {
            icon.source: "qrc:/icons/svgs/solid/plus.svg"
            enabled: value < to
            width: 40
            height: parent.height
            font.pixelSize: 20
            focusPolicy: Qt.NoFocus
            autoRepeat: true
            onClicked: function() {
                value += step;
                setValue(value);
            }
        }
    }
}
