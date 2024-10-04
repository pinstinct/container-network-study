source ./functions.sh

echo "# 구분하기 쉽게 새로운 체인 추가"
run_with_echo iptables --new-chain MAIN_SPACE
echo ""
run_with_echo ./inspect-net-context.sh
