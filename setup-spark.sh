#!/bin/bash

SPARK_VERSION="2.4.6"
HADOOP_VERSION="2.7.7"
SCALA_VERSION=""
WITH_SCALA_VERSION=""
SPARK_INSTALL_PATH="/opt/spark"
HADOOP_INSTALL_PATH="/opt/hadoop"
SPARK_TMP_PATH="/tmp/spark.tgz"
HADOOP_TMP_PATH="/tmp/hadoop.tgz"
XRC_PATH="~/.zshrc"

for i in "$@"; do
  case ${i} in
    --scala-version=*)
      SCALA_VERSION="${i#*=}"
      WITH_SCALA_VERSION="-scala-$SCALA_VERSION"
      echo "Scala version set to $SCALA_VERSION"
    shift
    ;;
    --spark-version=*)
      SPARK_VERSION="${i#*=}"
      echo "Apache Spark version set to $SPARK_VERSION"
    shift
    ;;
    --hadoop-version=*)
      HADOOP_VERSION="${i#*=}"
      echo "Apache Hadoop version set to $HADOOP_VERSION"
    shift
    ;;
    --spark-install-path=*)
      SPARK_INSTALL_PATH="${i#*=}"
      echo "Apache Spark install path set to $SPARK_INSTALL_PATH"
    shift
    ;;
    --hadoop-install-path=*)
      HADOOP_INSTALL_PATH="${i#*=}"
      echo "Apache Hadoop install path set to $HADOOP_INSTALL_PATH"
    shift
    ;;
    --spark-tmp-path=*)
      SPARK_TMP_PATH="${i#*=}"
      echo "Apache Spark temporary path set to $SPARK_TMP_PATH"
    shift
    ;;
    --hadop-tmp-path=*)
      HADOOP_TMP_PATH="${i#*=}"
      echo "Apache Hadoop temporary path set to $HADOOP_TMP_PATH"
    shift
    ;;
    --xrc-path=*)
      XRC_PATH="${i#*=}"
      echo ".*rc path set to $XRC_PATH"
    shift
    ;;
    --yes)
      YES=true
      echo "Auto approuve parameters validation"
    shift
    ;;
    -h|--help|*)
      echo "Handled parameters"
      echo "--scala-version"
      echo "--spark-version"
      echo "--hadoop-version"
      echo "--spark-install-path"
      echo "--hadoop-install-path"
      echo "--spark-tmp-path"
      echo "--hadoop-tmp-path"
      echo "--xrc-path"
      echo "--yes"
    ;;
  esac
done

if [ -z $SCALA_VERSION ]; then
  SCALA_VERSION="undefined"
fi

echo "================="
echo "Install summary :"
echo "- Apache Spark :"
echo "  - version : $SPARK_VERSION"
echo "  - temporary path : $SPARK_TMP_PATH"
echo "  - install path : $SPARK_INSTALL_PATH"
echo "- Apache Hadoop :"
echo "  - version : $HADOOP_VERSION"
echo "  - temporary path : $HADOOP_TMP_PATH"
echo "  - install path : $HADOOP_INSTALL_PATH"
echo "- Scala version : $SCALA_VERSION"
echo "- .*rc path : $XRC_PATH"
echo "================="

if [ -z ${YES} ]; then
  read -p "Continue ? (Y/N): " confirm 
  if [ $confirm != "Y" ]; then
    exit 1
  fi
fi

if [ -z $JAVA_HOME ]; then
  echo "Missing JAVA_HOME aborting install"
  exit 1
fi

echo "Downloading Apache Spark $SPARK_VERSION to $SPARK_TMP_PATH"
wget -O $SPARK_TMP_PATH "https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-without-hadoop$WITH_SCALA_VERSION.tgz"

echo "Downloading Spache Hadoop $HADOOP_VERSION to $HADOOP_TMP_PATH"
wget -O $HADOOP_TMP_PATH "https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"

echo "Creating final install folders $SPARK_INSTALL_PATH & $HADOOP_INSTALL_PATH"
sudo mkdir -p $SPARK_INSTALL_PATH $HADOOP_INSTALL_PATH
sudo chown -R $USER:$USER $SPARK_INSTALL_PATH $HADOOP_INSTALL_PATH

echo "Extracting Apache Spark archive to $SPARK_INSTALL_PATH"
tar -xzvf $SPARK_TMP_PATH -C $SPARK_INSTALL_PATH  --strip 1

echo "Extracting Apache Hadoop archive to $HADOOP_INSTALL_PATH"
tar -xzvf $HADOOP_TMP_PATH -C $HADOOP_INSTALL_PATH  --strip 1

echo "Appending Environment variables to $XRC_PATH"
echo "" >> "$XRC_PATH"
echo "====== Spark environment variables ======" >> "$XRC_PATH"
echo "export SPARK_HOME=$SPARK_INSTALL_PATH" >> "$XRC_PATH"
echo "export HADOOP_HOME=$HADOOP_INSTALL_PATH" >> "$XRC_PATH"
echo "export PATH=$PATH:$SPARK_INSTALL_PATH/bin:$SPARK_INSTALL_PATH/sbin:$HADOOP_INSTALL_PATH/bin:$HADOOP_INSTALL_PATH/sbin" >> "$XRC_PATH"
echo "====== End ======" >> "$XRC_PATH"
echo "" >> "$XRC_PATH"
source "$XRC_PATH"

echo "Setup $SPARK_INSTALL_PATH/conf/spark-env.sh based on template"
cp $SPARK_INSTALL_PATH/conf/spark-env.sh.template "$SPARK_INSTALL_PATH/conf/spark-env.sh"
echo "export HADOOP_HOME=$HADOOP_INSTALL_PATH" >> "$SPARK_INSTALL_PATH/conf/spark-env.sh"
echo "export HADOOP_CONF_DIR=$HADOOP_INSTALL_PATH/etc/hadoop" >> "$SPARK_INSTALL_PATH/conf/spark-env.sh"
echo "export SPARK_DIST_CLASSPATH=$($HADOOP_INSTALL_PATH/bin/hadoop classpath)" >> "$SPARK_INSTALL_PATH/conf/spark-env.sh"

echo "Cleanup temporary files $SPARK_TMP_PATH & $HADOOP_TMP_PATH"
rm -f "$SPARK_TMP_PATH" "$HADOOP_TMP_PATH"

echo "Install finished successfully ! Let's aggregate some data ;)"

exit 0