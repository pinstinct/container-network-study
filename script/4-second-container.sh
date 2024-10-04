source ./functions.sh

echo "# 두번째 컨테이너 생성"
echo "## 네트워크 네임스페이스를 사용해 컨테이너 생성"
run_with_echo ip netns add netns1
echo "## 가상 이더넷 장치를 이용해 컨테이너에 연결"
run_with_echo ip link add veth1 type veth peer name ceth1
echo "## 장치 켜기"
run_with_echo ip link set veth1 up
echo "## IP 주소 할당"
run_with_echo ip addr add 172.18.0.21/16 dev veth1

echo -e "\n# 가상 이더넷 장치 중 하나를 다른 네임스페이스로 이동"
run_with_echo ip link set ceth1 netns netns1
echo "## 장치 켜기"
run_with_echo nsenter --net=/run/netns/netns1 ip link set lo up
run_with_echo nsenter --net=/run/netns/netns1 ip link set ceth1 up
echo "## IP 주소 할당"
run_with_echo nsenter --net=/run/netns/netns1 ip addr add 172.18.0.20/16 dev ceth1

echo -e "\n## Route table"
run_with_echo ip route list
echo ""
run_with_echo nsenter --net=/run/netns/netns1 ip route list

echo -e "\n# 연결 확인"
echo "## netns1 --> veth1"
run_with_echo nsenter --net=/run/netns/netns1 ping -c 2 172.18.0.21
echo -e "\n## main --> ceth1"
run_with_echo ping -c 2 172.18.0.20
echo -e "\n## netns0 --> veth1"
run_with_echo nsenter --net=/run/netns/netns0 ping -c 2 172.18.0.21
echo -e "\n## netns0 --> ceth1"
run_with_echo nsenter --net=/run/netns/netns0 ping -c 2 172.18.0.20

echo -e "\n# Route table"
run_with_echo ip route list
echo "같은 IP 네트워크 대역에 두 개의 컨테이너가 있다. 두번째 컨테이너가 veth1 장치에 핑할때, 라우팅 테이블 첫번째가 선택되고 연결이 끊어진다. 첫번째 라우트를 삭제하면 동작하겠지만, 반대로 netns0 컨테이너가 먹통이 될 것이다. 또는 netns1이 다른 IP 네트워크를 선택하면 잘 작동할 것이다. 하지만, 여러 컨테이너가 하나의 IP 네트워크를 사용하는 것은 정당한 사용 케이스입니다."