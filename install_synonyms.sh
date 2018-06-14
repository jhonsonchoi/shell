#/bin/bash

# 유사어 사전을 빌드하고 설치하는 프로그램
# 5분 주기로 실행되며, 작업지시가 있는 경우에만, 본 작업을 수행

echo "# 유사어 사전 빌드 및 설치"

cd /home/elastic/enuri/shell

JOB_TYPE=400	# 100: 메인전체색인, 200: 메인 추가색인, 300: 자동완성전체색인, 400: 유사어
JOB_EXECUTION_TYPE=1    # 1: 계획, 2: 수시
JOB_STATE=1	# 1: 시작전, 2: 진행중, 9: 종료

JAR=mkdic-1.0.jar

echo "# 작업지시 확인"
java -jar $JAR -jc $JOB_TYPE,$JOB_STATE

if [[ $? == 1 ]];
#if [[ 1 == 1 ]];
then

echo "# 작업시작 시각 취득"
START_TIME=`(date -u +"%Y%m%d%H%M%S")`

echo "# 작업레코드에 작업플래그와 시작일시를 업데이트"
java -jar $JAR -ju $JOB_TYPE,2,$START_TIME,NULL

echo "# 유사어 사전 작성"
java -jar $JAR -s

if [[ $? != 0 ]]
then

END_CODE=N
END_MESSAGE="사전작성중 에러"

else

echo "# ES 에 유사어 사전 설치"

cp c1/synonym.txt ../ansible/roles/synonyms-installer/files/enuri_synonyms.txt

cd ../ansible

ansible-playbook install-enuri-synonyms.yml -i hosts

if [[ $? != 0 ]]
then

END_CODE=N
END_MESSAGE="사전설치중 에러"

else

END_CODE=Y
END_MESSAGE="정상종료"

fi

cd ../shell

fi


echo "# 작업 종료 시각 취득"
END_TIME=`(date -u +"%Y%m%d%H%M%S")`

echo "# 작업레코드에 작업플래그와 종료일시를 업데이트"
java -jar $JAR -ju $JOB_TYPE,9,$START_TIME,$END_TIME

echo "# 작업 로그 추가"
java -jar $JAR -jla $JOB_TYPE,$JOB_EXECUTION_TYPE,$START_TIME,$END_TIME,\"$END_MESSAGE\",$END_CODE


fi
