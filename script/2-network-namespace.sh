source ./functions.sh

echo "# 네트워크 네임스페이스(netns)를 사용해 컨테이너 생성"
run_with_echo ip netns add netns0

echo -e "\n# 네트워크 네임스페이스 확인"
run_with_echo ip netns list

echo -e "\n# 네임스페이스 사용하기"
run_with_echo nsenter --net=/run/netns/netns0 iptables --list-rules
