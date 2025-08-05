cmake_minimum_required(VERSION 3.19)

project(PharmaCync VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Sql PrintSupport)

qt_standard_project_setup(REQUIRES 6.5)
qt_policy(SET QTP0004 NEW)

set(CMAKE_AUTORCC ON)
set(QT_QML_GENERATE_QMLLS_INI ON)
qt_add_executable(pharmacync_start
  ressource.qrc
  main.cpp
  core/database.h
  core/database.cpp
  core/tableModel.h
  core/tableModel.cpp

  engines/loginEngine.h
  engines/loginEngine.cpp
  engines/sqlQueryEngine.h
  engines/sqlQueryEngine.cpp
  engines/sqlImageProvider.h
  engines/sqlImageProvider.cpp
  engines/facture.h
  engines/facture.cpp
  engines/painterEngine.h
  engines/painterEngine.cpp
  engines/statistics.h
  engines/statistics.cpp
)

qt_add_qml_module(pharmacync_start
    URI PharmaCync.Start
    VERSION 1.0
    QML_FILES
        Qml/Main.qml
        Qml/Screens/Login.qml

        Qml/Screens/Menu.qml
        Qml/Screens/MenuForm.ui.qml

        Qml/Widgets/Table.qml
        Qml/Widgets/TableAndFilter.qml
        Qml/Widgets/CustomTextField.qml
        Qml/Widgets/CustomLabelField.qml
        Qml/Widgets/VenteBoard.qml
        Qml/Widgets/Facture.qml
        Qml/Widgets/NumberField.qml
        Qml/Widgets/CustomComboBox.qml
        Qml/Widgets/CToolButton.qml
        Qml/Widgets/CDateField.qml
        Qml/Widgets/CNumberField.qml
        Qml/Widgets/CTimeField.qml
        Qml/Widgets/CNumberPreviousField.qml
        Qml/Widgets/CustomTextLabelField.qml

        Qml/Menus/Dictionnaire.qml
        Qml/Menus/DictionnaireMedicament.qml
        Qml/Menus/DictionnaireProduit.qml
        Qml/Menus/Stock.qml
        Qml/Menus/StockMedicament.qml
        Qml/Menus/StockProduit.qml
        Qml/Menus/Ventes.qml
        Qml/Menus/CreationVente.qml
        Qml/Menus/Factures.qml
        Qml/Menus/Configuration.qml
        Qml/Menus/ConfigurationUtilisateurs.qml
        Qml/Menus/Inventaire.qml
        Qml/Menus/InventaireMedicament.qml
        Qml/Menus/InventaireProduit.qml

        Qml/Dialogs/DictionnaireMedicamentDialog.qml
        Qml/Dialogs/DictionnaireProduitDialog.qml
        Qml/Dialogs/StockMedicamentDialog.qml
        Qml/Dialogs/StockProduitDialog.qml
        Qml/Dialogs/EntreStockDialog.qml
        Qml/Dialogs/AjoutStockMedicamentDialog.qml
        Qml/Dialogs/ChoisirMedicamentDialog.qml
        Qml/Dialogs/ChoisirProdtuiDialog.qml
        Qml/Dialogs/AjoutStockProduitDialog.qml
        Qml/Dialogs/UtilisateurDialog.qml

        Qml/Dialogs/Configuration/Utilisateur/Suppression.qml
        Qml/Dialogs/Ventes/Factures/Edit.qml
        Qml/Dialogs/Ventes/Factures/AjoutProduit.qml
        Qml/Dialogs/AjoutStockPresentation.qml
        Qml/Dialogs/AjoutStockPresentationProduit.qml

        Qml/Utils/functions.mjs

        Qml/DataHandlers/Specialite.qml
        Qml/DataHandlers/Composition.qml
        Qml/DataHandlers/Presentation.qml
        Qml/DataHandlers/Produit.qml
        Qml/DataHandlers/PresentationProduit.qml
        Qml/DataHandlers/MedicamentPreview.qml
        Qml/DataHandlers/ProduitPreview.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(pharmacync_start PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.PharmaCync_Start
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE_GUI_IDENTIFIER com.pharmacync.app
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(pharmacync_start
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Sql
    PRIVATE Qt6::PrintSupport
)

include(GNUInstallDirs)
install(TARGETS pharmacync_start
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

