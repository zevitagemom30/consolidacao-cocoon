#!/bin/bash

spinner() {
    local PROC="$1"
    local str="${2:-"carregando..."}"
    local delay="0.3"
    tput civis
    printf "\033[1;32m"
    while [ -d /proc/$PROC ]; do
        printf '\033[s\033[u[/] %s\033[u' "$str"; sleep "$delay"
        printf '\033[s\033[u[—] %s\033[u' "$str"; sleep "$delay"
        printf '\033[s\033[u[\] %s\033[u' "$str"; sleep "$delay"
        printf '\033[s\033[u[|] %s\033[u' "$str"; sleep "$delay"
    done
    printf '\033[s\033[u%*s\033[u\033[0m' $((${#str}+6)) " "
    tput cnorm
    return 0
}

promptMessage() {
    local str="$1"
    if [ $str -eq 0 ]; then
        printf "\033[1;32m"
        echo "Execução concluída."
        printf "\033[0m"
    else
        printf "\033[1;31m"
        echo "Erro na execução, verifique as configurações e tente novamente."
        printf "\033[0m"
    fi
}

# Diretório que contém os projetos
diretorio="source"

# Lista todas as pastas dentro do diretório
pastas=$(find ${diretorio} -mindepth 1 -maxdepth 1 -type d)

# Verifica se existem pastas disponíveis
if [ -z "$pastas" ]; then
  printf "\033[1;31m"
  echo "Nenhuma pasta encontrada no diretório ${diretorio}."
  exit 1
fi

# Prompt de seleção das pastas
printf "\033[0;37m"
echo "Selecione as aplicações a serem manuseadas:"
printf "\033[0m"

select pasta in $pastas; do
  # Verifica se uma opção válida foi selecionada
  if [[ -n $pasta ]]; then
    echo "Aplicação selecionada: $pasta"

    # Extrai o nome da pasta sem o caminho completo
    nome_pasta=$(basename ${pasta})

    # Verifica se existe um arquivo .yml correspondente
    arquivo_yml="${pasta}/docker-compose.yml"
    if [ -f "${arquivo_yml}" ]; then

    sleep 0.3 &
    spinner $!
    echo "Executando ${arquivo_yml}..."
      
      # Prompt para comando o usuário deseja executar
      read -p "Selecione uma ação: (build/up/down/restart) " acao

      case $acao in
          build)
              sleep 0.3 &
              spinner $!
              echo "Executando comando 'docker-compose up -d --build'..."
              sudo docker-compose -f "${arquivo_yml}" up -d --build
              promptMessage $?
              ;;
          up)
              sleep 0.3 &
              spinner $!
              echo "Executando comando 'docker-compose up -d'..."
              sudo docker-compose -f "${arquivo_yml}" up -d
              promptMessage $?
              ;;
          down)
              sleep 0.3 &
              spinner $!
              echo "Executando comando 'docker-compose down'..."
              sudo docker-compose -f "${arquivo_yml}" down
              promptMessage $?
              ;;
          restart)
              sleep 0.3 &
              spinner $!
              echo "Executando comando 'docker-compose restart'..."
              sudo docker-compose -f "${arquivo_yml}" restart
              promptMessage $?
              ;;
          *)
              printf "\033[1;31m"
              echo "Ação inválida."
              printf "\033[0m"
              ;;
      esac
       
    else
      printf "\033[1;31m"
      echo "Arquivo docker-compose.yml não encontrado na pasta ${nome_pasta}."
      printf "\033[0m"
    fi
    break
  else
    printf "\033[1;31m"
    echo "Opção inválida. Por favor, selecione um número válido."
    printf "\033[0m"
  fi
done
