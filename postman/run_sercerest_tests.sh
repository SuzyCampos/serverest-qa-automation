#!/bin/bash

# Caminho dos arquivos Postman
COLLECTION="ServeRest_QA.postman_collection.json"
ENVIRONMENT="ServeRest_QA_Environment.postman_environment.json"
REPORT="relatorio_sercerest.html"

# Rodar os testes com o Newman e gerar relatório HTML
newman run "$COLLECTION" \
    -e "$ENVIRONMENT" \
    -r cli,html \
    --reporter-html-export "$REPORT"

