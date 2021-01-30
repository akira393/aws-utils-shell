#!/bin/bash



if [ $# != 2 ]; then
    echo 【引数エラー】: 引数は2つ設定してください。
    echo 引数エラー: $*

    exit 1
fi

username=$1
password=$2

echo ""
echo 指定したユーザー名: $username
echo 指定したパスワード: $password

echo ""

user_pool_id="ap-northeast-1_W6oGDWOoK"

client_id="7emnlin3q3ai0ood3kil5tvdb3"

#ユーザーの存在チェック
user_name=$(aws cognito-idp list-users \
    --user-pool-id $user_pool_id \
    --query "Users[?Username == \`${username}\`].Username" \
    --output text)


if [ "$user_name" == "" ]; then
    echo ""
    echo "指定したユーザー名は存在しておりません。"
    echo "マネジメントコンソール画面にて新規ユーザーを作成するもしくは、入力したユーザー名をご確認ください。"
    echo "処理を終了します。"
    echo ""
    exit 1
fi

#ユーザーのステータスを習得
user_status=$(aws cognito-idp list-users \
    --user-pool-id $user_pool_id \
    --query "Users[?Username == \`${username}\`].UserStatus" \
    --output text)


if [ "$user_status" == CONFIRMED ];then
    echo ""
    echo 指定したユーザーのステータスは、CONFIRMEDになっています。
    echo 処理を終了します。
    echo ""
    exit 1
fi

#セッションの取得
session=`aws cognito-idp admin-initiate-auth \
    --user-pool-id $user_pool_id \
    --client-id $client_id \
    --auth-flow ADMIN_NO_SRP_AUTH \
    --auth-parameters \
    USERNAME=$username,PASSWORD=$password --query "Session" \
    --output text 2>/dev/null`

if [ $? != 0 ]; then
    echo ""
    echo パスワードが誤っています。
    echo 正しいパスワードを引数に指定後、再度実行してください。
    echo ""
    exit 1
fi


aws cognito-idp admin-respond-to-auth-challenge \
    --user-pool-id $user_pool_id \
    --client-id $client_id \
    --challenge-name NEW_PASSWORD_REQUIRED \
    --challenge-responses NEW_PASSWORD=$password,USERNAME=$username \
    --session $session >/dev/null