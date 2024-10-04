run_with_echo() {
    local command="$@"
    local result

    # 명령어 출력
    echo "Executing command: $command"

    # 명령어 실행결과 변수에 저장 
    result=$(eval "$command")
    
    # 결과 출력 
    if [[ -n "$result" ]]; then
        echo "[Result]"
        echo "$result"
    fi
}

run_backgroud_with_echo() {
    local command="$@"
    local result

    # 명령어 출력
    echo "Executing command: $command"

    # 명령어 실행결과 변수에 저장 
    eval $command > server.log 2>&1 &
}