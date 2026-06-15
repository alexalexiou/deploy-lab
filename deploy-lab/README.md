# deploy-lab

A deliberately small Spring Boot service whose only purpose is to be deployed.
The application is trivial so that all the learning goes into the pipeline:
CI/CD, containers, Kubernetes, Helm, Ingress, and a managed database.

## Phase 0 (this commit): the app and local Docker

A minimal REST API for "notes", backed by PostgreSQL with Flyway migrations
and Spring Boot Actuator health probes.

### Stack

- Java 21, Spring Boot 3.4
- Spring Web, Spring Data JPA, Validation, Actuator
- PostgreSQL, Flyway
- Testcontainers for integration tests

### Endpoints

| Method | Path             | Purpose            |
|--------|------------------|--------------------|
| GET    | /api/notes       | list all notes     |
| GET    | /api/notes/{id}  | fetch one note     |
| POST   | /api/notes       | create a note      |
| PUT    | /api/notes/{id}  | update a note      |
| DELETE | /api/notes/{id}  | delete a note      |

Health probes (these map directly onto Kubernetes later):

- Liveness:  GET /actuator/health/liveness
- Readiness: GET /actuator/health/readiness

### Run it locally with Docker

The whole thing comes up with one command. This builds the image from the
multi-stage Dockerfile and starts it next to a Postgres container.

```bash
docker compose up --build
```

Then try it:

```bash
curl -s localhost:8080/api/notes
curl -s -X POST localhost:8080/api/notes \
  -H 'Content-Type: application/json' \
  -d '{"title":"first","body":"hello"}'
curl -s localhost:8080/actuator/health/readiness
```

Stop everything:

```bash
docker compose down -v
```

### Run the app from source (without Docker)

You need a local Postgres reachable on localhost:5432 with the credentials in
`application.yml`, or just start the db container on its own:

```bash
docker compose up -d db
mvn spring-boot:run
```

### Run the tests

The integration test spins up a real Postgres via Testcontainers, so a Docker
daemon must be running.

```bash
mvn verify
```

## What comes next

- Phase 1: GitHub Actions builds and tests on every push, then pushes the image
  to a registry (ECR), authenticating to AWS with OIDC and no stored keys.
- Phase 2 onward: deploy to Kubernetes (self-managed k3s on a free EC2 instance),
  package with Helm, add an Ingress with TLS, move the database to RDS, wire the
  pipeline to deploy automatically, and post a Slack report on each deploy.
