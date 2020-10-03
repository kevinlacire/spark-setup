FROM openjdk:8
ADD setup-spark.sh /setup-spark.sh
ENTRYPOINT [ "/bin/sh", "/setup-spark.sh", "--yes", "--xrc-path=/.bashrc" ]