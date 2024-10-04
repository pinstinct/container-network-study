## 실행 방법

1. 저장소 내용을 클론 받는다.
2. Dockerfile이 있는 위치에서 다음 명령어를 실행한다.

```shell
docker build -t docker-network .
docker run --privileged --rm -it docker-network /bin/sh

# docker container 내부 
/project/script # ./1-main-network.sh
/project/script # ./2-network-namespace.sh
/project/script # ./3-virtual-ethernet-devices.sh
/project/script # ./4-second-container.sh
/project/script # ./11-virtual-network-switch.sh
/project/script # ./12-ip-routing.sh
/project/script # ./13-port-publishing.sh
```
