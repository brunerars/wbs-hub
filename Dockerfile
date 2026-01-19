FROM python:3.11-slim

WORKDIR /app

# Dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Dependências Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Código da aplicação
COPY . .

# Copia data/ para template (será usado pelo entrypoint)
RUN cp -r /app/data /app/data-template

# Porta do Streamlit
EXPOSE 8501

# Health check
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health || exit 1

# Entrypoint: copia dados iniciais se volume estiver vazio
CMD sh -c 'if [ ! -f /app/data/projetos.json ]; then cp -r /app/data-template/* /app/data/; fi && streamlit run app.py --server.address=0.0.0.0 --server.port=8501'
