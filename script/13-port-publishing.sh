source ./functions.sh

echo "컨테이너 내부에 서버 실행"
run_backgroud_with_echo nsenter --net=/run/netns/netns0 python3 -m http.server --bind 172.18.0.10 5000
run_with_echo sleep 3 
run_with_echo curl 172.18.0.10:5000
run_with_echo curl 172.17.0.2:5000
echo "호스트의 eth0 인터페이스 5000포트에 도착하는 모든 패킷을 172.18.0.10:5000 목적지로 전달해야 한다. 다른 말로 하면, 호스트의 eth0 인터페이스에 컨테이너의 5000포트를 게시해야 한다."

echo -e "\n# 포트 게시"
echo "## 외부 트래픽에 대한 포트 게시"
run_with_echo iptables -t nat -A PREROUTING -d 172.17.0.2 -p tcp -m tcp --dport 5000 -j DNAT --to-destination 172.18.0.10:5000
echo "## 내부 트래픽에 대한 포트 게시(PREROUTING 체인을 통과하지 않기 때문에)"
run_with_echo iptables -t nat -A OUTPUT -d 172.17.0.2 -p tcp -m tcp --dport 5000 -j DNAT --to-destination 172.18.0.10:5000
echo "## 브릿지 네트워크를 통한 트래픽 가로채기"
run_with_echo modprobe br_netfilter
echo "## 연결 확인"
run_with_echo curl 172.17.0.2:5000
