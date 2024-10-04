source ./functions.sh

echo "# 기존 구성 제거"
run_with_echo ip netns delete netns0
run_with_echo ip netns delete netns1
run_with_echo ip link delete veth0
run_with_echo ip link delete veth1

echo -e "\n# 첫번째 컨테이너 생성"
run_with_echo ip netns add netns0
run_with_echo ip link add veth0 type veth peer name ceth0
run_with_echo ip link set veth0 up
run_with_echo ip link set ceth0 netns netns0
run_with_echo nsenter --net=/run/netns/netns0 ip link set lo up
run_with_echo nsenter --net=/run/netns/netns0 ip link set ceth0 up
run_with_echo nsenter --net=/run/netns/netns0 ip addr add 172.18.0.10/16 dev ceth0

echo -e "\n# 두번째 컨테이너 생성"
run_with_echo ip netns add netns1
run_with_echo ip link add veth1 type veth peer name ceth1
run_with_echo ip link set veth1 up
run_with_echo ip link set ceth1 netns netns1
run_with_echo nsenter --net=/run/netns/netns1 ip link set lo up
run_with_echo nsenter --net=/run/netns/netns1 ip link set ceth1 up
run_with_echo nsenter --net=/run/netns/netns1 ip addr add 172.18.0.20/16 dev ceth1

echo -e "\n# Route table"
run_with_echo ip route list

echo -e "\n# 브릿지 장치 생성"
run_with_echo ip link add br0 type bridge
run_with_echo ip link set br0 up 

echo -e "\n# 브릿지와 컨테이너 연결"
run_with_echo ip link set veth0 master br0
run_with_echo ip link set veth1 master br0

echo -e "\n# 연결 확인"
echo "## netns0 --> ceth1 ping (첫번째 컨테이너 --> 두번째 컨테이너)"
run_with_echo nsenter --net=/run/netns/netns0 ping -c 2 172.18.0.20
echo -e "\n## netns1 --> ceth0 ping (두번째 컨테이너 --> 첫번째 컨테이너)"
run_with_echo nsenter --net=/run/netns/netns1 ping -c 2 172.18.0.10
echo "veth0과 veth1에 아무 구성도 하지 않고, ceth0과 ceth1 끝에 두 개의 IP 주소를 명시적으로 할당했다."
echo "그러나 둘 다 같은 Ethernet 세그먼트에 있기 때문에, L2 레벨에서 접속 가능하다."

echo -e "\n# IP 주소와 그에 대응하는 링크 계층 주소(예: MAC 주소) 간의 매핑 확인"
run_with_echo nsenter --net=/run/netns/netns0 ip neigh
run_with_echo nsenter --net=/run/netns/netns1 ip neigh
