import QtQuick
import QtQuick.Controls

Column {
  id: root
  property alias title: label.text
  property alias text: textField.text
  property alias labelTextAlignment: textField.horizontalAlignment
  property alias textField: textField
  property alias label: label
  width: 300

  spacing: 0
  visible: textField.text !== ""

  Label {
    id: label
    font.pixelSize: 11
    width: root.width
  }

  Label {
    id: textField
    font.pixelSize: 15
    wrapMode: Text.Wrap
    width: root.width
  }
}
