#!/bin/bash

WORKDIR=$(cd $(dirname $0) && pwd)
WORKDIR_B=${WORKDIR}
# while read line; do export $line; done < ${WORKDIR}/.env


rm -rf ${WORKDIR_B}/.lambda_layer/
mkdir -p ${WORKDIR_B}/.lambda_layer/python

cd ${WORKDIR_B}/.lambda_layer
pipenv lock -r > requirements.txt

pip3 install -r requirements.txt  -t python/

## mac環境などはdocker上でpythonライブラリをビルドすべし
# docker run --rm -v $(pwd):/python -w /python lambci/lambda:build-python3.8 pip install -r requirements.txt -t ./python

if [ $? != 0 ]; then
    echo ""
    echo ライブラリーのビルドに失敗しました．
    echo ""
    exit 1
fi
cp -R ${WORKDIR_B}/lambda/layer/ python/


cd ${WORKDIR_B}
npm run build


npx cdk deploy