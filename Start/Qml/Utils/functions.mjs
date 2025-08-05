export function setSqlEngine(sqlEngine) {
  _sqlEngine = sqlEngine;
}

var _sqlEngine;

export function deleteFromDictionnaire(code_CIS) {
  /** @type {Array<any>} */
  var result = _sqlEngine.select("presentation", ["deleted"], "code_CIS", code_CIS);
  var deleted = 0;
  var nodelet = 0;
  for (var i = 0; i < result.length; i++) {
    if (result[i][0] === 1)
      deleted++;
    else
      nodelet++;
  }
  if (nodelet > 0) {
    console.log("Cant delete when there are still presentations.");
    return false;
  } else {
    var ok = false;
    if (deleted > 0)
      ok = _sqlEngine.update("specialite", ["deleted"], [1], "code_CIS", code_CIS);
    else
      ok = _sqlEngine.deleteRow("specialite", "code_CIS", code_CIS);
    return ok;
  }
}

export function save(tableName, columns, values, idCol, idVal) {   
  var saved = false, here = false, deleted = false;
  
  /** @type {Array<any>} */
  var result = _sqlEngine.select(tableName, ["deleted"], idCol, idVal);

  if (result.length > 1) {
    console.log("Error qml 01", tableName, idCol, idVal, " to many lines", result.length);
    return false;
  }

  if (result.length > 0) {
    here = true;
    deleted = result[0][0] === 1;
  }

  if (here) {
    if (deleted)
      saved = _sqlEngine.update(tableName, columns, values, idCol, idVal);
    else {
      console.log("Error qml 02", tableName, idCol, idVal, "trying to save present no deleted");
      return false;
    }
  } else 
    saved = _sqlEngine.insert(tableName, columns, values);
  return saved;
}

export function update(tableName, columns, values, idCol, idVal) {
  var saved = false;
  saved = _sqlEngine.update(tableName, columns, values, idCol, idVal);
  return saved;
  
}
