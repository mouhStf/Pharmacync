import QtQuick
import QtQuick.Controls

Flickable {
  id: root
  property var products
  property string tableData
  property int total
  property int paye
  property int donne
  property int rendu
  property int numero: -1
  property string emetteur
  property string date
  property string time
  
  
  contentWidth: edit.contentWidth
  contentHeight: edit.contentHeight
  clip: true

  ListModel {
    id: listModel
  }
    
  function setId(idFacture) {
    listModel.clear();
    var result = sqlEngine.select("facture",
                                  ["date", "paye", "donne", "rendu",
                                   "id_user"], "id", idFacture);
    if (result.length !== 1) return;
    
    root.numero = idFacture;
    root.date = sqlEngine.dateFromSec(result[0][0]);
    root.time = sqlEngine.timeFromSec(result[0][0]);
    root.paye = result[0][1];
    root.donne = result[0][2];
    root.rendu = result[0][3];

    var idUser = result[0][4];
    result = sqlEngine.select("utilisateur",
                              ["titre", "prenom", "nom"], "id", idUser);
    var emetteur = "";
    if (result.length === 1)
      emetteur = result[0][0] + ". " + result[0][1] + " " + result[0][2];
    root.emetteur = emetteur;

    
    result = sqlEngine.select("flux", ["id_entres_stock", "restant", "id"],
                              "id_facture", idFacture, "AND restant > 0");
    for (var i = 0; i < result.length; i++) {
      var ligne = result[i];
      var quantite = ligne[1];
      var idFlux = ligne[2];
      var tmp = sqlEngine.select("entres_stock JOIN stock ON stock.code_CIP13 = entres_stock.code_CIP13",
                                 ["entres_stock.code_CIP13", "prix_de_vente", "category"],
                                 "entres_stock.id", ligne[0]);
      if (tmp.length !== 1) return;
      var cip13 = tmp[0][0].toString();
      var prix = tmp[0][1];
      var category = tmp[0][2];
      var nom0 = "", nom1 = "";
      tmp = [];
      var img = "";
      if (category === 1) {
        tmp = sqlEngine.select("presentation join specialite on presentation.code_CIS = specialite.code_CIS",
                               ["denomination_du_medicament", "libelle_de_la_presentation"],
                               "presentation.code_CIP13", cip13);
        img = "image://imageProvider/db://presentation/code_CIP13/" + cip13;
      } else {
        tmp = sqlEngine.select("presentation_produit join produits on presentation_produit.code_produit = produits.code_produit",
                                       ["designation", "libelle"], "ean_13", cip13);
        img = "image://imageProvider/db://presentation_produit/ean_13/" + cip13;
      }
      
      if (tmp.length !== 1) return;
      nom0 = tmp[0][0];
      nom1 = tmp[0][1];
      
      listModel.append({
        "idFlux": idFlux, "cip13": cip13,
        "nom0": nom0, "nom1": nom1,
        "quantite": quantite, "prix": prix,
        "img": img
      });
    }
    
    root.products = listModel;
  }  
  
  ScrollBar.vertical: ScrollBar {}
  ScrollBar.horizontal: ScrollBar {}
  
  onProductsChanged: function() {
    tableData = "";
    total = 0;
    for (var i = 0; i < products.count; i++) {
      tableData = tableData
        + "<tr>"
        + "<td style='padding:5px;padding-top:10px;padding-bottom:10px;'>" + products.get(i).nom0 + "<br> <span style='text-decoration:underline;'>" + products.get(i).nom1 + "</span></td>"
        + "<td style='padding:5px;padding-top:10px;padding-bottom:10px;text-align: right;'>" + products.get(i).quantite + "</td>"
        + "<td style='padding:5px;padding-top:10px;padding-bottom:10px;text-align: right;'>" + products.get(i).prix + "</td>"
        + "<td style='padding:5px;padding-top:10px;padding-bottom:10px;text-align: right;'>" + (products.get(i).prix * products.get(i).quantite) + "</td>"
        + "</tr> ";
      total += products.get(i).prix * products.get(i).quantite;
    }
  }
  
  
  TextEdit {
    id: edit
    wrapMode: TextEdit.Wrap
    readOnly: true
    textFormat: TextEdit.RichText
    width: root.width
    
    text: "
<h1 style='text-align:center;'>" + (numero === -1 ? "Devis" : "Facture") +  "</h1>"
      + (
        numero === -1 ? "" : ("
<table style='border-collapse:collapse;margin-bottom:20px;' width='100%'>
  <tr>
    <td style='padding:5px;padding-top:10px;padding-bottom:10px;'>
      <strong>Numero :</strong> " + numero + "
      <br><strong>Emetteur :</strong> " + emetteur + "
    </td>
    <td  style='padding:5px;padding-top:10px;padding-bottom:10px;text-align: right;'>
      " + root.date + "  <br> " + time + "
    </td>
  </tr>
</table>
")
      )
      + "
<table style='border-collapse:collapse;margin-bottom:20px;border: 1px solid black;' width='100%'>
  <thead>
    <tr height='20'>
      <th style='height: 40px;'>Médicaments</th>
      <th style='height: 40px;text-align:center;'>Qut</th>
      <th style='height: 40px;'>Prx un. (FCFA)</th>
      <th style='height: 40px;'>Prx tt. (FCFA)</th>
    </tr>
  </thead>
  <tbody>" + tableData + "
</tbody>
</table>
<div style='text-align:right;font-size:20;'>
  <h3><strong>Total:</strong> " + total.toLocaleString() + " F CFA</h3>"
      + (numero === -1 ? "" :
         ("<h4> Payé : " + paye.toLocaleString() + " F CFA (" + donne.toLocaleString() + " F CFA donné - " + rendu + " F CFA rendu)</h4>") )
      +
      "</div>"
  }
}
