# Projeto Ping-Pong (Quebrando Blocos)

## Descrição do Projeto

Este projeto consiste em um jogo de ping-pong, desenvolvido em linguagem Assembly, onde o objetivo é quebrar todos os blocos dispostos em uma matriz de 6 colunas por 2 linhas. O jogador controla uma base que se move horizontalmente na parte inferior da tela para evitar que a bola caia fora da região do jogo. A bola se move sempre em ângulos de 45 graus, quicando nas paredes e nos blocos até que todos sejam destruídos.
O projeto do jogo foi desenvolvido na disciplina de Sistemas Embarcados I da Universidade Federal do Espírito Santo.

## Funcionalidades

1. **Início do Jogo**
   - O jogo inicia quando o usuário pressiona a tecla Enter.
   - A interface inicial permanece fixa até o início do jogo.

2. **Movimento da Bola**
   - A bola percorre a tela sempre em ângulos de 45 graus.
   - A bola não retorna na direção de onde veio.

3. **Controle da Base**
   - O jogador controla a base usando as teclas 'd'/'a' (direita e esquerda).

4. **Limites da Tela**
   - A tela possui limites à direita, esquerda e superior.
   - A parte inferior da tela é limitada pela base, onde a bola quica.

5. **Pausar e Retomar Jogo**
   - O jogo pode ser pausado a qualquer momento pressionando a tecla "p".
   - Para retomar o jogo após a pausa, pressione "p" novamente.

6. **Finalizar Jogo**
   - O jogo pode ser finalizado a qualquer momento pressionando a tecla "q".
   - Se a bola cair fora da tela, o jogo exibe a mensagem "Game Over" e pergunta se o jogador deseja reiniciar (tecla "y") ou sair (tecla "n").

7. **Quebrar Blocos**
   - A cada contato da bola com um bloco, o bloco é destruído.
   - O objetivo é destruir todos os blocos da matriz (2 filas x 6 colunas).
   - O jogo termina quando todos os blocos são quebrados.

## Instruções de Execução

1. Siga as intruções do pdf para instalar e configurar o seu DOSBox.
2. Solte os arquivos na pasta criada.
3. Execute o DOSBox e monte o local em que a pasta foi criada.
4. Execute o comando: "make.bat"
5. Espere compilar todos os arquivos, após isso, pressione enter para iniciar o jogo.
6. Utilize as teclas "a" e "d" para mover a base.
7. Pressione "p" para pausar o jogo e "p" novamente para retomar.
8. Pressione "q" para finalizar o jogo a qualquer momento.
9. Se a bola cair fora da tela, siga as instruções para reiniciar (tecla "y") ou sair do jogo (tecla "n").

## Contribuições
Contribuições são bem-vindas! Se você identificar bugs, problemas de desempenho ou tiver sugestões para melhorias, sinta-se à vontade para abrir uma issue ou enviar um pull request.

## Autores

Camila Audibert e Gustavo Nunes Lopes

Divirta-se jogando e quebrando todos os blocos!
