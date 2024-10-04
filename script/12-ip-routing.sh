source ./functions.sh

echo "# 컨테이너와 main 네임스페이스와 연결 확인"
run_with_echo ip addr show dev eth0
echo "## netns0 --> eth0 ping"
run_with_echo nsenter --net=/run/netns/netns0 ping -c 2 172.17.0.2
echo -e "\n## main --> ceth0 ping"
run_with_echo ping -c 2 172.18.0.10
echo -e "\n## main --> ceth1 ping"
run_with_echo ping -c 2 172.18.0.20

echo -e "\n# main과 컨테이너와 연결 설정"
run_with_echo ip addr add 172.18.0.1/16 dev br0
run_with_echo ip route list

echo -e "\n# main과 컨테이너 연결 확인"
echo "## main --> ceth0 ping"
run_with_echo ping -c 2 172.18.0.10
echo -e "\n## main --> ceth1 ping"
run_with_echo ping -c 2 172.18.0.20
echo -e "\n## netns0 --> eth0"
run_with_echo nsenter --net=/run/netns/netns0 ping -c 2 172.17.0.2
echo "여전히 호스트의 eth0에 연결 안 됨"

echo -e "\n# 컨테이너 라우팅 테이블에 기본 라우트 추가"
run_with_echo nsenter --net=/run/netns/netns0 ip route list
run_with_echo nsenter --net=/run/netns/netns0 ip route add default via 172.18.0.1
run_with_echo nsenter --net=/run/netns/netns1 ip route add default via 172.18.0.1
run_with_echo nsenter --net=/run/netns/netns0 ip route list


echo -e "\n# 연결 확인"
echo "## netns0 --> eth0"
run_with_echo nsenter --net=/run/netns/netns0 ping -c 2 172.17.0.2

echo -e "\n# 컨테이너를 외부 세계에 연걸"
echo "## 리눅스에서 패킷 전달(즉, 라우터 기능) 기능 활성화"
run_with_echo "echo 1 > /proc/sys/net/ipv4/ip_forward"
echo "호스트 머신이 라우터로 바뀌고, 브릿지 인터페이스는 컨테이너를 위한 기본 게이트웨이가 됨"
run_with_echo nsenter --net=/run/netns/netns0 ping -c 2 8.8.8.8
echo "컨테이너가 패킷을 외부 세계로 보내면, 도착지 서버는 컨테이너의 IP 주소가 비공개이기 때문에 컨테이너로 다시 패킷을 전송할 수 없다."
echo "즉, 해당 IP에 대한 라우팅 규칙을 로컬 네트워크만 알고 있다. 이 문제에 대한 해결책은 네트워크 주소 변환(NAT, Network Address Translation) 이다."
echo "외부 네트워크로 나가기 전에, 컨테이너에서 생성된 패킷은 source IP 주소가 호스트의 외부 인터페이스 주소로 바꾼다."
echo "또한, 호스트는 모든 기존 매핑을 추적하고 도착 시 패킷을 컨테이너로 다시 전달하기 전에 IP 주소를 복원한다."
echo "수동으로 구성하기 복잡하지만, 이 작업을 iptabels 명령어로 처리 할 수 있다."

echo -e "\n# NAT 규칙 설정"
run_with_echo iptables -t nat -A POSTROUTING -s 172.18.0.0/16 ! -o br0 -j MASQUERADE
echo "브릿지 인터페이스로 이동하는 패킷을 제외하고, 172.18.0.0/16 네트워크에서 시작된 모든 패킷을 위장하도록 요청하는 POSTROUTING 체인 NAT 테이블에 새 규칙을 추가한다."
run_with_echo nsenter --net=/run/netns/netns0 ping -c 2 8.8.8.8
