source ./functions.sh

echo "# 가상 이더넷 장치를 이용해 컨테이너 연결"
run_with_echo ip link add veth0 type veth peer name ceth0

echo -e "\n# Network devices"
ip link list

echo -e "\n# 가상 이더넷 장치 중 하나는 main 네임스페이스에 두고, 다른 장치는 netns0(앞에서 생성한 네임스페이스)로 이동"
run_with_echo ip link set ceth0 netns netns0

echo -e "\n# Network devices"
ip link list

echo -e "\n# 장치를 켜고 적절한 IP 주소를 할당하면, 장치 중 하나에서 발생하는 모든 패킷은 즉시 peer 장치에 나타나게 되고 두 개의 네트워크 네임스페이스가 연결 됨"
echo "## 장치 켜기"
run_with_echo ip link set veth0 up
echo "## IP 주소 할당"
run_with_echo ip addr add 172.18.0.11/16 dev veth0
echo "## netns0 네임스페이스 작업"
run_with_echo nsenter --net=/run/netns/netns0 ip link list
echo "## loopback 장치 켜기"
run_with_echo nsenter --net=/run/netns/netns0 ip link set lo up
echo "## 장치 켜기"
run_with_echo nsenter --net=/run/netns/netns0 ip link set ceth0 up
echo "## IP 주소 할당"
run_with_echo nsenter --net=/run/netns/netns0 ip addr add 172.18.0.10/16 dev ceth0
echo -e "\n## Network devices"
run_with_echo nsenter --net=/run/netns/netns0 ip link list

echo -e "\n# 네임스페이스간 연결 확인"
echo "## netns0 --> veth0 ping"
run_with_echo nsenter --net=/run/netns/netns0 ping -c 2 172.18.0.11
echo -e "\n## main --> ceth0 ping"
run_with_echo ping -c 2 172.18.0.10

echo -e "\n# netns0 네임 스페이스에서 다른 주소에 도달하기"
echo "## eth0 주소 알아내기"
run_with_echo ip addr show dev eth0
echo "## netns0 --> eth0 ping"
run_with_echo nsenter --net=/run/netns/netns0 ping 172.17.0.2
echo -e "\n## netns0 --> Internet ping"
run_with_echo nsenter --net=/run/netns/netns0 ping 8.8.8.8

echo -e "\n## Route table"
run_with_echo nsenter --net=/run/netns/netns0 ip route list
echo "라우팅 테이블을 보면 172.18.0.0/16 네트워크 대역의 트래픽은 ceth0 장치를 통해 전송한다. 하지만 다른 패킷은 모두 삭제된다."
