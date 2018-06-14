#/bin/bash

cd /home/elastic/enuri/shell

JOB_TYPE=101	# 전체색인
JOB_EXECUTION_TYPE=1    # 계획, 수시, CLI
JOB_STATE=1     # 1: 시작전, 2: 진행중, 9: 종료

JAR=mkdic-1.0.jar

echo "# 작업지시 확인"
java -jar $JAR -jc $JOB_TYPE,$JOB_STATE

# 작업지시 상태이면 작업 수행
#if [[ $? == 1 ]];
if [[ $? == 1 ]];
then

echo "# 작업시작 시각 취득"
START_TIME=`(date -u +"%Y%m%d%H%M%S")`

echo "# 작업레코드에 작업플래그와 시작일시를 업데이트"
java -jar $JAR -ju $JOB_TYPE,2,$START_TIME,NULL

echo "# 단어 csv 작성"
java -jar $JAR -d1

echo "# 복합어 csv 작성"
java -jar $JAR -d2

echo "# 사전 빌드"
docker run --rm -v /home/elastic/enuri/shell/c1:/var/lib/mecab dict-builder bash my.sh

echo "# ES 에 mecab 사전 설치"

cp c1/unk.dic c1/sys.dic ../ansible/roles/mecab-dic-installer/files

cd ../ansible

ansible-playbook install_mecab_tt_dict.yml -i hosts

cd ../shell

echo "# 불용어 csv 작성"
java -jar $JAR -d3

cp c1/stop.txt ../ansible/roles/stops-installer/files/enuri_stopwords.txt

echo "# ES 에 불용어 사전 설치"

cd ../ansible

ansible-playbook install-enuri-tt-stops.yml -i hosts

cd ../shell

END_CODE=Y
END_MESSAGE="정상종료"


# 작업 종료 시각 취득
END_TIME=`(date -u +"%Y%m%d%H%M%S")`

echo "# 작업레코드에 작업플래그와 종료일시를 업데이트"
java -jar $JAR -ju $JOB_TYPE,9,$START_TIME,$END_TIME

echo "# 작업 로그 추가"
java -jar $JAR -jla $JOB_TYPE,$JOB_EXECUTION_TYPE,$START_TIME,$END_TIME,\"$END_MESSAGE\",$END_CODE

#cd ../ansible

#ansible-playbook stop_elasticsearch.yml -i hosts

#sleep 30s

#ansible-playbook start_elasticsearch.yml -i hosts

fi
