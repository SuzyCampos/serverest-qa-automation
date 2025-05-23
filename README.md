# 📘 Testes de API ServeRest - Automação com Postman, Newman & CI/CD

Esta documentação e a coleção do Postman foram desenvolvidas como parte dos meus estudos e prática profissional na área de QA, com foco na automação de testes da API pública [ServeRest](https://serverest.dev). O objetivo é demonstrar a capacidade de criar fluxos de teste robustos, com validação de dados, cenários de sucesso e falha, e a integração com uma pipeline de CI/CD.

---

## ✨ Funcionalidades e Abordagem de Teste

A coleção `ServeRest_QA` abrange os seguintes aspectos e fluxos de teste:

* **Organização Clara:** Requisições organizadas em pastas lógicas (Ex: Auth, Produto, Carrinho).
* **Descrições Detalhadas:** Cada endpoint possui descrições claras de seu propósito e comportamento.
* **Automação com Postman Scripts:** Utilização intensiva de scripts na aba "Tests" para:
    * **Validação de Status Code:** Verifica se a resposta da API retorna o código HTTP esperado.
    * **Validação de Mensagens:** Confirma as mensagens de sucesso e erro retornadas pela API.
    * **Validação de Schema (tv4):** Garante que a estrutura e os tipos de dados das respostas da API estão conforme o esperado, aumentando a robustez dos testes.
    * **Cenários Positivos e Negativos:** Testes para o fluxo de sucesso e para situações de erro esperadas (ex: credenciais inválidas, recurso não encontrado).
* **Variáveis de Ambiente:** Uso estratégico de variáveis de ambiente (`baseUrl`, `token`, `userId`, `productId`, `currentTestUserEmail`, `currentTestUserPassword`) para:
    * Configurar a URL base da API.
    * Gerenciar dados dinâmicos (e-mails, senhas, IDs) para cada execução de teste.
    * Permitir que requisições subsequentes utilizem dados gerados por requisições anteriores (ex: token de autenticação, ID de produto).
* **Geração de Dados Dinâmicos:** Utilização de variáveis dinâmicas do Postman (`{{$timestamp}}`, `{{$randomEmail}}`, etc.) e scripts para gerar dados únicos a cada execução, prevenindo conflitos e garantindo a repetibilidade dos testes.
* **Integração CI/CD com GitHub Actions:** Automação da execução dos testes em uma pipeline de Integração Contínua, garantindo que os testes rodem automaticamente a cada `push` ou `pull request` para a branch `main`, com relatórios gerados como artefatos.

---

## 🚀 Fluxo de Teste Completo (End-to-End)

O fluxo de testes cobre as principais operações da API ServeRest em uma sequência lógica:

1.  **Criação de Usuário (`POST /usuarios`):** Cadastra um novo usuário administrador para os testes.
2.  **Login (`POST /login`):** Realiza o login com o usuário recém-criado e armazena o token de autenticação na variável de ambiente `token`.
3.  **Criação de Produto (`POST /produtos`):** Cadastra um novo produto, utilizando o token e gerando dados únicos para o produto, salvando seu `_id`.
4.  **Edição de Produto (`PUT /produtos/{_id}`):** Atualiza os dados do produto recém-criado, usando o `productId` e o `token`.
5.  **Exclusão de Produto (`DELETE /produtos/{_id}`):** Remove o produto do sistema, usando o `productId` e o `token`.
6.  **Validação de Exclusão (`GET /produtos/{_id}`):** Tenta buscar o produto recém-excluído para confirmar que ele não existe mais (espera-se um erro `400 Bad Request` com mensagem "Produto não encontrado").
7.  **Tentar Editar Produto Após Exclusão (`PUT /produtos/{_id}`):** Tenta editar o produto após sua exclusão. Conforme as "Observações Importantes", este teste é projetado para falhar e evidenciar um comportamento específico da API.

---

## 📝 Observações Importantes

* A API ServeRest possui algumas particularidades:
    * Retorna `400 Bad Request` com a mensagem "Produto não encontrado" para requisições `GET` e `PUT` em IDs que não existem, em vez do mais comum `404 Not Found`. Os scripts de teste foram adaptados para este comportamento.
    * **Comportamento de "Upsert" do `PUT` (Teste 7 - "Tentar Editar Produto Após Exclusão"):** Em alguns cenários, um `PUT` em um recurso inexistente pode resultar em uma `201 Created` (comportamento de "upsert" - *update* se existe, *insert* se não existe), em vez de um erro `404 Not Found` ou `400 Bad Request`.
        * **Propósito do Teste:** O teste "Tentar Editar Produto Após Exclusão" foi intencionalmente configurado para **falhar** (`❌ Edição de produto resultou em criação inesperada (Status 201)`).
        * **Significado da Falha:** Essa falha evidencia que, mesmo após a exclusão de um produto, a API ainda permite que um `PUT` para o ID excluído o recrie, retornando `201 Created`. Do ponto de vista de um teste de QA, isso é uma falha esperada para demonstrar que o recurso não é, de fato, inacessível para operações de escrita após a exclusão via `PUT`, o que pode ser uma divergência do comportamento esperado em um sistema real.
* Os comentários dentro do JSON do `body` das requisições **não são permitidos** pelo JSON padrão e foram removidos para garantir a funcionalidade da coleção.

---

## 🚀 Como Usar esta Coleção

Para executar os testes e explorar a automação:

### 1. Preparação (Localmente no Postman)

1.  **Importe o Environment:**
    * No Postman, vá em `Environments` (no menu lateral esquerdo).
    * Clique em `Import` e selecione o arquivo de ambiente `ServeRest_QA_Environment.postman_environment.json`.
    * Certifique-se de que o ambiente `ServeRest_QA_Environment` está **selecionado** no dropdown do Postman (canto superior direito).

2.  **Importe a Coleção:**
    * No Postman, vá em `Collections` (no menu lateral esquerdo).
    * Clique em `Import` e selecione o arquivo `ServeRest_QA.postman_collection.json`.

3.  **Execute o Fluxo de Testes:**
    * Na barra lateral de `Collections`, passe o mouse sobre a coleção `ServeRest_QA`.
    * Clique nos três pontinhos (`...`) e selecione `Run collection`.
    * No "Collection Runner", certifique-se de que:
        * Seu ambiente `ServeRest_QA_Environment` está selecionado.
        * As requisições estão na ordem correta (conforme o fluxo de teste descrito acima). Você pode arrastá-las para reordenar se necessário.
    * Clique em `Run ServeRest_QA` para iniciar a execução automatizada.

4.  **Analise os Resultados (Localmente):**
    * O Collection Runner exibirá o resultado de cada requisição (Pass/Fail) e os detalhes dos testes.
    * Abra o **Postman Console** (`Ctrl + Alt + C` ou `Cmd + Alt + C`) para ver os logs (`console.log`) dos scripts, que incluem informações sobre variáveis salvas (token, IDs).

### 2. Execução Automatizada (GitHub Actions)

A pipeline de CI/CD configurada no `.github/workflows/workflow-newman-tests.yml` executa automaticamente os testes Newman sempre que há um `push` ou `pull request` para a branch `main`.

1.  **Visualizar Execuções:**
    * No GitHub, vá para o seu repositório `serverest-qa-automation`.
    * Clique na aba `Actions`.
    * Selecione o workflow `Run ServeRest API Tests with Newman` no menu lateral.

2.  **Analisar Resultados da Pipeline:**
    * Clique na execução mais recente para ver os detalhes.
    * Verifique o status do job `newman-tests`: um **VISTO VERDE (✓)** indica sucesso, enquanto um **X VERMELHO (✗)** indica falha.
    * Dentro do job, expanda o passo `Run Newman tests` para ver o log detalhado dos testes.
    * Na seção "Artifacts" (ao final da página de detalhes da execução), você pode baixar o arquivo `newman-report.html` para uma análise detalhada dos resultados em seu navegador.
