CustomTextField {
  id: root
  property string old: text
  text: "__:__:__"
  
  onEditinFinished: function() {
    if (!sqlEngine.isTimeValid(text))
      error = "Heure invalide";
    else error = "";
  }
  
  function addOne(t, c, p) {
    var r = t.slice(0,p) + c + t.slice(p+1);
    return r.slice(0,6);
  }
  
  function delOne(t,p) {
    return t.slice(0,p-1) + "_" + t.slice(p)
  }
  
  onTextEdited: function() {
    // Store cursor position before any modifications
    var originalCursorPos = cursorPosition;
    
    // Remove all slashes from current and previous text
    var cleanText = text.replace(/\//g, "");
    var cleanOld = old.replace(/\//g, "");
    
    // Calculate cursor position in the clean text (without slashes)
    var cleanCursorPos = originalCursorPos - (text.slice(0, originalCursorPos).match(/\//g) || []).length;
    
    // Format the date with slashes (if there's content to format)
    if (cleanText.length > 0) {
      // Format as MM/DD/YY
      var formattedText = "";
      if (cleanText.length > 0) formattedText += cleanText.slice(0, Math.min(2, cleanText.length));
      if (cleanText.length > 2) formattedText += "/" + cleanText.slice(2, Math.min(4, cleanText.length));
      if (cleanText.length > 4) formattedText += "/" + cleanText.slice(4, Math.min(6, cleanText.length));
      
      // Update the text with formatted version
      text = formattedText;
    }
    
    // Determine new cursor position based on the formatted text
    var newCursorPos = cleanCursorPos;
    // Add 1 for each slash that appears before the cursor
    if (cleanCursorPos > 2) newCursorPos++;
    if (cleanCursorPos > 4) newCursorPos++;
    
    // Apply the new cursor position
    cursorPosition = Math.min(newCursorPos, text.length);
    
    // Save current text for the next edit
    old = text;
  }
  
}
/*
  CustomTextField {
  id: root
  property string old: text
  text: "__/__/____"
  
  function addOne(t, c, p) {
  var r = t.slice(0,p) + c + t.slice(p+1);
  return r.slice(0,8);
  }
  
    function delOne(t,p) {
        return t.slice(0,p-1) + "_" + t.slice(p)
    }

    onEditinFinished: function() {
        if (!sqlEngine.isDateValid(text))
            error = "Date invalide";
        else error = "";
    }

    onEditingBeginning: function() {
        var cp = cursorPosition;
        while (cp > 0 && (text[cp-1] === "_" || text[cp-1] === "/")) {
            cp = cp - 1;
            if (text[cp] === "/" && text[cp-1] !== "_") {
                cp += 1;
                break
            }
        }
        if (cursorPosition !== cp)
            cursorPosition = cp;
    }

    onTextEdited: function() {
        var txt = text.replace(/\//g, "");
        var t = old.replace(/\//g, "");
        var cp = cursorPosition
        var s = txt.length - t.length;
        var p = cp - (text.slice(0, cp).match(/\//g) || []).length;
        var i = 0;
        if (s>0) {
            for (i = 0; i < s; i++)
                t = addOne(t, txt[p -s + i], p-s+i);

            if (cp - s === 2 || cp - s === 5)
                cp++;
            if (cp === 2 || cp === 5)
                cp++;
        } else if (s < 0) {
            for (i = 0; i < -s; i++)
                t = delOne(t, p-s-i);

            if (cp === 3 || cp === 6)
                cp--;
        }

        text = t.slice(0,2) + "/" + t.slice(2,4) + "/" + t.slice(4);
        old = text;
        cursorPosition = Math.min(cp,10);
    }
}
*/
