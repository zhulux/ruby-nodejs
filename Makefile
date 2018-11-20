DOCKER_USER=astarup
NAME = ruby-nodejs
DATE = `date +"%Y%m%d"`
BUILDER_VER = builder-$(DATE)
RUNER_VER = runer-$(DATE)
GEM_TOKEN = "xxxx"

echo: 
	echo "hello world"

build-builder:
	docker build -t $(NAME):$(BUILDER_VER) -f Dockerfile.build --build-arg GEM_TOKEN=${GEM_TOKEN} .

build-runer:
	docker build -t $(NAME):$(RUNER_VER) -f Dockerfile.run .

tag-builder:
	docker tag $(NAME):$(BUILDER_VER) $(DOCKER_USER)/$(NAME):$(BUILDER_VER)

tag-runer:
	docker tag $(NAME):$(RUNER_VER) $(DOCKER_USER)/$(NAME):$(RUNER_VER)

push-builder:
	docker push $(DOCKER_USER)/$(NAME):$(BUILDER_VER)
push-runer:
	docker push $(DOCKER_USER)/$(NAME):$(RUNER_VER)
