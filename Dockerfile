FROM ruby:2.6.5	
ENV RUBYGEMS_VERSION=2.7.0

# Set default locale for the environment	
ENV LC_ALL C.UTF-8	
ENV LANG en_US.UTF-8	
ENV LANGUAGE en_US.UTF-8
ENV NODE_ENV production

LABEL "com.github.actions.name"="Building a jekyll site from configured directory, maybe deploying it."	
LABEL "com.github.actions.description"="A more configurable jekyll repo builder with configurable deployment options."	
LABEL "com.github.actions.icon"="globe"	
LABEL "com.github.actions.color"="green"	

LABEL version="0.0.2"
LABEL repository="http://github.com/MarkTuddenham/jekyll-build-optional-deploy-gh-pages"	
LABEL maintainer="Mark Tuddenham"

# Add node.js and gulp.js
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash - && \
    apt-get install -y nodejs
RUN npm install --global gulp-cli

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
