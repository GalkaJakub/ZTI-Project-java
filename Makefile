BACKEND_DIR=backend/wsp
CLIENT_DIR=client/wsp

.PHONY: backend-build backend-run backend-test backend-clean \
        docker-up docker-down docker-logs docker-ps \
        flutter-run flutter-web flutter-build-web flutter-clean flutter-get \
        deploy all clean

backend-build:
	cd $(BACKEND_DIR) && mvn clean package

backend-run:
	cd $(BACKEND_DIR) && mvn spring-boot:run

backend-test:
	cd $(BACKEND_DIR) && mvn test

backend-clean:
	cd $(BACKEND_DIR) && mvn clean

docker-up:
	cd $(BACKEND_DIR) && docker-compose up -d --build

docker-down:
	cd $(BACKEND_DIR) && docker-compose down

docker-logs:
	docker logs -f ZTI-wsp-backend

docker-ps:
	docker ps

flutter-get:
	cd $(CLIENT_DIR) && flutter pub get

flutter-run:
	cd $(CLIENT_DIR) && flutter run

flutter-build-web:
	cd $(CLIENT_DIR) && flutter build web

flutter-run-web:
	cd $(CLIENT_DIR) && flutter build web
	cd $(CLIENT_DIR)/build/web && python3 -m http.server 3000

flutter-clean:
	cd $(CLIENT_DIR) && flutter clean

all: backend-build flutter-get

clean: backend-clean flutter-clean
