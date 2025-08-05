import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
  id: root
  property alias title: label.text
  property int value: 0
  property alias error: error.text
  width: 150
  
  property bool readOnly: parent !== undefined ? parent.readOnly : false
  
  spacing: 3
  
  Label {
    id: label
    visible: text !== ""
    font.pixelSize: 11
  }

  function formatedValue() {
    var t = root.value.toFixed(0);
    var result = t.slice(Math.max(t.length-3, 0), t.length);
    for (var i = t.length-3; i > 0; i -= 3)
      result = t.slice(Math.max(i-3, 0), i) + Qt.locale().groupSeparator + result;
    return result;
  }

  function unformatedValue() {
    var sep = new RegExp(Qt.locale().groupSeparator, "g");
    return textField.text.replace(sep , "");
  }


  property bool inEdit: false
  onValueChanged: function() {
    if (!inEdit)
      textField.text = root.formatedValue();
  }
  
  TextField {
    id: textField
    readOnly: root.readOnly
    property string groupSep
    maximumLength: 11
    font.pixelSize: 14
    text: "0"
    Layout.fillWidth: true
    
    validator: DoubleValidator {}

    onFocusChanged: function() {
      if (focus) {
        text = root.unformatedValue();
        maximumLength = 9;
      }
      else {
        maximumLength = 11;
        text = root.formatedValue();
      }
    }
    
    horizontalAlignment: TextField.AlignRight
    
    background: Rectangle {
      implicitHeight: 40
      color: palette.base
      border.color: error.text !== "" ? "red" : (textField.activeFocus ? "#0066ff" : "#bdbdbd")
      border.width: textField.activeFocus ? 2 : 1
    }

    onEditingFinished: function() {
      root.inEdit = true
      root.value = root.unformatedValue();
      root.inEdit = false
    }
  }
  
  Label {
    id: error
    visible: text !== ""
    color: "#951512"
    Layout.fillWidth: true
    wrapMode: Text.Wrap
  }
}
