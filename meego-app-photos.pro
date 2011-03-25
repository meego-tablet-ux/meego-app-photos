VERSION = 0.2.2
TEMPLATE = subdirs 

qmlfiles.files += *.qml images/ 
qmlfiles.path += $$INSTALL_ROOT/usr/share/$$TARGET

desktop.files += *.desktop
desktop.path += $$INSTALL_ROOT/usr/share/applications

INSTALLS += qmlfiles desktop

QML_FILES += \
    *.qml

OTHER_FILES += \
    $${QML_FILES} \
    tests/*.qml

TRANSLATIONS += $${QML_FILES}
PROJECT_NAME = meego-app-photos

dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION} &&
dist.commands += git clone . $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION}/.git &&
dist.commands += mkdir -p $${PROJECT_NAME}-$${VERSION}/ts &&
dist.commands += lupdate $${TRANSLATIONS} -ts $${PROJECT_NAME}-$${VERSION}/ts/$${PROJECT_NAME}.ts &&
dist.commands += tar jcpvf $${PROJECT_NAME}-$${VERSION}.tar.bz2 $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION} &&
dist.commands += echo; echo Created $${PROJECT_NAME}-$${VERSION}.tar.bz2
QMAKE_EXTRA_TARGETS += dist
