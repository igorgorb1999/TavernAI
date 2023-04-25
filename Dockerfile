FROM node:19.1.0-alpine3.16

# Arguments
ARG APP_HOME=/home/node/app

# Create app directory
WORKDIR ${APP_HOME}

# Install app dependencies
COPY package*.json ./
RUN \
  echo "*** Install npm packages ***" && \
  npm install

# Bundle app source
COPY . ./

# Give permissions for the files
RUN chgrp -R 0 "${APP_HOME}/public" && \
    chmod -R g=u "${APP_HOME}/public" && \
    chgrp -R 0 "${APP_HOME}/config" && \
    chmod -R g=u "${APP_HOME}/config" && \
    chgrp 0 "${APP_HOME}" && \
    chmod g=u "${APP_HOME}"

# Copy default chats, characters and user avatars to <folder>.default folder
RUN \
  echo "*** Copy default chats, characters and user avatars to <folder>.default folder ***" && \
  mv "./public/characters"    "./public/characters.default" --ignore-permissions && \
  mv "./public/chats"         "./public/chats.default" --ignore-permissions && \
  mv "./public/User Avatars"  "./public/User Avatars.default" --ignore-permissions && \
  mv "./public/settings.json"   "./public/settings.json.default" --ignore-permissions && \

  echo "*** Create symbolic links to config directory ***" && \
  ln -s "${APP_HOME}/config/characters"     "${APP_HOME}/public/characters" && \
  ln -s "${APP_HOME}/config/chats"          "${APP_HOME}/public/chats" && \
  ln -s "${APP_HOME}/config/User Avatars"   "${APP_HOME}/public/User Avatars" && \
  ln -s "${APP_HOME}/config/settings.json"  "${APP_HOME}/public/settings.json"

# Cleanup unnecessary files
RUN \
  echo "*** Cleanup ***" && \
  mv "./docker/docker-entrypoint.sh" "./" --ignore-permissions && \
  rm -rf "./docker" && \
  rm -rf "./.git" && \
  echo "*** Make docker-entrypoint.sh executable ***" && \
  chmod +x "./docker-entrypoint.sh" && \
  echo "*** Convert line endings to Unix format ***" && \
  dos2unix "./docker-entrypoint.sh"

EXPOSE 8000

ENTRYPOINT [ "/bin/sh", "-c", "./docker-entrypoint.sh" ]
