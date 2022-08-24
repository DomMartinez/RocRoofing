# Install all npm dependencies as its own
# stage in order to cache the node_modules dirs
FROM node:18.7.0-alpine3.15 AS FRONTEND_DEPENDENCY_STAGE
WORKDIR /src
ADD ./frontend/package.json /src/package.json
RUN npm install

FROM node:18.7.0-alpine3.15 AS WEBAPP_DEPENDENCY_STAGE
WORKDIR /src
ADD ./webapp/package.json /src/package.json
RUN npm install

FROM node:18.7.0-alpine3.15 AS FRONTEND_BUILD_STAGE
ADD ./frontend/ /src/
COPY --from=FRONTEND_DEPENDENCY_STAGE /src/node_modules/ /src/node_modules/
WORKDIR /src
RUN npm run build

FROM node:18.7.0-alpine3.15
ADD ./webapp/ /src/
COPY --from=WEBAPP_DEPENDENCY_STAGE /src/package.json /src/package.json
COPY --from=WEBAPP_DEPENDENCY_STAGE /src/node_modules/ /src/node_modules/
WORKDIR /src
RUN npm run build
COPY --from=FRONTEND_BUILD_STAGE /src/theme/ /src/dist/public/

RUN adduser -D nonroot && chown -R nonroot /src/dist
USER nonroot
WORKDIR /src/dist
ENTRYPOINT ["node", "index.js"]
