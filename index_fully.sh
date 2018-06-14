#/bin/bash

cd /home/elastic/enuri/shell

JOB_TYPE=100	# 전체색인
JOB_STATE=1     # 1: 시작전, 2: 진행중, 9: 종료

JAR=mkdic-1.0.jar

echo "# 작업레코드에 작업플래그와 시작일시를 업데이트"
java -jar $JAR -ju $JOB_TYPE,$JOB_STATE,NULL,NULL

