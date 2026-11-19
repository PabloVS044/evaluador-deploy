# Despliegue del Evaluador semántico sin tocar el repo original:
# clona el código público y construye frontend + API en una sola imagen.
ARG REPO=https://github.com/PabloVS044/logica-matematica-proy1.git
ARG REF=main

FROM alpine/git AS source
ARG REPO
ARG REF
RUN git clone --depth 1 --branch ${REF} ${REPO} /src

FROM node:22-slim AS web
RUN npm install -g pnpm@10
WORKDIR /app/frontend
COPY --from=source /src/frontend/ ./
RUN pnpm install --frozen-lockfile && pnpm build

FROM python:3.12-slim
WORKDIR /app
COPY --from=source /src/backend/ backend/
RUN pip install --no-cache-dir -e backend
COPY --from=web /app/frontend/dist frontend/dist
ENV PORT=8000
EXPOSE 8000
CMD ["sh", "-c", "uvicorn evaluador.api.main:app --host 0.0.0.0 --port ${PORT}"]
