#!/bin/bash
# 
# Build Helper Script for qcadoo

VERSION=${QCADOO_VERSION:-2.2.10}

abort() {
    local msg=$1
    shift
    local code=${1:-1}
    echo -e "\033[31m\033[1m[ABORT]\033[0m ${msg}"
    exit ${code}
}

info() {
    echo -e "\033[32m[INFO]\033[0m $1"
}

# --------- Clone Qcadoo

info "Cloning qcadoo repositories"

git clone -q https://github.com/qcadoo/qcadoo-super-pom-open
git clone -q https://github.com/qcadoo/qcadoo-maven-plugin
git clone -q https://github.com/qcadoo/qcadoo
git clone -q https://github.com/qcadoo/mes

# --------- Download Problematic Packages

info "Downloading Prerequisites"

TMPDIR=`tempfile -d /tmp`
wget -qP ${TMPDIR} http://nexus.qcadoo.org/content/repositories/releases/org/apache/tomcat/bootstrap/8.5.12/bootstrap-8.5.12.jar
wget -qP ${TMPDIR} http://nexus.qcadoo.org/content/repositories/releases/jgrapht/jgrapht/0.8.2/jgrapht-0.8.2.jar

# --------- Super POM

info "Building qcadoo Super POM"

cd qcadoo-super-pom-open
git checkout -q ${VERSION} || abort "Failed to checkout version ${VERSION}"
mvn clean install -q || abort "Failed to build Super POM"
cd ..

# --------- Maven Plugin

info "Building qcadoo Maven Plugin"

cd qcadoo-maven-plugin
git checkout -q ${VERSION} || abort "Failed to checkout version ${VERSION}"
mvn clean install -q || abort "Failed to build Maven Plugin"
cd ..

# --------- Qcadoo Framework

cd qcadoo
git checkout -q ${VERSION} || abort "Failed to checkout version ${VERSION}"

info "Installing jgrapht"
mvn install:install-file -q \
    -DgroupId=jgrapht \
    -DartifactId=jgrapht \
    -Dversion=0.8.2 \
    -Dpackaging=jar \
    -Dfile="${TMPDIR}/jgrapht-0.8.2.jar" \
|| abort "Failed to install jgrapht"

# Note: Tests currently fail
info "Building qcadoo Framework"
mvn clean install -q -DskipTests || abort "Failed to build framework"
cd ..

# --------- MES Core

info "Building MES Core"

cd mes
git checkout -q ${VERSION} || abort "Failed to checkout version ${VERSION}"
mvn clean install -q -DskipTests || abort "Failed to build MES Core"

# --------- MES Application

cd mes-application

info "Installing tomcat-bootstrap"
mvn install:install-file -q \
    -DgroupId=org.apache.tomcat \
    -DartifactId=bootstrap \
    -Dversion=8.5.12 \
    -Dpackaging=jar \
    -Dfile="${TMPDIR}/bootstrap-8.5.12.jar" \
|| abort "Failed to install tomcat-bootstrap"

info "Building Tomcat Application"
mvn clean install -q -Ptomcat -Dprofile=package || abort "Failed to build Tomcat application"
cd ..

info "Completed building MES Tomcat Application"
