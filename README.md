## initial setup for the docker-uv-nvidia environment
1. initialize uv project
    ```bash
    uv init --python 3.12
    ```
2. write `pyproject.toml` 
    ```
    # requires-python = "==3.12.*"
    use the above line to make the uv project to exactly use a specific python version
    ```
3. write `Dockerfile`

4. write `.gitignore` and `.dockerignore`

5. make `uv.lock`
    ```bash
    uv lock
    ```
5. build the docker image
    ```bash
    docker build -t uv-nvidia-template:v0.0.1
    ```
6. write the `docker-compose.yml` accordingly

7. commit and make the first tag for version v0.0.1 then push
    If you didn't add the github remote origin yet then the below lines first.
    ```bash
    git branch -M main
    git remote add origin git@github.com:....
    ```
    commit and make the first version tag
    ```bash
    git add .
    git commit -m "version tag: v0.0.1"
    # Create the Git tag
    git tag v0.0.1
    # Push to remote (Github/Gitlab)
    git push origin main --tags
    ```
    
## when there is a new update[new version]
### case 1) when there is a package update 
1. inside the running container add and test the package first
    ```bash
    docker exec -it my-dev-container bash
    uv add pandas --dependency-group data
    # check if things work ...
    exit
    ```
    Result: since of the mount, your local `pyproject.toml` and `uv.lock` are now updated
    

2. build the new docker image version
    ```bash
    docker build -t $(IMAGE_NAME):$(VERSION)
    ```
3. update the `docker-compose.yml` accordingly

4. commit
    ```bash
    git add pyproject.toml uv.lock docker-compose.yml
    git commit -m "build: added pandas, bumped to v0.0.2"
    ```
5. tag
    ```bash
    git tag v0.0.2
    ```
6. push
    ```bash
    git push origin main --tags
    ```
### case 2) when system/infastructure changes
1. modify your `Dockerfile` (eg. adding a library to the `apt-get` block)
2. build the new docker image version
    ```bash
    docker build -t $(IMAGE_NAME):$(VERSION)
    ```
3. update the `docker-compose.yml` accordingly

4. verify: Run docker compose up to ensure the container starts correctly with the new system libraries.

5. commit
    ```bash
    git add Dockerfile docker-compose.yml
    git commit -m "build: added library .."
    ```
6. tag
    ```bash
    git tag v0.0.2
    ```
7. push
    ```bash
    git push origin main --tags
    ```
